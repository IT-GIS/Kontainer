
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








