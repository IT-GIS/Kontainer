"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { Building2, Database, Eye, Pencil, Plus, Save, UserRoundCheck } from "lucide-react";
import { useRouter } from "next/navigation";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { FilterBar, type FilterBarField } from "@/components/ui/filter-bar";
import { FormField } from "@/components/ui/form-field";
import { FormSection } from "@/components/ui/form-section";
import { PageHeader } from "@/components/ui/page-header";
import { PageTabs } from "@/components/ui/page-tabs";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { SearchableSelect } from "@/components/ui/searchable-select";
import { StatusBadge } from "@/components/ui/status-badge";
import { StickyActionBar } from "@/components/ui/sticky-action-bar";
import { ToastFeedback } from "@/components/ui/toast-feedback";
import { UnsavedChangesGuard } from "@/components/ui/unsaved-changes-guard";
import type { FitnessClientDetail, FitnessClientSummary, PageTabItem } from "@/types/fitness-admin";

const workspaceTabs: PageTabItem[] = [
  { id: "clients", label: "Daftar Klien", href: "/fitness/clients" },
  { id: "master", label: "Master Data Klien", href: "/fitness/client-master-data" }
];

export function ClientWorkspaceTabs({ activeHref }: { activeHref: string }) {
  return <PageTabs tabs={workspaceTabs} activeHref={activeHref} />;
}

export function FitnessClientsList({ initialClients }: { initialClients: FitnessClientSummary[] }) {
  const router = useRouter();
  const [clients, setClients] = useState(initialClients);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [pendingClient, setPendingClient] = useState<FitnessClientSummary | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  const fields: FilterBarField[] = [
    { id: "keyword", label: "Cari", type: "search", value: filters.keyword ?? "", placeholder: "Nama atau kode klien" },
    {
      id: "status",
      label: "Status",
      type: "select",
      value: filters.status ?? "",
      placeholder: "Semua status",
      options: [{ value: "Aktif", label: "Aktif" }, { value: "Tidak Aktif", label: "Tidak Aktif" }]
    },
    {
      id: "region",
      label: "Kota/Provinsi",
      type: "select",
      value: filters.region ?? "",
      placeholder: "Semua wilayah",
      options: Array.from(new Set(clients.flatMap((item) => [item.city, item.province]))).map((value) => ({ value, label: value }))
    }
  ];

  const visibleClients = useMemo(() => {
    const keyword = (filters.keyword ?? "").trim().toLowerCase();
    return clients.filter((client) => {
      const matchesKeyword = !keyword || (client.name + " " + client.code).toLowerCase().includes(keyword);
      const matchesStatus = !filters.status || client.status === filters.status;
      const matchesRegion = !filters.region || client.city === filters.region || client.province === filters.region;
      return matchesKeyword && matchesStatus && matchesRegion;
    });
  }, [clients, filters]);

  const columns: ResponsiveColumn<FitnessClientSummary>[] = [
    { key: "code", header: "Kode Klien", render: (row) => <strong>{row.code}</strong> },
    {
      key: "name",
      header: "Perusahaan/Organisasi",
      render: (row) => <span><strong>{row.name}</strong><small className="client-cell-note">{row.addressShort}</small></span>
    },
    { key: "pic", header: "PIC Utama", render: (row) => <span>{row.primaryContactName}<small className="client-cell-note">{row.email}<br />{row.phone}</small></span> },
    { key: "locations", header: "Lokasi", render: (row) => row.locationCount },
    { key: "containers", header: "Peti Kemas", render: (row) => row.containerCount },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: (row) => row.updatedAt },
    {
      key: "actions",
      header: "Aksi",
      render: (row) => (
        <div className="client-row-actions">
          <Link className="icon-button" href={"/fitness/clients/" + row.id} aria-label={"Lihat detail " + row.name} title="Lihat detail"><Eye size={16} /></Link>
          <Link className="icon-button" href={"/fitness/clients/" + row.id} aria-label={"Edit " + row.name} title="Edit"><Pencil size={16} /></Link>
          <Link className="secondary-button client-inline-action" href={"/fitness/client-master-data/" + row.id + "?tab=summary"}>Kelola Master Data</Link>
          <button className="secondary-button client-inline-action" disabled={row.status !== "Aktif"} onClick={() => setPendingClient(row)} type="button">Nonaktifkan</button>
        </div>
      )
    }
  ];

  function confirmDeactivate() {
    if (!pendingClient) return;
    setClients((current) => current.map((item) => item.id === pendingClient.id ? { ...item, status: "Tidak Aktif" } : item));
    setToast(pendingClient.name + " dinonaktifkan pada state lokal.");
    setPendingClient(null);
  }

  return (
    <div className="page-stack">
      <ClientWorkspaceTabs activeHref="/fitness/clients" />
      <PageHeader
        eyebrow="Klien & Master Data"
        title="Daftar Klien"
        description="Perusahaan atau organisasi pengguna jasa inspeksi GIFT."
        meta={<span>{visibleClients.length} dari {clients.length} klien ditampilkan</span>}
        action={{ label: "Tambah Klien", icon: Plus, onClick: () => router.push("/fitness/clients/create") }}
      />
      <FilterBar
        fields={fields}
        onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))}
        onReset={() => setFilters({})}
        onSubmit={() => undefined}
      />
      {visibleClients.length > 0 ? (
        <ResponsiveTableCards columns={columns} rows={visibleClients} getRowId={(row) => row.id} getRowTitle={(row) => row.name} />
      ) : (
        <EmptyState title="Klien tidak ditemukan" description="Ubah pencarian atau reset filter untuk menampilkan klien." />
      )}
      {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
      <ConfirmationDialog
        open={Boolean(pendingClient)}
        title="Nonaktifkan klien?"
        description="Perubahan hanya berlaku pada state lokal UI-B.2 dan akan kembali setelah halaman dimuat ulang."
        confirmLabel="Nonaktifkan"
        tone="danger"
        onClose={() => setPendingClient(null)}
        onConfirm={confirmDeactivate}
      />
    </div>
  );
}

export function FitnessClientForm({ client }: { client?: FitnessClientDetail }) {
  const router = useRouter();
  const isEdit = Boolean(client);
  const [form, setForm] = useState({
    code: client?.code ?? "",
    name: client?.name ?? "",
    shortName: client?.shortName ?? "",
    status: client?.status ?? "Aktif",
    address: client?.address ?? "",
    city: client?.city ?? "",
    province: client?.province ?? "",
    postalCode: client?.postalCode ?? "",
    legalIdentity: client?.legalIdentity ?? "",
    primaryContactName: client?.primaryContactName ?? "",
    primaryContactTitle: client?.primaryContactTitle ?? "",
    email: client?.email ?? "",
    phone: client?.phone ?? "",
    adminNotes: client?.adminNotes ?? "",
    accessInformation: client?.accessInformation ?? ""
  });
  const [dirty, setDirty] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [toastOpen, setToastOpen] = useState(false);
  const missingRequired = !form.code.trim() || !form.name.trim() || !form.primaryContactName.trim() || !form.email.trim();

  function update(field: keyof typeof form, value: string) {
    setForm((current) => ({ ...current, [field]: value }));
    setDirty(true);
  }

  function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!missingRequired) setConfirmOpen(true);
  }

  function saveLocal() {
    setDirty(false);
    setConfirmOpen(false);
    setToastOpen(true);
  }

  return (
    <div className="page-stack">
      <ClientWorkspaceTabs activeHref="/fitness/clients" />
      <PageHeader
        eyebrow={isEdit ? client?.code : "Klien baru"}
        title={isEdit ? "Detail dan Edit Klien" : "Tambah Klien"}
        description="Form frontend-only. Tidak ada data yang dikirim ke backend pada UI-B.2."
        meta={client ? <StatusBadge tone={client.status === "Aktif" ? "success" : "neutral"}>{client.status}</StatusBadge> : undefined}
      />
      <form id="fitness-client-form" onSubmit={submit}>
        <FormSection title="Identitas" description="Kode dan identitas perusahaan atau organisasi klien.">
          <TextField id="client-code" label="Kode Klien" value={form.code} onChange={(value) => update("code", value)} required />
          <TextField id="client-name" label="Nama Perusahaan/Organisasi" value={form.name} onChange={(value) => update("name", value)} required />
          <TextField id="client-short-name" label="Nama Singkat" value={form.shortName} onChange={(value) => update("shortName", value)} />
          <FormField id="client-status" label="Status" required helpText="Status hanya mengubah state lokal pada tahap ini.">
            <SearchableSelect
              id="client-status"
              label="Status"
              value={form.status}
              onChange={(value) => update("status", value ?? "Aktif")}
              options={[{ value: "Aktif", label: "Aktif" }, { value: "Tidak Aktif", label: "Tidak Aktif" }]}
              required
            />
          </FormField>
        </FormSection>
        <FormSection title="Legal dan Alamat">
          <TextField id="client-address" label="Alamat" value={form.address} onChange={(value) => update("address", value)} multiline />
          <TextField id="client-city" label="Kota/Kabupaten" value={form.city} onChange={(value) => update("city", value)} />
          <TextField id="client-province" label="Provinsi" value={form.province} onChange={(value) => update("province", value)} />
          <TextField id="client-postal" label="Kode Pos" value={form.postalCode} onChange={(value) => update("postalCode", value)} />
          <TextField id="client-legal" label="Identitas Perusahaan" value={form.legalIdentity} onChange={(value) => update("legalIdentity", value)} multiline />
        </FormSection>
        <FormSection title="Kontak Utama">
          <TextField id="client-pic" label="PIC Utama" value={form.primaryContactName} onChange={(value) => update("primaryContactName", value)} required />
          <TextField id="client-title" label="Jabatan" value={form.primaryContactTitle} onChange={(value) => update("primaryContactTitle", value)} />
          <TextField id="client-email" label="Email" type="email" value={form.email} onChange={(value) => update("email", value)} required />
          <TextField id="client-phone" label="Telepon" value={form.phone} onChange={(value) => update("phone", value)} />
        </FormSection>
        <FormSection title="Catatan Admin">
          <TextField id="client-notes" label="Catatan" value={form.adminNotes} onChange={(value) => update("adminNotes", value)} multiline />
          <TextField id="client-access" label="Informasi Akses" value={form.accessInformation} onChange={(value) => update("accessInformation", value)} multiline />
        </FormSection>
      </form>
      {missingRequired && dirty ? <div className="alert alert-warning" role="alert">Lengkapi kode, nama klien, PIC utama, dan email sebelum menyimpan.</div> : null}
      {toastOpen ? <ToastFeedback title="Data tersimpan di tampilan" description="Perubahan lokal akan kembali ke mock awal setelah reload." tone="success" onDismiss={() => setToastOpen(false)} /> : null}
      <UnsavedChangesGuard active={dirty} message="Perubahan Klien belum disimpan." />
      <ConfirmationDialog
        open={confirmOpen}
        title="Simpan perubahan lokal?"
        description="Tindakan ini tidak memanggil backend dan tidak mengubah database."
        confirmLabel="Simpan"
        onClose={() => setConfirmOpen(false)}
        onConfirm={saveLocal}
      />
      <StickyActionBar
        summary={<span>{dirty ? "Ada perubahan belum disimpan" : "Tidak ada perubahan lokal"}</span>}
        tertiary={{ label: "Kembali", href: "/fitness/clients" }}
        secondary={client ? { label: "Kelola Master Data", href: "/fitness/client-master-data/" + client.id + "?tab=summary" } : undefined}
        primary={{ label: "Simpan", icon: Save, type: "submit", form: "fitness-client-form", disabled: missingRequired || !dirty }}
      />
    </div>
  );
}

export function FitnessClientPicker({ clients, targetTab = "summary", targetSection }: { clients: FitnessClientSummary[]; targetTab?: string; targetSection?: string }) {
  const [filters, setFilters] = useState<Record<string, string>>({});
  const keyword = (filters.keyword ?? "").toLowerCase();
  const visible = clients.filter((client) => (!keyword || (client.name + " " + client.code).toLowerCase().includes(keyword)) && (!filters.status || client.status === filters.status));
  const fields: FilterBarField[] = [
    { id: "keyword", label: "Cari", type: "search", value: filters.keyword ?? "", placeholder: "Nama atau kode klien" },
    { id: "status", label: "Status", type: "select", value: filters.status ?? "", placeholder: "Semua status", options: [{ value: "Aktif", label: "Aktif" }, { value: "Tidak Aktif", label: "Tidak Aktif" }] }
  ];
  const columns: ResponsiveColumn<FitnessClientSummary>[] = [
    { key: "client", header: "Klien", render: (row) => <span><strong>{row.name}</strong><small className="client-cell-note">{row.code}</small></span> },
    { key: "locations", header: "Lokasi", render: (row) => row.locationCount },
    { key: "personnel", header: "Personel/PIC", render: (row) => row.personnelCount },
    { key: "types", header: "Jenis Peti Kemas", render: (row) => row.containerTypeCount },
    { key: "references", header: "Referensi", render: (row) => row.referenceCount },
    { key: "complete", header: "Kelengkapan", render: (row) => <StatusBadge tone={row.completeness === "Lengkap" ? "success" : "warning"}>{row.completeness}</StatusBadge> },
    { key: "action", header: "Aksi", render: (row) => <Link className="primary-button client-inline-action" href={masterHref(row.id, targetTab, targetSection)}>Kelola Master Data</Link> }
  ];

  return (
    <div className="page-stack">
      <ClientWorkspaceTabs activeHref="/fitness/client-master-data" />
      <PageHeader eyebrow="Klien & Master Data" title="Pilih Klien" description="Pilih klien terlebih dahulu agar seluruh data turunan tetap terisolasi." meta={<span>{clients.length} klien mock tersedia</span>} />
      <div className="client-isolation-notice"><Database size={18} /><span>Lokasi, personel, jenis peti kemas, referensi, dan mapping dimuat berdasarkan <strong>clientId</strong>.</span></div>
      <FilterBar fields={fields} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} onSubmit={() => undefined} />
      {visible.length ? <ResponsiveTableCards columns={columns} rows={visible} getRowId={(row) => row.id} getRowTitle={(row) => row.name} /> : <EmptyState title="Klien tidak ditemukan" description="Reset filter untuk memilih klien lain." />}
    </div>
  );
}

export type CompatibilityNoticeProps = {
  title: string;
  description: string;
  primary: { label: string; href: string };
  secondary?: { label: string; href: string };
  internalGift?: boolean;
};

export function FitnessMasterCompatibilityNotice({ title, description, primary, secondary, internalGift }: CompatibilityNoticeProps) {
  return (
    <div className="page-stack">
      <PageHeader eyebrow="Compatibility route" title={title} description={description} />
      <section className="workspace-panel compatibility-notice">
        <span className="compatibility-notice-icon">{internalGift ? <UserRoundCheck size={28} /> : <Building2 size={28} />}</span>
        <div>
          <StatusBadge tone="warning">Route lama dipertahankan</StatusBadge>
          <h2>Pilih konteks data yang benar</h2>
          <p>CRUD global lama tidak dijadikan workflow aktif pada UI-B.2. Data klien harus dibuka melalui clientId, sedangkan data personel internal tetap berada di konteks GIFT.</p>
          <div className="compatibility-actions">
            <Link className="primary-button" href={primary.href}>{primary.label}</Link>
            {secondary ? <Link className="secondary-button" href={secondary.href}>{secondary.label}</Link> : null}
          </div>
        </div>
      </section>
    </div>
  );
}

function TextField({ id, label, value, onChange, required, multiline, type = "text" }: { id: string; label: string; value: string; onChange: (value: string) => void; required?: boolean; multiline?: boolean; type?: string }) {
  return (
    <FormField id={id} label={label} required={required}>
      {multiline ? (
        <textarea id={id} rows={3} value={value} onChange={(event) => onChange(event.target.value)} required={required} />
      ) : (
        <input id={id} type={type} value={value} onChange={(event) => onChange(event.target.value)} required={required} />
      )}
    </FormField>
  );
}

function masterHref(clientId: string, tab: string, section?: string) {
  const query = new URLSearchParams({ tab });
  if (section) query.set("section", section);
  return "/fitness/client-master-data/" + clientId + "?" + query.toString();
}
