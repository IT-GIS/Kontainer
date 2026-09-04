-- Keep one active application flow: enrich Job, Job Container, and Survey snapshots
-- while reusing the existing fitness master and container_technical_specs foundation.

ALTER TABLE customers
  ADD COLUMN entity_type VARCHAR(30) NOT NULL DEFAULT 'business' AFTER customer_name,
  ADD COLUMN country VARCHAR(100) NULL AFTER address,
  ADD COLUMN admin_notes TEXT NULL AFTER payment_term_days,
  ADD CONSTRAINT chk_customers_entity_type CHECK (entity_type IN ('business','individual'));

ALTER TABLE job_orders
  ADD COLUMN approval_category_id CHAR(36) NULL AFTER customer_id,
  ADD COLUMN owner_id CHAR(36) NULL AFTER approval_category_id,
  ADD COLUMN applicant_owner_relationship VARCHAR(50) NULL AFTER owner_id,
  ADD COLUMN manufacturer_id CHAR(36) NULL AFTER applicant_owner_relationship,
  ADD COLUMN planned_inspection_date DATE NULL AFTER deadline,
  ADD COLUMN special_notes TEXT NULL AFTER instruction,
  ADD INDEX idx_job_orders_approval_category (approval_category_id),
  ADD INDEX idx_job_orders_owner (owner_id),
  ADD INDEX idx_job_orders_manufacturer (manufacturer_id),
  ADD CONSTRAINT fk_job_orders_approval_category FOREIGN KEY (approval_category_id) REFERENCES fitness_approval_categories(id),
  ADD CONSTRAINT fk_job_orders_owner FOREIGN KEY (owner_id) REFERENCES customers(id),
  ADD CONSTRAINT fk_job_orders_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES container_manufacturers(id),
  ADD CONSTRAINT chk_job_orders_owner_relationship CHECK (
    applicant_owner_relationship IS NULL OR applicant_owner_relationship IN ('owner','owner_representative','lessee','contracting_party','other')
  );

ALTER TABLE container_technical_specs
  MODIFY application_container_id CHAR(36) NULL,
  ADD COLUMN job_container_id CHAR(36) NULL AFTER application_container_id,
  ADD COLUMN manufacturer_id CHAR(36) NULL AFTER job_container_id,
  ADD UNIQUE INDEX uq_container_technical_specs_job_container (job_container_id),
  ADD INDEX idx_container_technical_specs_manufacturer (manufacturer_id),
  ADD CONSTRAINT fk_container_technical_specs_job_container FOREIGN KEY (job_container_id) REFERENCES job_containers(id),
  ADD CONSTRAINT fk_container_technical_specs_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES container_manufacturers(id),
  ADD CONSTRAINT chk_container_technical_specs_parent CHECK (
    (application_container_id IS NOT NULL AND job_container_id IS NULL)
    OR (application_container_id IS NULL AND job_container_id IS NOT NULL)
  );

ALTER TABLE survey_general_infos
  ADD COLUMN owner_name_snapshot VARCHAR(255) NULL AFTER customer_name_snapshot,
  ADD COLUMN approval_category_name_snapshot VARCHAR(255) NULL AFTER owner_name_snapshot,
  ADD COLUMN manufacturer_name_snapshot VARCHAR(255) NULL AFTER approval_category_name_snapshot,
  ADD COLUMN manufacturer_serial_no_snapshot VARCHAR(120) NULL AFTER manufacturer_name_snapshot,
  ADD COLUMN type_model_snapshot VARCHAR(150) NULL AFTER manufacturer_serial_no_snapshot,
  ADD COLUMN cube_capacity_m3_snapshot DECIMAL(12,3) NULL AFTER payload,
  ADD COLUMN allowable_stacking_weight_kg_snapshot DECIMAL(12,2) NULL AFTER cube_capacity_m3_snapshot,
  ADD COLUMN racking_test_load_kg_snapshot DECIMAL(12,2) NULL AFTER allowable_stacking_weight_kg_snapshot,
  ADD COLUMN maintenance_scheme_snapshot VARCHAR(100) NULL AFTER csc_program_type,
  ADD COLUMN csc_plate_number_verified VARCHAR(100) NULL AFTER csc_plate_number,
  ADD COLUMN csc_approval_reference_verified VARCHAR(150) NULL AFTER csc_approval_reference,
  ADD COLUMN csc_manufacture_date_verified DATE NULL AFTER csc_manufacture_date,
  ADD COLUMN csc_next_examination_date_verified DATE NULL AFTER csc_next_examination_date,
  ADD COLUMN csc_program_type_verified VARCHAR(50) NULL AFTER csc_program_type;
