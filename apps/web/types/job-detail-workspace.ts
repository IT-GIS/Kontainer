import type { ReportSummary, ReportVersion, ReviewDetail } from "@/types/reviews";
import type { SurveyListItem } from "@/types/surveys";

export type JobDetailSupportingData = {
  surveys: SurveyListItem[];
  reviews: ReviewDetail[];
  documents: ReportSummary[];
  versions: Record<string, ReportVersion[]>;
};

export type ContainerTypeOption = {
  id: string;
  label: string;
  code: string;
  isoCode: string;
};
