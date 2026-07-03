import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function ApprovedSurveysPage() {
  return <ProtectedRoute><AppShell title="Approved Survey"><SurveyorSurveyList title="Approved Survey" description="Survey yang telah disetujui." fixedStatus="approved" /></AppShell></ProtectedRoute>;
}
