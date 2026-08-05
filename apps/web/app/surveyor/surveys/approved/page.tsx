import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function ApprovedSurveysPage() {
	return <ProtectedRoute><AppShell title="Selesai"><SurveyorSurveyList title="Selesai" description="Survey yang telah Disetujui." fixedStatus="approved" /></AppShell></ProtectedRoute>;
}
