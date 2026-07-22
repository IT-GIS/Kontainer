"use client";

import { useParams } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import type { ReportDetail, ReportVersion } from "@/types/reviews";

export default function ReportDetailPage() {
  return <ProtectedRoute><AppShell title="Metadata Dokumen Kelaikan"><ReportDetailContent /></AppShell></ProtectedRoute>;
}

function ReportDetailContent() {
  const params = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const [report, setReport] = useState<ReportDetail | null>(null);
  const [versions, setVersions] = useState<ReportVersion[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadReport = useCallback(async () => {
    if (!accessToken || !params.id) return;
    setIsLoading(true);
    setError(null);
    try {
      const [detail, versionRows] = await Promise.all([
        apiData<ReportDetail>(`/reports/${params.id}`, { accessToken }),
        apiData<ReportVersion[]>(`/reports/${params.id}/versions`, { accessToken })
      ]);
      setReport(detail);
      setVersions(versionRows);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil metadata dokumen.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, params.id]);

  useEffect(() => { const timer = window.setTimeout(() => void loadReport(), 0); return () => window.clearTimeout(timer); }, [loadReport]);

  if (isLoading && !report) return <div className="center-screen">Memuat metadata dokumen...</div>;
  if (!report) return <div className="alert alert-danger">{error ?? "Metadata dokumen tidak ditemukan."}</div>;

  return <div className="page-stack">
    <PageHeader title={report.report_no} description={`${report.customer_name} — ${report.container_no}`} />
    {error ? <div className="alert alert-danger">{error}</div> : null}
    <div className="alert alert-warning">Halaman ini hanya menampilkan metadata dokumen. PDF final, QR, penandatangan, dan verifikasi publik belum aktif.</div>
    <section className="workspace-panel detail-grid">
      <div><span>Status</span><strong><StatusBadge tone={report.status === "failed" ? "danger" : "warning"}>{humanize(report.status)}</StatusBadge></strong></div>
      <div><span>Versi Aktif</span><strong>Rev. {report.current_version_no ?? report.revision_no ?? 0}</strong></div>
      <div><span>Nomor Survey</span><strong>{report.survey_no}</strong></div>
      <div><span>Nomor Pekerjaan</span><strong>{report.job_order_no}</strong></div>
      <div><span>Customer</span><strong>{report.customer_name}</strong></div>
      <div><span>Peti Kemas</span><strong>{report.container_no}</strong></div>
      <div><span>Jenis Dokumen</span><strong>{humanize(report.report_type)}</strong></div>
      <div><span>Penandatangan</span><strong>Belum tersedia</strong></div>
      <div><span>Dibuat</span><strong>{formatDateTime(report.created_at)}</strong></div>
      <div><span>Diperbarui</span><strong>{formatDateTime(report.updated_at)}</strong></div>
    </section>
    <section className="workspace-panel job-tab-stack">
      <div><h2>Riwayat Versi</h2><p className="muted-text">Metadata versi existing tanpa file PDF final.</p></div>
      <DataTable rows={versions} emptyText="Riwayat versi belum tersedia." columns={[
        { key: "version", header: "Versi", render: (row) => `Rev. ${row.version_no}` },
        { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "draft" ? "warning" : "success"}>{humanize(row.status)}</StatusBadge> },
        { key: "reason", header: "Alasan Perubahan", render: (row) => row.change_reason ?? "Belum tersedia" },
        { key: "creator", header: "Dibuat Oleh", render: () => "Belum tersedia pada kontrak existing" },
        { key: "created", header: "Waktu", render: (row) => formatDateTime(row.created_at) },
        { key: "active", header: "Versi Aktif", render: (row) => row.version_no === (report.current_version_no ?? report.revision_no) ? <StatusBadge tone="success">Aktif</StatusBadge> : "-" }
      ]} />
    </section>
  </div>;
}

function formatDateTime(value?: string | null) { if (!value) return "Belum tersedia"; const date = new Date(value); return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(date); }
function humanize(value: string) { return value.replaceAll("_", " ").replaceAll("-", " ").replace(/\b\w/g, (letter) => letter.toUpperCase()); }
