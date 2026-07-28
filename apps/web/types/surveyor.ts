export type SurveyorDashboard = {
  total_jobs: number;
  not_started: number;
  draft: number;
  submitted: number;
  need_revision: number;
  approved: number;
};

export type SurveyorSurveyListItem = {
  survey_id: string;
  survey_no: string;
  job_order_id: string;
  job_order_no: string;
  job_container_id: string;
  container_no: string;
  customer_name: string;
  location_name: string;
  survey_type_name: string;
  status: string;
  started_at?: string | null;
  submitted_at?: string | null;
  approved_at?: string | null;
  created_at?: string | null;
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
  assignment_no?: string | null;
  assignment_start_date?: string | null;
  assignment_due_date?: string | null;
  assignment_instruction?: string | null;
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
  container_lifecycle?: "new" | "existing" | null;
  weather?: string | null;
  general_remark?: string | null;
};

export type ChecklistItem = {
  item_key: string;
  item_label?: string;
  value?: string;
  numeric_value?: number | null;
  note?: string;
  response_type?: string;
  unit?: string | null;
  standard_reference?: string | null;
  requires_attachment?: boolean;
  attachment_file_id?: string | null;
  is_required?: boolean;
  is_critical?: boolean;
};

export type SurveyDamage = {
  id: string;
  damage_no: string;
  face: string;
  internal_location: string;
  cedex_location_id?: string | null;
  cedex_location_code?: string | null;
  manual_location_reason?: string | null;
  component_id?: string;
  component_code?: string;
  component_name?: string;
  damage_code_id?: string;
  damage_code?: string;
  damage_name?: string;
  repair_code?: string | null;
  repair_code_id?: string | null;
  repair_name?: string | null;
  material_code_id?: string | null;
  material_code?: string | null;
  material_name?: string | null;
  responsibility_code_id?: string | null;
  responsibility_code?: string | null;
  responsibility_name?: string | null;
  severity: string;
  quantity?: number | null;
  quantity_unit?: string | null;
  length?: number | null;
  width?: number | null;
  depth?: number | null;
  unit?: string;
  is_repair_required?: boolean;
  is_cargo_worthy_impact?: boolean;
  remark?: string | null;
  decision_rule_id?: string | null;
  decision_result?: string | null;
  decision_reason?: string | null;
  tolerance_snapshot?: Record<string, unknown> | string | null;
  finding_description?: string | null;
  inspection_reference_id?: string | null;
  inspection_reference_code?: string | null;
  inspection_reference_name?: string | null;
  inspection_standard_reference?: string | null;
  inspection_reference_clause?: string | null;
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
  watermarked_object_key?: string | null;
  content_url?: string;
  original_url?: string;
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
  customer_id?: string;
  survey_type_id?: string;
  container_type_id?: string | null;
  container_type_name?: string | null;
  container_type_code?: string | null;
  iso_type_code?: string | null;
  job_instruction?: string | null;
  job_deadline?: string | null;
  assignment_instruction?: string | null;
  assignment_due_at?: string | null;
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
  id: string;
  code: string;
  label: string;
  has_damage: boolean;
  damage_markers: Array<{ damage_id: string; damage_no: string; severity: string }>;
};

export type SurveyMasterOption = {
  id: string;
  code: string;
  name: string;
  description?: string | null;
  face?: string;
  grid_code?: string;
  container_size?: string | null;
  unit?: string | null;
  standard_reference?: string | null;
  applicable_face?: string | null;
  is_structural_critical?: boolean;
  damage_category?: string | null;
  default_severity?: string | null;
  requires_dimension?: boolean;
  default_action_id?: string | null;
  default_inspection_reference_id?: string | null;
  result_mapping?: string | null;
  requires_reinspection?: boolean;
  reference_type?: string | null;
  clause_section?: string | null;
};

export type SurveyMasterOptions = {
  customer: Record<string, unknown>;
  survey_type: Record<string, unknown>;
  container_type: Record<string, unknown>;
  cedex_locations: SurveyMasterOption[];
  cedex_components: SurveyMasterOption[];
  cedex_damages: SurveyMasterOption[];
  cedex_repairs: SurveyMasterOption[];
  cedex_materials: SurveyMasterOption[];
  responsibility_codes: SurveyMasterOption[];
  finding_severities: SurveyMasterOption[];
  test_parameters: SurveyMasterOption[];
  photo_categories: SurveyMasterOption[];
};

export type SheetFace = {
  face: string;
  label: string;
  locations: SheetLocation[];
};

export type DamageDecisionPreview = {
  configured: boolean;
  matched: boolean;
  requires_dimension: boolean;
  default_severity?: string;
  default_action_id?: string;
  default_inspection_reference_id?: string;
  decision_rule_id?: string;
  measurement_field?: string;
  measurement_value?: number;
  comparison_operator?: string;
  minimum_value?: number;
  maximum_value?: number;
  unit?: string;
  tolerance?: string;
  decision_result?: string;
  decision_reason?: string;
  recommended_action_id?: string;
  recommended_action_code?: string;
  recommended_action_name?: string;
  inspection_reference_id?: string;
  inspection_reference_code?: string;
  inspection_reference_name?: string;
  inspection_standard_reference?: string;
  inspection_reference_clause?: string;
};
