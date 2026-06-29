"use client";

import { Plus, Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import type { JobSummary } from "@/types/jobs";

export default function JobsPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Job Order">
        <JobsContent />
      </AppShell>
    </ProtectedRoute>
  );
}

function JobsContent() {
  const { accessToken, user } = useAuth();
  const [rows, setRows] = useState<JobSummary[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const canCreate = can(user, "jobs.create.all");

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<JobSummary>(`/jobs${buildQuery({ page, per_page: 10, search, status })}`, { accessToken });
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil job.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, page, search, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  return (
    <div className="page-stack">
      <PageHeader title="Job Order" description="Create, assign, and monitor container survey jobs." action={canCreate ? { label: "Create Job", icon: Plus, onClick: () => window.location.assign("/jobs/create") } : undefined} />
      <div className="toolbar">
        <label className="search-box"><Search size={17} /><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Search job/reference" /></label>
        <select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}>
          <option value="">All Status</option>
          {['draft','assigned','in_progress','all_survey_submitted','all_survey_approved','report_generated','ready_to_invoice','invoiced','paid','closed','cancelled'].map((item) => <option key={item} value={item}>{item}</option>)}
        </select>
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <DataTable
        rows={rows}
        isLoading={isLoading}
        page={page}
        totalPages={totalPages}
        onPageChange={setPage}
        columns={[
          { key: "job_order_no", header: "Job No", render: (row) => <Link className="text-link" href={`/jobs/${row.id}`}>{row.job_order_no}</Link> },
          { key: "job_date", header: "Date", render: (row) => row.job_date },
          { key: "customer", header: "Customer", render: (row) => row.customer_name },
          { key: "survey_type", header: "Survey Type", render: (row) => row.survey_type_name },
          { key: "location", header: "Location", render: (row) => row.location_name },
          { key: "containers", header: "Containers", render: (row) => row.total_containers ?? 0 },
          { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "cancelled" ? "danger" : row.status === "draft" ? "warning" : "success"}>{row.status.toUpperCase()}</StatusBadge> }
        ]}
      />
    </div>
  );
}