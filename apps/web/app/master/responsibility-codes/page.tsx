import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function ResponsibilityCodesPage() {
  return <ProtectedRoute><AppShell title="Responsibility Code"><MasterDataPage resourceId="responsibility-codes" /></AppShell></ProtectedRoute>;
}
