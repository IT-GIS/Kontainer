ALTER TABLE surveys
  ADD COLUMN review_started_by CHAR(36) NULL AFTER submitted_at,
  ADD COLUMN review_started_at DATETIME(6) NULL AFTER review_started_by,
  ADD COLUMN resubmitted_at DATETIME(6) NULL AFTER review_started_at,
  ADD CONSTRAINT fk_surveys_review_started_by
    FOREIGN KEY (review_started_by) REFERENCES users(id);

CREATE INDEX idx_surveys_review_started_at ON surveys(review_started_at);
CREATE INDEX idx_surveys_resubmitted_at ON surveys(resubmitted_at);

CREATE TABLE IF NOT EXISTS survey_revisions (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  survey_id CHAR(36) NOT NULL,
  revision_no INT NOT NULL,
  revision_reason TEXT NOT NULL,
  requested_by CHAR(36) NOT NULL,
  requested_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  resubmitted_by CHAR(36) NULL,
  resubmitted_at DATETIME(6) NULL,
  reviewer_note TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'requested',
  snapshot_before JSON NOT NULL,
  snapshot_after JSON NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE KEY uq_survey_revisions_no (survey_id, revision_no),
  INDEX idx_survey_revisions_survey (survey_id),
  INDEX idx_survey_revisions_status (status),
  INDEX idx_survey_revisions_requested_at (requested_at),
  CONSTRAINT fk_survey_revisions_survey
    FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
  CONSTRAINT fk_survey_revisions_requested_by
    FOREIGN KEY (requested_by) REFERENCES users(id),
  CONSTRAINT fk_survey_revisions_resubmitted_by
    FOREIGN KEY (resubmitted_by) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE survey_damages
  ADD COLUMN checklist_response_id CHAR(36) NULL AFTER survey_id,
  ADD CONSTRAINT fk_survey_damages_checklist_response
    FOREIGN KEY (checklist_response_id) REFERENCES survey_checklist_responses(id);

CREATE INDEX idx_survey_damages_checklist_response
  ON survey_damages(checklist_response_id);
