"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { Building2, Eye, Pencil, Plus, Save, UserRoundCheck } from "lucide-react";
import { useRouter } from "next/navigation";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { FilterBar, type FilterBarField } from "@/components/ui/filter-bar";
import { FormField } from "@/components/ui/form-field";
import { FormSection } from "@/components/ui/form-section";
import { PageHeader } from "@/components/ui/page-header";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { SearchableSelect } from "@/components/ui/searchable-select";
import { StatusBadge } from "@/components/ui/status-badge";
import { StickyActionBar } from "@/components/ui/sticky-action-bar";
import { ToastFeedback } from "@/components/ui/toast-feedback";
import { UnsavedChangesGuard } from "@/components/ui/unsaved-changes-guard";
import type { FitnessClientDetail, FitnessClientSummary, FitnessMasterDataCategorySummary } from "@/types/fitness-admin";
import { customerCreateHref, masterDataDetailHref, masterDataIndexHref, type MasterDataRouteFamily } from "@/constants/fitness-master-data-client-first";
import { CustomerMasterDataOverview } from "./customer-master-data-overview";

export function FitnessClientsList({ initialClients, routeFamily = "fitness" }: { initialClients: FitnessClientSummary[]; routeFamily?: MasterDataRouteFamily }) {
  const router = useRouter();
  const customerBase = masterDataIndexHref("customer", routeFamily);
  const [clients, setClients] = useState(initialClients);
  const [filters, setFilters] = useState<Record<string, string>>({});
  const [pendingClient, setPendingClient] = useState<FitnessClientSummary | null>(null);
  const [toast, setToast] = useState<string | null>(null);

  const fields: FilterBarField[] = [
    { id: "keyword", label: "Cari", type: "search", value: filters.keyword ?? "", placeholder: "Nama atau kode Customer" },
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
    { key: "code", header: "Kode Customer", render: (row) => <strong>{row.code}</strong> },
    {
      key: "name",
      header: "Perusahaan/Organisasi",
      render: (row) => <span><strong>{row.name}</strong><small className="client-cell-note">{row.addressShort}</small></span>
    },
    { key: "pic", header: "PIC Utama", render: (row) => <span>{row.primaryContactName}<small className="client-cell-note">{row.email}<br />{row.phone}</small></span> },
    { key: "locations", header: "Location Customer", render: (row) => row.locationCount },
    { key: "containers", header: "Peti Kemas", render: (row) => row.containerCount },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "Aktif" ? "success" : "neutral"}>{row.status}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: (row) => row.updatedAt },
    {
      key: "actions",
      header: "Aksi",
      render: (row) => (
        <div className="client-row-actions">
          <Link className="icon-button" href={masterDataDetailHref("customer", row.id, routeFamily)} aria-label={"Lihat detail " + row.name} title="Lihat detail"><Eye size={16} /></Link>
          <Link className="icon-button" href={masterDataDetailHref("customer", row.id, routeFamily)} aria-label={"Edit " + row.name} title="Edit"><Pencil size={16} /></Link>
          <Link className="secondary-button client-inline-action" href={masterDataDetailHref("customer", row.id, routeFamily)}>Buka Ringkasan Master Data</Link>
          <button aria-label={"Nonaktifkan " + row.name} className="secondary-button client-inline-action" disabled={row.status !== "Aktif"} onClick={() => setPendingClient(row)} type="button">Nonaktifkan</button>
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
      <PageHeader
        eyebrow="Klien & Master Data"
        title="Customer"
        description="Customer adalah perusahaan atau organisasi pengguna jasa inspeksi GIFT."
        meta={<span>{visibleClients.length} dari {clients.length} Customer ditampilkan</span>}
        action={{ label: "Tambah Customer", icon: Plus, onClick: () => router.push(customerCreateHref(routeFamily)) }}
      />
      <FilterBar
        fields={fields}
        onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))}
        onReset={() => setFilters({})}
      />
      {visibleClients.length > 0 ? (
        <ResponsiveTableCards columns={columns} rows={visibleClients} getRowId={(row) => row.id} getRowTitle={(row) => row.name} label="Daftar Customer" pageSize={10} />
      ) : (
        <EmptyState title="Customer tidak ditemukan" description="Ubah pencarian atau reset filter untuk menampilkan data." />
      )}
      {toast ? <ToastFeedback title="Perubahan lokal berhasil" description={toast} tone="success" onDismiss={() => setToast(null)} /> : null}
      <ConfirmationDialog
        open={Boolean(pendingClient)}
        title="Nonaktifkan Customer?"
        description="Perubahan hanya berlaku pada state lokal frontend dan akan kembali setelah halaman dimuat ulang."
        confirmLabel="Nonaktifkan"
        tone="danger"
        onClose={() => setPendingClient(null)}
        onConfirm={confirmDeactivate}
      />
    </div>
  );
}

export function FitnessClientForm({
  client,
  overview = [],
  routeFamily = "fitness"
}: {
  client?: FitnessClientDetail;
  overview?: FitnessMasterDataCategorySummary[];
  routeFamily?: MasterDataRouteFamily;
}) {
  const isEdit = Boolean(client);
  const customerBase = masterDataIndexHref("customer", routeFamily);
  const readOnly = client?.status === "Tidak Aktif";
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
  const invalidEmail = Boolean(form.email.trim()) && !isValidEmail(form.email);
  const formInvalid = missingRequired || invalidEmail;

  function update(field: keyof typeof form, value: string) {
    if (readOnly) return;
    setForm((current) => ({ ...current, [field]: value }));
    setDirty(true);
  }

  function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!formInvalid && !readOnly) setConfirmOpen(true);
  }

  function saveLocal() {
    if (readOnly) return;
    setDirty(false);
    setConfirmOpen(false);
    setToastOpen(true);
  }

  return (
    <div className="page-stack">
      <PageHeader
        eyebrow={isEdit ? client?.code : "Customer baru"}
        title={isEdit ? "Detail dan Edit Customer" : "Tambah Customer"}
        description="Form frontend-only. Tidak ada data yang dikirim ke backend."
        meta={client ? <StatusBadge tone={client.status === "Aktif" ? "success" : "neutral"}>{client.status}</StatusBadge> : undefined}
      />
      {readOnly ? <div className="alert alert-warning" role="alert">Customer tidak aktif. Profil dan Master Data hanya dapat dilihat.</div> : null}
      {client && overview.length ? (
        <CustomerMasterDataOverview
          clientId={client.id}
          customerName={client.name}
          items={overview}
          onEdit={() => document.getElementById("client-code")?.focus()}
          routeFamily={routeFamily}
          readOnly={readOnly}
        />
      ) : null}
      <form id="fitness-client-form" onSubmit={submit}>
        <fieldset className="client-readonly-fieldset" disabled={readOnly}>
        <FormSection title="Identitas" description="Kode dan identitas perusahaan atau organisasi Customer.">
          <TextField id="client-code" label="Kode Customer" value={form.code} onChange={(value) => update("code", value)} required />
          <TextField id="client-name" label="Nama Perusahaan/Organisasi" value={form.name} onChange={(value) => update("name", value)} required />
          <TextField id="client-short-name" label="Nama Singkat" value={form.shortName} onChange={(value) => update("shortName", value)} />
          <FormField id="client-status" label="Status" required helpText="Status hanya mengubah state lokal pada tahap ini.">
            <SearchableSelect
              id="client-status"
              label="Status"
              showLabel={false}
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
          <TextField id="client-email" label="Email" type="email" value={form.email} onChange={(value) => update("email", value)} error={invalidEmail ? "Gunakan format email yang valid." : undefined} required />
          <TextField id="client-phone" label="Telepon" value={form.phone} onChange={(value) => update("phone", value)} />
        </FormSection>
        <FormSection title="Catatan">
          <TextField id="client-notes" label="Catatan Admin" value={form.adminNotes} onChange={(value) => update("adminNotes", value)} multiline />
          <TextField id="client-access" label="Informasi Akses" value={form.accessInformation} onChange={(value) => update("accessInformation", value)} multiline />
        </FormSection>
        </fieldset>
      </form>
      {formInvalid && dirty ? <div className="alert alert-warning" role="alert">{invalidEmail ? "Perbaiki format email sebelum menyimpan." : "Lengkapi Kode Customer, nama, PIC utama, dan email sebelum menyimpan."}</div> : null}
      {toastOpen ? <ToastFeedback title="Data tersimpan di tampilan" description="Perubahan lokal akan kembali ke mock awal setelah reload." tone="success" onDismiss={() => setToastOpen(false)} /> : null}
      <UnsavedChangesGuard active={dirty} message="Perubahan Customer belum disimpan." />
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
        tertiary={{ label: "Kembali", href: customerBase }}
        primary={{ label: "Simpan", icon: Save, type: "submit", form: "fitness-client-form", disabled: readOnly || formInvalid || !dirty }}
      />
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
          <p>CRUD global lama tidak dijadikan workflow aktif. Data Customer harus dibuka melalui clientId, sedangkan personel internal tetap berada di konteks GIFT.</p>
          <div className="compatibility-actions">
            <Link className="primary-button" href={primary.href}>{primary.label}</Link>
            {secondary ? <Link className="secondary-button" href={secondary.href}>{secondary.label}</Link> : null}
          </div>
        </div>
      </section>
    </div>
  );
}

function TextField({ id, label, value, onChange, required, multiline, type = "text", error }: { id: string; label: string; value: string; onChange: (value: string) => void; required?: boolean; multiline?: boolean; type?: string; error?: string }) {
  return (
    <FormField error={error} id={id} label={label} required={required}>
      {multiline ? (
        <textarea aria-describedby={error ? id + "-error" : undefined} aria-invalid={Boolean(error)} id={id} rows={3} value={value} onChange={(event) => onChange(event.target.value)} required={required} />
      ) : (
        <input aria-describedby={error ? id + "-error" : undefined} aria-invalid={Boolean(error)} id={id} type={type} value={value} onChange={(event) => onChange(event.target.value)} required={required} />
      )}
    </FormField>
  );
}

function isValidEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim());
}
