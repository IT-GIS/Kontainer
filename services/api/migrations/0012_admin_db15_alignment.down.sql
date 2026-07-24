ALTER TABLE survey_checklist_responses
  DROP FOREIGN KEY fk_survey_checklist_template_item,
  DROP FOREIGN KEY fk_survey_checklist_survey,
  DROP INDEX idx_survey_checklist_template_item;

ALTER TABLE job_orders
  DROP FOREIGN KEY fk_job_orders_spk_file,
  DROP INDEX idx_job_orders_spk_file,
  DROP COLUMN spk_notes,
  DROP COLUMN spk_file_id,
  DROP COLUMN spk_date,
  DROP COLUMN spk_no;
