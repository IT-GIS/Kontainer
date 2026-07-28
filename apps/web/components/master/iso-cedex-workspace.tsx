"use client";

import { Box, ExternalLink, Hammer, History, MapPinned, PackageOpen, RotateCcw, Search, ShieldAlert, UserRoundCog } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useId, useRef, useState } from "react";
import type { FormEvent, RefObject } from "react";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { ApiClientError, apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import { can } from "@/lib/permissions";

export type IsoCedexTab = "location" | "component" | "damage" | "action" | "material";
type MasterRow = Record<string, string | number | boolean | null | undefined>;
type FormState = { code: string; description: string; status: "active" | "inactive" };
type FormErrors = Partial<Record<keyof FormState | "form", string>>;
type StatusFilter = "" | "active" | "inactive" | "legacy";
type SectionDefinition = {
  id: IsoCedexTab; title: string; subtitle?: string; description: string;
  codeLabel: string; codeLength: number; placeholder: string; helper: string;
  endpoint: string; permissionModule: string;
  nameField: "grid_code" | "component_name" | "damage_name" | "repair_name" | "material_name";
  emptyDescription: string; icon: typeof MapPinned;
};

const sections: SectionDefinition[] = [
  {
    id: "location", title: "Damage Location", description: "Kode posisi atau koordinat kerusakan pada peti kemas.",
    codeLabel: "Location Code", codeLength: 4, placeholder: "Contoh: BR5N",
    helper: "Gunakan 4 karakter huruf atau angka tanpa spasi dan tanda baca.", endpoint: "/master/cedex/locations",
    permissionModule: "cedex_locations", nameField: "grid_code",
    emptyDescription: "Tambahkan Location Code agar Surveyor dapat memilih posisi kerusakan saat mencatat temuan.", icon: MapPinned
  },
  {
    id: "component", title: "Component / Part", description: "Kode komponen atau bagian peti kemas yang mengalami kerusakan.",
    codeLabel: "Component Code", codeLength: 3, placeholder: "Contoh: FPP",
    helper: "Gunakan 3 karakter huruf atau angka tanpa spasi dan tanda baca.", endpoint: "/master/cedex/components",
    permissionModule: "cedex_components", nameField: "component_name",
    emptyDescription: "Tambahkan Component Code agar Surveyor dapat memilih bagian peti kemas saat mencatat temuan.", icon: Box
  },
  {
    id: "damage", title: "Damage Type", description: "Kode jenis kerusakan yang ditemukan Surveyor.",
    codeLabel: "Damage Code", codeLength: 2, placeholder: "Contoh: DT",
    helper: "Gunakan 2 karakter huruf atau angka tanpa spasi dan tanda baca.", endpoint: "/master/cedex/damages",
    permissionModule: "cedex_damages", nameField: "damage_name",
    emptyDescription: "Tambahkan Damage Code agar Surveyor dapat memilih jenis kerusakan saat mencatat temuan.", icon: ShieldAlert
  },
  {
    id: "action", title: "Action Repair", subtitle: "Rekomendasi Tindakan",
    description: "Kode metode atau tindakan perbaikan yang direkomendasikan. GIFT tidak mengelola pekerjaan repair internal.",
    codeLabel: "Action Repair Code", codeLength: 2, placeholder: "Contoh: GS",
    helper: "Gunakan 2 karakter huruf atau angka tanpa spasi dan tanda baca.", endpoint: "/master/cedex/repairs",
    permissionModule: "cedex_repairs", nameField: "repair_name",
    emptyDescription: "Tambahkan Action Repair Code agar Surveyor dapat memilih rekomendasi tindakan.", icon: Hammer
  },
  {
    id: "material", title: "Material Type", description: "Kode jenis material komponen atau material yang terkait dengan tindakan.",
    codeLabel: "Material Code", codeLength: 2, placeholder: "Contoh: PP",
    helper: "Gunakan 2 karakter huruf atau angka tanpa spasi dan tanda baca.", endpoint: "/master/cedex/materials",
    permissionModule: "cedex_materials", nameField: "material_name",
    emptyDescription: "Tambahkan Material Code agar Surveyor dapat memilih jenis material yang terkait dengan temuan.", icon: PackageOpen
  }
];
export function IsoCedexWorkspace({ initialTab = "location" }: { initialTab?: IsoCedexTab }) {
  const { user } = useAuth();
  const readOnly = !user?.roles.some((role) => role === "admin" || role === "super_admin");
  useEffect(() => {
    if (initialTab === "location") return;
    const timer = window.setTimeout(() => document.getElementById(`iso-cedex-${initialTab}`)?.scrollIntoView({ behavior: "smooth", block: "start" }), 100);
    return () => window.clearTimeout(timer);
  }, [initialTab]);
  return <div className="page-stack iso-cedex-workspace">
    <section className="iso-cedex-heading">
      <div><p className="eyebrow">MASTER DATA</p><h1>ISO CEDEX Code Master</h1><p>Kelola kode lokasi, komponen, kerusakan, tindakan perbaikan, dan material yang digunakan Surveyor pada Inspeksi Kelaikan.</p></div>
      <div className="iso-cedex-heading-actions">
        <Link className="secondary-button" href="/master/inspection-references"><ExternalLink size={16} />Buka Acuan Pemeriksaan</Link>
        <Link className="secondary-button" href="/master/iso-cedex/proposals"><UserRoundCog size={16} />Review Pengajuan</Link>
        <Link className="secondary-button" href="/settings/audit-log"><History size={16} />Riwayat Perubahan</Link>
      </div>
    </section>
    <div className="alert alert-info iso-cedex-how-it-works"><strong>Cara kerja:</strong><span>Kode yang disimpan di halaman ini akan digunakan Surveyor untuk mencatat temuan. Deskripsi lengkap akan dibuat otomatis oleh sistem pada laporan.</span></div>
    {readOnly ? <div className="alert alert-warning">Halaman dibuka dalam mode baca-saja. Hanya Admin dan Super Admin yang dapat mengubah master ISO CEDEX.</div> : null}
    <div className="iso-cedex-section-list">{sections.map((section) => <IsoCedexSection definition={section} forceReadOnly={readOnly} key={section.id} />)}</div>
  </div>;
}

function IsoCedexSection({ definition, forceReadOnly }: { definition: SectionDefinition; forceReadOnly: boolean }) {
  const { accessToken, user } = useAuth();
  const fieldID = useId();
  const codeInputRef = useRef<HTMLInputElement>(null);
  const [rows, setRows] = useState<MasterRow[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalRows, setTotalRows] = useState(0);
  const [searchInput, setSearchInput] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("");
  const [form, setForm] = useState<FormState>(emptyForm);
  const [editing, setEditing] = useState<MasterRow | null>(null);
  const [errors, setErrors] = useState<FormErrors>({});
  const [loadError, setLoadError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [pendingRowID, setPendingRowID] = useState<string | null>(null);
  const requestSequence = useRef(0);
  const canCreate = !forceReadOnly && can(user, `${definition.permissionModule}.create.all`);
  const canUpdate = !forceReadOnly && can(user, `${definition.permissionModule}.update.all`);
  const canDeactivate = !forceReadOnly && can(user, `${definition.permissionModule}.delete.all`);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    const requestID = ++requestSequence.current;
    setIsLoading(true); setLoadError(null);
    try {
      const result = await apiPaginated<MasterRow>(`${definition.endpoint}${buildQuery({
        page, per_page: 10, search: debouncedSearch,
        status: statusFilter === "active" || statusFilter === "inactive" ? statusFilter : undefined,
        source: statusFilter === "legacy" ? "legacy" : undefined, sort_by: "code", sort_order: "asc"
      })}`, { accessToken });
      if (requestID !== requestSequence.current) return;
      setRows(result.rows); setTotalPages(Math.max(1, Number(result.meta.total_pages ?? 1))); setTotalRows(Number(result.meta.total ?? result.rows.length));
    } catch (error) {
      if (requestID === requestSequence.current) setLoadError(errorMessage(error, "Daftar data gagal dimuat."));
    } finally { if (requestID === requestSequence.current) setIsLoading(false); }
  }, [accessToken, debouncedSearch, definition.endpoint, page, statusFilter]);

  useEffect(() => {
    const timer = window.setTimeout(() => { setPage(1); setDebouncedSearch(searchInput.trim()); }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);
  useEffect(() => { const timer = window.setTimeout(() => void loadRows(), 0); return () => window.clearTimeout(timer); }, [loadRows]);

  function changeForm<Key extends keyof FormState>(field: Key, value: FormState[Key]) {
    setForm((current) => ({ ...current, [field]: value }));
    setErrors((current) => ({ ...current, [field]: undefined, form: undefined })); setSuccess(null);
  }
  function beginEdit(row: MasterRow) {
    if (!rowCanMutate(definition, row)) return;
    setEditing(row); setForm({ code: String(row.code ?? "").toUpperCase(), description: rowDescription(definition, row), status: isInactive(row) ? "inactive" : "active" });
    setErrors({}); setSuccess(null); codeInputRef.current?.focus();
    document.getElementById(`iso-cedex-${definition.id}`)?.scrollIntoView({ behavior: "smooth", block: "start" });
  }
  function cancelEdit() { setEditing(null); setForm(emptyForm()); setErrors({}); setSuccess(null); codeInputRef.current?.focus(); }
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!accessToken || isSubmitting || (editing ? !canUpdate : !canCreate)) return;
    const nextErrors = validateForm(definition, form);
    if (Object.keys(nextErrors).length > 0) { setErrors(nextErrors); return; }
    setIsSubmitting(true); setErrors({}); setSuccess(null);
    const normalized = { ...form, code: form.code.trim().toUpperCase(), description: form.description.trim() };
    try {
      const payload = compatibilityPayload(definition, normalized, editing === null);
      if (editing?.id) {
        await apiData(`${definition.endpoint}/${editing.id}`, { method: "PUT", accessToken, body: JSON.stringify(payload) });
        setSuccess(`${definition.codeLabel} berhasil diperbarui.`);
      } else {
        await apiData(definition.endpoint, { method: "POST", accessToken, body: JSON.stringify(payload) });
        setSuccess(`${definition.codeLabel} berhasil disimpan.`);
      }
      setEditing(null); setForm(emptyForm()); await loadRows(); codeInputRef.current?.focus();
    } catch (error) {
      if (error instanceof ApiClientError && error.code === "DUPLICATE_RESOURCE") setErrors({ code: `${definition.codeLabel} sudah digunakan. Gunakan kode lain atau edit data yang sudah ada.` });
      else setErrors({ form: error instanceof ApiClientError ? error.details?.[0]?.message ?? error.message : errorMessage(error, "Data gagal disimpan.") });
    } finally { setIsSubmitting(false); }
  }

  async function toggleStatus(row: MasterRow, nextStatus: "active" | "inactive") {
    const id = String(row.id ?? "");
    if (!accessToken || !id || pendingRowID) return;
    const actionLabel = nextStatus === "active" ? "Aktifkan" : "Nonaktifkan";
    if (!window.confirm(`${actionLabel} ${definition.codeLabel} ${String(row.code ?? "")}?`)) return;
    setPendingRowID(id); setLoadError(null); setSuccess(null);
    try {
      if (nextStatus === "inactive") await apiData(`${definition.endpoint}/${id}`, { method: "DELETE", accessToken });
      else await apiData(`${definition.endpoint}/${id}`, { method: "PUT", accessToken, body: JSON.stringify({ status: "active" }) });
      setSuccess(`${definition.codeLabel} berhasil ${nextStatus === "active" ? "diaktifkan" : "dinonaktifkan"}.`);
      if (editing?.id === id) { setEditing(null); setForm(emptyForm()); setErrors({}); }
      await loadRows();
    } catch (error) { setLoadError(errorMessage(error, `${definition.codeLabel} gagal diubah.`)); }
    finally { setPendingRowID(null); }
  }

  const sectionReadOnly = forceReadOnly || (!canCreate && !canUpdate && !canDeactivate);
  const Icon = definition.icon;
  return <section aria-labelledby={`${fieldID}-title`} className="iso-master-section" id={`iso-cedex-${definition.id}`}>
    <header className="iso-master-section-heading"><span className="iso-master-section-icon"><Icon size={21} /></span><div>
      <div className="iso-master-title-row"><h2 id={`${fieldID}-title`}>{editing ? `Edit ${definition.title}` : definition.title}</h2>{definition.subtitle ? <span>{definition.subtitle}</span> : null}</div>
      <p>{definition.description}</p>
    </div></header>
    <form className="iso-master-form" onSubmit={submit} noValidate>
      <label className="field iso-master-code-field"><span>{definition.codeLabel} *</span>
        <input aria-describedby={`${fieldID}-code-help${errors.code ? ` ${fieldID}-code-error` : ""}`} aria-invalid={Boolean(errors.code)} autoCapitalize="characters" disabled={sectionReadOnly || isSubmitting || (editing !== null && !canUpdate)} maxLength={definition.codeLength} onChange={(event) => changeForm("code", event.target.value.toUpperCase())} pattern={`[A-Za-z0-9]{${definition.codeLength}}`} placeholder={definition.placeholder} ref={codeInputRef} value={form.code} />
        <small className="muted-text" id={`${fieldID}-code-help`}>{definition.helper}</small>{errors.code ? <small className="field-error" id={`${fieldID}-code-error`}>{errors.code}</small> : null}
      </label>
      <label className="field iso-master-description-field"><span>Description *</span>
        <textarea aria-describedby={errors.description ? `${fieldID}-description-error` : undefined} aria-invalid={Boolean(errors.description)} disabled={sectionReadOnly || isSubmitting || (editing !== null && !canUpdate)} onChange={(event) => changeForm("description", event.target.value)} placeholder={`Deskripsi ${definition.codeLabel.toLowerCase()}`} rows={2} value={form.description} />
        {errors.description ? <small className="field-error" id={`${fieldID}-description-error`}>{errors.description}</small> : null}
      </label>
      <label className="field iso-master-status-field"><span>Status</span><select disabled={sectionReadOnly || isSubmitting || (editing !== null && !canUpdate)} onChange={(event) => changeForm("status", event.target.value as FormState["status"])} value={form.status}><option value="active">Aktif</option><option value="inactive">Tidak Aktif</option></select></label>
      <div className="iso-master-form-actions"><button className="primary-button" disabled={isSubmitting || (editing ? !canUpdate : !canCreate)} type="submit">{isSubmitting ? "Menyimpan..." : editing ? "Simpan Perubahan" : "Simpan"}</button>{editing ? <button className="secondary-button" disabled={isSubmitting} onClick={cancelEdit} type="button">Batal Edit</button> : null}</div>
    </form>
    {errors.form ? <div className="alert alert-danger" role="alert">{errors.form}</div> : null}
    {success ? <div className="alert alert-success" role="status">{success}</div> : null}
    {loadError ? <div className="alert alert-danger" role="alert">{loadError}</div> : null}
    <div className="iso-master-toolbar">
      <label className="search-box"><Search size={17} /><span className="sr-only">Cari {definition.title}</span><input onChange={(event) => setSearchInput(event.target.value)} placeholder={`Cari ${definition.codeLabel} atau description`} type="search" value={searchInput} /></label>
      <label><span className="sr-only">Filter status {definition.title}</span><select onChange={(event) => { setPage(1); setStatusFilter(event.target.value as StatusFilter); }} value={statusFilter}><option value="">Semua</option><option value="active">Aktif</option><option value="inactive">Tidak Aktif</option><option value="legacy">Legacy</option></select></label>
      <span className="iso-master-total">{isLoading ? "Memuat..." : `${totalRows} data`}</span>
    </div>
    <MasterList canDeactivate={canDeactivate} canUpdate={canUpdate} codeInputRef={codeInputRef} definition={definition} isLoading={isLoading} onEdit={beginEdit} onToggleStatus={toggleStatus} pendingRowID={pendingRowID} rows={rows} />
    {totalPages > 1 ? <nav aria-label={`Pagination ${definition.title}`} className="iso-master-pagination">
      <button className="secondary-button" disabled={page <= 1 || isLoading} onClick={() => setPage((current) => Math.max(1, current - 1))} type="button">Sebelumnya</button><span>Halaman {page} dari {totalPages}</span><button className="secondary-button" disabled={page >= totalPages || isLoading} onClick={() => setPage((current) => Math.min(totalPages, current + 1))} type="button">Berikutnya</button>
    </nav> : null}
  </section>;
}

function MasterList({ definition, rows, isLoading, canUpdate, canDeactivate, pendingRowID, codeInputRef, onEdit, onToggleStatus }: {
  definition: SectionDefinition; rows: MasterRow[]; isLoading: boolean; canUpdate: boolean; canDeactivate: boolean;
  pendingRowID: string | null; codeInputRef: RefObject<HTMLInputElement | null>;
  onEdit: (row: MasterRow) => void; onToggleStatus: (row: MasterRow, status: "active" | "inactive") => void;
}) {
  if (isLoading && rows.length === 0) return <div className="iso-master-empty"><p>Memuat daftar {definition.codeLabel}...</p></div>;
  if (rows.length === 0) return <div className="iso-master-empty"><strong>Belum ada {definition.codeLabel}</strong><p>{definition.emptyDescription}</p>{canUpdate ? <button className="secondary-button" onClick={() => codeInputRef.current?.focus()} type="button">Tambah {definition.codeLabel}</button> : null}</div>;
  return <div className="iso-master-table-wrap"><table className="iso-master-table">
    <thead><tr><th>{definition.codeLabel}</th><th>Description</th><th>Status</th><th>Updated At</th><th>Action</th></tr></thead>
    <tbody>{rows.map((row) => {
      const id = String(row.id ?? `${definition.id}-${String(row.code ?? "")}`);
      const inactive = isInactive(row); const mutable = rowCanMutate(definition, row); const pending = pendingRowID === id;
      return <tr key={id}>
        <td data-label={definition.codeLabel}><strong className="iso-master-code">{String(row.code ?? "-")}</strong>{String(row.source_type ?? "legacy") === "legacy" ? <StatusBadge tone="neutral">Legacy</StatusBadge> : null}</td>
        <td data-label="Description">{rowDescription(definition, row) || "-"}</td>
        <td data-label="Status"><StatusBadge tone={inactive ? "neutral" : "success"}>{inactive ? "Tidak Aktif" : "Aktif"}</StatusBadge></td>
        <td data-label="Updated At">{formatDateTime(row.updated_at)}</td>
        <td data-label="Action"><div className="iso-master-row-actions">
          <button className="text-button" disabled={!canUpdate || !mutable || pending} onClick={() => onEdit(row)} type="button">Edit</button>
          {inactive ? <button className="text-button" disabled={!canUpdate || !mutable || pending} onClick={() => onToggleStatus(row, "active")} type="button"><RotateCcw size={14} />Aktifkan</button> : <button className="text-button danger-action" disabled={!canDeactivate || !mutable || pending} onClick={() => onToggleStatus(row, "inactive")} type="button">Nonaktifkan</button>}
          <Link className="text-button" href={`/settings/audit-log?search=${encodeURIComponent(String(row.id ?? row.code ?? ""))}`}><History size={14} />Riwayat</Link>
          {!mutable ? <span className="muted-text">Read-only</span> : null}
        </div></td>
      </tr>;
    })}</tbody>
  </table></div>;
}
function emptyForm(): FormState { return { code: "", description: "", status: "active" }; }

function validateForm(definition: SectionDefinition, form: FormState): FormErrors {
  const errors: FormErrors = {};
  if (!new RegExp(`^[A-Z0-9]{${definition.codeLength}}$`).test(form.code.trim())) errors.code = `${definition.codeLabel} wajib terdiri dari tepat ${definition.codeLength} karakter huruf atau angka.`;
  if (!form.description.trim()) errors.description = "Description wajib diisi.";
  return errors;
}

function compatibilityPayload(definition: SectionDefinition, form: FormState, create: boolean): MasterRow {
  const payload: MasterRow = { code: form.code, description: form.description, status: form.status };
  if (create) payload.source_type = "standard_global";
  if (definition.id === "location") {
    payload.input_mode = "manual"; payload.face = locationFace(form.code); payload.grid_code = form.code;
  } else {
    payload[definition.nameField] = form.description;
    if (definition.id === "damage" && create) payload.default_severity = "minor";
  }
  return payload;
}

function locationFace(code: string) {
  const faces: Record<string, string> = { D: "door", L: "left", R: "right", F: "front", U: "understructure", T: "roof", B: "floor" };
  return faces[code.slice(0, 1).toUpperCase()] ?? "other";
}
function rowDescription(definition: SectionDefinition, row: MasterRow) { return String(row.description ?? row[definition.nameField] ?? ""); }
function rowCanMutate(definition: SectionDefinition, row: MasterRow) {
  if (String(row.source_type ?? "legacy") !== "legacy") return true;
  return new RegExp(`^[A-Za-z0-9]{${definition.codeLength}}$`).test(String(row.code ?? ""));
}
function isInactive(row: MasterRow) { return String(row.status ?? "").toLowerCase() === "inactive"; }
function formatDateTime(value: MasterRow[string]) {
  if (!value) return "-";
  const date = new Date(String(value));
  if (Number.isNaN(date.getTime())) return String(value);
  return new Intl.DateTimeFormat("id-ID", { dateStyle: "medium", timeStyle: "short" }).format(date);
}
function errorMessage(error: unknown, fallback: string) { return error instanceof Error && error.message ? error.message : fallback; }
