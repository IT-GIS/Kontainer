"use client";

import { Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import type { SurveyListItem } from "@/types/surveys";

type StatusOption = { label: string; value: string };

type SurveyListPageProps = {
  title: string;
  description: string;
  endpoint: "/surveys/monitoring" | "/reviews";
  fixedStatus?: string;
  statusOptions?: StatusOption[];
};

export function SurveyListPage({ title, description, endpoint, fixedStatus = "", statusOptions = [] }: SurveyListPageProps) {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<SurveyListItem[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState(fixedStatus || statusOptions[0]?.value || "");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<SurveyListItem>(
        `${endpoint}${buildQuery({ page, per_page: 10, search, status: fixedStatus || status })}`,
        { accessToken }
      );
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil daftar survey.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, endpoint, fixedStatus, page, search, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  return (
    <div className="page-stack">
      <PageHeader title={title} description={description} />
      <div className="toolbar">
        <label className="search-box">
          <Search size={17} />
          <input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Cari survey, job, container, customer, surveyor" />
        </label>
        {statusOptions.length > 0 ? (
          <select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}>
            {statusOptions.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}
          </select>
        ) : null}
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <DataTable
        rows={rows}
        isLoading={isLoading}
        emptyText="Survey dengan status ini belum tersedia."
        page={page}
        totalPages={totalPages}
        onPageChange={setPage}
        columns={[
          { key: "survey_no", header: "Survey No", render: (row) => <Link className="text-link" href={`/review/${row.survey_id}`}>{row.survey_no}</Link> },
          { key: "job_order_no", header: "Job Order", render: (row) => row.job_order_no },
          { key: "container_no", header: "Container", render: (row) => row.container_no },
          { key: "customer", header: "Customer / Location", render: (row) => <><strong>{row.customer_name}</strong><br /><span className="muted-text">{row.location_name}</span></> },
          { key: "survey_type", header: "Survey Type", render: (row) => row.survey_type_name },
          { key: "surveyor", header: "Surveyor", render: (row) => row.surveyor_name },
          { key: "status", header: "Status", render: (row) => <StatusBadge tone={statusTone(row.status)}>{row.status.replaceAll("_", " ").toUpperCase()}</StatusBadge> },
          { key: "started_at", header: "Started At", render: (row) => row.started_at ?? "-" },
          { key: "submitted_at", header: "Submitted At", render: (row) => row.submitted_at ?? "-" },
          { key: "approved_at", header: "Approved At", render: (row) => row.approved_at ?? "-" },
          { key: "action", header: "Action", render: (row) => <Link className="secondary-button table-action" href={`/review/${row.survey_id}`}>Detail</Link> }
        ]}
      />
    </div>
  );
}

function statusTone(status: string): "success" | "warning" | "danger" | "neutral" {
  if (status === "approved") return "success";
  if (status === "need_revision" || status === "rejected") return "danger";
  if (status === "submitted" || status === "in_progress") return "warning";
  return "neutral";
}
