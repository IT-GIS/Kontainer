import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientPicker } from "@/components/fitness/client-master-data/client-pages";
import { AppShell } from "@/components/layout/app-shell";
import { ErrorState } from "@/components/ui/error-state";
import { getFitnessClients } from "@/lib/fitness-client-master-data-mock-service";

export default async function FitnessClientMasterPickerPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const query = await searchParams;
  const targetTab = first(query.targetTab) ?? "summary";
  const targetSection = first(query.targetSection);
  const state = await getFitnessClients();
  return (
    <ProtectedRoute>
      <AppShell title="Master Data Klien" subtitle="Pilih klien sebelum membuka lokasi, personel, jenis, dan referensi." breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/clients" }, { label: "Master Data Klien" }]}>
        {state.status === "success" ? <FitnessClientPicker clients={state.data} targetTab={targetTab} targetSection={targetSection} /> : <ErrorState message="Daftar klien belum dapat dimuat." />}
      </AppShell>
    </ProtectedRoute>
  );
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
