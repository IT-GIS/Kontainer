ALTER TABLE job_orders
  ADD COLUMN spk_no VARCHAR(100) NULL AFTER reference_no,
  ADD COLUMN spk_date DATE NULL AFTER spk_no,
  ADD COLUMN spk_file_id CHAR(36) NULL AFTER spk_date,
  ADD COLUMN spk_notes TEXT NULL AFTER spk_file_id,
  ADD INDEX idx_job_orders_spk_file (spk_file_id),
  ADD CONSTRAINT fk_job_orders_spk_file FOREIGN KEY (spk_file_id) REFERENCES file_objects(id);

ALTER TABLE survey_checklist_responses
  ADD INDEX idx_survey_checklist_template_item (template_item_id),
  ADD CONSTRAINT fk_survey_checklist_survey FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
  ADD CONSTRAINT fk_survey_checklist_template_item FOREIGN KEY (template_item_id) REFERENCES fitness_checklist_template_items(id);
