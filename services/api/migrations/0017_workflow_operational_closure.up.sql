-- Operational workflow closure for Admin, Surveyor, Review, and internal reports.
-- Additive and compatibility-safe: legacy columns remain available during transition.

ALTER TABLE job_orders
  DROP CHECK chk_job_orders_status,
  ADD CONSTRAINT chk_job_orders_status CHECK (status IN (
    'draft','assigned','in_progress','all_survey_submitted','under_review','need_revision',
    'all_survey_decided','all_survey_approved','completed_with_rejection','report_generated',
    'ready_to_invoice','invoiced','paid','closed','cancelled'
  ));

ALTER TABLE job_containers
  DROP CHECK chk_job_containers_status,
  ADD COLUMN container_number_input VARCHAR(20) NULL AFTER container_no,
  ADD COLUMN container_check_digit_calculated VARCHAR(2) NULL AFTER check_digit,
  ADD COLUMN container_check_digit_valid TINYINT(1) NULL AFTER container_check_digit_calculated,
  ADD COLUMN check_digit_override_by CHAR(36) NULL AFTER check_digit_override_reason,
  ADD COLUMN check_digit_override_at DATETIME(6) NULL AFTER check_digit_override_by,
  ADD COLUMN csc_plate_number VARCHAR(100) NULL AFTER csc_plate_status,
  ADD COLUMN csc_approval_reference VARCHAR(150) NULL AFTER csc_plate_number,
  ADD COLUMN csc_manufacture_date DATE NULL AFTER csc_approval_reference,
  ADD COLUMN csc_next_examination_date DATE NULL AFTER csc_manufacture_date,
  ADD COLUMN csc_program_type VARCHAR(50) NULL AFTER csc_next_examination_date,
  ADD CONSTRAINT fk_job_containers_check_digit_override_by FOREIGN KEY (check_digit_override_by) REFERENCES users(id),
  ADD CONSTRAINT chk_job_containers_status CHECK (status IN (
    'not_started','unassigned','assigned','in_progress','draft','submitted','under_review',
    'need_revision','resubmitted','approved','rejected','report_generated','reported',
    'invoiced','closed','cancelled'
  ));

UPDATE job_containers
SET container_number_input=container_no,
    container_check_digit_valid=CASE WHEN check_digit_status='valid' THEN 1 WHEN check_digit_status IN ('invalid','override') THEN 0 ELSE NULL END
WHERE container_number_input IS NULL;

-- Some installations received the expanded survey-status check through an
-- earlier compatibility patch. Normalize it before applying the canonical
-- constraint so this migration also works on those databases.
SET @has_survey_status_check = (
  SELECT COUNT(*)
  FROM information_schema.table_constraints
  WHERE constraint_schema = DATABASE()
    AND table_name = 'surveys'
    AND constraint_name = 'chk_surveys_status'
    AND constraint_type = 'CHECK'
);
SET @drop_survey_status_check = IF(
  @has_survey_status_check > 0,
  'ALTER TABLE surveys DROP CHECK chk_surveys_status',
  'SELECT 1'
);
PREPARE workflow_stmt FROM @drop_survey_status_check;
EXECUTE workflow_stmt;
DEALLOCATE PREPARE workflow_stmt;

ALTER TABLE surveys
  ADD COLUMN phase VARCHAR(30) NOT NULL DEFAULT 'initial' AFTER survey_type_id,
  ADD COLUMN survey_round INT NOT NULL DEFAULT 1 AFTER phase,
  ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1 AFTER survey_round,
  ADD COLUMN current_reviewer_id CHAR(36) NULL AFTER review_started_by,
  ADD CONSTRAINT fk_surveys_current_reviewer FOREIGN KEY (current_reviewer_id) REFERENCES users(id),
  ADD CONSTRAINT chk_surveys_status CHECK (status IN (
    'draft','submitted','under_review','need_revision','resubmitted','approved','rejected','cancelled'
  )),
  ADD CONSTRAINT chk_surveys_phase CHECK (phase IN ('initial','reinspection')),
  ADD CONSTRAINT chk_surveys_round CHECK (survey_round > 0),
  ADD UNIQUE KEY uq_surveys_active_container_phase_round (job_container_id,survey_type_id,phase,survey_round,is_active),
  ADD INDEX idx_surveys_active_status (is_active,status),
  ADD INDEX idx_surveys_current_reviewer (current_reviewer_id);

ALTER TABLE survey_revision_items
  ADD COLUMN category VARCHAR(50) NOT NULL DEFAULT 'general' AFTER target_type,
  ADD COLUMN target_snapshot JSON NULL AFTER target_id,
  ADD COLUMN due_at DATETIME(6) NULL AFTER target_snapshot,
  ADD CONSTRAINT chk_survey_revision_items_target CHECK (target_type IN ('survey','finding','checklist','photo')),
  ADD INDEX idx_survey_revision_items_target (survey_id,target_type,target_id);

ALTER TABLE surveyor_profiles
  ADD COLUMN certificate_number VARCHAR(100) NULL AFTER area,
  ADD COLUMN certificate_valid_until DATE NULL AFTER certificate_number,
  ADD COLUMN competencies TEXT NULL AFTER certificate_valid_until,
  ADD COLUMN assignment_locations TEXT NULL AFTER competencies,
  ADD INDEX idx_surveyor_profiles_certificate_valid_until (certificate_valid_until);

ALTER TABLE reports
  ADD COLUMN job_container_id CHAR(36) NULL AFTER job_order_id,
  ADD COLUMN created_by CHAR(36) NULL AFTER generated_by,
  ADD COLUMN approved_by CHAR(36) NULL AFTER finalized_by,
  ADD COLUMN approved_at DATETIME(6) NULL AFTER approved_by,
  ADD COLUMN notes TEXT NULL AFTER approved_at,
  ADD CONSTRAINT fk_reports_job_container FOREIGN KEY (job_container_id) REFERENCES job_containers(id),
  ADD CONSTRAINT fk_reports_created_by FOREIGN KEY (created_by) REFERENCES users(id),
  ADD CONSTRAINT fk_reports_approved_by FOREIGN KEY (approved_by) REFERENCES users(id),
  ADD INDEX idx_reports_job_container (job_container_id);

CREATE TABLE object_deletion_queue (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  bucket_name VARCHAR(160) NOT NULL,
  object_key VARCHAR(700) NOT NULL,
  reason VARCHAR(100) NOT NULL,
  requested_by CHAR(36) NULL,
  requested_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  eligible_after DATETIME(6) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  processed_at DATETIME(6) NULL,
  error_message TEXT NULL,
  UNIQUE KEY uq_object_deletion_queue_key_status (object_key,status),
  INDEX idx_object_deletion_queue_eligible (status,eligible_after),
  CONSTRAINT fk_object_deletion_queue_requested_by FOREIGN KEY (requested_by) REFERENCES users(id),
  CONSTRAINT chk_object_deletion_queue_status CHECK (status IN ('pending','cancelled','processed','failed'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT IGNORE INTO permissions (code,name,module,action,scope,description)
VALUES ('surveyor_profiles.view.own','View Own Surveyor Profile','surveyor_profiles','view','own','Melihat profil Surveyor milik akun sendiri');

INSERT IGNORE INTO role_permissions (role_id,permission_id)
SELECT role.id, permission.id
FROM roles role
JOIN permissions permission ON permission.code='surveyor_profiles.view.own'
WHERE role.code='surveyor';
