import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function CedexLocationsPage() {
  return <ProtectedRoute><AppShell title="CEDEX Location"><MasterDataPage resourceId="cedex-locations" /></AppShell></ProtectedRoute>;
}
