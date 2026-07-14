import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessApplicationCreateWorkspace } from "@/components/fitness/applications/application-create-workspace";
import { AppShell } from "@/components/layout/app-shell";
import { ErrorState } from "@/components/ui/error-state";
import { getFitnessClients } from "@/lib/fitness-client-master-data-mock-service";
import { getFitnessApplicationDraft } from "@/lib/fitness-dashboard-applications-mock-service";

export default async function FitnessApplicationCreatePage() {
  const [clientState, draftState] = await Promise.all([getFitnessClients(), getFitnessApplicationDraft()]);
  const ready = clientState.status === "success" && draftState.status === "success";
  return <ProtectedRoute>
    <AppShell title="Buat Permohonan" subtitle="Form bertahap berbasis Klien dan Master Data Klien." breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Permohonan", href: "/fitness/applications" }, { label: "Buat Permohonan" }]}>
      {ready ? <FitnessApplicationCreateWorkspace clients={clientState.data} initialDraft={draftState.data} /> : <ErrorState message="Form Permohonan mock belum dapat dimuat." />}
    </AppShell>
  </ProtectedRoute>;
}
