export type PendingReview = {
  survey_id: string;
  survey_no: string;
  job_order_no: string;
  container_no: string;
  customer_name: string;
  surveyor_name: string;
  survey_type_name: string;
  submitted_at?: string | null;
  review_started_at?: string | null;
  resubmitted_at?: string | null;
  status: string;
	current_reviewer_id?: string | null;
	current_reviewer_name?: string | null;
	current_revision_no?: number;
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
  revision_history?: SurveyRevision[];
	revision_items?: SurveyRevisionItem[];
};

export type SurveyRevisionItem = {
	id: string;
	target_type: "survey" | "finding" | "checklist" | "photo";
	target_id?: string | null;
	category: string;
	note: string;
	due_at?: string | null;
	is_resolved: boolean;
	resolved_by_name?: string | null;
};

export type SurveyRevision = {
  id: string;
  survey_id: string;
  revision_no: number;
  revision_reason: string;
  requested_by: string;
	requested_by_name?: string | null;
  requested_at: string;
  resubmitted_by?: string | null;
	resubmitted_by_name?: string | null;
  resubmitted_at?: string | null;
  reviewer_note?: string | null;
  status: string;
  snapshot_before: Record<string, unknown> | string;
  snapshot_after?: Record<string, unknown> | string | null;
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
