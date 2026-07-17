import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientForm, FitnessClientsList } from "@/components/fitness/client-master-data/client-pages";
import { FitnessClientMasterCategoryWorkspace } from "@/components/fitness/client-master-data/client-master-workspace";
import { MasterDataCustomerPicker, type MasterDataCustomerPickerItem } from "@/components/fitness/client-master-data/master-data-customer-picker";
import { AppShell } from "@/components/layout/app-shell";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { Skeleton } from "@/components/ui/skeleton";
import { getFitnessMasterDataCategoryConfigByID, masterDataIndexHref } from "@/constants/fitness-master-data-client-first";
import {
  getFitnessClientLocations,
  getFitnessCustomerById,
  getFitnessCustomerMasterDataOverview,
  getFitnessCustomers,
  getFitnessMasterDataCategoryRecords,
  getMasterDataCategorySummary
} from "@/lib/fitness-client-master-data-mock-service";
import type { FitnessMasterDataCategory, FitnessMockMode } from "@/types/fitness-admin";

type ActualMasterDataIndexProps = {
  category: FitnessMasterDataCategory;
  mockState?: string;
};

type ActualMasterDataDetailProps = ActualMasterDataIndexProps & {
  customerId: string;
};

export type ActualMasterDataSearchParams = Promise<Record<string, string | string[] | undefined>>;

export async function ActualMasterDataIndexRoute({ category, searchParams }: { category: FitnessMasterDataCategory; searchParams: ActualMasterDataSearchParams }) {
  const query = await searchParams;
  return <ActualMasterDataIndex category={category} mockState={first(query.mockState)} />;
}

export async function ActualMasterDataDetailRoute({ category, customerId, searchParams }: { category: FitnessMasterDataCategory; customerId: string; searchParams: ActualMasterDataSearchParams }) {
  const query = await searchParams;
  return <ActualMasterDataDetail category={category} customerId={customerId} mockState={first(query.mockState)} />;
}

export async function ActualMasterDataIndex({ category, mockState }: ActualMasterDataIndexProps) {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  const customerState = await getFitnessCustomers(mockMode(mockState));
  let pickerItems: MasterDataCustomerPickerItem[] = [];

  if (category !== "customer" && customerState.status === "success") {
    const summaries = await Promise.all(customerState.data.map((customer) => getMasterDataCategorySummary(customer.id, category)));
    pickerItems = customerState.data.flatMap((customer, index) => {
      const summary = summaries[index];
      return summary.status === "success" && summary.data ? [{ customer, summary: summary.data }] : [];
    });
  }

  return (
    <ProtectedRoute>
      <AppShell
        title={config.label}
        subtitle="Master Data customer-first pada route aplikasi aktual."
        breadcrumbs={[{ label: "Master Data" }, { label: config.label }]}
      >
        {customerState.status === "loading" ? <Skeleton variant="table" label={`Memuat Customer untuk ${config.label}`} /> : null}
        {customerState.status === "error" ? <ErrorState message={customerState.error} /> : null}
        {customerState.status === "empty" ? <EmptyState title="Customer belum tersedia" description="Tambahkan Customer sebelum mengelola data turunannya." /> : null}
        {customerState.status === "success" && category === "customer" ? <FitnessClientsList initialClients={customerState.data} routeFamily="actual" /> : null}
        {customerState.status === "success" && category !== "customer" ? (
          <MasterDataCustomerPicker config={config} items={pickerItems} routeFamily="actual" />
        ) : null}
      </AppShell>
    </ProtectedRoute>
  );
}

export async function ActualMasterDataDetail({ category, customerId, mockState }: ActualMasterDataDetailProps) {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  const recordMode = mockMode(mockState);
  const [customerState, recordState, locationState, overviewState] = await Promise.all([
    getFitnessCustomerById(customerId),
    category === "customer" ? Promise.resolve(null) : getFitnessMasterDataCategoryRecords(customerId, category, recordMode),
    category === "surveyor" ? getFitnessClientLocations(customerId) : Promise.resolve(null),
    category === "customer" ? getFitnessCustomerMasterDataOverview(customerId) : Promise.resolve(null)
  ]);
  const customer = customerState.status === "success" ? customerState.data : null;
  const indexHref = masterDataIndexHref(category, "actual");

  return (
    <ProtectedRoute>
      <AppShell
        title={customer?.name ?? config.label}
        subtitle={`${config.label} berdasarkan Customer aktif.`}
        breadcrumbs={[
          { label: "Master Data" },
          { label: config.label, href: indexHref },
          { label: customer?.name ?? customerId }
        ]}
      >
        {!customer ? <ErrorState message="Customer ID tidak ditemukan. Data global tidak digunakan sebagai fallback." action={{ label: "Kembali ke Daftar Customer", href: indexHref }} /> : null}
        {customer && category === "customer" ? (
          <FitnessClientForm
            client={customer}
            overview={overviewState?.status === "success" ? overviewState.data ?? [] : []}
            routeFamily="actual"
          />
        ) : null}
        {customer && recordState?.status === "loading" ? <Skeleton variant="table" label={`Memuat ${config.label} ${customer.name}`} /> : null}
        {customer && recordState?.status === "error" ? <ErrorState message={recordState.error} action={{ label: "Kembali ke Daftar Customer", href: indexHref }} /> : null}
        {customer && (recordState?.status === "success" || recordState?.status === "empty") ? (
          <FitnessClientMasterCategoryWorkspace
            category={category as Exclude<FitnessMasterDataCategory, "customer">}
            client={customer}
            locations={locationState?.status === "success" ? locationState.data : []}
            records={recordState.status === "success" ? recordState.data : []}
            routeFamily="actual"
          />
        ) : null}
      </AppShell>
    </ProtectedRoute>
  );
}

export function ActualCustomerCreate() {
  return (
    <ProtectedRoute>
      <AppShell
        title="Tambah Customer"
        subtitle="Daftarkan perusahaan atau organisasi pada sumber Customer."
        breadcrumbs={[{ label: "Master Data" }, { label: "Customer", href: masterDataIndexHref("customer", "actual") }, { label: "Tambah Customer" }]}
      >
        <FitnessClientForm routeFamily="actual" />
      </AppShell>
    </ProtectedRoute>
  );
}

function mockMode(value?: string): FitnessMockMode {
  return value === "loading" || value === "empty" || value === "error" ? value : "success";
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
