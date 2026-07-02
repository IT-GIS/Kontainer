export type SurveyListItem = {
  survey_id: string;
  survey_no: string;
  job_order_no: string;
  container_no: string;
  customer_name: string;
  location_name: string;
  survey_type_name: string;
  surveyor_name: string;
  status: string;
  started_at?: string | null;
  submitted_at?: string | null;
  approved_at?: string | null;
};
