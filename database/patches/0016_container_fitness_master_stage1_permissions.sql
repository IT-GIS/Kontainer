-- 0016_container_fitness_master_stage1_permissions.sql
-- Align granular CRUD permissions for Admin Master Data CRUD Stage 1.
-- Safe to run repeatedly after 0015_container_fitness_foundation.sql.

START TRANSACTION;

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES
  ('container_manufacturers.create.all', 'Create Container Manufacturers', 'container_manufacturers', 'create', 'all', 'Membuat master pabrik pembuat peti kemas'),
  ('container_manufacturers.update.all', 'Update Container Manufacturers', 'container_manufacturers', 'update', 'all', 'Mengubah master pabrik pembuat peti kemas'),
  ('container_manufacturers.delete.all', 'Delete Container Manufacturers', 'container_manufacturers', 'delete', 'all', 'Menonaktifkan master pabrik pembuat peti kemas'),
  ('fitness_approval_categories.create.all', 'Create Fitness Approval Categories', 'fitness_approval_categories', 'create', 'all', 'Membuat kategori persetujuan kelaikan'),
  ('fitness_approval_categories.update.all', 'Update Fitness Approval Categories', 'fitness_approval_categories', 'update', 'all', 'Mengubah kategori persetujuan kelaikan'),
  ('fitness_approval_categories.delete.all', 'Delete Fitness Approval Categories', 'fitness_approval_categories', 'delete', 'all', 'Menonaktifkan kategori persetujuan kelaikan');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'container_manufacturers.create.all',
  'container_manufacturers.update.all',
  'container_manufacturers.delete.all',
  'fitness_approval_categories.create.all',
  'fitness_approval_categories.update.all',
  'fitness_approval_categories.delete.all'
)
WHERE r.code IN ('super_admin', 'admin');

COMMIT;
