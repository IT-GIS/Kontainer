"use client";

import { Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import { loadOptions } from "@/lib/options";
import type { OptionItem } from "@/types/jobs";
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
  const [surveyorID, setSurveyorID] = useState("");
  const [locationID, setLocationID] = useState("");
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [surveyors, setSurveyors] = useState<OptionItem[]>([]);
  const [locations, setLocations] = useState<OptionItem[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<SurveyListItem>(
        `${endpoint}${buildQuery({ page, per_page: 10, search, status: fixedStatus || status, surveyor_id: surveyorID, location_id: locationID, date_from: dateFrom, date_to: dateTo })}`,
        { accessToken }
      );
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil daftar survey.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, dateFrom, dateTo, endpoint, fixedStatus, locationID, page, search, status, surveyorID]);

  useEffect(() => {
    if (!accessToken || endpoint !== "/surveys/monitoring") return;
    void Promise.all([
      loadOptions(accessToken, "/master/surveyors", "name", "surveyor_code"),
      loadOptions(accessToken, "/master/locations", "location_name", "location_code")
    ]).then(([people, places]) => { setSurveyors(people); setLocations(places); }).catch(() => undefined);
  }, [accessToken, endpoint]);

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
      {endpoint === "/surveys/monitoring" ? (
        <div className="monitoring-filter-toolbar">
          <label className="field"><span>Surveyor</span><select value={surveyorID} onChange={(event) => { setPage(1); setSurveyorID(event.target.value); }}><option value="">All Surveyors</option>{surveyors.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select></label>
          <label className="field"><span>Location</span><select value={locationID} onChange={(event) => { setPage(1); setLocationID(event.target.value); }}><option value="">All Locations</option>{locations.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select></label>
          <label className="field"><span>Date From</span><input type="date" max={dateTo || undefined} value={dateFrom} onChange={(event) => { setPage(1); setDateFrom(event.target.value); }} /></label>
          <label className="field"><span>Date To</span><input type="date" min={dateFrom || undefined} value={dateTo} onChange={(event) => { setPage(1); setDateTo(event.target.value); }} /></label>
        </div>
      ) : null}
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
