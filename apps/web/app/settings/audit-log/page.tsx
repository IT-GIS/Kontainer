import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { AuditLogSettings } from "@/components/settings/admin-settings";

export default function AuditLogPage() {
  return <ProtectedRoute><AppShell title="Audit Log"><AuditLogSettings /></AppShell></ProtectedRoute>;
}
