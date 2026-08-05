DELETE rp FROM role_permissions rp
JOIN roles r ON r.id=rp.role_id
JOIN permissions p ON p.id=rp.permission_id
WHERE r.code='surveyor' AND p.code='surveyor_profiles.view.own';

DROP TABLE IF EXISTS object_deletion_queue;

ALTER TABLE reports
  DROP INDEX idx_reports_job_container,
  DROP FOREIGN KEY fk_reports_approved_by,
  DROP FOREIGN KEY fk_reports_created_by,
  DROP FOREIGN KEY fk_reports_job_container,
  DROP COLUMN notes,
  DROP COLUMN approved_at,
  DROP COLUMN approved_by,
  DROP COLUMN created_by,
  DROP COLUMN job_container_id;

ALTER TABLE surveyor_profiles
  DROP INDEX idx_surveyor_profiles_certificate_valid_until,
  DROP COLUMN assignment_locations,
  DROP COLUMN competencies,
  DROP COLUMN certificate_valid_until,
  DROP COLUMN certificate_number;

ALTER TABLE survey_revision_items
  DROP INDEX idx_survey_revision_items_target,
  DROP CHECK chk_survey_revision_items_target,
  DROP COLUMN due_at,
  DROP COLUMN target_snapshot,
  DROP COLUMN category;

ALTER TABLE surveys
  DROP INDEX idx_surveys_current_reviewer,
  DROP INDEX idx_surveys_active_status,
  DROP INDEX uq_surveys_active_container_phase_round,
  DROP CHECK chk_surveys_round,
  DROP CHECK chk_surveys_phase,
  DROP CHECK chk_surveys_status,
  DROP FOREIGN KEY fk_surveys_current_reviewer,
  DROP COLUMN current_reviewer_id,
  DROP COLUMN is_active,
  DROP COLUMN survey_round,
  DROP COLUMN phase;

ALTER TABLE job_containers
  DROP CHECK chk_job_containers_status,
  DROP FOREIGN KEY fk_job_containers_check_digit_override_by,
  DROP COLUMN csc_program_type,
  DROP COLUMN csc_next_examination_date,
  DROP COLUMN csc_manufacture_date,
  DROP COLUMN csc_approval_reference,
  DROP COLUMN csc_plate_number,
  DROP COLUMN check_digit_override_at,
  DROP COLUMN check_digit_override_by,
  DROP COLUMN container_check_digit_valid,
  DROP COLUMN container_check_digit_calculated,
  DROP COLUMN container_number_input,
  ADD CONSTRAINT chk_job_containers_status CHECK (status IN (
    'not_started','assigned','in_progress','draft','submitted','need_revision','approved','rejected',
    'reported','invoiced','closed','cancelled'
  ));

ALTER TABLE job_orders
  DROP CHECK chk_job_orders_status,
  ADD CONSTRAINT chk_job_orders_status CHECK (status IN (
    'draft','assigned','in_progress','all_survey_submitted','all_survey_approved','report_generated',
    'ready_to_invoice','invoiced','paid','closed','cancelled'
  ));
