"use client";

import { Check, Search, X } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";

type ProposalRow = {
  id: string;
  customer_label?: string;
  proposed_by_label?: string;
  code_type: string;
  code: string;
  description: string;
  reason: string;
  evidence_file_id?: string | null;
  notes?: string | null;
  status: "pending" | "approved" | "rejected";
  review_note?: string | null;
  master_entity_id?: string | null;
  created_at?: string;
};

export function IsoCedexCodeProposals() {
  const { accessToken, user } = useAuth();
  const [rows, setRows] = useState<ProposalRow[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [codeType, setCodeType] = useState("");
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [target, setTarget] = useState<ProposalRow | null>(null);
  const [decision, setDecision] = useState<"approved" | "rejected">("approved");
  const [reviewNote, setReviewNote] = useState("");
  const isEditor = Boolean(user?.roles.some((role) => role === "admin" || role === "super_admin"));

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<ProposalRow>(`/master/cedex/code-proposals${buildQuery({ page, per_page: 20, search, status, code_type: codeType })}`, { accessToken });
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : "Pengajuan ISO CEDEX gagal dimuat.");
    } finally {
      setLoading(false);
    }
  }, [accessToken, codeType, page, search, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 250);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  function openReview(row: ProposalRow, nextDecision: "approved" | "rejected") {
    setTarget(row);
    setDecision(nextDecision);
    setReviewNote("");
    setError(null);
  }

  async function submitReview() {
    if (!accessToken || !target || saving) return;
    if (decision === "rejected" && !reviewNote.trim()) {
      setError("Catatan review wajib diisi saat pengajuan ditolak.");
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await apiData(`/master/cedex/code-proposals/${target.id}/review`, {
        method: "POST",
        accessToken,
        body: JSON.stringify({ decision, review_note: reviewNote.trim() })
      });
      setMessage(decision === "approved" ? "Pengajuan disetujui dan kode aktif dibuat untuk Customer terkait." : "Pengajuan ditolak.");
      setTarget(null);
      await loadRows();
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : "Review pengajuan gagal disimpan.");
    } finally {
      setSaving(false);
    }
  }

  return <div className="page-stack">
    <PageHeader title="Pengajuan Kode ISO CEDEX" description="Review kode yang tidak ditemukan Surveyor. Pengajuan tidak mengubah master aktif sebelum disetujui Admin." />
    {!isEditor ? <div className="alert alert-warning">Halaman dibuka dalam mode baca-saja. Review hanya dapat dilakukan oleh Admin atau Super Admin.</div> : null}
    <div className="toolbar">
      <label className="search-box"><Search size={17} /><span className="sr-only">Cari pengajuan</span><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Cari kode, deskripsi, atau alasan" /></label>
      <label><span className="sr-only">Filter status</span><select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}><option value="">Semua Status</option><option value="pending">Menunggu Persetujuan</option><option value="approved">Disetujui</option><option value="rejected">Ditolak</option></select></label>
      <label><span className="sr-only">Filter jenis kode</span><select value={codeType} onChange={(event) => { setPage(1); setCodeType(event.target.value); }}><option value="">Semua Jenis Kode</option><option value="location">Location Code</option><option value="component">Component Code</option><option value="damage">Damage Code</option><option value="action_repair">Action Repair Code</option><option value="material">Material Code</option></select></label>
      <button className="secondary-button" onClick={() => void loadRows()} type="button">Refresh</button>
    </div>
    {message ? <div className="alert alert-success">{message}</div> : null}
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    <DataTable responsiveCards rows={rows} isLoading={loading} page={page} totalPages={totalPages} onPageChange={setPage} emptyText="Belum ada pengajuan kode." columns={[
      { key: "code", header: "Code", render: (row) => <strong>{row.code}</strong> },
      { key: "type", header: "Jenis Kode", render: (row) => proposalTypeLabel(row.code_type) },
      { key: "description", header: "Description", render: (row) => row.description },
      { key: "reason", header: "Alasan Pengajuan", render: (row) => row.reason },
      { key: "customer", header: "Customer", render: (row) => row.customer_label ?? "-" },
      { key: "proposer", header: "Diajukan Oleh", render: (row) => row.proposed_by_label ?? "-" },
      { key: "evidence", header: "Foto / Bukti", render: (row) => row.evidence_file_id ?? "-" },
      { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "approved" ? "success" : row.status === "rejected" ? "danger" : "warning"}>{row.status === "pending" ? "Menunggu Persetujuan" : row.status === "approved" ? "Disetujui" : "Ditolak"}</StatusBadge> },
      { key: "actions", header: "Action", render: (row) => row.status === "pending" && isEditor ? <div className="row-actions"><button className="icon-button" aria-label={`Setujui ${row.code}`} onClick={() => openReview(row, "approved")} title="Setujui" type="button"><Check size={16} /></button><button className="icon-button danger-action" aria-label={`Tolak ${row.code}`} onClick={() => openReview(row, "rejected")} title="Tolak" type="button"><X size={16} /></button></div> : <span className="muted-text">{row.master_entity_id ? `Master: ${row.master_entity_id}` : row.review_note ?? "-"}</span> }
    ]} />
    <FormDialog title={`${decision === "approved" ? "Setujui" : "Tolak"} Pengajuan ${target?.code ?? ""}`} open={Boolean(target)} onClose={() => setTarget(null)} onSubmit={submitReview} isSubmitting={saving} submitLabel={decision === "approved" ? "Setujui & Aktifkan" : "Tolak Pengajuan"}>
      <div className="detail-grid"><div><span>Jenis Kode</span><strong>{proposalTypeLabel(target?.code_type ?? "")}</strong></div><div><span>Code</span><strong>{target?.code ?? "-"}</strong></div><div className="form-span-2"><span>Description</span><strong>{target?.description ?? "-"}</strong></div><div className="form-span-2"><span>Alasan</span><strong>{target?.reason ?? "-"}</strong></div></div>
      <label className="field"><span>Catatan Review{decision === "rejected" ? " *" : ""}</span><textarea rows={4} value={reviewNote} onChange={(event) => setReviewNote(event.target.value)} /></label>
    </FormDialog>
  </div>;
}

function proposalTypeLabel(value: string) {
  const labels: Record<string, string> = { location: "Location Code", component: "Component Code", damage: "Damage Code", action_repair: "Action Repair Code", material: "Material Code" };
  return labels[value] ?? value;
}
