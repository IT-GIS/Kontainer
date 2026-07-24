import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { NumberingSettings } from "@/components/settings/admin-settings";

export default function NumberingSettingsPage() {
  return <ProtectedRoute><AppShell title="Penomoran"><NumberingSettings /></AppShell></ProtectedRoute>;
}
