import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientForm } from "@/components/fitness/client-master-data/client-pages";
import { AppShell } from "@/components/layout/app-shell";
import { ErrorState } from "@/components/ui/error-state";
import { getFitnessClientById } from "@/lib/fitness-client-master-data-mock-service";

export default async function FitnessClientDetailPage({ params }: { params: Promise<{ clientId: string }> }) {
  const { clientId } = await params;
  const state = await getFitnessClientById(clientId);
  const client = state.status === "success" ? state.data : null;
  return (
    <ProtectedRoute>
      <AppShell title={client?.name ?? "Klien tidak ditemukan"} subtitle="Detail profil klien Sistem Kelaikan Peti Kemas." breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/clients" }, { label: "Daftar Klien", href: "/fitness/clients" }, { label: client?.name ?? clientId }]}>
        {client ? <FitnessClientForm client={client} /> : <ErrorState message="clientId tidak ditemukan pada mock UI-B.2." action={{ label: "Kembali ke Daftar Klien", href: "/fitness/clients" }} />}
      </AppShell>
    </ProtectedRoute>
  );
}
