import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function SurveyorsPage() {
  return (
    <ProtectedRoute>
      <AppShell
        title="Surveyor GIFT"
        subtitle="Surveyor internal GIFT yang terhubung ke akun aplikasi; terpisah dari Personel/PIC Customer."
        breadcrumbs={[{ label: "Pengaturan" }, { label: "Surveyor GIFT" }]}
      >
        <MasterDataPage resourceId="surveyors" />
      </AppShell>
    </ProtectedRoute>
  );
}
