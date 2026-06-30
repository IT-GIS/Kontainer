"use client";

import { ClipboardList, FileCheck2, PackageOpen, ReceiptText, ShieldCheck } from "lucide-react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";

const metrics = [
  { label: "Draft Job", value: "0", icon: ClipboardList, tone: "teal" },
  { label: "Assigned", value: "0", icon: PackageOpen, tone: "cyan" },
  { label: "Pending Review", value: "0", icon: ShieldCheck, tone: "gold" },
  { label: "Report Archive", value: "0", icon: FileCheck2, tone: "blue" },
  { label: "Ready Invoice", value: "0", icon: ReceiptText, tone: "violet" }
];

export default function DashboardPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Dashboard">
        <DashboardContent />
      </AppShell>
    </ProtectedRoute>
  );
}

function DashboardContent() {
  const { user } = useAuth();
  const roles = user?.roles ?? [];

  return (
    <div className="page-stack source-dashboard-stack">
      <div className="source-dashboard-intro">
        <h2>Ringkasan Aktivitas</h2>
        <p>Ringkasan aktivitas inspeksi &amp; sertifikasi kontainer.</p>
      </div>

      <section className="metric-grid source-metric-grid">
        {metrics.map((metric) => {
          const Icon = metric.icon;
          return (
            <article className="metric-tile source-metric-card" key={metric.label}>
              <div className="source-metric-head">
                <p>{metric.label}</p>
                <span className={`source-metric-icon source-metric-${metric.tone}`}><Icon size={20} /></span>
              </div>
              <strong>{metric.value}</strong>
            </article>
          );
        })}
      </section>

      <section className="workspace-panel source-dashboard-note">
        <div className="source-note-head">
          <h2>{dashboardTitle(roles)}</h2>
          <StatusBadge tone="success">MVP READY</StatusBadge>
        </div>
        <p>{dashboardCopy(roles)}</p>
      </section>
    </div>
  );
}

function dashboardTitle(roles: string[]) {
  if (roles.includes("super_admin")) return "System Control Overview";
  if (roles.length > 1) return "Multi-workspace Overview";
  const titles: Record<string, string> = {
    admin: "Operational Dashboard",
    surveyor: "Dashboard Surveyor",
    supervisor: "Dashboard Review",
    finance: "Dashboard Finance",
    management: "Dashboard Management"
  };
  const role = roles.find((item) => titles[item]);
  return role ? titles[role] : "Dashboard";
}

function dashboardCopy(roles: string[]) {
  if (roles.includes("super_admin")) {
    return "User, permission, master data, and system configuration workspace.";
  }
  if (roles.length > 1) {
    return `Workspace aktif: ${roles.map((role) => role.replaceAll("_", " ")).join(", ")}.`;
  }
  const copies: Record<string, string> = {
    admin: "Job order, assignment, master data, and operational monitoring workspace.",
    surveyor: "Assigned job and survey progress workspace for the web MVP flow.",
    supervisor: "Pending review, approval, revision, and report readiness workspace.",
    finance: "Ready-to-invoice, price list, invoice, payment, and outstanding workspace.",
    management: "Read-only recap, dashboard, report archive, and finance summary workspace."
  };
  const role = roles.find((item) => copies[item]);
  return role ? copies[role] : "Role-based dashboard workspace.";
}
