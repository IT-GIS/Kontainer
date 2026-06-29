export type PendingReview = {
  survey_id: string;
  survey_no: string;
  job_order_no: string;
  container_no: string;
  customer_name: string;
  surveyor_name: string;
  survey_type_name: string;
  submitted_at?: string | null;
  status: string;
};

export type ReviewDetail = PendingReview & {
  id: string;
  location_name?: string;
  survey_result?: string | null;
  survey_result_recommendation?: string;
  general_info?: Record<string, unknown>;
  checklist?: Array<Record<string, unknown>>;
  damages?: Array<Record<string, unknown>>;
  photos?: Array<Record<string, unknown>>;
  approval_history?: Array<Record<string, unknown>>;
};

export type ReportSummary = {
  id: string;
  report_no: string;
  revision_no: number;
  job_order_no: string;
  survey_no: string;
  container_no: string;
  customer_name: string;
  status: string;
  qr_token?: string | null;
  created_at: string;
};

export type ReportDetail = ReportSummary & {
  report_type: string;
  current_version_no: number;
  updated_at?: string;
  versions?: ReportVersion[];
};

export type ReportVersion = {
  id: string;
  report_id: string;
  version_no: number;
  file_id?: string | null;
  change_reason?: string | null;
  status: string;
  created_at: string;
};
