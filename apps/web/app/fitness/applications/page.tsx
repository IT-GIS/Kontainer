import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessApplicationsList } from "@/components/fitness/applications/applications-list";
import { AppShell } from "@/components/layout/app-shell";
import { ErrorState } from "@/components/ui/error-state";
import { getFitnessClients } from "@/lib/fitness-client-master-data-mock-service";
import { getFitnessApplications } from "@/lib/fitness-dashboard-applications-mock-service";

export default async function FitnessApplicationsPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const [query, applicationState, clientState] = await Promise.all([searchParams, getFitnessApplications(), getFitnessClients()]);
  const ready = applicationState.status === "success" && clientState.status === "success";
  const initialFilters = Object.fromEntries(Object.entries(query).flatMap(([key, value]) => {
    const first = Array.isArray(value) ? value[0] : value;
    return first ? [[key, first]] : [];
  }));
  return <ProtectedRoute>
    <AppShell title="Permohonan" subtitle="Daftar Permohonan Kelaikan Peti Kemas." breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Permohonan" }]}>
      {ready ? <FitnessApplicationsList applications={applicationState.data} clients={clientState.data} initialFilters={initialFilters} /> : <ErrorState message="Daftar Permohonan mock belum dapat dimuat." />}
    </AppShell>
  </ProtectedRoute>;
}
