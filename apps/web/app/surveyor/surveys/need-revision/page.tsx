import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function RevisionSurveysPage() {
  return <ProtectedRoute><AppShell title="Need Revision"><SurveyorSurveyList title="Need Revision" description="Survey yang dikembalikan reviewer untuk diperbaiki." fixedStatus="need_revision" /></AppShell></ProtectedRoute>;
}
