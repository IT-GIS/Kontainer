
-- Development-only bootstrap user.
-- Email: superadmin@gift.local
-- Password: password
-- Replace this credential before any staging/production use.
INSERT IGNORE INTO users (id, name, email, username, password_hash, status, password_changed_at)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Super Admin Dev',
  'superadmin@gift.local',
  'superadmin',
  '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',
  'active',
  now()
);

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000001', r.id
FROM roles r
WHERE r.code = 'super_admin';







