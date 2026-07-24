"use client";

import { RefreshCw, Save, Search } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import { can } from "@/lib/permissions";

type CompanyProfile = {
  id?: string;
  company_name: string;
  brand_name: string;
  address: string;
  phone: string;
  email: string;
  website: string;
  tax_no: string;
  logo_file_id?: string | null;
  default_signature_file_id?: string | null;
  is_active: boolean;
};

type NumberingSetting = {
  id: string;
  document_type: string;
  prefix: string;
  doc_code: string;
  year_format: string;
  running_digits: number;
  reset_period: string;
  stored_preview: string;
  next_preview: string;
  current_number: number;
  next_number: number;
  current_period: string;
  is_active: boolean;
};

type AuditLog = {
  id: string;
  created_at: string;
  user_name: string;
  active_role: string;
  action: string;
  entity_type: string;
  entity_id?: string;
  old_state?: string;
  new_state?: string;
  old_value?: string;
  new_value?: string;
  reason?: string;
  request_id?: string;
  ip_address?: string;
  user_agent?: string;
};

const emptyCompany: CompanyProfile = {
  company_name: "", brand_name: "", address: "", phone: "", email: "", website: "", tax_no: "", is_active: true
};

export function CompanyProfileSettings() {
  const { accessToken, user } = useAuth();
  const [form, setForm] = useState<CompanyProfile>(emptyCompany);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const canSave = can(user, form.id ? "company_profiles.update.all" : "company_profiles.create.all");

  const load = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<CompanyProfile>("/fitness/master-data/company-profile?per_page=2", { accessToken });
      if (result.rows.length > 1) {
        setError("Ditemukan lebih dari satu Company Profile. Perbaikan data diperlukan sebelum perubahan dapat disimpan.");
      }
      setForm({ ...emptyCompany, ...(result.rows[0] ?? {}) });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil Company Profile.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken]);

  useEffect(() => { const timer = window.setTimeout(() => void load(), 0); return () => window.clearTimeout(timer); }, [load]);

  async function save() {
    if (!accessToken || !canSave || isSaving) return;
    if (!form.company_name.trim()) {
      setError("Nama badan usaha wajib diisi.");
      return;
    }
    setIsSaving(true);
    setError(null);
    setSuccess(null);
    const payload = {
      company_name: form.company_name.trim(), brand_name: nullIfEmpty(form.brand_name), address: nullIfEmpty(form.address),
      phone: nullIfEmpty(form.phone), email: nullIfEmpty(form.email), website: nullIfEmpty(form.website),
      tax_no: nullIfEmpty(form.tax_no), is_active: form.is_active
    };
    try {
      const saved = await apiData<CompanyProfile>(form.id ? `/fitness/master-data/company-profile/${form.id}` : "/fitness/master-data/company-profile", {
        method: form.id ? "PUT" : "POST", accessToken, body: JSON.stringify(payload)
      });
      setForm({ ...emptyCompany, ...saved });
      setSuccess("Company Profile berhasil disimpan.");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal menyimpan Company Profile.");
    } finally {
      setIsSaving(false);
    }
  }

  const missing = [
    ["Alamat", form.address], ["Telepon", form.phone], ["Email", form.email], ["Logo", form.logo_file_id]
  ].filter(([, value]) => !String(value ?? "").trim()).map(([label]) => label);

  return <div className="page-stack">
    <PageHeader title="Company Profile" description="Satu profil badan usaha internal GIFT untuk identitas operasional dan dokumen." action={canSave ? { label: isSaving ? "Menyimpan..." : "Simpan", icon: Save, onClick: () => void save(), disabled: isSaving || isLoading } : undefined} />
    {missing.length > 0 ? <div className="alert alert-warning">Data belum lengkap: {missing.join(", ")}. Upload logo belum diaktifkan, sehingga status logo hanya ditampilkan.</div> : null}
    {!canSave && !isLoading ? <div className="alert alert-warning">Role aktif hanya memiliki akses baca Company Profile.</div> : null}
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    {success ? <div className="alert alert-success">{success}</div> : null}
    <section className="workspace-panel">
      <div className="form-grid">
        <TextField label="Nama Badan Usaha" required value={form.company_name} disabled={isLoading || !canSave} onChange={(value) => setForm((current) => ({ ...current, company_name: value }))} />
        <TextField label="Brand" value={form.brand_name} disabled={isLoading || !canSave} onChange={(value) => setForm((current) => ({ ...current, brand_name: value }))} />
        <TextField label="Alamat" textarea value={form.address} disabled={isLoading || !canSave} onChange={(value) => setForm((current) => ({ ...current, address: value }))} />
        <TextField label="Telepon" type="tel" value={form.phone} disabled={isLoading || !canSave} onChange={(value) => setForm((current) => ({ ...current, phone: value }))} />
        <TextField label="Email" type="email" value={form.email} disabled={isLoading || !canSave} onChange={(value) => setForm((current) => ({ ...current, email: value }))} />
        <TextField label="Website" type="url" value={form.website} disabled={isLoading || !canSave} onChange={(value) => setForm((current) => ({ ...current, website: value }))} />
        <TextField label="Nomor Pajak" value={form.tax_no} disabled={isLoading || !canSave} onChange={(value) => setForm((current) => ({ ...current, tax_no: value }))} />
        <label className="field"><span>Status Logo</span><input readOnly value={form.logo_file_id ? "File logo tercatat" : "Belum tersedia"} /></label>
        <label className="field"><span>Status Tanda Tangan Default</span><input readOnly value={form.default_signature_file_id ? "File tanda tangan tercatat" : "Belum tersedia"} /></label>
        <label className="check-row form-check"><input checked={form.is_active} disabled={isLoading || !canSave} onChange={(event) => setForm((current) => ({ ...current, is_active: event.target.checked }))} type="checkbox" /><span>Profil aktif</span></label>
      </div>
    </section>
  </div>;
}

export function NumberingSettings() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<NumberingSetting[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const load = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true); setError(null);
    try { setRows(await apiData<NumberingSetting[]>("/settings/numbering", { accessToken })); }
    catch (err) { setError(err instanceof Error ? err.message : "Gagal mengambil pengaturan penomoran."); }
    finally { setIsLoading(false); }
  }, [accessToken]);
  useEffect(() => { const timer = window.setTimeout(() => void load(), 0); return () => window.clearTimeout(timer); }, [load]);
  return <div className="page-stack">
    <PageHeader title="Penomoran" description="Konfigurasi nomor dokumen dan contoh nomor berikutnya. Membuka halaman ini tidak menaikkan sequence." secondaryAction={{ label: "Muat Ulang", icon: RefreshCw, onClick: () => void load(), disabled: isLoading }} />
    <div className="alert alert-warning">Mode baca-saja. Perubahan format penomoran memerlukan keputusan terkontrol karena berdampak pada identitas dokumen.</div>
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    <DataTable rows={rows} isLoading={isLoading} emptyText="Konfigurasi penomoran belum tersedia." columns={[
      { key: "type", header: "Jenis Dokumen", render: (row) => humanize(row.document_type) },
      { key: "format", header: "Format", render: (row) => `${row.prefix}-${row.doc_code}-${row.year_format}-${"0".repeat(Math.min(row.running_digits, 12))}` },
      { key: "period", header: "Reset / Periode", render: (row) => `${humanize(row.reset_period)} / ${row.current_period}` },
      { key: "current", header: "Nomor Saat Ini", render: (row) => row.current_number },
      { key: "preview", header: "Preview Berikutnya", render: (row) => <strong>{row.next_preview}</strong> },
      { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.is_active ? "success" : "neutral"}>{row.is_active ? "Aktif" : "Tidak Aktif"}</StatusBadge> }
    ]} />
  </div>;
}

export function AuditLogSettings() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<AuditLog[]>([]);
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const query = useMemo(() => buildQuery({ page, per_page: 20, search }), [page, search]);
  const load = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true); setError(null);
    try {
      const result = await apiPaginated<AuditLog>(`/audit-logs${query}`, { accessToken });
      setRows(result.rows); setTotalPages(Math.max(1, Number(result.meta.total_pages ?? 1)));
    } catch (err) { setError(err instanceof Error ? err.message : "Gagal mengambil Audit Log."); }
    finally { setIsLoading(false); }
  }, [accessToken, query]);
  useEffect(() => { const timer = window.setTimeout(() => void load(), 250); return () => window.clearTimeout(timer); }, [load]);
  return <div className="page-stack">
    <PageHeader title="Audit Log" description="Jejak perubahan sistem dalam mode baca-saja." />
    <div className="toolbar"><label className="search-box"><Search size={17} /><span className="sr-only">Cari Audit Log</span><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Cari aksi, entitas, pengguna, role, request ID" /></label></div>
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    <DataTable rows={rows} isLoading={isLoading} page={page} totalPages={totalPages} onPageChange={setPage} emptyText="Audit Log tidak ditemukan." columns={[
      { key: "time", header: "Waktu", render: (row) => formatDateTime(row.created_at) },
      { key: "user", header: "Pengguna / Role", render: (row) => <><strong>{row.user_name}</strong><br /><span className="muted-text">{humanize(row.active_role || "sistem")}</span></> },
      { key: "action", header: "Aksi", render: (row) => humanize(row.action) },
      { key: "entity", header: "Entitas", render: (row) => <>{humanize(row.entity_type)}{row.entity_id ? <><br /><span className="muted-text">{row.entity_id}</span></> : null}</> },
      { key: "transition", header: "Perubahan", render: (row) => row.old_state || row.new_state ? `${humanize(row.old_state || "-")} → ${humanize(row.new_state || "-")}` : "-" },
      { key: "details", header: "Detail", render: (row) => <AuditDetails row={row} /> },
      { key: "request", header: "Request / IP", render: (row) => <><span>{row.request_id || "-"}</span><br /><span className="muted-text">{row.ip_address || "-"}</span></> }
    ]} />
  </div>;
}

function TextField({ label, value, onChange, disabled, required, textarea, type = "text" }: { label: string; value: string; onChange: (value: string) => void; disabled?: boolean; required?: boolean; textarea?: boolean; type?: string }) {
  return <label className="field"><span>{label}{required ? " *" : ""}</span>{textarea ? <textarea value={value} disabled={disabled} required={required} onChange={(event) => onChange(event.target.value)} /> : <input type={type} value={value} disabled={disabled} required={required} onChange={(event) => onChange(event.target.value)} />}</label>;
}

function AuditDetails({ row }: { row: AuditLog }) {
  if (!row.old_value && !row.new_value && !row.reason && !row.user_agent) return <span className="muted-text">-</span>;
  return <details><summary>Lihat</summary><div className="page-stack"><AuditValue label="Sebelum" value={row.old_value} /><AuditValue label="Sesudah" value={row.new_value} /><AuditValue label="Alasan" value={row.reason} /><AuditValue label="User Agent" value={row.user_agent} /></div></details>;
}

function AuditValue({ label, value }: { label: string; value?: string }) {
  if (!value) return null;
  return <div><strong>{label}</strong><pre className="muted-text">{prettyJSON(value)}</pre></div>;
}

function nullIfEmpty(value: string) { const trimmed = value.trim(); return trimmed || null; }
function humanize(value: string) { return value.replaceAll("_", " ").replaceAll(".", " ").replace(/\b\w/g, (letter) => letter.toUpperCase()); }
function prettyJSON(value: string) { try { return JSON.stringify(JSON.parse(value), null, 2); } catch { return value; } }
function formatDateTime(value: string) { const date = new Date(value); return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(date); }
