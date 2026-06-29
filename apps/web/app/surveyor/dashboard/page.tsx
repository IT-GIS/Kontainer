"use client";

import { ClipboardList, FileCheck2, RefreshCcw, Send, TriangleAlert } from "lucide-react";
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
    { label: "Total Job", value: data?.total_jobs ?? 0, icon: ClipboardList },
    { label: "Not Started", value: data?.not_started ?? 0, icon: TriangleAlert },
    { label: "Draft", value: data?.draft ?? 0, icon: RefreshCcw },
    { label: "Submitted", value: data?.submitted ?? 0, icon: Send },
    { label: "Need Revision", value: data?.need_revision ?? 0, icon: TriangleAlert },
    { label: "Approved", value: data?.approved ?? 0, icon: FileCheck2 }
  ];

  return (
    <div className="page-stack">
      <PageHeader title="Dashboard Surveyor" description="Ringkasan job dan survey yang ditugaskan kepada Anda." action={{ label: "Job Saya", icon: ClipboardList, onClick: () => window.location.assign("/surveyor/jobs") }} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <section className="metric-grid">
        {metrics.map((item) => {
          const Icon = item.icon;
          return (
            <div className="metric-tile metric-rich" key={item.label}>
              <Icon size={20} />
              <p>{item.label}</p>
              <strong>{item.value}</strong>
            </div>
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

