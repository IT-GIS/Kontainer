-- 0014_uat_stabilization.sql
-- Stabilize the UAT role matrix without changing schema or business data.
-- Safe to run repeatedly after database/kontainer_db.sql.

START TRANSACTION;

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES
  ('users.view.all', 'View All Users', 'users', 'view', 'all', 'Melihat daftar user read-only'),
  ('surveys.view.all', 'View All Surveys', 'surveys', 'view', 'all', 'Melihat seluruh survey untuk monitoring');

DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id=rp.role_id
JOIN permissions p ON p.id=rp.permission_id
WHERE r.code='admin'
  AND p.code IN ('users.manage.all', 'roles.view.all', 'roles.manage.all');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'dashboard.view.all',
  'customers.manage.all', 'locations.manage.all', 'surveyors.manage.all',
  'container_types.manage.all', 'survey_types.manage.all',
  'cedex_locations.manage.all', 'cedex_components.manage.all', 'cedex_damages.manage.all',
  'cedex_repairs.manage.all', 'cedex_materials.manage.all', 'responsibility_codes.manage.all',
  'jobs.manage.all', 'job_containers.view.all', 'job_containers.create.all',
  'job_containers.import.all', 'job_containers.update.all', 'job_containers.delete.all',
  'job_containers.reassign.all', 'assignments.manage.all',
  'surveys.view.all', 'reviews.view.all', 'reviews.manage.all',
  'reports.view.all', 'users.view.all',
  'company_profiles.view.all', 'numbering_settings.view.all', 'audit.view.all'
)
WHERE r.code='admin';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'dashboard.view.all', 'surveys.view.all',
  'reviews.view.all', 'reviews.manage.all',
  'reports.view.all', 'reports.generate.all', 'reports.version.all'
)
WHERE r.code='supervisor';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'dashboard.view.all', 'finance.view.all', 'finance.manage.all', 'reports.view.all'
)
WHERE r.code='finance';

DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id=rp.role_id
JOIN permissions p ON p.id=rp.permission_id
WHERE r.code='management'
  AND p.code NOT IN ('dashboard.view.all', 'reports.view.all', 'finance.view.all');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('dashboard.view.all', 'reports.view.all', 'finance.view.all')
WHERE r.code='management';

COMMIT;
