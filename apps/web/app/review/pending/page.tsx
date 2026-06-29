"use client";

import { Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import type { PendingReview } from "@/types/reviews";

export default function PendingReviewPage() {
  return <ProtectedRoute><AppShell title="Pending Review"><PendingReviewContent /></AppShell></ProtectedRoute>;
}

function PendingReviewContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<PendingReview[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<PendingReview>(`/reviews/pending${buildQuery({ page, per_page: 10, search })}`, { accessToken });
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil pending review.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, page, search]);

  useEffect(() => { const timer = window.setTimeout(() => void loadRows(), 0); return () => window.clearTimeout(timer); }, [loadRows]);

  return (
    <div className="page-stack">
      <PageHeader title="Pending Review" description="Survey submitted yang menunggu keputusan supervisor." />
      <div className="toolbar">
        <label className="search-box"><Search size={17} /><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Search survey/container/job" /></label>
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <DataTable rows={rows} isLoading={isLoading} page={page} totalPages={totalPages} onPageChange={setPage} columns={[
        { key: "survey_no", header: "Survey No", render: (row) => <Link className="text-link" href={`/review/${row.survey_id}`}>{row.survey_no}</Link> },
        { key: "container", header: "Container", render: (row) => row.container_no },
        { key: "customer", header: "Customer", render: (row) => row.customer_name },
        { key: "surveyor", header: "Surveyor", render: (row) => row.surveyor_name },
        { key: "submitted", header: "Submitted At", render: (row) => row.submitted_at ?? "-" },
        { key: "status", header: "Status", render: (row) => <StatusBadge tone="warning">{row.status.toUpperCase()}</StatusBadge> }
      ]} />
    </div>
  );
}
