import { PackagePlus, Send, Upload, UserRoundCheck } from "lucide-react";
import Link from "next/link";
import { PhotoEvidence } from "@/components/surveys/photo-evidence";
import { DataTable } from "@/components/ui/data-table";
import { StatusBadge } from "@/components/ui/status-badge";
import type { JobDetailSupportingData } from "@/types/job-detail-workspace";
import type { AssignmentSummary, JobContainer, JobDetail, JobEvent } from "@/types/jobs";
import type { ReviewDetail } from "@/types/reviews";

export function JobSummaryTab({ job, support }: { job: JobDetail; support: JobDetailSupportingData }) {
  const total = job.containers?.length ?? 0;
  const completed = job.containers?.filter((item) => ["approved", "reported", "report_generated"].includes(item.status)).length ?? 0;
  const progress = total > 0 ? Math.round((completed / total) * 100) : 0;
  const rows: Array<[string, React.ReactNode]> = [
    ["Nomor Pekerjaan", job.job_order_no],
    ["Customer", job.customer?.customer_name ?? job.customer_name],
    ["PIC Customer", job.pic_customer_name ?? "Belum tersedia"],
    ["Location", job.location?.location_name ?? job.location_name],
    ["Survey Type", job.survey_type?.name ?? job.survey_type_name],
    ["Tanggal", formatDate(job.job_date)],
    ["Deadline", formatDateTime(job.deadline)],
    ["Prioritas", humanize(job.priority)],
    ["Instruksi", job.instruction ?? "Belum tersedia"],
    ["Status Pekerjaan", <StatusBadge key="status" tone={job.status === "cancelled" ? "danger" : "success"}>{humanize(job.status)}</StatusBadge>],
    ["Progress Keseluruhan", `${progress}% (${completed}/${total} peti kemas selesai)`],
    ["Pembaruan Terakhir", formatDateTime(latestSupportUpdate(job, support))]
  ];
  return <section className="workspace-panel detail-grid">{rows.map(([label, value]) => <div key={label}><span>{label}</span><strong>{value}</strong></div>)}</section>;
}

export function JobContainersTab({
  jobID,
  containers,
  selected,
  canAdd,
  canImport,
  onSelected,
  onAdd
}: {
  jobID: string;
  containers: JobContainer[];
  selected: string[];
  canAdd: boolean;
  canImport: boolean;
  onSelected: (ids: string[]) => void;
  onAdd: () => void;
}) {
  return <section className="workspace-panel job-tab-stack">
    <div className="section-title-row"><div><h2>Peti Kemas</h2><p className="muted-text">Kelola peti kemas yang tercatat pada pekerjaan inspeksi ini.</p></div><div className="job-actions">
      {canAdd ? <button className="secondary-button" onClick={onAdd} type="button"><PackagePlus size={17} /><span>Tambah Peti Kemas</span></button> : null}
      {canImport ? <Link className="primary-button" href={`/jobs/${jobID}/containers/import`}><Upload size={17} /><span>Import Peti Kemas</span></Link> : null}
    </div></div>
    <DataTable rows={containers} emptyText="Belum ada peti kemas pada pekerjaan ini." columns={[
      { key: "select", header: "Pilih", render: (row) => <input aria-label={`Pilih peti kemas ${row.container_no}`} type="checkbox" checked={selected.includes(row.id)} onChange={(event) => onSelected(event.target.checked ? [...selected, row.id] : selected.filter((id) => id !== row.id))} /> },
      { key: "container_no", header: "Nomor Peti Kemas", render: (row) => row.container_no },
      { key: "type", header: "Container / ISO Type", render: (row) => `${row.container_type_code ?? "-"} / ${row.iso_type_code ?? "-"}` },
      { key: "identity", header: "Seal / Cargo", render: (row) => `${row.seal_no ?? "-"} / ${humanize(row.cargo_status)}` },
      { key: "weight", header: "Gross / Tare / Payload", render: (row) => `${row.gross_weight ?? "-"} / ${row.tare_weight ?? "-"} / ${row.payload ?? "-"}` },
      { key: "manufacture", header: "Pembuatan / CSC Plate", render: (row) => `${formatDate(row.manufacture_date)} / ${humanize(row.csc_plate_status ?? "belum tersedia")}` },
      { key: "vehicle", header: "Truck / Driver", render: (row) => `${row.truck_no ?? "-"} / ${row.driver_name ?? "-"}` },
      { key: "remark", header: "Remark", render: (row) => row.remark ?? "-" },
      { key: "status", header: "Status", render: (row) => <StatusBadge tone={containerTone(row.status)}>{humanize(row.status)}</StatusBadge> }
    ]} />
  </section>;
}

export function JobAssignmentTab({
  assignments,
  selectedCount,
  canAssign,
  canReassign,
  onAssign,
  onReassign
}: {
  assignments: AssignmentSummary[];
  selectedCount: number;
  canAssign: boolean;
  canReassign: boolean;
  onAssign: () => void;
  onReassign: () => void;
}) {
  return <section className="workspace-panel job-tab-stack">
    <div className="section-title-row"><div><h2>Penugasan Surveyor GIFT</h2><p className="muted-text">{selectedCount} peti kemas dipilih dari tab Peti Kemas.</p></div><div className="job-actions">
      {canAssign ? <button className="primary-button" onClick={onAssign} type="button"><Send size={17} /><span>Tugaskan Surveyor GIFT</span></button> : null}
      {canReassign ? <button className="secondary-button" onClick={onReassign} type="button"><UserRoundCheck size={17} /><span>Ubah Penugasan</span></button> : null}
    </div></div>
    {!canAssign && !canReassign ? <div className="alert alert-warning">Anda hanya dapat melihat penugasan. Permission aksi tidak tersedia.</div> : null}
    <DataTable rows={assignments} emptyText="Belum ada penugasan aktif." columns={[
      { key: "assignment_no", header: "Nomor Penugasan", render: (row) => row.assignment_no },
      { key: "surveyor", header: "Surveyor GIFT", render: (row) => row.surveyor_name },
      { key: "period", header: "Periode", render: (row) => `${formatDate(row.start_date)} - ${formatDate(row.due_date)}` },
      { key: "instruction", header: "Instruksi", render: (row) => row.instruction ?? "-" },
      { key: "containers", header: "Peti Kemas", render: (row) => row.total_containers },
      { key: "status", header: "Status", render: (row) => <StatusBadge tone="success">{humanize(row.status)}</StatusBadge> }
    ]} />
    <p className="muted-text">Perubahan penugasan Surveyor GIFT tercatat pada tab Riwayat.</p>
  </section>;
}

export function JobProgressTab({ containers, support }: { containers: JobContainer[]; support: JobDetailSupportingData }) {
  return <section className="workspace-panel job-tab-stack">
    <div><h2>Progress Pemeriksaan</h2><p className="muted-text">Monitoring read-only. Admin tidak dapat mengisi hasil teknis Surveyor.</p></div>
    <DataTable rows={containers} emptyText="Progress pemeriksaan belum tersedia." columns={[
      { key: "container", header: "Peti Kemas", render: (row) => row.container_no },
      { key: "status", header: "Status Pemeriksaan", render: (row) => <StatusBadge tone={containerTone(row.status)}>{humanize(row.status)}</StatusBadge> },
      { key: "checklist", header: "Checklist", render: (row) => checklistProgress(reviewForContainer(row, support)) },
      { key: "findings", header: "Temuan", render: (row) => reviewForContainer(row, support)?.damages?.length ?? 0 },
      { key: "photos", header: "Foto", render: (row) => reviewForContainer(row, support)?.photos?.length ?? 0 },
      { key: "updated", header: "Terakhir Diperbarui", render: (row) => formatDateTime(surveyForContainer(row, support)?.approved_at ?? surveyForContainer(row, support)?.submitted_at ?? surveyForContainer(row, support)?.started_at) },
      { key: "submit", header: "Submit / Revisi", render: (row) => humanize(surveyForContainer(row, support)?.status ?? row.status) },
      { key: "surveyor", header: "Surveyor", render: (row) => surveyForContainer(row, support)?.surveyor_name ?? "Belum tersedia" }
    ]} />
  </section>;
}

export function JobSurveyResultsTab({ support }: { support: JobDetailSupportingData }) {
  if (support.reviews.length === 0) return <section className="workspace-panel"><h2>Hasil Survey</h2><p className="muted-text">Hasil survey belum tersedia atau permission review tidak diberikan.</p></section>;
  return <div className="job-tab-stack">{support.reviews.map((review) => <section className="workspace-panel survey-result-card" key={review.survey_id}>
    <div className="section-title-row"><div><h2>{review.survey_no}</h2><p className="muted-text">{review.container_no} — {review.surveyor_name}</p></div><StatusBadge tone={review.status === "approved" ? "success" : review.status === "need_revision" ? "danger" : "warning"}>{humanize(review.status)}</StatusBadge></div>
    <h3>General Information</h3><ObjectPanel data={review.general_info ?? {}} />
    <h3>Checklist</h3><DataTable rows={review.checklist ?? []} emptyText="Checklist belum tersedia." columns={[
      { key: "item", header: "Item", render: (row) => String(row.item_label ?? row.item_key ?? "-") },
      { key: "value", header: "Jawaban", render: (row) => String(row.value ?? "-") },
      { key: "note", header: "Catatan Surveyor", render: (row) => String(row.note ?? "-") }
    ]} />
    <h3>Temuan CEDEX</h3><DataTable rows={review.damages ?? []} emptyText="Tidak ada temuan." columns={[
      { key: "location", header: "CEDEX Location", render: (row) => String(row.internal_location ?? row.face ?? "-") },
      { key: "component", header: "CEDEX Component", render: (row) => String(row.component_name ?? row.component_code ?? "-") },
      { key: "damage", header: "CEDEX Damage", render: (row) => String(row.damage_name ?? row.damage_code ?? "-") },
      { key: "repair", header: "CEDEX Repair", render: (row) => String(row.repair_name ?? row.repair_code ?? "-") },
      { key: "material", header: "CEDEX Material", render: (row) => String(row.material_name ?? row.material_code ?? "-") },
      { key: "responsibility", header: "Responsibility Code", render: (row) => String(row.responsibility_name ?? row.responsibility_code ?? "-") },
      { key: "severity", header: "Severity / Ukuran", render: (row) => `${String(row.severity ?? "-")} / ${String(row.length ?? "-")} × ${String(row.width ?? "-")} × ${String(row.depth ?? "-")} ${String(row.unit ?? "")}` },
      { key: "remark", header: "Catatan", render: (row) => String(row.remark ?? "-") }
    ]} />
    <div><h3>Foto</h3><div className="photo-grid">{(review.photos ?? []).length === 0 ? <p className="muted-text">Belum ada foto.</p> : (review.photos ?? []).map((photo, index) => <PhotoEvidence id={String(photo.id ?? index)} name={String(photo.original_file_name ?? "Photo evidence")} caption={photo.caption ? String(photo.caption) : null} key={String(photo.id ?? index)} />)}</div></div>
    <div className="detail-grid"><div><span>Rekomendasi</span><strong>{humanize(review.survey_result_recommendation ?? "belum tersedia")}</strong></div><div><span>Catatan Surveyor</span><strong>{String(review.general_info?.general_remark ?? "Belum tersedia")}</strong></div></div>
  </section>)}</div>;
}

export function JobReviewTab({ support }: { support: JobDetailSupportingData }) {
  return <section className="workspace-panel job-tab-stack">
    <div><h2>Review</h2><p className="muted-text">Read-only pada detail pekerjaan. Keputusan teknis tetap dilakukan di workspace Review & Keputusan.</p></div>
    <DataTable rows={support.reviews} emptyText="Belum ada data review." columns={[
      { key: "survey", header: "Survey", render: (row) => row.survey_no },
      { key: "container", header: "Peti Kemas", render: (row) => row.container_no },
      { key: "status", header: "Status Review", render: (row) => <StatusBadge tone={row.status === "approved" ? "success" : row.status === "need_revision" || row.status === "rejected" ? "danger" : "warning"}>{humanize(row.status)}</StatusBadge> },
      { key: "reviewer", header: "Reviewer", render: () => "Belum tersedia pada kontrak existing" },
      { key: "decision", header: "Keputusan / Catatan", render: (row) => latestDecision(row) },
      { key: "revision", header: "Riwayat Revisi", render: (row) => `${row.approval_history?.filter((item) => String(item.decision) === "need_revision").length ?? 0} revisi` },
      { key: "action", header: "Aksi", render: (row) => <Link className="primary-button table-action" href={`/review/${row.survey_id}`}>Buka Review & Keputusan</Link> }
    ]} />
  </section>;
}

export function JobDocumentsTab({ support }: { support: JobDetailSupportingData }) {
  return <section className="workspace-panel job-tab-stack">
    <div><h2>Dokumen</h2><p className="muted-text">Metadata dokumen saja. PDF final, QR, penandatangan, dan verifikasi publik belum aktif.</p></div>
    <DataTable rows={support.documents} emptyText="Metadata dokumen belum tersedia." columns={[
      { key: "number", header: "Nomor Dokumen", render: (row) => <Link className="text-link" href={`/reports/${row.id}`}>{row.report_no}</Link> },
      { key: "customer", header: "Customer / Peti Kemas", render: (row) => `${row.customer_name} / ${row.container_no}` },
      { key: "review", header: "Hasil Review", render: (row) => reviewResultForSurvey(row.survey_no, support) },
      { key: "signer", header: "Penandatangan", render: () => "Belum tersedia" },
      { key: "status", header: "Status Dokumen", render: (row) => <StatusBadge tone={row.status === "failed" ? "danger" : "warning"}>{humanize(row.status)}</StatusBadge> },
      { key: "version", header: "Versi", render: (row) => `Rev. ${row.revision_no ?? 0}` },
      { key: "date", header: "Tanggal", render: (row) => formatDateTime(row.created_at) },
      { key: "history", header: "Riwayat", render: (row) => `${support.versions[row.id]?.length ?? 0} versi` }
    ]} />
  </section>;
}

export function JobHistoryTab({ rows }: { rows: JobEvent[] }) {
  return <section className="workspace-panel timeline-list"><h2>Riwayat</h2>{rows.length === 0 ? <p className="muted-text">Event pekerjaan belum tersedia.</p> : rows.map((row) => <div key={row.id}><strong>{row.event_title}</strong><p>{row.description}</p><span>{row.actor ?? "System"} — {formatDateTime(row.created_at)}</span></div>)}</section>;
}

function ObjectPanel({ data }: { data: Record<string, unknown> }) {
  const entries = Object.entries(data).filter(([key]) => !key.endsWith("_id"));
  return <div className="detail-grid">{entries.length === 0 ? <div><span>Status</span><strong>Belum tersedia</strong></div> : entries.map(([key, value]) => <div key={key}><span>{humanize(key)}</span><strong>{String(value ?? "-")}</strong></div>)}</div>;
}

function surveyForContainer(container: JobContainer, support: JobDetailSupportingData) {
  return support.surveys.find((item) => item.container_no === container.container_no);
}

function reviewForContainer(container: JobContainer, support: JobDetailSupportingData) {
  return support.reviews.find((item) => item.container_no === container.container_no);
}

function checklistProgress(review?: ReviewDetail) {
  if (!review?.checklist) return "Belum tersedia";
  const completed = review.checklist.filter((item) => item.value !== undefined && item.value !== null && item.value !== "").length;
  return `${completed}/${review.checklist.length}`;
}

function latestDecision(review: ReviewDetail) {
  const item = review.approval_history?.[0];
  if (!item) return "Belum ada keputusan";
  return `${humanize(String(item.decision ?? "-"))} — ${String(item.review_note ?? "Tanpa catatan")}`;
}

function reviewResultForSurvey(surveyNo: string, support: JobDetailSupportingData) {
  const review = support.reviews.find((item) => item.survey_no === surveyNo);
  return humanize(review?.survey_result ?? review?.status ?? "belum tersedia");
}

function latestSupportUpdate(job: JobDetail, support: JobDetailSupportingData) {
  const values = [job.updated_at, job.created_at, ...support.surveys.flatMap((item) => [item.approved_at, item.submitted_at, item.started_at]), ...support.documents.map((item) => item.created_at)].filter((item): item is string => Boolean(item));
  return values.reduce((latest, value) => new Date(value).getTime() > new Date(latest).getTime() ? value : latest, values[0] ?? "");
}

function containerTone(status: string): "success" | "warning" | "danger" | "neutral" {
  if (["approved", "reported", "report_generated"].includes(status)) return "success";
  if (["need_revision", "rejected", "cancelled"].includes(status)) return "danger";
  if (["assigned", "in_progress", "submitted", "draft"].includes(status)) return "warning";
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
