DELETE role_permission
FROM role_permissions role_permission
JOIN permissions permission ON permission.id=role_permission.permission_id
WHERE permission.code='survey_photos.delete.assigned';

DELETE FROM permissions WHERE code='survey_photos.delete.assigned';

ALTER TABLE survey_damages
  DROP COLUMN location_selection_snapshot,
  DROP COLUMN dimension_profile;
