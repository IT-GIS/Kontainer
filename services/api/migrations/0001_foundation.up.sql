

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









