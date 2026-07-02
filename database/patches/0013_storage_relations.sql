-- Tahap 3: photo derivative storage and core operational foreign keys.
-- Re-runnable. A foreign key is skipped (with a warning row) when legacy orphan data exists.

SET @has_watermarked_file_id = (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema=DATABASE() AND table_name='survey_photos' AND column_name='watermarked_file_id'
);
SET @stage3_sql = IF(
  @has_watermarked_file_id = 0,
  'ALTER TABLE survey_photos ADD COLUMN watermarked_file_id CHAR(36) NULL AFTER file_id',
  'SELECT 1'
);
PREPARE stage3_stmt FROM @stage3_sql;
EXECUTE stage3_stmt;
DEALLOCATE PREPARE stage3_stmt;

SET @has_watermarked_file_index = (
  SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema=DATABASE() AND table_name='survey_photos' AND index_name='idx_survey_photos_watermarked_file'
);
SET @stage3_sql = IF(
  @has_watermarked_file_index = 0,
  'ALTER TABLE survey_photos ADD INDEX idx_survey_photos_watermarked_file (watermarked_file_id)',
  'SELECT 1'
);
PREPARE stage3_stmt FROM @stage3_sql;
EXECUTE stage3_stmt;
DEALLOCATE PREPARE stage3_stmt;

DROP PROCEDURE IF EXISTS stage3_add_fk;
DELIMITER $$
CREATE PROCEDURE stage3_add_fk(
  IN p_table VARCHAR(64), IN p_column VARCHAR(64), IN p_constraint VARCHAR(64),
  IN p_parent_table VARCHAR(64), IN p_parent_column VARCHAR(64), IN p_on_delete VARCHAR(32)
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.key_column_usage
    WHERE table_schema=DATABASE() AND table_name=p_table AND column_name=p_column
      AND referenced_table_name IS NOT NULL
  ) THEN
    SET @stage3_orphans = 0;
    SET @stage3_check = CONCAT(
      'SELECT COUNT(*) INTO @stage3_orphans FROM `', p_table, '` child_row ',
      'LEFT JOIN `', p_parent_table, '` parent_row ON child_row.`', p_column,
      '`=parent_row.`', p_parent_column, '` WHERE child_row.`', p_column,
      '` IS NOT NULL AND parent_row.`', p_parent_column, '` IS NULL'
    );
    PREPARE stage3_check_stmt FROM @stage3_check;
    EXECUTE stage3_check_stmt;
    DEALLOCATE PREPARE stage3_check_stmt;

    IF @stage3_orphans = 0 THEN
      SET @stage3_alter = CONCAT(
        'ALTER TABLE `', p_table, '` ADD CONSTRAINT `', p_constraint,
        '` FOREIGN KEY (`', p_column, '`) REFERENCES `', p_parent_table,
        '` (`', p_parent_column, '`)', p_on_delete
      );
      PREPARE stage3_alter_stmt FROM @stage3_alter;
      EXECUTE stage3_alter_stmt;
      DEALLOCATE PREPARE stage3_alter_stmt;
    ELSE
      SELECT CONCAT('Skipped ', p_constraint, ': ', @stage3_orphans, ' orphan row(s)') AS stage3_warning;
    END IF;
  END IF;
END$$
DELIMITER ;

CALL stage3_add_fk('job_orders','customer_id','fk_job_orders_customer','customers','id','');
CALL stage3_add_fk('job_orders','survey_type_id','fk_job_orders_survey_type','survey_types','id','');
CALL stage3_add_fk('job_orders','location_id','fk_job_orders_location','locations','id','');
CALL stage3_add_fk('job_containers','job_order_id','fk_job_containers_job_order','job_orders','id','');
CALL stage3_add_fk('job_containers','container_type_id','fk_job_containers_container_type','container_types','id','');
CALL stage3_add_fk('assignments','job_order_id','fk_assignments_job_order','job_orders','id','');
CALL stage3_add_fk('assignments','surveyor_id','fk_assignments_surveyor','surveyor_profiles','id','');
CALL stage3_add_fk('assignments','assigned_by','fk_assignments_assigned_by','users','id','');
CALL stage3_add_fk('assignment_containers','assignment_id','fk_assignment_containers_assignment','assignments','id','');
CALL stage3_add_fk('assignment_containers','job_container_id','fk_assignment_containers_job_container','job_containers','id','');
CALL stage3_add_fk('surveys','job_order_id','fk_surveys_job_order','job_orders','id','');
CALL stage3_add_fk('surveys','job_container_id','fk_surveys_job_container','job_containers','id','');
CALL stage3_add_fk('surveys','assignment_id','fk_surveys_assignment','assignments','id','');
CALL stage3_add_fk('surveys','surveyor_id','fk_surveys_surveyor','surveyor_profiles','id','');
CALL stage3_add_fk('surveys','survey_type_id','fk_surveys_survey_type','survey_types','id','');
CALL stage3_add_fk('survey_general_infos','survey_id','fk_survey_general_infos_survey','surveys','id',' ON DELETE CASCADE');
CALL stage3_add_fk('survey_general_infos','customer_id','fk_survey_general_infos_customer','customers','id','');
CALL stage3_add_fk('survey_general_infos','location_id','fk_survey_general_infos_location','locations','id','');
CALL stage3_add_fk('survey_general_infos','container_type_id','fk_survey_general_infos_container_type','container_types','id','');
CALL stage3_add_fk('survey_damages','survey_id','fk_survey_damages_survey','surveys','id',' ON DELETE CASCADE');
CALL stage3_add_fk('survey_damages','cedex_location_id','fk_survey_damages_cedex_location','cedex_locations','id','');
CALL stage3_add_fk('survey_damages','component_id','fk_survey_damages_component','cedex_components','id','');
CALL stage3_add_fk('survey_damages','damage_id','fk_survey_damages_damage','cedex_damages','id','');
CALL stage3_add_fk('survey_damages','repair_id','fk_survey_damages_repair','cedex_repairs','id','');
CALL stage3_add_fk('survey_damages','material_id','fk_survey_damages_material','cedex_materials','id','');
CALL stage3_add_fk('survey_damages','responsibility_id','fk_survey_damages_responsibility','responsibility_codes','id','');
CALL stage3_add_fk('survey_photos','survey_id','fk_survey_photos_survey','surveys','id',' ON DELETE CASCADE');
CALL stage3_add_fk('survey_photos','damage_id','fk_survey_photos_damage','survey_damages','id','');
CALL stage3_add_fk('survey_photos','file_id','fk_survey_photos_file','file_objects','id','');
CALL stage3_add_fk('survey_photos','watermarked_file_id','fk_survey_photos_watermarked_file','file_objects','id','');
CALL stage3_add_fk('survey_photos','uploaded_by','fk_survey_photos_uploaded_by','users','id','');
CALL stage3_add_fk('reports','job_order_id','fk_reports_job_order','job_orders','id','');
CALL stage3_add_fk('reports','survey_id','fk_reports_survey','surveys','id','');
CALL stage3_add_fk('reports','customer_id','fk_reports_customer','customers','id','');
CALL stage3_add_fk('invoice_items','invoice_id','fk_invoice_items_invoice','invoices','id',' ON DELETE CASCADE');
CALL stage3_add_fk('invoice_items','report_id','fk_invoice_items_report','reports','id','');
CALL stage3_add_fk('invoice_items','survey_id','fk_invoice_items_survey','surveys','id','');
CALL stage3_add_fk('payments','invoice_id','fk_payments_invoice','invoices','id','');

DROP PROCEDURE stage3_add_fk;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code='survey_photos.view.assigned'
WHERE r.code IN ('admin','supervisor');
