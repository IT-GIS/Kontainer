import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function CedexMaterialsPage() {
  return <ProtectedRoute><AppShell title="CEDEX Material"><MasterDataPage resourceId="cedex-materials" /></AppShell></ProtectedRoute>;
}
