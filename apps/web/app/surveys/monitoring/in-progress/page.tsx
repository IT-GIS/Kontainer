import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function InProgressSurveyPage() {
  return <ProtectedRoute><AppShell title="Survey In Progress"><SurveyListPage title="Survey In Progress" description="Survey yang sudah dimulai dan belum disubmit." endpoint="/surveys/monitoring" fixedStatus="in_progress" /></AppShell></ProtectedRoute>;
}
