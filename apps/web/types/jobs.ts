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
};

export type JobDetail = JobSummary & {
  customer?: { id: string; customer_name: string };
  survey_type?: { id: string; name: string };
  location?: { id: string; location_name: string };
  containers?: JobContainer[];
  assignments?: AssignmentSummary[];
  timeline?: JobEvent[];
  instruction?: string | null;
  reference_no?: string | null;
  booking_no?: string | null;
  do_no?: string | null;
  bl_no?: string | null;
  vessel?: string | null;
  voyage?: string | null;
  trucking_company?: string | null;
  deadline?: string | null;
};

export type JobContainer = {
  id: string;
  container_no: string;
  check_digit_status: string;
  container_type_id?: string | null;
  container_type_code?: string | null;
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
  status: string;
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
};
