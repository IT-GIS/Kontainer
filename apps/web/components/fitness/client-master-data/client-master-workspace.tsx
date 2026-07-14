"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { Activity, ClipboardCheck, Container, Database, MapPin, Pencil, Plus, UsersRound } from "lucide-react";
import { ActivityTimeline } from "@/components/ui/activity-timeline";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";
import { Drawer } from "@/components/ui/drawer";
import { EmptyState } from "@/components/ui/empty-state";
import { FilterBar, type FilterBarField } from "@/components/ui/filter-bar";
import { FormField } from "@/components/ui/form-field";
import { FormSection } from "@/components/ui/form-section";
import { MetricCard } from "@/components/ui/metric-card";
import { PageHeader } from "@/components/ui/page-header";
import { PageTabs } from "@/components/ui/page-tabs";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { StatusBadge } from "@/components/ui/status-badge";
import { ToastFeedback } from "@/components/ui/toast-feedback";
import { UnsavedChangesGuard } from "@/components/ui/unsaved-changes-guard";
import type {
  FitnessClientContainerType,
  FitnessClientDetail,
  FitnessClientInspectionReference,
  FitnessClientLocation,
  FitnessClientMasterSummary,
  FitnessClientPersonnel,
  FitnessInspectionReferenceSection,
  FitnessLegacyMappingRecord,
  FitnessLegacyMappingSection,
  PageTabItem
} from "@/types/fitness-admin";
import { ClientWorkspaceTabs } from "./client-pages";

export type ClientMasterTab = "summary" | "locations" | "personnel" | "container-types" | "inspection-references" | "legacy-mapping";
export type ClientMasterSection = FitnessInspectionReferenceSection | FitnessLegacyMappingSection;

type EditableRecord = FitnessClientLocation | FitnessClientPersonnel | FitnessClientContainerType | FitnessClientInspectionReference;

type ClientMasterWorkspaceProps = {
  client: FitnessClientDetail;
  summary: FitnessClientMasterSummary;
  locations: FitnessClientLocation[];
  personnel: FitnessClientPersonnel[];
  containerTypes: FitnessClientContainerType[];
  references: FitnessClientInspectionReference[];
  legacyMappings: FitnessLegacyMappingRecord[];
  activeTab: ClientMasterTab;
  activeSection: ClientMasterSection;
};

const referenceSections: Array<{ id: FitnessInspectionReferenceSection; label: string }> = [
  { id: "inspection-areas", label: "Area Pemeriksaan" },
  { id: "structural-components", label: "Komponen Struktur Peti Kemas" },
  { id: "damage-criteria", label: "Kriteria Kerusakan/Ketidaksesuaian" },
  { id: "finding-severities", label: "Tingkat Keparahan" },
  { id: "test-parameters", label: "Parameter Pengujian" },
  { id: "photo-categories", label: "Kategori Bukti Foto" },
  { id: "inspection-recommendations", label: "Rekomendasi Pemeriksaan" }
];

const legacySections: Array<{ id: FitnessLegacyMappingSection; label: string }> = [
  { id: "location", label: "Location" },
  { id: "component", label: "Component" },
  { id: "damage", label: "Damage" },
  { id: "material", label: "Material" }
];

export function FitnessClientMasterWorkspace(props: ClientMasterWorkspaceProps) {
  const { client, summary, activeTab, activeSection } = props;
  const base = "/fitness/client-master-data/" + client.id;
  const tabs: PageTabItem[] = [
    { id: "summary", label: "Ringkasan", href: base + "?tab=summary" },
    { id: "locations", label: "Lokasi", href: base + "?tab=locations", count: client.locationCount },
    { id: "personnel", label: "Personel/PIC Klien", href: base + "?tab=personnel", count: client.personnelCount },
    { id: "container-types", label: "Jenis Peti Kemas", href: base + "?tab=container-types", count: client.containerTypeCount },
    { id: "inspection-references", label: "Referensi Pemeriksaan", href: base + "?tab=inspection-references&section=inspection-areas", count: client.referenceCount },
    { id: "legacy-mapping", label: "Mapping Legacy", href: base + "?tab=legacy-mapping&section=location", count: summary.legacyMappingCount }
  ];

  return (
    <div className="page-stack">
      <ClientWorkspaceTabs activeHref="/fitness/client-master-data" />
      <PageHeader
        eyebrow="Master Data Klien"
        title={client.name}
        description="Seluruh data pada halaman ini dimuat menggunakan clientId dari route."
        meta={<span className="client-header-meta"><strong>{client.code}</strong><StatusBadge tone={client.status === "Aktif" ? "success" : "neutral"}>{client.status}</StatusBadge><span>PIC: {client.primaryContactName}</span><span>Diperbarui: {client.updatedAt}</span></span>}
      />
      <div className="client-context-strip" role="status" aria-label={"Klien aktif " + client.name}>
        <Database size={18} />
        <span><strong>Klien aktif:</strong> {client.name}</span>
        <span><strong>Kode:</strong> {client.code}</span>
        <span><strong>Status:</strong> {client.status}</span>
      </div>
      <PageTabs tabs={tabs} activeHref={mainActiveHref(base, activeTab)} />
      {activeTab === "summary" ? <SummaryTab client={client} summary={summary} /> : null}
      {activeTab === "locations" ? <EditableTab client={client} kind="locations" initialRows={props.locations} /> : null}
      {activeTab === "personnel" ? <EditableTab client={client} kind="personnel" initialRows={props.personnel} /> : null}
      {activeTab === "container-types" ? <EditableTab client={client} kind="container-types" initialRows={props.containerTypes} /> : null}
      {activeTab === "inspection-references" ? (
        <ReferenceTab client={client} activeSection={activeSection as FitnessInspectionReferenceSection} rows={props.references} />
      ) : null}
      {activeTab === "legacy-mapping" ? (
        <LegacyMappingTab client={client} activeSection={activeSection as FitnessLegacyMappingSection} rows={props.legacyMappings} />
      ) : null}
    </div>
  );
}

function SummaryTab({ client, summary }: { client: FitnessClientDetail; summary: FitnessClientMasterSummary }) {
  const base = "/fitness/client-master-data/" + client.id;
  return (
    <>
      <section className="ui-metric-grid">
        <MetricCard label="Lokasi Aktif" value={summary.activeLocationCount} description="Lokasi milik atau digunakan klien." icon={MapPin} tone="info" />
        <MetricCard label="Personel/PIC Aktif" value={summary.activePersonnelCount} description="Personel pihak klien, bukan Surveyor GIFT." icon={UsersRound} tone="success" />
        <MetricCard label="Jenis Peti Kemas" value={summary.containerTypeCount} description="Referensi jenis khusus klien." icon={Container} tone="neutral" />
        <MetricCard label="Referensi Pemeriksaan" value={summary.inspectionReferenceCount} description="Referensi aktif tanpa checklist seed." icon={ClipboardCheck} tone="info" />
        <MetricCard label="Mapping Legacy" value={summary.legacyMappingCount} description="Read-only untuk pembacaan data lama." icon={Database} tone="warning" />
        <MetricCard label="Kelengkapan" value={summary.completeness} description={"Pembaruan terakhir " + summary.updatedAt} icon={Activity} tone={summary.completeness === "Lengkap" ? "success" : "warning"} />
      </section>
      <section className="workspace-panel">
        <div className="fitness-section-header"><div><h2>Aksi Master Data</h2><p>Setiap aksi mempertahankan clientId {client.code}.</p></div></div>
        <div className="client-summary-actions">
          <Link className="secondary-button" href={base + "?tab=locations"}>Tambah Lokasi</Link>
          <Link className="secondary-button" href={base + "?tab=personnel"}>Tambah Personel</Link>
          <Link className="secondary-button" href={base + "?tab=container-types"}>Tambah Jenis Peti Kemas</Link>
          <Link className="secondary-button" href={base + "?tab=inspection-references&section=inspection-areas"}>Kelola Referensi</Link>
        </div>
      </section>
      <section className="workspace-panel">
        <div className="fitness-section-header"><div><h2>Aktivitas Terbaru</h2><p>Aktivitas mock untuk konteks klien aktif.</p></div></div>
        <ActivityTimeline items={summary.activities} />
      </section>
    </>
  );
}

function EditableTab({ client, kind, initialRows, referenceSection }: { client: FitnessClientDetail; kind: "locations" | "personnel" | "container-types" | "references"; initialRows: EditableRecord[]; referenceSection?: FitnessInspectionReferenceSection }) {
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<EditableRecord | null>(null);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [pendingDeactivate, setPendingDeactivate] = useState<EditableRecord | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const [dirty, setDirty] = useState(false);
  const [draft, setDraft] = useState({ code: "", name: "", detail: "", contact: "", status: "Aktif" });
  const config = editableConfig(kind);
  const keyword = (filters.keyword ?? "").toLowerCase();
  const visibleRows = rows.filter((row) => {
    const searchable = recordCode(row) + " " + recordName(row) + " " + recordDetail(row);
    return (!keyword || searchable.toLowerCase().includes(keyword)) && (!filters.status || row.status === filters.status);
  });

  const fields: FilterBarField[] = [
    { id: "keyword", label: "Cari", type: "search", value: filters.keyword ?? "", placeholder: config.searchPlaceholder },
    { id: "status", label: "Status", type: "select", value: filters.status ?? "", placeholder: "Semua status", options: [{ value: "Aktif", label: "Aktif" }, { value: "Tidak Aktif", label: "Tidak Aktif" }] }
  ];

  const columns: ResponsiveColumn<EditableRecord>[] = [
    { key: "code", header: config.codeLabel, render: (row) => <strong>{recordCode(row) || "-"}</strong> },
    { key: "name", header: config.nameLabel, render: (row) => recordName(row) },
    { key: "detail", header: config.detailLabel, render: (row) => recordDetail(row) },
    { key: "contact", header: config.contactLabel, render: (row) => recordContact(row) },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: (row) => row.updatedAt },
    {
      key: "actions",
      header: "Aksi",
      render: (row) => <div className="client-row-actions"><button className="icon-button" aria-label={"Edit " + recordName(row)} onClick={() => openEditor(row)} type="button"><Pencil size={16} /></button><button className="secondary-button client-inline-action" disabled={row.status !== "Aktif"} onClick={() => setPendingDeactivate(row)} type="button">Nonaktifkan</button></div>
    }
  ];

  function openEditor(row?: EditableRecord) {
    setEditing(row ?? null);
    setDraft(row ? { code: recordCode(row), name: recordName(row), detail: recordDetail(row), contact: recordContact(row), status: row.status } : { code: "", name: "", detail: "", contact: "", status: "Aktif" });
    setDirty(false);
    setDrawerOpen(true);
  }

  function change(field: keyof typeof draft, value: string) {
    setDraft((current) => ({ ...current, [field]: value }));
    setDirty(true);
  }

  function save() {
    if (!draft.name.trim() || (kind !== "personnel" && !draft.code.trim())) return;
    if (editing) {
      setRows((current) => current.map((row) => row.id === editing.id ? updateRecord(row, draft) : row));
    } else {
      setRows((current) => [...current, createRecord(kind, client.id, draft, referenceSection)]);
    }
    setDirty(false);
    setDrawerOpen(false);
    setToast((editing ? "Perubahan " : "Data baru ") + "tersimpan pada state lokal " + client.code + ".");
  }

  function deactivate() {
    if (!pendingDeactivate) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setToast(recordName(pendingDeactivate) + " dinonaktifkan pada state lokal.");
    setPendingDeactivate(null);
  }

  return (
    <>
      <section className="workspace-panel">
        <PageHeader title={config.title} description={config.description} action={{ label: config.addLabel, icon: Plus, onClick: () => openEditor() }} />
        <FilterBar fields={fields} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} onSubmit={() => undefined} />
        {visibleRows.length ? <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={recordName} /> : <EmptyState title={"Belum ada " + config.title.toLowerCase()} description="Tambah data lokal atau reset filter." />}
      </section>
      <Drawer
        open={drawerOpen}
        title={(editing ? "Edit " : "Tambah ") + config.singular}
        description={"Konteks klien dikunci ke " + client.name + " (" + client.code + ")."}
        preventClose={false}
        onClose={() => setDrawerOpen(false)}
        footer={<div className="client-drawer-actions"><button className="secondary-button" onClick={() => setDrawerOpen(false)} type="button">Batal</button><button className="primary-button" disabled={!draft.name.trim() || (kind !== "personnel" && !draft.code.trim())} onClick={save} type="button">Simpan lokal</button></div>}
      >
        <div className="client-context-field"><span>Klien</span><strong>{client.name}</strong><small>clientId: {client.id} — tidak dapat diubah</small></div>
        <FormSection title={config.singular} description="Data hanya berlaku untuk klien aktif.">
          {kind !== "personnel" ? <EditorField id="record-code" label={config.codeLabel} value={draft.code} onChange={(value) => change("code", value)} required /> : null}
          <EditorField id="record-name" label={config.nameLabel} value={draft.name} onChange={(value) => change("name", value)} required />
          <EditorField id="record-detail" label={config.detailLabel} value={draft.detail} onChange={(value) => change("detail", value)} />
          <EditorField id="record-contact" label={config.contactLabel} value={draft.contact} onChange={(value) => change("contact", value)} />
          <FormField id="record-status" label="Status"><select id="record-status" value={draft.status} onChange={(event) => change("status", event.target.value)}><option>Aktif</option><option>Tidak Aktif</option></select></FormField>
        </FormSection>
      </Drawer>
      <UnsavedChangesGuard active={drawerOpen && dirty} message={"Perubahan " + config.singular + " belum disimpan."} />
      <ConfirmationDialog open={Boolean(pendingDeactivate)} title={"Nonaktifkan " + config.singular + "?"} description="Perubahan hanya berlaku pada state lokal UI-B.2." confirmLabel="Nonaktifkan" tone="danger" onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
      {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
    </>
  );
}

function ReferenceTab({ client, activeSection, rows }: { client: FitnessClientDetail; activeSection: FitnessInspectionReferenceSection; rows: FitnessClientInspectionReference[] }) {
  const base = "/fitness/client-master-data/" + client.id + "?tab=inspection-references&section=";
  const tabs = referenceSections.map((section) => ({ id: section.id, label: section.label, href: base + section.id }));
  return (
    <section className="workspace-panel">
      <PageTabs tabs={tabs} activeHref={base + activeSection} />
      <div className="client-reference-note"><ClipboardCheck size={18} /><span>Referensi aktif khusus {client.code}. Tidak ada checklist seed, nilai batas, keputusan otomatis, atau referensi regulasi yang dibuat pada tahap ini.</span></div>
      <EditableTab client={client} kind="references" initialRows={rows} referenceSection={activeSection} />
    </section>
  );
}

function LegacyMappingTab({ client, activeSection, rows }: { client: FitnessClientDetail; activeSection: FitnessLegacyMappingSection; rows: FitnessLegacyMappingRecord[] }) {
  const [keyword, setKeyword] = useState("");
  const base = "/fitness/client-master-data/" + client.id + "?tab=legacy-mapping&section=";
  const tabs = legacySections.map((section) => ({ id: section.id, label: section.label, href: base + section.id }));
  const visible = rows.filter((row) => (row.legacyCode + " " + row.legacyName + " " + (row.mappedTarget ?? "")).toLowerCase().includes(keyword.toLowerCase()));
  const columns: ResponsiveColumn<FitnessLegacyMappingRecord>[] = [
    { key: "code", header: "Kode Lama", render: (row) => <strong>{row.legacyCode}</strong> },
    { key: "name", header: "Nama Lama", render: (row) => row.legacyName },
    { key: "target", header: "Target Mapping Aktif", render: (row) => row.mappedTarget ?? "Belum tersedia" },
    { key: "status", header: "Status Mapping", render: (row) => <StatusBadge tone={row.mappingStatus === "Terpetakan" ? "success" : "warning"}>{row.mappingStatus}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: (row) => row.updatedAt }
  ];
  return (
    <section className="workspace-panel">
      <PageHeader title="Mapping Legacy" description="Referensi lama hanya dibaca dan difilter berdasarkan clientId. Tidak tersedia aksi CRUD." meta={<StatusBadge tone="warning">Read-only</StatusBadge>} />
      <PageTabs tabs={tabs} activeHref={base + activeSection} />
      <FilterBar fields={[{ id: "keyword", label: "Cari data lama", type: "search", value: keyword, placeholder: "Kode, nama, atau target mapping" }]} onChange={(_, value) => setKeyword(value)} onReset={() => setKeyword("")} onSubmit={() => undefined} />
      {visible.length ? <ResponsiveTableCards columns={columns} rows={visible} getRowId={(row) => row.id} getRowTitle={(row) => row.legacyName} /> : <EmptyState title="Mapping tidak ditemukan" description="Reset pencarian untuk melihat mapping klien ini." />}
    </section>
  );
}

function EditorField({ id, label, value, onChange, required }: { id: string; label: string; value: string; onChange: (value: string) => void; required?: boolean }) {
  return <FormField id={id} label={label} required={required}><input id={id} value={value} onChange={(event) => onChange(event.target.value)} required={required} /></FormField>;
}

function recordCode(row: EditableRecord) {
  if ("code" in row) return row.code;
  return "";
}

function recordName(row: EditableRecord) {
  return row.name;
}

function recordDetail(row: EditableRecord) {
  if ("type" in row && "city" in row) return row.type + " — " + row.city + ", " + row.province;
  if ("title" in row) return row.title + " — " + row.type;
  if ("size" in row) return row.size + " — " + row.description;
  return row.description;
}

function recordContact(row: EditableRecord) {
  if ("contactName" in row) return row.contactName + " — " + row.phone;
  if ("locationNames" in row) return row.email + " — " + row.locationNames.join(", ");
  if ("section" in row) return referenceSections.find((item) => item.id === row.section)?.label ?? row.section;
  return "-";
}

function updateRecord(row: EditableRecord, draft: { code: string; name: string; detail: string; contact: string; status: string }): EditableRecord {
  const status = draft.status as "Aktif" | "Tidak Aktif";
  if ("city" in row) return { ...row, code: draft.code, name: draft.name, address: draft.detail, contactName: draft.contact, status };
  if ("title" in row) return { ...row, name: draft.name, title: draft.detail, email: draft.contact, status };
  if ("size" in row) return { ...row, code: draft.code, name: draft.name, size: draft.detail, description: draft.contact, status };
  return { ...row, code: draft.code, name: draft.name, description: draft.detail, status };
}

function createRecord(kind: "locations" | "personnel" | "container-types" | "references", clientId: string, draft: { code: string; name: string; detail: string; contact: string; status: string }, referenceSection?: FitnessInspectionReferenceSection): EditableRecord {
  const common = { id: clientId + "-local-" + Date.now(), clientId, status: draft.status as "Aktif" | "Tidak Aktif", updatedAt: "State lokal" };
  if (kind === "locations") return { ...common, code: draft.code, name: draft.name, type: "Lokasi Pemeriksaan", address: draft.detail, city: "-", province: "-", postalCode: "-", contactName: draft.contact, phone: "-", email: "-", accessNotes: "State lokal" };
  if (kind === "personnel") return { ...common, name: draft.name, title: draft.detail, type: "PIC Lokasi", locationIds: [], locationNames: [], email: draft.contact, phone: "-" };
  if (kind === "references") return { ...common, section: referenceSection ?? "inspection-areas", code: draft.code, name: draft.name, description: draft.detail, relatedTo: draft.contact };
  return { ...common, code: draft.code, name: draft.name, size: draft.detail, description: draft.contact };
}

function editableConfig(kind: "locations" | "personnel" | "container-types" | "references") {
  if (kind === "locations") return { title: "Lokasi Klien", singular: "Lokasi", description: "Lokasi yang dimiliki atau digunakan klien untuk proses inspeksi.", addLabel: "Tambah Lokasi", codeLabel: "Kode Lokasi", nameLabel: "Nama Lokasi", detailLabel: "Jenis dan Wilayah", contactLabel: "PIC dan Telepon", searchPlaceholder: "Kode atau nama lokasi" };
  if (kind === "personnel") return { title: "Personel/PIC Klien", singular: "Personel/PIC Klien", description: "Personel pihak klien. Surveyor GIFT tidak berada pada daftar ini.", addLabel: "Tambah Personel", codeLabel: "Kode", nameLabel: "Nama", detailLabel: "Jabatan dan Tipe", contactLabel: "Kontak dan Lokasi", searchPlaceholder: "Nama atau jabatan" };
  if (kind === "references") return { title: "Referensi Pemeriksaan", singular: "Referensi Pemeriksaan", description: "Referensi presentasi yang terisolasi per klien.", addLabel: "Tambah Referensi", codeLabel: "Kode", nameLabel: "Nama Referensi", detailLabel: "Deskripsi", contactLabel: "Relasi/Keterangan", searchPlaceholder: "Kode atau nama referensi" };
  return { title: "Jenis Peti Kemas Klien", singular: "Jenis Peti Kemas", description: "Referensi jenis peti kemas yang hanya tersedia untuk klien aktif.", addLabel: "Tambah Jenis", codeLabel: "Kode", nameLabel: "Nama Jenis", detailLabel: "Ukuran dan Deskripsi", contactLabel: "Keterangan", searchPlaceholder: "Kode atau nama jenis" };
}

function mainActiveHref(base: string, tab: ClientMasterTab) {
  if (tab === "inspection-references") return base + "?tab=inspection-references&section=inspection-areas";
  if (tab === "legacy-mapping") return base + "?tab=legacy-mapping&section=location";
  return base + "?tab=" + tab;
}
