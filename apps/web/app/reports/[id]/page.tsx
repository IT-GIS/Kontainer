"use client";

import { Download, QrCode } from "lucide-react";
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

const apiBase = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080/api/v1";

export default function ReportDetailPage() {
  return <ProtectedRoute><AppShell title="Report Detail"><ReportDetailContent /></AppShell></ProtectedRoute>;
}

function ReportDetailContent() {
  const params = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const [report, setReport] = useState<ReportDetail | null>(null);
  const [versions, setVersions] = useState<ReportVersion[]>([]);
  const [error, setError] = useState<string | null>(null);

  const loadReport = useCallback(async () => {
    if (!accessToken || !params.id) return;
    setError(null);
    try {
      const [detail, versionRows] = await Promise.all([
        apiData<ReportDetail>(`/reports/${params.id}`, { accessToken }),
        apiData<ReportVersion[]>(`/reports/${params.id}/versions`, { accessToken })
      ]);
      setReport(detail);
      setVersions(versionRows);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil report.");
    }
  }, [accessToken, params.id]);

  useEffect(() => { const timer = window.setTimeout(() => void loadReport(), 0); return () => window.clearTimeout(timer); }, [loadReport]);

  if (!report) return <div className="center-screen">Memuat report...</div>;
  const validateUrl = report.qr_token ? `${apiBase}/public/reports/validate/${report.qr_token}` : "-";

  return (
    <div className="page-stack">
      <PageHeader title={`Report Detail: ${report.report_no}`} description={`${report.customer_name} - ${report.container_no}`} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <div className="job-actions">
        <button className="primary-button" onClick={() => void downloadReport(report.id, report.report_no, accessToken)}><Download size={17} /><span>Download PDF</span></button>
        {report.qr_token ? <a className="secondary-button" href={validateUrl} target="_blank"><QrCode size={17} /><span>Validate QR</span></a> : null}
      </div>
      <section className="workspace-panel detail-grid">
        <div><span>Status</span><strong><StatusBadge tone={report.status === "failed" ? "danger" : report.status === "pending_generation" ? "warning" : "success"}>{report.status.toUpperCase()}</StatusBadge></strong></div>
        <div><span>Version</span><strong>Rev. {report.current_version_no ?? report.revision_no ?? 0}</strong></div>
        <div><span>Survey No</span><strong>{report.survey_no}</strong></div>
        <div><span>Job No</span><strong>{report.job_order_no}</strong></div>
        <div><span>QR Token</span><strong>{report.qr_token ?? "-"}</strong></div>
        <div><span>Created At</span><strong>{report.created_at}</strong></div>
      </section>
      <section className="workspace-panel">
        <div className="section-title-row"><h2>Versions</h2><p className="muted-text">Versioning dasar report.</p></div>
        <DataTable rows={versions} columns={[
          { key: "version", header: "Version", render: (row) => `Rev. ${row.version_no}` },
          { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "draft" ? "warning" : "success"}>{row.status.toUpperCase()}</StatusBadge> },
          { key: "reason", header: "Reason", render: (row) => row.change_reason ?? "-" },
          { key: "created", header: "Created At", render: (row) => row.created_at }
        ]} />
      </section>
    </div>
  );
}

async function downloadReport(id: string, reportNo: string, accessToken: string | null) {
  if (!accessToken) return;
  const response = await fetch(`${apiBase}/reports/${id}/download`, { headers: { Authorization: `Bearer ${accessToken}` } });
  if (!response.ok) return;
  const blob = await response.blob();
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `${reportNo}.pdf`;
  link.click();
  window.URL.revokeObjectURL(url);
}
