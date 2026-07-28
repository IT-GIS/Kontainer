import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CustomerScopedMasterIndex } from "@/components/master/customer-scoped-master-data";
import { ErrorState } from "@/components/ui/error-state";
import { getFitnessMasterDataCategoryConfig } from "@/constants/fitness-master-data-client-first";

export default async function FitnessMasterDataCategoryPage({ params }: { params: Promise<{ category: string }> }) {
  const { category } = await params;
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
        subtitle="Master Data per Customer melalui API aktual."
        breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/master-data/customers" }, { label: config.label }]}
      >
        <CustomerScopedMasterIndex category={config.id} routeFamily="fitness" />
      </AppShell>
    </ProtectedRoute>
  );
}
