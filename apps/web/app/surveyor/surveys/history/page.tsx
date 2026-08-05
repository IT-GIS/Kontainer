import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function SurveyHistoryPage() {
	return <ProtectedRoute><AppShell title="Riwayat"><SurveyorSurveyList title="Riwayat" description="Hanya survey terminal yang telah Disetujui atau Ditolak." fixedStatus="terminal" /></AppShell></ProtectedRoute>;
}
