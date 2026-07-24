import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function CreateCustomerPage() {
  return <ProtectedRoute><AppShell title="Tambah Customer" breadcrumbs={[{ label: "Master Data" }, { label: "Customer", href: "/master/customers" }, { label: "Tambah Customer" }]}><MasterDataPage backHref="/master/customers" resourceId="customers" startInCreateMode /></AppShell></ProtectedRoute>;
}
