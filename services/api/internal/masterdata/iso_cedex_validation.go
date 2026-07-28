package masterdata

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
)

func (r Repository) validateISOCEDEXMutation(ctx context.Context, resource Resource, payload map[string]any) error {
	if _, _, ok := isoCEDEXCodeSpec(resource.Name); ok {
		if stringValue(payload["source_type"]) == "customer_specific" && stringValue(payload["source_reason"]) == "" {
			return fmt.Errorf("%w: Sumber atau alasan Kode Khusus Customer wajib diisi", ErrInvalidInput)
		}
	}
	switch resource.Name {
	case "inspection_test_parameters":
		return validateDateRange(payload, "effective_date", "expiry_date", "Masa berlaku Inspection Reference")
	case "cedex_locations":
		return validateLocationStructure(payload)
	case "cedex_damages":
		if resource.LegacyOnly {
			return r.validateOptionalGlobalCEDEXID(ctx, payload, "default_action_id", "cedex_repairs", "Default Action")
		}
		customerID, err := requiredUUID(payload, "customer_id")
		if err != nil {
			return err
		}
		if err := r.validateOptionalScopedID(ctx, payload, "default_action_id", "cedex_repairs", customerID, "Default Action"); err != nil {
			return err
		}
		return r.validateOptionalGlobalID(ctx, payload, "default_inspection_reference_id", "inspection_test_parameters", "Default Inspection Reference")
	case "cedex_damage_decision_rules":
		return r.validateDecisionRule(ctx, payload)
	default:
		return nil
	}
}

func (r Repository) validateDecisionRule(ctx context.Context, payload map[string]any) error {
	customerText := strings.TrimSpace(stringValue(payload["customer_id"]))
	var customerID uuid.UUID
	var err error
	if customerText == "" || customerText == "<nil>" {
		if err := r.validateRequiredGlobalCEDEXID(ctx, payload, "damage_id", "cedex_damages", "Damage"); err != nil {
			return err
		}
	} else {
		customerID, err = requiredUUID(payload, "customer_id")
		if err != nil {
			return err
		}
		if err := r.validateRequiredScopedID(ctx, payload, "damage_id", "cedex_damages", customerID, "Damage"); err != nil {
			return err
		}
	}
	for _, relation := range []struct {
		field string
		table string
		label string
	}{
		{field: "component_id", table: "cedex_components", label: "Component"},
		{field: "location_id", table: "cedex_locations", label: "Location"},
		{field: "material_id", table: "cedex_materials", label: "Material"},
		{field: "container_type_id", table: "container_types", label: "Container Type"},
		{field: "recommended_action_id", table: "cedex_repairs", label: "Recommended Action"},
	} {
		if customerText == "" || customerText == "<nil>" {
			if relation.table == "container_types" {
				if err := r.validateOptionalGlobalCEDEXID(ctx, payload, relation.field, relation.table, relation.label); err != nil {
					return err
				}
			} else if err := r.validateOptionalGlobalCEDEXID(ctx, payload, relation.field, relation.table, relation.label); err != nil {
				return err
			}
		} else if err := r.validateOptionalScopedID(ctx, payload, relation.field, relation.table, customerID, relation.label); err != nil {
			return err
		}
	}
	if err := r.validateRequiredGlobalID(ctx, payload, "inspection_reference_id", "inspection_test_parameters", "Inspection Reference"); err != nil {
		return err
	}
	if err := validateDecisionThreshold(payload); err != nil {
		return err
	}
	return validateDateRange(payload, "valid_from", "valid_until", "Masa berlaku Decision Rule")
}

func validateLocationStructure(payload map[string]any) error {
	if stringValue(payload["input_mode"]) != "structured" {
		return nil
	}
	sector := strings.ToUpper(stringValue(payload["sector_code"]))
	vertical := strings.ToUpper(stringValue(payload["vertical_code"]))
	start := strings.ToUpper(stringValue(payload["start_section"]))
	end := strings.ToUpper(stringValue(payload["end_section"]))
	span := strings.ToUpper(stringValue(payload["transverse_span"]))
	size := stringValue(payload["container_size"])
	if !oneOf(sector, []string{"D", "L", "R", "F", "U", "T", "B"}) ||
		!oneOf(vertical, []string{"G", "B", "T", "H", "X"}) {
		return fmt.Errorf("%w: kombinasi Sector dan Vertical Position tidak valid", ErrInvalidInput)
	}
	sections := "12345"
	if size == "40" || size == "45" {
		sections = "1234567890"
	} else if size != "20" {
		return fmt.Errorf("%w: Container Size structured Location harus 20, 40, atau 45", ErrInvalidInput)
	}
	if !strings.Contains(sections, start) {
		return fmt.Errorf("%w: Start Section tidak sesuai ukuran peti kemas", ErrInvalidInput)
	}
	expected := sector + vertical + start + "N"
	if span == "RANGE" {
		if end == "" || !strings.Contains(sections, end) || start == end {
			return fmt.Errorf("%w: End Section rentang tidak valid", ErrInvalidInput)
		}
		expected = sector + vertical + start + end
	} else if span != "N" {
		return fmt.Errorf("%w: Transverse / Span tidak valid", ErrInvalidInput)
	}
	if stringValue(payload["code"]) != expected {
		return fmt.Errorf("%w: Location Code Preview tidak sesuai struktur", ErrInvalidInput)
	}
	return nil
}

func validateDecisionThreshold(payload map[string]any) error {
	operator := strings.TrimSpace(stringValue(payload["comparison_operator"]))
	minimum, hasMinimum := optionalNumber(payload["minimum_value"])
	maximum, hasMaximum := optionalNumber(payload["maximum_value"])
	switch operator {
	case "lt", "lte":
		if !hasMaximum {
			return fmt.Errorf("%w: Maximum Value wajib diisi untuk operator %s", ErrInvalidInput, operator)
		}
	case "gt", "gte", "eq":
		if !hasMinimum {
			return fmt.Errorf("%w: Minimum Value wajib diisi untuk operator %s", ErrInvalidInput, operator)
		}
	case "between":
		if !hasMinimum || !hasMaximum {
			return fmt.Errorf("%w: Minimum Value dan Maximum Value wajib diisi untuk operator between", ErrInvalidInput)
		}
		if minimum > maximum {
			return fmt.Errorf("%w: Minimum Value tidak boleh lebih besar dari Maximum Value", ErrInvalidInput)
		}
	case "manual":
		return nil
	default:
		return fmt.Errorf("%w: Comparison Operator tidak valid", ErrInvalidInput)
	}
	return nil
}

func optionalNumber(value any) (float64, bool) {
	if value == nil || strings.TrimSpace(stringValue(value)) == "" {
		return 0, false
	}
	number, ok := numericValue(value)
	return number, ok
}

func validateDateRange(payload map[string]any, fromField, untilField, label string) error {
	from, hasFrom, err := optionalDate(payload[fromField])
	if err != nil {
		return fmt.Errorf("%w: %s tidak valid", ErrInvalidInput, fromField)
	}
	until, hasUntil, err := optionalDate(payload[untilField])
	if err != nil {
		return fmt.Errorf("%w: %s tidak valid", ErrInvalidInput, untilField)
	}
	if hasFrom && hasUntil && until.Before(from) {
		return fmt.Errorf("%w: %s berakhir sebelum tanggal mulai", ErrInvalidInput, label)
	}
	return nil
}

func optionalDate(value any) (time.Time, bool, error) {
	text := strings.TrimSpace(stringValue(value))
	if text == "" || text == "<nil>" {
		return time.Time{}, false, nil
	}
	parsed, err := time.Parse("2006-01-02", text)
	return parsed, true, err
}

func requiredUUID(payload map[string]any, field string) (uuid.UUID, error) {
	id, err := uuid.Parse(strings.TrimSpace(stringValue(payload[field])))
	if err != nil {
		return uuid.Nil, fmt.Errorf("%w: %s wajib berupa UUID", ErrInvalidInput, field)
	}
	return id, nil
}

func (r Repository) validateRequiredScopedID(ctx context.Context, payload map[string]any, field, table string, customerID uuid.UUID, label string) error {
	id, err := requiredUUID(payload, field)
	if err != nil {
		return err
	}
	return r.requireScopedID(ctx, table, id, customerID, label)
}

func (r Repository) validateOptionalScopedID(ctx context.Context, payload map[string]any, field, table string, customerID uuid.UUID, label string) error {
	value := strings.TrimSpace(stringValue(payload[field]))
	if value == "" || value == "<nil>" {
		return nil
	}
	id, err := uuid.Parse(value)
	if err != nil {
		return fmt.Errorf("%w: %s tidak valid", ErrInvalidInput, label)
	}
	return r.requireScopedID(ctx, table, id, customerID, label)
}

func (r Repository) requireScopedID(ctx context.Context, table string, id, customerID uuid.UUID, label string) error {
	allowed := map[string]bool{
		"cedex_damages": true, "cedex_components": true, "cedex_locations": true,
		"cedex_materials": true, "cedex_repairs": true, "container_types": true,
	}
	if !allowed[table] {
		return fmt.Errorf("unsupported ISO CEDEX relation table %q", table)
	}
	var count int
	customerClause := "customer_id=$2"
	if strings.HasPrefix(table, "cedex_") {
		customerClause = "(customer_id=$2 OR customer_id IS NULL)"
	}
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE id=$1 AND %s AND status='active'", table, customerClause)
	if err := r.runner().QueryRow(ctx, query, id, customerID).Scan(&count); err != nil {
		return err
	}
	if count != 1 {
		return fmt.Errorf("%w: %s harus aktif dan berasal dari Customer yang sama", ErrInvalidInput, label)
	}
	return nil
}

func (r Repository) validateRequiredGlobalCEDEXID(ctx context.Context, payload map[string]any, field, table, label string) error {
	id, err := requiredUUID(payload, field)
	if err != nil {
		return err
	}
	return r.requireGlobalCEDEXID(ctx, table, id, label)
}

func (r Repository) validateOptionalGlobalCEDEXID(ctx context.Context, payload map[string]any, field, table, label string) error {
	value := strings.TrimSpace(stringValue(payload[field]))
	if value == "" || value == "<nil>" {
		return nil
	}
	id, err := uuid.Parse(value)
	if err != nil {
		return fmt.Errorf("%w: %s tidak valid", ErrInvalidInput, label)
	}
	return r.requireGlobalCEDEXID(ctx, table, id, label)
}

func (r Repository) requireGlobalCEDEXID(ctx context.Context, table string, id uuid.UUID, label string) error {
	allowed := map[string]bool{
		"cedex_damages": true, "cedex_components": true, "cedex_locations": true,
		"cedex_materials": true, "cedex_repairs": true, "container_types": true,
	}
	if !allowed[table] {
		return fmt.Errorf("unsupported ISO CEDEX global relation table %q", table)
	}
	var count int
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE id=$1 AND customer_id IS NULL AND status='active'", table)
	if err := r.runner().QueryRow(ctx, query, id).Scan(&count); err != nil {
		return err
	}
	if count != 1 {
		return fmt.Errorf("%w: %s harus berupa Kode Standar Global yang aktif", ErrInvalidInput, label)
	}
	return nil
}

func (r Repository) validateRequiredGlobalID(ctx context.Context, payload map[string]any, field, table, label string) error {
	id, err := requiredUUID(payload, field)
	if err != nil {
		return err
	}
	return r.requireGlobalID(ctx, table, id, label)
}

func (r Repository) validateOptionalGlobalID(ctx context.Context, payload map[string]any, field, table, label string) error {
	value := strings.TrimSpace(stringValue(payload[field]))
	if value == "" || value == "<nil>" {
		return nil
	}
	id, err := uuid.Parse(value)
	if err != nil {
		return fmt.Errorf("%w: %s tidak valid", ErrInvalidInput, label)
	}
	return r.requireGlobalID(ctx, table, id, label)
}

func (r Repository) requireGlobalID(ctx context.Context, table string, id uuid.UUID, label string) error {
	if table != "inspection_test_parameters" {
		return fmt.Errorf("unsupported ISO CEDEX global relation table %q", table)
	}
	var count int
	if err := r.runner().QueryRow(ctx, "SELECT COUNT(*) FROM inspection_test_parameters WHERE id=$1 AND status='active'", id).Scan(&count); err != nil {
		return err
	}
	if count != 1 {
		return fmt.Errorf("%w: %s harus aktif", ErrInvalidInput, label)
	}
	return nil
}
