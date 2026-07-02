import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function NeedRevisionReviewPage() {
  return <ProtectedRoute><AppShell title="Need Revision"><SurveyListPage title="Need Revision" description="Riwayat survey yang dikembalikan untuk revisi." endpoint="/reviews" fixedStatus="need_revision" /></AppShell></ProtectedRoute>;
}
