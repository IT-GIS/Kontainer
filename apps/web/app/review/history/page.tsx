import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

const statuses = [
  { label: "Perlu Revisi", value: "need_revision" },
  { label: "Ditolak", value: "rejected" },
  { label: "Disetujui", value: "approved" }
];

export default function ReviewHistoryPage() {
  return <ProtectedRoute><AppShell title="Riwayat Keputusan"><SurveyListPage title="Riwayat Keputusan" description="Riwayat keputusan teknis, penolakan, dan permintaan revisi." endpoint="/reviews" statusOptions={statuses} /></AppShell></ProtectedRoute>;
}
