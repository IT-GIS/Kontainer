-- ISO CEDEX governance, structured Location Code, and Surveyor proposal workflow.
-- Existing global dictionary rows are retained and explicitly marked as legacy.

ALTER TABLE cedex_locations
  ADD COLUMN input_mode VARCHAR(20) NOT NULL DEFAULT 'manual' AFTER customer_id,
  ADD COLUMN sector_code VARCHAR(1) NULL AFTER input_mode,
  ADD COLUMN vertical_code VARCHAR(1) NULL AFTER sector_code,
  ADD COLUMN start_section VARCHAR(1) NULL AFTER vertical_code,
  ADD COLUMN end_section VARCHAR(1) NULL AFTER start_section,
  ADD COLUMN transverse_span VARCHAR(10) NULL AFTER end_section,
  ADD COLUMN source_type VARCHAR(30) NOT NULL DEFAULT 'legacy' AFTER description,
  ADD COLUMN source_reason TEXT NULL AFTER source_type,
  ADD INDEX idx_cedex_locations_source (source_type);

ALTER TABLE cedex_components
  ADD COLUMN assembly_group VARCHAR(100) NULL AFTER component_name,
  ADD COLUMN source_type VARCHAR(30) NOT NULL DEFAULT 'legacy' AFTER description,
  ADD COLUMN source_reason TEXT NULL AFTER source_type,
  ADD INDEX idx_cedex_components_source (source_type);

ALTER TABLE cedex_damages
  ADD COLUMN source_type VARCHAR(30) NOT NULL DEFAULT 'legacy' AFTER description,
  ADD COLUMN source_reason TEXT NULL AFTER source_type,
  ADD INDEX idx_cedex_damages_source (source_type);

ALTER TABLE cedex_repairs
  ADD COLUMN source_type VARCHAR(30) NOT NULL DEFAULT 'legacy' AFTER description,
  ADD COLUMN source_reason TEXT NULL AFTER source_type,
  ADD INDEX idx_cedex_repairs_source (source_type);

ALTER TABLE cedex_materials
  ADD COLUMN source_type VARCHAR(30) NOT NULL DEFAULT 'legacy' AFTER description,
  ADD COLUMN source_reason TEXT NULL AFTER source_type,
  ADD INDEX idx_cedex_materials_source (source_type);

ALTER TABLE cedex_damage_decision_rules
  MODIFY COLUMN customer_id CHAR(36) NULL,
  DROP CHECK chk_cedex_decision_rules_measurement,
  ADD CONSTRAINT chk_cedex_decision_rules_measurement
    CHECK (measurement_field IN ('length', 'width', 'depth', 'thickness', 'quantity', 'area', 'manual_assessment'));

ALTER TABLE survey_damages
  ADD COLUMN quantity_unit VARCHAR(20) NULL AFTER quantity;

CREATE TABLE cedex_code_proposals (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  survey_id CHAR(36) NOT NULL,
  customer_id CHAR(36) NOT NULL,
  proposed_by CHAR(36) NOT NULL,
  code_type VARCHAR(30) NOT NULL,
  code VARCHAR(4) NOT NULL,
  description TEXT NOT NULL,
  reason TEXT NOT NULL,
  evidence_file_id CHAR(36) NULL,
  notes TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  review_note TEXT NULL,
  reviewed_by CHAR(36) NULL,
  reviewed_at DATETIME(6) NULL,
  master_entity_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_cedex_code_proposals_survey FOREIGN KEY (survey_id) REFERENCES surveys(id),
  CONSTRAINT fk_cedex_code_proposals_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_cedex_code_proposals_proposed_by FOREIGN KEY (proposed_by) REFERENCES users(id),
  CONSTRAINT fk_cedex_code_proposals_evidence FOREIGN KEY (evidence_file_id) REFERENCES file_objects(id),
  CONSTRAINT fk_cedex_code_proposals_reviewed_by FOREIGN KEY (reviewed_by) REFERENCES users(id),
  CONSTRAINT chk_cedex_code_proposals_type
    CHECK (code_type IN ('location', 'component', 'damage', 'action_repair', 'material')),
  CONSTRAINT chk_cedex_code_proposals_status
    CHECK (status IN ('pending', 'approved', 'rejected')),
  INDEX idx_cedex_code_proposals_customer_status (customer_id, status),
  INDEX idx_cedex_code_proposals_survey (survey_id),
  INDEX idx_cedex_code_proposals_proposed_by (proposed_by),
  INDEX idx_cedex_code_proposals_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT IGNORE INTO permissions (code, module, action, scope, description) VALUES
  ('cedex_code_proposals.view.all', 'cedex_code_proposals', 'view', 'all', 'View ISO CEDEX code proposals'),
  ('cedex_code_proposals.review.all', 'cedex_code_proposals', 'review', 'all', 'Review ISO CEDEX code proposals');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM roles role
JOIN permissions permission
  ON permission.code IN ('cedex_code_proposals.view.all', 'cedex_code_proposals.review.all')
WHERE role.code IN ('super_admin', 'admin');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM roles role
JOIN permissions permission ON permission.code = 'cedex_code_proposals.view.all'
WHERE role.code IN ('supervisor', 'management');
