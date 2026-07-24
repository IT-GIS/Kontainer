import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CompanyProfileSettings } from "@/components/settings/admin-settings";

export default function CompanyProfileSettingsPage() {
  return <ProtectedRoute><AppShell title="Company Profile"><CompanyProfileSettings /></AppShell></ProtectedRoute>;
}
