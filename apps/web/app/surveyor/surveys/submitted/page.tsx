import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function SubmittedSurveysPage() {
	return <ProtectedRoute><AppShell title="Terkirim & Dalam Review"><SurveyorSurveyList title="Terkirim & Dalam Review" description="Survey yang telah dikirim, sedang direview, atau dikirim ulang." fixedStatus="submitted" /></AppShell></ProtectedRoute>;
}
