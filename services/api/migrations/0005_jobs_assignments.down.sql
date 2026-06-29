DROP TABLE IF EXISTS job_events;
DROP TABLE IF EXISTS assignment_containers;
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS container_import_batches;
DROP TABLE IF EXISTS job_containers;
DROP TABLE IF EXISTS job_orders;

DELETE rp FROM role_permissions rp JOIN permissions p ON p.id = rp.permission_id WHERE p.code IN ('jobs.view.all', 'jobs.create.all', 'jobs.update.all', 'jobs.cancel.all', 'jobs.manage.all', 'job_containers.view.all', 'job_containers.create.all', 'job_containers.import.all', 'job_containers.update.all', 'job_containers.delete.all', 'job_containers.reassign.all', 'assignments.view.all', 'assignments.assign.all', 'assignments.reassign.all', 'assignments.manage.all');

DELETE FROM permissions WHERE code IN ('jobs.view.all', 'jobs.create.all', 'jobs.update.all', 'jobs.cancel.all', 'jobs.manage.all', 'job_containers.view.all', 'job_containers.create.all', 'job_containers.import.all', 'job_containers.update.all', 'job_containers.delete.all', 'job_containers.reassign.all', 'assignments.view.all', 'assignments.assign.all', 'assignments.reassign.all', 'assignments.manage.all');





