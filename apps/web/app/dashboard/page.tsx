"use client";

import { AlertTriangle, CheckCircle2, ClipboardList, FileCheck2, PackageOpen, ReceiptText, RotateCcw, Send, Timer } from "lucide-react";
import { useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";

type AdminMetrics = {
  total_jobs: number; draft_jobs: number; assigned_jobs: number; survey_in_progress: number;
  submitted_surveys: number; need_revision_surveys: number; approved_surveys: number;
  report_generated: number; ready_to_invoice: number; overdue_jobs: number;
};

const metricDefinitions = [
  { key: "total_jobs", label: "Total Job", icon: ClipboardList, tone: "teal" },
  { key: "draft_jobs", label: "Draft Job", icon: ClipboardList, tone: "teal" },
  { key: "assigned_jobs", label: "Assigned Job", icon: PackageOpen, tone: "cyan" },
  { key: "survey_in_progress", label: "Survey In Progress", icon: Timer, tone: "cyan" },
  { key: "submitted_surveys", label: "Submitted Survey", icon: Send, tone: "gold" },
  { key: "need_revision_surveys", label: "Need Revision", icon: RotateCcw, tone: "gold" },
  { key: "approved_surveys", label: "Approved Survey", icon: CheckCircle2, tone: "blue" },
  { key: "report_generated", label: "Report Generated", icon: FileCheck2, tone: "blue" },
  { key: "ready_to_invoice", label: "Ready to Invoice", icon: ReceiptText, tone: "violet" },
  { key: "overdue_jobs", label: "Overdue Job", icon: AlertTriangle, tone: "violet" }
] as const;

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
  const { accessToken, user } = useAuth();
  const roles = user?.roles ?? [];
  const isAdmin = roles.includes("admin") || roles.includes("super_admin");
  const [metrics, setMetrics] = useState<AdminMetrics | null>(null);
  const [error, setError] = useState<string | null>(null);
  const isLoading = Boolean(accessToken && isAdmin && metrics === null && error === null);

  useEffect(() => {
    if (!accessToken || !isAdmin) return;
    let active = true;
    void apiData<AdminMetrics>("/dashboard/admin", { accessToken })
      .then((result) => {
        if (!active) return;
        setMetrics(result);
        setError(null);
      })
      .catch((err) => {
        if (active) setError(err instanceof Error ? err.message : "Gagal mengambil dashboard Admin.");
      });
    return () => { active = false; };
  }, [accessToken, isAdmin]);

  return (
    <div className="page-stack source-dashboard-stack">
      <div className="source-dashboard-intro">
        <h2>Ringkasan Aktivitas</h2>
        <p>Ringkasan aktivitas inspeksi &amp; sertifikasi kontainer.</p>
      </div>

      {isAdmin && isLoading ? <div className="workspace-panel">Memuat metric dashboard...</div> : null}
      {isAdmin && error ? <div className="alert alert-danger">{error}</div> : null}
      {isAdmin && metrics && Object.values(metrics).every((value) => value === 0) ? <div className="workspace-panel muted-text">Belum ada aktivitas operasional untuk ditampilkan.</div> : null}
      {isAdmin && metrics ? <section className="metric-grid source-metric-grid">
        {metricDefinitions.map((metric) => {
          const Icon = metric.icon;
          return (
            <article className="metric-tile source-metric-card" key={metric.label}>
              <div className="source-metric-head">
                <p>{metric.label}</p>
                <span className={`source-metric-icon source-metric-${metric.tone}`}><Icon size={20} /></span>
              </div>
              <strong>{metrics[metric.key]}</strong>
            </article>
          );
        })}
      </section> : null}

      <section className="workspace-panel source-dashboard-note">
        <div className="source-note-head">
          <h2>{dashboardTitle(roles)}</h2>
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
