import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientsList } from "@/components/fitness/client-master-data/client-pages";
import { AppShell } from "@/components/layout/app-shell";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { getFitnessClients } from "@/lib/fitness-client-master-data-mock-service";

export default async function FitnessClientsPage() {
  const state = await getFitnessClients();
  return (
    <ProtectedRoute>
      <AppShell title="Klien & Master Data" subtitle="Kelola klien dan data referensi yang terisolasi per klien." breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data" }, { label: "Daftar Klien" }]}>
        {state.status === "error" ? <ErrorState message={state.error} /> : state.status === "success" ? <FitnessClientsList initialClients={state.data} /> : <EmptyState title="Klien belum tersedia" description="Belum ada data mock klien untuk ditampilkan." />}
      </AppShell>
    </ProtectedRoute>
  );
}
