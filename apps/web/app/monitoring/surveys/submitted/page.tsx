import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function SubmittedSurveysPage() {
	return <ProtectedRoute><AppShell title="Terkirim & Dalam Review"><SurveyListPage title="Terkirim & Dalam Review" description="Survey yang menunggu atau sedang melalui review teknis." endpoint="/surveys/monitoring" fixedStatus="submitted" /></AppShell></ProtectedRoute>;
}
