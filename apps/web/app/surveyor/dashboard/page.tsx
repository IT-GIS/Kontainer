"use client";

import { ClipboardList, FileCheck2, RefreshCcw, Send, ShieldCheck, TriangleAlert } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import type { SurveyorDashboard } from "@/types/surveyor";

export default function SurveyorDashboardPage() {
  return <ProtectedRoute><AppShell title="Dashboard Surveyor"><SurveyorDashboardContent /></AppShell></ProtectedRoute>;
}

function SurveyorDashboardContent() {
  const { accessToken } = useAuth();
  const [data, setData] = useState<SurveyorDashboard | null>(null);
  const [error, setError] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    if (!accessToken) return;
    setError(null);
    try {
      setData(await apiData<SurveyorDashboard>("/surveyor/dashboard", { accessToken }));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil dashboard.");
    }
  }, [accessToken]);

  useEffect(() => { const timer = window.setTimeout(() => void loadData(), 0); return () => window.clearTimeout(timer); }, [loadData]);

  const metrics = [
	{ label: "Total Assignment", value: data?.total_assignments ?? 0, icon: ClipboardList, href: "/surveyor/jobs" },
	{ label: "Belum Dimulai", value: data?.assigned_not_started ?? data?.not_started ?? 0, icon: TriangleAlert, href: "/surveyor/jobs?state=not_started" },
	{ label: "Draft / Sedang Dikerjakan", value: data?.draft ?? 0, icon: RefreshCcw, href: "/surveyor/surveys/draft" },
	{ label: "Terkirim", value: data?.submitted ?? 0, icon: Send, href: "/surveyor/surveys/submitted" },
	{ label: "Dalam Review", value: data?.under_review ?? 0, icon: ShieldCheck, href: "/surveyor/surveys/submitted" },
	{ label: "Perlu Revisi", value: data?.need_revision ?? 0, icon: TriangleAlert, href: "/surveyor/surveys/need-revision" },
	{ label: "Disetujui", value: data?.approved ?? 0, icon: FileCheck2, href: "/surveyor/surveys/approved" },
	{ label: "Ditolak", value: data?.rejected ?? 0, icon: TriangleAlert, href: "/surveyor/surveys/history" }
  ];

  return (
    <div className="page-stack">
      <PageHeader title="Dashboard Surveyor" description="Ringkasan job dan survey yang ditugaskan kepada Anda." action={{ label: "Job Saya", icon: ClipboardList, onClick: () => window.location.assign("/surveyor/jobs") }} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <section className="metric-grid">
        {metrics.map((item) => {
          const Icon = item.icon;
          return (
			<Link className="metric-tile metric-rich" href={item.href} key={item.label}>
              <Icon size={20} />
              <p>{item.label}</p>
              <strong>{item.value}</strong>
			</Link>
          );
        })}
      </section>
      <section className="workspace-panel">
        <div className="section-title-row">
          <div>
            <h2>Job Aktif</h2>
            <p className="muted-text">Lanjutkan survey draft atau buka job yang baru ditugaskan.</p>
          </div>
          <Link className="primary-button" href="/surveyor/jobs"><span>Buka Job Saya</span></Link>
        </div>
      </section>
    </div>
  );
}

