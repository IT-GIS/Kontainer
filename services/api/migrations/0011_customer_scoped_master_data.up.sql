-- Customer-scoped operational master data.
-- Existing reference rows remain legacy/unassigned with customer_id = NULL.

ALTER TABLE locations
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  ADD COLUMN province VARCHAR(100) NULL AFTER city,
  ADD COLUMN postal_code VARCHAR(20) NULL AFTER province,
  ADD COLUMN pic_email VARCHAR(150) NULL AFTER pic_phone,
  ADD COLUMN access_notes TEXT NULL AFTER pic_email,
  DROP INDEX idx_locations_code,
  ADD UNIQUE INDEX uq_locations_customer_code (customer_id, location_code),
  ADD INDEX idx_locations_customer (customer_id),
  ADD INDEX idx_locations_customer_status (customer_id, status),
  ADD CONSTRAINT fk_locations_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE container_types
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  DROP INDEX code,
  ADD UNIQUE INDEX uq_container_types_customer_code (customer_id, code),
  ADD INDEX idx_container_types_customer (customer_id),
  ADD INDEX idx_container_types_customer_status (customer_id, status),
  ADD CONSTRAINT fk_container_types_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE survey_types
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  DROP INDEX code,
  ADD UNIQUE INDEX uq_survey_types_customer_code (customer_id, code),
  ADD INDEX idx_survey_types_customer (customer_id),
  ADD INDEX idx_survey_types_customer_status (customer_id, status),
  ADD CONSTRAINT fk_survey_types_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE cedex_locations
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  DROP INDEX idx_cedex_locations_unique_scope,
  ADD UNIQUE INDEX uq_cedex_locations_customer_code (customer_id, code),
  ADD INDEX idx_cedex_locations_customer (customer_id),
  ADD INDEX idx_cedex_locations_customer_status (customer_id, status),
  ADD CONSTRAINT fk_cedex_locations_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE cedex_components
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  DROP INDEX code,
  ADD UNIQUE INDEX uq_cedex_components_customer_code (customer_id, code),
  ADD INDEX idx_cedex_components_customer (customer_id),
  ADD INDEX idx_cedex_components_customer_status (customer_id, status),
  ADD CONSTRAINT fk_cedex_components_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE cedex_damages
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  DROP INDEX code,
  ADD UNIQUE INDEX uq_cedex_damages_customer_code (customer_id, code),
  ADD INDEX idx_cedex_damages_customer (customer_id),
  ADD INDEX idx_cedex_damages_customer_status (customer_id, status),
  ADD CONSTRAINT fk_cedex_damages_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE cedex_repairs
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  DROP INDEX code,
  ADD UNIQUE INDEX uq_cedex_repairs_customer_code (customer_id, code),
  ADD INDEX idx_cedex_repairs_customer (customer_id),
  ADD INDEX idx_cedex_repairs_customer_status (customer_id, status),
  ADD CONSTRAINT fk_cedex_repairs_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE cedex_materials
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  DROP INDEX code,
  ADD UNIQUE INDEX uq_cedex_materials_customer_code (customer_id, code),
  ADD INDEX idx_cedex_materials_customer (customer_id),
  ADD INDEX idx_cedex_materials_customer_status (customer_id, status),
  ADD CONSTRAINT fk_cedex_materials_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE responsibility_codes
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  DROP INDEX code,
  ADD UNIQUE INDEX uq_responsibility_codes_customer_code (customer_id, code),
  ADD INDEX idx_responsibility_codes_customer (customer_id),
  ADD INDEX idx_responsibility_codes_customer_status (customer_id, status),
  ADD CONSTRAINT fk_responsibility_codes_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

CREATE TABLE customer_personnel (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  customer_id CHAR(36) NOT NULL,
  personnel_code VARCHAR(80) NOT NULL,
  full_name VARCHAR(180) NOT NULL,
  position_title VARCHAR(150) NULL,
  personnel_type VARCHAR(80) NOT NULL,
  email VARCHAR(150) NULL,
  phone VARCHAR(50) NULL,
  notes TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL,
  CONSTRAINT fk_customer_personnel_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT uq_customer_personnel_customer_code UNIQUE (customer_id, personnel_code),
  INDEX idx_customer_personnel_customer (customer_id),
  INDEX idx_customer_personnel_customer_status (customer_id, status),
  INDEX idx_customer_personnel_deleted_at (deleted_at)
);

CREATE TABLE customer_personnel_locations (
  customer_personnel_id CHAR(36) NOT NULL,
  location_id CHAR(36) NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (customer_personnel_id, location_id),
  CONSTRAINT fk_customer_personnel_locations_personnel FOREIGN KEY (customer_personnel_id) REFERENCES customer_personnel(id) ON DELETE CASCADE,
  CONSTRAINT fk_customer_personnel_locations_location FOREIGN KEY (location_id) REFERENCES locations(id),
  INDEX idx_customer_personnel_locations_location (location_id)
);

ALTER TABLE job_orders
  ADD COLUMN pic_customer_personnel_id CHAR(36) NULL AFTER location_id,
  ADD INDEX idx_job_orders_pic_customer_personnel (pic_customer_personnel_id),
  ADD CONSTRAINT fk_job_orders_pic_customer_personnel FOREIGN KEY (pic_customer_personnel_id) REFERENCES customer_personnel(id);

ALTER TABLE fitness_checklist_templates
  ADD COLUMN customer_id CHAR(36) NULL AFTER id,
  ADD COLUMN survey_type_id CHAR(36) NULL AFTER approval_category_id,
  DROP INDEX template_code,
  ADD UNIQUE INDEX uq_fitness_checklist_templates_customer_code (customer_id, template_code),
  ADD INDEX idx_fitness_checklist_templates_customer (customer_id),
  ADD INDEX idx_fitness_checklist_templates_customer_status (customer_id, status),
  ADD INDEX idx_fitness_checklist_templates_survey_type (survey_type_id),
  ADD CONSTRAINT fk_fitness_checklist_templates_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  ADD CONSTRAINT fk_fitness_checklist_templates_survey_type FOREIGN KEY (survey_type_id) REFERENCES survey_types(id);

CREATE TABLE customer_survey_type_severities (
  customer_id CHAR(36) NOT NULL,
  survey_type_id CHAR(36) NOT NULL,
  severity_id CHAR(36) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (customer_id, survey_type_id, severity_id),
  CONSTRAINT fk_customer_survey_type_severities_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_customer_survey_type_severities_survey_type FOREIGN KEY (survey_type_id) REFERENCES survey_types(id),
  CONSTRAINT fk_customer_survey_type_severities_severity FOREIGN KEY (severity_id) REFERENCES finding_severities(id),
  INDEX idx_customer_survey_type_severities_lookup (customer_id, survey_type_id, is_active)
);

CREATE TABLE customer_survey_type_test_parameters (
  customer_id CHAR(36) NOT NULL,
  survey_type_id CHAR(36) NOT NULL,
  test_parameter_id CHAR(36) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (customer_id, survey_type_id, test_parameter_id),
  CONSTRAINT fk_customer_survey_type_tests_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_customer_survey_type_tests_survey_type FOREIGN KEY (survey_type_id) REFERENCES survey_types(id),
  CONSTRAINT fk_customer_survey_type_tests_parameter FOREIGN KEY (test_parameter_id) REFERENCES inspection_test_parameters(id),
  INDEX idx_customer_survey_type_tests_lookup (customer_id, survey_type_id, is_active)
);

CREATE TABLE customer_survey_type_photo_categories (
  customer_id CHAR(36) NOT NULL,
  survey_type_id CHAR(36) NOT NULL,
  photo_category_id CHAR(36) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (customer_id, survey_type_id, photo_category_id),
  CONSTRAINT fk_customer_survey_type_photos_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_customer_survey_type_photos_survey_type FOREIGN KEY (survey_type_id) REFERENCES survey_types(id),
  CONSTRAINT fk_customer_survey_type_photos_category FOREIGN KEY (photo_category_id) REFERENCES evidence_photo_categories(id),
  INDEX idx_customer_survey_type_photos_lookup (customer_id, survey_type_id, is_active)
);

ALTER TABLE surveys
  ADD COLUMN checklist_template_id CHAR(36) NULL AFTER survey_type_id,
  ADD INDEX idx_surveys_checklist_template (checklist_template_id),
  ADD CONSTRAINT fk_surveys_checklist_template FOREIGN KEY (checklist_template_id) REFERENCES fitness_checklist_templates(id);

ALTER TABLE survey_checklist_responses
  ADD COLUMN response_numeric DECIMAL(14,4) NULL AFTER response_value,
  ADD COLUMN response_type VARCHAR(50) NOT NULL DEFAULT 'ok_not_ok' AFTER response_text,
  ADD COLUMN unit VARCHAR(50) NULL AFTER response_type,
  ADD COLUMN standard_reference VARCHAR(200) NULL AFTER unit,
  ADD COLUMN requires_attachment TINYINT(1) NOT NULL DEFAULT 0 AFTER is_critical,
  ADD COLUMN attachment_file_id CHAR(36) NULL AFTER requires_attachment,
  ADD INDEX idx_survey_checklist_attachment (attachment_file_id),
  ADD CONSTRAINT fk_survey_checklist_attachment FOREIGN KEY (attachment_file_id) REFERENCES file_objects(id);

ALTER TABLE survey_damages
  ADD COLUMN manual_location_reason TEXT NULL AFTER cedex_location_id;
