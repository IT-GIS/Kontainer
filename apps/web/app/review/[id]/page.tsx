"use client";

import { Check, RotateCcw, X } from "lucide-react";
import { useParams, useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import type { ReviewDetail } from "@/types/reviews";

const tabs = ["Summary", "General Info", "Checklist", "Damage", "Photos", "Log"] as const;
type Tab = (typeof tabs)[number];

export default function ReviewDetailPage() {
  return <ProtectedRoute><AppShell title="Review Survey"><ReviewDetailContent /></AppShell></ProtectedRoute>;
}

function ReviewDetailContent() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { accessToken, user } = useAuth();
  const [review, setReview] = useState<ReviewDetail | null>(null);
  const [activeTab, setActiveTab] = useState<Tab>("Summary");
  const [dialog, setDialog] = useState<"revision" | "approve" | "reject" | null>(null);
  const [note, setNote] = useState("");
  const [finalResult, setFinalResult] = useState("damage");
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

  async function submitAction() {
    if (!accessToken || !dialog) return;
    setIsSubmitting(true);
    setError(null);
    const endpoint = dialog === "revision" ? "need-revision" : dialog;
    const body = dialog === "revision" ? { revision_note: note } : dialog === "approve" ? { final_result: finalResult, approval_note: note, generate_report: true } : { rejection_reason: note };
    try {
      await apiData(`/reviews/${params.id}/${endpoint}`, { method: "POST", accessToken, body: JSON.stringify(body) });
      setDialog(null);
      setNote("");
      if (dialog === "approve") {
        router.push("/reports");
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
  const canManageReview = can(user, "reviews.manage.all");
  const canDecide = canManageReview && review.status === "submitted";

  return (
    <div className="page-stack">
      <PageHeader title={`Review Survey: ${review.survey_no}`} description={`Container: ${review.container_no} - ${review.customer_name}`} />
      {canManageReview ? <div className="job-actions">
        <button className="secondary-button" disabled={!canDecide} onClick={() => setDialog("revision")}><RotateCcw size={17} /><span>Need Revision</span></button>
        <button className="secondary-button" disabled={!canDecide} onClick={() => setDialog("reject")}><X size={17} /><span>Reject</span></button>
        <button className="primary-button" disabled={!canDecide} onClick={() => setDialog("approve")}><Check size={17} /><span>Approve</span></button>
      </div> : null}
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <div className="tab-list">{tabs.map((tab) => <button className={activeTab === tab ? "tab-active" : ""} key={tab} onClick={() => setActiveTab(tab)}>{tab}</button>)}</div>
      {activeTab === "Summary" ? <Summary review={review} /> : null}
      {activeTab === "General Info" ? <ObjectPanel data={review.general_info ?? {}} /> : null}
      {activeTab === "Checklist" ? <Checklist rows={review.checklist ?? []} /> : null}
      {activeTab === "Damage" ? <Damage rows={review.damages ?? []} /> : null}
      {activeTab === "Photos" ? <Photos rows={review.photos ?? []} /> : null}
      {activeTab === "Log" ? <Log rows={review.approval_history ?? []} /> : null}

      <FormDialog title={dialogTitle(dialog)} open={canManageReview && dialog !== null} onClose={() => setDialog(null)} onSubmit={submitAction} isSubmitting={isSubmitting} submitLabel={dialog === "approve" ? "Approve" : "Submit"}>
        <div className="form-grid">
          {dialog === "approve" ? <label className="field"><span>Final Result</span><select value={finalResult} onChange={(event) => setFinalResult(event.target.value)}><option value="sound">Sound</option><option value="damage">Damage</option><option value="cargo_worthy">Cargo Worthy</option><option value="not_cargo_worthy">Not Cargo Worthy</option></select></label> : null}
          <label className="field form-span-2"><span>{dialog === "revision" ? "Revision Note" : dialog === "reject" ? "Rejection Reason" : "Approval Note"}</span><textarea rows={4} value={note} onChange={(event) => setNote(event.target.value)} /></label>
        </div>
      </FormDialog>
    </div>
  );
}

function Summary({ review }: { review: ReviewDetail }) {
  const rows: Array<[string, React.ReactNode]> = [
    ["Status", <StatusBadge key="status" tone={review.status === "submitted" ? "warning" : review.status === "approved" ? "success" : "danger"}>{review.status.toUpperCase()}</StatusBadge>],
    ["Job No", review.job_order_no],
    ["Container", review.container_no],
    ["Surveyor", review.surveyor_name],
    ["Survey Type", review.survey_type_name],
    ["Recommendation", review.survey_result_recommendation ?? "-"],
    ["Damage Count", review.damages?.length ?? 0],
    ["Photo Count", review.photos?.length ?? 0]
  ];
  return <section className="workspace-panel detail-grid">{rows.map(([label, value]) => <div key={label}><span>{label}</span><strong>{value}</strong></div>)}</section>;
}

function ObjectPanel({ data }: { data: Record<string, unknown> }) {
  return <section className="workspace-panel detail-grid">{Object.entries(data).filter(([key]) => !key.endsWith("_id")).map(([key, value]) => <div key={key}><span>{key.replaceAll("_", " ")}</span><strong>{String(value ?? "-")}</strong></div>)}</section>;
}

function Checklist({ rows }: { rows: Array<Record<string, unknown>> }) {
  return <DataTable rows={rows} columns={[{ key: "item", header: "Item", render: (row) => String(row.item_label ?? row.item_key ?? "-") }, { key: "value", header: "Value", render: (row) => String(row.value ?? "-") }, { key: "note", header: "Note", render: (row) => String(row.note ?? "-") }]} />;
}

function Damage({ rows }: { rows: Array<Record<string, unknown>> }) {
  return <DataTable rows={rows} columns={[{ key: "damage_no", header: "Damage No", render: (row) => String(row.damage_no ?? "-") }, { key: "location", header: "Location", render: (row) => `${row.face ?? "-"} ${row.internal_location ?? ""}` }, { key: "component", header: "Component", render: (row) => String(row.component_name ?? row.component_code ?? "-") }, { key: "damage", header: "Damage", render: (row) => String(row.damage_name ?? row.damage_code ?? "-") }, { key: "severity", header: "Severity", render: (row) => String(row.severity ?? "-") }, { key: "photo", header: "Photos", render: (row) => String(row.photo_count ?? 0) }]} />;
}

function Photos({ rows }: { rows: Array<Record<string, unknown>> }) {
  return <section className="workspace-panel photo-grid">{rows.length === 0 ? <p className="muted-text">Belum ada foto.</p> : rows.map((row, index) => <div className="photo-card" key={String(row.id ?? index)}><strong>{String(row.original_file_name ?? "Photo evidence")}</strong><span>{String(row.caption ?? row.object_key ?? "-")}</span></div>)}</section>;
}

function Log({ rows }: { rows: Array<Record<string, unknown>> }) {
  return <DataTable rows={rows} columns={[{ key: "decision", header: "Decision", render: (row) => String(row.decision ?? "-") }, { key: "note", header: "Note", render: (row) => String(row.review_note ?? "-") }, { key: "result", header: "Final Result", render: (row) => String(row.final_result ?? "-") }, { key: "time", header: "Reviewed At", render: (row) => String(row.reviewed_at ?? "-") }]} />;
}

function dialogTitle(dialog: "revision" | "approve" | "reject" | null) {
  if (dialog === "revision") return "Need Revision";
  if (dialog === "approve") return "Approve Survey";
  if (dialog === "reject") return "Reject Survey";
  return "";
}
