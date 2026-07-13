package masterdata

import (
	"context"
	"fmt"
	"net/mail"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
)

type Actor struct {
	UserID     uuid.UUID
	ActiveRole string
	RequestID  string
	IPAddress  string
	UserAgent  string
}

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) List(ctx context.Context, resource Resource, params ListParams) (ListResult, error) {
	return s.repo.List(ctx, resource, params)
}

func (s *Service) Get(ctx context.Context, resource Resource, id uuid.UUID) (map[string]any, error) {
	return s.repo.Get(ctx, resource, id)
}

func (s *Service) Create(ctx context.Context, resource Resource, payload map[string]any, actor Actor) (map[string]any, error) {
	if err := validateKnownFields(resource, payload); err != nil {
		return nil, err
	}
	normalized := normalizePayload(resource, payload)
	if err := validatePayload(resource, normalized, true); err != nil {
		return nil, err
	}
	exists, err := s.repo.DuplicateExists(ctx, resource, normalized, nil)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrDuplicate
	}

	created, err := s.repo.Create(ctx, resource, normalized)
	if err != nil {
		if isDuplicateDBError(err) {
			return nil, ErrDuplicate
		}
		if isForeignKeyDBError(err) {
			return nil, ErrForeignKey
		}
		return nil, err
	}
	if err := s.audit(ctx, resource, "create", actor, nil, created); err != nil {
		return nil, err
	}
	return created, nil
}

func (s *Service) Update(ctx context.Context, resource Resource, id uuid.UUID, payload map[string]any, actor Actor) (map[string]any, error) {
	if err := validateKnownFields(resource, payload); err != nil {
		return nil, err
	}
	oldValue, err := s.repo.Get(ctx, resource, id)
	if err != nil {
		return nil, err
	}
	normalized := normalizePayload(resource, payload)
	if err := validatePayload(resource, normalized, false); err != nil {
		return nil, err
	}
	merged := mergeForDuplicate(resource, oldValue, normalized)
	exists, err := s.repo.DuplicateExists(ctx, resource, merged, &id)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrDuplicate
	}

	updated, err := s.repo.Update(ctx, resource, id, normalized)
	if err != nil {
		if isDuplicateDBError(err) {
			return nil, ErrDuplicate
		}
		if isForeignKeyDBError(err) {
			return nil, ErrForeignKey
		}
		return nil, err
	}
	if err := s.audit(ctx, resource, "update", actor, oldValue, updated); err != nil {
		return nil, err
	}
	return updated, nil
}

func (s *Service) Delete(ctx context.Context, resource Resource, id uuid.UUID, actor Actor) (map[string]any, error) {
	oldValue, err := s.repo.Get(ctx, resource, id)
	if err != nil {
		return nil, err
	}
	deleted, err := s.repo.Delete(ctx, resource, id)
	if err != nil {
		return nil, err
	}
	if err := s.audit(ctx, resource, "deactivate", actor, oldValue, deleted); err != nil {
		return nil, err
	}
	return deleted, nil
}

func (s *Service) audit(ctx context.Context, resource Resource, action string, actor Actor, oldValue any, newValue any) error {
	userID := actor.UserID
	activeRole := actor.ActiveRole
	var entityID *uuid.UUID
	if item, ok := newValue.(map[string]any); ok {
		if parsed, ok := parseMapUUID(item, "id"); ok {
			entityID = &parsed
		}
	}
	if entityID == nil {
		if item, ok := oldValue.(map[string]any); ok {
			if parsed, ok := parseMapUUID(item, "id"); ok {
				entityID = &parsed
			}
		}
	}
	return s.repo.InsertAudit(ctx, AuditEntry{
		UserID: &userID, ActiveRole: &activeRole, Action: resource.Name + "." + action, EntityType: resource.Name,
		EntityID: entityID, OldValue: mustJSON(oldValue), NewValue: mustJSON(newValue), RequestID: actor.RequestID,
		IPAddress: actor.IPAddress, UserAgent: actor.UserAgent,
	})
}

func normalizePayload(resource Resource, payload map[string]any) map[string]any {
	result := map[string]any{}
	for _, field := range resource.Fields {
		value, ok := payload[field.Name]
		if !ok && field.APIName != "" {
			value, ok = payload[field.APIName]
		}
		if !ok {
			continue
		}
		result[field.Name] = normalizeFieldValue(resource, field, value)
	}
	return result
}

func normalizeFieldValue(resource Resource, field Field, value any) any {
	if value == nil {
		return nil
	}
	if text, ok := value.(string); ok {
		trimmed := strings.TrimSpace(text)
		if trimmed == "" && !field.Required && field.Name != resource.statusField() {
			return nil
		}
		value = trimmed
	}
	switch field.Name {
	case "payment_term_days", "display_order", "default_interval_months", "level_no", "version_no":
		switch v := value.(type) {
		case float64:
			return int(v)
		case int:
			return v
		case string:
			if strings.TrimSpace(v) == "" {
				return nil
			}
			parsed, err := strconv.Atoi(v)
			if err == nil {
				return parsed
			}
		}
	case "is_mvp_active", "requires_next_examination_date", "is_structural_critical", "affects_fitness_default", "repair_required_default", "requires_supervisor_review", "applies_to_new_container", "applies_to_existing_container", "requires_numeric_result", "requires_attachment", "is_required_default", "is_required", "is_critical", "fail_requires_repair", "fail_marks_unfit", "is_active":
		switch v := value.(type) {
		case bool:
			return v
		case float64:
			return v != 0
		case string:
			trimmed := strings.TrimSpace(v)
			if trimmed == "" {
				return nil
			}
			return trimmed == "1" || strings.EqualFold(trimmed, "true") || strings.EqualFold(trimmed, "yes")
		}
	}
	return value
}

func validateKnownFields(resource Resource, payload map[string]any) error {
	allowed := map[string]bool{}
	for _, field := range resource.Fields {
		allowed[field.Name] = true
		if field.APIName != "" {
			allowed[field.APIName] = true
		}
	}
	for key := range payload {
		if !allowed[key] {
			return fmt.Errorf("%w: field %s tidak dikenal", ErrInvalidInput, key)
		}
	}
	return nil
}

func validatePayload(resource Resource, payload map[string]any, create bool) error {
	if len(payload) == 0 {
		return fmt.Errorf("%w: request body kosong", ErrInvalidInput)
	}
	for _, field := range resource.Fields {
		value, exists := payload[field.Name]
		if create && field.Required && isEmpty(value) {
			return fmt.Errorf("%w: %s wajib diisi", ErrInvalidInput, field.RequestName())
		}
		if !create && exists && field.Required && isEmpty(value) {
			return fmt.Errorf("%w: %s wajib diisi", ErrInvalidInput, field.RequestName())
		}
		if !exists || isEmpty(value) {
			continue
		}
		if err := validateFieldValue(resource, field, value); err != nil {
			return err
		}
	}
	return nil
}

func validateFieldValue(resource Resource, field Field, value any) error {
	if field.Name == resource.statusField() {
		if resource.statusField() == "is_active" {
			if _, ok := value.(bool); !ok {
				return fmt.Errorf("%w: status aktif harus boolean", ErrInvalidInput)
			}
		} else {
			status := stringValue(value)
			if !oneOf(status, resource.allowedStatusValues()) {
				return fmt.Errorf("%w: status tidak valid", ErrInvalidInput)
			}
		}
	}
	if strings.HasSuffix(field.Name, "_id") {
		if _, err := uuid.Parse(stringValue(value)); err != nil {
			return fmt.Errorf("%w: %s harus UUID", ErrInvalidInput, field.RequestName())
		}
	}
	switch effectiveFieldType(field) {
	case "email":
		if _, err := mail.ParseAddress(stringValue(value)); err != nil {
			return fmt.Errorf("%w: %s tidak valid", ErrInvalidInput, field.RequestName())
		}
	case "url":
		parsed, err := url.ParseRequestURI(stringValue(value))
		if err != nil || parsed.Scheme == "" || parsed.Host == "" {
			return fmt.Errorf("%w: %s tidak valid", ErrInvalidInput, field.RequestName())
		}
	case "tel":
		phone := stringValue(value)
		if len(phone) > effectiveMaxLength(field, 50) {
			return fmt.Errorf("%w: %s terlalu panjang", ErrInvalidInput, field.RequestName())
		}
	case "date":
		if _, err := time.Parse("2006-01-02", stringValue(value)); err != nil {
			return fmt.Errorf("%w: %s harus tanggal YYYY-MM-DD", ErrInvalidInput, field.RequestName())
		}
	case "number", "decimal":
		number, ok := numericValue(value)
		if !ok {
			return fmt.Errorf("%w: %s harus angka", ErrInvalidInput, field.RequestName())
		}
		min, max := effectiveNumericBounds(field)
		if min != nil && number < *min {
			return fmt.Errorf("%w: %s kurang dari batas minimum", ErrInvalidInput, field.RequestName())
		}
		if max != nil && number > *max {
			return fmt.Errorf("%w: %s melewati batas maksimum", ErrInvalidInput, field.RequestName())
		}
	}
	if maxLength := effectiveMaxLength(field, 0); maxLength > 0 && len(stringValue(value)) > maxLength {
		return fmt.Errorf("%w: %s terlalu panjang", ErrInvalidInput, field.RequestName())
	}
	allowed := effectiveAllowedValues(resource, field)
	if len(allowed) > 0 && !oneOf(stringValue(value), allowed) {
		return fmt.Errorf("%w: %s tidak valid", ErrInvalidInput, field.RequestName())
	}
	return nil
}

func effectiveFieldType(field Field) string {
	if field.Type != "" {
		return field.Type
	}
	switch field.Name {
	case "pic_email", "email":
		return "email"
	case "pic_phone", "phone":
		return "tel"
	case "website":
		return "url"
	case "valid_from", "valid_until", "manufacture_date", "application_date", "client_letter_date", "next_examination_date":
		return "date"
	case "gps_latitude", "gps_longitude":
		return "decimal"
	case "payment_term_days", "display_order", "default_interval_months", "level_no", "version_no":
		return "number"
	}
	return "text"
}

func effectiveAllowedValues(resource Resource, field Field) []string {
	if len(field.AllowedValues) > 0 {
		return field.AllowedValues
	}
	switch field.Name {
	case resource.statusField():
		if resource.statusField() == "is_active" {
			return nil
		}
		return resource.allowedStatusValues()
	case "response_type":
		return []string{"ok_not_ok", "yes_no", "text", "number", "date", "photo_required", "not_applicable"}
	case "container_lifecycle":
		return []string{"new", "existing"}
	case "location_type":
		return []string{"depot", "yard", "port", "warehouse", "factory", "customer_site", "other"}
	case "face":
		return []string{"left", "right", "front", "door", "roof", "floor", "understructure"}
	case "container_size":
		return []string{"all", "20", "40", "45"}
	case "severity_default":
		return []string{"minor", "major", "critical"}
	case "badge_tone":
		return []string{"neutral", "success", "warning", "danger"}
	case "final_fitness_result_mapping":
		return []string{"pending", "fit", "unfit"}
	case "restriction_status_mapping":
		return []string{"none", "suspended", "prohibited", "released"}
	case "applies_to":
		return []string{"inspection", "finding", "test", "repair", "reinspection", "document"}
	}
	return nil
}

func effectiveNumericBounds(field Field) (*float64, *float64) {
	if field.Min != nil || field.Max != nil {
		return field.Min, field.Max
	}
	switch field.Name {
	case "gps_latitude":
		min, max := -90.0, 90.0
		return &min, &max
	case "gps_longitude":
		min, max := -180.0, 180.0
		return &min, &max
	case "payment_term_days", "display_order":
		min := 0.0
		return &min, nil
	case "default_interval_months", "level_no", "version_no":
		min := 1.0
		return &min, nil
	}
	return nil, nil
}

func effectiveMaxLength(field Field, fallback int) int {
	if field.MaxLength > 0 {
		return field.MaxLength
	}
	switch field.Name {
	case "pic_phone", "phone":
		return 50
	case "website":
		return 150
	}
	return fallback
}

func numericValue(value any) (float64, bool) {
	switch v := value.(type) {
	case int:
		return float64(v), true
	case int64:
		return float64(v), true
	case float64:
		return v, true
	case string:
		parsed, err := strconv.ParseFloat(strings.TrimSpace(v), 64)
		return parsed, err == nil
	default:
		return 0, false
	}
}

func mergeForDuplicate(resource Resource, oldValue map[string]any, payload map[string]any) map[string]any {
	merged := map[string]any{}
	for _, field := range resource.Fields {
		key := field.Name
		outKey := key
		if field.APIName != "" {
			outKey = field.APIName
		}
		if value, ok := oldValue[outKey]; ok {
			merged[key] = value
		}
		if value, ok := payload[key]; ok {
			merged[key] = value
		}
	}
	return merged
}

func isEmpty(value any) bool {
	if value == nil {
		return true
	}
	if text, ok := value.(string); ok {
		return strings.TrimSpace(text) == ""
	}
	return false
}

func oneOf(value string, allowed []string) bool {
	for _, item := range allowed {
		if value == item {
			return true
		}
	}
	return false
}

func parseMapUUID(item map[string]any, key string) (uuid.UUID, bool) {
	value, ok := item[key]
	if !ok || value == nil {
		return uuid.Nil, false
	}
	parsed, err := uuid.Parse(fmt.Sprint(value))
	return parsed, err == nil
}

func isDuplicateDBError(err error) bool {
	text := strings.ToLower(err.Error())
	return strings.Contains(text, "duplicate key") || strings.Contains(text, "unique constraint") || strings.Contains(text, "duplicate entry")
}

func isForeignKeyDBError(err error) bool {
	text := strings.ToLower(err.Error())
	return strings.Contains(text, "foreign key constraint") || strings.Contains(text, "violates foreign key")
}
