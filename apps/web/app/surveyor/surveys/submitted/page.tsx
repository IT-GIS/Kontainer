import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function SubmittedSurveysPage() {
  return <ProtectedRoute><AppShell title="Submitted Survey"><SurveyorSurveyList title="Submitted Survey" description="Survey yang menunggu review." fixedStatus="submitted" /></AppShell></ProtectedRoute>;
}
