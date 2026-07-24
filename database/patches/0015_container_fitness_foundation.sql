-- 0015_container_fitness_foundation.sql
-- Database foundation for Sistem Kelaikan Peti Kemas.
-- Additive only: no legacy table is dropped, renamed, or destructively changed.

CREATE TABLE IF NOT EXISTS container_manufacturers (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  manufacturer_code VARCHAR(50) NOT NULL UNIQUE,
  manufacturer_name VARCHAR(200) NOT NULL,
  address TEXT NULL,
  country VARCHAR(100) NULL,
  pic_name VARCHAR(150) NULL,
  pic_phone VARCHAR(50) NULL,
  pic_email VARCHAR(150) NULL,
  website VARCHAR(150) NULL,
  note TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL,
  INDEX idx_container_manufacturers_code (manufacturer_code),
  INDEX idx_container_manufacturers_name (manufacturer_name),
  INDEX idx_container_manufacturers_status (status),
  INDEX idx_container_manufacturers_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fitness_approval_categories (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  container_lifecycle VARCHAR(50) NOT NULL,
  is_mvp_active TINYINT(1) NOT NULL DEFAULT 1,
  display_order INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_fitness_approval_categories_lifecycle (container_lifecycle),
  INDEX idx_fitness_approval_categories_mvp (is_mvp_active),
  INDEX idx_fitness_approval_categories_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS maintenance_schemes (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  requires_next_examination_date TINYINT(1) NOT NULL DEFAULT 0,
  default_interval_months INT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_maintenance_schemes_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS inspection_areas (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(50) NOT NULL UNIQUE,
  area_name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  display_order INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_inspection_areas_status (status),
  INDEX idx_inspection_areas_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS structural_components (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(50) NOT NULL UNIQUE,
  component_name VARCHAR(180) NOT NULL,
  inspection_area_id CHAR(36) NULL,
  is_structural_critical TINYINT(1) NOT NULL DEFAULT 0,
  description TEXT NULL,
  display_order INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_structural_components_area (inspection_area_id),
  INDEX idx_structural_components_status (status),
  INDEX idx_structural_components_display_order (display_order),
  CONSTRAINT fk_structural_components_area FOREIGN KEY (inspection_area_id) REFERENCES inspection_areas(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS structural_damage_criteria (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(80) NOT NULL UNIQUE,
  criteria_name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  component_id CHAR(36) NULL,
  severity_default VARCHAR(30) NOT NULL DEFAULT 'minor',
  affects_fitness_default TINYINT(1) NOT NULL DEFAULT 0,
  repair_required_default TINYINT(1) NOT NULL DEFAULT 0,
  inspection_note TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_structural_damage_criteria_component (component_id),
  INDEX idx_structural_damage_criteria_severity (severity_default),
  INDEX idx_structural_damage_criteria_status (status),
  CONSTRAINT fk_structural_damage_criteria_component FOREIGN KEY (component_id) REFERENCES structural_components(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS finding_severities (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT NULL,
  level_no INT NOT NULL,
  affects_fitness_default TINYINT(1) NOT NULL DEFAULT 0,
  requires_supervisor_review TINYINT(1) NOT NULL DEFAULT 0,
  badge_tone VARCHAR(30) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_finding_severities_level (level_no),
  INDEX idx_finding_severities_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS inspection_test_parameters (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(80) NOT NULL UNIQUE,
  parameter_name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  unit VARCHAR(50) NULL,
  standard_reference VARCHAR(200) NULL,
  applies_to_new_container TINYINT(1) NOT NULL DEFAULT 1,
  applies_to_existing_container TINYINT(1) NOT NULL DEFAULT 1,
  requires_numeric_result TINYINT(1) NOT NULL DEFAULT 0,
  requires_attachment TINYINT(1) NOT NULL DEFAULT 0,
  display_order INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_inspection_test_parameters_status (status),
  INDEX idx_inspection_test_parameters_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fitness_checklist_templates (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  template_code VARCHAR(80) NOT NULL UNIQUE,
  template_name VARCHAR(180) NOT NULL,
  approval_category_id CHAR(36) NULL,
  container_type_id CHAR(36) NULL,
  description TEXT NULL,
  version_no INT NOT NULL DEFAULT 1,
  status VARCHAR(30) NOT NULL DEFAULT 'draft',
  created_by CHAR(36) NULL,
  approved_by CHAR(36) NULL,
  approved_at DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL,
  INDEX idx_fitness_checklist_templates_category (approval_category_id),
  INDEX idx_fitness_checklist_templates_container_type (container_type_id),
  INDEX idx_fitness_checklist_templates_status (status),
  INDEX idx_fitness_checklist_templates_deleted_at (deleted_at),
  CONSTRAINT fk_fitness_checklist_templates_category FOREIGN KEY (approval_category_id) REFERENCES fitness_approval_categories(id),
  CONSTRAINT fk_fitness_checklist_templates_container_type FOREIGN KEY (container_type_id) REFERENCES container_types(id),
  CONSTRAINT fk_fitness_checklist_templates_created_by FOREIGN KEY (created_by) REFERENCES users(id),
  CONSTRAINT fk_fitness_checklist_templates_approved_by FOREIGN KEY (approved_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fitness_checklist_template_items (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  template_id CHAR(36) NOT NULL,
  item_code VARCHAR(80) NOT NULL,
  item_label VARCHAR(255) NOT NULL,
  description TEXT NULL,
  inspection_area_id CHAR(36) NULL,
  structural_component_id CHAR(36) NULL,
  test_parameter_id CHAR(36) NULL,
  response_type VARCHAR(50) NOT NULL DEFAULT 'ok_not_ok',
  expected_value VARCHAR(150) NULL,
  is_required TINYINT(1) NOT NULL DEFAULT 1,
  is_critical TINYINT(1) NOT NULL DEFAULT 0,
  fail_requires_repair TINYINT(1) NOT NULL DEFAULT 0,
  fail_marks_unfit TINYINT(1) NOT NULL DEFAULT 0,
  display_order INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_fitness_checklist_template_items_code (template_id, item_code),
  INDEX idx_fitness_checklist_template_items_area (inspection_area_id),
  INDEX idx_fitness_checklist_template_items_component (structural_component_id),
  INDEX idx_fitness_checklist_template_items_test_parameter (test_parameter_id),
  INDEX idx_fitness_checklist_template_items_status (status),
  CONSTRAINT fk_fitness_checklist_template_items_template FOREIGN KEY (template_id) REFERENCES fitness_checklist_templates(id),
  CONSTRAINT fk_fitness_checklist_template_items_area FOREIGN KEY (inspection_area_id) REFERENCES inspection_areas(id),
  CONSTRAINT fk_fitness_checklist_template_items_component FOREIGN KEY (structural_component_id) REFERENCES structural_components(id),
  CONSTRAINT fk_fitness_checklist_template_items_test_parameter FOREIGN KEY (test_parameter_id) REFERENCES inspection_test_parameters(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS evidence_photo_categories (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  is_required_default TINYINT(1) NOT NULL DEFAULT 0,
  applies_to VARCHAR(80) NULL,
  display_order INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_evidence_photo_categories_status (status),
  INDEX idx_evidence_photo_categories_display_order (display_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS inspection_recommendations (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(80) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  final_fitness_result_mapping VARCHAR(50) NOT NULL DEFAULT 'pending',
  workflow_status_mapping VARCHAR(50) NULL,
  restriction_status_mapping VARCHAR(50) NULL,
  requires_supervisor_review TINYINT(1) NOT NULL DEFAULT 1,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_inspection_recommendations_result (final_fitness_result_mapping),
  INDEX idx_inspection_recommendations_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS authorized_signers (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  signer_name VARCHAR(180) NOT NULL,
  position_title VARCHAR(180) NOT NULL,
  employee_no VARCHAR(80) NULL,
  email VARCHAR(150) NULL,
  phone VARCHAR(50) NULL,
  signature_file_id CHAR(36) NULL,
  valid_from DATE NULL,
  valid_until DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL,
  INDEX idx_authorized_signers_status (status),
  INDEX idx_authorized_signers_deleted_at (deleted_at),
  CONSTRAINT fk_authorized_signers_signature_file FOREIGN KEY (signature_file_id) REFERENCES file_objects(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fitness_applications (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  application_no VARCHAR(80) NOT NULL UNIQUE,
  application_date DATE NOT NULL,
  owner_id CHAR(36) NOT NULL,
  manufacturer_id CHAR(36) NULL,
  location_id CHAR(36) NOT NULL,
  approval_category_id CHAR(36) NOT NULL,
  client_letter_no VARCHAR(120) NULL,
  client_letter_date DATE NULL,
  pic_name VARCHAR(150) NULL,
  pic_phone VARCHAR(50) NULL,
  pic_email VARCHAR(150) NULL,
  instruction TEXT NULL,
  workflow_status VARCHAR(50) NOT NULL DEFAULT 'draft',
  created_by CHAR(36) NULL,
  updated_by CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL,
  INDEX idx_fitness_applications_owner (owner_id),
  INDEX idx_fitness_applications_manufacturer (manufacturer_id),
  INDEX idx_fitness_applications_location (location_id),
  INDEX idx_fitness_applications_category (approval_category_id),
  INDEX idx_fitness_applications_workflow_status (workflow_status),
  INDEX idx_fitness_applications_deleted_at (deleted_at),
  CONSTRAINT fk_fitness_applications_owner FOREIGN KEY (owner_id) REFERENCES customers(id),
  CONSTRAINT fk_fitness_applications_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES container_manufacturers(id),
  CONSTRAINT fk_fitness_applications_location FOREIGN KEY (location_id) REFERENCES locations(id),
  CONSTRAINT fk_fitness_applications_category FOREIGN KEY (approval_category_id) REFERENCES fitness_approval_categories(id),
  CONSTRAINT fk_fitness_applications_created_by FOREIGN KEY (created_by) REFERENCES users(id),
  CONSTRAINT fk_fitness_applications_updated_by FOREIGN KEY (updated_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS application_containers (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  fitness_application_id CHAR(36) NOT NULL,
  container_no VARCHAR(20) NOT NULL,
  owner_code VARCHAR(4) NULL,
  serial_number VARCHAR(10) NULL,
  check_digit VARCHAR(2) NULL,
  check_digit_status VARCHAR(30) NOT NULL DEFAULT 'not_checked',
  check_digit_override_reason TEXT NULL,
  container_type_id CHAR(36) NULL,
  iso_type_code VARCHAR(20) NULL,
  workflow_status VARCHAR(50) NOT NULL DEFAULT 'draft',
  final_fitness_result VARCHAR(50) NOT NULL DEFAULT 'pending',
  restriction_status VARCHAR(50) NOT NULL DEFAULT 'none',
  approval_status VARCHAR(50) NOT NULL DEFAULT 'not_ready',
  remark TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL,
  UNIQUE KEY uq_application_containers_application_container_no (fitness_application_id, container_no),
  INDEX idx_application_containers_application (fitness_application_id),
  INDEX idx_application_containers_container_type (container_type_id),
  INDEX idx_application_containers_container_no (container_no),
  INDEX idx_application_containers_workflow_status (workflow_status),
  INDEX idx_application_containers_final_result (final_fitness_result),
  INDEX idx_application_containers_deleted_at (deleted_at),
  CONSTRAINT fk_application_containers_application FOREIGN KEY (fitness_application_id) REFERENCES fitness_applications(id),
  CONSTRAINT fk_application_containers_container_type FOREIGN KEY (container_type_id) REFERENCES container_types(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS container_technical_specs (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  application_container_id CHAR(36) NOT NULL UNIQUE,
  csc_no VARCHAR(120) NULL,
  manufacture_date DATE NULL,
  manufacturer_serial_no VARCHAR(120) NULL,
  type_model VARCHAR(150) NULL,
  iso_code VARCHAR(20) NULL,
  max_gross_weight_kg DECIMAL(12,2) NULL,
  max_gross_weight_lbs DECIMAL(12,2) NULL,
  tare_weight_kg DECIMAL(12,2) NULL,
  tare_weight_lbs DECIMAL(12,2) NULL,
  payload_weight_kg DECIMAL(12,2) NULL,
  payload_weight_lbs DECIMAL(12,2) NULL,
  cube_capacity_m3 DECIMAL(12,3) NULL,
  cube_capacity_ft3 DECIMAL(12,3) NULL,
  allowable_stacking_weight_kg DECIMAL(12,2) NULL,
  allowable_stacking_weight_lbs DECIMAL(12,2) NULL,
  racking_test_load_value_kg DECIMAL(12,2) NULL,
  racking_test_load_value_lbs DECIMAL(12,2) NULL,
  end_wall_strength VARCHAR(100) NULL,
  side_wall_strength VARCHAR(100) NULL,
  next_examination_date DATE NULL,
  maintenance_scheme_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_container_technical_specs_csc_no (csc_no),
  INDEX idx_container_technical_specs_maintenance_scheme (maintenance_scheme_id),
  CONSTRAINT fk_container_technical_specs_application_container FOREIGN KEY (application_container_id) REFERENCES application_containers(id),
  CONSTRAINT fk_container_technical_specs_maintenance_scheme FOREIGN KEY (maintenance_scheme_id) REFERENCES maintenance_schemes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fitness_application_events (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  fitness_application_id CHAR(36) NOT NULL,
  application_container_id CHAR(36) NULL,
  event_type VARCHAR(100) NOT NULL,
  event_title VARCHAR(200) NOT NULL,
  event_description TEXT NULL,
  old_status VARCHAR(50) NULL,
  new_status VARCHAR(50) NULL,
  actor_id CHAR(36) NULL,
  metadata JSON NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_fitness_application_events_application (fitness_application_id),
  INDEX idx_fitness_application_events_container (application_container_id),
  INDEX idx_fitness_application_events_actor (actor_id),
  INDEX idx_fitness_application_events_type (event_type),
  CONSTRAINT fk_fitness_application_events_application FOREIGN KEY (fitness_application_id) REFERENCES fitness_applications(id),
  CONSTRAINT fk_fitness_application_events_container FOREIGN KEY (application_container_id) REFERENCES application_containers(id),
  CONSTRAINT fk_fitness_application_events_actor FOREIGN KEY (actor_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fitness_container_import_batches (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  fitness_application_id CHAR(36) NOT NULL,
  file_id CHAR(36) NULL,
  original_file_name VARCHAR(255) NULL,
  total_rows INT NOT NULL DEFAULT 0,
  success_rows INT NOT NULL DEFAULT 0,
  failed_rows INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'draft',
  error_summary JSON NULL,
  imported_by CHAR(36) NULL,
  imported_at DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_fitness_container_import_batches_application (fitness_application_id),
  INDEX idx_fitness_container_import_batches_file (file_id),
  INDEX idx_fitness_container_import_batches_status (status),
  INDEX idx_fitness_container_import_batches_imported_by (imported_by),
  CONSTRAINT fk_fitness_container_import_batches_application FOREIGN KEY (fitness_application_id) REFERENCES fitness_applications(id),
  CONSTRAINT fk_fitness_container_import_batches_file FOREIGN KEY (file_id) REFERENCES file_objects(id),
  CONSTRAINT fk_fitness_container_import_batches_imported_by FOREIGN KEY (imported_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS fitness_container_import_rows (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  import_batch_id CHAR(36) NOT NULL,
  row_no INT NOT NULL,
  raw_data JSON NULL,
  container_no VARCHAR(20) NULL,
  container_type VARCHAR(80) NULL,
  iso_type_code VARCHAR(20) NULL,
  csc_no VARCHAR(120) NULL,
  manufacture_date DATE NULL,
  manufacturer_serial_no VARCHAR(120) NULL,
  type_model VARCHAR(150) NULL,
  max_gross_weight_kg DECIMAL(12,2) NULL,
  tare_weight_kg DECIMAL(12,2) NULL,
  payload_weight_kg DECIMAL(12,2) NULL,
  validation_status VARCHAR(30) NOT NULL DEFAULT 'pending',
  validation_errors JSON NULL,
  application_container_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_fitness_container_import_rows_batch_row (import_batch_id, row_no),
  INDEX idx_fitness_container_import_rows_batch (import_batch_id),
  INDEX idx_fitness_container_import_rows_container_no (container_no),
  INDEX idx_fitness_container_import_rows_status (validation_status),
  INDEX idx_fitness_container_import_rows_application_container (application_container_id),
  CONSTRAINT fk_fitness_container_import_rows_batch FOREIGN KEY (import_batch_id) REFERENCES fitness_container_import_batches(id),
  CONSTRAINT fk_fitness_container_import_rows_application_container FOREIGN KEY (application_container_id) REFERENCES application_containers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT IGNORE INTO fitness_approval_categories (code, name, description, container_lifecycle, is_mvp_active, display_order, status)
VALUES
  ('new_individual', 'Peti Kemas Baru Individual', 'Persetujuan kelaikan untuk peti kemas baru individual.', 'new', 1, 10, 'active'),
  ('existing_used', 'Peti Kemas Lama yang Telah Digunakan', 'Persetujuan kelaikan untuk peti kemas lama yang telah digunakan.', 'existing', 1, 20, 'active'),
  ('existing_produced_without_initial_approval', 'Peti Kemas yang Sudah Diproduksi dan Belum Mendapat Persetujuan Awal', 'Persetujuan kelaikan untuk peti kemas yang sudah diproduksi dan belum mendapat persetujuan awal.', 'existing', 1, 30, 'active'),
  ('type_design', 'Peti Kemas Baru Type Design', 'Future scope; tidak aktif pada MVP.', 'new', 0, 90, 'inactive');

INSERT IGNORE INTO maintenance_schemes (code, name, description, requires_next_examination_date, default_interval_months, status)
VALUES
  ('ACEP', 'ACEP', 'Approved continuous examination program.', 1, NULL, 'active'),
  ('PES', 'PES', 'Periodic examination scheme.', 1, 30, 'active'),
  ('IICL', 'IICL', 'IICL-based maintenance reference.', 0, NULL, 'active'),
  ('ISO', 'ISO', 'ISO-based maintenance reference.', 0, NULL, 'active'),
  ('NED', 'NED', 'Next examination date reference.', 1, NULL, 'active'),
  ('OTHER', 'Other', 'Other maintenance scheme.', 0, NULL, 'active');

INSERT IGNORE INTO inspection_areas (code, area_name, description, display_order, status)
VALUES
  ('left_side', 'Left Side', 'Sisi kiri peti kemas.', 10, 'active'),
  ('right_side', 'Right Side', 'Sisi kanan peti kemas.', 20, 'active'),
  ('front_end', 'Front End', 'Bagian depan peti kemas.', 30, 'active'),
  ('door_end', 'Door End', 'Bagian pintu peti kemas.', 40, 'active'),
  ('roof', 'Roof', 'Atap peti kemas.', 50, 'active'),
  ('floor', 'Floor', 'Lantai peti kemas.', 60, 'active'),
  ('understructure', 'Understructure', 'Struktur bawah peti kemas.', 70, 'active'),
  ('corner_area', 'Corner Area', 'Area corner post dan corner fitting.', 80, 'active'),
  ('csc_plate_area', 'CSC Plate Area', 'Area plate persetujuan keselamatan.', 90, 'active');

INSERT IGNORE INTO structural_components (code, component_name, inspection_area_id, is_structural_critical, description, display_order, status)
VALUES
  ('top_side_rail', 'Top Side Rail', (SELECT id FROM inspection_areas WHERE code='roof'), 1, NULL, 10, 'active'),
  ('bottom_side_rail', 'Bottom Side Rail', (SELECT id FROM inspection_areas WHERE code='understructure'), 1, NULL, 20, 'active'),
  ('header', 'Header', (SELECT id FROM inspection_areas WHERE code='front_end'), 1, NULL, 30, 'active'),
  ('sill', 'Sill', (SELECT id FROM inspection_areas WHERE code='door_end'), 1, NULL, 40, 'active'),
  ('corner_post', 'Corner Post', (SELECT id FROM inspection_areas WHERE code='corner_area'), 1, NULL, 50, 'active'),
  ('corner_fitting', 'Corner Fitting', (SELECT id FROM inspection_areas WHERE code='corner_area'), 1, NULL, 60, 'active'),
  ('intermediate_fitting', 'Intermediate Fitting', (SELECT id FROM inspection_areas WHERE code='corner_area'), 1, NULL, 70, 'active'),
  ('cross_member', 'Cross Member', (SELECT id FROM inspection_areas WHERE code='understructure'), 1, NULL, 80, 'active'),
  ('understructure', 'Understructure', (SELECT id FROM inspection_areas WHERE code='understructure'), 1, NULL, 90, 'active'),
  ('floor', 'Floor', (SELECT id FROM inspection_areas WHERE code='floor'), 0, NULL, 100, 'active'),
  ('roof', 'Roof', (SELECT id FROM inspection_areas WHERE code='roof'), 0, NULL, 110, 'active'),
  ('side_wall', 'Side Wall', (SELECT id FROM inspection_areas WHERE code='left_side'), 0, NULL, 120, 'active'),
  ('end_wall', 'End Wall', (SELECT id FROM inspection_areas WHERE code='front_end'), 0, NULL, 130, 'active'),
  ('door_panel', 'Door Panel', (SELECT id FROM inspection_areas WHERE code='door_end'), 0, NULL, 140, 'active'),
  ('door_locking_rod', 'Door Locking Rod', (SELECT id FROM inspection_areas WHERE code='door_end'), 1, NULL, 150, 'active'),
  ('csc_safety_approval_plate', 'CSC Safety Approval Plate', (SELECT id FROM inspection_areas WHERE code='csc_plate_area'), 1, NULL, 160, 'active');

INSERT IGNORE INTO structural_damage_criteria (code, criteria_name, description, component_id, severity_default, affects_fitness_default, repair_required_default, inspection_note, status)
VALUES
  ('dent', 'Dent', 'Penyok pada komponen peti kemas.', NULL, 'minor', 0, 0, NULL, 'active'),
  ('crack', 'Crack', 'Retak pada komponen peti kemas.', NULL, 'major', 1, 1, NULL, 'active'),
  ('hole', 'Hole', 'Lubang pada komponen peti kemas.', NULL, 'major', 1, 1, NULL, 'active'),
  ('broken', 'Broken', 'Komponen patah atau rusak berat.', NULL, 'critical', 1, 1, NULL, 'active'),
  ('bent', 'Bent', 'Komponen bengkok atau berubah bentuk.', NULL, 'major', 1, 1, NULL, 'active'),
  ('missing', 'Missing', 'Komponen hilang.', NULL, 'critical', 1, 1, NULL, 'active'),
  ('corrosion', 'Corrosion', 'Korosi pada komponen.', NULL, 'minor', 0, 0, NULL, 'active'),
  ('severe_corrosion', 'Severe Corrosion', 'Korosi berat pada komponen.', NULL, 'critical', 1, 1, NULL, 'active'),
  ('loose_locking_rod', 'Loose Locking Rod', 'Locking rod longgar.', (SELECT id FROM structural_components WHERE code='door_locking_rod'), 'major', 1, 1, NULL, 'active'),
  ('csc_plate_missing', 'CSC Plate Missing', 'Plate persetujuan keselamatan tidak ada.', (SELECT id FROM structural_components WHERE code='csc_safety_approval_plate'), 'critical', 1, 1, NULL, 'active'),
  ('csc_plate_unreadable', 'CSC Plate Unreadable', 'Plate persetujuan keselamatan tidak terbaca.', (SELECT id FROM structural_components WHERE code='csc_safety_approval_plate'), 'major', 1, 1, NULL, 'active'),
  ('deformation_affecting_structure', 'Deformation Affecting Structure', 'Deformasi yang memengaruhi struktur.', NULL, 'critical', 1, 1, NULL, 'active'),
  ('watertightness_failure', 'Watertightness Failure', 'Kegagalan kedap air.', NULL, 'major', 1, 1, NULL, 'active');

INSERT IGNORE INTO finding_severities (code, name, description, level_no, affects_fitness_default, requires_supervisor_review, badge_tone, status)
VALUES
  ('minor', 'Minor', 'Temuan ringan.', 1, 0, 0, 'neutral', 'active'),
  ('major', 'Major', 'Temuan signifikan yang perlu review.', 2, 1, 1, 'warning', 'active'),
  ('critical', 'Critical', 'Temuan kritikal yang memengaruhi kelaikan.', 3, 1, 1, 'danger', 'active');

INSERT IGNORE INTO inspection_test_parameters (code, parameter_name, description, unit, standard_reference, applies_to_new_container, applies_to_existing_container, requires_numeric_result, requires_attachment, display_order, status)
VALUES
  ('lifting_test', 'Lifting Test', 'Pengujian lifting.', NULL, NULL, 1, 1, 0, 0, 10, 'active'),
  ('stacking_test', 'Stacking Test', 'Pengujian stacking.', NULL, NULL, 1, 1, 0, 0, 20, 'active'),
  ('concentrated_load_test', 'Concentrated Load Test', 'Pengujian concentrated load.', NULL, NULL, 1, 1, 0, 0, 30, 'active'),
  ('transverse_racking_test', 'Transverse Racking Test', 'Pengujian transverse racking.', NULL, NULL, 1, 1, 1, 0, 40, 'active'),
  ('longitudinal_restraint_test', 'Longitudinal Restraint Test', 'Pengujian longitudinal restraint.', NULL, NULL, 1, 1, 0, 0, 50, 'active'),
  ('side_wall_strength', 'Side Wall Strength', 'Pemeriksaan kekuatan side wall.', NULL, NULL, 1, 1, 0, 0, 60, 'active'),
  ('end_wall_strength', 'End Wall Strength', 'Pemeriksaan kekuatan end wall.', NULL, NULL, 1, 1, 0, 0, 70, 'active'),
  ('one_door_off_operation', 'One Door Off Operation', 'Pemeriksaan operasi one door off.', NULL, NULL, 1, 0, 0, 0, 80, 'active'),
  ('watertightness_test', 'Watertightness Test', 'Pengujian kedap air.', NULL, NULL, 1, 1, 0, 1, 90, 'active'),
  ('ndt_if_required', 'NDT If Required', 'NDT jika diperlukan.', NULL, NULL, 1, 1, 0, 1, 100, 'active');

INSERT IGNORE INTO evidence_photo_categories (code, name, description, is_required_default, applies_to, display_order, status)
VALUES
  ('general_container', 'General Container', 'Foto umum peti kemas.', 1, 'inspection', 10, 'active'),
  ('container_number', 'Container Number', 'Foto nomor peti kemas.', 1, 'inspection', 20, 'active'),
  ('csc_plate', 'CSC Plate', 'Foto plate persetujuan keselamatan.', 1, 'inspection', 30, 'active'),
  ('structural_component', 'Structural Component', 'Foto komponen struktur.', 0, 'inspection', 40, 'active'),
  ('damage_finding', 'Damage Finding', 'Foto temuan kerusakan.', 0, 'finding', 50, 'active'),
  ('test_result', 'Test Result', 'Foto atau lampiran hasil pengujian.', 0, 'test', 60, 'active'),
  ('repair_evidence', 'Repair Evidence', 'Evidence perbaikan.', 0, 'repair', 70, 'active'),
  ('reinspection_evidence', 'Reinspection Evidence', 'Evidence re-inspection.', 0, 'reinspection', 80, 'active');

INSERT IGNORE INTO inspection_recommendations (code, name, description, final_fitness_result_mapping, workflow_status_mapping, restriction_status_mapping, requires_supervisor_review, status)
VALUES
  ('fit', 'Layak', 'Direkomendasikan layak.', 'fit', 'under_review', 'none', 1, 'active'),
  ('need_repair', 'Perlu Perbaikan', 'Perlu perbaikan sebelum keputusan akhir.', 'pending', 'need_repair', 'suspended', 1, 'active'),
  ('unfit', 'Tidak Layak', 'Direkomendasikan tidak layak.', 'unfit', 'under_review', 'prohibited', 1, 'active'),
  ('need_reinspection', 'Perlu Re-Inspection', 'Perlu pemeriksaan ulang.', 'pending', 'ready_for_reinspection', 'suspended', 1, 'active'),
  ('suspend_use', 'Dilarang Digunakan Sementara', 'Penggunaan ditangguhkan sementara.', 'pending', 'need_repair', 'suspended', 1, 'active');

INSERT IGNORE INTO numbering_settings (document_type, prefix, doc_code, year_format, running_digits, reset_period, format_preview, is_active)
VALUES
  ('fitness_application', 'GIFT', 'FAP', 'YYYY', 6, 'yearly', 'GIFT-FAP-2026-000001', 1),
  ('fitness_container_import', 'GIFT', 'FCI', 'YYYY', 6, 'yearly', 'GIFT-FCI-2026-000001', 1),
  ('fitness_assignment', 'GIFT', 'FAS', 'YYYY', 6, 'yearly', 'GIFT-FAS-2026-000001', 1),
  ('fitness_inspection', 'GIFT', 'FIN', 'YYYY', 6, 'yearly', 'GIFT-FIN-2026-000001', 1),
  ('repair_followup', 'GIFT', 'RFL', 'YYYY', 6, 'yearly', 'GIFT-RFL-2026-000001', 1),
  ('fitness_review', 'GIFT', 'FRV', 'YYYY', 6, 'yearly', 'GIFT-FRV-2026-000001', 1),
  ('fitness_approval', 'GIFT', 'FAPV', 'YYYY', 6, 'yearly', 'GIFT-FAPV-2026-000001', 1),
  ('approval_document', 'GIFT', 'ADOC', 'YYYY', 6, 'yearly', 'GIFT-ADOC-2026-000001', 1),
  ('release_letter', 'GIFT', 'REL', 'YYYY', 6, 'yearly', 'GIFT-REL-2026-000001', 1);

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES
  ('container_manufacturers.view.all', 'View Container Manufacturers', 'container_manufacturers', 'view', 'all', 'Melihat master pabrik pembuat peti kemas'),
  ('container_manufacturers.manage.all', 'Manage Container Manufacturers', 'container_manufacturers', 'manage', 'all', 'Mengelola master pabrik pembuat peti kemas'),
  ('fitness_approval_categories.view.all', 'View Fitness Approval Categories', 'fitness_approval_categories', 'view', 'all', 'Melihat kategori persetujuan kelaikan'),
  ('fitness_approval_categories.manage.all', 'Manage Fitness Approval Categories', 'fitness_approval_categories', 'manage', 'all', 'Mengelola kategori persetujuan kelaikan'),
  ('maintenance_schemes.view.all', 'View Maintenance Schemes', 'maintenance_schemes', 'view', 'all', 'Melihat skema pemeliharaan peti kemas'),
  ('maintenance_schemes.manage.all', 'Manage Maintenance Schemes', 'maintenance_schemes', 'manage', 'all', 'Mengelola skema pemeliharaan peti kemas'),
  ('inspection_areas.view.all', 'View Inspection Areas', 'inspection_areas', 'view', 'all', 'Melihat area pemeriksaan peti kemas'),
  ('inspection_areas.manage.all', 'Manage Inspection Areas', 'inspection_areas', 'manage', 'all', 'Mengelola area pemeriksaan peti kemas'),
  ('structural_components.view.all', 'View Structural Components', 'structural_components', 'view', 'all', 'Melihat komponen struktur peti kemas'),
  ('structural_components.manage.all', 'Manage Structural Components', 'structural_components', 'manage', 'all', 'Mengelola komponen struktur peti kemas'),
  ('structural_damage_criteria.view.all', 'View Structural Damage Criteria', 'structural_damage_criteria', 'view', 'all', 'Melihat kriteria kerusakan struktur'),
  ('structural_damage_criteria.manage.all', 'Manage Structural Damage Criteria', 'structural_damage_criteria', 'manage', 'all', 'Mengelola kriteria kerusakan struktur'),
  ('finding_severities.view.all', 'View Finding Severities', 'finding_severities', 'view', 'all', 'Melihat tingkat temuan'),
  ('finding_severities.manage.all', 'Manage Finding Severities', 'finding_severities', 'manage', 'all', 'Mengelola tingkat temuan'),
  ('inspection_test_parameters.view.all', 'View Inspection Test Parameters', 'inspection_test_parameters', 'view', 'all', 'Melihat parameter pengujian kelaikan'),
  ('inspection_test_parameters.manage.all', 'Manage Inspection Test Parameters', 'inspection_test_parameters', 'manage', 'all', 'Mengelola parameter pengujian kelaikan'),
  ('fitness_checklist_templates.view.all', 'View Fitness Checklist Templates', 'fitness_checklist_templates', 'view', 'all', 'Melihat template checklist kelaikan'),
  ('fitness_checklist_templates.manage.all', 'Manage Fitness Checklist Templates', 'fitness_checklist_templates', 'manage', 'all', 'Mengelola template checklist kelaikan'),
  ('evidence_photo_categories.view.all', 'View Evidence Photo Categories', 'evidence_photo_categories', 'view', 'all', 'Melihat kategori foto evidence'),
  ('evidence_photo_categories.manage.all', 'Manage Evidence Photo Categories', 'evidence_photo_categories', 'manage', 'all', 'Mengelola kategori foto evidence'),
  ('inspection_recommendations.view.all', 'View Inspection Recommendations', 'inspection_recommendations', 'view', 'all', 'Melihat rekomendasi hasil pemeriksaan'),
  ('inspection_recommendations.manage.all', 'Manage Inspection Recommendations', 'inspection_recommendations', 'manage', 'all', 'Mengelola rekomendasi hasil pemeriksaan'),
  ('authorized_signers.view.all', 'View Authorized Signers', 'authorized_signers', 'view', 'all', 'Melihat pejabat penandatangan'),
  ('authorized_signers.manage.all', 'Manage Authorized Signers', 'authorized_signers', 'manage', 'all', 'Mengelola pejabat penandatangan'),
  ('fitness_applications.view.all', 'View Fitness Applications', 'fitness_applications', 'view', 'all', 'Melihat permohonan kelaikan'),
  ('fitness_applications.manage.all', 'Manage Fitness Applications', 'fitness_applications', 'manage', 'all', 'Mengelola permohonan kelaikan'),
  ('application_containers.view.all', 'View Application Containers', 'application_containers', 'view', 'all', 'Melihat data peti kemas kelaikan'),
  ('application_containers.manage.all', 'Manage Application Containers', 'application_containers', 'manage', 'all', 'Mengelola data peti kemas kelaikan'),
  ('fitness_container_imports.view.all', 'View Fitness Container Imports', 'fitness_container_imports', 'view', 'all', 'Melihat import data peti kemas kelaikan'),
  ('fitness_container_imports.manage.all', 'Manage Fitness Container Imports', 'fitness_container_imports', 'manage', 'all', 'Mengelola import data peti kemas kelaikan'),
  ('fitness_assignments.view.all', 'View Fitness Assignments', 'fitness_assignments', 'view', 'all', 'Melihat assignment kelaikan'),
  ('fitness_assignments.manage.all', 'Manage Fitness Assignments', 'fitness_assignments', 'manage', 'all', 'Mengelola assignment kelaikan'),
  ('fitness_inspections.view.all', 'View Fitness Inspections', 'fitness_inspections', 'view', 'all', 'Melihat pemeriksaan kelaikan'),
  ('fitness_inspections.manage.assigned', 'Manage Assigned Fitness Inspections', 'fitness_inspections', 'manage', 'assigned', 'Mengelola pemeriksaan kelaikan yang ditugaskan'),
  ('structural_findings.view.all', 'View Structural Findings', 'structural_findings', 'view', 'all', 'Melihat temuan struktur'),
  ('structural_findings.manage.assigned', 'Manage Assigned Structural Findings', 'structural_findings', 'manage', 'assigned', 'Mengelola temuan struktur yang ditugaskan'),
  ('repair_followups.view.all', 'View Repair Followups', 'repair_followups', 'view', 'all', 'Melihat tindak lanjut perbaikan'),
  ('repair_followups.manage.all', 'Manage Repair Followups', 'repair_followups', 'manage', 'all', 'Mengelola tindak lanjut perbaikan'),
  ('fitness_reviews.view.all', 'View Fitness Reviews', 'fitness_reviews', 'view', 'all', 'Melihat review kelaikan'),
  ('fitness_reviews.manage.all', 'Manage Fitness Reviews', 'fitness_reviews', 'manage', 'all', 'Mengelola review kelaikan'),
  ('fitness_approvals.view.all', 'View Fitness Approvals', 'fitness_approvals', 'view', 'all', 'Melihat persetujuan kelaikan'),
  ('fitness_approvals.issue.all', 'Issue Fitness Approvals', 'fitness_approvals', 'issue', 'all', 'Menerbitkan persetujuan kelaikan'),
  ('fitness_documents.view.all', 'View Fitness Documents', 'fitness_documents', 'view', 'all', 'Melihat dokumen kelaikan'),
  ('fitness_documents.manage.all', 'Manage Fitness Documents', 'fitness_documents', 'manage', 'all', 'Mengelola dokumen kelaikan');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'container_manufacturers.view.all', 'container_manufacturers.manage.all',
  'fitness_approval_categories.view.all', 'fitness_approval_categories.manage.all',
  'maintenance_schemes.view.all', 'maintenance_schemes.manage.all',
  'inspection_areas.view.all', 'inspection_areas.manage.all',
  'structural_components.view.all', 'structural_components.manage.all',
  'structural_damage_criteria.view.all', 'structural_damage_criteria.manage.all',
  'finding_severities.view.all', 'finding_severities.manage.all',
  'inspection_test_parameters.view.all', 'inspection_test_parameters.manage.all',
  'fitness_checklist_templates.view.all', 'fitness_checklist_templates.manage.all',
  'evidence_photo_categories.view.all', 'evidence_photo_categories.manage.all',
  'inspection_recommendations.view.all', 'inspection_recommendations.manage.all',
  'authorized_signers.view.all', 'authorized_signers.manage.all',
  'fitness_applications.view.all', 'fitness_applications.manage.all',
  'application_containers.view.all', 'application_containers.manage.all',
  'fitness_container_imports.view.all', 'fitness_container_imports.manage.all',
  'fitness_assignments.view.all', 'fitness_assignments.manage.all',
  'fitness_inspections.view.all', 'fitness_inspections.manage.assigned',
  'structural_findings.view.all', 'structural_findings.manage.assigned',
  'repair_followups.view.all', 'repair_followups.manage.all',
  'fitness_reviews.view.all', 'fitness_reviews.manage.all',
  'fitness_approvals.view.all', 'fitness_approvals.issue.all',
  'fitness_documents.view.all', 'fitness_documents.manage.all'
)
WHERE r.code='super_admin';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'container_manufacturers.view.all', 'container_manufacturers.manage.all',
  'fitness_approval_categories.view.all', 'fitness_approval_categories.manage.all',
  'maintenance_schemes.view.all', 'maintenance_schemes.manage.all',
  'inspection_areas.view.all', 'inspection_areas.manage.all',
  'structural_components.view.all', 'structural_components.manage.all',
  'structural_damage_criteria.view.all', 'structural_damage_criteria.manage.all',
  'finding_severities.view.all', 'finding_severities.manage.all',
  'inspection_test_parameters.view.all', 'inspection_test_parameters.manage.all',
  'fitness_checklist_templates.view.all', 'fitness_checklist_templates.manage.all',
  'evidence_photo_categories.view.all', 'evidence_photo_categories.manage.all',
  'inspection_recommendations.view.all', 'inspection_recommendations.manage.all',
  'authorized_signers.view.all', 'authorized_signers.manage.all',
  'fitness_applications.view.all', 'fitness_applications.manage.all',
  'application_containers.view.all', 'application_containers.manage.all',
  'fitness_container_imports.view.all', 'fitness_container_imports.manage.all',
  'fitness_assignments.view.all', 'fitness_assignments.manage.all',
  'repair_followups.view.all', 'repair_followups.manage.all',
  'fitness_documents.view.all', 'fitness_documents.manage.all'
)
WHERE r.code='admin';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'fitness_inspections.manage.assigned',
  'structural_findings.manage.assigned'
)
WHERE r.code='surveyor';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'fitness_inspections.view.all',
  'fitness_reviews.view.all',
  'fitness_reviews.manage.all',
  'fitness_approvals.view.all',
  'fitness_documents.view.all'
)
WHERE r.code='supervisor';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'container_manufacturers.view.all',
  'fitness_approval_categories.view.all',
  'maintenance_schemes.view.all',
  'inspection_areas.view.all',
  'structural_components.view.all',
  'structural_damage_criteria.view.all',
  'finding_severities.view.all',
  'inspection_test_parameters.view.all',
  'fitness_checklist_templates.view.all',
  'evidence_photo_categories.view.all',
  'inspection_recommendations.view.all',
  'authorized_signers.view.all',
  'fitness_applications.view.all',
  'application_containers.view.all',
  'fitness_container_imports.view.all',
  'fitness_assignments.view.all',
  'fitness_inspections.view.all',
  'structural_findings.view.all',
  'repair_followups.view.all',
  'fitness_reviews.view.all',
  'fitness_approvals.view.all',
  'fitness_documents.view.all'
)
WHERE r.code='management';
