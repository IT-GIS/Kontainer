export type SurveyorDashboard = {
  total_jobs: number;
  not_started: number;
  draft: number;
  submitted: number;
  need_revision: number;
  approved: number;
};

export type SurveyorJob = {
  id: string;
  job_order_no: string;
  customer_name: string;
  location_name: string;
  survey_type_name: string;
  total_containers: number;
  completed_containers: number;
  status: string;
  deadline?: string | null;
};

export type SurveyorContainer = {
  id: string;
  container_no: string;
  container_type_code?: string | null;
  seal_no?: string | null;
  cargo_status: string;
  survey_id?: string | null;
  survey_no?: string | null;
  status: string;
};

export type SurveyorJobDetail = SurveyorJob & {
  job_date?: string;
  priority?: string;
  instruction?: string | null;
  containers: SurveyorContainer[];
};

export type SurveyGeneralInfo = {
  survey_date_time?: string;
  cargo_status?: string;
  seal_no?: string | null;
  truck_no?: string | null;
  driver_name?: string | null;
  chassis_no?: string | null;
  csc_plate_status?: string | null;
  door_status?: string | null;
  general_condition?: string | null;
  weather?: string | null;
  general_remark?: string | null;
};

export type ChecklistItem = {
  item_key: string;
  item_label?: string;
  value?: string;
  note?: string;
  is_required?: boolean;
  is_critical?: boolean;
};

export type SurveyDamage = {
  id: string;
  damage_no: string;
  face: string;
  internal_location: string;
  component_id?: string;
  component_code?: string;
  component_name?: string;
  damage_code_id?: string;
  damage_code?: string;
  damage_name?: string;
  repair_code?: string | null;
  repair_name?: string | null;
  severity: string;
  quantity?: number | null;
  length?: number | null;
  width?: number | null;
  depth?: number | null;
  unit?: string;
  remark?: string | null;
  photo_count?: number;
};

export type SurveyPhoto = {
  id: string;
  survey_id: string;
  damage_id?: string | null;
  photo_type: string;
  photo_category?: string | null;
  caption?: string | null;
  object_key?: string;
  original_file_name?: string | null;
  created_at?: string;
};

export type SurveyDetail = {
  id: string;
  survey_no: string;
  status: string;
  job_order_no: string;
  container_no: string;
  customer_name: string;
  location_name: string;
  survey_type_name: string;
  surveyor_name: string;
  general_info?: SurveyGeneralInfo;
  checklist?: ChecklistItem[];
  damages?: SurveyDamage[];
  photos?: SurveyPhoto[];
  can_submit?: boolean;
  warnings?: SurveyWarning[];
  survey_result_recommendation?: string;
};

export type SurveyWarning = {
  code: string;
  message: string;
};

export type SheetLocation = {
  code: string;
  label: string;
  has_damage: boolean;
  damage_markers: Array<{ damage_id: string; damage_no: string; severity: string }>;
};

export type SheetFace = {
  face: string;
  label: string;
  locations: SheetLocation[];
};
