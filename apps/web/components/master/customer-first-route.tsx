import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CustomerScopedMasterDetail, CustomerScopedMasterIndex } from "@/components/master/customer-scoped-master-data";
import { getFitnessMasterDataCategoryConfigByID, masterDataIndexHref } from "@/constants/fitness-master-data-client-first";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";

export type ActualMasterDataSearchParams = Promise<Record<string, string | string[] | undefined>>;

export async function ActualMasterDataIndexRoute({ category, searchParams }: { category: FitnessMasterDataCategory; searchParams: ActualMasterDataSearchParams }) {
  const resolved = await searchParams;
  const requestedTab = Array.isArray(resolved.tab) ? resolved.tab[0] : resolved.tab;
  const customerDetailTab = ["profile", "personnel", "location", "history"].includes(requestedTab ?? "")
    ? requestedTab
    : undefined;
  return <ActualMasterDataIndex category={category} customerDetailTab={customerDetailTab} />;
}

export async function ActualMasterDataDetailRoute({ category, customerId, searchParams }: { category: FitnessMasterDataCategory; customerId: string; searchParams: ActualMasterDataSearchParams }) {
  await searchParams;
  return <ActualMasterDataDetail category={category} customerId={customerId} />;
}

export function ActualMasterDataIndex({ category, customerDetailTab }: { category: FitnessMasterDataCategory; customerDetailTab?: string }) {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  const isCustomer = category === "customer";
  return (
    <ProtectedRoute>
      <AppShell
        title={isCustomer ? "Customer & Master" : config.label}
        subtitle={isCustomer ? "Siapkan setiap Customer sampai siap operasional." : "Master Data dikelola secara terpisah untuk setiap Customer."}
        breadcrumbs={[{ label: isCustomer ? "Customer & Master" : "Master Data" }, ...(isCustomer ? [] : [{ label: config.label }])]}
      >
        <CustomerScopedMasterIndex category={category} routeFamily="actual" customerDetailTab={customerDetailTab} />
      </AppShell>
    </ProtectedRoute>
  );
}

export function ActualMasterDataDetail({ category, customerId }: { category: FitnessMasterDataCategory; customerId: string }) {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  return (
    <ProtectedRoute>
      <AppShell
        title={config.label}
        subtitle="Data pada halaman ini khusus untuk Customer yang dipilih."
        breadcrumbs={[
          { label: "Master Data" },
          { label: config.label, href: masterDataIndexHref(category, "actual") },
          { label: "Detail Customer" }
        ]}
      >
        <CustomerScopedMasterDetail category={category} customerId={customerId} routeFamily="actual" />
      </AppShell>
    </ProtectedRoute>
  );
}

export function ActualCustomerCreate() {
  return <ActualMasterDataIndex category="customer" />;
}
