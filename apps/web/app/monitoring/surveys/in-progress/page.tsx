import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function InProgressSurveysPage() {
	return <ProtectedRoute><AppShell title="Sedang Dikerjakan"><SurveyListPage title="Sedang Dikerjakan" description="Survey aktif yang masih diselesaikan Surveyor." endpoint="/surveys/monitoring" fixedStatus="in_progress" /></AppShell></ProtectedRoute>;
}
