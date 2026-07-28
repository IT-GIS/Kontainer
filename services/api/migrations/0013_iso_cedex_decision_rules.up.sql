-- ISO CEDEX technical dictionary and decision rules.
-- Additive only: legacy tables, rows, and foreign keys remain available.

ALTER TABLE cedex_components
  ADD COLUMN applicable_face VARCHAR(50) NULL AFTER component_name,
  ADD COLUMN is_structural_critical TINYINT(1) NOT NULL DEFAULT 0 AFTER applicable_face,
  ADD COLUMN display_order INT NOT NULL DEFAULT 0 AFTER description,
  ADD INDEX idx_cedex_components_customer_order (customer_id, display_order);

ALTER TABLE cedex_damages
  ADD COLUMN damage_category VARCHAR(50) NULL AFTER damage_name,
  ADD COLUMN default_severity VARCHAR(30) NOT NULL DEFAULT 'minor' AFTER damage_category,
  ADD COLUMN requires_dimension TINYINT(1) NOT NULL DEFAULT 0 AFTER default_severity,
  ADD COLUMN default_action_id CHAR(36) NULL AFTER requires_dimension,
  ADD COLUMN default_inspection_reference_id CHAR(36) NULL AFTER default_action_id,
  ADD COLUMN display_order INT NOT NULL DEFAULT 0 AFTER description,
  ADD INDEX idx_cedex_damages_customer_order (customer_id, display_order),
  ADD INDEX idx_cedex_damages_default_action (default_action_id),
  ADD INDEX idx_cedex_damages_default_reference (default_inspection_reference_id),
  ADD CONSTRAINT fk_cedex_damages_default_action
    FOREIGN KEY (default_action_id) REFERENCES cedex_repairs(id),
  ADD CONSTRAINT fk_cedex_damages_default_reference
    FOREIGN KEY (default_inspection_reference_id) REFERENCES inspection_test_parameters(id);

ALTER TABLE cedex_repairs
  ADD COLUMN result_mapping VARCHAR(50) NULL AFTER repair_name,
  ADD COLUMN requires_reinspection TINYINT(1) NOT NULL DEFAULT 0 AFTER result_mapping,
  ADD COLUMN display_order INT NOT NULL DEFAULT 0 AFTER description,
  ADD INDEX idx_cedex_repairs_customer_order (customer_id, display_order);

ALTER TABLE inspection_test_parameters
  ADD COLUMN reference_type VARCHAR(50) NULL AFTER parameter_name,
  ADD COLUMN clause_section VARCHAR(150) NULL AFTER standard_reference,
  ADD COLUMN effective_date DATE NULL AFTER clause_section,
  ADD COLUMN expiry_date DATE NULL AFTER effective_date,
  ADD COLUMN reference_attachment_file_id CHAR(36) NULL AFTER expiry_date,
  ADD INDEX idx_inspection_test_parameters_reference_type (reference_type),
  ADD INDEX idx_inspection_test_parameters_validity (effective_date, expiry_date),
  ADD INDEX idx_inspection_test_parameters_attachment (reference_attachment_file_id),
  ADD CONSTRAINT fk_inspection_test_parameters_attachment
    FOREIGN KEY (reference_attachment_file_id) REFERENCES file_objects(id);

CREATE TABLE cedex_damage_decision_rules (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  customer_id CHAR(36) NOT NULL,
  damage_id CHAR(36) NOT NULL,
  component_id CHAR(36) NULL,
  location_id CHAR(36) NULL,
  material_id CHAR(36) NULL,
  container_type_id CHAR(36) NULL,
  container_lifecycle VARCHAR(30) NULL,
  inspection_reference_id CHAR(36) NOT NULL,
  measurement_field VARCHAR(30) NOT NULL,
  comparison_operator VARCHAR(20) NOT NULL,
  minimum_value DECIMAL(14,4) NULL,
  maximum_value DECIMAL(14,4) NULL,
  unit VARCHAR(30) NULL,
  decision_result VARCHAR(40) NOT NULL,
  recommended_action_id CHAR(36) NULL,
  decision_note TEXT NULL,
  priority INT NOT NULL DEFAULT 0,
  valid_from DATE NULL,
  valid_until DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_cedex_decision_rules_customer_damage (customer_id, damage_id, status),
  INDEX idx_cedex_decision_rules_component (component_id),
  INDEX idx_cedex_decision_rules_location (location_id),
  INDEX idx_cedex_decision_rules_material (material_id),
  INDEX idx_cedex_decision_rules_container_type (container_type_id),
  INDEX idx_cedex_decision_rules_reference (inspection_reference_id),
  INDEX idx_cedex_decision_rules_action (recommended_action_id),
  INDEX idx_cedex_decision_rules_validity (valid_from, valid_until),
  CONSTRAINT fk_cedex_decision_rules_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_cedex_decision_rules_damage FOREIGN KEY (damage_id) REFERENCES cedex_damages(id),
  CONSTRAINT fk_cedex_decision_rules_component FOREIGN KEY (component_id) REFERENCES cedex_components(id),
  CONSTRAINT fk_cedex_decision_rules_location FOREIGN KEY (location_id) REFERENCES cedex_locations(id),
  CONSTRAINT fk_cedex_decision_rules_material FOREIGN KEY (material_id) REFERENCES cedex_materials(id),
  CONSTRAINT fk_cedex_decision_rules_container_type FOREIGN KEY (container_type_id) REFERENCES container_types(id),
  CONSTRAINT fk_cedex_decision_rules_reference FOREIGN KEY (inspection_reference_id) REFERENCES inspection_test_parameters(id),
  CONSTRAINT fk_cedex_decision_rules_action FOREIGN KEY (recommended_action_id) REFERENCES cedex_repairs(id),
  CONSTRAINT chk_cedex_decision_rules_lifecycle
    CHECK (container_lifecycle IS NULL OR container_lifecycle IN ('new', 'existing')),
  CONSTRAINT chk_cedex_decision_rules_measurement
    CHECK (measurement_field IN ('length', 'width', 'depth', 'thickness', 'quantity', 'area', 'manual_assessment')),
  CONSTRAINT chk_cedex_decision_rules_operator
    CHECK (comparison_operator IN ('lt', 'lte', 'eq', 'gt', 'gte', 'between', 'manual')),
  CONSTRAINT chk_cedex_decision_rules_result
    CHECK (decision_result IN ('passed', 'need_repair', 'need_reinspection', 'not_passed', 'manual_review')),
  CONSTRAINT chk_cedex_decision_rules_priority CHECK (priority >= 0),
  CONSTRAINT chk_cedex_decision_rules_status CHECK (status IN ('active', 'inactive'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE survey_general_infos
  ADD COLUMN container_lifecycle VARCHAR(30) NULL AFTER general_condition;

ALTER TABLE survey_damages
  ADD COLUMN decision_rule_id CHAR(36) NULL AFTER responsibility_id,
  ADD COLUMN inspection_reference_id CHAR(36) NULL AFTER decision_rule_id,
  ADD COLUMN recommended_action_id CHAR(36) NULL AFTER inspection_reference_id,
  ADD COLUMN decision_result VARCHAR(40) NULL AFTER recommended_action_id,
  ADD COLUMN decision_reason TEXT NULL AFTER decision_result,
  ADD COLUMN tolerance_snapshot JSON NULL AFTER decision_reason,
  ADD COLUMN finding_description TEXT NULL AFTER tolerance_snapshot,
  ADD INDEX idx_survey_damages_decision_rule (decision_rule_id),
  ADD INDEX idx_survey_damages_inspection_reference (inspection_reference_id),
  ADD INDEX idx_survey_damages_recommended_action (recommended_action_id),
  ADD INDEX idx_survey_damages_decision_result (decision_result),
  ADD CONSTRAINT fk_survey_damages_decision_rule
    FOREIGN KEY (decision_rule_id) REFERENCES cedex_damage_decision_rules(id),
  ADD CONSTRAINT fk_survey_damages_inspection_reference
    FOREIGN KEY (inspection_reference_id) REFERENCES inspection_test_parameters(id),
  ADD CONSTRAINT fk_survey_damages_recommended_action
    FOREIGN KEY (recommended_action_id) REFERENCES cedex_repairs(id);
