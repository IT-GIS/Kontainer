import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SettingsWorkspace } from "@/components/settings/settings-workspace";

export default function SettingsPage() {
  return <ProtectedRoute roles={["admin", "supervisor", "management"]}><AppShell title="Pengaturan" breadcrumbs={[{ label: "Pengaturan" }]}><SettingsWorkspace /></AppShell></ProtectedRoute>;
}
