package masterdata

import "fmt"

var effectiveMasterTables = map[string]bool{
	"cedex_locations":      true,
	"cedex_components":     true,
	"cedex_damages":        true,
	"cedex_repairs":        true,
	"cedex_materials":      true,
	"responsibility_codes": true,
}

// EffectiveMasterScopeSQL is the canonical global/customer override rule used
// by both readiness checks and Survey Sheet option resolution.
func EffectiveMasterScopeSQL(table, alias, customerExpression string) (string, error) {
	if !effectiveMasterTables[table] {
		return "", fmt.Errorf("unsupported effective master table %q", table)
	}
	if alias == "" || customerExpression == "" {
		return "", fmt.Errorf("effective master alias and customer expression are required")
	}
	return fmt.Sprintf(`%s.status='active' AND (
		%s.customer_id=%s OR (
			%s.customer_id IS NULL AND NOT EXISTS (
				SELECT 1 FROM %s override
				WHERE override.customer_id=%s
				  AND override.status='active'
				  AND LOWER(override.code)=LOWER(%s.code)
			)
		)
	)`, alias, alias, customerExpression, alias, table, customerExpression, alias), nil
}

func effectiveMasterCountSQL(table, alias, customerExpression string, extraPredicate ...string) string {
	scope, err := EffectiveMasterScopeSQL(table, alias, customerExpression)
	if err != nil {
		panic(err)
	}
	extra := ""
	if len(extraPredicate) > 0 && extraPredicate[0] != "" {
		extra = " AND " + extraPredicate[0]
	}
	return fmt.Sprintf("(SELECT COUNT(*) FROM %s %s WHERE %s%s)", table, alias, scope, extra)
}

func EffectiveDecisionRuleScopeSQL(alias, customerExpression string) string {
	return fmt.Sprintf(`%s.status='active' AND (
		%s.customer_id=%s OR (
			%s.customer_id IS NULL AND NOT EXISTS (
				SELECT 1 FROM cedex_damage_decision_rules override
				WHERE override.customer_id=%s AND override.status='active'
				  AND override.damage_id=%s.damage_id
				  AND override.component_id <=> %s.component_id
				  AND override.location_id <=> %s.location_id
				  AND override.material_id <=> %s.material_id
				  AND override.container_type_id <=> %s.container_type_id
				  AND override.container_lifecycle <=> %s.container_lifecycle
				  AND override.measurement_field=%s.measurement_field
			)
		)
	)`, alias, alias, customerExpression, alias, customerExpression, alias, alias, alias, alias, alias, alias, alias)
}
