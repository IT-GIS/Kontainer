import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function SubmittedSurveyPage() {
  return <ProtectedRoute><AppShell title="Submitted Survey"><SurveyListPage title="Submitted Survey" description="Survey yang menunggu proses review." endpoint="/surveys/monitoring" fixedStatus="submitted" /></AppShell></ProtectedRoute>;
}
