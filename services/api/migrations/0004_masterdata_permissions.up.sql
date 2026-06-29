
INSERT IGNORE INTO permissions (code, module, action, scope, description) VALUES
('customers.view.all', 'customers', 'view', 'all', 'View customers'),
    ('customers.create.all', 'customers', 'create', 'all', 'Create customers'),
    ('customers.update.all', 'customers', 'update', 'all', 'Update customers'),
    ('customers.delete.all', 'customers', 'delete', 'all', 'Deactivate customers'),
    ('locations.view.all', 'locations', 'view', 'all', 'View locations'),
    ('locations.create.all', 'locations', 'create', 'all', 'Create locations'),
    ('locations.update.all', 'locations', 'update', 'all', 'Update locations'),
    ('locations.delete.all', 'locations', 'delete', 'all', 'Deactivate locations'),
    ('surveyors.view.all', 'surveyors', 'view', 'all', 'View surveyor profiles'),
    ('surveyors.create.all', 'surveyors', 'create', 'all', 'Create surveyor profiles'),
    ('surveyors.update.all', 'surveyors', 'update', 'all', 'Update surveyor profiles'),
    ('surveyors.delete.all', 'surveyors', 'delete', 'all', 'Deactivate surveyor profiles'),
    ('container_types.view.all', 'container_types', 'view', 'all', 'View container types'),
    ('container_types.create.all', 'container_types', 'create', 'all', 'Create container types'),
    ('container_types.update.all', 'container_types', 'update', 'all', 'Update container types'),
    ('container_types.delete.all', 'container_types', 'delete', 'all', 'Deactivate container types'),
    ('survey_types.view.all', 'survey_types', 'view', 'all', 'View survey types'),
    ('survey_types.create.all', 'survey_types', 'create', 'all', 'Create survey types'),
    ('survey_types.update.all', 'survey_types', 'update', 'all', 'Update survey types'),
    ('survey_types.delete.all', 'survey_types', 'delete', 'all', 'Deactivate survey types'),
    ('cedex_locations.view.all', 'cedex_locations', 'view', 'all', 'View CEDEX locations'),
    ('cedex_locations.create.all', 'cedex_locations', 'create', 'all', 'Create CEDEX locations'),
    ('cedex_locations.update.all', 'cedex_locations', 'update', 'all', 'Update CEDEX locations'),
    ('cedex_locations.delete.all', 'cedex_locations', 'delete', 'all', 'Deactivate CEDEX locations'),
    ('cedex_components.view.all', 'cedex_components', 'view', 'all', 'View CEDEX components'),
    ('cedex_components.create.all', 'cedex_components', 'create', 'all', 'Create CEDEX components'),
    ('cedex_components.update.all', 'cedex_components', 'update', 'all', 'Update CEDEX components'),
    ('cedex_components.delete.all', 'cedex_components', 'delete', 'all', 'Deactivate CEDEX components'),
    ('cedex_damages.view.all', 'cedex_damages', 'view', 'all', 'View CEDEX damages'),
    ('cedex_damages.create.all', 'cedex_damages', 'create', 'all', 'Create CEDEX damages'),
    ('cedex_damages.update.all', 'cedex_damages', 'update', 'all', 'Update CEDEX damages'),
    ('cedex_damages.delete.all', 'cedex_damages', 'delete', 'all', 'Deactivate CEDEX damages'),
    ('cedex_repairs.view.all', 'cedex_repairs', 'view', 'all', 'View CEDEX repairs'),
    ('cedex_repairs.create.all', 'cedex_repairs', 'create', 'all', 'Create CEDEX repairs'),
    ('cedex_repairs.update.all', 'cedex_repairs', 'update', 'all', 'Update CEDEX repairs'),
    ('cedex_repairs.delete.all', 'cedex_repairs', 'delete', 'all', 'Deactivate CEDEX repairs'),
    ('cedex_materials.view.all', 'cedex_materials', 'view', 'all', 'View CEDEX materials'),
    ('cedex_materials.create.all', 'cedex_materials', 'create', 'all', 'Create CEDEX materials'),
    ('cedex_materials.update.all', 'cedex_materials', 'update', 'all', 'Update CEDEX materials'),
    ('cedex_materials.delete.all', 'cedex_materials', 'delete', 'all', 'Deactivate CEDEX materials'),
    ('responsibility_codes.view.all', 'responsibility_codes', 'view', 'all', 'View responsibility codes'),
    ('responsibility_codes.create.all', 'responsibility_codes', 'create', 'all', 'Create responsibility codes'),
    ('responsibility_codes.update.all', 'responsibility_codes', 'update', 'all', 'Update responsibility codes'),
    ('responsibility_codes.delete.all', 'responsibility_codes', 'delete', 'all', 'Deactivate responsibility codes'),
    ('cedex_locations.manage.all', 'cedex_locations', 'manage', 'all', 'Manage CEDEX locations'),
    ('cedex_components.manage.all', 'cedex_components', 'manage', 'all', 'Manage CEDEX components'),
    ('cedex_damages.manage.all', 'cedex_damages', 'manage', 'all', 'Manage CEDEX damages'),
    ('cedex_repairs.manage.all', 'cedex_repairs', 'manage', 'all', 'Manage CEDEX repairs'),
    ('cedex_materials.manage.all', 'cedex_materials', 'manage', 'all', 'Manage CEDEX materials'),
    ('responsibility_codes.manage.all', 'responsibility_codes', 'manage', 'all', 'Manage responsibility codes'),
    ('surveyors.manage.all', 'surveyors', 'manage', 'all', 'Manage surveyor profiles');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customers.manage.all', 'locations.manage.all', 'surveyors.manage.all', 'container_types.manage.all', 'survey_types.manage.all', 'cedex_locations.manage.all', 'cedex_components.manage.all', 'cedex_damages.manage.all', 'cedex_repairs.manage.all', 'cedex_materials.manage.all', 'responsibility_codes.manage.all')
WHERE r.code = 'admin';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customers.view.all', 'locations.view.all', 'surveyors.view.all', 'container_types.view.all', 'survey_types.view.all', 'cedex_locations.view.all', 'cedex_components.view.all', 'cedex_damages.view.all', 'cedex_repairs.view.all', 'cedex_materials.view.all', 'responsibility_codes.view.all')
WHERE r.code IN ('supervisor', 'management');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('customers.view.all', 'container_types.view.all', 'survey_types.view.all')
WHERE r.code = 'finance';






