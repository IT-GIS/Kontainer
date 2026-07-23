-- Rollback is intentionally guarded because dropping customer_id after scoped
-- data exists would destroy ownership and can make global unique keys invalid.

DELIMITER $$
DROP PROCEDURE IF EXISTS guard_0011_customer_scoped_down$$
CREATE PROCEDURE guard_0011_customer_scoped_down()
BEGIN
  IF EXISTS (SELECT 1 FROM locations WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM container_types WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM survey_types WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM cedex_locations WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM cedex_components WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM cedex_damages WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM cedex_repairs WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM cedex_materials WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM responsibility_codes WHERE customer_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM customer_personnel LIMIT 1)
    OR EXISTS (SELECT 1 FROM fitness_checklist_templates WHERE customer_id IS NOT NULL OR survey_type_id IS NOT NULL LIMIT 1)
    OR EXISTS (SELECT 1 FROM customer_survey_type_severities LIMIT 1)
    OR EXISTS (SELECT 1 FROM customer_survey_type_test_parameters LIMIT 1)
    OR EXISTS (SELECT 1 FROM customer_survey_type_photo_categories LIMIT 1)
  THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = '0011 rollback blocked: remove or migrate customer-scoped data first';
  END IF;
END$$
DELIMITER ;

CALL guard_0011_customer_scoped_down();
DROP PROCEDURE guard_0011_customer_scoped_down;

ALTER TABLE survey_damages
  DROP COLUMN manual_location_reason;

ALTER TABLE survey_checklist_responses
  DROP FOREIGN KEY fk_survey_checklist_attachment,
  DROP INDEX idx_survey_checklist_attachment,
  DROP COLUMN attachment_file_id,
  DROP COLUMN requires_attachment,
  DROP COLUMN standard_reference,
  DROP COLUMN unit,
  DROP COLUMN response_type,
  DROP COLUMN response_numeric;

ALTER TABLE surveys
  DROP FOREIGN KEY fk_surveys_checklist_template,
  DROP INDEX idx_surveys_checklist_template,
  DROP COLUMN checklist_template_id;

DROP TABLE customer_survey_type_photo_categories;
DROP TABLE customer_survey_type_test_parameters;
DROP TABLE customer_survey_type_severities;

ALTER TABLE fitness_checklist_templates
  DROP FOREIGN KEY fk_fitness_checklist_templates_survey_type,
  DROP FOREIGN KEY fk_fitness_checklist_templates_customer,
  DROP INDEX idx_fitness_checklist_templates_survey_type,
  DROP INDEX idx_fitness_checklist_templates_customer_status,
  DROP INDEX idx_fitness_checklist_templates_customer,
  DROP INDEX uq_fitness_checklist_templates_customer_code,
  ADD UNIQUE INDEX template_code (template_code),
  DROP COLUMN survey_type_id,
  DROP COLUMN customer_id;

ALTER TABLE job_orders
  DROP FOREIGN KEY fk_job_orders_pic_customer_personnel,
  DROP INDEX idx_job_orders_pic_customer_personnel,
  DROP COLUMN pic_customer_personnel_id;

DROP TABLE customer_personnel_locations;
DROP TABLE customer_personnel;

ALTER TABLE responsibility_codes
  DROP FOREIGN KEY fk_responsibility_codes_customer,
  DROP INDEX idx_responsibility_codes_customer_status,
  DROP INDEX idx_responsibility_codes_customer,
  DROP INDEX uq_responsibility_codes_customer_code,
  ADD UNIQUE INDEX code (code),
  DROP COLUMN customer_id;

ALTER TABLE cedex_materials
  DROP FOREIGN KEY fk_cedex_materials_customer,
  DROP INDEX idx_cedex_materials_customer_status,
  DROP INDEX idx_cedex_materials_customer,
  DROP INDEX uq_cedex_materials_customer_code,
  ADD UNIQUE INDEX code (code),
  DROP COLUMN customer_id;

ALTER TABLE cedex_repairs
  DROP FOREIGN KEY fk_cedex_repairs_customer,
  DROP INDEX idx_cedex_repairs_customer_status,
  DROP INDEX idx_cedex_repairs_customer,
  DROP INDEX uq_cedex_repairs_customer_code,
  ADD UNIQUE INDEX code (code),
  DROP COLUMN customer_id;

ALTER TABLE cedex_damages
  DROP FOREIGN KEY fk_cedex_damages_customer,
  DROP INDEX idx_cedex_damages_customer_status,
  DROP INDEX idx_cedex_damages_customer,
  DROP INDEX uq_cedex_damages_customer_code,
  ADD UNIQUE INDEX code (code),
  DROP COLUMN customer_id;

ALTER TABLE cedex_components
  DROP FOREIGN KEY fk_cedex_components_customer,
  DROP INDEX idx_cedex_components_customer_status,
  DROP INDEX idx_cedex_components_customer,
  DROP INDEX uq_cedex_components_customer_code,
  ADD UNIQUE INDEX code (code),
  DROP COLUMN customer_id;

ALTER TABLE cedex_locations
  DROP FOREIGN KEY fk_cedex_locations_customer,
  DROP INDEX idx_cedex_locations_customer_status,
  DROP INDEX idx_cedex_locations_customer,
  DROP INDEX uq_cedex_locations_customer_code,
  ADD UNIQUE INDEX idx_cedex_locations_unique_scope (code, face, container_size),
  DROP COLUMN customer_id;

ALTER TABLE survey_types
  DROP FOREIGN KEY fk_survey_types_customer,
  DROP INDEX idx_survey_types_customer_status,
  DROP INDEX idx_survey_types_customer,
  DROP INDEX uq_survey_types_customer_code,
  ADD UNIQUE INDEX code (code),
  DROP COLUMN customer_id;

ALTER TABLE container_types
  DROP FOREIGN KEY fk_container_types_customer,
  DROP INDEX idx_container_types_customer_status,
  DROP INDEX idx_container_types_customer,
  DROP INDEX uq_container_types_customer_code,
  ADD UNIQUE INDEX code (code),
  DROP COLUMN customer_id;

ALTER TABLE locations
  DROP FOREIGN KEY fk_locations_customer,
  DROP INDEX idx_locations_customer_status,
  DROP INDEX idx_locations_customer,
  DROP INDEX uq_locations_customer_code,
  ADD UNIQUE INDEX idx_locations_code (location_code),
  DROP COLUMN access_notes,
  DROP COLUMN pic_email,
  DROP COLUMN postal_code,
  DROP COLUMN province,
  DROP COLUMN customer_id;
