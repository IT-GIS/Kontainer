"use client";

import { Download, Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import type { ReportSummary } from "@/types/reviews";

const apiBase = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080/api/v1";

export default function ReportsPage() {
  return <ProtectedRoute><AppShell title="Report Archive"><ReportsContent /></AppShell></ProtectedRoute>;
}

function ReportsContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<ReportSummary[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [error, setError] = useState<string | null>(null);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setError(null);
    try {
      const result = await apiPaginated<ReportSummary>(`/reports${buildQuery({ page, per_page: 10, search, status })}`, { accessToken });
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil report.");
    }
  }, [accessToken, page, search, status]);

  useEffect(() => { const timer = window.setTimeout(() => void loadRows(), 0); return () => window.clearTimeout(timer); }, [loadRows]);

  return (
    <div className="page-stack">
      <PageHeader title="Report Archive" description="Arsip report hasil approval survey." />
      <div className="toolbar">
        <label className="search-box"><Search size={17} /><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Search report/container/customer" /></label>
        <select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}>
          <option value="">All Status</option>
          {["pending_generation", "generating", "generated", "failed", "finalized", "superseded", "void"].map((item) => <option key={item} value={item}>{item}</option>)}
        </select>
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <DataTable rows={rows} page={page} totalPages={totalPages} onPageChange={setPage} columns={[
        { key: "report_no", header: "Report No", render: (row) => <Link className="text-link" href={`/reports/${row.id}`}>{row.report_no}</Link> },
        { key: "survey_no", header: "Survey No", render: (row) => row.survey_no },
        { key: "container", header: "Container", render: (row) => row.container_no },
        { key: "customer", header: "Customer", render: (row) => row.customer_name },
        { key: "version", header: "Version", render: (row) => `Rev. ${row.revision_no ?? 0}` },
        { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "failed" ? "danger" : row.status === "pending_generation" ? "warning" : "success"}>{row.status.toUpperCase()}</StatusBadge> },
        { key: "download", header: "Action", render: (row) => <button className="secondary-button table-action" onClick={() => void downloadReport(row.id, row.report_no, accessToken)}><Download size={16} /><span>PDF</span></button> }
      ]} />
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
