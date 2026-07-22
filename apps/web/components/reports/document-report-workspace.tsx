"use client";

import { RotateCcw, Search } from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { useCallback, useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/ui/page-header";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { StatusBadge } from "@/components/ui/status-badge";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { loadAllPages } from "@/lib/inspection-work";
import type { ReportSummary, ReviewDetail } from "@/types/reviews";
import type { SurveyListItem } from "@/types/surveys";

type DocumentRow = { report: ReportSummary; review?: ReviewDetail };
type RecapRow = {
  id: string;
  jobOrderNo: string;
  customer: string;
  location: string;
  surveyType: string;
  surveyor: string;
  containers: number;
  inspections: number;
  status: string;
  result: string;
  date: string;
};
type ReportFilters = { search: string; customer: string; location: string; surveyType: string; surveyor: string; status: string; result: string; dateFrom: string; dateTo: string };

const emptyFilters: ReportFilters = { search: "", customer: "", location: "", surveyType: "", surveyor: "", status: "", result: "", dateFrom: "", dateTo: "" };

export function DocumentReportWorkspace() {
  const requestedView = useSearchParams().get("view");
  const view = requestedView === "recap" ? "recap" : requestedView === "archive" ? "archive" : "reports";
  const { accessToken } = useAuth();
  const [documents, setDocuments] = useState<DocumentRow[]>([]);
  const [recaps, setRecaps] = useState<RecapRow[]>([]);
  const [filters, setFilters] = useState<ReportFilters>(emptyFilters);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const [reports, surveys] = await Promise.all([
        loadAllPages<ReportSummary>("/reports", accessToken),
        loadAllPages<SurveyListItem>("/surveys/monitoring", accessToken)
      ]);
      const reviews = (await mapConcurrent(surveys, 6, (survey) => apiData<ReviewDetail>(`/reviews/${survey.survey_id}`, { accessToken }).catch(() => null)))
        .filter((item): item is ReviewDetail => item !== null);
      const reviewBySurvey = new Map(reviews.map((review) => [review.survey_no, review]));
      setDocuments(reports.map((report) => ({ report, review: reviewBySurvey.get(report.survey_no) })));
      setRecaps(buildRecaps(reviews));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil Dokumen & Laporan.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadData(), 0);
    return () => window.clearTimeout(timer);
  }, [loadData]);

  useEffect(() => setFilters(emptyFilters), [view]);

  const rows = useMemo(() => view === "recap"
    ? recaps.filter((row) => matchesRecap(row, filters))
    : documents.filter((row) => matchesDocument(row, filters)), [documents, filters, recaps, view]);
  const sourceRows = view === "recap" ? recaps : documents.map(documentFilterSource);
  const options = {
    customers: unique(sourceRows.map((row) => row.customer)),
    locations: unique(sourceRows.map((row) => row.location)),
    surveyTypes: unique(sourceRows.map((row) => row.surveyType)),
    surveyors: unique(sourceRows.map((row) => row.surveyor)),
    statuses: unique(sourceRows.map((row) => row.status)),
    results: unique(sourceRows.map((row) => row.result))
  };

  return <div className="page-stack document-report-workspace">
    <PageHeader
      title={view === "archive" ? "Arsip Laporan" : view === "recap" ? "Rekap Pemeriksaan" : "Laporan Pemeriksaan"}
      description={view === "archive" ? "Arsip metadata laporan dan akses ke riwayat versi pada detail." : view === "recap" ? "Rekap berdasarkan data existing." : "Laporan hasil pemeriksaan; PDF final dan QR belum aktif."}
    />
    <WorkspaceTabs activeID={view === "archive" ? "archive" : "reports"} label="Dokumen dan Laporan" tabs={[
      { id: "reports", label: "Laporan Pemeriksaan", href: "/reports" },
      { id: "archive", label: "Arsip Laporan", href: "/reports?view=archive" }
    ]} />
    {error ? <div className="alert alert-danger">{error}</div> : null}
    <ReportFilter filters={filters} onChange={setFilters} onReset={() => setFilters(emptyFilters)} options={options} />
    {isLoading ? <div className="workspace-panel inspection-loading">Memuat metadata dokumen dan hasil pemeriksaan...</div> : view !== "recap" ? (
      <ResponsiveTableCards columns={documentColumns} rows={rows as DocumentRow[]} getRowId={(row) => row.report.id} getRowTitle={(row) => row.report.report_no} emptyText="Metadata dokumen belum tersedia." label="Daftar Dokumen Kelaikan" pageSize={10} />
    ) : (
      <>
        <section className="metric-grid inspection-summary-grid"><Metric label="Pekerjaan" value={(rows as RecapRow[]).length} /><Metric label="Peti Kemas" value={(rows as RecapRow[]).reduce((sum, row) => sum + row.containers, 0)} /><Metric label="Pemeriksaan" value={(rows as RecapRow[]).reduce((sum, row) => sum + row.inspections, 0)} /><Metric label="Disetujui" value={(rows as RecapRow[]).filter((row) => row.status === "approved").length} /></section>
        <ResponsiveTableCards columns={recapColumns} rows={rows as RecapRow[]} getRowId={(row) => row.id} getRowTitle={(row) => row.jobOrderNo} emptyText="Rekap pemeriksaan belum tersedia." label="Rekap Pemeriksaan" pageSize={10} />
      </>
    )}
  </div>;
}

const documentColumns: ResponsiveColumn<DocumentRow>[] = [
  { key: "number", header: "Nomor Dokumen", render: (row) => <Link className="text-link" href={`/reports/${row.report.id}`}>{row.report.report_no}</Link> },
  { key: "job", header: "Nomor Pekerjaan", render: (row) => row.report.job_order_no },
  { key: "customer", header: "Customer", render: (row) => row.report.customer_name },
  { key: "container", header: "Peti Kemas", render: (row) => row.report.container_no },
  { key: "surveyType", header: "Survey Type", render: (row) => row.review?.survey_type_name ?? "Belum tersedia" },
  { key: "result", header: "Hasil Review", render: (row) => humanize(row.review?.survey_result ?? row.review?.status ?? "belum tersedia") },
  { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.report.status === "failed" ? "danger" : "warning"}>{humanize(row.report.status)}</StatusBadge> },
  { key: "version", header: "Versi", render: (row) => `Rev. ${row.report.revision_no ?? 0}` },
  { key: "signer", header: "Penandatangan", render: () => "Belum tersedia" },
  { key: "date", header: "Tanggal", render: (row) => formatDate(row.report.created_at) },
  { key: "action", header: "Aksi", render: (row) => <Link className="secondary-button table-action" href={`/reports/${row.report.id}`}>Lihat Metadata</Link> }
];

const recapColumns: ResponsiveColumn<RecapRow>[] = [
  { key: "job", header: "Nomor Pekerjaan", render: (row) => row.jobOrderNo },
  { key: "customer", header: "Customer", render: (row) => row.customer },
  { key: "location", header: "Location", render: (row) => row.location },
  { key: "surveyType", header: "Survey Type", render: (row) => row.surveyType },
  { key: "surveyor", header: "Surveyor GIFT", render: (row) => row.surveyor },
  { key: "containers", header: "Peti Kemas", render: (row) => row.containers },
  { key: "inspections", header: "Pemeriksaan", render: (row) => row.inspections },
  { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "approved" ? "success" : row.status === "need_revision" || row.status === "rejected" ? "danger" : "warning"}>{humanize(row.status)}</StatusBadge> },
  { key: "result", header: "Hasil Kelaikan", render: (row) => humanize(row.result) },
  { key: "date", header: "Periode", render: (row) => formatDate(row.date) }
];

function ReportFilter({ filters, onChange, onReset, options }: { filters: ReportFilters; onChange: React.Dispatch<React.SetStateAction<ReportFilters>>; onReset: () => void; options: { customers: string[]; locations: string[]; surveyTypes: string[]; surveyors: string[]; statuses: string[]; results: string[] } }) {
  const set = (key: keyof ReportFilters, value: string) => onChange((current) => ({ ...current, [key]: value }));
  return <section aria-label="Filter Dokumen dan Laporan" className="inspection-filter-panel">
    <label className="search-box inspection-search"><Search size={17} /><span className="sr-only">Cari dokumen atau pekerjaan</span><input value={filters.search} onChange={(event) => set("search", event.target.value)} placeholder="Cari dokumen, pekerjaan, atau peti kemas" /></label>
    <SelectFilter label="Customer" value={filters.customer} options={options.customers} onChange={(value) => set("customer", value)} />
    <SelectFilter label="Location" value={filters.location} options={options.locations} onChange={(value) => set("location", value)} />
    <SelectFilter label="Survey Type" value={filters.surveyType} options={options.surveyTypes} onChange={(value) => set("surveyType", value)} />
    <SelectFilter label="Surveyor GIFT" value={filters.surveyor} options={options.surveyors} onChange={(value) => set("surveyor", value)} />
    <SelectFilter label="Status" value={filters.status} options={options.statuses} onChange={(value) => set("status", value)} />
    <SelectFilter label="Hasil" value={filters.result} options={options.results} onChange={(value) => set("result", value)} />
    <DateFilter label="Periode dari" value={filters.dateFrom} max={filters.dateTo || undefined} onChange={(value) => set("dateFrom", value)} />
    <DateFilter label="Periode sampai" value={filters.dateTo} min={filters.dateFrom || undefined} onChange={(value) => set("dateTo", value)} />
    <button className="secondary-button inspection-reset" onClick={onReset} type="button"><RotateCcw size={16} /><span>Reset Filter</span></button>
  </section>;
}

function buildRecaps(reviews: ReviewDetail[]): RecapRow[] {
  const grouped = new Map<string, ReviewDetail[]>();
  for (const review of reviews) grouped.set(review.job_order_no, [...(grouped.get(review.job_order_no) ?? []), review]);
  return Array.from(grouped.entries()).map(([jobOrderNo, items]) => {
    const statuses = items.map((item) => item.status);
    const status = statuses.includes("need_revision") ? "need_revision" : statuses.includes("submitted") ? "submitted" : statuses.every((item) => item === "approved") ? "approved" : statuses[0] ?? "draft";
    return {
      id: jobOrderNo,
      jobOrderNo,
      customer: items[0]?.customer_name ?? "Belum tersedia",
      location: items[0]?.location_name ?? "Belum tersedia",
      surveyType: items[0]?.survey_type_name ?? "Belum tersedia",
      surveyor: unique(items.map((item) => item.surveyor_name)).join(", ") || "Belum tersedia",
      containers: unique(items.map((item) => item.container_no)).length,
      inspections: items.length,
      status,
      result: unique(items.map((item) => item.survey_result ?? item.survey_result_recommendation ?? "belum tersedia")).join(", "),
      date: latestDate(items.map((item) => item.submitted_at ?? "").filter(Boolean))
    };
  });
}

function matchesDocument(row: DocumentRow, filters: ReportFilters) {
  const source = documentFilterSource(row);
  return matchesSource(source, filters, `${row.report.report_no} ${row.report.job_order_no} ${row.report.container_no}`);
}

function matchesRecap(row: RecapRow, filters: ReportFilters) {
  return matchesSource(row, filters, `${row.jobOrderNo} ${row.customer}`);
}

function matchesSource(source: RecapRow, filters: ReportFilters, searchable: string) {
  if (filters.search && !searchable.toLowerCase().includes(filters.search.toLowerCase())) return false;
  if (filters.customer && source.customer !== filters.customer) return false;
  if (filters.location && source.location !== filters.location) return false;
  if (filters.surveyType && source.surveyType !== filters.surveyType) return false;
  if (filters.surveyor && source.surveyor !== filters.surveyor) return false;
  if (filters.status && source.status !== filters.status) return false;
  if (filters.result && source.result !== filters.result) return false;
  if (filters.dateFrom && source.date.slice(0, 10) < filters.dateFrom) return false;
  if (filters.dateTo && source.date.slice(0, 10) > filters.dateTo) return false;
  return true;
}

function documentFilterSource(row: DocumentRow): RecapRow {
  return { id: row.report.id, jobOrderNo: row.report.job_order_no, customer: row.report.customer_name, location: row.review?.location_name ?? "Belum tersedia", surveyType: row.review?.survey_type_name ?? "Belum tersedia", surveyor: row.review?.surveyor_name ?? "Belum tersedia", containers: 1, inspections: 1, status: row.report.status, result: row.review?.survey_result ?? row.review?.status ?? "Belum tersedia", date: row.report.created_at };
}

function SelectFilter({ label, value, options, onChange }: { label: string; value: string; options: string[]; onChange: (value: string) => void }) {
  return <label className="field"><span>{label}</span><select value={value} onChange={(event) => onChange(event.target.value)}><option value="">Semua</option>{options.map((option) => <option key={option} value={option}>{humanize(option)}</option>)}</select></label>;
}

function DateFilter({ label, value, min, max, onChange }: { label: string; value: string; min?: string; max?: string; onChange: (value: string) => void }) {
  return <label className="field"><span>{label}</span><input type="date" value={value} min={min} max={max} onChange={(event) => onChange(event.target.value)} /></label>;
}

function Metric({ label, value }: { label: string; value: number }) { return <div className="metric-tile"><p>{label}</p><strong>{value}</strong></div>; }
function formatDate(value?: string | null) { if (!value) return "Belum tersedia"; const date = new Date(value); return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium" }).format(date); }
function humanize(value: string) { return value.replaceAll("_", " ").replaceAll("-", " ").replace(/\b\w/g, (letter) => letter.toUpperCase()); }
function unique(values: string[]) { return Array.from(new Set(values.filter(Boolean))).sort((a, b) => a.localeCompare(b)); }
function latestDate(values: string[]) { return values.reduce((latest, value) => !latest || new Date(value).getTime() > new Date(latest).getTime() ? value : latest, ""); }

async function mapConcurrent<T, R>(items: T[], limit: number, worker: (item: T) => Promise<R>): Promise<R[]> {
  const results = new Array<R>(items.length); let cursor = 0;
  async function run() { while (cursor < items.length) { const index = cursor; cursor += 1; results[index] = await worker(items[index]); } }
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, () => run()));
  return results;
}
