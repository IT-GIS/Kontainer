ALTER TABLE survey_general_infos
  DROP COLUMN csc_program_type_verified,
  DROP COLUMN csc_next_examination_date_verified,
  DROP COLUMN csc_manufacture_date_verified,
  DROP COLUMN csc_approval_reference_verified,
  DROP COLUMN csc_plate_number_verified,
  DROP COLUMN maintenance_scheme_snapshot,
  DROP COLUMN racking_test_load_kg_snapshot,
  DROP COLUMN allowable_stacking_weight_kg_snapshot,
  DROP COLUMN cube_capacity_m3_snapshot,
  DROP COLUMN type_model_snapshot,
  DROP COLUMN manufacturer_serial_no_snapshot,
  DROP COLUMN manufacturer_name_snapshot,
  DROP COLUMN approval_category_name_snapshot,
  DROP COLUMN owner_name_snapshot;

ALTER TABLE container_technical_specs
  DROP CHECK chk_container_technical_specs_parent,
  DROP FOREIGN KEY fk_container_technical_specs_manufacturer,
  DROP FOREIGN KEY fk_container_technical_specs_job_container,
  DROP INDEX idx_container_technical_specs_manufacturer,
  DROP INDEX uq_container_technical_specs_job_container,
  DROP COLUMN manufacturer_id,
  DROP COLUMN job_container_id,
  MODIFY application_container_id CHAR(36) NOT NULL;

ALTER TABLE job_orders
  DROP CHECK chk_job_orders_owner_relationship,
  DROP FOREIGN KEY fk_job_orders_manufacturer,
  DROP FOREIGN KEY fk_job_orders_owner,
  DROP FOREIGN KEY fk_job_orders_approval_category,
  DROP INDEX idx_job_orders_manufacturer,
  DROP INDEX idx_job_orders_owner,
  DROP INDEX idx_job_orders_approval_category,
  DROP COLUMN special_notes,
  DROP COLUMN planned_inspection_date,
  DROP COLUMN manufacturer_id,
  DROP COLUMN applicant_owner_relationship,
  DROP COLUMN owner_id,
  DROP COLUMN approval_category_id;

ALTER TABLE customers
  DROP CHECK chk_customers_entity_type,
  DROP COLUMN admin_notes,
  DROP COLUMN country,
  DROP COLUMN entity_type;
