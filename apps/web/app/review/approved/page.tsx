import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyListPage } from "@/components/surveys/survey-list-page";

export default function ApprovedReviewPage() {
  return <ProtectedRoute><AppShell title="Approved Survey"><SurveyListPage title="Approved Survey" description="Riwayat survey yang sudah disetujui." endpoint="/reviews" fixedStatus="approved" /></AppShell></ProtectedRoute>;
}
