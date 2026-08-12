package surveyor

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"strconv"
	"strings"

	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/masterdata"

	"github.com/google/uuid"
)

type DamageDecisionEvaluation struct {
	Configured                   bool     `json:"configured"`
	Matched                      bool     `json:"matched"`
	RequiresDimension            bool     `json:"requires_dimension"`
	DefaultSeverity              string   `json:"default_severity,omitempty"`
	DefaultActionID              string   `json:"default_action_id,omitempty"`
	DefaultInspectionReferenceID string   `json:"default_inspection_reference_id,omitempty"`
	DecisionRuleID               string   `json:"decision_rule_id,omitempty"`
	MeasurementField             string   `json:"measurement_field,omitempty"`
	MeasurementValue             *float64 `json:"measurement_value,omitempty"`
	ComparisonOperator           string   `json:"comparison_operator,omitempty"`
	MinimumValue                 *float64 `json:"minimum_value,omitempty"`
	MaximumValue                 *float64 `json:"maximum_value,omitempty"`
	Unit                         string   `json:"unit,omitempty"`
	Tolerance                    string   `json:"tolerance,omitempty"`
	DecisionResult               string   `json:"decision_result,omitempty"`
	DecisionReason               string   `json:"decision_reason,omitempty"`
	RecommendedActionID          string   `json:"recommended_action_id,omitempty"`
	RecommendedActionCode        string   `json:"recommended_action_code,omitempty"`
	RecommendedActionName        string   `json:"recommended_action_name,omitempty"`
	InspectionReferenceID        string   `json:"inspection_reference_id,omitempty"`
	InspectionReferenceCode      string   `json:"inspection_reference_code,omitempty"`
	InspectionReferenceName      string   `json:"inspection_reference_name,omitempty"`
	InspectionStandardReference  string   `json:"inspection_standard_reference,omitempty"`
	InspectionReferenceClause    string   `json:"inspection_reference_clause,omitempty"`
}

type damageMasterDefaults struct {
	RequiresDimension            bool
	DefaultSeverity              string
	DefaultActionID              *uuid.UUID
	DefaultInspectionReferenceID *uuid.UUID
}

func (r Repository) PreviewDamageDecision(ctx context.Context, surveyID uuid.UUID, input DamageInput, actor Actor) (DamageDecisionEvaluation, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return DamageDecisionEvaluation{}, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyBaseTx(ctx, tx, surveyID, actor)
	if err != nil {
		return DamageDecisionEvaluation{}, err
	}
	customerID := parseUUIDString(base["customer_id"])
	damageID, err := uuid.Parse(strings.TrimSpace(input.DamageID))
	if err != nil {
		return DamageDecisionEvaluation{}, validationError("DAMAGE_CODE_INVALID", "Damage type tidak valid.")
	}
	componentID, err := uuid.Parse(strings.TrimSpace(input.ComponentID))
	if err != nil {
		return DamageDecisionEvaluation{}, validationError("COMPONENT_INVALID", "Component tidak valid.")
	}
	if err := r.validateScopedReferenceTx(ctx, tx, "cedex_damages", damageID, customerID, "DAMAGE_CODE_SCOPE"); err != nil {
		return DamageDecisionEvaluation{}, err
	}
	if err := r.validateScopedReferenceTx(ctx, tx, "cedex_components", componentID, customerID, "COMPONENT_SCOPE"); err != nil {
		return DamageDecisionEvaluation{}, err
	}
	locationID, _, _, err := r.resolveCEDEXLocation(ctx, tx, customerID, input)
	if err != nil {
		return DamageDecisionEvaluation{}, err
	}
	if input.LocationSelection != nil && !strings.HasPrefix(strings.TrimSpace(fmt.Sprint(base["container_size"])), input.LocationSelection.ContainerSize) {
		return DamageDecisionEvaluation{}, validationError("LOCATION_SELECTION_CONTAINER_SIZE_MISMATCH", "Ukuran template Survey Sheet tidak sesuai Container Type pekerjaan.")
	}
	if err := r.validateSelectionMappingTx(ctx, tx, customerID, locationID, input.LocationSelection); err != nil {
		return DamageDecisionEvaluation{}, err
	}
	materialID, err := parseOptionalReferenceID(input.MaterialID, "MATERIAL_INVALID", "Material code tidak valid.")
	if err != nil {
		return DamageDecisionEvaluation{}, err
	}
	if materialID != nil {
		if err := r.validateScopedReferenceTx(ctx, tx, "cedex_materials", *materialID, customerID, "MATERIAL_SCOPE"); err != nil {
			return DamageDecisionEvaluation{}, err
		}
	}
	return r.evaluateDamageDecisionTx(ctx, tx, base, input, damageID, componentID, locationID, materialID)
}

func (r Repository) evaluateDamageDecisionTx(
	ctx context.Context,
	tx database.Tx,
	base map[string]any,
	input DamageInput,
	damageID uuid.UUID,
	componentID uuid.UUID,
	locationID *uuid.UUID,
	materialID *uuid.UUID,
) (DamageDecisionEvaluation, error) {
	defaults, err := r.damageDefaultsTx(ctx, tx, damageID)
	if err != nil {
		return DamageDecisionEvaluation{}, err
	}
	evaluation := DamageDecisionEvaluation{
		RequiresDimension:            defaults.RequiresDimension,
		DefaultSeverity:              defaults.DefaultSeverity,
		DefaultActionID:              uuidString(defaults.DefaultActionID),
		DefaultInspectionReferenceID: uuidString(defaults.DefaultInspectionReferenceID),
	}
	if err := validateDimensionProfile(input, defaults.RequiresDimension); err != nil {
		return evaluation, err
	}

	containerTypeID := nullableUUID(base["container_type_id"])
	var lifecycle string
	_ = tx.QueryRow(ctx, "SELECT COALESCE(container_lifecycle,'') FROM survey_general_infos WHERE survey_id=$1", parseUUIDString(base["id"])).Scan(&lifecycle)
	rows, err := tx.Query(ctx, fmt.Sprintf(`
		SELECT rule.id, rule.measurement_field, rule.comparison_operator,
		       rule.minimum_value, rule.maximum_value, rule.unit, rule.decision_result,
		       rule.decision_note, rule.recommended_action_id,
		       action.code AS recommended_action_code, action.repair_name AS recommended_action_name,
		       reference.id AS inspection_reference_id, reference.code AS inspection_reference_code,
		       reference.parameter_name AS inspection_reference_name,
		       reference.standard_reference AS inspection_standard_reference,
		       reference.clause_section AS inspection_reference_clause
		FROM cedex_damage_decision_rules rule
		JOIN inspection_test_parameters reference
		  ON reference.id=rule.inspection_reference_id AND reference.status='active'
		LEFT JOIN cedex_repairs action
		  ON action.id=rule.recommended_action_id AND action.status='active'
		WHERE %s AND rule.damage_id=$2
		  AND (rule.component_id IS NULL OR rule.component_id=$3)
		  AND (rule.location_id IS NULL OR rule.location_id=$4)
		  AND (rule.material_id IS NULL OR rule.material_id=$5)
		  AND (rule.container_type_id IS NULL OR rule.container_type_id=$6)
		  AND (rule.container_lifecycle IS NULL OR rule.container_lifecycle=NULLIF($7,''))
		  AND (rule.valid_from IS NULL OR rule.valid_from<=CURRENT_DATE)
		  AND (rule.valid_until IS NULL OR rule.valid_until>=CURRENT_DATE)
		ORDER BY (rule.customer_id=$1) DESC, rule.priority DESC,
		  ((rule.component_id IS NOT NULL) + (rule.location_id IS NOT NULL) +
		   (rule.material_id IS NOT NULL) + (rule.container_type_id IS NOT NULL) +
		   (rule.container_lifecycle IS NOT NULL)) DESC,
		  rule.created_at ASC
	`, masterdata.EffectiveDecisionRuleScopeSQL("rule", "$1")), parseUUIDString(base["customer_id"]), damageID, componentID, locationID, materialID, containerTypeID, lifecycle)
	if err != nil {
		return evaluation, err
	}
	defer rows.Close()
	rules, err := rowsToMaps(rows)
	if err != nil {
		return evaluation, err
	}
	evaluation.Configured = len(rules) > 0
	for _, rule := range rules {
		matched, measuredValue := decisionRuleMatches(rule, input)
		if !matched {
			continue
		}
		evaluation.Matched = true
		evaluation.DecisionRuleID = cleanString(rule["id"])
		evaluation.MeasurementField = cleanString(rule["measurement_field"])
		evaluation.MeasurementValue = measuredValue
		evaluation.ComparisonOperator = cleanString(rule["comparison_operator"])
		evaluation.MinimumValue = nullableFloat(rule["minimum_value"])
		evaluation.MaximumValue = nullableFloat(rule["maximum_value"])
		evaluation.Unit = cleanString(rule["unit"])
		evaluation.Tolerance = toleranceLabel(evaluation.ComparisonOperator, evaluation.MinimumValue, evaluation.MaximumValue, evaluation.Unit)
		evaluation.DecisionResult = cleanString(rule["decision_result"])
		evaluation.DecisionReason = cleanString(rule["decision_note"])
		if evaluation.DecisionReason == "" {
			evaluation.DecisionReason = "Hasil ditentukan oleh Decision Rule aktif yang sesuai dengan scope dan pengukuran finding."
		}
		evaluation.RecommendedActionID = cleanString(rule["recommended_action_id"])
		evaluation.RecommendedActionCode = cleanString(rule["recommended_action_code"])
		evaluation.RecommendedActionName = cleanString(rule["recommended_action_name"])
		evaluation.InspectionReferenceID = cleanString(rule["inspection_reference_id"])
		evaluation.InspectionReferenceCode = cleanString(rule["inspection_reference_code"])
		evaluation.InspectionReferenceName = cleanString(rule["inspection_reference_name"])
		evaluation.InspectionStandardReference = cleanString(rule["inspection_standard_reference"])
		evaluation.InspectionReferenceClause = cleanString(rule["inspection_reference_clause"])
		return evaluation, nil
	}
	if defaults.DefaultInspectionReferenceID != nil {
		if err := r.populateDefaultReferenceTx(ctx, tx, &evaluation, *defaults.DefaultInspectionReferenceID); err != nil {
			return evaluation, err
		}
	}
	evaluation.DecisionResult = "manual_review"
	evaluation.DecisionReason = "Tidak ada Decision Rule aktif yang cocok dengan scope dan pengukuran finding ini."
	return evaluation, nil
}

func (r Repository) damageDefaultsTx(ctx context.Context, tx database.Tx, damageID uuid.UUID) (damageMasterDefaults, error) {
	var defaults damageMasterDefaults
	err := tx.QueryRow(ctx, `
		SELECT requires_dimension, default_severity, default_action_id, default_inspection_reference_id
		FROM cedex_damages WHERE id=$1
	`, damageID).Scan(
		&defaults.RequiresDimension,
		&defaults.DefaultSeverity,
		&defaults.DefaultActionID,
		&defaults.DefaultInspectionReferenceID,
	)
	return defaults, err
}

func (r Repository) populateDefaultReferenceTx(ctx context.Context, tx database.Tx, evaluation *DamageDecisionEvaluation, referenceID uuid.UUID) error {
	return tx.QueryRow(ctx, `
		SELECT id, code, parameter_name, COALESCE(standard_reference,''), COALESCE(clause_section,'')
		FROM inspection_test_parameters WHERE id=$1
	`, referenceID).Scan(
		&evaluation.InspectionReferenceID,
		&evaluation.InspectionReferenceCode,
		&evaluation.InspectionReferenceName,
		&evaluation.InspectionStandardReference,
		&evaluation.InspectionReferenceClause,
	)
}

func decisionRuleMatches(rule map[string]any, input DamageInput) (bool, *float64) {
	operator := cleanString(rule["comparison_operator"])
	if operator == "manual" {
		return true, nil
	}
	value, ok := measuredValue(cleanString(rule["measurement_field"]), cleanString(rule["unit"]), input)
	if !ok {
		return false, nil
	}
	minimum := nullableFloat(rule["minimum_value"])
	maximum := nullableFloat(rule["maximum_value"])
	switch operator {
	case "lt":
		return maximum != nil && value < *maximum, &value
	case "lte":
		return maximum != nil && value <= *maximum, &value
	case "eq":
		return minimum != nil && math.Abs(value-*minimum) < 0.000001, &value
	case "gt":
		return minimum != nil && value > *minimum, &value
	case "gte":
		return minimum != nil && value >= *minimum, &value
	case "between":
		return minimum != nil && maximum != nil && value >= *minimum && value <= *maximum, &value
	default:
		return false, &value
	}
}

func measuredValue(field, ruleUnit string, input DamageInput) (float64, bool) {
	switch field {
	case "length":
		return convertedMeasurement(input.Length, input.Unit, ruleUnit)
	case "width":
		return convertedMeasurement(input.Width, input.Unit, ruleUnit)
	case "depth", "thickness":
		return convertedMeasurement(input.Depth, input.Unit, ruleUnit)
	case "quantity":
		if input.Quantity == nil {
			return 0, false
		}
		return float64(*input.Quantity), true
	case "area":
		length, lengthOK := convertedMeasurement(input.Length, input.Unit, ruleUnit)
		width, widthOK := convertedMeasurement(input.Width, input.Unit, ruleUnit)
		return length * width, lengthOK && widthOK
	default:
		return 0, false
	}
}

func convertedMeasurement(value *float64, inputUnit, ruleUnit string) (float64, bool) {
	if value == nil {
		return 0, false
	}
	from := strings.ToLower(strings.TrimSpace(inputUnit))
	to := strings.ToLower(strings.TrimSpace(ruleUnit))
	if to == "" || from == to {
		return *value, true
	}
	factors := map[string]float64{"mm": 1, "cm": 10, "m": 1000}
	fromFactor, fromOK := factors[from]
	toFactor, toOK := factors[to]
	if !fromOK || !toOK {
		return 0, false
	}
	return *value * fromFactor / toFactor, true
}

func toleranceLabel(operator string, minimum, maximum *float64, unit string) string {
	number := func(value *float64) string {
		if value == nil {
			return ""
		}
		return strconv.FormatFloat(*value, 'f', -1, 64)
	}
	suffix := ""
	if strings.TrimSpace(unit) != "" {
		suffix = " " + strings.TrimSpace(unit)
	}
	switch operator {
	case "lt":
		return "< " + number(maximum) + suffix
	case "lte":
		return "<= " + number(maximum) + suffix
	case "eq":
		return "= " + number(minimum) + suffix
	case "gt":
		return "> " + number(minimum) + suffix
	case "gte":
		return ">= " + number(minimum) + suffix
	case "between":
		return number(minimum) + " – " + number(maximum) + suffix
	case "manual":
		return "Manual Review"
	default:
		return ""
	}
}

func nullableFloat(value any) *float64 {
	if value == nil {
		return nil
	}
	text := cleanString(value)
	if text == "" {
		return nil
	}
	parsed, err := strconv.ParseFloat(text, 64)
	if err != nil {
		return nil
	}
	return &parsed
}

func cleanString(value any) string {
	text := strings.TrimSpace(fmt.Sprint(value))
	if text == "<nil>" {
		return ""
	}
	return text
}

func uuidString(value *uuid.UUID) string {
	if value == nil {
		return ""
	}
	return value.String()
}

func (evaluation DamageDecisionEvaluation) snapshotJSON() string {
	if !evaluation.Matched && evaluation.InspectionReferenceID == "" {
		return ""
	}
	value, _ := json.Marshal(evaluation)
	return string(value)
}
