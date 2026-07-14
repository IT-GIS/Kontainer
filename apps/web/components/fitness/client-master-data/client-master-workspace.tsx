"use client";

import Link from "next/link";
import { useState } from "react";
import { Activity, ArrowLeft, ClipboardCheck, Container, Database, MapPin, Pencil, Plus, UsersRound } from "lucide-react";
import { fitnessMasterDataCategoryHref, getFitnessMasterDataCategoryConfigByID } from "@/constants/fitness-master-data-client-first";
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
  FitnessClientContainerType, FitnessClientDetail, FitnessClientInspectionReference,
  FitnessClientLocation, FitnessClientLocationType, FitnessClientMasterDataRecord,
  FitnessClientMasterDataReference, FitnessClientMasterSummary,
  FitnessClientPersonnel, FitnessClientPersonnelType, FitnessClientReferenceCategory,
  FitnessClientStatus, FitnessClientSurveyor,
  FitnessInspectionReferenceSection, FitnessLegacyMappingRecord,
  FitnessLegacyMappingSection, FitnessMasterDataCategory, PageTabItem
} from "@/types/fitness-admin";
import { ClientWorkspaceTabs } from "./client-pages";

export type ClientMasterTab = "summary" | "locations" | "personnel" | "container-types" | "inspection-references" | "legacy-mapping";
export type ClientMasterSection = FitnessInspectionReferenceSection | FitnessLegacyMappingSection;

type Props = {
  client: FitnessClientDetail; summary: FitnessClientMasterSummary;
  locations: FitnessClientLocation[]; personnel: FitnessClientPersonnel[];
  containerTypes: FitnessClientContainerType[]; references: FitnessClientInspectionReference[];
  legacyMappings: FitnessLegacyMappingRecord[]; activeTab: ClientMasterTab; activeSection: ClientMasterSection;
};

const statuses: FitnessClientStatus[] = ["Aktif", "Tidak Aktif"];
const locationTypes: FitnessClientLocationType[] = ["Depo", "Gudang", "Terminal", "Pelabuhan", "Lokasi Pemeriksaan", "Lokasi Perbaikan Eksternal", "Lainnya"];
const personnelTypes: FitnessClientPersonnelType[] = ["PIC Utama", "PIC Lokasi", "Penanggung Jawab Peti Kemas", "Personel Teknis", "Pendamping Pemeriksaan", "Surveyor Internal Klien"];
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
  { id: "location", label: "Location" }, { id: "component", label: "Component" },
  { id: "damage", label: "Damage" }, { id: "material", label: "Material" }
];

export function FitnessClientMasterWorkspace(props: Props) {
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
      <PageHeader eyebrow="Master Data Klien" title={client.name} description="Seluruh data pada halaman ini dimuat menggunakan clientId dari route."
        meta={<span className="client-header-meta"><strong>{client.code}</strong><StatusBadge tone={client.status === "Aktif" ? "success" : "neutral"}>{client.status}</StatusBadge><span>PIC: {client.primaryContactName}</span><span>Diperbarui: {client.updatedAt}</span></span>} />
      <div className="client-context-strip" role="status" aria-label={"Klien aktif " + client.name}>
        <Database size={18} /><span><strong>Klien aktif:</strong> {client.name}</span><span><strong>Kode:</strong> {client.code}</span><span><strong>Status:</strong> {client.status}</span>
      </div>
      <PageTabs tabs={tabs} activeHref={mainActiveHref(base, activeTab)} />
      {activeTab === "summary" ? <SummaryTab client={client} summary={summary} /> : null}
      {activeTab === "locations" ? <LocationTab client={client} initialRows={props.locations} /> : null}
      {activeTab === "personnel" ? <PersonnelTab client={client} initialRows={props.personnel} locations={props.locations} /> : null}
      {activeTab === "container-types" ? <ContainerTypeTab client={client} initialRows={props.containerTypes} /> : null}
      {activeTab === "inspection-references" ? <ReferenceTab client={client} activeSection={activeSection as FitnessInspectionReferenceSection} initialRows={props.references} /> : null}
      {activeTab === "legacy-mapping" ? <LegacyMappingTab client={client} activeSection={activeSection as FitnessLegacyMappingSection} rows={props.legacyMappings} /> : null}
    </div>
  );
}

export function FitnessClientMasterCategoryWorkspace({
  client,
  category,
  records,
  locations
}: {
  client: FitnessClientDetail;
  category: Exclude<FitnessMasterDataCategory, "customer">;
  records: FitnessClientMasterDataRecord[];
  locations: FitnessClientLocation[];
}) {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  const pickerHref = fitnessMasterDataCategoryHref(category);
  return (
    <div className="page-stack master-data-category-workspace">
      <PageHeader
        eyebrow={config.label}
        title={client.name}
        description={config.description}
        meta={
          <span className="client-header-meta">
            <strong>{client.code}</strong>
            <StatusBadge tone={client.status === "Aktif" ? "success" : "neutral"}>{client.status}</StatusBadge>
            <span>PIC: {client.primaryContactName}</span>
            <span>{records.length} data</span>
            <span>Diperbarui: {client.updatedAt}</span>
          </span>
        }
        secondaryAction={{ label: "Daftar Customer", icon: ArrowLeft, href: pickerHref }}
      />
      <div className="client-context-strip" role="status" aria-label={`Customer aktif ${client.name}`}>
        <Database size={18} />
        <span><strong>Customer aktif:</strong> {client.name}</span>
        <span><strong>Kode:</strong> {client.code}</span>
        <span><strong>clientId:</strong> {client.id}</span>
      </div>
      {config.notice ? <div className="client-reference-note"><ClipboardCheck size={18} /><span>{config.notice}</span></div> : null}
      {category === "location" ? <LocationTab client={client} initialRows={records as FitnessClientLocation[]} /> : null}
      {category === "surveyor" ? <CustomerSurveyorTab client={client} initialRows={records as FitnessClientSurveyor[]} locations={locations} /> : null}
      {category === "container-type" ? <ContainerTypeTab client={client} initialRows={records as FitnessClientContainerType[]} /> : null}
      {category !== "location" && category !== "surveyor" && category !== "container-type" ? (
        <MasterDataReferenceTab client={client} category={category as FitnessClientReferenceCategory} initialRows={records as FitnessClientMasterDataReference[]} />
      ) : null}
    </div>
  );
}

function SummaryTab({ client, summary }: { client: FitnessClientDetail; summary: FitnessClientMasterSummary }) {
  const base = "/fitness/client-master-data/" + client.id;
  return <>
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
    <section className="workspace-panel"><div className="fitness-section-header"><div><h2>Aktivitas Terbaru</h2><p>Aktivitas mock untuk konteks klien aktif.</p></div></div><ActivityTimeline items={summary.activities} /></section>
  </>;
}

function useDirtyDrawer() {
  const [open, setOpen] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [discardOpen, setDiscardOpen] = useState(false);
  return {
    open, dirty, discardOpen,
    begin: () => { setDirty(false); setDiscardOpen(false); setOpen(true); },
    requestClose: () => { if (dirty) setDiscardOpen(true); else setOpen(false); },
    confirmDiscard: () => { setDirty(false); setDiscardOpen(false); setOpen(false); },
    finish: () => { setDirty(false); setDiscardOpen(false); setOpen(false); },
    markDirty: () => setDirty(true), cancelDiscard: () => setDiscardOpen(false)
  };
}
type DrawerController = ReturnType<typeof useDirtyDrawer>;

function MasterDataDrawer({ client, controller, title, description, valid, onSave, children }: {
  client: FitnessClientDetail; controller: DrawerController; title: string; description: string;
  valid: boolean; onSave: () => void; children: React.ReactNode;
}) {
  return <>
    <Drawer open={controller.open} title={title} description={description} onClose={controller.requestClose}
      footer={<div className="client-drawer-actions"><button className="secondary-button" onClick={controller.requestClose} type="button">Batal</button><button className="primary-button" disabled={!valid} onClick={onSave} type="button">Simpan lokal</button></div>}>
      <div className="client-context-field"><span>Klien</span><strong>{client.name}</strong><small>clientId: {client.id} — tidak dapat diubah</small></div>{children}
    </Drawer>
    <UnsavedChangesGuard active={controller.open && controller.dirty} message={"Perubahan " + title.toLowerCase() + " belum disimpan."} />
    <ConfirmationDialog open={controller.discardOpen} title="Buang perubahan?" description="Perubahan pada form belum disimpan. Drawer tetap terbuka jika tindakan ini dibatalkan."
      confirmLabel="Buang perubahan" cancelLabel="Kembali ke form" tone="danger" onClose={controller.cancelDiscard} onConfirm={controller.confirmDiscard} />
  </>;
}

function baseFilterFields(filters: Record<string, string>, placeholder: string): FilterBarField[] {
  return [
    { id: "keyword", label: "Cari", type: "search", value: filters.keyword ?? "", placeholder },
    { id: "status", label: "Status", type: "select", value: filters.status ?? "", placeholder: "Semua status", options: statuses.map((value) => ({ value, label: value })) }
  ];
}
function matchesFilters(searchable: string, status: FitnessClientStatus, filters: Record<string, string>) {
  const keyword = (filters.keyword ?? "").trim().toLowerCase();
  return (!keyword || searchable.toLowerCase().includes(keyword)) && (!filters.status || status === filters.status);
}
type LocationDraft = Omit<FitnessClientLocation, "id" | "clientId" | "updatedAt">;
const emptyLocation: LocationDraft = { code: "", name: "", type: "Lokasi Pemeriksaan", address: "", city: "", province: "", postalCode: "", contactName: "", phone: "", email: "", accessNotes: "", status: "Aktif" };

function LocationTab({ client, initialRows }: { client: FitnessClientDetail; initialRows: FitnessClientLocation[] }) {
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientLocation | null>(null);
  const [draft, setDraft] = useState<LocationDraft>(emptyLocation);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientLocation | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const visibleRows = rows.filter((row) => matchesFilters(row.code + " " + row.name + " " + row.city + " " + row.contactName, row.status, filters));
  const columns: ResponsiveColumn<FitnessClientLocation>[] = [
    { key: "code", header: "Kode Lokasi", render: (row) => <strong>{row.code}</strong> },
    { key: "name", header: "Nama dan Jenis", render: (row) => <span><strong>{row.name}</strong><small className="client-cell-note">{row.type}</small></span> },
    { key: "address", header: "Alamat", render: (row) => <span>{row.address}<small className="client-cell-note">{row.city}, {row.province} {row.postalCode}</small></span> },
    { key: "contact", header: "PIC", render: (row) => <span>{row.contactName}<small className="client-cell-note">{row.phone}<br />{row.email}</small></span> },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientLocation) {
    setEditing(row ?? null); setDraft(row ? locationDraft(row) : { ...emptyLocation }); drawer.begin();
  }
  function change<K extends keyof LocationDraft>(field: K, value: LocationDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value })); drawer.markDirty();
  }
  function save() {
    if (!draft.code.trim() || !draft.name.trim()) return;
    const record: FitnessClientLocation = { ...draft, id: editing?.id ?? client.id + "-location-local-" + Date.now(), clientId: client.id, updatedAt: "State lokal" };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    drawer.finish(); setToast((editing ? "Perubahan lokasi" : "Lokasi baru") + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null); setToast("Lokasi dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title="Lokasi Klien" description="Lokasi milik atau yang digunakan klien untuk proses pemeriksaan." action={{ label: "Tambah Lokasi", icon: Plus, onClick: () => openEditor() }} />
      <FilterBar fields={baseFilterFields(filters, "Kode, nama, kota, atau PIC")} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} /> : <EmptyState title="Lokasi tidak ditemukan" description="Tambah lokasi atau reset filter." />}
    </section>
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + "Lokasi Klien"} description="Identitas klien dikunci oleh route." valid={Boolean(draft.code.trim() && draft.name.trim())} onSave={save}>
      <FormSection title="Identitas Lokasi" description="Data lokasi hanya berlaku untuk klien aktif.">
        <EditorField id="location-code" label="Kode Lokasi" value={draft.code} onChange={(value) => change("code", value)} required />
        <EditorField id="location-name" label="Nama Lokasi" value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorSelect id="location-type" label="Jenis Lokasi" value={draft.type} options={locationTypes} onChange={(value) => change("type", value as FitnessClientLocationType)} required />
        <EditorTextarea id="location-address" label="Alamat" value={draft.address} onChange={(value) => change("address", value)} />
        <EditorField id="location-city" label="Kota/Kabupaten" value={draft.city} onChange={(value) => change("city", value)} />
        <EditorField id="location-province" label="Provinsi" value={draft.province} onChange={(value) => change("province", value)} />
        <EditorField id="location-postal" label="Kode Pos" value={draft.postalCode} onChange={(value) => change("postalCode", value)} />
      </FormSection>
      <FormSection title="Kontak dan Akses">
        <EditorField id="location-pic" label="PIC Lokasi" value={draft.contactName} onChange={(value) => change("contactName", value)} />
        <EditorField id="location-phone" label="Telepon" value={draft.phone} onChange={(value) => change("phone", value)} />
        <EditorField id="location-email" label="Email" type="email" value={draft.email} onChange={(value) => change("email", value)} />
        <EditorTextarea id="location-access" label="Catatan Akses" value={draft.accessNotes} onChange={(value) => change("accessNotes", value)} />
        <EditorSelect id="location-status" label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate?.name} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}

type PersonnelDraft = Omit<FitnessClientPersonnel, "id" | "clientId" | "updatedAt" | "locationNames">;
const emptyPersonnel: PersonnelDraft = { name: "", title: "", type: "PIC Lokasi", locationIds: [], email: "", phone: "", status: "Aktif" };

function PersonnelTab({ client, initialRows, locations }: { client: FitnessClientDetail; initialRows: FitnessClientPersonnel[]; locations: FitnessClientLocation[] }) {
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientPersonnel | null>(null);
  const [draft, setDraft] = useState<PersonnelDraft>(emptyPersonnel);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientPersonnel | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const clientLocations = locations.filter((location) => location.clientId === client.id);
  const visibleRows = rows.filter((row) => matchesFilters(row.name + " " + row.title + " " + row.type + " " + row.locationNames.join(" "), row.status, filters));
  const columns: ResponsiveColumn<FitnessClientPersonnel>[] = [
    { key: "name", header: "Nama", render: (row) => <strong>{row.name}</strong> },
    { key: "role", header: "Jabatan dan Tipe", render: (row) => <span>{row.title}<small className="client-cell-note">{row.type}</small></span> },
    { key: "locations", header: "Lokasi Terkait", render: (row) => row.locationNames.join(", ") || "Seluruh lokasi klien" },
    { key: "contact", header: "Kontak", render: (row) => <span>{row.email}<small className="client-cell-note">{row.phone}</small></span> },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientPersonnel) {
    setEditing(row ?? null);
    setDraft(row ? { name: row.name, title: row.title, type: row.type, locationIds: [...row.locationIds], email: row.email, phone: row.phone, status: row.status } : { ...emptyPersonnel, locationIds: [] });
    drawer.begin();
  }
  function change<K extends keyof PersonnelDraft>(field: K, value: PersonnelDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value })); drawer.markDirty();
  }
  function toggleLocation(locationId: string) {
    change("locationIds", draft.locationIds.includes(locationId) ? draft.locationIds.filter((id) => id !== locationId) : [...draft.locationIds, locationId]);
  }
  function save() {
    if (!draft.name.trim()) return;
    const locationNames = clientLocations.filter((location) => draft.locationIds.includes(location.id)).map((location) => location.name);
    const record: FitnessClientPersonnel = { ...draft, locationNames, id: editing?.id ?? client.id + "-personnel-local-" + Date.now(), clientId: client.id, updatedAt: "State lokal" };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    drawer.finish(); setToast((editing ? "Perubahan personel" : "Personel baru") + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null); setToast("Personel/PIC dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title="Personel/PIC Klien" description="Hanya personel pihak klien. Surveyor GIFT tidak menjadi pilihan pada form ini." action={{ label: "Tambah Personel", icon: Plus, onClick: () => openEditor() }} />
      <FilterBar fields={baseFilterFields(filters, "Nama, jabatan, tipe, atau lokasi")} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} /> : <EmptyState title="Personel/PIC tidak ditemukan" description="Tambah personel klien atau reset filter." />}
    </section>
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + "Personel/PIC Klien"} description="Surveyor GIFT tetap terpisah dari data pihak klien." valid={Boolean(draft.name.trim())} onSave={save}>
      <FormSection title="Identitas Personel">
        <EditorField id="personnel-name" label="Nama Lengkap" value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorField id="personnel-title" label="Jabatan" value={draft.title} onChange={(value) => change("title", value)} />
        <EditorSelect id="personnel-type" label="Tipe Personel Klien" value={draft.type} options={personnelTypes} onChange={(value) => change("type", value as FitnessClientPersonnelType)} required />
        <EditorField id="personnel-email" label="Email" type="email" value={draft.email} onChange={(value) => change("email", value)} />
        <EditorField id="personnel-phone" label="Telepon" value={draft.phone} onChange={(value) => change("phone", value)} />
        <EditorSelect id="personnel-status" label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
      <fieldset className="ui-form-field">
        <legend className="ui-form-label">Lokasi Terkait <span>Opsional</span></legend>
        <div className="client-location-options">
          {clientLocations.map((location) => <label key={location.id}><input type="checkbox" checked={draft.locationIds.includes(location.id)} onChange={() => toggleLocation(location.id)} /> <span>{location.name}<small>{location.code}</small></span></label>)}
        </div>
        <small>Hanya lokasi milik {client.code} yang dapat dipilih.</small>
      </fieldset>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate?.name} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}

type CustomerSurveyorDraft = Omit<FitnessClientSurveyor, "id" | "clientId" | "updatedAt" | "locationNames">;
const emptyCustomerSurveyor: CustomerSurveyorDraft = { code: "", name: "", title: "", locationIds: [], email: "", phone: "", status: "Aktif" };

function CustomerSurveyorTab({ client, initialRows, locations }: { client: FitnessClientDetail; initialRows: FitnessClientSurveyor[]; locations: FitnessClientLocation[] }) {
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientSurveyor | null>(null);
  const [draft, setDraft] = useState<CustomerSurveyorDraft>(emptyCustomerSurveyor);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientSurveyor | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const clientLocations = locations.filter((location) => location.clientId === client.id);
  const visibleRows = rows.filter((row) => matchesFilters(row.code + " " + row.name + " " + row.title + " " + row.locationNames.join(" "), row.status, filters));
  const columns: ResponsiveColumn<FitnessClientSurveyor>[] = [
    { key: "code", header: "Kode", render: (row) => <strong>{row.code}</strong> },
    { key: "name", header: "Surveyor Customer", render: (row) => <span><strong>{row.name}</strong><small className="client-cell-note">{row.title}</small></span> },
    { key: "locations", header: "Location Terkait", render: (row) => row.locationNames.join(", ") || "Seluruh Location Customer" },
    { key: "contact", header: "Kontak", render: (row) => <span>{row.email}<small className="client-cell-note">{row.phone}</small></span> },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: (row) => row.updatedAt },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientSurveyor) {
    setEditing(row ?? null);
    setDraft(row ? { code: row.code, name: row.name, title: row.title, locationIds: [...row.locationIds], email: row.email, phone: row.phone, status: row.status } : { ...emptyCustomerSurveyor, locationIds: [] });
    drawer.begin();
  }
  function change<K extends keyof CustomerSurveyorDraft>(field: K, value: CustomerSurveyorDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value }));
    drawer.markDirty();
  }
  function toggleLocation(locationId: string) {
    change("locationIds", draft.locationIds.includes(locationId) ? draft.locationIds.filter((id) => id !== locationId) : [...draft.locationIds, locationId]);
  }
  function save() {
    if (!draft.code.trim() || !draft.name.trim()) return;
    const locationNames = clientLocations.filter((location) => draft.locationIds.includes(location.id)).map((location) => location.name);
    const record: FitnessClientSurveyor = { ...draft, locationNames, id: editing?.id ?? client.id + "-surveyor-local-" + Date.now(), clientId: client.id, updatedAt: "State lokal" };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    drawer.finish();
    setToast((editing ? "Perubahan Surveyor" : "Surveyor baru") + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null);
    setToast("Surveyor Customer dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title="Surveyor Customer" description="Surveyor milik atau terkait Customer aktif. Surveyor GIFT tidak tersedia pada form ini." action={{ label: "Tambah Surveyor", icon: Plus, onClick: () => openEditor() }} />
      <FilterBar fields={baseFilterFields(filters, "Kode, nama, jabatan, atau Location")} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} /> : <EmptyState title="Surveyor Customer tidak ditemukan" description="Tambah Surveyor Customer atau reset filter." />}
    </section>
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + "Surveyor Customer"} description="Customer dan clientId dikunci oleh route. Surveyor GIFT tetap terpisah." valid={Boolean(draft.code.trim() && draft.name.trim())} onSave={save}>
      <FormSection title="Identitas Surveyor Customer">
        <EditorField id="customer-surveyor-code" label="Kode Surveyor" value={draft.code} onChange={(value) => change("code", value)} required />
        <EditorField id="customer-surveyor-name" label="Nama Lengkap" value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorField id="customer-surveyor-title" label="Jabatan" value={draft.title} onChange={(value) => change("title", value)} />
        <EditorField id="customer-surveyor-email" label="Email" type="email" value={draft.email} onChange={(value) => change("email", value)} />
        <EditorField id="customer-surveyor-phone" label="Telepon" value={draft.phone} onChange={(value) => change("phone", value)} />
        <EditorSelect id="customer-surveyor-status" label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
      <fieldset className="ui-form-field">
        <legend className="ui-form-label">Location Terkait <span>Opsional</span></legend>
        <div className="client-location-options">
          {clientLocations.map((location) => <label key={location.id}><input type="checkbox" checked={draft.locationIds.includes(location.id)} onChange={() => toggleLocation(location.id)} /> <span>{location.name}<small>{location.code}</small></span></label>)}
        </div>
        <small>Hanya Location milik {client.code} yang dapat dipilih.</small>
      </fieldset>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate?.name} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}

type ContainerTypeDraft = Omit<FitnessClientContainerType, "id" | "clientId" | "updatedAt">;
const emptyContainerType: ContainerTypeDraft = { code: "", name: "", size: "", description: "", status: "Aktif" };

function ContainerTypeTab({ client, initialRows }: { client: FitnessClientDetail; initialRows: FitnessClientContainerType[] }) {
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientContainerType | null>(null);
  const [draft, setDraft] = useState<ContainerTypeDraft>(emptyContainerType);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientContainerType | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const visibleRows = rows.filter((row) => matchesFilters(row.code + " " + row.name + " " + row.size + " " + row.description, row.status, filters));
  const columns: ResponsiveColumn<FitnessClientContainerType>[] = [
    { key: "code", header: "Kode", render: (row) => <strong>{row.code}</strong> },
    { key: "name", header: "Nama Jenis", render: (row) => row.name },
    { key: "size", header: "Ukuran", render: (row) => row.size },
    { key: "description", header: "Deskripsi", render: (row) => row.description },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientContainerType) {
    setEditing(row ?? null); setDraft(row ? { code: row.code, name: row.name, size: row.size, description: row.description, status: row.status } : { ...emptyContainerType }); drawer.begin();
  }
  function change<K extends keyof ContainerTypeDraft>(field: K, value: ContainerTypeDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value })); drawer.markDirty();
  }
  function save() {
    if (!draft.code.trim() || !draft.name.trim()) return;
    const record: FitnessClientContainerType = { ...draft, id: editing?.id ?? client.id + "-container-type-local-" + Date.now(), clientId: client.id, updatedAt: "State lokal" };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    drawer.finish(); setToast((editing ? "Perubahan jenis" : "Jenis baru") + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null); setToast("Jenis peti kemas dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title="Jenis Peti Kemas Klien" description="Referensi jenis peti kemas yang terisolasi untuk klien aktif." action={{ label: "Tambah Jenis", icon: Plus, onClick: () => openEditor() }} />
      <FilterBar fields={baseFilterFields(filters, "Kode, nama, ukuran, atau deskripsi")} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} /> : <EmptyState title="Jenis peti kemas tidak ditemukan" description="Tambah jenis atau reset filter." />}
    </section>
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + "Jenis Peti Kemas"} description="Identitas klien dikunci oleh route." valid={Boolean(draft.code.trim() && draft.name.trim())} onSave={save}>
      <FormSection title="Jenis Peti Kemas">
        <EditorField id="container-type-code" label="Kode Jenis" value={draft.code} onChange={(value) => change("code", value)} required />
        <EditorField id="container-type-name" label="Nama Jenis" value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorField id="container-type-size" label="Ukuran" value={draft.size} onChange={(value) => change("size", value)} />
        <EditorTextarea id="container-type-description" label="Deskripsi" value={draft.description} onChange={(value) => change("description", value)} />
        <EditorSelect id="container-type-status" label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate?.name} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}

type MasterDataReferenceDraft = Omit<FitnessClientMasterDataReference, "id" | "clientId" | "category" | "updatedAt">;
const emptyMasterDataReference: MasterDataReferenceDraft = { code: "", name: "", description: "", status: "Aktif" };

function MasterDataReferenceTab({ client, category, initialRows }: { client: FitnessClientDetail; category: FitnessClientReferenceCategory; initialRows: FitnessClientMasterDataReference[] }) {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientMasterDataReference | null>(null);
  const [draft, setDraft] = useState<MasterDataReferenceDraft>(emptyMasterDataReference);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientMasterDataReference | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const visibleRows = rows.filter((row) => matchesFilters(row.code + " " + row.name + " " + row.description, row.status, filters));
  const columns: ResponsiveColumn<FitnessClientMasterDataReference>[] = [
    { key: "code", header: "Kode", render: (row) => <strong>{row.code}</strong> },
    { key: "name", header: "Nama/Label", render: (row) => row.name },
    { key: "description", header: "Deskripsi", render: (row) => row.description },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: (row) => row.updatedAt },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientMasterDataReference) {
    setEditing(row ?? null);
    setDraft(row ? { code: row.code, name: row.name, description: row.description, status: row.status } : { ...emptyMasterDataReference });
    drawer.begin();
  }
  function change<K extends keyof MasterDataReferenceDraft>(field: K, value: MasterDataReferenceDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value }));
    drawer.markDirty();
  }
  function save() {
    if (!draft.code.trim() || !draft.name.trim()) return;
    const record: FitnessClientMasterDataReference = {
      ...draft,
      id: editing?.id ?? client.id + "-" + category + "-local-" + Date.now(),
      clientId: client.id,
      category,
      updatedAt: "State lokal"
    };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    drawer.finish();
    setToast((editing ? "Perubahan " : "Data baru ") + config.label + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null);
    setToast(config.label + " dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title={config.label} description={config.description} action={{ label: config.addLabel, icon: Plus, onClick: () => openEditor() }} />
      <FilterBar fields={baseFilterFields(filters, config.searchPlaceholder)} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} /> : <EmptyState title={config.emptyTitle} description={`Tambah ${config.label} atau reset filter.`} />}
    </section>
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + config.label} description="Customer, kategori, dan clientId dikunci oleh route." valid={Boolean(draft.code.trim() && draft.name.trim())} onSave={save}>
      <FormSection title={config.label} description={config.notice}>
        <EditorField id={category + "-code"} label="Kode" value={draft.code} onChange={(value) => change("code", value)} required />
        <EditorField id={category + "-name"} label="Nama/Label" value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorTextarea id={category + "-description"} label="Deskripsi" value={draft.description} onChange={(value) => change("description", value)} />
        <EditorSelect id={category + "-status"} label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate?.name} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}

type ReferenceDraft = Omit<FitnessClientInspectionReference, "id" | "clientId" | "section" | "updatedAt">;
const emptyReference: ReferenceDraft = { code: "", name: "", description: "", relatedTo: "", unit: "", presentationRequired: false, order: 1, status: "Aktif" };

function ReferenceTab({ client, activeSection, initialRows }: { client: FitnessClientDetail; activeSection: FitnessInspectionReferenceSection; initialRows: FitnessClientInspectionReference[] }) {
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientInspectionReference | null>(null);
  const [draft, setDraft] = useState<ReferenceDraft>(emptyReference);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientInspectionReference | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const base = "/fitness/client-master-data/" + client.id + "?tab=inspection-references&section=";
  const tabs = referenceSections.map((section) => ({ id: section.id, label: section.label, href: base + section.id }));
  const sectionLabel = referenceSections.find((section) => section.id === activeSection)?.label ?? "Referensi Pemeriksaan";
  const sectionRows = rows.filter((row) => row.section === activeSection);
  const visibleRows = sectionRows.filter((row) => matchesFilters(row.code + " " + row.name + " " + row.description + " " + (row.relatedTo ?? "") + " " + (row.unit ?? ""), row.status, filters));
  const columns: ResponsiveColumn<FitnessClientInspectionReference>[] = [
    { key: "code", header: "Kode", render: (row) => <strong>{row.code}</strong> },
    { key: "name", header: "Nama", render: (row) => row.name },
    { key: "description", header: "Deskripsi", render: (row) => row.description },
    { key: "detail", header: referenceDetailLabel(activeSection), render: (row) => referenceDetail(row) },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientInspectionReference) {
    setEditing(row ?? null);
    setDraft(row ? { code: row.code, name: row.name, description: row.description, relatedTo: row.relatedTo ?? "", unit: row.unit ?? "", presentationRequired: row.presentationRequired ?? false, order: row.order ?? 1, status: row.status } : { ...emptyReference });
    drawer.begin();
  }
  function change<K extends keyof ReferenceDraft>(field: K, value: ReferenceDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value })); drawer.markDirty();
  }
  function save() {
    if (!draft.code.trim() || !draft.name.trim()) return;
    const record: FitnessClientInspectionReference = { ...draft, id: editing?.id ?? client.id + "-reference-local-" + Date.now(), clientId: client.id, section: activeSection, updatedAt: "State lokal" };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    drawer.finish(); setToast((editing ? "Perubahan referensi" : "Referensi baru") + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null); setToast("Referensi pemeriksaan dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageTabs tabs={tabs} activeHref={base + activeSection} />
      <div className="client-reference-note"><ClipboardCheck size={18} /><span>Referensi khusus {client.code}. Tidak ada checklist seed, batas teknis, keputusan otomatis, atau referensi regulasi baru.</span></div>
      <PageHeader title={sectionLabel} description="Referensi pemeriksaan terisolasi berdasarkan clientId dan section aktif." action={{ label: "Tambah Referensi", icon: Plus, onClick: () => openEditor() }} />
      <FilterBar fields={baseFilterFields(filters, "Kode, nama, deskripsi, atau relasi")} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} /> : <EmptyState title="Referensi tidak ditemukan" description="Tambah referensi pada section ini atau reset filter." />}
    </section>
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + sectionLabel} description="Section dan clientId dikunci oleh route." valid={Boolean(draft.code.trim() && draft.name.trim())} onSave={save}>
      <FormSection title={sectionLabel}>
        <EditorField id="reference-code" label="Kode" value={draft.code} onChange={(value) => change("code", value)} required />
        <EditorField id="reference-name" label={referenceNameLabel(activeSection)} value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorTextarea id="reference-description" label="Deskripsi" value={draft.description} onChange={(value) => change("description", value)} />
        {activeSection === "inspection-areas" ? <EditorField id="reference-order" label="Urutan" type="number" value={String(draft.order ?? 1)} onChange={(value) => change("order", Number(value) || 1)} /> : null}
        {activeSection === "structural-components" ? <EditorField id="reference-related-area" label="Area Pemeriksaan Terkait" value={draft.relatedTo ?? ""} onChange={(value) => change("relatedTo", value)} /> : null}
        {activeSection === "damage-criteria" ? <EditorField id="reference-related-component" label="Komponen Terkait" value={draft.relatedTo ?? ""} onChange={(value) => change("relatedTo", value)} /> : null}
        {activeSection === "finding-severities" ? <EditorField id="reference-visual-impact" label="Dampak Visual" value={draft.relatedTo ?? ""} onChange={(value) => change("relatedTo", value)} /> : null}
        {activeSection === "test-parameters" ? <EditorField id="reference-unit" label="Satuan" value={draft.unit ?? ""} onChange={(value) => change("unit", value)} /> : null}
        {activeSection === "photo-categories" ? <FormField id="reference-presentation" label="Kebutuhan Presentasi"><label className="client-checkbox-control"><input id="reference-presentation" type="checkbox" checked={Boolean(draft.presentationRequired)} onChange={(event) => change("presentationRequired", event.target.checked)} /> Wajib ditampilkan dalam presentasi pemeriksaan</label></FormField> : null}
        <EditorSelect id="reference-status" label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate?.name} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}
function LegacyMappingTab({ client, activeSection, rows }: { client: FitnessClientDetail; activeSection: FitnessLegacyMappingSection; rows: FitnessLegacyMappingRecord[] }) {
  const [keyword, setKeyword] = useState("");
  const base = "/fitness/client-master-data/" + client.id + "?tab=legacy-mapping&section=";
  const tabs = legacySections.map((section) => ({ id: section.id, label: section.label, href: base + section.id }));
  const visible = rows.filter((row) => row.section === activeSection && (row.legacyCode + " " + row.legacyName + " " + (row.mappedTarget ?? "")).toLowerCase().includes(keyword.toLowerCase()));
  const columns: ResponsiveColumn<FitnessLegacyMappingRecord>[] = [
    { key: "code", header: "Kode Lama", render: (row) => <strong>{row.legacyCode}</strong> },
    { key: "name", header: "Nama Lama", render: (row) => row.legacyName },
    { key: "target", header: "Target Mapping Aktif", render: (row) => row.mappedTarget ?? "Belum tersedia" },
    { key: "status", header: "Status Mapping", render: (row) => <StatusBadge tone={row.mappingStatus === "Terpetakan" ? "success" : "warning"}>{row.mappingStatus}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: (row) => row.updatedAt }
  ];
  return <section className="workspace-panel">
    <PageHeader title="Mapping Legacy" description="Referensi lama hanya dibaca dan difilter berdasarkan clientId. Tidak tersedia aksi CRUD." meta={<StatusBadge tone="warning">Read-only</StatusBadge>} />
    <PageTabs tabs={tabs} activeHref={base + activeSection} />
    <FilterBar fields={[{ id: "keyword", label: "Cari data lama", type: "search", value: keyword, placeholder: "Kode, nama, atau target mapping" }]} onChange={(_, value) => setKeyword(value)} onReset={() => setKeyword("")} />
    {visible.length ? <ResponsiveTableCards columns={columns} rows={visible} getRowId={(row) => row.id} getRowTitle={(row) => row.legacyName} /> : <EmptyState title="Mapping tidak ditemukan" description="Reset pencarian untuk melihat mapping klien ini." />}
  </section>;
}

function RowActions({ name, active, onEdit, onDeactivate }: { name: string; active: boolean; onEdit: () => void; onDeactivate: () => void }) {
  return <div className="client-row-actions"><button className="icon-button" aria-label={"Edit " + name} onClick={onEdit} type="button"><Pencil size={16} /></button><button className="secondary-button client-inline-action" disabled={!active} onClick={onDeactivate} type="button">Nonaktifkan</button></div>;
}
function DeactivateDialog({ item, onClose, onConfirm }: { item?: string; onClose: () => void; onConfirm: () => void }) {
  return <ConfirmationDialog open={Boolean(item)} title="Nonaktifkan data?" description={(item ?? "Data") + " hanya dinonaktifkan pada state lokal UI-B.2.1."} confirmLabel="Nonaktifkan" tone="danger" onClose={onClose} onConfirm={onConfirm} />;
}
function EditorField({ id, label, value, onChange, required, type = "text" }: { id: string; label: string; value: string; onChange: (value: string) => void; required?: boolean; type?: string }) {
  return <FormField id={id} label={label} required={required}><input id={id} type={type} value={value} onChange={(event) => onChange(event.target.value)} required={required} /></FormField>;
}
function EditorTextarea({ id, label, value, onChange }: { id: string; label: string; value: string; onChange: (value: string) => void }) {
  return <FormField id={id} label={label}><textarea id={id} rows={3} value={value} onChange={(event) => onChange(event.target.value)} /></FormField>;
}
function EditorSelect({ id, label, value, options, onChange, required }: { id: string; label: string; value: string; options: readonly string[]; onChange: (value: string) => void; required?: boolean }) {
  return <FormField id={id} label={label} required={required}><select id={id} value={value} onChange={(event) => onChange(event.target.value)} required={required}>{options.map((option) => <option key={option} value={option}>{option}</option>)}</select></FormField>;
}
function locationDraft(row: FitnessClientLocation): LocationDraft {
  return { code: row.code, name: row.name, type: row.type, address: row.address, city: row.city, province: row.province, postalCode: row.postalCode, contactName: row.contactName, phone: row.phone, email: row.email, accessNotes: row.accessNotes, status: row.status };
}
function referenceNameLabel(section: FitnessInspectionReferenceSection) {
  if (section === "finding-severities") return "Label Tingkat Keparahan";
  if (section === "test-parameters") return "Nama Parameter";
  if (section === "photo-categories") return "Nama Kategori Foto";
  if (section === "inspection-recommendations") return "Nama Rekomendasi";
  return "Nama";
}
function referenceDetailLabel(section: FitnessInspectionReferenceSection) {
  if (section === "inspection-areas") return "Urutan";
  if (section === "structural-components") return "Area Terkait";
  if (section === "damage-criteria") return "Komponen Terkait";
  if (section === "finding-severities") return "Dampak Visual";
  if (section === "test-parameters") return "Satuan";
  if (section === "photo-categories") return "Presentasi";
  return "Keterangan";
}
function referenceDetail(row: FitnessClientInspectionReference) {
  if (row.section === "inspection-areas") return row.order ?? "-";
  if (row.section === "photo-categories") return row.presentationRequired ? "Wajib" : "Tidak wajib";
  if (row.section === "test-parameters") return row.unit || "-";
  return row.relatedTo || "-";
}
function mainActiveHref(base: string, tab: ClientMasterTab) {
  if (tab === "inspection-references") return base + "?tab=inspection-references&section=inspection-areas";
  if (tab === "legacy-mapping") return base + "?tab=legacy-mapping&section=location";
  return base + "?tab=" + tab;
}
