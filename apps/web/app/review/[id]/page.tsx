"use client";

import { Check, Play, Plus, RotateCcw, Trash2, X } from "lucide-react";
import { useParams, useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { InteractiveSurveySheet } from "@/components/surveys/interactive-survey-sheet";
import { PhotoEvidence } from "@/components/surveys/photo-evidence";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { SurveySheetFieldSourceBadge, type SurveySheetFieldSource } from "@/components/ui/survey-sheet-field-source-badge";
import { revisionStatusLabel, surveyStatusLabel } from "@/lib/status-labels";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import type { ReviewDetail } from "@/types/reviews";
import type { SurveyDamage } from "@/types/surveyor";

const tabs = ["Ringkasan", "Header Survey Sheet", "Informasi Umum", "Checklist", "Survey Sheet", "Daftar Kerusakan", "Foto", "Riwayat"] as const;
type Tab = (typeof tabs)[number];
type RevisionDraft = { target_type: "survey" | "finding" | "checklist" | "photo"; target_id: string; category: string; note: string; due_at: string };
const emptyRevisionItem: RevisionDraft = { target_type: "survey", target_id: "", category: "general", note: "", due_at: "" };

export default function ReviewDetailPage() {
  return <ProtectedRoute><AppShell title="Review & Keputusan" breadcrumbs={[{ label: "Review & Keputusan", href: "/review" }, { label: "Detail Review" }]}><ReviewDetailContent /></AppShell></ProtectedRoute>;
}

function ReviewDetailContent() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { accessToken, user } = useAuth();
  const [review, setReview] = useState<ReviewDetail | null>(null);
  const [activeTab, setActiveTab] = useState<Tab>("Ringkasan");
  const [activeFace, setActiveFace] = useState("right");
  const [dialog, setDialog] = useState<"revision" | "approve" | "reject" | null>(null);
  const [note, setNote] = useState("");
  const [finalResult, setFinalResult] = useState("damage");
	const [revisionItems, setRevisionItems] = useState<RevisionDraft[]>([{ ...emptyRevisionItem }]);
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const loadReview = useCallback(async () => {
    if (!accessToken || !params.id) return;
    setError(null);
    try {
      setReview(await apiData<ReviewDetail>(`/reviews/${params.id}`, { accessToken }));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil detail review.");
    }
  }, [accessToken, params.id]);

  useEffect(() => { const timer = window.setTimeout(() => void loadReview(), 0); return () => window.clearTimeout(timer); }, [loadReview]);

  async function startReview() {
    if (!accessToken) return;
    setIsSubmitting(true);
    setError(null);
    try {
      await apiData(`/reviews/${params.id}/start-review`, {
        method: "POST",
        accessToken,
        body: JSON.stringify({})
      });
      await loadReview();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal memulai review.");
    } finally {
      setIsSubmitting(false);
    }
  }

  async function submitAction() {
    if (!accessToken || !dialog) return;
    if ((dialog === "revision" || dialog === "reject") && !note.trim()) {
      setError(dialog === "revision" ? "Revision Note wajib diisi." : "Rejection Reason wajib diisi.");
      return;
    }
	if (dialog === "revision" && (revisionItems.length === 0 || revisionItems.some((item) => !item.note.trim() || (item.target_type !== "survey" && !item.target_id)))) {
		setError("Setiap item revisi wajib memiliki target dan catatan.");
		return;
	}
    if (dialog === "approve" && !finalResult) {
      setError("Final Result wajib dipilih.");
      return;
    }
    setIsSubmitting(true);
    setError(null);
    const endpoint = dialog === "revision" ? "need-revision" : dialog;
	const body = dialog === "revision" ? {
		revision_note: note,
		items: revisionItems.map((item) => ({ ...item, target_id: item.target_id || undefined, due_at: item.due_at ? new Date(item.due_at).toISOString() : undefined }))
	} : dialog === "approve" ? { final_result: finalResult, approval_note: note, generate_report: false } : { rejection_reason: note };
    try {
      await apiData(`/reviews/${params.id}/${endpoint}`, { method: "POST", accessToken, body: JSON.stringify(body) });
      setDialog(null);
      setNote("");
	  setRevisionItems([{ ...emptyRevisionItem }]);
      if (dialog === "approve") {
        router.push("/review?view=history");
        return;
      }
      await loadReview();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Aksi review gagal.");
    } finally {
      setIsSubmitting(false);
    }
  }

  if (!review) return <div className="center-screen">Memuat review...</div>;
	const canManageReview = can(user, "reviews.manage.all") && (user?.active_role === "supervisor" || user?.active_role === "super_admin");
  const canStart = canManageReview && ["submitted", "resubmitted"].includes(review.status);
	const canDecide = canManageReview && review.status === "under_review" && review.current_reviewer_id === user?.id;
	const revisionTargetOptions = (targetType: RevisionDraft["target_type"]) => {
		if (targetType === "finding") return (review.damages ?? []).map((item) => ({ id: String(item.id), label: String(item.damage_no ?? item.id) }));
		if (targetType === "checklist") return (review.checklist ?? []).map((item) => ({ id: String(item.id), label: String(item.item_label ?? item.item_key ?? item.id) }));
		if (targetType === "photo") return (review.photos ?? []).map((item) => ({ id: String(item.id), label: String(item.original_file_name ?? item.photo_category ?? item.id) }));
		return [];
	};

  return (
    <div className="page-stack">
      <PageHeader title={`Review & Keputusan: ${review.survey_no}`} description={`Peti kemas: ${review.container_no} - ${review.customer_name}`} />
      {!canManageReview ? <div className="alert alert-warning">Mode read-only. Keputusan teknis hanya tersedia bagi Supervisor/Super Admin yang juga memiliki permission <code>reviews.manage.all</code>.</div> : null}
	  {review.current_reviewer_name ? <div className="alert alert-info">Reviewer aktif: <strong>{review.current_reviewer_name}</strong></div> : null}
	  {canManageReview && review.status === "under_review" && !canDecide ? <div className="alert alert-warning">Keputusan dikunci karena review ini sedang diklaim reviewer lain.</div> : null}
      {canManageReview ? <div className="job-actions">
        {canStart ? <button className="primary-button" disabled={isSubmitting} onClick={() => void startReview()}><Play size={17} /><span>Mulai Review</span></button> : null}
		<button className="secondary-button" disabled={!canDecide} onClick={() => { setRevisionItems([{ ...emptyRevisionItem }]); setDialog("revision"); }}><RotateCcw size={17} /><span>Perlu Revisi</span></button>
        <button className="secondary-button" disabled={!canDecide} onClick={() => setDialog("reject")}><X size={17} /><span>Tolak</span></button>
        <button className="primary-button" disabled={!canDecide} onClick={() => setDialog("approve")}><Check size={17} /><span>Setujui</span></button>
      </div> : null}
      {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
      <div className="tab-list">{tabs.map((tab) => <button className={activeTab === tab ? "tab-active" : ""} key={tab} onClick={() => setActiveTab(tab)}>{tab}</button>)}</div>
      {activeTab === "Ringkasan" ? <Summary review={review} /> : null}
      {activeTab === "Header Survey Sheet" ? <SurveySheetHeader review={review} /> : null}
      {activeTab === "Informasi Umum" ? <ObjectPanel data={review.general_info ?? {}} /> : null}
      {activeTab === "Checklist" ? <Checklist rows={review.checklist ?? []} /> : null}
      {activeTab === "Survey Sheet" ? <ReviewSurveySheet review={review} activeFace={activeFace} onFace={setActiveFace} /> : null}
      {activeTab === "Daftar Kerusakan" ? <Damage rows={review.damages ?? []} /> : null}
      {activeTab === "Foto" ? <Photos rows={review.photos ?? []} /> : null}
      {activeTab === "Riwayat" ? <History approvals={review.approval_history ?? []} revisions={review.revision_history ?? []} /> : null}

      <FormDialog title={dialogTitle(dialog)} open={canManageReview && dialog !== null} onClose={() => setDialog(null)} onSubmit={submitAction} isSubmitting={isSubmitting} submitLabel={dialog === "approve" ? "Approve" : "Submit"}>
        <div className="form-grid">
          {dialog === "approve" ? <label className="field"><span>Hasil Akhir</span><select value={finalResult} onChange={(event) => setFinalResult(event.target.value)}><option value="sound">Baik</option><option value="damage">Rusak</option><option value="cargo_worthy">Layak Muat</option><option value="not_cargo_worthy">Tidak Layak Muat</option></select></label> : null}
		  {dialog === "revision" ? <div className="form-span-2 page-stack">
			<div className="section-title-row"><div><strong>Item Revisi</strong><p className="muted-text">Tautkan setiap catatan ke survey, temuan, checklist, atau foto tertentu.</p></div><button className="secondary-button" type="button" onClick={() => setRevisionItems((current) => [...current, { ...emptyRevisionItem }])}><Plus size={16} /><span>Tambah Item</span></button></div>
			{revisionItems.map((item, index) => {
				const options = revisionTargetOptions(item.target_type);
				return <section className="workspace-panel" key={`revision-${index}`}><div className="form-grid">
					<label className="field"><span>Target</span><select value={item.target_type} onChange={(event) => setRevisionItems((current) => current.map((row, rowIndex) => rowIndex === index ? { ...row, target_type: event.target.value as RevisionDraft["target_type"], target_id: "" } : row))}><option value="survey">Survey</option><option value="finding">Temuan</option><option value="checklist">Checklist</option><option value="photo">Foto</option></select></label>
					{item.target_type !== "survey" ? <label className="field"><span>Record Target</span><select value={item.target_id} onChange={(event) => setRevisionItems((current) => current.map((row, rowIndex) => rowIndex === index ? { ...row, target_id: event.target.value } : row))}><option value="">Pilih record</option>{options.map((option) => <option key={option.id} value={option.id}>{option.label}</option>)}</select></label> : null}
					<label className="field"><span>Kategori</span><select value={item.category} onChange={(event) => setRevisionItems((current) => current.map((row, rowIndex) => rowIndex === index ? { ...row, category: event.target.value } : row))}><option value="general">Umum</option><option value="data">Data</option><option value="technical">Teknis</option><option value="photo_quality">Kualitas Foto</option><option value="completeness">Kelengkapan</option></select></label>
					<label className="field"><span>Batas Perbaikan</span><input type="datetime-local" value={item.due_at} onChange={(event) => setRevisionItems((current) => current.map((row, rowIndex) => rowIndex === index ? { ...row, due_at: event.target.value } : row))} /></label>
					<label className="field form-span-2"><span>Catatan Item *</span><textarea rows={3} value={item.note} onChange={(event) => setRevisionItems((current) => current.map((row, rowIndex) => rowIndex === index ? { ...row, note: event.target.value } : row))} /></label>
					{revisionItems.length > 1 ? <button className="secondary-button" type="button" onClick={() => setRevisionItems((current) => current.filter((_, rowIndex) => rowIndex !== index))}><Trash2 size={16} /><span>Hapus Item</span></button> : null}
				</div></section>;
			})}
		  </div> : null}
          <label className="field form-span-2"><span>{dialog === "revision" ? "Catatan Revisi" : dialog === "reject" ? "Alasan Penolakan" : "Catatan Persetujuan"}</span><textarea rows={4} value={note} onChange={(event) => setNote(event.target.value)} /></label>
        </div>
      </FormDialog>
    </div>
  );
}

function Summary({ review }: { review: ReviewDetail }) {
  const rows: Array<[string, React.ReactNode]> = [
	["Status", <StatusBadge key="status" tone={review.status === "approved" ? "success" : review.status === "need_revision" || review.status === "rejected" ? "danger" : "warning"}>{surveyStatusLabel(review.status)}</StatusBadge>],
    ["Job No", review.job_order_no],
    ["Container", review.container_no],
    ["Surveyor", review.surveyor_name],
    ["Survey Type", review.survey_type_name],
	["Kategori Persetujuan", review.approval_category_name ?? "Belum tersedia"],
	["Pemilik Sah Peti Kemas", review.owner_name ?? "Belum tersedia"],
    ["Recommendation", review.survey_result_recommendation ?? "-"],
    ["Damage Count", review.damages?.length ?? 0],
    ["Photo Count", review.photos?.length ?? 0]
  ];
  return <section className="workspace-panel detail-grid">{rows.map(([label, value]) => <div key={label}><span>{label}</span><strong>{value}</strong></div>)}</section>;
}

function SurveySheetHeader({ review }: { review: ReviewDetail }) {
  const general = review.general_info ?? {};
  const mismatches = verificationMismatches(review.cargo_status_initial, stringValue(general.cargo_status), review.csc_plate_status_initial, stringValue(general.csc_plate_status));
	for (const [label, initial, verified] of [
	  ["CSC Plate Number", review.csc_plate_number_initial, stringValue(general.csc_plate_number_verified)],
	  ["CSC Approval Reference", review.csc_approval_reference_initial, stringValue(general.csc_approval_reference_verified)],
	  ["CSC Manufacture Date", dateValue(review.csc_manufacture_date_initial), dateValue(stringValue(general.csc_manufacture_date_verified))],
	  ["CSC Next Examination", dateValue(review.csc_next_examination_date_initial), dateValue(stringValue(general.csc_next_examination_date_verified))],
	  ["CSC Program Type", review.csc_program_type_initial, stringValue(general.csc_program_type_verified)]
	] as const) if (isKnownMismatch(initial, verified)) mismatches.push(label);
  const rows: Array<{ label: string; value: React.ReactNode; source: SurveySheetFieldSource }> = [
    { label: "Customer / Client", value: review.customer_name, source: "Customer" },
	{ label: "Pemilik Sah Peti Kemas", value: displayValue(review.owner_name), source: "Job" },
	{ label: "Kategori Persetujuan", value: displayValue(review.approval_category_name), source: "Job" },
    { label: "Container Nbrs", value: review.container_no, source: "Peti Kemas" },
    { label: "Type of Survey", value: review.survey_type_name || "Belum tersedia", source: "Job" },
    { label: "Size", value: review.container_size ? `${review.container_size} feet` : "Belum tersedia", source: "Peti Kemas" },
    { label: "Manufacture", value: displayValue(review.manufacture_date), source: "Peti Kemas" },
    { label: "MTY / FULL (Data Awal)", value: formatCargoStatus(review.cargo_status_initial), source: "Peti Kemas" },
    { label: "Cargo Status Verifikasi", value: formatCargoStatus(stringValue(general.cargo_status)), source: "Surveyor" },
    { label: "Type", value: [review.container_type_code, review.container_type_name].filter(Boolean).join(" - ") || "Belum tersedia", source: "Peti Kemas" },
    { label: "CSC Plate Status Awal", value: humanizeValue(review.csc_plate_status_initial), source: "Peti Kemas" },
    { label: "CSC Plate Status Verifikasi", value: humanizeValue(stringValue(general.csc_plate_status)), source: "Surveyor" },
	{ label: "CSC Plate Number Awal", value: displayValue(review.csc_plate_number_initial ?? review.csc_plate_number), source: "Peti Kemas" },
	{ label: "CSC Plate Number Verifikasi", value: displayValue(general.csc_plate_number_verified), source: "Surveyor" },
	{ label: "CSC Approval Reference Awal", value: displayValue(review.csc_approval_reference_initial ?? review.csc_approval_reference), source: "Peti Kemas" },
	{ label: "CSC Approval Reference Verifikasi", value: displayValue(general.csc_approval_reference_verified), source: "Surveyor" },
	{ label: "CSC Manufacture Date Awal", value: displayValue(review.csc_manufacture_date_initial ?? review.csc_manufacture_date), source: "Peti Kemas" },
	{ label: "CSC Manufacture Date Verifikasi", value: displayValue(general.csc_manufacture_date_verified), source: "Surveyor" },
	{ label: "CSC Next Examination Awal", value: displayValue(review.csc_next_examination_date_initial ?? review.csc_next_examination_date), source: "Peti Kemas" },
	{ label: "CSC Next Examination Verifikasi", value: displayValue(general.csc_next_examination_date_verified), source: "Surveyor" },
	{ label: "CSC Program Type Awal", value: displayValue(review.csc_program_type_initial ?? review.csc_program_type), source: "Peti Kemas" },
	{ label: "CSC Program Type Verifikasi", value: displayValue(general.csc_program_type_verified), source: "Surveyor" },
    { label: "Payload", value: formatWeight(review.payload), source: "Peti Kemas" },
    { label: "Survey Location", value: displayValue(review.location_name), source: "Job" },
    { label: "Tare", value: formatWeight(review.tare_weight), source: "Peti Kemas" },
    { label: "Date of Survey", value: formatDateTime(review.started_at), source: "Sistem" },
    { label: "Condition", value: canonicalValue(general.general_condition, ["DMG", "AVL", "AR"]), source: "Surveyor" },
    { label: "Cleanliness", value: canonicalValue(general.cleanliness, ["DTY", "CTM"]), source: "Surveyor" }
  ];
  return <section className="workspace-panel page-stack">
    <div className="section-title-row"><div><span className="eyebrow">Read-only reviewer</span><h2>Header Survey Sheet dan Provenance</h2><p className="muted-text">Data administratif membaca snapshot Survey. Reviewer dapat membandingkan data awal dengan hasil verifikasi tanpa mengubah source.</p></div></div>
    <div className="survey-sheet-summary-grid">{rows.map((row) => <div key={row.label}><span>{row.label}<SurveySheetFieldSourceBadge source={row.source} /></span><strong>{row.value}</strong></div>)}</div>
    {mismatches.length > 0 ? <div className="alert alert-warning"><div><strong>Mismatch data awal dan hasil verifikasi: {mismatches.join(", ")}</strong><p>Catatan Surveyor: {displayValue(general.general_remark)}</p></div></div> : null}
    <div className="alert alert-info"><strong>DOMAIN GAP:</strong>&nbsp; MGM, TCT, 3rd Scty Sys, dan Cu-Cap tetap tidak ditampilkan sebagai field final sampai definisi dan ownership disahkan.</div>
  </section>;
}

function stringValue(value: unknown) { return typeof value === "string" ? value : null; }
function displayValue(value: unknown) { return value == null || value === "" ? "Belum tersedia" : String(value); }
function formatCargoStatus(value?: string | null) { return value === "empty" ? "MTY (Empty)" : value === "laden" ? "FULL (Laden)" : "Belum tersedia"; }
function formatWeight(value?: number | null) { return value == null ? "Belum tersedia" : `${new Intl.NumberFormat("id-ID", { maximumFractionDigits: 2 }).format(value)} kg`; }
function humanizeValue(value?: string | null) { return value ? value.replaceAll("_", " ").replace(/\b\w/g, (letter) => letter.toUpperCase()) : "Belum tersedia"; }
function canonicalValue(value: unknown, allowed: string[]) { const normalized = stringValue(value)?.toUpperCase(); return normalized && allowed.includes(normalized) ? normalized : "Belum diisi"; }
function formatDateTime(value?: string | null) { if (!value) return "Belum tersedia"; const date = new Date(value); return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(date); }
function verificationMismatches(cargoInitial?: string | null, cargoVerified?: string | null, cscInitial?: string | null, cscVerified?: string | null) { const result: string[] = []; if (isKnownMismatch(cargoInitial, cargoVerified)) result.push("Cargo Status"); if (isKnownMismatch(cscInitial, cscVerified)) result.push("CSC Plate Status"); return result; }
function isKnownMismatch(initial?: string | null, verified?: string | null) { const normalize = (value?: string | null) => { const normalized = value?.trim().toLowerCase() ?? ""; return ["", "unknown", "not_checked"].includes(normalized) ? "" : normalized; }; const initialValue = normalize(initial); const verifiedValue = normalize(verified); return Boolean(initialValue && verifiedValue && initialValue !== verifiedValue); }
function dateValue(value?: string | null) { return value ? value.slice(0, 10) : null; }

function ObjectPanel({ data }: { data: Record<string, unknown> }) {
  return <section className="workspace-panel detail-grid">{Object.entries(data).filter(([key]) => !key.endsWith("_id")).map(([key, value]) => <div key={key}><span>{key.replaceAll("_", " ")}</span><strong>{String(value ?? "-")}</strong></div>)}</section>;
}

function ReviewSurveySheet({ review, activeFace, onFace }: { review: ReviewDetail; activeFace: string; onFace: (face: string) => void }) {
  const damages = (review.damages ?? []) as unknown as SurveyDamage[];
  return <div className="page-stack">
    <div className="alert alert-info">Diagram dan marker Temuan adalah snapshot read-only dari Surveyor. Reviewer tidak dapat memindahkan marker atau mengubah data CEDEX.</div>
    <InteractiveSurveySheet containerSize={review.container_size} activeFace={activeFace} locations={[]} damages={damages} selection={null} readonly preview onFace={onFace} />
  </div>;
}

function Checklist({ rows }: { rows: Array<Record<string, unknown>> }) {
  return <DataTable rows={rows} columns={[{ key: "item", header: "Item", render: (row) => String(row.item_label ?? row.item_key ?? "-") }, { key: "value", header: "Value", render: (row) => String(row.value ?? "-") }, { key: "note", header: "Note", render: (row) => String(row.note ?? "-") }]} />;
}

function Damage({ rows }: { rows: Array<Record<string, unknown>> }) {
  return <DataTable responsiveCards rows={rows} columns={[{ key: "damage_no", header: "Damage No", render: (row) => String(row.damage_no ?? "-") }, { key: "location", header: "Location", render: (row) => `${row.face ?? "-"} ${row.internal_location ?? ""}` }, { key: "component", header: "Component", render: (row) => String(row.component_name ?? row.component_code ?? "-") }, { key: "damage", header: "Damage", render: (row) => String(row.damage_name ?? row.damage_code ?? "-") }, { key: "repair", header: "Rekomendasi Tindakan", render: (row) => String(row.repair_name ?? row.repair_code ?? "-") }, { key: "material", header: "Material", render: (row) => String(row.material_name ?? row.material_code ?? "-") }, { key: "responsibility", header: "Responsibility (Legacy)", render: (row) => String(row.responsibility_name ?? row.responsibility_code ?? "-") }, { key: "severity", header: "Severity", render: (row) => String(row.severity ?? "-") }, { key: "photo", header: "Photos", render: (row) => String(row.photo_count ?? 0) }]} />;
}

function Photos({ rows }: { rows: Array<Record<string, unknown>> }) {
  return <section className="workspace-panel photo-grid">{rows.length === 0 ? <p className="muted-text">Belum ada foto.</p> : rows.map((row, index) => <PhotoEvidence id={String(row.id ?? index)} name={String(row.original_file_name ?? "Photo evidence")} caption={row.caption ? String(row.caption) : null} key={String(row.id ?? index)} />)}</section>;
}

function History({ approvals, revisions }: { approvals: Array<Record<string, unknown>>; revisions: NonNullable<ReviewDetail["revision_history"]> }) {
  return <div className="page-stack">
    <section className="workspace-panel"><h2>Histori Revisi</h2><DataTable rows={revisions} emptyText="Belum ada siklus revisi." columns={[
      { key: "revision", header: "Revisi", render: (row) => `#${row.revision_no}` },
      { key: "reason", header: "Alasan", render: (row) => row.revision_reason },
      { key: "requested", header: "Diminta", render: (row) => row.requested_at },
      { key: "resubmitted", header: "Disubmit Ulang", render: (row) => row.resubmitted_at ?? "-" },
      { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "approved" ? "success" : row.status === "requested" ? "danger" : "warning"}>{revisionStatusLabel(row.status)}</StatusBadge> }
    ]} />
    {revisions.map((revision) => <details className="revision-comparison" key={revision.id}>
      <summary>Bandingkan Revision #{revision.revision_no}</summary>
      <div className="form-grid">
        <div><strong>Sebelum revisi</strong><pre>{snapshotText(revision.snapshot_before)}</pre></div>
        <div><strong>Sesudah revisi</strong><pre>{snapshotText(revision.snapshot_after)}</pre></div>
      </div>
    </details>)}</section>
    <section className="workspace-panel"><h2>Histori Keputusan</h2><DataTable rows={approvals} emptyText="Belum ada keputusan reviewer." columns={[{ key: "decision", header: "Decision", render: (row) => String(row.decision ?? "-") }, { key: "note", header: "Note", render: (row) => String(row.review_note ?? "-") }, { key: "result", header: "Final Result", render: (row) => String(row.final_result ?? "-") }, { key: "time", header: "Reviewed At", render: (row) => String(row.reviewed_at ?? "-") }]} /></section>
  </div>;
}

function snapshotText(value: Record<string, unknown> | string | null | undefined) {
  if (value == null) return "Belum disubmit ulang.";
  if (typeof value !== "string") return JSON.stringify(value, null, 2);
  try {
    return JSON.stringify(JSON.parse(value), null, 2);
  } catch {
    return value;
  }
}

function dialogTitle(dialog: "revision" | "approve" | "reject" | null) {
  if (dialog === "revision") return "Perlu Revisi";
  if (dialog === "approve") return "Setujui Pemeriksaan";
  if (dialog === "reject") return "Tolak Pemeriksaan";
  return "";
}
