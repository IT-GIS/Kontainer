package masterdata

import (
	"context"
	"fmt"
	"strconv"
	"strings"

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
		return nil, err
	}
	s.audit(ctx, resource, "create", actor, nil, created)
	return created, nil
}

func (s *Service) Update(ctx context.Context, resource Resource, id uuid.UUID, payload map[string]any, actor Actor) (map[string]any, error) {
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
		return nil, err
	}
	s.audit(ctx, resource, "update", actor, oldValue, updated)
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
	s.audit(ctx, resource, "delete", actor, oldValue, deleted)
	return deleted, nil
}

func (s *Service) audit(ctx context.Context, resource Resource, action string, actor Actor, oldValue any, newValue any) {
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
	_ = s.repo.InsertAudit(ctx, AuditEntry{
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
		result[field.Name] = normalizeFieldValue(field.Name, value)
	}
	return result
}

func normalizeFieldValue(field string, value any) any {
	if value == nil {
		return nil
	}
	switch field {
	case "payment_term_days", "display_order":
		switch v := value.(type) {
		case float64:
			return int(v)
		case string:
			if strings.TrimSpace(v) == "" {
				return nil
			}
			parsed, err := strconv.Atoi(v)
			if err == nil {
				return parsed
			}
		}
	}
	if text, ok := value.(string); ok {
		return strings.TrimSpace(text)
	}
	return value
}

func validatePayload(resource Resource, payload map[string]any, create bool) error {
	if create {
		for _, field := range resource.Fields {
			if !field.Required {
				continue
			}
			if isEmpty(payload[field.Name]) {
				return fmt.Errorf("%w: %s wajib diisi", ErrInvalidInput, field.RequestName())
			}
		}
	}
	if len(payload) == 0 {
		return fmt.Errorf("%w: request body kosong", ErrInvalidInput)
	}
	if status, ok := payload["status"]; ok && !isEmpty(status) {
		value := stringValue(status)
		if value != "active" && value != "inactive" {
			return fmt.Errorf("%w: status tidak valid", ErrInvalidInput)
		}
	}
	if value, ok := payload["location_type"]; ok && !isEmpty(value) {
		if !oneOf(stringValue(value), []string{"depot", "yard", "port", "warehouse", "factory", "customer_site", "other"}) {
			return fmt.Errorf("%w: location_type tidak valid", ErrInvalidInput)
		}
	}
	if value, ok := payload["face"]; ok && !isEmpty(value) {
		if !oneOf(stringValue(value), []string{"left", "right", "front", "door", "roof", "floor", "understructure"}) {
			return fmt.Errorf("%w: face tidak valid", ErrInvalidInput)
		}
	}
	if value, ok := payload["container_size"]; ok && !isEmpty(value) {
		if !oneOf(stringValue(value), []string{"all", "20", "40", "45"}) {
			return fmt.Errorf("%w: container_size tidak valid", ErrInvalidInput)
		}
	}
	return nil
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
	return strings.Contains(strings.ToLower(err.Error()), "duplicate key") || strings.Contains(strings.ToLower(err.Error()), "unique constraint")
}
