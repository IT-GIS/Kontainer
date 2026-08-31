"use client";

import { Search } from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { useCallback, useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/ui/page-header";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { StatusBadge } from "@/components/ui/status-badge";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import { surveyStatusLabel } from "@/lib/status-labels";
import type { PendingReview } from "@/types/reviews";

type ReviewView = "pending" | "need-revision" | "approved" | "rejected" | "history";
const views: ReviewView[] = ["pending", "need-revision", "approved", "rejected", "history"];
const tabs = [
  { id: "pending", label: "Menunggu Review" },
  { id: "need-revision", label: "Perlu Revisi" },
  { id: "approved", label: "Disetujui" },
  { id: "rejected", label: "Ditolak" },
  { id: "history", label: "Riwayat" }
] as const;
const viewCopy: Record<ReviewView, { title: string; description: string }> = {
  pending: { title: "Menunggu Review", description: "Hasil Surveyor yang sudah dikirim dan menunggu keputusan teknis." },
  "need-revision": { title: "Perlu Revisi", description: "Survey yang dikembalikan kepada Surveyor dengan catatan revisi." },
  approved: { title: "Disetujui", description: "Survey yang sudah mendapat keputusan persetujuan." },
  rejected: { title: "Ditolak", description: "Survey dengan keputusan penolakan." },
  history: { title: "Riwayat Keputusan", description: "Gabungan keputusan revisi, persetujuan, dan penolakan." }
};

export function ReviewWorkspace() {
  const requested = useSearchParams().get("view");
  const view = views.includes(requested as ReviewView) ? requested as ReviewView : "pending";
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<PendingReview[]>([]);
  const [search, setSearch] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const statuses = view === "history" ? ["need_revision", "approved", "rejected"] : [statusForView(view)];
      const result = await Promise.all(statuses.map((status) => loadAllReviews(accessToken, status)));
      const merged = result.flat();
      setRows(Array.from(new Map(merged.map((row) => [row.survey_id, row])).values()).sort((a, b) => reviewTime(b) - reviewTime(a)));
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : "Workspace Review gagal dimuat.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, view]);

  useEffect(() => { const timer = window.setTimeout(() => void loadRows(), 0); return () => window.clearTimeout(timer); }, [loadRows]);
  useEffect(() => { const timer = window.setTimeout(() => setSearch(""), 0); return () => window.clearTimeout(timer); }, [view]);

  const filtered = useMemo(() => {
    const needle = search.trim().toLowerCase();
    return !needle ? rows : rows.filter((row) => `${row.survey_no} ${row.job_order_no} ${row.container_no} ${row.customer_name} ${row.surveyor_name}`.toLowerCase().includes(needle));
  }, [rows, search]);
  const copy = viewCopy[view];

  return <div className="page-stack review-workspace">
    <PageHeader title={copy.title} description={copy.description} />
    <WorkspaceTabs activeID={view} label="Status Review & Keputusan" tabs={tabs.map((tab) => ({ id: tab.id, label: tab.label, href: tab.id === "pending" ? "/review" : `/review?view=${tab.id}` }))} />
    <div className="toolbar"><label className="search-box"><Search size={17} /><span className="sr-only">Cari review</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Cari survey, pekerjaan, peti kemas, Customer, atau Surveyor" /></label></div>
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    {isLoading ? <div className="workspace-panel inspection-loading">Memuat Review & Keputusan...</div> : <ResponsiveTableCards columns={columns} rows={filtered} getRowId={(row) => row.survey_id} getRowTitle={(row) => row.survey_no} emptyText="Review dengan status ini belum tersedia." label={copy.title} pageSize={10} />}
  </div>;
}

const columns: ResponsiveColumn<PendingReview>[] = [
  { key: "survey", header: "Survey", render: (row) => <Link className="text-link" href={`/review/${row.survey_id}`}>{row.survey_no}</Link> },
  { key: "job", header: "Pekerjaan", render: (row) => row.job_order_no },
  { key: "container", header: "Peti Kemas", render: (row) => row.container_no },
  { key: "customer", header: "Customer", render: (row) => row.customer_name },
  { key: "surveyor", header: "Surveyor GIFT", render: (row) => row.surveyor_name },
  { key: "type", header: "Jenis Pemeriksaan", render: (row) => row.survey_type_name },
  { key: "reviewer", header: "Reviewer", render: (row) => row.current_reviewer_name ?? "Belum ditetapkan" },
  { key: "submitted", header: "Dikirim", render: (row) => formatDateTime(row.resubmitted_at ?? row.submitted_at) },
  { key: "status", header: "Status", render: (row) => <StatusBadge tone={statusTone(row.status)}>{surveyStatusLabel(row.status)}</StatusBadge> },
  { key: "action", header: "Aksi", render: (row) => <Link className="primary-button table-action" href={`/review/${row.survey_id}`}>Buka Review</Link> }
];

async function loadAllReviews(accessToken: string, status: string) {
  const rows: PendingReview[] = [];
  let page = 1;
  let totalPages = 1;
  do {
    const endpoint = status === "pending" ? "/reviews/pending" : "/reviews";
    const result = await apiPaginated<PendingReview>(`${endpoint}${buildQuery({ page, per_page: 100, ...(status === "pending" ? {} : { status }) })}`, { accessToken });
    rows.push(...result.rows);
    totalPages = Math.max(1, Number(result.meta.total_pages ?? 1));
    page += 1;
  } while (page <= totalPages);
  return rows;
}

function statusForView(view: ReviewView) { if (view === "pending") return "pending"; if (view === "need-revision") return "need_revision"; return view; }
function reviewTime(row: PendingReview) { return new Date(row.resubmitted_at ?? row.review_started_at ?? row.submitted_at ?? 0).getTime(); }
function formatDateTime(value?: string | null) { if (!value) return "Belum tersedia"; const date = new Date(value); return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(date); }
function statusTone(status: string): "success" | "warning" | "danger" | "neutral" { if (status === "approved") return "success"; if (status === "need_revision" || status === "rejected") return "danger"; if (status === "submitted" || status === "resubmitted" || status === "under_review") return "warning"; return "neutral"; }
