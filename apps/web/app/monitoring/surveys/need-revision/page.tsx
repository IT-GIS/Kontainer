import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function NeedRevisionSurveysPage() {
	return <ProtectedRoute><AppShell title="Perlu Revisi"><SurveyListPage title="Perlu Revisi" description="Survey yang dikembalikan kepada Surveyor dengan catatan revisi." endpoint="/surveys/monitoring" fixedStatus="need_revision" /></AppShell></ProtectedRoute>;
}
