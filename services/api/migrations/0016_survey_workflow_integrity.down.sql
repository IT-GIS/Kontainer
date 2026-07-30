DROP INDEX idx_survey_damages_checklist_response ON survey_damages;
ALTER TABLE survey_damages
  DROP FOREIGN KEY fk_survey_damages_checklist_response,
  DROP COLUMN checklist_response_id;

DROP TABLE IF EXISTS survey_revisions;

DROP INDEX idx_surveys_resubmitted_at ON surveys;
DROP INDEX idx_surveys_review_started_at ON surveys;
ALTER TABLE surveys
  DROP FOREIGN KEY fk_surveys_review_started_by,
  DROP COLUMN resubmitted_at,
  DROP COLUMN review_started_at,
  DROP COLUMN review_started_by;
