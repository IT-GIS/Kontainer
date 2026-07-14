import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientForm } from "@/components/fitness/client-master-data/client-pages";
import { AppShell } from "@/components/layout/app-shell";

export default function FitnessClientCreatePage() {
  return (
    <ProtectedRoute>
      <AppShell title="Tambah Klien" subtitle="Siapkan profil klien untuk layanan inspeksi GIFT." breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/clients" }, { label: "Daftar Klien", href: "/fitness/clients" }, { label: "Tambah Klien" }]}>
        <FitnessClientForm />
      </AppShell>
    </ProtectedRoute>
  );
}
