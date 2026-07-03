import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function DraftSurveysPage() {
  return <ProtectedRoute><AppShell title="Draft Survey"><SurveyorSurveyList title="Draft Survey" description="Survey yang masih dapat dilengkapi." fixedStatus="draft" /></AppShell></ProtectedRoute>;
}
