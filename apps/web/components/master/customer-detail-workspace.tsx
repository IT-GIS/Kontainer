"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { ChecklistReferenceTab } from "@/components/master/checklist-reference-tab";
import { CustomerReadinessPanel, type CustomerReadiness } from "@/components/master/customer-readiness";
import { CustomerScopedMasterDetail, SurveyTypeReferenceConfiguration } from "@/components/master/customer-scoped-master-data";
import { CustomerSetupStepper, type CustomerSetupTab } from "@/components/master/customer-setup-stepper";
import { MasterSourceSelector } from "@/components/master/master-source-selector";
import type { IsoCedexTab } from "@/components/master/iso-cedex-workspace";
import { MasterDataPage } from "@/components/master/master-data-page";
import { PersonnelLocationMapping } from "@/components/master/personnel-location-mapping";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { NextActionCard } from "@/components/workflow/next-action-card";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import { jobStatusLabel } from "@/lib/status-labels";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";
import type { JobSummary } from "@/types/jobs";

type CustomerRecord = {
  id: string;
  customer_code: string;
  customer_name: string;
  address?: string | null;
  npwp?: string | null;
  pic_name?: string | null;
  pic_phone?: string | null;
  pic_email?: string | null;
  billing_address?: string | null;
  payment_term_days?: number | null;
  status: string;
};

const cedexTabs: Array<{ id: IsoCedexTab; label: string; category: FitnessMasterDataCategory }> = [
  { id: "location", label: "Location", category: "cedex-location" },
  { id: "component", label: "Component", category: "cedex-component" },
  { id: "damage", label: "Damage", category: "cedex-damage" },
  { id: "action", label: "Repair / Action", category: "cedex-action" },
  { id: "material", label: "Material", category: "cedex-material" }
];

export function CustomerDetailWorkspace({
  customerId,
  activeTab,
  cedexSection
}: {
  customerId: string;
  activeTab: CustomerSetupTab;
  cedexSection: IsoCedexTab;
}) {
  const { accessToken } = useAuth();
  const [customer, setCustomer] = useState<CustomerRecord | null>(null);
  const [readiness, setReadiness] = useState<CustomerReadiness | null>(null);
  const [jobs, setJobs] = useState<JobSummary[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      if (!accessToken) return;
      setLoading(true);
      Promise.all([
        apiData<CustomerRecord>(`/master/customers/${customerId}`, { accessToken }),
        apiData<CustomerReadiness>(`/customers/${customerId}/readiness`, { accessToken }),
        apiPaginated<JobSummary>(`/jobs?page=1&per_page=100&customer_id=${customerId}`, { accessToken })
      ])
        .then(([customerResult, readinessResult, jobResult]) => {
          setCustomer(customerResult);
          setReadiness(readinessResult);
          setJobs(jobResult.rows.filter((job) => job.customer_id === customerId));
        })
        .catch((cause) => setError(cause instanceof Error ? cause.message : "Setup Customer gagal dimuat."))
        .finally(() => setLoading(false));
    }, 0);
    return () => window.clearTimeout(timer);
  }, [accessToken, customerId]);

  const lastJob = useMemo(
    () => jobs.reduce<JobSummary | null>((latest, job) => !latest || new Date(job.updated_at ?? job.created_at).getTime() > new Date(latest.updated_at ?? latest.created_at).getTime() ? job : latest, null),
    [jobs]
  );

  if (loading) return <div className="workspace-panel" role="status">Memuat setup Customer...</div>;
  if (!customer) return <div className="alert alert-danger">{error ?? "Customer tidak ditemukan."}</div>;

  const baseHref = `/master/customers/customer/${customerId}`;
  return (
    <div className="page-stack customer-detail-workspace">
      <PageHeader
        eyebrow="Customer & Master"
        title={customer.customer_name}
        description={`Customer ${customer.customer_code} - setup operasional, master efektif, dan langkah berikutnya.`}
        meta={<StatusBadge tone={readiness?.overall_ready ? "success" : "warning"}>{readiness?.overall_ready ? "Customer Siap" : "Belum Siap"}</StatusBadge>}
      />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <CustomerSetupStepper activeTab={activeTab} customerId={customerId} readiness={readiness} />

      {activeTab === "profile" ? <CustomerProfile customer={customer} jobs={jobs} lastJob={lastJob} onSaved={setCustomer} nextHref={`${baseHref}?tab=location-pic`} /> : null}
      {activeTab === "location-pic" ? <LocationAndPic customer={customer} customerId={customerId} /> : null}
      {activeTab === "survey-type" ? <CustomerScopedMasterDetail category="survey-type" customerId={customerId} hideBackLink routeFamily="actual" showReferenceConfiguration={false} /> : null}
      {activeTab === "container-type" ? <CustomerScopedMasterDetail category="container-type" customerId={customerId} hideBackLink routeFamily="actual" /> : null}
      {activeTab === "checklist" ? <ChecklistReferenceTab baseHref={`${baseHref}?tab=checklist`} customerId={customerId} /> : null}
      {activeTab === "cedex" ? <CustomerCedexSetup baseHref={baseHref} customerId={customerId} section={cedexSection} /> : null}
      {activeTab === "references" ? <ReferenceSetup customer={customer} customerId={customerId} mode="references" /> : null}
      {activeTab === "photo-evidence" ? <ReferenceSetup customer={customer} customerId={customerId} mode="photos" /> : null}
      {activeTab === "readiness" ? <ReadinessStep baseHref={baseHref} customer={customer} customerId={customerId} readiness={readiness} /> : null}
    </div>
  );
}

function CustomerProfile({
  customer,
  jobs,
  lastJob,
  onSaved,
  nextHref
}: {
  customer: CustomerRecord;
  jobs: JobSummary[];
  lastJob: JobSummary | null;
  onSaved: (customer: CustomerRecord) => void;
  nextHref: string;
}) {
  const { accessToken, user } = useAuth();
  const router = useRouter();
  const editable = can(user, "customers.update.all");
  const [form, setForm] = useState(() => customerForm(customer));
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  async function saveAndContinue() {
    if (!accessToken || !editable) return;
    if (!form.customer_code.trim() || !form.customer_name.trim()) {
      setMessage("Kode dan Nama Customer wajib diisi.");
      return;
    }
    setSaving(true);
    setMessage(null);
    try {
      const updated = await apiData<CustomerRecord>(`/master/customers/${customer.id}`, {
        method: "PUT",
        accessToken,
        body: JSON.stringify({
          ...form,
          payment_term_days: form.payment_term_days === "" ? null : Number(form.payment_term_days)
        })
      });
      onSaved(updated);
      router.push(nextHref);
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : "Profil Customer gagal disimpan.");
    } finally {
      setSaving(false);
    }
  }

  return <div className="page-stack">
    <section className="workspace-panel page-stack" aria-labelledby="customer-profile-title">
      <div className="section-title-row"><div><h2 id="customer-profile-title">Profil Customer</h2><p className="muted-text">Informasi existing disimpan melalui endpoint Customer yang sama.</p></div><StatusBadge tone={customer.status === "active" ? "success" : "warning"}>{customer.status === "active" ? "Aktif" : "Tidak Aktif"}</StatusBadge></div>
      {!editable ? <div className="alert alert-warning">Mode baca-saja. Permission perubahan Customer tidak tersedia.</div> : null}
      {message ? <div className="alert alert-danger" role="alert">{message}</div> : null}
      <div className="form-grid form-grid-wide">
        <Field label="Kode Customer"><input disabled={!editable} value={form.customer_code} onChange={(event) => setForm((current) => ({ ...current, customer_code: event.target.value.toUpperCase() }))} /></Field>
        <Field label="Nama Customer"><input disabled={!editable} value={form.customer_name} onChange={(event) => setForm((current) => ({ ...current, customer_name: event.target.value }))} /></Field>
        <Field label="Status"><select disabled={!editable} value={form.status} onChange={(event) => setForm((current) => ({ ...current, status: event.target.value }))}><option value="active">Aktif</option><option value="inactive">Tidak Aktif</option></select></Field>
        <label className="field form-span-2"><span>Alamat</span><textarea disabled={!editable} rows={3} value={form.address} onChange={(event) => setForm((current) => ({ ...current, address: event.target.value }))} /></label>
        <Field label="NPWP"><input disabled={!editable} value={form.npwp} onChange={(event) => setForm((current) => ({ ...current, npwp: event.target.value }))} /></Field>
        <Field label="Kontak Utama"><input disabled={!editable} value={form.pic_name} onChange={(event) => setForm((current) => ({ ...current, pic_name: event.target.value }))} /></Field>
        <Field label="Telepon Kontak"><input disabled={!editable} type="tel" value={form.pic_phone} onChange={(event) => setForm((current) => ({ ...current, pic_phone: event.target.value }))} /></Field>
        <Field label="Email Kontak"><input disabled={!editable} type="email" value={form.pic_email} onChange={(event) => setForm((current) => ({ ...current, pic_email: event.target.value }))} /></Field>
        <label className="field form-span-2"><span>Alamat Penagihan</span><textarea disabled={!editable} rows={2} value={form.billing_address} onChange={(event) => setForm((current) => ({ ...current, billing_address: event.target.value }))} /></label>
        <Field label="Termin Pembayaran (hari)"><input disabled={!editable} min="0" type="number" value={form.payment_term_days} onChange={(event) => setForm((current) => ({ ...current, payment_term_days: event.target.value }))} /></Field>
      </div>
      {editable ? <div className="job-actions"><button className="primary-button" disabled={saving} onClick={() => void saveAndContinue()} type="button">{saving ? "Menyimpan..." : "Simpan & Lanjut"}</button></div> : <Link className="primary-button" href={nextHref}>Lanjut ke Lokasi & PIC</Link>}
    </section>
    <CustomerJobHistory jobs={jobs} lastJob={lastJob} />
  </div>;
}

function LocationAndPic({ customer, customerId }: { customer: CustomerRecord; customerId: string }) {
  const readOnly = customer.status !== "active";
  return <div className="page-stack">
    <PageHeader title="Lokasi & PIC" description="Location, Personel/PIC, dan mapping aktif terlihat dalam satu tahap." />
    <MasterDataPage endpointOverride={`/customers/${customerId}/locations`} fixedValues={{ customer_id: customerId }} resourceId="locations" readOnly={readOnly} readOnlyMessage="Customer tidak aktif. Location hanya dapat dilihat." />
    <MasterDataPage endpointOverride={`/customers/${customerId}/personnel`} fixedValues={{ customer_id: customerId }} resourceId="customer-personnel" readOnly={readOnly} readOnlyMessage="Customer tidak aktif. Personel/PIC hanya dapat dilihat." />
    <PersonnelLocationMapping customerId={customerId} readOnly={readOnly} />
  </div>;
}

function CustomerCedexSetup({ customerId, baseHref, section }: { customerId: string; baseHref: string; section: IsoCedexTab }) {
  const active = cedexTabs.find((tab) => tab.id === section) ?? cedexTabs[0];
  return <div className="page-stack">
    <MasterSourceSelector title="Sumber Master CEDEX" note="Backend effective-master memprioritaskan override Customer aktif dan memakai Global fallback tanpa menduplikasi seluruh master." />
    <WorkspaceTabs activeID={section} label="Master CEDEX Customer" tabs={cedexTabs.map((tab) => ({ id: tab.id, label: tab.label, href: `${baseHref}?tab=cedex&section=${tab.id}` }))} />
    <CustomerScopedMasterDetail category={active.category} customerId={customerId} hideBackLink routeFamily="actual" />
  </div>;
}

function ReferenceSetup({ customer, customerId, mode }: { customer: CustomerRecord; customerId: string; mode: "references" | "photos" }) {
  const photos = mode === "photos";
  return <div className="page-stack">
    <MasterSourceSelector
      title={photos ? "Foto / Evidence" : "Referensi Pemeriksaan"}
      customerLabel="Mapping Customer"
      globalLabel="Master Global"
      note={photos ? "Kategori yang ditampilkan berasal dari active master existing; UI tidak menambahkan requirement foto baru." : "Survey Type memetakan referensi aktif existing; standard, clause, dan rule tidak dibuat secara fiktif."}
    />
    <SurveyTypeReferenceConfiguration customerId={customerId} readOnly={customer.status !== "active"} visibleGroups={photos ? ["photo_categories"] : ["finding_severities", "test_parameters"]} />
  </div>;
}

function ReadinessStep({ baseHref, customer, customerId, readiness }: { baseHref: string; customer: CustomerRecord; customerId: string; readiness: CustomerReadiness | null }) {
  const nextTab = firstIncompleteTab(readiness);
  return <div className="page-stack">
    <CustomerReadinessPanel customerId={customerId} />
    {readiness?.overall_ready ? <NextActionCard title="Customer siap operasional" description={`Seluruh pemeriksaan readiness backend untuk ${customer.customer_name} sudah terpenuhi.`} actionLabel={`Buat Pekerjaan untuk ${customer.customer_name}`} href={`/jobs/create?customerId=${customerId}`} /> : <NextActionCard title="Lengkapi setup Customer" description={`${readiness?.checks.filter((check) => !check.ready).length ?? 0} pemeriksaan backend masih perlu dilengkapi.`} actionLabel="Buka data yang belum lengkap" href={`${baseHref}?tab=${nextTab}`} />}
  </div>;
}

function CustomerJobHistory({ jobs, lastJob }: { jobs: JobSummary[]; lastJob: JobSummary | null }) {
  const active = jobs.filter((job) => !["completed", "closed", "cancelled", "report_generated"].includes(job.status)).length;
  const completed = jobs.filter((job) => ["completed", "closed", "report_generated", "all_survey_approved", "all_survey_decided"].includes(job.status)).length;
  return <section className="workspace-panel page-stack">
    <div className="section-title-row"><div><h2>Riwayat Pekerjaan</h2><p className="muted-text">Riwayat tetap tersedia di workspace Customer tanpa menambah tahap setup.</p></div></div>
    <div className="metric-grid inspection-summary-grid"><Metric label="Jumlah Pekerjaan" value={jobs.length} /><Metric label="Pekerjaan Aktif" value={active} /><Metric label="Pemeriksaan Selesai" value={completed} /><Metric label="Terakhir Diperiksa" value={lastJob ? formatDate(lastJob.updated_at ?? lastJob.created_at) : "-"} /></div>
    <DataTable responsiveCards rows={jobs} emptyText="Riwayat pekerjaan Customer belum tersedia." columns={[
      { key: "number", header: "Nomor Pekerjaan", render: (row) => <Link className="text-link" href={`/jobs/${row.id}`}>{row.job_order_no}</Link> },
      { key: "date", header: "Tanggal", render: (row) => formatDate(row.job_date) },
      { key: "location", header: "Location", render: (row) => row.location_name },
      { key: "type", header: "Survey Type", render: (row) => row.survey_type_name },
      { key: "containers", header: "Peti Kemas", render: (row) => row.total_containers },
      { key: "status", header: "Status", render: (row) => <StatusBadge tone={completedStatus(row.status) ? "success" : "warning"}>{jobStatusLabel(row.status)}</StatusBadge> }
    ]} />
  </section>;
}

function customerForm(customer: CustomerRecord) {
  return {
    customer_code: customer.customer_code,
    customer_name: customer.customer_name,
    address: customer.address ?? "",
    npwp: customer.npwp ?? "",
    pic_name: customer.pic_name ?? "",
    pic_phone: customer.pic_phone ?? "",
    pic_email: customer.pic_email ?? "",
    billing_address: customer.billing_address ?? "",
    payment_term_days: customer.payment_term_days == null ? "" : String(customer.payment_term_days),
    status: customer.status
  };
}

function firstIncompleteTab(readiness: CustomerReadiness | null): CustomerSetupTab {
  if (!readiness) return "profile";
  const missing = new Set(readiness.checks.filter((check) => !check.ready).map((check) => check.key));
  if (missing.has("profile")) return "profile";
  if (missing.has("personnel") || missing.has("location")) return "location-pic";
  if (missing.has("survey_type")) return "survey-type";
  if (missing.has("container_type")) return "container-type";
  if (missing.has("checklist_template") || missing.has("checklist_item")) return "checklist";
  if (["cedex_location", "cedex_component", "cedex_damage", "cedex_action_repair", "cedex_material", "responsibility"].some((key) => missing.has(key))) return "cedex";
  if (missing.has("test_parameter_mapping") || missing.has("severity_mapping")) return "references";
  if (missing.has("photo_category_mapping")) return "photo-evidence";
  return "readiness";
}

function Field({ label, children }: { label: string; children: React.ReactNode }) { return <label className="field"><span>{label}</span>{children}</label>; }
function Metric({ label, value }: { label: string; value: string | number }) { return <div className="metric-tile"><p>{label}</p><strong>{value}</strong></div>; }
function formatDate(value: string) { const date = new Date(value); return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium" }).format(date); }
function completedStatus(status: string) { return ["completed", "closed", "report_generated", "all_survey_approved", "all_survey_decided"].includes(status); }
