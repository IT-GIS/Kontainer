import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessDashboardWorkspace } from "@/components/fitness/dashboard/dashboard-workspace";
import { AppShell } from "@/components/layout/app-shell";
import { ErrorState } from "@/components/ui/error-state";
import { getFitnessClients } from "@/lib/fitness-client-master-data-mock-service";
import { getFitnessDashboardSnapshot } from "@/lib/fitness-dashboard-applications-mock-service";

export default async function FitnessDashboardPage() {
  const [dashboardState, clientState] = await Promise.all([getFitnessDashboardSnapshot(), getFitnessClients()]);
  const ready = dashboardState.status === "success" && clientState.status === "success";
  return <ProtectedRoute>
    <AppShell title="Dashboard" subtitle="Pusat tindakan Admin Kelaikan GIFT." breadcrumbs={[{ label: "Admin Kelaikan" }, { label: "Dashboard" }]}>
      {ready ? <FitnessDashboardWorkspace initialSnapshot={dashboardState.data} clients={clientState.data} /> : <ErrorState message="Dashboard mock belum dapat dimuat." />}
    </AppShell>
  </ProtectedRoute>;
}
