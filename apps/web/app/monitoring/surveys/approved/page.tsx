import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function ApprovedSurveysPage() {
	return <ProtectedRoute><AppShell title="Survey Disetujui"><SurveyListPage title="Survey Disetujui" description="Survey dengan keputusan teknis final Approved." endpoint="/surveys/monitoring" fixedStatus="approved" /></AppShell></ProtectedRoute>;
}
