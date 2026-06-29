CREATE TABLE IF NOT EXISTS surveys (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  survey_no VARCHAR(80) UNIQUE NOT NULL,
  job_order_id CHAR(36) NOT NULL REFERENCES job_orders(id),
  job_container_id CHAR(36) NOT NULL REFERENCES job_containers(id),
  assignment_id CHAR(36) NULL REFERENCES assignments(id),
  surveyor_id CHAR(36) NOT NULL REFERENCES surveyor_profiles(id),
  survey_type_id CHAR(36) NOT NULL REFERENCES survey_types(id),
  status VARCHAR(50) NOT NULL DEFAULT 'draft',
  survey_result VARCHAR(50) NULL,
  system_recommendation_result VARCHAR(50) NULL,
  started_at DATETIME(6) NULL,
  submitted_at DATETIME(6) NULL,
  approved_at DATETIME(6) NULL,
  rejected_at DATETIME(6) NULL,
  current_revision_no INT NOT NULL DEFAULT 0,
  final_remark TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL
);

CREATE INDEX idx_surveys_container_type_active ON surveys(job_container_id, survey_type_id);
CREATE UNIQUE INDEX idx_surveys_no ON surveys(survey_no);
CREATE INDEX idx_surveys_job ON surveys(job_order_id);
CREATE INDEX idx_surveys_container ON surveys(job_container_id);
CREATE INDEX idx_surveys_surveyor ON surveys(surveyor_id);
CREATE INDEX idx_surveys_status ON surveys(status);
CREATE INDEX idx_surveys_submitted_at ON surveys(submitted_at);

CREATE TABLE IF NOT EXISTS survey_general_infos (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  survey_id CHAR(36) UNIQUE NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
  container_no VARCHAR(20) NOT NULL,
  container_type_id CHAR(36) NULL REFERENCES container_types(id),
  iso_type_code VARCHAR(20) NULL,
  customer_id CHAR(36) NOT NULL REFERENCES customers(id),
  location_id CHAR(36) NOT NULL REFERENCES locations(id),
  survey_date_time DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  cargo_status VARCHAR(30) NOT NULL DEFAULT 'unknown',
  seal_no VARCHAR(100) NULL,
  truck_no VARCHAR(80) NULL,
  driver_name VARCHAR(150) NULL,
  chassis_no VARCHAR(100) NULL,
  csc_plate_status VARCHAR(30) NULL,
  door_status VARCHAR(30) NULL,
  general_condition VARCHAR(50) NULL,
  weather VARCHAR(100) NULL,
  gps_latitude DECIMAL(10,7) NULL,
  gps_longitude DECIMAL(10,7) NULL,
  general_remark TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE TABLE IF NOT EXISTS survey_checklist_responses (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  survey_id CHAR(36) NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
  template_item_id CHAR(36) NULL,
  item_code VARCHAR(80) NOT NULL,
  item_label VARCHAR(200) NOT NULL,
  response_value VARCHAR(50) NULL,
  response_text TEXT NULL,
  is_required TINYINT(1) NOT NULL DEFAULT true,
  is_critical TINYINT(1) NOT NULL DEFAULT false,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE(survey_id, item_code)
);

CREATE INDEX idx_survey_checklist_survey ON survey_checklist_responses(survey_id);

CREATE TABLE IF NOT EXISTS survey_damages (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  survey_id CHAR(36) NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
  damage_no VARCHAR(30) NOT NULL,
  face VARCHAR(50) NOT NULL,
  internal_location VARCHAR(30) NOT NULL,
  cedex_location_id CHAR(36) NULL REFERENCES cedex_locations(id),
  component_id CHAR(36) NOT NULL REFERENCES cedex_components(id),
  damage_id CHAR(36) NOT NULL REFERENCES cedex_damages(id),
  repair_id CHAR(36) NULL REFERENCES cedex_repairs(id),
  material_id CHAR(36) NULL REFERENCES cedex_materials(id),
  responsibility_id CHAR(36) NULL REFERENCES responsibility_codes(id),
  severity VARCHAR(30) NOT NULL DEFAULT 'minor',
  quantity INT NULL,
  length_value DECIMAL(10,2) NULL,
  width_value DECIMAL(10,2) NULL,
  depth_value DECIMAL(10,2) NULL,
  unit VARCHAR(10) NOT NULL DEFAULT 'cm',
  is_repair_required TINYINT(1) NOT NULL DEFAULT false,
  is_cargo_worthy_impact TINYINT(1) NOT NULL DEFAULT false,
  is_photo_only TINYINT(1) NOT NULL DEFAULT false,
  remark TEXT NULL,
  created_by CHAR(36) NULL REFERENCES users(id),
  updated_by CHAR(36) NULL REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL
);

CREATE UNIQUE INDEX idx_survey_damages_no_active
  ON survey_damages(survey_id, damage_no);
CREATE INDEX idx_survey_damages_survey ON survey_damages(survey_id);
CREATE INDEX idx_survey_damages_location ON survey_damages(face, internal_location);
CREATE INDEX idx_survey_damages_severity ON survey_damages(severity);
CREATE INDEX idx_survey_damages_component ON survey_damages(component_id);
CREATE INDEX idx_survey_damages_damage ON survey_damages(damage_id);

CREATE TABLE IF NOT EXISTS survey_damage_counters (
  survey_id CHAR(36) PRIMARY KEY REFERENCES surveys(id) ON DELETE CASCADE,
  last_number INT NOT NULL DEFAULT 0,
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE TABLE IF NOT EXISTS survey_photos (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  survey_id CHAR(36) NOT NULL REFERENCES surveys(id) ON DELETE CASCADE,
  damage_id CHAR(36) NULL REFERENCES survey_damages(id),
  file_id CHAR(36) NOT NULL REFERENCES file_objects(id),
  photo_type VARCHAR(30) NOT NULL DEFAULT 'general',
  photo_category VARCHAR(80) NULL,
  caption TEXT NULL,
  taken_at DATETIME(6) NULL,
  gps_latitude DECIMAL(10,7) NULL,
  gps_longitude DECIMAL(10,7) NULL,
  watermark_text TEXT NULL,
  display_order INT NOT NULL DEFAULT 0,
  uploaded_by CHAR(36) NOT NULL REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL
);

CREATE INDEX idx_survey_photos_survey ON survey_photos(survey_id);
CREATE INDEX idx_survey_photos_damage ON survey_photos(damage_id);
CREATE INDEX idx_survey_photos_type ON survey_photos(photo_type);

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES
  ('surveyor_jobs.view.assigned', 'View Assigned Surveyor Jobs', 'surveyor_jobs', 'view', 'assigned', 'Melihat job yang ditugaskan ke surveyor login'),
  ('surveys.view.assigned', 'View Assigned Surveys', 'surveys', 'view', 'assigned', 'Melihat survey milik assignment sendiri'),
  ('surveys.start.assigned', 'Start Assigned Survey', 'surveys', 'start', 'assigned', 'Memulai survey untuk container yang ditugaskan'),
  ('surveys.update.assigned', 'Update Assigned Survey', 'surveys', 'update', 'assigned', 'Mengubah draft/revisi survey sendiri'),
  ('surveys.submit.assigned', 'Submit Assigned Survey', 'surveys', 'submit', 'assigned', 'Submit survey sendiri untuk review'),
  ('survey_damages.view.assigned', 'View Assigned Survey Damages', 'survey_damages', 'view', 'assigned', 'Melihat damage pada survey sendiri'),
  ('survey_damages.create.assigned', 'Create Assigned Survey Damage', 'survey_damages', 'create', 'assigned', 'Membuat damage pada survey sendiri'),
  ('survey_damages.update.assigned', 'Update Assigned Survey Damage', 'survey_damages', 'update', 'assigned', 'Mengubah damage pada survey sendiri'),
  ('survey_damages.delete.assigned', 'Delete Assigned Survey Damage', 'survey_damages', 'delete', 'assigned', 'Menghapus damage pada survey sendiri'),
  ('survey_photos.upload.assigned', 'Upload Assigned Survey Photo', 'survey_photos', 'upload', 'assigned', 'Upload foto evidence pada survey sendiri'),
  ('survey_photos.view.assigned', 'View Assigned Survey Photos', 'survey_photos', 'view', 'assigned', 'Melihat foto evidence pada survey sendiri');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'surveyor_jobs.view.assigned',
  'surveys.view.assigned',
  'surveys.start.assigned',
  'surveys.update.assigned',
  'surveys.submit.assigned',
  'survey_damages.view.assigned',
  'survey_damages.create.assigned',
  'survey_damages.update.assigned',
  'survey_damages.delete.assigned',
  'survey_photos.upload.assigned',
  'survey_photos.view.assigned'
)
WHERE r.code = 'surveyor';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'cedex_locations.view.all',
  'cedex_components.view.all',
  'cedex_damages.view.all',
  'cedex_repairs.view.all',
  'cedex_materials.view.all',
  'responsibility_codes.view.all'
)
WHERE r.code = 'surveyor';
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.module IN ('surveyor_jobs', 'surveys', 'survey_damages', 'survey_photos')
WHERE r.code IN ('super_admin', 'admin', 'supervisor');









