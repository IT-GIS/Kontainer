export type JobSummary = {
  id: string;
  job_order_no: string;
  job_date: string;
  priority: string;
  status: string;
  customer_id: string;
  customer_name: string;
  survey_type_id: string;
  survey_type_name: string;
  location_id: string;
  location_name: string;
  total_containers: number;
  created_at: string;
  updated_at?: string;
};

export type JobDetail = JobSummary & {
  customer?: { id: string; customer_name: string };
  survey_type?: { id: string; name: string };
  location?: { id: string; location_name: string };
  containers?: JobContainer[];
  assignments?: AssignmentSummary[];
  timeline?: JobEvent[];
  instruction?: string | null;
  pic_customer_name?: string | null;
  pic_customer_phone?: string | null;
  pic_customer_email?: string | null;
  reference_no?: string | null;
	approval_category_id?: string | null;
	approval_category_name?: string | null;
	owner_id?: string | null;
	owner_name?: string | null;
	applicant_owner_relationship?: string | null;
	manufacturer_id?: string | null;
	manufacturer_name?: string | null;
  spk_no?: string | null;
  spk_date?: string | null;
  spk_file_id?: string | null;
  spk_notes?: string | null;
  booking_no?: string | null;
  do_no?: string | null;
  bl_no?: string | null;
  vessel?: string | null;
  voyage?: string | null;
  trucking_company?: string | null;
  deadline?: string | null;
	planned_inspection_date?: string | null;
	special_notes?: string | null;
	spk_file_name?: string | null;
	spk_mime_type?: string | null;
	spk_file_size?: number | null;
};

export type InspectionReadinessCheck = { code: string; label: string; ready: boolean };
export type InspectionReadiness = {
	job_id: string;
	container_id: string;
	container_no: string;
	status: "BLOCKED" | "READY_WITH_WARNINGS" | "READY";
	blockers: InspectionReadinessCheck[];
	warnings: InspectionReadinessCheck[];
};

export type JobContainer = {
  id: string;
  container_no: string;
  check_digit_status: string;
  container_type_id?: string | null;
  container_type_code?: string | null;
	container_size?: string | null;
  iso_type_code?: string | null;
  seal_no?: string | null;
  cargo_status: string;
  gross_weight?: number | null;
  tare_weight?: number | null;
  payload?: number | null;
  manufacture_date?: string | null;
  check_digit_override_reason?: string | null;
  truck_no?: string | null;
  driver_name?: string | null;
  csc_plate_status?: string | null;
	csc_plate_number?: string | null;
	csc_approval_reference?: string | null;
	csc_manufacture_date?: string | null;
	csc_next_examination_date?: string | null;
	csc_program_type?: string | null;
	manufacturer_id?: string | null;
	manufacturer_name?: string | null;
	manufacturer_serial_no?: string | null;
	type_model?: string | null;
	cube_capacity_m3?: number | null;
	allowable_stacking_weight_kg?: number | null;
	racking_test_load_kg?: number | null;
	maintenance_scheme_id?: string | null;
	maintenance_scheme_name?: string | null;
	container_number_input?: string | null;
	container_check_digit_calculated?: string | null;
	container_check_digit_valid?: boolean | null;
	check_digit_override_by?: string | null;
	check_digit_override_at?: string | null;
  remark?: string | null;
  status: string;
	inspection_readiness: InspectionReadiness;
};

export type AssignmentSummary = {
  id: string;
  assignment_no: string;
  surveyor_id: string;
  surveyor_name: string;
  status: string;
  assigned_at: string;
  start_date?: string | null;
  due_date?: string | null;
  instruction?: string | null;
  total_containers: number;
};

export type JobEvent = {
  id: string;
  event: string;
  event_title: string;
  description?: string | null;
  actor?: string | null;
  created_at: string;
};

export type OptionItem = {
  id: string;
  label: string;
  code?: string;
  applies_to?: string | null;
};
