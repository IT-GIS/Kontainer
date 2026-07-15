import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientForm } from "@/components/fitness/client-master-data/client-pages";
import { AppShell } from "@/components/layout/app-shell";

export default function FitnessCustomerCreatePage() {
  return (
    <ProtectedRoute>
      <AppShell title="Tambah Customer" subtitle="Daftarkan perusahaan atau organisasi pengguna jasa." breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/master-data/customers" }, { label: "Customer", href: "/fitness/master-data/customers" }, { label: "Tambah Customer" }]}>
        <FitnessClientForm />
      </AppShell>
    </ProtectedRoute>
  );
}
