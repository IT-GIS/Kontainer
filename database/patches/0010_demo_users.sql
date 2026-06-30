-- 0010_demo_users.sql
-- Development-only demo accounts for each application role.
-- Password for every account: password
-- Safe to run repeatedly after database/kontainer_db.sql.

START TRANSACTION;

INSERT IGNORE INTO users (id, name, email, username, password_hash, status, password_changed_at)
VALUES
  ('00000000-0000-0000-0000-000000000002', 'Admin Demo', 'admin@gift.local', 'admin', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6)),
  ('00000000-0000-0000-0000-000000000003', 'Surveyor Demo', 'surveyor@gift.local', 'surveyor', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6)),
  ('00000000-0000-0000-0000-000000000004', 'Supervisor Demo', 'supervisor@gift.local', 'supervisor', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6)),
  ('00000000-0000-0000-0000-000000000005', 'Finance Demo', 'finance@gift.local', 'finance', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6)),
  ('00000000-0000-0000-0000-000000000006', 'Management Demo', 'management@gift.local', 'management', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6));

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
JOIN roles r ON r.code = CASE u.email
  WHEN 'admin@gift.local' THEN 'admin'
  WHEN 'surveyor@gift.local' THEN 'surveyor'
  WHEN 'supervisor@gift.local' THEN 'supervisor'
  WHEN 'finance@gift.local' THEN 'finance'
  WHEN 'management@gift.local' THEN 'management'
END
WHERE u.email IN (
  'admin@gift.local',
  'surveyor@gift.local',
  'supervisor@gift.local',
  'finance@gift.local',
  'management@gift.local'
);

INSERT IGNORE INTO surveyor_profiles (id, user_id, surveyor_code, full_name, area, status)
SELECT
  '00000000-0000-0000-0000-000000000103',
  u.id,
  'SVY-DEMO',
  'Surveyor Demo',
  'Demo Area',
  'active'
FROM users u
WHERE u.email = 'surveyor@gift.local';

COMMIT;
