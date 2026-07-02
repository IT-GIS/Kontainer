ALTER TABLE survey_photos
  ADD COLUMN watermarked_file_id CHAR(36) NULL AFTER file_id,
  ADD INDEX idx_survey_photos_watermarked_file (watermarked_file_id);

ALTER TABLE job_orders
  ADD CONSTRAINT fk_job_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  ADD CONSTRAINT fk_job_orders_survey_type FOREIGN KEY (survey_type_id) REFERENCES survey_types(id),
  ADD CONSTRAINT fk_job_orders_location FOREIGN KEY (location_id) REFERENCES locations(id);

ALTER TABLE job_containers
  ADD CONSTRAINT fk_job_containers_job_order FOREIGN KEY (job_order_id) REFERENCES job_orders(id),
  ADD CONSTRAINT fk_job_containers_container_type FOREIGN KEY (container_type_id) REFERENCES container_types(id);

ALTER TABLE assignments
  ADD CONSTRAINT fk_assignments_job_order FOREIGN KEY (job_order_id) REFERENCES job_orders(id),
  ADD CONSTRAINT fk_assignments_surveyor FOREIGN KEY (surveyor_id) REFERENCES surveyor_profiles(id),
  ADD CONSTRAINT fk_assignments_assigned_by FOREIGN KEY (assigned_by) REFERENCES users(id);

ALTER TABLE assignment_containers
  ADD CONSTRAINT fk_assignment_containers_assignment FOREIGN KEY (assignment_id) REFERENCES assignments(id),
  ADD CONSTRAINT fk_assignment_containers_job_container FOREIGN KEY (job_container_id) REFERENCES job_containers(id);

ALTER TABLE surveys
  ADD CONSTRAINT fk_surveys_job_order FOREIGN KEY (job_order_id) REFERENCES job_orders(id),
  ADD CONSTRAINT fk_surveys_job_container FOREIGN KEY (job_container_id) REFERENCES job_containers(id),
  ADD CONSTRAINT fk_surveys_assignment FOREIGN KEY (assignment_id) REFERENCES assignments(id),
  ADD CONSTRAINT fk_surveys_surveyor FOREIGN KEY (surveyor_id) REFERENCES surveyor_profiles(id),
  ADD CONSTRAINT fk_surveys_survey_type FOREIGN KEY (survey_type_id) REFERENCES survey_types(id);

ALTER TABLE survey_general_infos
  ADD CONSTRAINT fk_survey_general_infos_survey FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
  ADD CONSTRAINT fk_survey_general_infos_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  ADD CONSTRAINT fk_survey_general_infos_location FOREIGN KEY (location_id) REFERENCES locations(id),
  ADD CONSTRAINT fk_survey_general_infos_container_type FOREIGN KEY (container_type_id) REFERENCES container_types(id);

ALTER TABLE survey_damages
  ADD CONSTRAINT fk_survey_damages_survey FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
  ADD CONSTRAINT fk_survey_damages_cedex_location FOREIGN KEY (cedex_location_id) REFERENCES cedex_locations(id),
  ADD CONSTRAINT fk_survey_damages_component FOREIGN KEY (component_id) REFERENCES cedex_components(id),
  ADD CONSTRAINT fk_survey_damages_damage FOREIGN KEY (damage_id) REFERENCES cedex_damages(id),
  ADD CONSTRAINT fk_survey_damages_repair FOREIGN KEY (repair_id) REFERENCES cedex_repairs(id),
  ADD CONSTRAINT fk_survey_damages_material FOREIGN KEY (material_id) REFERENCES cedex_materials(id),
  ADD CONSTRAINT fk_survey_damages_responsibility FOREIGN KEY (responsibility_id) REFERENCES responsibility_codes(id);

ALTER TABLE survey_photos
  ADD CONSTRAINT fk_survey_photos_survey FOREIGN KEY (survey_id) REFERENCES surveys(id) ON DELETE CASCADE,
  ADD CONSTRAINT fk_survey_photos_damage FOREIGN KEY (damage_id) REFERENCES survey_damages(id),
  ADD CONSTRAINT fk_survey_photos_file FOREIGN KEY (file_id) REFERENCES file_objects(id),
  ADD CONSTRAINT fk_survey_photos_watermarked_file FOREIGN KEY (watermarked_file_id) REFERENCES file_objects(id),
  ADD CONSTRAINT fk_survey_photos_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(id);

ALTER TABLE reports
  ADD CONSTRAINT fk_reports_job_order FOREIGN KEY (job_order_id) REFERENCES job_orders(id),
  ADD CONSTRAINT fk_reports_survey FOREIGN KEY (survey_id) REFERENCES surveys(id),
  ADD CONSTRAINT fk_reports_customer FOREIGN KEY (customer_id) REFERENCES customers(id);

ALTER TABLE invoice_items
  ADD CONSTRAINT fk_invoice_items_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
  ADD CONSTRAINT fk_invoice_items_report FOREIGN KEY (report_id) REFERENCES reports(id),
  ADD CONSTRAINT fk_invoice_items_survey FOREIGN KEY (survey_id) REFERENCES surveys(id);

ALTER TABLE payments
  ADD CONSTRAINT fk_payments_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code='survey_photos.view.assigned'
WHERE r.code IN ('admin','supervisor');
