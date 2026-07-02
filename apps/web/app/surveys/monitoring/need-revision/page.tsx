import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function NeedRevisionMonitoringPage() {
  return <ProtectedRoute><AppShell title="Need Revision"><SurveyListPage title="Need Revision" description="Survey yang dikembalikan untuk diperbaiki." endpoint="/surveys/monitoring" fixedStatus="need_revision" /></AppShell></ProtectedRoute>;
}
