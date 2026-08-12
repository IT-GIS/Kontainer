"use client";

import { Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import { surveyStatusLabel } from "@/lib/status-labels";
import type { SurveyorSurveyListItem } from "@/types/surveyor";

type Props = { title: string; description: string; fixedStatus?: string; history?: boolean };

export function SurveyorSurveyList({ title, description, fixedStatus = "", history = false }: Props) {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<SurveyorSurveyListItem[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState(fixedStatus);
	const [customer, setCustomer] = useState("");
	const [container, setContainer] = useState("");
	const [dateFrom, setDateFrom] = useState("");
	const [dateTo, setDateTo] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const load = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<SurveyorSurveyListItem>(
		`/surveyor/surveys${buildQuery({ page, per_page: 10, search, status: history ? status : fixedStatus || status, customer, container, date_from: dateFrom, date_to: dateTo })}`,
        { accessToken }
      );
      setRows(result.rows);
      setTotalPages(Math.max(1, Number(result.meta.total_pages ?? 1)));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil daftar survey.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, container, customer, dateFrom, dateTo, fixedStatus, history, page, search, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => void load(), 0);
    return () => window.clearTimeout(timer);
  }, [load]);

  return <div className="page-stack">
    <PageHeader title={title} description={description} />
    <div className="toolbar">
      <label className="search-box"><Search size={17} /><span className="sr-only">Cari pekerjaan survei</span><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Cari survey, job, peti kemas, customer" /></label>
	  {history ? <label><span className="sr-only">Filter hasil akhir</span><select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}><option value="terminal">Semua Hasil Akhir</option>{["approved", "rejected", "cancelled"].map((item) => <option key={item} value={item}>{surveyStatusLabel(item)}</option>)}</select></label> : null}
    </div>
	{history ? <div className="monitoring-filter-toolbar">
	  <label className="field"><span>Customer</span><input value={customer} onChange={(event) => { setPage(1); setCustomer(event.target.value); }} placeholder="Nama Customer" /></label>
	  <label className="field"><span>Peti Kemas</span><input value={container} onChange={(event) => { setPage(1); setContainer(event.target.value); }} placeholder="Nomor peti kemas" /></label>
	  <label className="field"><span>Tanggal Mulai</span><input type="date" max={dateTo || undefined} value={dateFrom} onChange={(event) => { setPage(1); setDateFrom(event.target.value); }} /></label>
	  <label className="field"><span>Tanggal Akhir</span><input type="date" min={dateFrom || undefined} value={dateTo} onChange={(event) => { setPage(1); setDateTo(event.target.value); }} /></label>
	</div> : null}
    {error ? <div className="alert alert-danger">{error}</div> : null}
    <DataTable rows={rows} isLoading={isLoading} page={page} totalPages={totalPages} onPageChange={setPage} emptyText="Survey belum tersedia." columns={[
      { key: "survey", header: "Survey", render: (row) => <Link className="text-link" href={`/surveyor/surveys/${row.survey_id}`}>{row.survey_no}</Link> },
	  { key: "job", header: "Nomor Job", render: (row) => row.job_order_no },
	  { key: "container", header: "Peti Kemas", render: (row) => row.container_no },
      { key: "customer", header: "Customer / Location", render: (row) => <><strong>{row.customer_name}</strong><br /><span className="muted-text">{row.location_name}</span></> },
	  { key: "type", header: "Jenis Pemeriksaan", render: (row) => row.survey_type_name },
	  { key: "status", header: "Status", render: (row) => <StatusBadge tone={tone(row.status)}>{surveyStatusLabel(row.status)}</StatusBadge> },
	  { key: "reviewer", header: "Reviewer Aktif", render: (row) => row.current_reviewer_name ?? "-" },
	  { key: "revision", header: "Revisi", render: (row) => Number(row.current_revision_no ?? 0) > 0 ? `R${row.current_revision_no}` : "-" },
      { key: "date", header: "Tanggal", render: (row) => row.approved_at ?? row.resubmitted_at ?? row.review_started_at ?? row.submitted_at ?? row.started_at ?? row.created_at ?? "-" }
    ]} />
  </div>;
}

function tone(status: string): "success" | "warning" | "danger" | "neutral" {
  if (status === "approved") return "success";
  if (status === "need_revision" || status === "rejected") return "danger";
  if (status === "draft" || status === "submitted" || status === "resubmitted") return "warning";
  return "neutral";
}
