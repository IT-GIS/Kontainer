import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function SurveyHistoryPage() {
  return <ProtectedRoute><AppShell title="Riwayat Survey"><SurveyorSurveyList title="Riwayat Survey" description="Seluruh survey milik akun Surveyor ini." history /></AppShell></ProtectedRoute>;
}
