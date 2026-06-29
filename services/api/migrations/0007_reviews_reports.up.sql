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






