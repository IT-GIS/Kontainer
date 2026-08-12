DELETE role_permission
FROM role_permissions role_permission
JOIN roles role ON role.id=role_permission.role_id
JOIN permissions permission ON permission.id=role_permission.permission_id
WHERE role.code='management'
  AND permission.code IN ('surveys.view.all','reviews.view.all');

INSERT IGNORE INTO role_permissions (role_id,permission_id)
SELECT role.id, permission.id
FROM roles role
JOIN permissions permission ON permission.code='reviews.manage.all'
WHERE role.code='admin';

ALTER TABLE object_deletion_queue
  DROP CHECK chk_object_deletion_queue_retry_count,
  DROP INDEX idx_object_deletion_queue_retry,
  DROP COLUMN locked_by,
  DROP COLUMN locked_at,
  DROP COLUMN next_retry_at,
  DROP COLUMN last_attempt_at,
  DROP COLUMN retry_count;
