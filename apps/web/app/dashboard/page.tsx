"use client";

import { CheckCircle2, ClipboardList, PackageOpen, RotateCcw, Send, Timer, UsersRound } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";

type AdminMetrics = {
	jobs_total: number;
	containers_total: number;
	assignments_total: number;
	surveys_total: number;
	unassigned_containers: number;
	assigned_not_started: number;
	surveys_draft: number;
	surveys_submitted: number;
	surveys_under_review: number;
	surveys_need_revision: number;
	surveys_resubmitted: number;
	surveys_approved: number;
	surveys_rejected: number;
	jobs_mixed_decision: number;
  new_jobs: number;
  unassigned_jobs: number;
  survey_in_progress: number;
  submitted_surveys: number;
  need_revision_surveys: number;
  approved_surveys: number;
  incomplete_customer_master: number;
  recent_activities: Array<{
    id: string;
    job_order_id: string;
    event: string;
    title: string;
    description: string;
    actor: string;
    created_at: string;
  }>;
};

const metricDefinitions = [
	{ key: "jobs_total", label: "Total Job", icon: ClipboardList, tone: "teal", href: "/jobs" },
	{ key: "containers_total", label: "Total Container", icon: PackageOpen, tone: "cyan", href: "/jobs" },
	{ key: "assignments_total", label: "Total Assignment", icon: UsersRound, tone: "cyan", href: "/jobs?tab=assignments" },
	{ key: "unassigned_containers", label: "Container Belum Ditugaskan", icon: PackageOpen, tone: "gold", href: "/jobs?view=unassigned" },
	{ key: "assigned_not_started", label: "Ditugaskan Belum Dimulai", icon: Timer, tone: "gold", href: "/jobs?view=assigned-not-started" },
	{ key: "surveys_draft", label: "Survey Draft", icon: Timer, tone: "cyan", href: "/monitoring/surveys/in-progress" },
	{ key: "surveys_submitted", label: "Survey Terkirim", icon: Send, tone: "gold", href: "/monitoring/surveys/submitted" },
	{ key: "surveys_under_review", label: "Dalam Review", icon: Timer, tone: "gold", href: "/monitoring/surveys?status=under_review" },
	{ key: "surveys_need_revision", label: "Perlu Revisi", icon: RotateCcw, tone: "gold", href: "/monitoring/surveys/need-revision" },
	{ key: "surveys_resubmitted", label: "Dikirim Ulang", icon: Send, tone: "cyan", href: "/monitoring/surveys?status=resubmitted" },
	{ key: "surveys_approved", label: "Disetujui", icon: CheckCircle2, tone: "blue", href: "/monitoring/surveys/approved" },
	{ key: "surveys_rejected", label: "Ditolak", icon: RotateCcw, tone: "violet", href: "/monitoring/surveys?status=rejected" },
	{ key: "jobs_mixed_decision", label: "Job Hasil Campuran", icon: ClipboardList, tone: "violet", href: "/jobs?status=completed_with_rejection" },
	{ key: "incomplete_customer_master", label: "Master Customer Belum Lengkap", icon: UsersRound, tone: "violet", href: "/master/customers?readiness=incomplete" }
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
  const isAdmin = user?.active_role === "admin" || user?.active_role === "super_admin";
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
        <h2>Ringkasan Operasional</h2>
        <p>Perjalanan pekerjaan inspeksi peti kemas dari persiapan sampai keputusan.</p>
      </div>

      {isAdmin && isLoading ? <div className="workspace-panel">Memuat metric dashboard...</div> : null}
      {isAdmin && error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
      {isAdmin && metrics ? <section className="metric-grid source-metric-grid">
        {metricDefinitions.map((metric) => {
          const Icon = metric.icon;
          return (
			<Link className="metric-tile source-metric-card" href={metric.href} key={metric.label}>
              <div className="source-metric-head">
                <p>{metric.label}</p>
                <span className={`source-metric-icon source-metric-${metric.tone}`}><Icon size={20} /></span>
              </div>
              <strong>{metrics[metric.key]}</strong>
			</Link>
          );
        })}
      </section> : null}

      {isAdmin && metrics ? <section className="workspace-panel page-stack" aria-labelledby="recent-activity-title">
        <div className="section-title-row"><div><h2 id="recent-activity-title">Aktivitas Terbaru</h2><p className="muted-text">Jejak aktivitas pekerjaan dari event operasional terbaru.</p></div></div>
        {metrics.recent_activities.length === 0 ? <p className="muted-text">Belum ada aktivitas pekerjaan.</p> : (
          <div className="job-tab-stack">
            {metrics.recent_activities.map((activity) => <article className="detail-grid" key={activity.id}>
              <div><span>Aktivitas</span><strong>{activity.title}</strong></div>
              <div><span>Pelaksana</span><strong>{activity.actor}</strong></div>
              <div><span>Waktu</span><strong>{formatDateTime(activity.created_at)}</strong></div>
              <div><span>Konteks</span><strong><Link className="text-link" href={`/jobs/${activity.job_order_id}`}>Buka Pekerjaan</Link></strong></div>
              {activity.description ? <div className="form-span-2"><span>Ringkasan</span><strong>{activity.description}</strong></div> : null}
            </article>)}
          </div>
        )}
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
  if (roles.includes("super_admin")) return "Ringkasan Kendali Sistem";
  if (roles.length > 1) return "Ringkasan Multi-workspace";
  const titles: Record<string, string> = {
    admin: "Dashboard Operasional",
    surveyor: "Dashboard Surveyor",
    supervisor: "Dashboard Review & Keputusan",
    finance: "Dashboard Finance",
    management: "Dashboard Management"
  };
  const role = roles.find((item) => titles[item]);
  return role ? titles[role] : "Dashboard";
}

function dashboardCopy(roles: string[]) {
  if (roles.includes("super_admin")) {
    return "Pemantauan pengguna, hak akses, Master Data, dan konfigurasi sistem.";
  }
  if (roles.length > 1) {
    return `Workspace tersedia: ${roles.map((role) => role.replaceAll("_", " ")).join(", ")}.`;
  }
  const copies: Record<string, string> = {
    admin: "Persiapan pekerjaan, penugasan Surveyor GIFT, Master Data, dan pemantauan operasional.",
    surveyor: "Pekerjaan yang ditugaskan dan progres pemeriksaan Surveyor GIFT.",
    supervisor: "Antrean review, revisi, persetujuan, dan penolakan hasil pemeriksaan.",
    finance: "Workspace Finance terpisah dari menu Admin Kelaikan.",
    management: "Ringkasan dan arsip laporan dalam mode baca-saja."
  };
  const role = roles.find((item) => copies[item]);
  return role ? copies[role] : "Role-based dashboard workspace.";
}

function formatDateTime(value: string) {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(date);
}
