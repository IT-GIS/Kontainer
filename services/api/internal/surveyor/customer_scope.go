package surveyor

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"container-survey/services/api/internal/database"

	"github.com/google/uuid"
)

func (r Repository) checklistTemplateTx(ctx context.Context, tx database.Tx, customerID, surveyTypeID, containerTypeID uuid.UUID) (uuid.UUID, error) {
	var templateID uuid.UUID
	err := tx.QueryRow(ctx, `
		SELECT t.id
		FROM fitness_checklist_templates t
		WHERE t.customer_id=$1
		  AND t.survey_type_id=$2
		  AND t.container_type_id=$3
		  AND t.status='active'
		  AND t.deleted_at IS NULL
		  AND EXISTS (
		    SELECT 1
		    FROM fitness_checklist_template_items item
		    WHERE item.template_id=t.id AND item.status='active'
		  )
		ORDER BY t.version_no DESC, t.updated_at DESC
		LIMIT 1
		FOR UPDATE
	`, customerID, surveyTypeID, containerTypeID).Scan(&templateID)
	if errors.Is(err, database.ErrNoRows) {
		return uuid.Nil, validationError(
			"CHECKLIST_TEMPLATE_NOT_CONFIGURED",
			"Checklist aktif untuk kombinasi Customer, Survey Type, dan Container Type ini belum dikonfigurasi.",
		)
	}
	return templateID, err
}

func (r Repository) instantiateChecklistTx(ctx context.Context, tx database.Tx, surveyID, templateID uuid.UUID) error {
	result, err := tx.Exec(ctx, `
		INSERT INTO survey_checklist_responses (
		  survey_id, template_item_id, item_code, item_label, response_type,
		  unit, standard_reference, is_required, is_critical, requires_attachment, display_order
		)
		SELECT $1, item.id, item.item_code, item.item_label, item.response_type,
		       parameter.unit, parameter.standard_reference, item.is_required, item.is_critical,
		       COALESCE(parameter.requires_attachment,0), item.display_order
		FROM fitness_checklist_template_items item
		LEFT JOIN inspection_test_parameters parameter ON parameter.id=item.test_parameter_id
		WHERE item.template_id=$2 AND item.status='active'
		ORDER BY item.display_order, item.item_code
	`, surveyID, templateID)
	if err != nil {
		return err
	}
	if result.RowsAffected() == 0 {
		return validationError("CHECKLIST_TEMPLATE_EMPTY", "Checklist aktif tidak memiliki item aktif.")
	}
	return nil
}

func (r Repository) MasterOptions(ctx context.Context, surveyID uuid.UUID, actor Actor) (SurveyMasterOptions, error) {
	base, err := r.surveyBase(ctx, surveyID, actor)
	if err != nil {
		return SurveyMasterOptions{}, err
	}
	customerID := parseUUIDString(base["customer_id"])
	surveyTypeID := parseUUIDString(base["survey_type_id"])

	options := SurveyMasterOptions{
		Customer: map[string]any{
			"id": customerID.String(), "code": base["customer_code"], "name": base["customer_name"],
		},
		SurveyType: map[string]any{
			"id": surveyTypeID.String(), "code": base["survey_type_code"], "name": base["survey_type_name"],
		},
		ContainerType: map[string]any{
			"id": base["container_type_id"], "code": base["container_type_code"], "name": base["container_type_name"],
			"size": base["container_size"], "iso_type_code": base["iso_type_code"],
		},
	}

	if options.CEDEXLocations, err = r.optionRows(ctx, `
		SELECT location.id, location.code, location.code AS name, location.description,
		       location.face, location.grid_code, location.container_size, location.display_order,
		       location.input_mode, location.sector_code, location.vertical_code,
		       location.start_section, location.end_section, location.transverse_span,
		       location.source_type, location.status
		FROM cedex_locations location
		WHERE location.status='active'
		  AND (location.customer_id=$1 OR (
		    location.customer_id IS NULL AND NOT EXISTS (
		      SELECT 1 FROM cedex_locations override
		      WHERE override.customer_id=$1 AND override.status='active'
		        AND LOWER(override.code)=LOWER(location.code)
		    )
		  ))
		ORDER BY location.display_order, location.face, location.grid_code, location.code
	`, customerID); err != nil {
		return SurveyMasterOptions{}, err
	}
	if options.CEDEXComponents, err = r.optionRows(ctx, `
		SELECT component.id, component.code, component.component_name AS name, component.description,
		       component.applicable_face, component.is_structural_critical, component.display_order,
		       component.source_type
		FROM cedex_components component
		WHERE component.status='active'
		  AND (component.customer_id=$1 OR (component.customer_id IS NULL AND NOT EXISTS (
		    SELECT 1 FROM cedex_components override
		    WHERE override.customer_id=$1 AND override.status='active'
		      AND LOWER(override.code)=LOWER(component.code)
		  )))
		ORDER BY component.display_order, component.code
	`, customerID); err != nil {
		return SurveyMasterOptions{}, err
	}
	if options.CEDEXDamages, err = r.optionRows(ctx, `
		SELECT damage.id, damage.code, damage.damage_name AS name, damage.description, damage.damage_category,
		       damage.default_severity, damage.requires_dimension, damage.default_action_id,
		       damage.default_inspection_reference_id, damage.display_order, damage.source_type
		FROM cedex_damages damage
		WHERE damage.status='active'
		  AND (damage.customer_id=$1 OR (damage.customer_id IS NULL AND NOT EXISTS (
		    SELECT 1 FROM cedex_damages override
		    WHERE override.customer_id=$1 AND override.status='active'
		      AND LOWER(override.code)=LOWER(damage.code)
		  )))
		ORDER BY damage.display_order, damage.code
	`, customerID); err != nil {
		return SurveyMasterOptions{}, err
	}
	if options.CEDEXRepairs, err = r.optionRows(ctx, `
		SELECT repair.id, repair.code, repair.repair_name AS name, repair.description, repair.result_mapping,
		       repair.requires_reinspection, repair.display_order, repair.source_type
		FROM cedex_repairs repair
		WHERE repair.status='active'
		  AND (repair.customer_id=$1 OR (repair.customer_id IS NULL AND NOT EXISTS (
		    SELECT 1 FROM cedex_repairs override
		    WHERE override.customer_id=$1 AND override.status='active'
		      AND LOWER(override.code)=LOWER(repair.code)
		  )))
		ORDER BY repair.display_order, repair.code
	`, customerID); err != nil {
		return SurveyMasterOptions{}, err
	}
	if options.CEDEXMaterials, err = r.optionRows(ctx, `
		SELECT material.id, material.code, material.material_name AS name, material.description, material.source_type
		FROM cedex_materials material
		WHERE material.status='active'
		  AND (material.customer_id=$1 OR (material.customer_id IS NULL AND NOT EXISTS (
		    SELECT 1 FROM cedex_materials override
		    WHERE override.customer_id=$1 AND override.status='active'
		      AND LOWER(override.code)=LOWER(material.code)
		  )))
		ORDER BY material.code
	`, customerID); err != nil {
		return SurveyMasterOptions{}, err
	}
	if options.ResponsibilityCodes, err = r.optionRows(ctx, `
		SELECT id, code, name, description
		FROM responsibility_codes
		WHERE customer_id=$1 AND status='active'
		ORDER BY code
	`, customerID); err != nil {
		return SurveyMasterOptions{}, err
	}
	if options.FindingSeverities, err = r.optionRows(ctx, `
		SELECT severity.id, severity.code, severity.name, severity.description,
		       severity.level_no, severity.badge_tone
		FROM customer_survey_type_severities mapping
		JOIN finding_severities severity ON severity.id=mapping.severity_id AND severity.status='active'
		WHERE mapping.customer_id=$1 AND mapping.survey_type_id=$2 AND mapping.is_active=1
		ORDER BY severity.level_no, severity.code
	`, customerID, surveyTypeID); err != nil {
		return SurveyMasterOptions{}, err
	}
	if options.TestParameters, err = r.optionRows(ctx, `
		SELECT parameter.id, parameter.code, parameter.parameter_name AS name, parameter.description,
		       parameter.reference_type, parameter.unit, parameter.standard_reference,
		       parameter.clause_section, parameter.requires_numeric_result,
		       parameter.requires_attachment, parameter.display_order
		FROM customer_survey_type_test_parameters mapping
		JOIN inspection_test_parameters parameter
		  ON parameter.id=mapping.test_parameter_id AND parameter.status='active'
		WHERE mapping.customer_id=$1 AND mapping.survey_type_id=$2 AND mapping.is_active=1
		ORDER BY parameter.display_order, parameter.code
	`, customerID, surveyTypeID); err != nil {
		return SurveyMasterOptions{}, err
	}
	if options.PhotoCategories, err = r.optionRows(ctx, `
		SELECT category.id, category.code, category.name, category.description,
		       category.is_required_default, category.applies_to, category.display_order
		FROM customer_survey_type_photo_categories mapping
		JOIN evidence_photo_categories category
		  ON category.id=mapping.photo_category_id AND category.status='active'
		WHERE mapping.customer_id=$1 AND mapping.survey_type_id=$2 AND mapping.is_active=1
		ORDER BY category.display_order, category.code
	`, customerID, surveyTypeID); err != nil {
		return SurveyMasterOptions{}, err
	}
	return options, nil
}

func (r Repository) optionRows(ctx context.Context, query string, args ...any) ([]map[string]any, error) {
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) validateScopedReferenceTx(ctx context.Context, tx database.Tx, table string, id uuid.UUID, customerID uuid.UUID, code string) error {
	allowed := map[string]bool{
		"cedex_components": true, "cedex_damages": true, "cedex_repairs": true,
		"cedex_materials": true, "responsibility_codes": true,
	}
	if !allowed[table] {
		return fmt.Errorf("unsupported scoped reference table %q", table)
	}
	var found uuid.UUID
	scopeClause := "item.customer_id=$2"
	if table != "responsibility_codes" {
		scopeClause = fmt.Sprintf(`(item.customer_id=$2 OR (
			item.customer_id IS NULL AND NOT EXISTS (
				SELECT 1
				FROM %s override
				WHERE override.customer_id=$2
				  AND override.status='active'
				  AND LOWER(override.code)=LOWER(item.code)
			)
		))`, table)
	}
	err := tx.QueryRow(ctx, fmt.Sprintf(
		"SELECT item.id FROM %s item WHERE item.id=$1 AND %s AND item.status='active' LIMIT 1",
		table, scopeClause,
	), id, customerID).Scan(&found)
	if errors.Is(err, database.ErrNoRows) {
		return validationError(code, "Referensi tidak aktif atau bukan milik Customer survei.")
	}
	return err
}

func (r Repository) validateSeverityTx(ctx context.Context, tx database.Tx, customerID, surveyTypeID uuid.UUID, severityCode string) error {
	var code string
	err := tx.QueryRow(ctx, `
		SELECT severity.code
		FROM customer_survey_type_severities mapping
		JOIN finding_severities severity ON severity.id=mapping.severity_id AND severity.status='active'
		WHERE mapping.customer_id=$1 AND mapping.survey_type_id=$2
		  AND mapping.is_active=1 AND LOWER(severity.code)=LOWER($3)
		LIMIT 1
	`, customerID, surveyTypeID, strings.TrimSpace(severityCode)).Scan(&code)
	if errors.Is(err, database.ErrNoRows) {
		return validationError("DAMAGE_SEVERITY_SCOPE", "Severity tidak aktif atau tidak dipetakan ke Customer dan Survey Type ini.")
	}
	return err
}

func (r Repository) ValidatePhotoCategory(ctx context.Context, customerID, surveyTypeID uuid.UUID, categoryCode, expectedScope string) error {
	return validatePhotoCategoryQuery(ctx, r.pool, customerID, surveyTypeID, categoryCode, expectedScope)
}

func (r Repository) validatePhotoCategoryTx(ctx context.Context, tx database.Tx, customerID, surveyTypeID uuid.UUID, categoryCode, expectedScope string) error {
	return validatePhotoCategoryQuery(ctx, tx, customerID, surveyTypeID, categoryCode, expectedScope)
}

type photoCategoryQuerier interface {
	QueryRow(context.Context, string, ...any) database.Row
}

func validatePhotoCategoryQuery(ctx context.Context, query photoCategoryQuerier, customerID, surveyTypeID uuid.UUID, categoryCode, expectedScope string) error {
	if strings.TrimSpace(categoryCode) == "" {
		return validationError("PHOTO_CATEGORY_REQUIRED", "Kategori foto wajib dipilih.")
	}
	var code, appliesTo string
	err := query.QueryRow(ctx, `
		SELECT category.code, COALESCE(category.applies_to, '')
		FROM customer_survey_type_photo_categories mapping
		JOIN evidence_photo_categories category
		  ON category.id=mapping.photo_category_id AND category.status='active'
		WHERE mapping.customer_id=$1 AND mapping.survey_type_id=$2
		  AND mapping.is_active=1 AND LOWER(category.code)=LOWER($3)
		LIMIT 1
	`, customerID, surveyTypeID, strings.TrimSpace(categoryCode)).Scan(&code, &appliesTo)
	if errors.Is(err, database.ErrNoRows) {
		return validationError("PHOTO_CATEGORY_SCOPE", "Kategori foto tidak aktif atau tidak dipetakan ke Customer dan Survey Type ini.")
	}
	if err != nil {
		return err
	}
	if !strings.EqualFold(strings.TrimSpace(appliesTo), strings.TrimSpace(expectedScope)) {
		return validationError("PHOTO_CATEGORY_APPLIES_TO", "Kategori foto tidak berlaku untuk scope unggahan ini.")
	}
	return nil
}

func parseOptionalReferenceID(value, code, message string) (*uuid.UUID, error) {
	if strings.TrimSpace(value) == "" {
		return nil, nil
	}
	id, err := uuid.Parse(value)
	if err != nil {
		return nil, validationError(code, message)
	}
	return &id, nil
}
