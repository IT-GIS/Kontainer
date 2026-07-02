import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function ApprovedMonitoringPage() {
  return <ProtectedRoute><AppShell title="Approved Survey"><SurveyListPage title="Approved Survey" description="Survey yang sudah disetujui." endpoint="/surveys/monitoring" fixedStatus="approved" /></AppShell></ProtectedRoute>;
}
