-- Compatibility patch for installations that already applied 0024.
-- Keep in sync with services/api/migrations/0019_survey_sheet_data_flow.up.sql.

ALTER TABLE survey_general_infos
  ADD COLUMN customer_name_snapshot VARCHAR(255) NULL AFTER location_id,
  ADD COLUMN location_name_snapshot VARCHAR(255) NULL AFTER customer_name_snapshot,
  ADD COLUMN survey_type_name_snapshot VARCHAR(255) NULL AFTER location_name_snapshot,
  ADD COLUMN job_order_no_snapshot VARCHAR(100) NULL AFTER survey_type_name_snapshot,
  ADD COLUMN spk_no_snapshot VARCHAR(100) NULL AFTER job_order_no_snapshot,
  ADD COLUMN container_type_code_snapshot VARCHAR(50) NULL AFTER spk_no_snapshot,
  ADD COLUMN container_type_name_snapshot VARCHAR(255) NULL AFTER container_type_code_snapshot,
  ADD COLUMN container_size_snapshot VARCHAR(30) NULL AFTER container_type_name_snapshot,
  ADD COLUMN manufacture_date DATE NULL AFTER container_size_snapshot,
  ADD COLUMN gross_weight DECIMAL(12,2) NULL AFTER manufacture_date,
  ADD COLUMN tare_weight DECIMAL(12,2) NULL AFTER gross_weight,
  ADD COLUMN payload DECIMAL(12,2) NULL AFTER tare_weight,
  ADD COLUMN cargo_status_initial VARCHAR(30) NULL AFTER cargo_status,
  ADD COLUMN csc_plate_status_initial VARCHAR(30) NULL AFTER csc_plate_status,
  ADD COLUMN csc_plate_number VARCHAR(100) NULL AFTER csc_plate_status_initial,
  ADD COLUMN csc_approval_reference VARCHAR(150) NULL AFTER csc_plate_number,
  ADD COLUMN csc_manufacture_date DATE NULL AFTER csc_approval_reference,
  ADD COLUMN csc_next_examination_date DATE NULL AFTER csc_manufacture_date,
  ADD COLUMN csc_program_type VARCHAR(50) NULL AFTER csc_next_examination_date,
  ADD COLUMN cleanliness VARCHAR(10) NULL AFTER general_condition;

UPDATE survey_general_infos info
JOIN surveys survey ON survey.id=info.survey_id
JOIN job_orders job ON job.id=survey.job_order_id
JOIN job_containers container ON container.id=survey.job_container_id
JOIN customers customer ON customer.id=job.customer_id
JOIN locations location ON location.id=job.location_id
JOIN survey_types survey_type ON survey_type.id=survey.survey_type_id
LEFT JOIN container_types container_type ON container_type.id=container.container_type_id
SET info.customer_name_snapshot=COALESCE(info.customer_name_snapshot,customer.customer_name),
    info.location_name_snapshot=COALESCE(info.location_name_snapshot,location.location_name),
    info.survey_type_name_snapshot=COALESCE(info.survey_type_name_snapshot,survey_type.name),
    info.job_order_no_snapshot=COALESCE(info.job_order_no_snapshot,job.job_order_no),
    info.spk_no_snapshot=COALESCE(info.spk_no_snapshot,job.spk_no),
    info.container_type_code_snapshot=COALESCE(info.container_type_code_snapshot,container_type.code),
    info.container_type_name_snapshot=COALESCE(info.container_type_name_snapshot,container_type.type_name),
    info.container_size_snapshot=COALESCE(info.container_size_snapshot,container_type.size),
    info.manufacture_date=COALESCE(info.manufacture_date,container.manufacture_date),
    info.gross_weight=COALESCE(info.gross_weight,container.gross_weight),
    info.tare_weight=COALESCE(info.tare_weight,container.tare_weight),
    info.payload=COALESCE(info.payload,container.payload),
    info.cargo_status_initial=COALESCE(info.cargo_status_initial,container.cargo_status),
    info.csc_plate_status_initial=COALESCE(info.csc_plate_status_initial,container.csc_plate_status),
    info.csc_plate_number=COALESCE(info.csc_plate_number,container.csc_plate_number),
    info.csc_approval_reference=COALESCE(info.csc_approval_reference,container.csc_approval_reference),
    info.csc_manufacture_date=COALESCE(info.csc_manufacture_date,container.csc_manufacture_date),
    info.csc_next_examination_date=COALESCE(info.csc_next_examination_date,container.csc_next_examination_date),
    info.csc_program_type=COALESCE(info.csc_program_type,container.csc_program_type);
