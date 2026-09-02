"use client";

import { useParams } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { SurveySheetFieldSourceBadge, type SurveySheetFieldSource } from "@/components/ui/survey-sheet-field-source-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import type { ReportDetail, ReportVersion } from "@/types/reviews";

export default function ReportDetailPage() {
  return <ProtectedRoute><AppShell title="Metadata Dokumen Kelaikan"><ReportDetailContent /></AppShell></ProtectedRoute>;
}

function ReportDetailContent() {
  const params = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const [report, setReport] = useState<ReportDetail | null>(null);
  const [versions, setVersions] = useState<ReportVersion[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const loadReport = useCallback(async () => {
    if (!accessToken || !params.id) return;
    setIsLoading(true);
    setError(null);
    try {
      const [detail, versionRows] = await Promise.all([
        apiData<ReportDetail>(`/reports/${params.id}`, { accessToken }),
        apiData<ReportVersion[]>(`/reports/${params.id}/versions`, { accessToken })
      ]);
      setReport(detail);
      setVersions(versionRows);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil metadata dokumen.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, params.id]);

  useEffect(() => { const timer = window.setTimeout(() => void loadReport(), 0); return () => window.clearTimeout(timer); }, [loadReport]);

  if (isLoading && !report) return <div className="center-screen">Memuat metadata dokumen...</div>;
  if (!report) return <div className="alert alert-danger">{error ?? "Metadata dokumen tidak ditemukan."}</div>;

  return <div className="page-stack">
    <PageHeader title={report.report_no} description={`${report.customer_name} — ${report.container_no}`} />
    {error ? <div className="alert alert-danger">{error}</div> : null}
    <div className="alert alert-warning">Halaman ini hanya menampilkan metadata dokumen. PDF final, QR, penandatangan, dan verifikasi publik belum aktif.</div>
    <section className="workspace-panel detail-grid">
      <div><span>Status</span><strong><StatusBadge tone={report.status === "failed" ? "danger" : "warning"}>{humanize(report.status)}</StatusBadge></strong></div>
      <div><span>Versi Aktif</span><strong>Rev. {report.current_version_no ?? report.revision_no ?? 0}</strong></div>
      <div><span>Nomor Survey</span><strong>{report.survey_no}</strong></div>
      <div><span>Nomor Pekerjaan</span><strong>{report.job_order_no}</strong></div>
      <div><span>Customer</span><strong>{report.customer_name}</strong></div>
      <div><span>Peti Kemas</span><strong>{report.container_no}</strong></div>
      <div><span>Hasil Review</span><strong>{report.survey_result ? humanize(report.survey_result) : "Belum tersedia"}</strong></div>
      <div><span>Jenis Dokumen</span><strong>{humanize(report.report_type)}</strong></div>
      <div><span>Penandatangan</span><strong>Belum tersedia</strong></div>
      <div><span>Dibuat</span><strong>{formatDateTime(report.created_at)}</strong></div>
      <div><span>Diperbarui</span><strong>{formatDateTime(report.updated_at)}</strong></div>
    </section>
    <SurveySheetReportHeader report={report} />
    <section className="workspace-panel job-tab-stack">
      <div><h2>Temuan Survey</h2><p className="muted-text">Data langsung dari survey_damages; tidak disalin atau diinput ulang pada Report.</p></div>
      <DataTable responsiveCards rows={report.damages ?? []} emptyText="Tidak ada Temuan pada Survey ini." columns={[
        { key: "no", header: "No.", render: (row) => String(row.damage_no ?? "-") },
        { key: "location", header: "Location", render: (row) => String(row.cedex_location_code ?? "-") },
        { key: "component", header: "Component", render: (row) => String(row.component_name ?? row.component_code ?? "-") },
        { key: "damage", header: "Damage", render: (row) => String(row.damage_name ?? row.damage_code ?? "-") },
        { key: "action", header: "Action / Repair", render: (row) => String(row.repair_name ?? row.repair_code ?? "-") },
        { key: "description", header: "Finding Description", render: (row) => String(row.finding_description ?? "-") },
        { key: "decision", header: "Decision", render: (row) => humanize(String(row.decision_result ?? "belum tersedia")) }
      ]} />
    </section>
    <section className="workspace-panel job-tab-stack">
      <div><h2>Foto / Evidence</h2><p className="muted-text">Metadata file yang sama dengan Survey dan Review; tidak ada upload ulang.</p></div>
      <DataTable responsiveCards rows={report.photos ?? []} emptyText="Belum ada Foto / Evidence." columns={[
        { key: "file", header: "File", render: (row) => String(row.original_file_name ?? "-") },
        { key: "scope", header: "Scope", render: (row) => row.damage_id ? `Finding ${String(row.damage_id)}` : "General Survey" },
        { key: "category", header: "Category", render: (row) => humanize(String(row.photo_category ?? row.photo_type ?? "belum tersedia")) },
        { key: "caption", header: "Caption", render: (row) => String(row.caption ?? "-") },
        { key: "created", header: "Waktu", render: (row) => formatDateTime(typeof row.created_at === "string" ? row.created_at : null) }
      ]} />
    </section>
    <section className="workspace-panel job-tab-stack">
      <div><h2>Riwayat Versi</h2><p className="muted-text">Metadata versi existing tanpa file PDF final.</p></div>
      <DataTable rows={versions} emptyText="Riwayat versi belum tersedia." columns={[
        { key: "version", header: "Versi", render: (row) => `Rev. ${row.version_no}` },
        { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "draft" ? "warning" : "success"}>{humanize(row.status)}</StatusBadge> },
        { key: "reason", header: "Alasan Perubahan", render: (row) => row.change_reason ?? "Belum tersedia" },
        { key: "creator", header: "Dibuat Oleh", render: () => "Belum tersedia pada kontrak existing" },
        { key: "created", header: "Waktu", render: (row) => formatDateTime(row.created_at) },
        { key: "active", header: "Versi Aktif", render: (row) => row.version_no === (report.current_version_no ?? report.revision_no) ? <StatusBadge tone="success">Aktif</StatusBadge> : "-" }
      ]} />
    </section>
  </div>;
}

function SurveySheetReportHeader({ report }: { report: ReportDetail }) {
  const rows: Array<{ label: string; value: string; source: SurveySheetFieldSource }> = [
    { label: "Customer / Client", value: report.customer_name, source: "Customer" },
    { label: "Container Nbrs", value: report.container_no, source: "Peti Kemas" },
    { label: "Type of Survey", value: displayValue(report.survey_type_name), source: "Job" },
    { label: "Size", value: report.container_size ? `${report.container_size} feet` : "Belum tersedia", source: "Peti Kemas" },
    { label: "Manufacture", value: displayValue(report.manufacture_date), source: "Peti Kemas" },
    { label: "MTY / FULL (Data Awal)", value: formatCargoStatus(report.cargo_status_initial), source: "Peti Kemas" },
    { label: "Cargo Status Verifikasi", value: formatCargoStatus(report.cargo_status_verified), source: "Surveyor" },
    { label: "Type", value: [report.container_type_code, report.container_type_name].filter(Boolean).join(" - ") || "Belum tersedia", source: "Peti Kemas" },
    { label: "CSC Plate Status Awal", value: humanizeValue(report.csc_plate_status_initial), source: "Peti Kemas" },
    { label: "CSC Plate Status Verifikasi", value: humanizeValue(report.csc_plate_status_verified), source: "Surveyor" },
    { label: "CSC Plate Number", value: displayValue(report.csc_plate_number), source: "Peti Kemas" },
    { label: "CSC Program Type", value: displayValue(report.csc_program_type), source: "Peti Kemas" },
    { label: "Payload", value: formatWeight(report.payload), source: "Peti Kemas" },
    { label: "Survey Location", value: displayValue(report.location_name), source: "Job" },
    { label: "Tare", value: formatWeight(report.tare_weight), source: "Peti Kemas" },
    { label: "Date of Survey", value: formatDateTime(report.started_at), source: "Sistem" },
    { label: "Condition", value: canonicalValue(report.general_condition, ["DMG", "AVL", "AR"]), source: "Surveyor" },
    { label: "Cleanliness", value: canonicalValue(report.cleanliness, ["DTY", "CTM"]), source: "Surveyor" }
  ];
  return <section className="workspace-panel page-stack">
    <div className="section-title-row"><div><span className="eyebrow">Sumber existing</span><h2>Data Survey Sheet untuk Laporan</h2><p className="muted-text">Laporan hanya membaca snapshot Survey dan hasil verifikasi yang telah melalui workflow. Tidak ada input ulang pada modul Reports.</p></div></div>
    <div className="survey-sheet-summary-grid">{rows.map((row) => <div key={row.label}><span>{row.label}<SurveySheetFieldSourceBadge source={row.source} /></span><strong>{row.value}</strong></div>)}</div>
  </section>;
}

function formatDateTime(value?: string | null) { if (!value) return "Belum tersedia"; const date = new Date(value); return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(date); }
function displayValue(value: unknown) { return value == null || value === "" ? "Belum tersedia" : String(value); }
function formatCargoStatus(value?: string | null) { return value === "empty" ? "MTY (Empty)" : value === "laden" ? "FULL (Laden)" : "Belum tersedia"; }
function formatWeight(value?: number | null) { return value == null ? "Belum tersedia" : `${new Intl.NumberFormat("id-ID", { maximumFractionDigits: 2 }).format(value)} kg`; }
function humanizeValue(value?: string | null) { return value ? value.replaceAll("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase()) : "Belum tersedia"; }
function canonicalValue(value: unknown, allowed: string[]) { const normalized = typeof value === "string" ? value.toUpperCase() : ""; return normalized && allowed.includes(normalized) ? normalized : "Belum diisi"; }
function humanize(value: string) { return value.replaceAll("_", " ").replaceAll("-", " ").replace(/\b\w/g, (letter) => letter.toUpperCase()); }
