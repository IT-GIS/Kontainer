-- 0009_navigation_permissions.sql
-- Align role permissions with the three frontend workspaces without changing schema.
-- Safe to run repeatedly after database/kontainer_db.sql.

START TRANSACTION;

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES
  ('audit.view.all', 'View Audit Log', 'audit', 'view', 'all', 'Melihat audit log sistem'),
  ('checklist_templates.view.all', 'View Checklist Templates', 'checklist_templates', 'view', 'all', 'Melihat checklist template dan data bootstrap'),
  ('settings.view.all', 'View Settings', 'settings', 'view', 'all', 'Melihat workspace setting'),
  ('users.view.all', 'View Users', 'users', 'view', 'all', 'Melihat daftar user secara read-only'),
  ('roles.view.all', 'View Roles', 'roles', 'view', 'all', 'Melihat role dan permission secara read-only'),
  ('company_profiles.view.all', 'View Company Profile', 'company_profiles', 'view', 'all', 'Melihat profil perusahaan'),
  ('numbering_settings.view.all', 'View Numbering Settings', 'numbering_settings', 'view', 'all', 'Melihat konfigurasi numbering');

-- Super Admin remains fully authorized through the existing wildcard.
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code = '*.*.all'
WHERE r.code = 'super_admin';

-- Admin receives read-only settings permissions, but never user/role management.
DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'admin'
  AND p.code IN ('users.manage.all', 'roles.manage.all');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'settings.view.all',
  'company_profiles.view.all',
  'numbering_settings.view.all',
  'checklist_templates.view.all',
  'audit.view.all'
)
WHERE r.code = 'admin';

-- Management is read-only: dashboard, report archive, and finance recap only.
DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'management'
  AND p.code NOT IN ('dashboard.view.all', 'reports.view.all', 'finance.view.all');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('dashboard.view.all', 'reports.view.all', 'finance.view.all')
WHERE r.code = 'management';

-- Supervisor is restricted to review and report workflows.
DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
WHERE r.code = 'supervisor';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'reviews.view.all',
  'reviews.manage.all',
  'reports.view.all',
  'reports.generate.all',
  'reports.version.all'
)
WHERE r.code = 'supervisor';

-- Surveyor keeps assigned-scope operations plus read-only CEDEX references
-- required by the assigned survey form. These reference grants do not expose
-- the Admin workspace because frontend workspace visibility is role-gated.
DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
WHERE r.code = 'surveyor';

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
  'survey_photos.view.assigned',
  'cedex_locations.view.all',
  'cedex_components.view.all',
  'cedex_damages.view.all',
  'cedex_repairs.view.all',
  'cedex_materials.view.all',
  'responsibility_codes.view.all'
)
WHERE r.code = 'surveyor';

-- Finance keeps finance operations and read-only report access.
DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
WHERE r.code = 'finance';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'finance.view.all',
  'finance.manage.all',
  'finance.invoice.create.all',
  'finance.payment.create.all',
  'reports.view.all'
)
WHERE r.code = 'finance';

COMMIT;
