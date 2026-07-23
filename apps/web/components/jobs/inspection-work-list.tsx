"use client";

import { AlertTriangle, Plus, RotateCcw, Search, Upload, UserRoundCheck } from "lucide-react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { useCallback, useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/ui/page-header";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { StatusBadge } from "@/components/ui/status-badge";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { useAuth } from "@/hooks/use-auth";
import { loadInspectionWorkDataset, matchesInspectionView } from "@/lib/inspection-work";
import { can } from "@/lib/permissions";
import type { InspectionWorkRow, InspectionWorkStage, InspectionWorkView } from "@/types/inspection-work";

const validViews: InspectionWorkView[] = ["all", "unassigned", "in-progress", "pending-review", "need-revision", "approved", "completed"];
const viewCopy: Record<InspectionWorkView, { title: string; description: string }> = {
  all: { title: "Semua Pekerjaan", description: "Pusat perjalanan pekerjaan inspeksi dari dibuat sampai selesai." },
  unassigned: { title: "Belum Ditugaskan", description: "Pekerjaan yang siap dilengkapi dan belum memiliki Surveyor GIFT aktif." },
  "in-progress": { title: "Sedang Berjalan", description: "Monitoring penugasan dan pemeriksaan aktif tanpa mengubah hasil teknis Surveyor." },
  "pending-review": { title: "Menunggu Review", description: "Monitoring hasil Surveyor yang sudah disubmit ke antrean review." },
  "need-revision": { title: "Perlu Revisi", description: "Monitoring pekerjaan yang dikembalikan Reviewer untuk diperbaiki Surveyor." },
  approved: { title: "Disetujui", description: "Pekerjaan yang sudah disetujui tetapi belum melengkapi seluruh metadata dokumen." },
  completed: { title: "Selesai", description: "Pekerjaan dengan pemeriksaan, keputusan, dan metadata dokumen yang lengkap." }
};

const workTabs = [
  { id: "all", label: "Semua" },
  { id: "unassigned", label: "Belum Ditugaskan" },
  { id: "in-progress", label: "Sedang Diperiksa" },
  { id: "pending-review", label: "Menunggu Review" },
  { id: "need-revision", label: "Perlu Revisi" },
  { id: "approved", label: "Disetujui" },
  { id: "completed", label: "Selesai" }
] as const;

type Filters = {
  search: string;
  customer: string;
  location: string;
  surveyType: string;
  surveyor: string;
  status: string;
  stage: string;
  dateFrom: string;
  dateTo: string;
  deadlineTo: string;
  overdue: string;
};

const emptyFilters: Filters = {
  search: "", customer: "", location: "", surveyType: "", surveyor: "", status: "", stage: "",
  dateFrom: "", dateTo: "", deadlineTo: "", overdue: ""
};

export function InspectionWorkList() {
  const searchParams = useSearchParams();
  const requestedView = searchParams.get("view") ?? "all";
  const view: InspectionWorkView = validViews.includes(requestedView as InspectionWorkView) ? requestedView as InspectionWorkView : "all";
  const compat = searchParams.get("compat");
  const { accessToken, user } = useAuth();
  const [rows, setRows] = useState<InspectionWorkRow[]>([]);
  const [warnings, setWarnings] = useState<string[]>([]);
  const [filters, setFilters] = useState<Filters>(emptyFilters);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const canCreate = can(user, "jobs.create.all");
  const copy = viewCopy[view];

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const dataset = await loadInspectionWorkDataset(accessToken);
      setRows(dataset.rows);
      setWarnings(dataset.warnings);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil pekerjaan inspeksi.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  useEffect(() => setFilters(emptyFilters), [view]);

  const viewRows = useMemo(() => rows.filter((row) => matchesInspectionView(row, view)), [rows, view]);
  const filteredRows = useMemo(() => viewRows.filter((row) => matchesFilters(row, filters)), [filters, viewRows]);
  const options = useMemo(() => ({
    customers: unique(viewRows.map((row) => row.job.customer_name)),
    locations: unique(viewRows.map((row) => row.job.location_name)),
    surveyTypes: unique(viewRows.map((row) => row.job.survey_type_name)),
    surveyors: unique(viewRows.flatMap((row) => row.surveyorNames)),
    statuses: unique(viewRows.map((row) => row.job.status))
  }), [viewRows]);
  const totalContainers = filteredRows.reduce((total, row) => total + (row.job.containers?.length ?? 0), 0);
  const columns = useMemo(() => workColumns(view), [view]);

  return (
    <div className="page-stack inspection-workspace">
      <PageHeader
        title={copy.title}
        description={copy.description}
        action={canCreate ? { label: "Buat Job/SPK", icon: Plus, onClick: () => window.location.assign("/jobs/create") } : undefined}
      />
      <WorkspaceTabs
        activeID={view}
        label="Filter tahap Pekerjaan Inspeksi"
        tabs={workTabs.map((tab) => ({ id: tab.id, label: tab.label, href: tab.id === "all" ? "/jobs" : "/jobs?view=" + tab.id }))}
      />
      {compat ? <CompatibilityNotice type={compat} /> : null}
      {error ? <div className="alert alert-danger">{error}</div> : null}
      {warnings.map((warning) => <div className="alert alert-warning" key={warning}>{warning}</div>)}

      <section aria-label="Ringkasan pekerjaan" className="metric-grid inspection-summary-grid">
        <Metric label="Pekerjaan" value={filteredRows.length} />
        <Metric label="Peti Kemas" value={totalContainers} />
        <Metric label="Terlambat" value={filteredRows.filter((row) => row.isOverdue).length} />
        <Metric label="Menunggu Review" value={filteredRows.filter((row) => row.reviewStatus === "Menunggu review").length} />
      </section>

      <InspectionWorkFilter filters={filters} onChange={setFilters} onReset={() => setFilters(emptyFilters)} options={options} />

      {isLoading ? <div className="workspace-panel inspection-loading">Memuat dan menyelaraskan pekerjaan, survey, serta metadata dokumen...</div> : (
        <ResponsiveTableCards
          columns={columns}
          rows={filteredRows}
          getRowId={(row) => row.id}
          getRowTitle={(row) => row.job.job_order_no}
          emptyText="Pekerjaan dengan kriteria ini belum tersedia."
          label={`Daftar ${copy.title}`}
          pageSize={10}
        />
      )}
    </div>
  );
}

function InspectionWorkFilter({
  filters,
  onChange,
  onReset,
  options
}: {
  filters: Filters;
  onChange: React.Dispatch<React.SetStateAction<Filters>>;
  onReset: () => void;
  options: { customers: string[]; locations: string[]; surveyTypes: string[]; surveyors: string[]; statuses: string[] };
}) {
  const set = (key: keyof Filters, value: string) => onChange((current) => ({ ...current, [key]: value }));
  return (
    <section aria-label="Filter pekerjaan inspeksi" className="inspection-filter-panel">
      <label className="search-box inspection-search"><Search size={17} /><span className="sr-only">Cari nomor pekerjaan</span><input value={filters.search} onChange={(event) => set("search", event.target.value)} placeholder="Cari nomor pekerjaan atau referensi" /></label>
      <FilterSelect label="Customer" value={filters.customer} options={options.customers} onChange={(value) => set("customer", value)} />
      <FilterSelect label="Location" value={filters.location} options={options.locations} onChange={(value) => set("location", value)} />
      <FilterSelect label="Survey Type" value={filters.surveyType} options={options.surveyTypes} onChange={(value) => set("surveyType", value)} />
      <FilterSelect label="Surveyor GIFT" value={filters.surveyor} options={options.surveyors} onChange={(value) => set("surveyor", value)} />
      <FilterSelect label="Status Pekerjaan" value={filters.status} options={options.statuses} onChange={(value) => set("status", value)} />
      <FilterSelect label="Tahap Proses" value={filters.stage} options={["draft", "unassigned", "in-progress", "pending-review", "need-revision", "completed"]} onChange={(value) => set("stage", value)} />
      <DateFilter label="Periode dari" value={filters.dateFrom} max={filters.dateTo || undefined} onChange={(value) => set("dateFrom", value)} />
      <DateFilter label="Periode sampai" value={filters.dateTo} min={filters.dateFrom || undefined} onChange={(value) => set("dateTo", value)} />
      <DateFilter label="Deadline sampai" value={filters.deadlineTo} onChange={(value) => set("deadlineTo", value)} />
      <FilterSelect label="Keterlambatan" value={filters.overdue} options={["overdue", "on-time"]} labels={{ overdue: "Terlambat", "on-time": "Tidak terlambat" }} onChange={(value) => set("overdue", value)} />
      <button className="secondary-button inspection-reset" onClick={onReset} type="button"><RotateCcw size={16} /><span>Reset Filter</span></button>
    </section>
  );
}

function workColumns(view: InspectionWorkView): ResponsiveColumn<InspectionWorkRow>[] {
  const columns: ResponsiveColumn<InspectionWorkRow>[] = [
    { key: "job", header: "Nomor Pekerjaan", render: (row) => <Link className="text-link" href={`/jobs/${row.id}`}>{row.job.job_order_no}</Link> },
    { key: "date", header: "Tanggal", render: (row) => formatDate(row.job.job_date) },
    { key: "customer", header: "Customer", render: (row) => row.job.customer_name },
    { key: "location", header: "Location / Survey Type", render: (row) => <><strong>{row.job.location_name}</strong><br /><span className="muted-text">{row.job.survey_type_name}</span></> },
    { key: "containers", header: "Peti Kemas", render: (row) => `${row.completedContainers}/${row.job.containers?.length ?? 0} selesai` },
    { key: "surveyor", header: "Surveyor GIFT", render: (row) => row.surveyorNames.join(", ") || "Belum ditugaskan" },
    { key: "assignment", header: "Penugasan", render: (row) => <StatusBadge tone={row.surveyorNames.length > 0 ? "success" : "warning"}>{row.assignmentStatus}</StatusBadge> },
    { key: "progress", header: "Progress Pemeriksaan", render: (row) => <div className="inspection-progress-cell"><strong>{row.progressPercent}%</strong><span>{row.findingCount} temuan / {row.photoCount} foto</span></div> },
    { key: "review", header: "Status Review", render: (row) => <StatusBadge tone={reviewTone(row.reviewStatus)}>{row.reviewStatus}</StatusBadge> },
    { key: "document", header: "Status Dokumen", render: (row) => <StatusBadge tone={row.documents.length > 0 ? "success" : "neutral"}>{humanize(row.documentStatus)}</StatusBadge> },
    { key: "deadline", header: "Deadline", render: (row) => <><span>{formatDate(row.job.deadline)}</span>{row.isOverdue ? <><br /><StatusBadge tone="danger">Terlambat</StatusBadge></> : null}</> },
    { key: "updated", header: "Pembaruan Terakhir", render: (row) => formatDateTime(row.lastUpdated) }
  ];
  if (view === "unassigned") {
    columns.splice(7, 0, { key: "readiness", header: "Readiness", render: (row) => <ReadinessChecklist row={row} /> });
  }
  if (view === "pending-review") {
    columns.splice(9, 0,
      { key: "reviewer", header: "Reviewer / Supervisor", render: () => "Belum ditetapkan" },
      { key: "queue", header: "Antrean Review", render: (row) => `Disubmit ${formatDateTime(row.surveys.find((item) => item.status === "submitted")?.submitted_at)}` }
    );
  }
  if (view === "need-revision") {
    columns.splice(9, 0, { key: "revision", header: "Informasi Revisi", render: (row) => <RevisionSummary row={row} /> });
  }
  columns.push({ key: "actions", header: "Aksi", render: (row) => <WorkActions row={row} view={view} /> });
  return columns;
}

function WorkActions({ row, view }: { row: InspectionWorkRow; view: InspectionWorkView }) {
  return <div className="row-actions inspection-row-actions">
    <Link className="secondary-button table-action" href={`/jobs/${row.id}`}>Buka Detail</Link>
    {view === "unassigned" ? <Link aria-label={`Import peti kemas ${row.job.job_order_no}`} className="secondary-button table-action" href={`/jobs/${row.id}?tab=peti-kemas`}><Upload size={15} /><span>Import</span></Link> : null}
    {view === "unassigned" ? <Link aria-label={`Tugaskan Surveyor GIFT ${row.job.job_order_no}`} className="primary-button table-action" href={`/jobs/${row.id}?tab=penugasan&action=assign`}><UserRoundCheck size={15} /><span>Tugaskan</span></Link> : null}
  </div>;
}

function ReadinessChecklist({ row }: { row: InspectionWorkRow }) {
  return <ul className="inspection-readiness">{row.readiness.map((item) => <li className={item.ready ? "readiness-ready" : "readiness-missing"} key={item.label}><span aria-hidden="true">{item.ready ? "✓" : "–"}</span>{item.label}</li>)}</ul>;
}

function RevisionSummary({ row }: { row: InspectionWorkRow }) {
  const history = row.surveyDetails.flatMap((item) => item.approval_history ?? []).filter((item) => String(item.decision) === "need_revision");
  const latest = history[0];
  return <div className="inspection-revision-summary"><strong>{String(latest?.review_note ?? "Catatan revisi belum tersedia")}</strong><span>Diminta: {formatDateTime(latest?.reviewed_at ? String(latest.reviewed_at) : null)}</span><span>Deadline revisi khusus: Belum tersedia</span><span>{history.length} permintaan revisi</span></div>;
}

function CompatibilityNotice({ type }: { type: string }) {
  const message = type === "import"
    ? "Pilih pekerjaan, lalu gunakan Import Peti Kemas pada tab Peti Kemas."
    : type === "assign"
      ? "Pilih pekerjaan, lalu gunakan Tugaskan Surveyor GIFT pada tab Penugasan."
      : "Gunakan filter Pekerjaan Inspeksi untuk melihat perkembangan pemeriksaan.";
  return <div className="alert alert-warning inspection-compat-notice"><AlertTriangle size={18} /><span>{message}</span></div>;
}

function FilterSelect({ label, value, options, labels = {}, onChange }: { label: string; value: string; options: string[]; labels?: Record<string, string>; onChange: (value: string) => void }) {
  return <label className="field"><span>{label}</span><select value={value} onChange={(event) => onChange(event.target.value)}><option value="">Semua</option>{options.map((option) => <option key={option} value={option}>{labels[option] ?? humanize(option)}</option>)}</select></label>;
}

function DateFilter({ label, value, min, max, onChange }: { label: string; value: string; min?: string; max?: string; onChange: (value: string) => void }) {
  return <label className="field"><span>{label}</span><input type="date" value={value} min={min} max={max} onChange={(event) => onChange(event.target.value)} /></label>;
}

function Metric({ label, value }: { label: string; value: number }) {
  return <div className="metric-tile"><p>{label}</p><strong>{value}</strong></div>;
}

function matchesFilters(row: InspectionWorkRow, filters: Filters): boolean {
  const search = filters.search.trim().toLowerCase();
  if (search && !`${row.job.job_order_no} ${row.job.reference_no ?? ""}`.toLowerCase().includes(search)) return false;
  if (filters.customer && row.job.customer_name !== filters.customer) return false;
  if (filters.location && row.job.location_name !== filters.location) return false;
  if (filters.surveyType && row.job.survey_type_name !== filters.surveyType) return false;
  if (filters.surveyor && !row.surveyorNames.includes(filters.surveyor)) return false;
  if (filters.status && row.job.status !== filters.status) return false;
  if (filters.stage && row.stage !== filters.stage) return false;
  if (filters.dateFrom && row.job.job_date < filters.dateFrom) return false;
  if (filters.dateTo && row.job.job_date > filters.dateTo) return false;
  if (filters.deadlineTo && (!row.job.deadline || row.job.deadline.slice(0, 10) > filters.deadlineTo)) return false;
  if (filters.overdue === "overdue" && !row.isOverdue) return false;
  if (filters.overdue === "on-time" && row.isOverdue) return false;
  return true;
}

function reviewTone(status: string): "success" | "warning" | "danger" | "neutral" {
  if (status === "Disetujui") return "success";
  if (status === "Perlu revisi" || status === "Ditolak") return "danger";
  if (status === "Menunggu review") return "warning";
  return "neutral";
}

function formatDate(value?: string | null) {
  if (!value) return "Belum tersedia";
  const date = new Date(value.length === 10 ? `${value}T00:00:00` : value);
  return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium" }).format(date);
}

function formatDateTime(value?: string | null) {
  if (!value) return "Belum tersedia";
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(date);
}

function humanize(value: string) {
  return value.replaceAll("_", " ").replaceAll("-", " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function unique(values: string[]) {
  return Array.from(new Set(values.filter(Boolean))).sort((a, b) => a.localeCompare(b));
}

export function inspectionStageLabel(stage: InspectionWorkStage) {
  return humanize(stage);
}
