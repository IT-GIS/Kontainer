"use client";

import { Play, Search } from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { Suspense, useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import { jobStatusLabel, jobStatusLabels } from "@/lib/status-labels";
import type { AssignedSurveyorContainer, SurveyorJob } from "@/types/surveyor";

export default function SurveyorJobsPage() {
  return <ProtectedRoute><AppShell title="Job Saya"><Suspense fallback={<div className="loading-state">Memuat pekerjaan...</div>}><SurveyorJobsContent /></Suspense></AppShell></ProtectedRoute>;
}

function SurveyorJobsContent() {
  const searchParams = useSearchParams();
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<SurveyorJob[]>([]);
	const [containerRows, setContainerRows] = useState<AssignedSurveyorContainer[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState(() => searchParams.get("status") ?? "");
	const isNotStarted = searchParams.get("state") === "not_started";
	const [startingID, setStartingID] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
		if (isNotStarted) {
			const result = await apiPaginated<AssignedSurveyorContainer>(`/surveyor/assigned-containers${buildQuery({ page, per_page: 10, search, state: "not_started" })}`, { accessToken });
			setContainerRows(result.rows);
			setTotalPages(Number(result.meta.total_pages ?? 1));
			return;
		}
		const result = await apiPaginated<SurveyorJob>(`/surveyor/jobs${buildQuery({ page, per_page: 10, search, status })}`, { accessToken });
		setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil job saya.");
    } finally {
      setIsLoading(false);
    }
	}, [accessToken, isNotStarted, page, search, status]);

	const startSurvey = async (container: AssignedSurveyorContainer) => {
		if (!accessToken || startingID) return;
		setStartingID(container.job_container_id);
		setError(null);
		try {
			const survey = await apiData<{ id: string }>("/surveys/start", { method: "POST", accessToken, body: JSON.stringify({ job_container_id: container.job_container_id }) });
			window.location.assign(`/surveyor/surveys/${survey.id}`);
		} catch (err) {
			setError(err instanceof Error ? err.message : "Survey gagal dimulai.");
			setStartingID(null);
		}
	};

  useEffect(() => { const timer = window.setTimeout(() => void loadRows(), 0); return () => window.clearTimeout(timer); }, [loadRows]);

  return (
    <div className="page-stack">
	  <PageHeader title={isNotStarted ? "Belum Dimulai" : "Job Saya"} description={isNotStarted ? "Daftar peti kemas aktif yang ditugaskan kepada Anda dan belum memiliki Survey." : "Daftar job dan peti kemas yang ditugaskan kepada Anda."} />
      <div className="toolbar">
		<label className="search-box"><Search size={17} /><span className="sr-only">Cari pekerjaan</span><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Cari pekerjaan" /></label>
		{!isNotStarted ? <select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}>
		  <option value="">Semua Status</option>
		  {Object.keys(jobStatusLabels).map((item) => <option key={item} value={item}>{jobStatusLabel(item)}</option>)}
		</select> : null}
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
	  {isNotStarted ? <DataTable
		rows={containerRows}
		isLoading={isLoading}
		emptyText="Tidak ada penugasan peti kemas yang belum dimulai."
		page={page}
		totalPages={totalPages}
		onPageChange={setPage}
		columns={[
			{ key: "container_no", header: "Peti Kemas", render: (row) => <strong>{row.container_no}</strong> },
			{ key: "job", header: "Job / Penugasan", render: (row) => <><Link className="text-link" href={`/surveyor/jobs/${row.job_order_id}`}>{row.job_order_no}</Link><br /><span className="muted-text">{row.assignment_no ?? "-"}</span></> },
			{ key: "customer", header: "Customer / Lokasi", render: (row) => <><strong>{row.customer_name}</strong><br /><span className="muted-text">{row.location_name}</span></> },
			{ key: "survey_type", header: "Jenis Pemeriksaan", render: (row) => row.survey_type_name },
			{ key: "due", header: "Batas Waktu", render: (row) => row.effective_due_at ?? "-" },
			{ key: "instruction", header: "Instruksi", render: (row) => row.assignment_instruction ?? "-" },
			{ key: "action", header: "Aksi", render: (row) => <button className="primary-button table-action" type="button" disabled={Boolean(startingID)} onClick={() => void startSurvey(row)}><Play size={15} /><span>{startingID === row.job_container_id ? "Memulai..." : "Mulai Survey"}</span></button> },
		]}
	  /> : <DataTable
        rows={rows}
        isLoading={isLoading}
        page={page}
        totalPages={totalPages}
        onPageChange={setPage}
        columns={[
          { key: "job_order_no", header: "Nomor Job", render: (row) => <Link className="text-link" href={`/surveyor/jobs/${row.id}`}>{row.job_order_no}</Link> },
          { key: "assignment_no", header: "Penugasan", render: (row) => row.assignment_no ?? "-" },
          { key: "customer", header: "Customer", render: (row) => row.customer_name },
          { key: "location", header: "Lokasi", render: (row) => row.location_name },
          { key: "survey_type", header: "Jenis Pemeriksaan", render: (row) => row.survey_type_name },
          { key: "progress", header: "Progres", render: (row) => `${row.completed_containers ?? 0}/${row.total_containers ?? 0}` },
          { key: "deadline", header: "Batas Waktu", render: (row) => row.deadline ?? "-" },
          { key: "instruction", header: "Instruksi", render: (row) => row.assignment_instruction ?? "-" },
          { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "assigned" ? "warning" : "success"}>{jobStatusLabel(row.status)}</StatusBadge> }
        ]}
	  />}
    </div>
  );
}
