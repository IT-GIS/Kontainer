import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CustomerScopedMasterDetail } from "@/components/master/customer-scoped-master-data";
import { ErrorState } from "@/components/ui/error-state";
import { fitnessMasterDataIndexHref, getFitnessMasterDataCategoryConfig } from "@/constants/fitness-master-data-client-first";

export default async function FitnessMasterDataCategoryDetailPage({ params }: { params: Promise<{ category: string; clientId: string }> }) {
  const { category, clientId } = await params;
  const config = getFitnessMasterDataCategoryConfig(category);

  if (!config) {
    return (
      <ProtectedRoute>
        <AppShell title="Master Data tidak ditemukan" subtitle="Admin Kelaikan">
          <ErrorState message="Kategori Master Data tidak dikenal." action={{ label: "Buka Customer", href: "/fitness/master-data/customers" }} />
        </AppShell>
      </ProtectedRoute>
    );
  }

  return (
    <ProtectedRoute>
      <AppShell
        title={config.label}
        subtitle="Customer terkunci dari route; CRUD tersimpan melalui API customer-scoped."
        breadcrumbs={[
          { label: "Admin Kelaikan", href: "/fitness/dashboard" },
          { label: "Klien & Master Data", href: "/fitness/master-data/customers" },
          { label: config.label, href: fitnessMasterDataIndexHref(config.id) },
          { label: "Detail Customer" }
        ]}
      >
        <CustomerScopedMasterDetail category={config.id} customerId={clientId} routeFamily="fitness" />
      </AppShell>
    </ProtectedRoute>
  );
}
