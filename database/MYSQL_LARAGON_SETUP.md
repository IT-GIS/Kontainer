# Query Database MySQL Laragon

Import `database/kontainer_db.sql` melalui phpMyAdmin. Akun development: `superadmin@gift.local` / `password`.

## Patch permission sidebar tiga workspace

Setelah mengimpor database utama, jalankan `database/patches/0009_navigation_permissions.sql`
melalui phpMyAdmin untuk database yang sudah terlanjur dibuat sebelum struktur sidebar
Admin, Surveyor, dan Finance diterapkan. Patch ini memakai `INSERT IGNORE` dan normalisasi
role permission yang idempotent, sehingga aman dijalankan ulang.

Urutan import:

1. `database/kontainer_db.sql`
2. `database/patches/0009_navigation_permissions.sql`

## Query lengkap

```sql
-- Container Survey Management System - MySQL 8 / Laragon
CREATE DATABASE IF NOT EXISTS kontainer_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kontainer_db;
SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

-- 0001_foundation.up.sql
-- File metadata is created early because users, company profiles, and surveyor
-- profiles can reference uploaded files. Binary objects live in MinIO/S3.
CREATE TABLE file_objects (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  bucket_name VARCHAR(100) NOT NULL,
  object_key VARCHAR(768) NOT NULL,
  original_file_name VARCHAR(255),
  mime_type VARCHAR(100),
  file_size BIGINT,
  checksum_sha256 VARCHAR(128),
  visibility VARCHAR(30) NOT NULL DEFAULT 'private',
  public_token VARCHAR(120) UNIQUE,
  uploaded_by CHAR(36),
  uploaded_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6),
  CONSTRAINT chk_file_objects_visibility CHECK (visibility IN ('private', 'internal', 'public_token')),
  CONSTRAINT chk_file_objects_file_size CHECK (file_size IS NULL OR file_size >= 0)
);

CREATE INDEX idx_file_objects_object_key ON file_objects(object_key);
CREATE INDEX idx_file_objects_uploaded_by ON file_objects(uploaded_by);

CREATE TABLE users (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  name VARCHAR(150) NOT NULL,
  email VARCHAR(150) NOT NULL,
  username VARCHAR(80),
  password_hash TEXT NOT NULL,
  phone VARCHAR(30),
  avatar_file_id CHAR(36) REFERENCES file_objects(id),
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  last_login_at DATETIME(6),
  password_changed_at DATETIME(6),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6),
  CONSTRAINT chk_users_status CHECK (status IN ('active', 'inactive', 'suspended'))
);

CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);

ALTER TABLE file_objects
  ADD CONSTRAINT fk_file_objects_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(id);

CREATE TABLE roles (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  is_system_role TINYINT(1) NOT NULL DEFAULT false,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE TABLE permissions (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(120) UNIQUE NOT NULL,
  name VARCHAR(150),
  module VARCHAR(80) NOT NULL,
  action VARCHAR(50) NOT NULL,
  scope VARCHAR(50) NOT NULL DEFAULT 'all',
  description TEXT
);

CREATE INDEX idx_permissions_module_action ON permissions(module, action);

CREATE TABLE user_roles (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL REFERENCES users(id),
  role_id CHAR(36) NOT NULL REFERENCES roles(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE(user_id, role_id)
);

CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);

CREATE TABLE role_permissions (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  role_id CHAR(36) NOT NULL REFERENCES roles(id),
  permission_id CHAR(36) NOT NULL REFERENCES permissions(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE(role_id, permission_id)
);

CREATE INDEX idx_role_permissions_role ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission ON role_permissions(permission_id);

CREATE TABLE refresh_tokens (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL REFERENCES users(id),
  token_hash TEXT NOT NULL,
  device_name VARCHAR(150),
  ip_address VARCHAR(45),
  user_agent TEXT,
  expires_at DATETIME(6) NOT NULL,
  revoked_at DATETIME(6),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);
CREATE INDEX idx_refresh_tokens_revoked ON refresh_tokens(revoked_at);

CREATE TABLE company_profiles (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  company_name VARCHAR(200) NOT NULL,
  brand_name VARCHAR(100),
  address TEXT,
  phone VARCHAR(50),
  email VARCHAR(150),
  website VARCHAR(150),
  tax_no VARCHAR(80),
  logo_file_id CHAR(36) REFERENCES file_objects(id),
  default_signature_file_id CHAR(36) REFERENCES file_objects(id),
  is_active TINYINT(1) NOT NULL DEFAULT true,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX idx_company_profiles_single_active ON company_profiles(is_active);

CREATE TABLE numbering_settings (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  document_type VARCHAR(50) NOT NULL,
  prefix VARCHAR(20) NOT NULL DEFAULT 'GIFT',
  doc_code VARCHAR(20) NOT NULL,
  year_format VARCHAR(10) NOT NULL DEFAULT 'YYYY',
  running_digits INT NOT NULL DEFAULT 6,
  reset_period VARCHAR(20) NOT NULL DEFAULT 'yearly',
  format_preview VARCHAR(100),
  is_active TINYINT(1) NOT NULL DEFAULT true,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_numbering_settings_running_digits CHECK (running_digits > 0),
  CONSTRAINT chk_numbering_settings_reset_period CHECK (reset_period IN ('yearly', 'monthly', 'never'))
);

CREATE UNIQUE INDEX idx_numbering_settings_active ON numbering_settings(document_type);

CREATE TABLE numbering_sequences (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  document_type VARCHAR(50) NOT NULL,
  period_key VARCHAR(20) NOT NULL,
  last_number BIGINT NOT NULL DEFAULT 0,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE(document_type, period_key),
  CONSTRAINT chk_numbering_sequences_last_number CHECK (last_number >= 0)
);

CREATE TABLE customers (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  customer_code VARCHAR(50) NOT NULL,
  customer_name VARCHAR(200) NOT NULL,
  address TEXT,
  npwp VARCHAR(80),
  pic_name VARCHAR(150),
  pic_phone VARCHAR(50),
  pic_email VARCHAR(150),
  billing_address TEXT,
  payment_term_days INT,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_by CHAR(36) REFERENCES users(id),
  updated_by CHAR(36) REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6),
  CONSTRAINT chk_customers_status CHECK (status IN ('active', 'inactive')),
  CONSTRAINT chk_customers_payment_term CHECK (payment_term_days IS NULL OR payment_term_days >= 0)
);

CREATE UNIQUE INDEX idx_customers_code ON customers(customer_code);
CREATE INDEX idx_customers_name ON customers(customer_name);
CREATE INDEX idx_customers_status ON customers(status);

CREATE TABLE locations (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  location_code VARCHAR(50) NOT NULL,
  location_name VARCHAR(200) NOT NULL,
  location_type VARCHAR(50) NOT NULL,
  address TEXT,
  city VARCHAR(100),
  gps_latitude DECIMAL(10,7),
  gps_longitude DECIMAL(10,7),
  pic_name VARCHAR(150),
  pic_phone VARCHAR(50),
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6),
  CONSTRAINT chk_locations_type CHECK (location_type IN ('depot', 'yard', 'port', 'warehouse', 'factory', 'customer_site', 'other')),
  CONSTRAINT chk_locations_status CHECK (status IN ('active', 'inactive')),
  CONSTRAINT chk_locations_latitude CHECK (gps_latitude IS NULL OR (gps_latitude >= -90 AND gps_latitude <= 90)),
  CONSTRAINT chk_locations_longitude CHECK (gps_longitude IS NULL OR (gps_longitude >= -180 AND gps_longitude <= 180))
);

CREATE UNIQUE INDEX idx_locations_code ON locations(location_code);
CREATE INDEX idx_locations_name ON locations(location_name);
CREATE INDEX idx_locations_type ON locations(location_type);
CREATE INDEX idx_locations_status ON locations(status);

CREATE TABLE surveyor_profiles (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) UNIQUE NOT NULL REFERENCES users(id),
  surveyor_code VARCHAR(50) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(50),
  area VARCHAR(150),
  signature_file_id CHAR(36) REFERENCES file_objects(id),
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6),
  CONSTRAINT chk_surveyor_profiles_status CHECK (status IN ('active', 'inactive'))
);

CREATE UNIQUE INDEX idx_surveyor_profiles_code ON surveyor_profiles(surveyor_code);
CREATE INDEX idx_surveyor_profiles_status ON surveyor_profiles(status);

CREATE TABLE container_types (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(30) UNIQUE NOT NULL,
  iso_code VARCHAR(20),
  size VARCHAR(50) NOT NULL,
  type_name VARCHAR(100) NOT NULL,
  description TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_container_types_status CHECK (status IN ('active', 'inactive'))
);

CREATE INDEX idx_container_types_status ON container_types(status);

CREATE TABLE survey_types (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(30) UNIQUE NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  requires_eir TINYINT(1) NOT NULL DEFAULT false,
  requires_light_test TINYINT(1) NOT NULL DEFAULT false,
  requires_cargo_worthy_result TINYINT(1) NOT NULL DEFAULT false,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_survey_types_status CHECK (status IN ('active', 'inactive'))
);

CREATE INDEX idx_survey_types_status ON survey_types(status);

CREATE TABLE cedex_locations (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(30) NOT NULL,
  face VARCHAR(50) NOT NULL,
  grid_code VARCHAR(30) NOT NULL,
  cedex_mapping_code VARCHAR(50),
  container_size VARCHAR(20),
  description TEXT,
  display_order INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_cedex_locations_face CHECK (face IN ('left', 'right', 'front', 'door', 'roof', 'floor', 'understructure')),
  CONSTRAINT chk_cedex_locations_container_size CHECK (container_size IS NULL OR container_size IN ('all', '20', '40', '45')),
  CONSTRAINT chk_cedex_locations_status CHECK (status IN ('active', 'inactive')),
  CONSTRAINT chk_cedex_locations_display_order CHECK (display_order >= 0)
);

CREATE UNIQUE INDEX idx_cedex_locations_unique_scope ON cedex_locations (code, face, container_size);
CREATE INDEX idx_cedex_locations_face ON cedex_locations(face);
CREATE INDEX idx_cedex_locations_status ON cedex_locations(status);

CREATE TABLE cedex_components (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(30) UNIQUE NOT NULL,
  component_name VARCHAR(150) NOT NULL,
  description TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_cedex_components_status CHECK (status IN ('active', 'inactive'))
);

CREATE INDEX idx_cedex_components_status ON cedex_components(status);

CREATE TABLE cedex_damages (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(30) UNIQUE NOT NULL,
  damage_name VARCHAR(150) NOT NULL,
  description TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_cedex_damages_status CHECK (status IN ('active', 'inactive'))
);

CREATE INDEX idx_cedex_damages_status ON cedex_damages(status);

CREATE TABLE cedex_repairs (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(30) UNIQUE NOT NULL,
  repair_name VARCHAR(150) NOT NULL,
  description TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_cedex_repairs_status CHECK (status IN ('active', 'inactive'))
);

CREATE INDEX idx_cedex_repairs_status ON cedex_repairs(status);

CREATE TABLE cedex_materials (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(30) UNIQUE NOT NULL,
  material_name VARCHAR(150) NOT NULL,
  description TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_cedex_materials_status CHECK (status IN ('active', 'inactive'))
);

CREATE INDEX idx_cedex_materials_status ON cedex_materials(status);

CREATE TABLE responsibility_codes (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  code VARCHAR(30) UNIQUE NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_responsibility_codes_status CHECK (status IN ('active', 'inactive'))
);

CREATE INDEX idx_responsibility_codes_status ON responsibility_codes(status);

INSERT INTO roles (code, name, description, is_system_role) VALUES
  ('super_admin', 'Super Admin', 'Highest system administrator', true),
  ('admin', 'Admin / Operasional', 'Operational admin for master data and jobs', true),
  ('surveyor', 'Surveyor', 'Survey field user', true),
  ('supervisor', 'Supervisor / Approver', 'Survey reviewer and approver', true),
  ('finance', 'Finance', 'Finance and billing user', true),
  ('management', 'Management', 'Read-only dashboard and recap user', true);

INSERT INTO permissions (code, module, action, scope, description) VALUES
  ('*.*.all', '*', '*', 'all', 'Wildcard permission for super admin'),
  ('users.manage.all', 'users', 'manage', 'all', 'Manage users'),
  ('roles.manage.all', 'roles', 'manage', 'all', 'Manage roles and permissions'),
  ('company_profiles.manage.all', 'company_profiles', 'manage', 'all', 'Manage company profile'),
  ('numbering_settings.manage.all', 'numbering_settings', 'manage', 'all', 'Manage numbering settings'),
  ('files.manage.all', 'files', 'manage', 'all', 'Manage file metadata'),
  ('customers.manage.all', 'customers', 'manage', 'all', 'Manage customers'),
  ('locations.manage.all', 'locations', 'manage', 'all', 'Manage locations'),
  ('surveyor_profiles.manage.all', 'surveyor_profiles', 'manage', 'all', 'Manage surveyor profiles'),
  ('surveyor_profiles.view.own', 'surveyor_profiles', 'view', 'own', 'View own surveyor profile'),
  ('container_types.manage.all', 'container_types', 'manage', 'all', 'Manage container types'),
  ('survey_types.manage.all', 'survey_types', 'manage', 'all', 'Manage survey types'),
  ('cedex.manage.all', 'cedex', 'manage', 'all', 'Manage CEDEX master data'),
  ('master_data.view.all', 'master_data', 'view', 'all', 'View master data'),
  ('dashboard.view.all', 'dashboard', 'view', 'all', 'View dashboards');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON
  (r.code = 'super_admin' AND p.code = '*.*.all')
  OR (r.code = 'admin' AND p.code IN (
    'customers.manage.all',
    'locations.manage.all',
    'surveyor_profiles.manage.all',
    'container_types.manage.all',
    'survey_types.manage.all',
    'cedex.manage.all',
    'master_data.view.all',
    'dashboard.view.all'
  ))
  OR (r.code = 'surveyor' AND p.code IN (
    'surveyor_profiles.view.own',
    'master_data.view.all',
    'dashboard.view.all'
  ))
  OR (r.code = 'supervisor' AND p.code IN (
    'master_data.view.all',
    'dashboard.view.all'
  ))
  OR (r.code = 'finance' AND p.code IN (
    'master_data.view.all',
    'dashboard.view.all'
  ))
  OR (r.code = 'management' AND p.code IN (
    'master_data.view.all',
    'dashboard.view.all'
  ));

INSERT INTO company_profiles (company_name, brand_name, is_active)
VALUES ('PT Global Inspeksi Sertifikasi Group', 'GIFT', true);

INSERT INTO numbering_settings (document_type, prefix, doc_code, format_preview) VALUES
  ('job_order', 'GIFT', 'JO', 'GIFT-JO-2026-000001'),
  ('assignment', 'GIFT', 'ASG', 'GIFT-ASG-2026-000001'),
  ('survey', 'GIFT', 'SVY', 'GIFT-SVY-2026-000001'),
  ('report', 'GIFT', 'RPT', 'GIFT-RPT-2026-000001'),
  ('eir', 'GIFT', 'EIR', 'GIFT-EIR-2026-000001'),
  ('invoice', 'GIFT', 'INV', 'GIFT-INV-2026-000001'),
  ('payment_receipt', 'GIFT', 'RCP', 'GIFT-RCP-2026-000001');

INSERT INTO container_types (code, iso_code, size, type_name, description) VALUES
  ('20GP', '22G1', '20 Feet', 'General Purpose', 'Dry container 20 feet'),
  ('40GP', '42G1', '40 Feet', 'General Purpose', 'Dry container 40 feet'),
  ('40HC', '45G1', '40 Feet', 'High Cube', 'High cube dry container 40 feet'),
  ('20RF', '22R1', '20 Feet', 'Reefer', 'Refrigerated container 20 feet'),
  ('40RF', '45R1', '40 Feet', 'Reefer', 'Refrigerated container 40 feet'),
  ('20OT', NULL, '20 Feet', 'Open Top', 'Open top container 20 feet'),
  ('40OT', NULL, '40 Feet', 'Open Top', 'Open top container 40 feet'),
  ('20FR', NULL, '20 Feet', 'Flat Rack', 'Flat rack container 20 feet'),
  ('40FR', NULL, '40 Feet', 'Flat Rack', 'Flat rack container 40 feet'),
  ('TANK', NULL, 'Tank', 'Tank Container', 'Tank container');

INSERT INTO survey_types (code, name, description, requires_eir, requires_light_test, requires_cargo_worthy_result) VALUES
  ('GI', 'Gate In Survey', 'Survey when container enters yard or depot', true, false, false),
  ('GO', 'Gate Out Survey', 'Survey when container leaves yard or depot', true, false, false),
  ('DS', 'Damage Survey', 'Specific survey for container damage', false, false, false),
  ('CW', 'Cargo Worthy Survey', 'Cargo worthy condition assessment', false, true, true),
  ('CL', 'Cleanliness Survey', 'Container cleanliness survey', false, false, false),
  ('ONH', 'On Hire Survey', 'Start of hire survey', false, false, false),
  ('OFH', 'Off Hire Survey', 'End of hire survey', false, false, false),
  ('STUF', 'Stuffing Survey', 'Survey during stuffing activity', false, false, false),
  ('STRP', 'Stripping Survey', 'Survey during stripping activity', false, false, false),
  ('PTI', 'Pre-Trip Inspection', 'Reefer pre-trip inspection', false, true, false);

INSERT INTO cedex_locations (code, face, grid_code, container_size, description, display_order) VALUES
  ('L1', 'left', 'L1', 'all', 'Left side section 1', 1),
  ('L2', 'left', 'L2', 'all', 'Left side section 2', 2),
  ('L3', 'left', 'L3', 'all', 'Left side section 3', 3),
  ('R1', 'right', 'R1', 'all', 'Right side section 1', 1),
  ('R2', 'right', 'R2', 'all', 'Right side section 2', 2),
  ('D1', 'door', 'D1', 'all', 'Door end section 1', 1),
  ('F1', 'front', 'F1', 'all', 'Front end section 1', 1),
  ('T1', 'roof', 'T1', 'all', 'Roof section 1', 1),
  ('FL1', 'floor', 'FL1', 'all', 'Floor section 1', 1),
  ('U1', 'understructure', 'U1', 'all', 'Understructure section 1', 1);

INSERT INTO cedex_components (code, component_name, description) VALUES
  ('SP', 'Side Panel', 'Side panel'),
  ('RP', 'Roof Panel', 'Roof panel'),
  ('FP', 'Front Panel', 'Front panel'),
  ('DP', 'Door Panel', 'Door panel'),
  ('DG', 'Door Gasket', 'Door gasket'),
  ('LB', 'Locking Bar', 'Locking bar'),
  ('CK', 'Cam Keeper', 'Cam keeper'),
  ('FB', 'Floor Board', 'Floor board'),
  ('CM', 'Cross Member', 'Cross member'),
  ('CP', 'Corner Post', 'Corner post'),
  ('CC', 'Corner Casting', 'Corner casting'),
  ('BSR', 'Bottom Side Rail', 'Bottom side rail'),
  ('TSR', 'Top Side Rail', 'Top side rail'),
  ('FKP', 'Forklift Pocket', 'Forklift pocket'),
  ('VN', 'Ventilator', 'Ventilator'),
  ('CSC', 'CSC Plate', 'CSC plate');

INSERT INTO cedex_damages (code, damage_name, description) VALUES
  ('DT', 'Dent', 'Dent'),
  ('HL', 'Hole', 'Hole'),
  ('CR', 'Crack', 'Crack'),
  ('BN', 'Bent', 'Bent'),
  ('BR', 'Broken', 'Broken'),
  ('MS', 'Missing', 'Missing'),
  ('RS', 'Rust', 'Rust'),
  ('CO', 'Corrosion', 'Corrosion'),
  ('TO', 'Torn', 'Torn'),
  ('LS', 'Loose', 'Loose'),
  ('DY', 'Dirty', 'Dirty'),
  ('WT', 'Wet', 'Wet'),
  ('OD', 'Odor', 'Odor'),
  ('OS', 'Oil Stain', 'Oil stain'),
  ('BM', 'Burn Mark', 'Burn mark'),
  ('DL', 'Delamination', 'Delamination'),
  ('LK', 'Leakage', 'Leakage'),
  ('IR', 'Improper Repair', 'Improper repair');

INSERT INTO cedex_repairs (code, repair_name, description) VALUES
  ('NR', 'No Repair', 'No repair'),
  ('ST', 'Straighten', 'Straighten'),
  ('WD', 'Weld', 'Weld'),
  ('PT', 'Patch', 'Patch'),
  ('RP', 'Replace', 'Replace'),
  ('RF', 'Refit', 'Refit'),
  ('CL', 'Clean', 'Clean'),
  ('DR', 'Drying', 'Drying'),
  ('GR', 'Grinding', 'Grinding'),
  ('PN', 'Painting', 'Painting'),
  ('SL', 'Sealant', 'Sealant'),
  ('TG', 'Tighten', 'Tighten'),
  ('RM', 'Remove', 'Remove'),
  ('RI', 'Reinstall', 'Reinstall');

INSERT INTO cedex_materials (code, material_name, description) VALUES
  ('STL', 'Steel', 'Steel'),
  ('AL', 'Aluminium', 'Aluminium'),
  ('PLY', 'Plywood', 'Plywood'),
  ('RUB', 'Rubber', 'Rubber'),
  ('PLS', 'Plastic', 'Plastic');

INSERT INTO responsibility_codes (code, name, description) VALUES
  ('C', 'Customer', 'Customer responsibility'),
  ('O', 'Owner', 'Owner responsibility'),
  ('D', 'Depot', 'Depot responsibility'),
  ('T', 'Trucker', 'Trucker responsibility'),
  ('U', 'Unknown', 'Unknown responsibility');

-- 0002_auth_audit.up.sql
CREATE TABLE audit_logs (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) REFERENCES users(id),
  active_role VARCHAR(50),
  action VARCHAR(120) NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id CHAR(36),
  old_state VARCHAR(50),
  new_state VARCHAR(50),
  old_value JSON,
  new_value JSON,
  reason TEXT,
  request_id VARCHAR(80),
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- 0003_dev_superadmin.up.sql
-- Development-only bootstrap user.
-- Email: superadmin@gift.local
-- Password: password
-- Replace this credential before any staging/production use.
INSERT IGNORE INTO users (id, name, email, username, password_hash, status, password_changed_at)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Super Admin Dev',
  'superadmin@gift.local',
  'superadmin',
  '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',
  'active',
  now()
);

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000001', r.id
FROM roles r
WHERE r.code = 'super_admin';

-- 0004_masterdata_permissions.up.sql
INSERT IGNORE INTO permissions (code, module, action, scope, description) VALUES
('customers.view.all', 'customers', 'view', 'all', 'View customers'),
    ('customers.create.all', 'customers', 'create', 'all', 'Create customers'),
    ('customers.update.all', 'customers', 'update', 'all', 'Update customers'),
    ('customers.delete.all', 'customers', 'delete', 'all', 'Deactivate customers'),
    ('locations.view.all', 'locations', 'view', 'all', 'View locations'),
    ('locations.create.all', 'locations', 'create', 'all', 'Create locations'),
    ('locations.update.all', 'locations', 'update', 'all', 'Update locations'),
    ('locations.delete.all', 'locations', 'delete', 'all', 'Deactivate locations'),
    ('surveyors.view.all', 'surveyors', 'view', 'all', 'View surveyor profiles'),
    ('surveyors.create.all', 'surveyors', 'create', 'all', 'Create surveyor profiles'),
    ('surveyors.update.all', 'surveyors', 'update', 'all', 'Update surveyor profiles'),
    ('surveyors.delete.all', 'surveyors', 'delete', 'all', 'Deactivate surveyor profiles'),
    ('container_types.view.all', 'container_types', 'view', 'all', 'View container types'),
    ('container_types.create.all', 'container_types', 'create', 'all', 'Create container types'),
    ('container_types.update.all', 'container_types', 'update', 'all', 'Update container types'),
    ('container_types.delete.all', 'container_types', 'delete', 'all', 'Deactivate container types'),
    ('survey_types.view.all', 'survey_types', 'view', 'all', 'View survey types'),
    ('survey_types.create.all', 'survey_types', 'create', 'all', 'Create survey types'),
    ('survey_types.update.all', 'survey_types', 'update', 'all', 'Update survey types'),
    ('survey_types.delete.all', 'survey_types', 'delete', 'all', 'Deactivate survey types'),
    ('cedex_locations.view.all', 'cedex_locations', 'view', 'all', 'View CEDEX locations'),
    ('cedex_locations.create.all', 'cedex_locations', 'create', 'all', 'Create CEDEX locations'),
    ('cedex_locations.update.all', 'cedex_locations', 'update', 'all', 'Update CEDEX locations'),
    ('cedex_locations.delete.all', 'cedex_locations', 'delete', 'all', 'Deactivate CEDEX locations'),
    ('cedex_components.view.all', 'cedex_components', 'view', 'all', 'View CEDEX components'),
    ('cedex_components.create.all', 'cedex_components', 'create', 'all', 'Create CEDEX components'),
    ('cedex_components.update.all', 'cedex_components', 'update', 'all', 'Update CEDEX components'),
    ('cedex_components.delete.all', 'cedex_components', 'delete', 'all', 'Deactivate CEDEX components'),
    ('cedex_damages.view.all', 'cedex_damages', 'view', 'all', 'View CEDEX damages'),
    ('cedex_damages.create.all', 'cedex_damages', 'create', 'all', 'Create CEDEX damages'),
    ('cedex_damages.update.all', 'cedex_damages', 'update', 'all', 'Update CEDEX damages'),
    ('cedex_damages.delete.all', 'cedex_damages', 'delete', 'all', 'Deactivate CEDEX damages'),
    ('cedex_repairs.view.all', 'cedex_repairs', 'view', 'all', 'View CEDEX repairs'),
    ('cedex_repairs.create.all', 'cedex_repairs', 'create', 'all', 'Create CEDEX repairs'),
    ('cedex_repairs.update.all', 'cedex_repairs', 'update', 'all', 'Update CEDEX repairs'),
    ('cedex_repairs.delete.all', 'cedex_repairs', 'delete', 'all', 'Deactivate CEDEX repairs'),
    ('cedex_materials.view.all', 'cedex_materials', 'view', 'all', 'View CEDEX materials'),
    ('cedex_materials.create.all', 'cedex_materials', 'create', 'all', 'Create CEDEX materials'),
    ('cedex_materials.update.all', 'cedex_materials', 'update', 'all', 'Update CEDEX materials'),
    ('cedex_materials.delete.all', 'cedex_materials', 'delete', 'all', 'Deactivate CEDEX materials'),
    ('responsibility_codes.view.all', 'responsibility_codes', 'view', 'all', 'View responsibility codes'),
    ('responsibility_codes.create.all', 'responsibility_codes', 'create', 'all', 'Create responsibility codes'),
    ('responsibility_codes.update.all', 'responsibility_codes', 'update', 'all', 'Update responsibility codes'),
    ('responsibility_codes.delete.all', 'responsibility_codes', 'delete', 'all', 'Deactivate responsibility codes'),
    ('cedex_locations.manage.all', 'cedex_locations', 'manage', 'all', 'Manage CEDEX locations'),
    ('cedex_components.manage.all', 'cedex_components', 'manage', 'all', 'Manage CEDEX components'),
    ('cedex_damages.manage.all', 'cedex_damages', 'manage', 'all', 'Manage CEDEX damages'),
    ('cedex_repairs.manage.all', 'cedex_repairs', 'manage', 'all', 'Manage CEDEX repairs'),
    ('cedex_materials.manage.all', 'cedex_materials', 'manage', 'all', 'Manage CEDEX materials'),
    ('responsibility_codes.manage.all', 'responsibility_codes', 'manage', 'all', 'Manage responsibility codes'),
    ('surveyors.manage.all', 'surveyors', 'manage', 'all', 'Manage surveyor profiles');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customers.manage.all', 'locations.manage.all', 'surveyors.manage.all', 'container_types.manage.all', 'survey_types.manage.all', 'cedex_locations.manage.all', 'cedex_components.manage.all', 'cedex_damages.manage.all', 'cedex_repairs.manage.all', 'cedex_materials.manage.all', 'responsibility_codes.manage.all')
WHERE r.code = 'admin';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customers.view.all', 'locations.view.all', 'surveyors.view.all', 'container_types.view.all', 'survey_types.view.all', 'cedex_locations.view.all', 'cedex_components.view.all', 'cedex_damages.view.all', 'cedex_repairs.view.all', 'cedex_materials.view.all', 'responsibility_codes.view.all')
WHERE r.code IN ('supervisor', 'management');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customers.view.all', 'container_types.view.all', 'survey_types.view.all')
WHERE r.code = 'finance';

-- 0005_jobs_assignments.up.sql
CREATE TABLE job_orders (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  job_order_no VARCHAR(80) UNIQUE NOT NULL,
  job_date DATE NOT NULL,
  customer_id CHAR(36) NOT NULL REFERENCES customers(id),
  survey_type_id CHAR(36) NOT NULL REFERENCES survey_types(id),
  location_id CHAR(36) NOT NULL REFERENCES locations(id),
  pic_customer_name VARCHAR(150),
  pic_customer_phone VARCHAR(50),
  pic_customer_email VARCHAR(150),
  reference_no VARCHAR(100),
  booking_no VARCHAR(100),
  do_no VARCHAR(100),
  bl_no VARCHAR(100),
  vessel VARCHAR(150),
  voyage VARCHAR(100),
  trucking_company VARCHAR(150),
  priority VARCHAR(30) NOT NULL DEFAULT 'normal',
  deadline DATETIME(6),
  instruction TEXT,
  status VARCHAR(50) NOT NULL DEFAULT 'draft',
  cancel_reason TEXT,
  cancelled_at DATETIME(6),
  cancelled_by CHAR(36) REFERENCES users(id),
  created_by CHAR(36) REFERENCES users(id),
  updated_by CHAR(36) REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6),
  CONSTRAINT chk_job_orders_priority CHECK (priority IN ('normal', 'urgent')),
  CONSTRAINT chk_job_orders_status CHECK (status IN ('draft', 'assigned', 'in_progress', 'all_survey_submitted', 'all_survey_approved', 'report_generated', 'ready_to_invoice', 'invoiced', 'paid', 'closed', 'cancelled'))
);

CREATE UNIQUE INDEX idx_job_orders_no ON job_orders(job_order_no);
CREATE INDEX idx_job_orders_customer ON job_orders(customer_id);
CREATE INDEX idx_job_orders_status ON job_orders(status);
CREATE INDEX idx_job_orders_date ON job_orders(job_date);
CREATE INDEX idx_job_orders_survey_type ON job_orders(survey_type_id);
CREATE INDEX idx_job_orders_deleted ON job_orders(deleted_at);

CREATE TABLE job_containers (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  job_order_id CHAR(36) NOT NULL REFERENCES job_orders(id),
  container_no VARCHAR(20) NOT NULL,
  owner_code VARCHAR(4),
  serial_number VARCHAR(10),
  check_digit VARCHAR(2),
  check_digit_status VARCHAR(30) NOT NULL DEFAULT 'not_checked',
  check_digit_override_reason TEXT,
  container_type_id CHAR(36) REFERENCES container_types(id),
  iso_type_code VARCHAR(20),
  seal_no VARCHAR(100),
  cargo_status VARCHAR(30) NOT NULL DEFAULT 'unknown',
  gross_weight DECIMAL(12,2),
  tare_weight DECIMAL(12,2),
  payload DECIMAL(12,2),
  manufacture_date DATE,
  csc_plate_status VARCHAR(30),
  truck_no VARCHAR(80),
  driver_name VARCHAR(150),
  remark TEXT,
  status VARCHAR(50) NOT NULL DEFAULT 'not_started',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6),
  CONSTRAINT chk_job_containers_check_digit_status CHECK (check_digit_status IN ('valid', 'invalid', 'not_checked', 'override')),
  CONSTRAINT chk_job_containers_cargo_status CHECK (cargo_status IN ('empty', 'laden', 'unknown')),
  CONSTRAINT chk_job_containers_status CHECK (status IN ('not_started', 'assigned', 'in_progress', 'draft', 'submitted', 'need_revision', 'approved', 'reported', 'invoiced', 'closed', 'cancelled'))
);

CREATE UNIQUE INDEX idx_job_containers_job_container_no ON job_containers(job_order_id, container_no);
CREATE INDEX idx_job_containers_job ON job_containers(job_order_id);
CREATE INDEX idx_job_containers_container_no ON job_containers(container_no);
CREATE INDEX idx_job_containers_status ON job_containers(status);

CREATE TABLE container_import_batches (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  job_order_id CHAR(36) NOT NULL REFERENCES job_orders(id),
  file_id CHAR(36) REFERENCES file_objects(id),
  total_rows INT NOT NULL DEFAULT 0,
  success_rows INT NOT NULL DEFAULT 0,
  failed_rows INT NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'processed',
  error_summary JSON,
  imported_by CHAR(36) REFERENCES users(id),
  imported_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_container_import_batches_status CHECK (status IN ('processed', 'failed', 'partial'))
);

CREATE TABLE assignments (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  assignment_no VARCHAR(80) UNIQUE NOT NULL,
  job_order_id CHAR(36) NOT NULL REFERENCES job_orders(id),
  surveyor_id CHAR(36) NOT NULL REFERENCES surveyor_profiles(id),
  assigned_by CHAR(36) NOT NULL REFERENCES users(id),
  assigned_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  start_date DATETIME(6),
  due_date DATETIME(6),
  instruction TEXT,
  status VARCHAR(50) NOT NULL DEFAULT 'assigned',
  cancel_reason TEXT,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT chk_assignments_status CHECK (status IN ('assigned', 'accepted', 'in_progress', 'completed', 'cancelled', 'reassigned'))
);

CREATE INDEX idx_assignments_job ON assignments(job_order_id);
CREATE INDEX idx_assignments_surveyor ON assignments(surveyor_id);
CREATE INDEX idx_assignments_status ON assignments(status);

CREATE TABLE assignment_containers (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  assignment_id CHAR(36) NOT NULL REFERENCES assignments(id),
  job_container_id CHAR(36) NOT NULL REFERENCES job_containers(id),
  assigned_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  unassigned_at DATETIME(6),
  unassigned_reason TEXT,
  UNIQUE(assignment_id, job_container_id)
);

CREATE INDEX idx_assignment_containers_active_container ON assignment_containers(job_container_id);
CREATE INDEX idx_assignment_containers_assignment ON assignment_containers(assignment_id);

CREATE TABLE job_events (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  job_order_id CHAR(36) NOT NULL REFERENCES job_orders(id),
  event_type VARCHAR(100) NOT NULL,
  event_title VARCHAR(200) NOT NULL,
  event_description TEXT,
  actor_id CHAR(36) REFERENCES users(id),
  metadata JSON,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX idx_job_events_job ON job_events(job_order_id);
CREATE INDEX idx_job_events_created_at ON job_events(created_at);

INSERT IGNORE INTO permissions (code, module, action, scope, description) VALUES
('jobs.view.all', 'jobs', 'view', 'all', 'View jobs'),
    ('jobs.create.all', 'jobs', 'create', 'all', 'Create jobs'),
    ('jobs.update.all', 'jobs', 'update', 'all', 'Update jobs'),
    ('jobs.cancel.all', 'jobs', 'cancel', 'all', 'Cancel jobs'),
    ('jobs.manage.all', 'jobs', 'manage', 'all', 'Manage jobs'),
    ('job_containers.view.all', 'job_containers', 'view', 'all', 'View job containers'),
    ('job_containers.create.all', 'job_containers', 'create', 'all', 'Create job containers'),
    ('job_containers.import.all', 'job_containers', 'import', 'all', 'Import job containers'),
    ('job_containers.update.all', 'job_containers', 'update', 'all', 'Update job containers'),
    ('job_containers.delete.all', 'job_containers', 'delete', 'all', 'Delete job containers'),
    ('job_containers.reassign.all', 'job_containers', 'reassign', 'all', 'Reassign job containers'),
    ('assignments.view.all', 'assignments', 'view', 'all', 'View assignments'),
    ('assignments.assign.all', 'assignments', 'assign', 'all', 'Assign surveyors'),
    ('assignments.reassign.all', 'assignments', 'reassign', 'all', 'Reassign surveyors'),
    ('assignments.manage.all', 'assignments', 'manage', 'all', 'Manage assignments');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('jobs.manage.all', 'job_containers.view.all', 'job_containers.create.all', 'job_containers.import.all', 'job_containers.update.all', 'job_containers.delete.all', 'job_containers.reassign.all', 'assignments.manage.all')
WHERE r.code = 'admin';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('jobs.view.all', 'job_containers.view.all', 'assignments.view.all')
WHERE r.code IN ('supervisor', 'management');

-- 0006_surveys_mvp.up.sql
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

-- 0007_reviews_reports.up.sql
CREATE TABLE IF NOT EXISTS survey_approvals (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  survey_id CHAR(36) NOT NULL REFERENCES surveys(id),
  reviewer_id CHAR(36) NOT NULL REFERENCES users(id),
  decision VARCHAR(30) NOT NULL,
  review_note TEXT NULL,
  final_result VARCHAR(50) NULL,
  revision_no INT NOT NULL DEFAULT 0,
  reviewed_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX idx_survey_approvals_survey ON survey_approvals(survey_id);
CREATE INDEX idx_survey_approvals_decision ON survey_approvals(decision);

CREATE TABLE IF NOT EXISTS survey_revision_items (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  approval_id CHAR(36) NOT NULL REFERENCES survey_approvals(id) ON DELETE CASCADE,
  survey_id CHAR(36) NOT NULL REFERENCES surveys(id),
  target_type VARCHAR(50) NOT NULL,
  target_id CHAR(36) NULL,
  note TEXT NOT NULL,
  is_resolved TINYINT(1) NOT NULL DEFAULT false,
  resolved_by CHAR(36) NULL REFERENCES users(id),
  resolved_at DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX idx_survey_revision_items_survey ON survey_revision_items(survey_id);
CREATE INDEX idx_survey_revision_items_resolved ON survey_revision_items(is_resolved);

CREATE TABLE IF NOT EXISTS reports (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  report_no VARCHAR(80) UNIQUE NOT NULL,
  report_type VARCHAR(50) NOT NULL DEFAULT 'container_inspection_report',
  job_order_id CHAR(36) NULL REFERENCES job_orders(id),
  survey_id CHAR(36) NULL REFERENCES surveys(id),
  customer_id CHAR(36) NULL REFERENCES customers(id),
  status VARCHAR(30) NOT NULL DEFAULT 'pending_generation',
  current_version_no INT NOT NULL DEFAULT 0,
  qr_token VARCHAR(120) UNIQUE NULL,
  validated_publicly TINYINT(1) NOT NULL DEFAULT true,
  generated_by CHAR(36) NULL REFERENCES users(id),
  generated_at DATETIME(6) NULL,
  finalized_by CHAR(36) NULL REFERENCES users(id),
  finalized_at DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE UNIQUE INDEX idx_reports_no ON reports(report_no);
CREATE INDEX idx_reports_survey_active ON reports(survey_id);
CREATE INDEX idx_reports_job ON reports(job_order_id);
CREATE INDEX idx_reports_survey ON reports(survey_id);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_qr_token ON reports(qr_token);

CREATE TABLE IF NOT EXISTS report_versions (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  report_id CHAR(36) NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
  version_no INT NOT NULL,
  file_id CHAR(36) NULL REFERENCES file_objects(id),
  change_reason TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'draft',
  created_by CHAR(36) NULL REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE(report_id, version_no)
);

CREATE INDEX idx_report_versions_report ON report_versions(report_id);
CREATE INDEX idx_report_versions_status ON report_versions(status);

CREATE TABLE IF NOT EXISTS report_snapshots (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  report_version_id CHAR(36) UNIQUE NOT NULL REFERENCES report_versions(id) ON DELETE CASCADE,
  snapshot_data JSON NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES
  ('reviews.view.all', 'View Reviews', 'reviews', 'view', 'all', 'Melihat survey pending review'),
  ('reviews.manage.all', 'Manage Reviews', 'reviews', 'manage', 'all', 'Approve, reject, dan need revision survey'),
  ('reports.view.all', 'View Reports', 'reports', 'view', 'all', 'Melihat arsip report'),
  ('reports.generate.all', 'Generate Reports', 'reports', 'generate', 'all', 'Membuat report dari survey approved'),
  ('reports.version.all', 'Version Reports', 'reports', 'version', 'all', 'Membuat revisi report');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('reviews.view.all', 'reviews.manage.all', 'reports.view.all', 'reports.generate.all', 'reports.version.all', 'surveys.view.assigned')
WHERE r.code IN ('super_admin', 'admin', 'supervisor');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('reports.view.all')
WHERE r.code IN ('management');

-- 0008_finance.up.sql
CREATE TABLE IF NOT EXISTS price_lists (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  customer_id CHAR(36) NULL REFERENCES customers(id),
  survey_type_id CHAR(36) NOT NULL REFERENCES survey_types(id),
  container_type_id CHAR(36) NULL REFERENCES container_types(id),
  description VARCHAR(200) NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  currency VARCHAR(10) NOT NULL DEFAULT 'IDR',
  tax_type VARCHAR(50) NULL,
  effective_date DATE NOT NULL,
  expired_date DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL
);

CREATE INDEX idx_price_lists_customer ON price_lists(customer_id);
CREATE INDEX idx_price_lists_survey_type ON price_lists(survey_type_id);
CREATE INDEX idx_price_lists_effective ON price_lists(effective_date);

CREATE TABLE IF NOT EXISTS invoices (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  invoice_no VARCHAR(80) UNIQUE NOT NULL,
  invoice_date DATE NOT NULL,
  customer_id CHAR(36) NOT NULL REFERENCES customers(id),
  billing_address TEXT NULL,
  payment_term_days INT NULL,
  due_date DATE NULL,
  currency VARCHAR(10) NOT NULL DEFAULT 'IDR',
  subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  grand_total DECIMAL(15,2) NOT NULL DEFAULT 0,
  paid_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  outstanding_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'draft',
  issued_at DATETIME(6) NULL,
  issued_by CHAR(36) NULL REFERENCES users(id),
  cancel_reason TEXT NULL,
  cancelled_at DATETIME(6) NULL,
  cancelled_by CHAR(36) NULL REFERENCES users(id),
  created_by CHAR(36) NULL REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE UNIQUE INDEX idx_invoices_no ON invoices(invoice_no);
CREATE INDEX idx_invoices_customer ON invoices(customer_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_date ON invoices(invoice_date);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);

CREATE TABLE IF NOT EXISTS invoice_items (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  invoice_id CHAR(36) NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  job_order_id CHAR(36) NULL REFERENCES job_orders(id),
  report_id CHAR(36) NULL REFERENCES reports(id),
  survey_id CHAR(36) NULL REFERENCES surveys(id),
  price_list_id CHAR(36) NULL REFERENCES price_lists(id),
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(12,2) NOT NULL DEFAULT 1,
  unit_price DECIMAL(15,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  total DECIMAL(15,2) NOT NULL DEFAULT 0,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX idx_invoice_items_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_items_report ON invoice_items(report_id);
CREATE TABLE IF NOT EXISTS payments (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  payment_no VARCHAR(80) UNIQUE NULL,
  invoice_id CHAR(36) NOT NULL REFERENCES invoices(id),
  payment_date DATE NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  payment_method VARCHAR(50) NULL,
  bank_account VARCHAR(150) NULL,
  proof_file_id CHAR(36) NULL REFERENCES file_objects(id),
  note TEXT NULL,
  created_by CHAR(36) NOT NULL REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  cancelled_at DATETIME(6) NULL,
  cancelled_by CHAR(36) NULL REFERENCES users(id),
  cancel_reason TEXT NULL
);

CREATE INDEX idx_payments_invoice ON payments(invoice_id);
CREATE INDEX idx_payments_date ON payments(payment_date);

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES
  ('finance.view.all', 'View Finance', 'finance', 'view', 'all', 'Melihat dashboard finance, invoice, payment, outstanding'),
  ('finance.manage.all', 'Manage Finance', 'finance', 'manage', 'all', 'Mengelola price list, invoice, dan payment'),
  ('finance.invoice.create.all', 'Create Invoice', 'finance.invoice', 'create', 'all', 'Membuat invoice draft'),
  ('finance.payment.create.all', 'Create Payment', 'finance.payment', 'create', 'all', 'Mencatat payment');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('finance.view.all', 'finance.manage.all', 'finance.invoice.create.all', 'finance.payment.create.all', 'reports.view.all')
WHERE r.code IN ('super_admin', 'finance');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('finance.view.all', 'reports.view.all')
WHERE r.code IN ('management');

SET FOREIGN_KEY_CHECKS = 1;
```
