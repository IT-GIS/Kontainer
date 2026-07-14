import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientsList, FitnessMasterCompatibilityNotice } from "@/components/fitness/client-master-data/client-pages";
import { MasterDataCustomerPicker, type MasterDataCustomerPickerItem } from "@/components/fitness/client-master-data/master-data-customer-picker";
import { AppShell } from "@/components/layout/app-shell";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Skeleton } from "@/components/ui/skeleton";
import { getFitnessMasterDataCategoryConfig } from "@/constants/fitness-master-data-client-first";
import { getFitnessCustomers, getMasterDataCategorySummary } from "@/lib/fitness-client-master-data-mock-service";
import type { FitnessMockMode } from "@/types/fitness-admin";
import { fitnessMasterDataCompatibility } from "../../[[...slug]]/page";

export default async function FitnessMasterDataCategoryPage({
  params,
  searchParams
}: {
  params: Promise<{ category: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const [{ category }, query] = await Promise.all([params, searchParams]);
  const config = getFitnessMasterDataCategoryConfig(category);
  const path = "/fitness/master-data/" + category;
  const compatibility = fitnessMasterDataCompatibility[path];

  if (!config) {
    return (
      <ProtectedRoute>
        <AppShell title={compatibility?.title ?? "Master Data tidak ditemukan"} subtitle="Compatibility route Admin Kelaikan" breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/master-data/customers" }, { label: compatibility?.title ?? category }]}>
          {compatibility ? <FitnessMasterCompatibilityNotice {...compatibility} /> : <ErrorState message="Kategori Master Data tidak dikenal." action={{ label: "Buka Customer", href: "/fitness/master-data/customers" }} />}
        </AppShell>
      </ProtectedRoute>
    );
  }

  const mode = mockMode(first(query.mockState));
  const customerState = await getFitnessCustomers(mode);
  let pickerItems: MasterDataCustomerPickerItem[] = [];
  if (config.id !== "customer" && customerState.status === "success") {
    const summaries = await Promise.all(customerState.data.map((customer) => getMasterDataCategorySummary(customer.id, config.id)));
    pickerItems = customerState.data.flatMap((customer, index) => {
      const summary = summaries[index];
      return summary.status === "success" && summary.data ? [{ customer, summary: summary.data }] : [];
    });
  }

  return (
    <ProtectedRoute>
      <AppShell title={config.label} subtitle="Master Data client-first berbasis Customer." breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/master-data/customers" }, { label: config.label }]}>
        {customerState.status === "loading" ? <Skeleton variant="table" label={`Memuat Customer untuk ${config.label}`} /> : null}
        {customerState.status === "error" ? <ErrorState message={customerState.error} /> : null}
        {customerState.status === "empty" ? <EmptyState title="Customer belum tersedia" description="Tambahkan Customer sebelum mengelola data turunannya." /> : null}
        {customerState.status === "success" && config.id === "customer" ? <FitnessClientsList initialClients={customerState.data} clientFirst /> : null}
        {customerState.status === "success" && config.id !== "customer" ? <MasterDataCustomerPicker config={config} items={pickerItems} /> : null}
      </AppShell>
    </ProtectedRoute>
  );
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}

function mockMode(value?: string): FitnessMockMode {
  return value === "loading" || value === "empty" || value === "error" ? value : "success";
}
