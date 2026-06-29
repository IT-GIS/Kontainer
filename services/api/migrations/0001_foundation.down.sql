
DROP TABLE IF EXISTS responsibility_codes;
DROP TABLE IF EXISTS cedex_materials;
DROP TABLE IF EXISTS cedex_repairs;
DROP TABLE IF EXISTS cedex_damages;
DROP TABLE IF EXISTS cedex_components;
DROP TABLE IF EXISTS cedex_locations;
DROP TABLE IF EXISTS survey_types;
DROP TABLE IF EXISTS container_types;
DROP TABLE IF EXISTS surveyor_profiles;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS numbering_sequences;
DROP TABLE IF EXISTS numbering_settings;
DROP TABLE IF EXISTS company_profiles;
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS roles;
ALTER TABLE IF EXISTS file_objects DROP CONSTRAINT IF EXISTS fk_file_objects_uploaded_by;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS file_objects;






