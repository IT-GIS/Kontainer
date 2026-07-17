import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientForm, FitnessMasterCompatibilityNotice } from "@/components/fitness/client-master-data/client-pages";
import { FitnessClientMasterCategoryWorkspace } from "@/components/fitness/client-master-data/client-master-workspace";
import { AppShell } from "@/components/layout/app-shell";
import { ErrorState } from "@/components/ui/error-state";
import { Skeleton } from "@/components/ui/skeleton";
import { fitnessMasterDataIndexHref, getFitnessMasterDataCategoryConfig } from "@/constants/fitness-master-data-client-first";
import { getFitnessClientLocations, getFitnessCustomerById, getFitnessCustomerMasterDataOverview, getFitnessMasterDataCategoryRecords } from "@/lib/fitness-client-master-data-mock-service";
import type { FitnessMasterDataCategory, FitnessMockMode } from "@/types/fitness-admin";
import { fitnessMasterDataCompatibility } from "../../../[[...slug]]/page";

export default async function FitnessMasterDataCategoryDetailPage({
  params,
  searchParams
}: {
  params: Promise<{ category: string; clientId: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const [{ category, clientId }, query] = await Promise.all([params, searchParams]);
  const config = getFitnessMasterDataCategoryConfig(category);
  const compatibility = fitnessMasterDataCompatibility["/fitness/master-data/" + category];
  if (!config) {
    return (
      <ProtectedRoute>
        <AppShell title={compatibility?.title ?? "Master Data tidak ditemukan"} subtitle="Compatibility route Admin Kelaikan" breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/master-data/customers" }, { label: compatibility?.title ?? category }]}>
          {compatibility ? <FitnessMasterCompatibilityNotice {...compatibility} /> : <ErrorState message="Kategori Master Data tidak dikenal." action={{ label: "Buka Customer", href: "/fitness/master-data/customers" }} />}
        </AppShell>
      </ProtectedRoute>
    );
  }

  const recordMode = mockMode(first(query.mockState));
  const [customerState, recordState, locationState, overviewState] = await Promise.all([
    getFitnessCustomerById(clientId),
    config.id === "customer" ? Promise.resolve(null) : getFitnessMasterDataCategoryRecords(clientId, config.id, recordMode),
    config.id === "surveyor" ? getFitnessClientLocations(clientId) : Promise.resolve(null),
    config.id === "customer" ? getFitnessCustomerMasterDataOverview(clientId) : Promise.resolve(null)
  ]);
  const customer = customerState.status === "success" ? customerState.data : null;
  const title = customer?.name ?? config.label;

  return (
    <ProtectedRoute>
      <AppShell title={title} subtitle={`${config.label} berdasarkan Customer aktif.`} breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/master-data/customers" }, { label: config.label, href: fitnessMasterDataIndexHref(config.id) }, { label: customer?.name ?? clientId }]}>
        {!customer ? <ErrorState message="clientId tidak ditemukan pada mock Customer." action={{ label: "Kembali ke Daftar Customer", href: fitnessMasterDataIndexHref(config.id) }} /> : null}
        {customer && config.id === "customer" ? <FitnessClientForm client={customer} overview={overviewState?.status === "success" ? overviewState.data ?? [] : []} /> : null}
        {customer && recordState?.status === "loading" ? <Skeleton variant="table" label={`Memuat ${config.label} ${customer.name}`} /> : null}
        {customer && recordState?.status === "error" ? <ErrorState message={recordState.error} action={{ label: "Kembali ke Daftar Customer", href: fitnessMasterDataIndexHref(config.id) }} /> : null}
        {customer && recordState?.status === "success" ? (
          <FitnessClientMasterCategoryWorkspace
            key={`${config.id}:${customer.id}`}
            client={customer}
            category={config.id as Exclude<FitnessMasterDataCategory, "customer">}
            records={recordState.data}
            locations={locationState?.status === "success" ? locationState.data : []}
          />
        ) : null}
        {customer && recordState?.status === "empty" ? (
          <FitnessClientMasterCategoryWorkspace key={`${config.id}:${customer.id}`} client={customer} category={config.id as Exclude<FitnessMasterDataCategory, "customer">} records={[]} locations={locationState?.status === "success" ? locationState.data : []} />
        ) : null}
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
