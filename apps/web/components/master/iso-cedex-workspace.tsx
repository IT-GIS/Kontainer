'use client';

import {
  Box, ChevronLeft, ChevronRight, ExternalLink, Hammer, History, Info, MapPinned,
  MoreHorizontal, PackageOpen, Pencil, Plus, RotateCcw, Search, ShieldAlert, UserRoundCog
} from 'lucide-react';
import Link from 'next/link';
import { useCallback, useEffect, useId, useRef, useState } from 'react';
import type { FormEvent, RefObject } from 'react';
import { StatusBadge } from '@/components/ui/status-badge';
import { ToastFeedback } from '@/components/ui/toast-feedback';
import { useAuth } from '@/hooks/use-auth';
import { ApiClientError, apiData, apiPaginated, buildQuery } from '@/lib/api-client';
import { can } from '@/lib/permissions';

export type IsoCedexTab = 'location' | 'component' | 'damage' | 'action' | 'material';
type MasterRow = Record<string, string | number | boolean | null | undefined>;
type FormState = { code: string; description: string; status: 'active' | 'inactive' };
type FormErrors = Partial<Record<keyof FormState | 'form', string>>;
type StatusFilter = '' | 'active' | 'inactive' | 'legacy';
type ActiveCounts = Partial<Record<IsoCedexTab, number | null>>;
type SectionDefinition = {
  id: IsoCedexTab; title: string; subtitle?: string; description: string;
  codeLabel: string; codeLength: number; placeholder: string; helper: string;
  endpoint: string; permissionModule: string;
  nameField: 'grid_code' | 'component_name' | 'damage_name' | 'repair_name' | 'material_name';
  emptyDescription: string; icon: typeof MapPinned;
};

const sections: SectionDefinition[] = [
  {
    id: "location", title: "Damage Location", description: 'Kode posisi atau koordinat kerusakan pada peti kemas.',
    codeLabel: 'Location Code', codeLength: 4, placeholder: 'Contoh: BR5N',
    helper: 'Gunakan 4 karakter huruf atau angka tanpa spasi dan tanda baca.', endpoint: '/master/cedex/locations',
    permissionModule: 'cedex_locations', nameField: 'grid_code',
    emptyDescription: 'Tambahkan Location Code agar Surveyor dapat memilih posisi kerusakan saat mencatat temuan.', icon: MapPinned
  },
  {
    id: "component", title: "Component / Part", description: 'Kode komponen atau bagian peti kemas yang mengalami kerusakan.',
    codeLabel: 'Component Code', codeLength: 3, placeholder: 'Contoh: FPP',
    helper: 'Gunakan 3 karakter huruf atau angka tanpa spasi dan tanda baca.', endpoint: '/master/cedex/components',
    permissionModule: 'cedex_components', nameField: 'component_name',
    emptyDescription: 'Tambahkan Component Code agar Surveyor dapat memilih bagian peti kemas saat mencatat temuan.', icon: Box
  },
  {
    id: "damage", title: "Damage Type", description: 'Kode jenis kerusakan yang ditemukan Surveyor.',
    codeLabel: 'Damage Code', codeLength: 2, placeholder: 'Contoh: DT',
    helper: 'Gunakan 2 karakter huruf atau angka tanpa spasi dan tanda baca.', endpoint: '/master/cedex/damages',
    permissionModule: 'cedex_damages', nameField: 'damage_name',
    emptyDescription: 'Tambahkan Damage Code agar Surveyor dapat memilih jenis kerusakan saat mencatat temuan.', icon: ShieldAlert
  },
  {
    id: "action", title: "Action Repair", subtitle: 'Rekomendasi Tindakan',
    description: 'Kode metode atau tindakan perbaikan yang direkomendasikan. GIFT tidak mengelola pekerjaan repair internal.',
    codeLabel: 'Action Repair Code', codeLength: 2, placeholder: 'Contoh: GS',
    helper: 'Gunakan 2 karakter huruf atau angka tanpa spasi dan tanda baca.', endpoint: '/master/cedex/repairs',
    permissionModule: 'cedex_repairs', nameField: 'repair_name',
    emptyDescription: 'Tambahkan Action Repair Code agar Surveyor dapat memilih rekomendasi tindakan.', icon: Hammer
  },
  {
    id: "material", title: "Material Type", description: 'Kode jenis material komponen atau material yang terkait dengan tindakan.',
    codeLabel: 'Material Code', codeLength: 2, placeholder: 'Contoh: PP',
    helper: 'Gunakan 2 karakter huruf atau angka tanpa spasi dan tanda baca.', endpoint: '/master/cedex/materials',
    permissionModule: 'cedex_materials', nameField: 'material_name',
    emptyDescription: 'Tambahkan Material Code agar Surveyor dapat memilih jenis material yang terkait dengan temuan.', icon: PackageOpen
  }
];

export function IsoCedexWorkspace({ initialTab = 'location' }: { initialTab?: IsoCedexTab }) {
  const { accessToken, user } = useAuth();
  const [activeTab, setActiveTab] = useState<IsoCedexTab>(initialTab);
  const [activeCounts, setActiveCounts] = useState<ActiveCounts>({});
  const readOnly = !user?.roles.some((role) => role === 'admin' || role === 'super_admin');
  const activeDefinition = sections.find((section) => section.id === activeTab) ?? sections[0];

  const loadActiveCount = useCallback(async (definition: SectionDefinition) => {
    if (!accessToken) return;
    try {
      const result = await apiPaginated<MasterRow>(`${definition.endpoint}${buildQuery({ page: 1, per_page: 1, status: 'active' })}`, { accessToken });
      setActiveCounts((current) => ({ ...current, [definition.id]: Number(result.meta.total ?? result.rows.length) }));
    } catch {
      setActiveCounts((current) => ({ ...current, [definition.id]: null }));
    }
  }, [accessToken]);

  useEffect(() => {
    if (!accessToken) return;
    const timer = window.setTimeout(() => {
      for (const definition of sections) void loadActiveCount(definition);
    }, 0);
    return () => window.clearTimeout(timer);
  }, [accessToken, loadActiveCount]);
  useEffect(() => {
    function syncSectionFromHistory() {
      const params = new URLSearchParams(window.location.search);
      const requested = params.get('section') ?? params.get('tab');
      if (isIsoCedexTab(requested)) setActiveTab(requested);
    }
    window.addEventListener('popstate', syncSectionFromHistory);
    return () => window.removeEventListener('popstate', syncSectionFromHistory);
  }, []);

  function selectSection(section: IsoCedexTab) {
    if (section === activeTab) return;
    setActiveTab(section);
    const params = new URLSearchParams(window.location.search);
    params.set('section', section);
    params.delete('tab');
    window.history.pushState(null, '', `${window.location.pathname}?${params.toString()}${window.location.hash}`);
  }

  return <div className='page-stack iso-cedex-workspace'>
    <section className='iso-cedex-heading'>
      <div><p className='eyebrow'>MASTER DATA</p><h1>ISO CEDEX Code Master</h1><p>Kelola kode yang digunakan Surveyor saat mencatat temuan Inspeksi Kelaikan.</p></div>
      <div aria-label='Tautan terkait ISO CEDEX' className='iso-cedex-heading-actions'>
        <Link className='secondary-button' href='/master/inspection-references'><ExternalLink size={16} />Buka Acuan Pemeriksaan</Link>
        <Link className='secondary-button' href='/master/iso-cedex/proposals'><UserRoundCog size={16} />Review Pengajuan</Link>
        <Link className='secondary-button' href='/settings/audit-log'><History size={16} />Riwayat Perubahan</Link>
      </div>
    </section>
    <section className='iso-cedex-how-it-works'>
      <span aria-hidden='true' className='iso-cedex-info-icon'><Info size={18} /></span>
      <div><strong>Cara kerja</strong><p>Admin menyiapkan kode CEDEX. Surveyor memilih kode tersebut saat inspeksi. Deskripsi lengkap dibuat otomatis oleh sistem.</p></div>
    </section>
    <nav aria-label='Kategori ISO CEDEX' className='iso-cedex-category-nav' role='tablist'>
      {sections.map((section) => {
        const Icon = section.icon;
        const count = activeCounts[section.id];
        return <button aria-controls={`iso-cedex-${section.id}`} aria-selected={activeTab === section.id} className={activeTab === section.id ? 'is-active' : undefined} id={`iso-cedex-tab-${section.id}`} key={section.id} onClick={() => selectSection(section.id)} role='tab' type='button'>
          <span aria-hidden='true' className='iso-cedex-category-icon'><Icon size={18} /></span>
          <span><strong>{section.title}</strong><small>{count === undefined ? 'Menghitung...' : count === null ? 'Jumlah tidak tersedia' : `${count} aktif`}</small></span>
        </button>;
      })}
    </nav>
    <IsoCedexSection definition={activeDefinition} forceReadOnly={readOnly} key={activeDefinition.id} onDataChanged={() => void loadActiveCount(activeDefinition)} />
  </div>;
}

function IsoCedexSection({ definition, forceReadOnly, onDataChanged }: {
  definition: SectionDefinition; forceReadOnly: boolean; onDataChanged: () => void;
}) {
  const { accessToken, user } = useAuth();
  const fieldID = useId();
  const codeInputRef = useRef<HTMLInputElement>(null);
  const formRegionRef = useRef<HTMLDivElement>(null);
  const [rows, setRows] = useState<MasterRow[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalRows, setTotalRows] = useState(0);
  const [searchInput, setSearchInput] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<StatusFilter>('');
  const [form, setForm] = useState<FormState>(emptyForm);
  const [editing, setEditing] = useState<MasterRow | null>(null);
  const [errors, setErrors] = useState<FormErrors>({});
  const [loadError, setLoadError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [hasLoaded, setHasLoaded] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [pendingRowID, setPendingRowID] = useState<string | null>(null);
  const requestSequence = useRef(0);
  const canCreate = !forceReadOnly && can(user, `${definition.permissionModule}.create.all`);
  const canUpdate = !forceReadOnly && can(user, `${definition.permissionModule}.update.all`);
  const canDeactivate = !forceReadOnly && can(user, `${definition.permissionModule}.delete.all`);
  const sectionReadOnly = forceReadOnly || (!canCreate && !canUpdate && !canDeactivate);
  const Icon = definition.icon;

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    const requestID = ++requestSequence.current;
    setIsLoading(true);
    setLoadError(null);
    try {
      const result = await apiPaginated<MasterRow>(`${definition.endpoint}${buildQuery({
        page, per_page: 10, search: debouncedSearch,
        status: statusFilter === 'active' || statusFilter === 'inactive' ? statusFilter : undefined,
        source: statusFilter === 'legacy' ? 'legacy' : undefined, sort_by: 'code', sort_order: 'asc'
      })}`, { accessToken });
      if (requestID !== requestSequence.current) return;
      setRows(result.rows);
      setTotalPages(Math.max(1, Number(result.meta.total_pages ?? 1)));
      setTotalRows(Number(result.meta.total ?? result.rows.length));
    } catch (error) {
      if (requestID === requestSequence.current) setLoadError(errorMessage(error, 'Daftar data gagal dimuat.'));
    } finally {
      if (requestID === requestSequence.current) {
        setIsLoading(false);
        setHasLoaded(true);
      }
    }
  }, [accessToken, debouncedSearch, definition.endpoint, page, statusFilter]);

  useEffect(() => {
    const timer = window.setTimeout(() => { setPage(1); setDebouncedSearch(searchInput.trim()); }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);
  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  function changeForm<Key extends keyof FormState>(field: Key, value: FormState[Key]) {
    setForm((current) => ({ ...current, [field]: value }));
    setErrors((current) => ({ ...current, [field]: undefined, form: undefined }));
    setSuccess(null);
  }

  function beginEdit(row: MasterRow) {
    if (!canUpdate || !rowCanMutate(definition, row)) return;
    setEditing(row);
    setForm({ code: String(row.code ?? '').toUpperCase(), description: rowDescription(definition, row), status: isInactive(row) ? 'inactive' : 'active' });
    setErrors({});
    setSuccess(null);
    window.requestAnimationFrame(() => {
      formRegionRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' });
      window.setTimeout(() => codeInputRef.current?.focus({ preventScroll: true }), 240);
    });
  }

  function cancelEdit() {
    setEditing(null);
    setForm(emptyForm());
    setErrors({});
    setSuccess(null);
    codeInputRef.current?.focus();
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!accessToken || isSubmitting || (editing ? !canUpdate : !canCreate)) return;
    const nextErrors = validateForm(definition, form);
    if (Object.keys(nextErrors).length > 0) { setErrors(nextErrors); return; }
    setIsSubmitting(true);
    setErrors({});
    setSuccess(null);
    const normalized = { ...form, code: form.code.trim().toUpperCase(), description: form.description.trim() };
    try {
      const payload = compatibilityPayload(definition, normalized, editing === null);
      if (editing?.id) {
        await apiData(`${definition.endpoint}/${editing.id}`, { method: 'PUT', accessToken, body: JSON.stringify(payload) });
        setSuccess(`${definition.codeLabel} berhasil diperbarui.`);
      } else {
        await apiData(definition.endpoint, { method: 'POST', accessToken, body: JSON.stringify(payload) });
        setSuccess(`${definition.codeLabel} berhasil disimpan.`);
      }
      setEditing(null);
      setForm(emptyForm());
      await loadRows();
      onDataChanged();
      codeInputRef.current?.focus();
    } catch (error) {
      if (error instanceof ApiClientError && error.code === 'DUPLICATE_RESOURCE') {
        setErrors({ code: `${definition.codeLabel} sudah digunakan. Gunakan kode lain atau edit data yang sudah ada.` });
      } else {
        setErrors({ form: error instanceof ApiClientError ? error.details?.[0]?.message ?? error.message : errorMessage(error, 'Data gagal disimpan.') });
      }
    } finally {
      setIsSubmitting(false);
    }
  }

  async function toggleStatus(row: MasterRow, nextStatus: 'active' | 'inactive') {
    const id = String(row.id ?? '');
    const allowed = nextStatus === 'active' ? canUpdate : canDeactivate;
    if (!accessToken || !id || pendingRowID || !allowed) return;
    const actionLabel = nextStatus === 'active' ? 'Aktifkan' : 'Nonaktifkan';
    if (!window.confirm(`${actionLabel} ${definition.codeLabel} ${String(row.code ?? '')}?`)) return;
    setPendingRowID(id);
    setLoadError(null);
    setSuccess(null);
    try {
      if (nextStatus === 'inactive') await apiData(`${definition.endpoint}/${id}`, { method: 'DELETE', accessToken });
      else await apiData(`${definition.endpoint}/${id}`, { method: 'PUT', accessToken, body: JSON.stringify({ status: 'active' }) });
      setSuccess(`${definition.codeLabel} berhasil ${nextStatus === 'active' ? 'diaktifkan' : 'dinonaktifkan'}.`);
      if (editing?.id === id) { setEditing(null); setForm(emptyForm()); setErrors({}); }
      await loadRows();
      onDataChanged();
    } catch (error) {
      setLoadError(errorMessage(error, `${definition.codeLabel} gagal diubah.`));
    } finally {
      setPendingRowID(null);
    }
  }

  return <section aria-labelledby={`iso-cedex-tab-${definition.id}`} className='iso-master-section' id={`iso-cedex-${definition.id}`} role='tabpanel'>
    <header className='iso-master-section-heading'>
      <span aria-hidden='true' className='iso-master-section-icon'><Icon size={21} /></span>
      <div><div className='iso-master-title-row'>
        <h2>{definition.title}</h2>
        {definition.subtitle ? <span className='iso-master-subtitle'>{definition.subtitle}</span> : null}
        {sectionReadOnly ? <span className='iso-master-readonly-badge'>Mode baca-saja</span> : null}
      </div><p>{definition.description}</p></div>
    </header>

    {!hasLoaded && isLoading ? <IsoMasterSkeleton showForm={!sectionReadOnly} /> : <>
      {sectionReadOnly ? <div className='iso-master-readonly-summary'>
        <strong>Mode baca-saja</strong><span>Form dan aksi perubahan disembunyikan. Search, filter, riwayat, dan pagination tetap dapat digunakan.</span>
      </div> : <IsoMasterForm
        canCreate={canCreate} canUpdate={canUpdate} codeInputRef={codeInputRef} definition={definition}
        editing={editing} errors={errors} fieldID={fieldID} form={form} formRegionRef={formRegionRef}
        isSubmitting={isSubmitting} onCancel={cancelEdit} onChange={changeForm} onSubmit={submit}
      />}

      <div aria-busy={isLoading} className='iso-master-toolbar'>
        <label className='search-box' htmlFor={`${fieldID}-search`}><Search aria-hidden='true' size={17} /><span className='sr-only'>Cari {definition.title}</span><input id={`${fieldID}-search`} onChange={(event) => setSearchInput(event.target.value)} placeholder='Cari kode atau description' type='search' value={searchInput} /></label>
        <label htmlFor={`${fieldID}-status-filter`}><span className='sr-only'>Filter status {definition.title}</span><select id={`${fieldID}-status-filter`} onChange={(event) => { setPage(1); setStatusFilter(event.target.value as StatusFilter); }} value={statusFilter}><option value=''>Semua</option><option value='active'>Aktif</option><option value='inactive'>Tidak Aktif</option><option value="legacy">Legacy</option></select></label>
        <span aria-live='polite' className='iso-master-total'>{isLoading ? 'Memuat data...' : `${totalRows} data`}</span>
      </div>

      {loadError ? <div className='iso-master-inline-error' role='alert'>
        <div><strong>Daftar {definition.codeLabel} gagal dimuat.</strong><span>{loadError}</span></div>
        <button className='secondary-button' disabled={isLoading} onClick={() => void loadRows()} type='button'>Coba Lagi</button>
      </div> : <MasterList canCreate={canCreate} canDeactivate={canDeactivate} canUpdate={canUpdate} codeInputRef={codeInputRef} definition={definition} isLoading={isLoading} onEdit={beginEdit} onToggleStatus={toggleStatus} pendingRowID={pendingRowID} rows={rows} />}

      {totalPages > 1 ? <nav aria-label={`Pagination ${definition.title}`} className='iso-master-pagination'>
        <button className='secondary-button' disabled={page <= 1 || isLoading} onClick={() => setPage((current) => Math.max(1, current - 1))} type='button'><ChevronLeft size={16} />Sebelumnya</button>
        <span>Halaman {page} dari {totalPages}</span>
        <button className='secondary-button' disabled={page >= totalPages || isLoading} onClick={() => setPage((current) => Math.min(totalPages, current + 1))} type='button'>Berikutnya<ChevronRight size={16} /></button>
      </nav> : null}
    </>}

    {success ? <div aria-atomic='true' aria-live='polite' className='iso-master-toast-region'><ToastFeedback duration={4500} onDismiss={() => setSuccess(null)} title={success} tone='success' /></div> : null}
  </section>;
}

function IsoMasterForm({ canCreate, canUpdate, codeInputRef, definition, editing, errors, fieldID, form, formRegionRef, isSubmitting, onCancel, onChange, onSubmit }: {
  canCreate: boolean; canUpdate: boolean; codeInputRef: RefObject<HTMLInputElement | null>;
  definition: SectionDefinition; editing: MasterRow | null; errors: FormErrors; fieldID: string; form: FormState;
  formRegionRef: RefObject<HTMLDivElement | null>; isSubmitting: boolean; onCancel: () => void;
  onChange: (field: keyof FormState, value: FormState[keyof FormState]) => void;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
}) {
  return <div className='iso-master-form-region' ref={formRegionRef}>
    <div className='iso-master-form-heading'>
      <h3>{editing ? `Edit ${definition.codeLabel}` : `Tambah ${definition.codeLabel}`}</h3>
      <p>{editing ? 'Perbarui data yang dipilih, lalu simpan perubahan.' : 'Isi kode, description, dan status data baru.'}</p>
    </div>
    {editing ? <div className='iso-master-edit-banner' role='status'>
      <Pencil aria-hidden='true' size={16} /><span>Sedang mengedit: <strong>{String(editing.code ?? '-')} - {rowDescription(definition, editing) || 'Tanpa description'}</strong></span>
    </div> : null}
    <form className='iso-master-form' onSubmit={onSubmit} noValidate>
      <label className='field iso-master-code-field' htmlFor={`${fieldID}-code`}>
        <span>{definition.codeLabel} *</span>
        <input aria-describedby={`${fieldID}-code-help${errors.code ? ` ${fieldID}-code-error` : ''}`} aria-invalid={Boolean(errors.code)} autoCapitalize='characters' disabled={isSubmitting || (editing !== null && !canUpdate)} id={`${fieldID}-code`} maxLength={definition.codeLength} onChange={(event) => onChange('code', event.target.value.toUpperCase())} pattern={`[A-Za-z0-9]{${definition.codeLength}}`} placeholder={definition.placeholder} ref={codeInputRef} value={form.code} />
        <small className='muted-text' id={`${fieldID}-code-help`}>{definition.helper}</small>
        {errors.code ? <small className='field-error' id={`${fieldID}-code-error`}>{errors.code}</small> : null}
      </label>
      <label className='field iso-master-description-field' htmlFor={`${fieldID}-description`}>
        <span>Description *</span>
        <textarea aria-describedby={`${fieldID}-description-help${errors.description ? ` ${fieldID}-description-error` : ''}`} aria-invalid={Boolean(errors.description)} disabled={isSubmitting || (editing !== null && !canUpdate)} id={`${fieldID}-description`} onChange={(event) => onChange('description', event.target.value)} placeholder={`Deskripsi ${definition.codeLabel.toLowerCase()}`} rows={2} value={form.description} />
        <small className='muted-text' id={`${fieldID}-description-help`}>Gunakan description singkat yang mudah dikenali Surveyor.</small>
        {errors.description ? <small className='field-error' id={`${fieldID}-description-error`}>{errors.description}</small> : null}
      </label>
      <label className='field iso-master-status-field' htmlFor={`${fieldID}-status`}>
        <span>Status</span><select disabled={isSubmitting || (editing !== null && !canUpdate)} id={`${fieldID}-status`} onChange={(event) => onChange('status', event.target.value as FormState['status'])} value={form.status}><option value='active'>Aktif</option><option value='inactive'>Tidak Aktif</option></select>
      </label>
      <div className='iso-master-form-actions'>
        <button className='primary-button' disabled={isSubmitting || (editing ? !canUpdate : !canCreate)} type='submit'>{isSubmitting ? 'Menyimpan...' : editing ? 'Simpan Perubahan' : 'Simpan'}</button>
        {editing ? <button className='secondary-button' disabled={isSubmitting} onClick={onCancel} type='button'>Batal Edit</button> : null}
      </div>
    </form>
    {errors.form ? <div className='iso-master-form-error' role='alert'><strong>Data gagal disimpan.</strong><span>{errors.form}</span></div> : null}
  </div>;
}

function IsoMasterSkeleton({ showForm }: { showForm: boolean }) {
  return <div aria-busy='true' aria-label='Memuat workspace ISO CEDEX' className='iso-master-skeleton'>
    {showForm ? <div className='iso-master-skeleton-form'><div className='skeleton-line' /><div className='skeleton-line' /><div className='skeleton-line' /><div className='skeleton-line' /></div> : null}
    <div className='iso-master-skeleton-toolbar'><div className='skeleton-line' /><div className='skeleton-line' /><div className='skeleton-line' /></div>
    <div className='iso-master-skeleton-table'>{Array.from({ length: 5 }, (_, index) => <div className='skeleton-line' key={index} />)}</div>
    <span className='sr-only'>Memuat form, toolbar, dan daftar data.</span>
  </div>;
}

function MasterList({ definition, rows, isLoading, canCreate, canUpdate, canDeactivate, pendingRowID, codeInputRef, onEdit, onToggleStatus }: {
  definition: SectionDefinition; rows: MasterRow[]; isLoading: boolean; canCreate: boolean; canUpdate: boolean; canDeactivate: boolean;
  pendingRowID: string | null; codeInputRef: RefObject<HTMLInputElement | null>;
  onEdit: (row: MasterRow) => void; onToggleStatus: (row: MasterRow, status: 'active' | 'inactive') => void;
}) {
  if (rows.length === 0) return <div className='iso-master-empty'>
    <span aria-hidden='true' className='iso-master-empty-icon'><Plus size={20} /></span>
    <strong>Belum ada {definition.codeLabel}</strong><p>{definition.emptyDescription}</p>
    {canCreate ? <button className='secondary-button' onClick={() => codeInputRef.current?.focus()} type='button'>Fokus ke Form Input</button> : null}
  </div>;

  return <div aria-busy={isLoading} className='iso-master-list'>
    <div className='iso-master-table-wrap'><table aria-label={`Daftar ${definition.title}`} className='iso-master-table'>
      <thead><tr><th scope='col'>Code</th><th scope='col'>Description</th><th scope='col'>Status</th><th scope='col'>Updated At</th><th scope='col'>Action</th></tr></thead>
      <tbody>{rows.map((row) => {
        const id = String(row.id ?? `${definition.id}-${String(row.code ?? '')}`);
        const inactive = isInactive(row); const mutable = rowCanMutate(definition, row); const pending = pendingRowID === id;
        return <tr key={id}>
          <td><strong className='iso-master-code'>{String(row.code ?? '-')}</strong>{isLegacy(row) ? <StatusBadge tone='neutral'>Legacy</StatusBadge> : null}</td>
          <td>{rowDescription(definition, row) || '-'}</td>
          <td><StatusBadge tone={inactive ? 'neutral' : 'success'}>{inactive ? 'Tidak Aktif' : 'Aktif'}</StatusBadge></td>
          <td>{formatDateTime(row.updated_at)}</td>
          <td><div className='iso-master-row-actions'>
            {canUpdate && mutable ? <button className='text-button' disabled={pending} onClick={() => onEdit(row)} type='button'>Edit</button> : null}
            {inactive && canUpdate && mutable ? <button className='text-button' disabled={pending} onClick={() => onToggleStatus(row, 'active')} type='button'><RotateCcw size={14} />Aktifkan</button> : null}
            {!inactive && canDeactivate && mutable ? <button className='text-button danger-action' disabled={pending} onClick={() => onToggleStatus(row, 'inactive')} type='button'>Nonaktifkan</button> : null}
            <Link className='text-button' href={`/settings/audit-log?search=${encodeURIComponent(String(row.id ?? row.code ?? ''))}`}><History size={14} />Riwayat</Link>
            {!mutable ? <span className='muted-text'>Read-only</span> : null}
          </div></td>
        </tr>;
      })}</tbody>
    </table></div>
    <MobileMasterList canDeactivate={canDeactivate} canUpdate={canUpdate} definition={definition} onEdit={onEdit} onToggleStatus={onToggleStatus} pendingRowID={pendingRowID} rows={rows} />
  </div>;
}

function MobileMasterList({ definition, rows, canUpdate, canDeactivate, pendingRowID, onEdit, onToggleStatus }: {
  definition: SectionDefinition; rows: MasterRow[]; canUpdate: boolean; canDeactivate: boolean; pendingRowID: string | null;
  onEdit: (row: MasterRow) => void; onToggleStatus: (row: MasterRow, status: 'active' | 'inactive') => void;
}) {
  return <div className='iso-master-mobile-list'>{rows.map((row) => {
    const id = String(row.id ?? `${definition.id}-${String(row.code ?? '')}`);
    const inactive = isInactive(row); const mutable = rowCanMutate(definition, row); const pending = pendingRowID === id;
    return <article aria-label={`${definition.codeLabel} ${String(row.code ?? '')}`} className='iso-master-mobile-card' key={id}>
      <header><div><strong className='iso-master-code'>{String(row.code ?? '-')}</strong>{isLegacy(row) ? <StatusBadge tone='neutral'>Legacy</StatusBadge> : null}</div><h3>{rowDescription(definition, row) || 'Tanpa description'}</h3></header>
      <dl><div><dt>Status</dt><dd><StatusBadge tone={inactive ? 'neutral' : 'success'}>{inactive ? 'Tidak Aktif' : 'Aktif'}</StatusBadge></dd></div><div><dt>Diperbarui</dt><dd>{formatDateTime(row.updated_at)}</dd></div></dl>
      <footer>
        {canUpdate && mutable ? <button className='secondary-button' disabled={pending} onClick={() => onEdit(row)} type='button'><Pencil size={15} />Edit</button> : null}
        <details className='iso-master-overflow-menu'>
          <summary aria-label={`Aksi lainnya untuk ${String(row.code ?? 'data')}`} className='icon-button' title='Aksi lainnya'><MoreHorizontal size={18} /></summary>
          <div>
            {inactive && canUpdate && mutable ? <button disabled={pending} onClick={() => onToggleStatus(row, 'active')} type='button'><RotateCcw size={15} />Aktifkan</button> : null}
            {!inactive && canDeactivate && mutable ? <button className='danger-action' disabled={pending} onClick={() => onToggleStatus(row, 'inactive')} type='button'>Nonaktifkan</button> : null}
            <Link href={`/settings/audit-log?search=${encodeURIComponent(String(row.id ?? row.code ?? ''))}`}><History size={15} />Riwayat</Link>
          </div>
        </details>
        {!mutable ? <span className='muted-text'>Data legacy baca-saja</span> : null}
      </footer>
    </article>;
  })}</div>;
}

function emptyForm(): FormState { return { code: '', description: '', status: 'active' }; }

function validateForm(definition: SectionDefinition, form: FormState): FormErrors {
  const errors: FormErrors = {};
  if (!new RegExp(`^[A-Z0-9]{${definition.codeLength}}$`).test(form.code.trim())) errors.code = `${definition.codeLabel} wajib terdiri dari tepat ${definition.codeLength} karakter huruf atau angka.`;
  if (!form.description.trim()) errors.description = 'Description wajib diisi.';
  return errors;
}

function compatibilityPayload(definition: SectionDefinition, form: FormState, create: boolean): MasterRow {
  const payload: MasterRow = { code: form.code, description: form.description, status: form.status };
  if (create) payload.source_type = "standard_global";
  if (definition.id === 'location') {
    payload.input_mode = 'manual'; payload.face = locationFace(form.code); payload.grid_code = form.code;
  } else {
    payload[definition.nameField] = form.description;
    if (definition.id === 'damage' && create) payload.default_severity = 'minor';
  }
  return payload;
}

function locationFace(code: string) {
  const faces: Record<string, string> = { D: 'door', L: 'left', R: 'right', F: 'front', U: 'understructure', T: 'roof', B: 'floor' };
  return faces[code.slice(0, 1).toUpperCase()] ?? 'other';
}
function rowDescription(definition: SectionDefinition, row: MasterRow) { return String(row.description ?? row[definition.nameField] ?? ''); }
function rowCanMutate(definition: SectionDefinition, row: MasterRow) {
  if (!isLegacy(row)) return true;
  return new RegExp(`^[A-Za-z0-9]{${definition.codeLength}}$`).test(String(row.code ?? ''));
}
function isLegacy(row: MasterRow) { return String(row.source_type ?? 'legacy') === 'legacy'; }
function isInactive(row: MasterRow) { return String(row.status ?? '').toLowerCase() === 'inactive'; }
function formatDateTime(value: MasterRow[string]) {
  if (!value) return '-';
  const date = new Date(String(value));
  if (Number.isNaN(date.getTime())) return String(value);
  return new Intl.DateTimeFormat('id-ID', { dateStyle: 'medium', timeStyle: 'short' }).format(date);
}
function errorMessage(error: unknown, fallback: string) { return error instanceof Error && error.message ? error.message : fallback; }
function isIsoCedexTab(value: string | null): value is IsoCedexTab { return value !== null && sections.some((section) => section.id === value); }
