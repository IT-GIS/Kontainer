import type { JobDetail } from "@/types/jobs";
import type { ReportSummary, ReviewDetail } from "@/types/reviews";
import type { SurveyListItem } from "@/types/surveys";

export type InspectionWorkView =
  | "all"
  | "draft"
  | "unassigned"
  | "assigned"
  | "in-progress"
  | "submitted"
  | "need-revision"
  | "approved"
  | "rejected"
  | "completed";

export type InspectionWorkStage = Exclude<InspectionWorkView, "all">;

export type InspectionReadinessItem = {
  label: string;
  ready: boolean;
};

export type InspectionWorkRow = {
  id: string;
  job: JobDetail;
  surveys: SurveyListItem[];
  surveyDetails: ReviewDetail[];
  documents: ReportSummary[];
  stage: InspectionWorkStage;
  assignmentStatus: string;
  surveyorNames: string[];
  progressPercent: number;
  completedContainers: number;
  findingCount: number;
  photoCount: number;
  reviewStatus: string;
  documentStatus: string;
  lastUpdated: string;
  isOverdue: boolean;
  readiness: InspectionReadinessItem[];
};

export type InspectionWorkDataset = {
  rows: InspectionWorkRow[];
  warnings: string[];
};
