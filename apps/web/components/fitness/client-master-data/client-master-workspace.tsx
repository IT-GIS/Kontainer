"use client";

import Link from "next/link";
import { useRef, useState } from "react";
import { ArrowLeft, ClipboardCheck, Database, Eye, Pencil, Plus, X } from "lucide-react";
import { useAuth } from "@/hooks/use-auth";
import { can, hasRole } from "@/lib/permissions";
import { getFitnessMasterDataCategoryConfigByID, masterDataIndexHref, type MasterDataRouteFamily } from "@/constants/fitness-master-data-client-first";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";
import { Drawer } from "@/components/ui/drawer";
import { EmptyState } from "@/components/ui/empty-state";
import { FilterBar, type FilterBarField } from "@/components/ui/filter-bar";
import { FormField } from "@/components/ui/form-field";
import { FormSection } from "@/components/ui/form-section";
import { PageHeader } from "@/components/ui/page-header";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { StatusBadge } from "@/components/ui/status-badge";
import { ToastFeedback } from "@/components/ui/toast-feedback";
import { UnsavedChangesGuard } from "@/components/ui/unsaved-changes-guard";
import type {
  FitnessCedexContainerSize, FitnessCedexFace,
  FitnessClientContainerType, FitnessClientDetail,
  FitnessClientLocation, FitnessClientLocationType, FitnessClientMasterDataRecord,
  FitnessClientMasterDataReference, FitnessClientReferenceCategory,
  FitnessClientStatus, FitnessClientSurveyor,
  FitnessMasterDataCategory
} from "@/types/fitness-admin";

const statuses: FitnessClientStatus[] = ["Aktif", "Tidak Aktif"];
const locationTypes: FitnessClientLocationType[] = ["Depo", "Gudang", "Terminal", "Pelabuhan", "Lokasi Pemeriksaan", "Lokasi Perbaikan Eksternal", "Lainnya"];
const cedexFaces: FitnessCedexFace[] = ["left", "right", "front", "door", "roof", "floor", "understructure"];
const cedexContainerSizes: FitnessCedexContainerSize[] = ["all", "20", "40", "45"];

export function FitnessClientMasterCategoryWorkspace({
  client,
  category,
  records,
  locations,
  routeFamily = "fitness"
}: {
  client: FitnessClientDetail;
  category: Exclude<FitnessMasterDataCategory, "customer">;
  records: FitnessClientMasterDataRecord[];
  locations: FitnessClientLocation[];
  routeFamily?: MasterDataRouteFamily;
}) {
  const { user } = useAuth();
  const config = getFitnessMasterDataCategoryConfigByID(category);
  const pickerHref = masterDataIndexHref(category, routeFamily);
  const customerInactive = client.status !== "Aktif";
  const canManageCategory = (hasRole(user, "admin") || hasRole(user, "super_admin"))
    && can(user, config.permissionModule + ".manage.all");
  const readOnly = customerInactive || !canManageCategory;
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
        secondaryAction={{ label: "Kembali ke Daftar Customer", icon: ArrowLeft, href: pickerHref }}
      />
      <div className="client-context-strip" role="status" aria-label={`Customer aktif ${client.name}`}>
        <Database size={18} />
        <span><strong>Customer aktif:</strong> {client.name}</span>
        <span><strong>Kode:</strong> {client.code}</span>
        <span><strong>Status:</strong> {client.status}</span>
        <span><strong>PIC Utama:</strong> {client.primaryContactName}</span>
        <span><strong>Customer ID:</strong> {client.id}</span>
      </div>
      {customerInactive ? <div className="alert alert-warning" role="alert">Customer tidak aktif. Data dapat dilihat, tetapi penambahan dan perubahan dinonaktifkan.</div> : null}
      {!customerInactive && !canManageCategory ? <div className="alert alert-warning" role="alert">Mode baca saja. Role atau permission Anda tidak mengizinkan pengelolaan {config.label} untuk Customer ini.</div> : null}
      {config.notice ? <div className="client-reference-note"><ClipboardCheck size={18} /><span>{config.notice}</span></div> : null}
      {category === "location" ? <LocationTab client={client} initialRows={records as FitnessClientLocation[]} readOnly={readOnly} /> : null}
      {category === "surveyor" ? <CustomerSurveyorTab client={client} initialRows={records as FitnessClientSurveyor[]} locations={locations} readOnly={readOnly} /> : null}
      {category === "container-type" ? <ContainerTypeTab client={client} initialRows={records as FitnessClientContainerType[]} readOnly={readOnly} /> : null}
      {category !== "location" && category !== "surveyor" && category !== "container-type" ? (
        <MasterDataReferenceTab client={client} category={category as FitnessClientReferenceCategory} initialRows={records as FitnessClientMasterDataReference[]} readOnly={readOnly} />
      ) : null}
    </div>
  );
}

function useDirtyDrawer() {
  const [open, setOpen] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [discardOpen, setDiscardOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const submitLockRef = useRef(false);
  return {
    open, dirty, discardOpen, submitting,
    begin: () => { submitLockRef.current = false; setSubmitting(false); setDirty(false); setDiscardOpen(false); setOpen(true); },
    requestClose: () => { if (dirty) setDiscardOpen(true); else setOpen(false); },
    confirmDiscard: () => { submitLockRef.current = false; setSubmitting(false); setDirty(false); setDiscardOpen(false); setOpen(false); },
    startSubmit: () => {
      if (submitLockRef.current) return false;
      submitLockRef.current = true;
      setSubmitting(true);
      return true;
    },
    finish: () => { submitLockRef.current = false; setSubmitting(false); setDirty(false); setDiscardOpen(false); setOpen(false); },
    markDirty: () => setDirty(true), cancelDiscard: () => setDiscardOpen(false)
  };
}
type DrawerController = ReturnType<typeof useDirtyDrawer>;

function createCategoryAction(label: string, customerName: string, onClick: () => void) {
  return {
    label,
    ariaLabel: label + " untuk " + customerName,
    icon: Plus,
    onClick
  };
}

function MasterDataDrawer({ client, controller, title, description, valid, onSave, children }: {
  client: FitnessClientDetail; controller: DrawerController; title: string; description: string;
  valid: boolean; onSave: () => void; children: React.ReactNode;
}) {
  return <>
    <Drawer open={controller.open} title={title} description={description} onClose={controller.requestClose}
      footer={<div className="client-drawer-actions"><button className="secondary-button" disabled={controller.submitting} onClick={controller.requestClose} type="button">Batal</button><button className="primary-button" disabled={!valid || controller.submitting} onClick={onSave} type="button">{controller.submitting ? "Menyimpan..." : "Simpan lokal"}</button></div>}>
      <div className="client-master-data-drawer-form">
        <div className="client-context-field"><span>Customer</span><strong>{client.name}</strong><small>Customer ID: {client.id} — berasal dari route dan tidak dapat diubah</small></div>
        {children}
      </div>
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

function LocationTab({ client, initialRows, readOnly }: { client: FitnessClientDetail; initialRows: FitnessClientLocation[]; readOnly: boolean }) {
  const config = getFitnessMasterDataCategoryConfigByID("location");
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientLocation | null>(null);
  const [viewing, setViewing] = useState<FitnessClientLocation | null>(null);
  const [draft, setDraft] = useState<LocationDraft>(emptyLocation);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientLocation | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const invalidEmail = !isValidEmail(draft.email);
  const valid = Boolean(draft.code.trim() && draft.name.trim() && !invalidEmail);
  const visibleRows = rows.filter((row) => matchesFilters(row.code + " " + row.name + " " + row.city + " " + row.contactName, row.status, filters));
  const columns: ResponsiveColumn<FitnessClientLocation>[] = [
    { key: "code", header: "Kode Location", render: (row) => <strong>{row.code}</strong> },
    { key: "name", header: "Nama dan Jenis", render: (row) => <span><strong>{row.name}</strong><small className="client-cell-note">{row.type}</small></span> },
    { key: "address", header: "Alamat", render: (row) => <span>{row.address}<small className="client-cell-note">{row.city}, {row.province} {row.postalCode}</small></span> },
    { key: "contact", header: "PIC", render: (row) => <span>{row.contactName}<small className="client-cell-note">{row.phone}<br />{row.email}</small></span> },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} readOnly={readOnly} onView={() => setViewing(row)} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientLocation) {
    setEditing(row ?? null); setDraft(row ? locationDraft(row) : { ...emptyLocation }); drawer.begin();
  }
  function openCreateDrawer() {
    openEditor();
  }
  const createAction = readOnly ? undefined : createCategoryAction(config.addLabel, client.name, openCreateDrawer);
  function change<K extends keyof LocationDraft>(field: K, value: LocationDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value })); drawer.markDirty();
  }
  function save() {
    if (!valid || readOnly || !drawer.startSubmit()) return;
    const record: FitnessClientLocation = { ...draft, id: editing?.id ?? client.id + "-location-local-" + Date.now(), clientId: client.id, updatedAt: "State lokal" };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    setEditing(null); setDraft({ ...emptyLocation }); drawer.finish();
    setToast((editing ? "Perubahan Location" : "Location baru") + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate || readOnly) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null); setToast("Location dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title="Location Customer" description="Location yang dimiliki atau digunakan Customer untuk proses pemeriksaan." action={createAction} />
      <FilterBar fields={baseFilterFields(filters, "Kode, nama, kota, atau PIC")} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? (
        <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} label={"Location " + client.name} pageSize={10} />
      ) : rows.length === 0 ? (
        <EmptyState title="Belum ada Location untuk Customer ini." description="Tambahkan Location pertama untuk Customer aktif." action={createAction ? { ...createAction, variant: "primary" } : undefined} />
      ) : (
        <EmptyState title="Location Customer tidak ditemukan" description="Ubah pencarian atau reset filter untuk melihat data lain." />
      )}
    </section>
    <RecordPreview item={viewing} onClose={() => setViewing(null)} title="Detail Location" />
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + "Location Customer"} description="Customer dikunci oleh route." valid={valid} onSave={save}>
      <FormSection title="Identitas Location" description="Data Location hanya berlaku untuk Customer aktif.">
        <EditorField id="location-code" label="Kode Location" value={draft.code} onChange={(value) => change("code", value)} required />
        <EditorField id="location-name" label="Nama Location" value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorSelect id="location-type" label="Jenis Location" value={draft.type} options={locationTypes} onChange={(value) => change("type", value as FitnessClientLocationType)} required />
        <EditorTextarea id="location-address" label="Alamat" value={draft.address} onChange={(value) => change("address", value)} />
        <EditorField id="location-city" label="Kota/Kabupaten" value={draft.city} onChange={(value) => change("city", value)} />
        <EditorField id="location-province" label="Provinsi" value={draft.province} onChange={(value) => change("province", value)} />
        <EditorField id="location-postal" label="Kode Pos" value={draft.postalCode} onChange={(value) => change("postalCode", value)} />
      </FormSection>
      <FormSection title="Kontak dan Akses">
        <EditorField id="location-pic" label="PIC Location" value={draft.contactName} onChange={(value) => change("contactName", value)} />
        <EditorField id="location-phone" label="Telepon" value={draft.phone} onChange={(value) => change("phone", value)} />
        <EditorField id="location-email" label="Email" type="email" value={draft.email} onChange={(value) => change("email", value)} error={invalidEmail ? "Gunakan format email yang valid." : undefined} />
        <EditorTextarea id="location-access" label="Catatan Akses" value={draft.accessNotes} onChange={(value) => change("accessNotes", value)} />
        <EditorSelect id="location-status" label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate?.name} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}

type CustomerSurveyorDraft = Omit<FitnessClientSurveyor, "id" | "clientId" | "updatedAt" | "locationNames">;
const emptyCustomerSurveyor: CustomerSurveyorDraft = { code: "", name: "", title: "", locationIds: [], email: "", phone: "", status: "Aktif" };

function CustomerSurveyorTab({ client, initialRows, locations, readOnly }: { client: FitnessClientDetail; initialRows: FitnessClientSurveyor[]; locations: FitnessClientLocation[]; readOnly: boolean }) {
  const config = getFitnessMasterDataCategoryConfigByID("surveyor");
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientSurveyor | null>(null);
  const [viewing, setViewing] = useState<FitnessClientSurveyor | null>(null);
  const [draft, setDraft] = useState<CustomerSurveyorDraft>(emptyCustomerSurveyor);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientSurveyor | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const clientLocations = locations.filter((location) => location.clientId === client.id && location.status === "Aktif");
  const invalidEmail = !isValidEmail(draft.email);
  const valid = Boolean(draft.code.trim() && draft.name.trim() && !invalidEmail);
  const visibleRows = rows.filter((row) => matchesFilters(row.code + " " + row.name + " " + row.title + " " + row.locationNames.join(" "), row.status, filters));
  const columns: ResponsiveColumn<FitnessClientSurveyor>[] = [
    { key: "code", header: "Kode", render: (row) => <strong>{row.code}</strong> },
    { key: "name", header: "Surveyor Customer", render: (row) => <span><strong>{row.name}</strong><small className="client-cell-note">{row.title}</small></span> },
    { key: "locations", header: "Location Terkait", render: (row) => row.locationNames.join(", ") || "Seluruh Location Customer" },
    { key: "contact", header: "Kontak", render: (row) => <span>{row.email}<small className="client-cell-note">{row.phone}</small></span> },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: (row) => row.updatedAt },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} readOnly={readOnly} onView={() => setViewing(row)} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientSurveyor) {
    setEditing(row ?? null);
    setDraft(row ? { code: row.code, name: row.name, title: row.title, locationIds: [...row.locationIds], email: row.email, phone: row.phone, status: row.status } : { ...emptyCustomerSurveyor, locationIds: [] });
    drawer.begin();
  }
  function openCreateDrawer() {
    openEditor();
  }
  const createAction = readOnly ? undefined : createCategoryAction(config.addLabel, client.name, openCreateDrawer);
  function change<K extends keyof CustomerSurveyorDraft>(field: K, value: CustomerSurveyorDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value }));
    drawer.markDirty();
  }
  function toggleLocation(locationId: string) {
    change("locationIds", draft.locationIds.includes(locationId) ? draft.locationIds.filter((id) => id !== locationId) : [...draft.locationIds, locationId]);
  }
  function save() {
    if (!valid || readOnly || !drawer.startSubmit()) return;
    const locationNames = clientLocations.filter((location) => draft.locationIds.includes(location.id)).map((location) => location.name);
    const record: FitnessClientSurveyor = { ...draft, locationNames, id: editing?.id ?? client.id + "-surveyor-local-" + Date.now(), clientId: client.id, updatedAt: "State lokal" };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    setEditing(null);
    setDraft({ ...emptyCustomerSurveyor, locationIds: [] });
    drawer.finish();
    setToast((editing ? "Perubahan Surveyor" : "Surveyor baru") + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate || readOnly) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null);
    setToast("Surveyor Customer dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title="Surveyor Customer" description="Surveyor milik atau terkait Customer aktif. Surveyor GIFT tidak tersedia pada form ini." action={createAction} />
      <FilterBar fields={baseFilterFields(filters, "Kode, nama, jabatan, atau Location")} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? (
        <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} label={"Surveyor Customer " + client.name} pageSize={10} />
      ) : rows.length === 0 ? (
        <EmptyState title="Belum ada Surveyor Customer untuk Customer ini." description="Tambahkan Surveyor Customer pertama untuk Customer aktif." action={createAction ? { ...createAction, variant: "primary" } : undefined} />
      ) : (
        <EmptyState title="Surveyor Customer tidak ditemukan" description="Ubah pencarian atau reset filter untuk melihat data lain." />
      )}
    </section>
    <RecordPreview item={viewing} onClose={() => setViewing(null)} title="Detail Surveyor Customer" />
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + "Surveyor Customer"} description="Customer dan clientId dikunci oleh route. Surveyor GIFT tetap terpisah." valid={valid} onSave={save}>
      <FormSection title="Identitas Surveyor Customer">
        <EditorField id="customer-surveyor-code" label="Kode Surveyor" value={draft.code} onChange={(value) => change("code", value)} required />
        <EditorField id="customer-surveyor-name" label="Nama Lengkap" value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorField id="customer-surveyor-title" label="Jabatan" value={draft.title} onChange={(value) => change("title", value)} />
        <EditorField id="customer-surveyor-email" label="Email" type="email" value={draft.email} onChange={(value) => change("email", value)} error={invalidEmail ? "Gunakan format email yang valid." : undefined} />
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

function ContainerTypeTab({ client, initialRows, readOnly }: { client: FitnessClientDetail; initialRows: FitnessClientContainerType[]; readOnly: boolean }) {
  const config = getFitnessMasterDataCategoryConfigByID("container-type");
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientContainerType | null>(null);
  const [viewing, setViewing] = useState<FitnessClientContainerType | null>(null);
  const [draft, setDraft] = useState<ContainerTypeDraft>(emptyContainerType);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientContainerType | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const visibleRows = rows.filter((row) => matchesFilters(row.code + " " + row.name + " " + row.size + " " + row.description, row.status, filters));
  const valid = Boolean(draft.code.trim() && draft.name.trim());
  const columns: ResponsiveColumn<FitnessClientContainerType>[] = [
    { key: "code", header: "Kode", render: (row) => <strong>{row.code}</strong> },
    { key: "name", header: "Nama Jenis", render: (row) => row.name },
    { key: "size", header: "Ukuran", render: (row) => row.size },
    { key: "description", header: "Deskripsi", render: (row) => row.description },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "actions", header: "Aksi", render: (row) => <RowActions name={row.name} active={row.status === "Aktif"} readOnly={readOnly} onView={() => setViewing(row)} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientContainerType) {
    setEditing(row ?? null); setDraft(row ? { code: row.code, name: row.name, size: row.size, description: row.description, status: row.status } : { ...emptyContainerType }); drawer.begin();
  }
  function openCreateDrawer() {
    openEditor();
  }
  const createAction = readOnly ? undefined : createCategoryAction(config.addLabel, client.name, openCreateDrawer);
  function change<K extends keyof ContainerTypeDraft>(field: K, value: ContainerTypeDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value })); drawer.markDirty();
  }
  function save() {
    if (!valid || readOnly || !drawer.startSubmit()) return;
    const record: FitnessClientContainerType = { ...draft, id: editing?.id ?? client.id + "-container-type-local-" + Date.now(), clientId: client.id, updatedAt: "State lokal" };
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    setEditing(null); setDraft({ ...emptyContainerType }); drawer.finish();
    setToast((editing ? "Perubahan jenis" : "Jenis baru") + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate || readOnly) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null); setToast("Jenis peti kemas dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title="Container Type Customer" description="Referensi jenis container Customer; bukan peti kemas individual." action={createAction} />
      <FilterBar fields={baseFilterFields(filters, "Kode, nama, ukuran, atau deskripsi")} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? (
        <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={(row) => row.name} label={"Container Type " + client.name} pageSize={10} />
      ) : rows.length === 0 ? (
        <EmptyState title="Belum ada Container Type untuk Customer ini." description="Tambahkan Container Type pertama untuk Customer aktif." action={createAction ? { ...createAction, variant: "primary" } : undefined} />
      ) : (
        <EmptyState title="Container Type Customer tidak ditemukan" description="Ubah pencarian atau reset filter untuk melihat data lain." />
      )}
    </section>
    <RecordPreview item={viewing} onClose={() => setViewing(null)} title="Detail Container Type" />
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + "Container Type Customer"} description="Customer dikunci oleh route. Peti kemas individual tetap dikelola pada menu Peti Kemas." valid={valid} onSave={save}>
      <FormSection title="Container Type Customer">
        <EditorField id="container-type-code" label="Kode Container Type" value={draft.code} onChange={(value) => change("code", value)} required />
        <EditorField id="container-type-name" label="Nama Container Type" value={draft.name} onChange={(value) => change("name", value)} required />
        <EditorField id="container-type-size" label="Ukuran" value={draft.size} onChange={(value) => change("size", value)} />
        <EditorTextarea id="container-type-description" label="Deskripsi" value={draft.description} onChange={(value) => change("description", value)} />
        <EditorSelect id="container-type-status" label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate?.name} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}

type MasterDataReferenceDraft = {
  code: string;
  name: string;
  description: string;
  status: FitnessClientStatus;
  requiresEir: boolean;
  requiresLightTest: boolean;
  requiresCargoWorthyResult: boolean;
  face: FitnessCedexFace;
  gridCode: string;
  cedexMappingCode: string;
  containerSize: FitnessCedexContainerSize;
  displayOrder: number;
};
const emptyMasterDataReference: MasterDataReferenceDraft = {
  code: "",
  name: "",
  description: "",
  status: "Aktif",
  requiresEir: false,
  requiresLightTest: false,
  requiresCargoWorthyResult: false,
  face: "left",
  gridCode: "",
  cedexMappingCode: "",
  containerSize: "all",
  displayOrder: 0
};

function MasterDataReferenceTab({ client, category, initialRows, readOnly }: { client: FitnessClientDetail; category: FitnessClientReferenceCategory; initialRows: FitnessClientMasterDataReference[]; readOnly: boolean }) {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  const [rows, setRows] = useState(initialRows);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [editing, setEditing] = useState<FitnessClientMasterDataReference | null>(null);
  const [viewing, setViewing] = useState<FitnessClientMasterDataReference | null>(null);
  const [draft, setDraft] = useState<MasterDataReferenceDraft>(emptyMasterDataReference);
  const [pendingDeactivate, setPendingDeactivate] = useState<FitnessClientMasterDataReference | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const drawer = useDirtyDrawer();
  const visibleRows = rows.filter((row) => matchesFilters(referenceSearchText(row), row.status, filters));
  const valid = Boolean(
    draft.code.trim()
    && (category === "cedex-location" ? draft.gridCode.trim() && draft.displayOrder >= 0 : draft.name.trim())
  );
  const columns: ResponsiveColumn<FitnessClientMasterDataReference>[] = [
    { key: "code", header: category === "cedex-location" ? "CODE" : config.codeLabel, render: (row) => <strong>{row.code}</strong> },
    ...(category === "cedex-location" ? [
      { key: "face", header: "FACE", render: (row: FitnessClientMasterDataReference) => row.category === "cedex-location" ? row.face : "-" },
      { key: "grid", header: "GRID", render: (row: FitnessClientMasterDataReference) => row.category === "cedex-location" ? row.gridCode : "-" },
      { key: "container-size", header: "CONTAINER SIZE", render: (row: FitnessClientMasterDataReference) => row.category === "cedex-location" ? row.containerSize : "-" },
      { key: "order", header: "ORDER", render: (row: FitnessClientMasterDataReference) => row.category === "cedex-location" ? row.displayOrder : "-" }
    ] : [
      { key: "name", header: config.nameLabel, render: (row: FitnessClientMasterDataReference) => "name" in row ? row.name : row.gridCode }
    ]),
    ...(category === "survey-type" ? [
      { key: "requirements", header: "Requirement", render: (row: FitnessClientMasterDataReference) => row.category === "survey-type" ? requirementLabels(row) : "-" }
    ] : []),
    ...(category === "cedex-location" ? [] : [{ key: "description", header: config.descriptionLabel, render: (row: FitnessClientMasterDataReference) => row.description || "-" }]),
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    ...(category === "cedex-location" ? [] : [{ key: "updated", header: "Pembaruan", render: (row: FitnessClientMasterDataReference) => row.updatedAt }]),
    { key: "actions", header: "AKSI", render: (row) => <RowActions name={referenceDisplayName(row)} active={row.status === "Aktif"} readOnly={readOnly} onView={() => setViewing(row)} onEdit={() => openEditor(row)} onDeactivate={() => setPendingDeactivate(row)} /> }
  ];
  function openEditor(row?: FitnessClientMasterDataReference) {
    setEditing(row ?? null);
    if (!row) {
      setDraft({ ...emptyMasterDataReference });
    } else if (row.category === "survey-type") {
      setDraft({ ...emptyMasterDataReference, code: row.code, name: row.name, description: row.description, status: row.status, requiresEir: row.requiresEir, requiresLightTest: row.requiresLightTest, requiresCargoWorthyResult: row.requiresCargoWorthyResult });
    } else if (row.category === "cedex-location") {
      setDraft({ ...emptyMasterDataReference, code: row.code, description: row.description, status: row.status, face: row.face, gridCode: row.gridCode, cedexMappingCode: row.cedexMappingCode, containerSize: row.containerSize, displayOrder: row.displayOrder });
    } else {
      setDraft({ ...emptyMasterDataReference, code: row.code, name: row.name, description: row.description, status: row.status });
    }
    drawer.begin();
  }
  function openCreateDrawer() {
    openEditor();
  }
  const createAction = readOnly ? undefined : createCategoryAction(config.addLabel, client.name, openCreateDrawer);
  function change<K extends keyof MasterDataReferenceDraft>(field: K, value: MasterDataReferenceDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value }));
    drawer.markDirty();
  }
  function save() {
    if (!valid || readOnly || !drawer.startSubmit()) return;
    const common = {
      id: editing?.id ?? client.id + "-" + category + "-local-" + Date.now(),
      clientId: client.id,
      code: draft.code,
      description: draft.description,
      status: draft.status,
      updatedAt: "State lokal"
    };
    let record: FitnessClientMasterDataReference;
    if (category === "survey-type") {
      record = { ...common, category, name: draft.name, requiresEir: draft.requiresEir, requiresLightTest: draft.requiresLightTest, requiresCargoWorthyResult: draft.requiresCargoWorthyResult };
    } else if (category === "cedex-location") {
      record = { ...common, category, face: draft.face, gridCode: draft.gridCode, cedexMappingCode: draft.cedexMappingCode, containerSize: draft.containerSize, displayOrder: draft.displayOrder };
    } else {
      record = { ...common, category, name: draft.name };
    }
    setRows((current) => editing ? current.map((row) => row.id === editing.id ? record : row) : [...current, record]);
    setEditing(null);
    setDraft({ ...emptyMasterDataReference });
    drawer.finish();
    setToast((editing ? "Perubahan " : "Data baru ") + config.label + " tersimpan pada state lokal " + client.code + ".");
  }
  function deactivate() {
    if (!pendingDeactivate || readOnly) return;
    setRows((current) => current.map((row) => row.id === pendingDeactivate.id ? { ...row, status: "Tidak Aktif" } : row));
    setPendingDeactivate(null);
    setToast(config.label + " dinonaktifkan pada state lokal.");
  }
  return <>
    <section className="workspace-panel">
      <PageHeader title={config.label + " Customer"} description={config.description} action={createAction} />
      <FilterBar fields={baseFilterFields(filters, config.searchPlaceholder)} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleRows.length ? (
        <ResponsiveTableCards columns={columns} rows={visibleRows} getRowId={(row) => row.id} getRowTitle={referenceDisplayName} label={config.label + " " + client.name} pageSize={10} />
      ) : rows.length === 0 ? (
        <EmptyState title={"Belum ada " + config.label + " untuk Customer ini."} description={"Tambahkan " + config.label + " pertama untuk Customer aktif."} action={createAction ? { ...createAction, variant: "primary" } : undefined} />
      ) : (
        <EmptyState title={config.label + " tidak ditemukan"} description="Ubah pencarian atau reset filter untuk melihat data lain." />
      )}
    </section>
    <RecordPreview item={viewing} onClose={() => setViewing(null)} title={`Detail ${config.label}`} />
    <MasterDataDrawer client={client} controller={drawer} title={(editing ? "Edit " : "Tambah ") + config.label} description="Customer, kategori, dan clientId dikunci oleh route." valid={valid} onSave={save}>
      <FormSection title={config.label} description={config.notice}>
        <EditorField id={category + "-code"} label={config.codeLabel} value={draft.code} onChange={(value) => change("code", value)} required />
        {category === "cedex-location" ? <>
          <EditorSelect id="cedex-location-face" label="Face" value={draft.face} options={cedexFaces} onChange={(value) => change("face", value as FitnessCedexFace)} required />
          <EditorField id="cedex-location-grid" label="Grid Code" value={draft.gridCode} onChange={(value) => change("gridCode", value)} required />
          <EditorField id="cedex-location-mapping" label="CEDEX Mapping Code" value={draft.cedexMappingCode} onChange={(value) => change("cedexMappingCode", value)} />
          <EditorSelect id="cedex-location-size" label="Container Size" value={draft.containerSize} options={cedexContainerSizes} onChange={(value) => change("containerSize", value as FitnessCedexContainerSize)} />
          <EditorField id="cedex-location-order" label="Display Order" type="number" value={String(draft.displayOrder)} onChange={(value) => change("displayOrder", Math.max(0, Number(value) || 0))} required />
        </> : <EditorField id={category + "-name"} label={config.nameLabel} value={draft.name} onChange={(value) => change("name", value)} required />}
        <EditorTextarea id={category + "-description"} label={config.descriptionLabel} value={draft.description} onChange={(value) => change("description", value)} />
        {category === "survey-type" ? <div className="client-checkbox-grid">
          <EditorCheckbox id="survey-type-eir" label="Memerlukan EIR" checked={draft.requiresEir} onChange={(value) => change("requiresEir", value)} />
          <EditorCheckbox id="survey-type-light-test" label="Memerlukan Light Test" checked={draft.requiresLightTest} onChange={(value) => change("requiresLightTest", value)} />
          <EditorCheckbox id="survey-type-cargo-worthy" label="Memerlukan Hasil Cargo Worthy" checked={draft.requiresCargoWorthyResult} onChange={(value) => change("requiresCargoWorthyResult", value)} />
        </div> : null}
        <EditorSelect id={category + "-status"} label="Status" value={draft.status} options={statuses} onChange={(value) => change("status", value as FitnessClientStatus)} required />
      </FormSection>
    </MasterDataDrawer>
    <DeactivateDialog item={pendingDeactivate ? referenceDisplayName(pendingDeactivate) : undefined} onClose={() => setPendingDeactivate(null)} onConfirm={deactivate} />
    {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
  </>;
}

function RowActions({ name, active, readOnly, onView, onEdit, onDeactivate }: { name: string; active: boolean; readOnly: boolean; onView: () => void; onEdit: () => void; onDeactivate: () => void }) {
  return <div className="client-row-actions"><button className="icon-button" aria-label={"Lihat " + name} onClick={onView} type="button"><Eye size={16} /></button><button className="icon-button" aria-label={"Edit " + name} disabled={readOnly} onClick={onEdit} type="button"><Pencil size={16} /></button><button aria-label={"Nonaktifkan " + name} className="secondary-button client-inline-action" disabled={readOnly || !active} onClick={onDeactivate} type="button">Nonaktifkan</button></div>;
}
function RecordPreview<T extends object>({ item, title, onClose }: { item: T | null; title: string; onClose: () => void }) {
  if (!item) return null;
  const entries = Object.entries(item).filter(([key]) => key !== "id" && key !== "clientId" && key !== "category");
  return (
    <section className="workspace-panel" aria-label={title}>
      <div className="section-title-row">
        <div><Eye size={20} /><h2>{title}</h2></div>
        <button aria-label={`Tutup ${title}`} className="icon-button" onClick={onClose} type="button"><X size={16} /></button>
      </div>
      <dl className="detail-grid">
        {entries.map(([key, value]) => <div className="detail-item" key={key}><dt>{recordFieldLabel(key)}</dt><dd>{recordFieldValue(value)}</dd></div>)}
      </dl>
    </section>
  );
}
function recordFieldLabel(value: string) {
  return value.replace(/([a-z])([A-Z])/g, "$1 $2").replaceAll("_", " ").replace(/^./, (letter) => letter.toUpperCase());
}
function recordFieldValue(value: unknown) {
  if (Array.isArray(value)) return value.join(", ") || "-";
  if (typeof value === "boolean") return value ? "Ya" : "Tidak";
  return value === null || value === undefined || value === "" ? "-" : String(value);
}
function DeactivateDialog({ item, onClose, onConfirm }: { item?: string; onClose: () => void; onConfirm: () => void }) {
  return <ConfirmationDialog open={Boolean(item)} title="Nonaktifkan data?" description={(item ?? "Data") + " hanya dinonaktifkan pada state lokal frontend."} confirmLabel="Nonaktifkan" tone="danger" onClose={onClose} onConfirm={onConfirm} />;
}
function EditorField({ id, label, value, onChange, required, type = "text", error }: { id: string; label: string; value: string; onChange: (value: string) => void; required?: boolean; type?: string; error?: string }) {
  return <FormField error={error} id={id} label={label} required={required}><input aria-describedby={error ? id + "-error" : undefined} aria-invalid={Boolean(error)} id={id} type={type} value={value} onChange={(event) => onChange(event.target.value)} required={required} /></FormField>;
}
function EditorTextarea({ id, label, value, onChange }: { id: string; label: string; value: string; onChange: (value: string) => void }) {
  return <FormField id={id} label={label}><textarea id={id} rows={3} value={value} onChange={(event) => onChange(event.target.value)} /></FormField>;
}
function EditorSelect({ id, label, value, options, onChange, required }: { id: string; label: string; value: string; options: readonly string[]; onChange: (value: string) => void; required?: boolean }) {
  return <FormField id={id} label={label} required={required}><select id={id} value={value} onChange={(event) => onChange(event.target.value)} required={required}>{options.map((option) => <option key={option} value={option}>{option}</option>)}</select></FormField>;
}
function EditorCheckbox({ id, label, checked, onChange }: { id: string; label: string; checked: boolean; onChange: (value: boolean) => void }) {
  return <FormField id={id} label={label} optionalLabel=""><input checked={checked} className="client-checkbox-input" id={id} onChange={(event) => onChange(event.target.checked)} type="checkbox" /></FormField>;
}
function locationDraft(row: FitnessClientLocation): LocationDraft {
  return { code: row.code, name: row.name, type: row.type, address: row.address, city: row.city, province: row.province, postalCode: row.postalCode, contactName: row.contactName, phone: row.phone, email: row.email, accessNotes: row.accessNotes, status: row.status };
}
function referenceDisplayName(row: FitnessClientMasterDataReference) {
  return row.category === "cedex-location" ? row.gridCode : row.name;
}
function referenceSearchText(row: FitnessClientMasterDataReference) {
  if (row.category === "cedex-location") {
    return [row.code, row.face, row.gridCode, row.cedexMappingCode, row.containerSize, row.description].join(" ");
  }
  return [row.code, row.name, row.description].join(" ");
}
function requirementLabels(row: Extract<FitnessClientMasterDataReference, { category: "survey-type" }>) {
  const labels = [
    row.requiresEir ? "EIR" : null,
    row.requiresLightTest ? "Light Test" : null,
    row.requiresCargoWorthyResult ? "Cargo Worthy" : null
  ].filter(Boolean);
  return labels.length ? labels.join(" · ") : "Tidak ada";
}
function isValidEmail(value: string) {
  return !value.trim() || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}
