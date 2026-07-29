ALTER TABLE survey_damages
  ADD COLUMN dimension_profile VARCHAR(30) NULL AFTER finding_description,
  ADD COLUMN location_selection_snapshot JSON NULL AFTER dimension_profile;

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES ('survey_photos.delete.assigned', 'Delete Assigned Survey Photo', 'survey_photos', 'delete', 'assigned', 'Hapus lunak foto evidence pada survey sendiri');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT role.id, permission.id
FROM roles role
JOIN permissions permission ON permission.code='survey_photos.delete.assigned'
WHERE role.code IN ('surveyor', 'super_admin', 'admin', 'supervisor');
