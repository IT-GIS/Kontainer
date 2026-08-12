-- Compatibility patch for installations that already applied 0023.
ALTER TABLE object_deletion_queue
  ADD COLUMN retry_count INT UNSIGNED NOT NULL DEFAULT 0 AFTER error_message,
  ADD COLUMN last_attempt_at DATETIME(6) NULL AFTER retry_count,
  ADD COLUMN next_retry_at DATETIME(6) NULL AFTER last_attempt_at,
  ADD COLUMN locked_at DATETIME(6) NULL AFTER next_retry_at,
  ADD COLUMN locked_by VARCHAR(160) NULL AFTER locked_at,
  ADD INDEX idx_object_deletion_queue_retry (status,next_retry_at,eligible_after,locked_at),
  ADD CONSTRAINT chk_object_deletion_queue_retry_count CHECK (retry_count >= 0);

DELETE role_permission
FROM role_permissions role_permission
JOIN roles role ON role.id=role_permission.role_id
JOIN permissions permission ON permission.id=role_permission.permission_id
WHERE role.code='management'
  AND permission.action IN ('create','update','delete','manage','assign','reassign','cancel','approve','reject','generate','version','issue');

DELETE role_permission
FROM role_permissions role_permission
JOIN roles role ON role.id=role_permission.role_id
JOIN permissions permission ON permission.id=role_permission.permission_id
WHERE role.code='admin' AND permission.code='reviews.manage.all';

INSERT IGNORE INTO role_permissions (role_id,permission_id)
SELECT role.id, permission.id
FROM roles role
JOIN permissions permission ON permission.code IN ('dashboard.view.all','surveys.view.all','reviews.view.all','reports.view.all')
WHERE role.code='management';
