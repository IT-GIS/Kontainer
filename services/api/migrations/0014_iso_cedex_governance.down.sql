DELETE role_permission
FROM role_permissions role_permission
JOIN permissions permission ON permission.id = role_permission.permission_id
WHERE permission.code IN ('cedex_code_proposals.view.all', 'cedex_code_proposals.review.all');

DELETE FROM permissions
WHERE code IN ('cedex_code_proposals.view.all', 'cedex_code_proposals.review.all');

DROP TABLE cedex_code_proposals;

ALTER TABLE survey_damages
  DROP COLUMN quantity_unit;

ALTER TABLE cedex_damage_decision_rules
  DROP CHECK chk_cedex_decision_rules_measurement,
  ADD CONSTRAINT chk_cedex_decision_rules_measurement
    CHECK (measurement_field IN ('length', 'width', 'depth', 'quantity', 'area', 'manual_assessment')),
  MODIFY COLUMN customer_id CHAR(36) NOT NULL;

ALTER TABLE cedex_materials
  DROP INDEX idx_cedex_materials_source,
  DROP COLUMN source_reason,
  DROP COLUMN source_type;

ALTER TABLE cedex_repairs
  DROP INDEX idx_cedex_repairs_source,
  DROP COLUMN source_reason,
  DROP COLUMN source_type;

ALTER TABLE cedex_damages
  DROP INDEX idx_cedex_damages_source,
  DROP COLUMN source_reason,
  DROP COLUMN source_type;

ALTER TABLE cedex_components
  DROP INDEX idx_cedex_components_source,
  DROP COLUMN source_reason,
  DROP COLUMN source_type,
  DROP COLUMN assembly_group;

ALTER TABLE cedex_locations
  DROP INDEX idx_cedex_locations_source,
  DROP COLUMN source_reason,
  DROP COLUMN source_type,
  DROP COLUMN transverse_span,
  DROP COLUMN end_section,
  DROP COLUMN start_section,
  DROP COLUMN vertical_code,
  DROP COLUMN sector_code,
  DROP COLUMN input_mode;
