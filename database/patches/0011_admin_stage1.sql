-- 0011_admin_stage1.sql
-- Stage 1 Admin navigation/monitoring permissions and rejected container status.
-- Safe to run repeatedly after database/kontainer_db.sql.

START TRANSACTION;

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES ('surveys.view.all', 'View All Surveys', 'surveys', 'view', 'all', 'Melihat seluruh survey untuk monitoring Admin');

DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'admin'
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
  'surveys.view.all', 'reviews.view.all', 'reviews.manage.all', 'reports.view.all',
  'users.view.all', 'company_profiles.view.all', 'numbering_settings.view.all', 'audit.view.all'
)
WHERE r.code = 'admin';

COMMIT;

SET @has_job_container_status_check = (
  SELECT COUNT(*)
  FROM information_schema.table_constraints
  WHERE constraint_schema = DATABASE()
    AND table_name = 'job_containers'
    AND constraint_name = 'chk_job_containers_status'
    AND constraint_type = 'CHECK'
);
SET @drop_job_container_status_check = IF(
  @has_job_container_status_check > 0,
  'ALTER TABLE job_containers DROP CHECK chk_job_containers_status',
  'SELECT 1'
);
PREPARE stage1_stmt FROM @drop_job_container_status_check;
EXECUTE stage1_stmt;
DEALLOCATE PREPARE stage1_stmt;

ALTER TABLE job_containers
  ADD CONSTRAINT chk_job_containers_status
  CHECK (status IN ('not_started', 'assigned', 'in_progress', 'draft', 'submitted', 'need_revision', 'approved', 'rejected', 'reported', 'invoiced', 'closed', 'cancelled'));
