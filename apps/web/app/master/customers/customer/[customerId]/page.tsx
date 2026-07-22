import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CustomerDetailWorkspace, type CustomerDetailTab } from "@/components/master/customer-detail-workspace";

type Query = Promise<Record<string, string | string[] | undefined>>;
const tabs: CustomerDetailTab[] = ["profile", "personnel", "location", "history"];

export default async function CustomerDetailPage({
  params,
  searchParams
}: {
  params: Promise<{ customerId: string }>;
  searchParams: Query;
}) {
  const { customerId } = await params;
  const query = await searchParams;
  const requested = Array.isArray(query.tab) ? query.tab[0] : query.tab;
  const activeTab = tabs.includes(requested as CustomerDetailTab) ? requested as CustomerDetailTab : "profile";

  return (
    <ProtectedRoute>
      <AppShell
        title="Detail Customer"
        subtitle="Profil, Personel/PIC, Location Pemeriksaan, dan riwayat pekerjaan Customer."
        breadcrumbs={[{ label: "Master Data" }, { label: "Customer", href: "/master/customers" }, { label: "Detail Customer" }]}
      >
        <CustomerDetailWorkspace activeTab={activeTab} customerId={customerId} />
      </AppShell>
    </ProtectedRoute>
  );
}
