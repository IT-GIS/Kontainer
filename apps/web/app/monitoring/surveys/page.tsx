import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function AllSurveysPage() {
	return <ProtectedRoute><AppShell title="Monitoring Survey"><SurveyListPage title="Monitoring Survey" description="Pantau progres survey per container, reviewer aktif, revisi, dan keputusan teknis." endpoint="/surveys/monitoring" statusOptions={[
		{ label: "Semua Status", value: "" },
		{ label: "Sedang Dikerjakan", value: "in_progress" },
		{ label: "Terkirim", value: "submitted" },
		{ label: "Dalam Review", value: "under_review" },
		{ label: "Perlu Revisi", value: "need_revision" },
		{ label: "Dikirim Ulang", value: "resubmitted" },
		{ label: "Disetujui", value: "approved" },
		{ label: "Ditolak", value: "rejected" },
	]} /></AppShell></ProtectedRoute>;
}
