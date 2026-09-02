export type SurveySheetFieldSource = "Customer" | "Job" | "Peti Kemas" | "Sistem" | "Surveyor" | "Master CEDEX";

export function SurveySheetFieldSourceBadge({ source }: { source: SurveySheetFieldSource }) {
  return <span className={`survey-field-source-badge source-${source.toLowerCase().replaceAll(" ", "-")}`}>{source}</span>;
}
