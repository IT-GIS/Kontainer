import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

const statuses = [
  { label: "Need Revision", value: "need_revision" },
  { label: "Rejected", value: "rejected" },
  { label: "Approved", value: "approved" }
];

export default function ReviewHistoryPage() {
  return <ProtectedRoute><AppShell title="Review History"><SurveyListPage title="Review History" description="Riwayat keputusan review survey." endpoint="/reviews" statusOptions={statuses} /></AppShell></ProtectedRoute>;
}
