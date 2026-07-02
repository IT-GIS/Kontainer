import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

const statuses = [
  { label: "All Status", value: "" },
  { label: "In Progress", value: "in_progress" },
  { label: "Submitted", value: "submitted" },
  { label: "Need Revision", value: "need_revision" },
  { label: "Approved", value: "approved" }
];

export default function MonitoringSurveyPage() {
  return <ProtectedRoute><AppShell title="All Survey"><SurveyListPage title="All Survey" description="Monitoring seluruh survey operasional." endpoint="/surveys/monitoring" statusOptions={statuses} /></AppShell></ProtectedRoute>;
}
