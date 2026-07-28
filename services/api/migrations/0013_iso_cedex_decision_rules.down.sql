ALTER TABLE survey_damages
  DROP FOREIGN KEY fk_survey_damages_recommended_action,
  DROP FOREIGN KEY fk_survey_damages_inspection_reference,
  DROP FOREIGN KEY fk_survey_damages_decision_rule,
  DROP INDEX idx_survey_damages_decision_result,
  DROP INDEX idx_survey_damages_recommended_action,
  DROP INDEX idx_survey_damages_inspection_reference,
  DROP INDEX idx_survey_damages_decision_rule,
  DROP COLUMN finding_description,
  DROP COLUMN tolerance_snapshot,
  DROP COLUMN decision_reason,
  DROP COLUMN decision_result,
  DROP COLUMN recommended_action_id,
  DROP COLUMN inspection_reference_id,
  DROP COLUMN decision_rule_id;

ALTER TABLE survey_general_infos
  DROP COLUMN container_lifecycle;

DROP TABLE cedex_damage_decision_rules;

ALTER TABLE inspection_test_parameters
  DROP FOREIGN KEY fk_inspection_test_parameters_attachment,
  DROP INDEX idx_inspection_test_parameters_attachment,
  DROP INDEX idx_inspection_test_parameters_validity,
  DROP INDEX idx_inspection_test_parameters_reference_type,
  DROP COLUMN reference_attachment_file_id,
  DROP COLUMN expiry_date,
  DROP COLUMN effective_date,
  DROP COLUMN clause_section,
  DROP COLUMN reference_type;

ALTER TABLE cedex_repairs
  DROP INDEX idx_cedex_repairs_customer_order,
  DROP COLUMN display_order,
  DROP COLUMN requires_reinspection,
  DROP COLUMN result_mapping;

ALTER TABLE cedex_damages
  DROP FOREIGN KEY fk_cedex_damages_default_reference,
  DROP FOREIGN KEY fk_cedex_damages_default_action,
  DROP INDEX idx_cedex_damages_default_reference,
  DROP INDEX idx_cedex_damages_default_action,
  DROP INDEX idx_cedex_damages_customer_order,
  DROP COLUMN display_order,
  DROP COLUMN default_inspection_reference_id,
  DROP COLUMN default_action_id,
  DROP COLUMN requires_dimension,
  DROP COLUMN default_severity,
  DROP COLUMN damage_category;

ALTER TABLE cedex_components
  DROP INDEX idx_cedex_components_customer_order,
  DROP COLUMN display_order,
  DROP COLUMN is_structural_critical,
  DROP COLUMN applicable_face;
