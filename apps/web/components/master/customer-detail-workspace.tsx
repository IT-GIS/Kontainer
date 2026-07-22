"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { MasterDataPage } from "@/components/master/master-data-page";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated } from "@/lib/api-client";
import type { JobSummary } from "@/types/jobs";

export type CustomerDetailTab = "profile" | "personnel" | "location" | "history";

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

const tabLabels: Array<{ id: CustomerDetailTab; label: string }> = [
  { id: "profile", label: "Profil Customer" },
  { id: "personnel", label: "Personel/PIC" },
  { id: "location", label: "Location Pemeriksaan" },
  { id: "history", label: "Riwayat Pekerjaan" }
];

export function CustomerDetailWorkspace({ customerId, activeTab }: { customerId: string; activeTab: CustomerDetailTab }) {
  const { accessToken } = useAuth();
  const [customer, setCustomer] = useState<CustomerRecord | null>(null);
  const [jobs, setJobs] = useState<JobSummary[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!accessToken) return;
    setLoading(true);
    Promise.all([
      apiData<CustomerRecord>("/master/customers/" + customerId, { accessToken }),
      apiPaginated<JobSummary>("/jobs?page=1&per_page=100&customer_id=" + customerId, { accessToken })
    ])
      .then(([customerResult, jobResult]) => {
        setCustomer(customerResult);
        setJobs(jobResult.rows.filter((job) => job.customer_id === customerId));
      })
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Detail Customer gagal dimuat."))
      .finally(() => setLoading(false));
  }, [accessToken, customerId]);

  const lastJob = useMemo(
    () => jobs.reduce<JobSummary | null>((latest, job) => !latest || new Date(job.updated_at ?? job.created_at).getTime() > new Date(latest.updated_at ?? latest.created_at).getTime() ? job : latest, null),
    [jobs]
  );

  if (loading) return <div className="workspace-panel" role="status">Memuat detail Customer...</div>;
  if (!customer) return <div className="alert alert-danger">{error ?? "Customer tidak ditemukan."}</div>;

  const baseHref = "/master/customers/customer/" + customerId;
  return (
    <div className="page-stack customer-detail-workspace">
      <PageHeader title={customer.customer_name} description={"Customer " + customer.customer_code + " - data pendukung pekerjaan inspeksi."} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <WorkspaceTabs
        activeID={activeTab}
        label="Detail Customer"
        tabs={tabLabels.map((tab) => ({ id: tab.id, label: tab.label, href: baseHref + "?tab=" + tab.id }))}
      />
      {activeTab === "profile" ? <CustomerProfile customer={customer} /> : null}
      {activeTab === "personnel" ? (
        <MasterDataPage
          backHref="/master/customers"
          endpointOverride={"/customers/" + customerId + "/personnel"}
          fixedValues={{ customer_id: customerId }}
          resourceId="customer-personnel"
        />
      ) : null}
      {activeTab === "location" ? (
        <MasterDataPage
          backHref="/master/customers"
          endpointOverride={"/customers/" + customerId + "/locations"}
          fixedValues={{ customer_id: customerId }}
          resourceId="locations"
        />
      ) : null}
      {activeTab === "history" ? <CustomerJobHistory jobs={jobs} lastJob={lastJob} /> : null}
    </div>
  );
}

function CustomerProfile({ customer }: { customer: CustomerRecord }) {
  const fields = [
    ["Kode Customer", customer.customer_code],
    ["Nama Customer", customer.customer_name],
    ["Alamat", customer.address],
    ["NPWP", customer.npwp],
    ["PIC Utama", customer.pic_name],
    ["Telepon PIC", customer.pic_phone],
    ["Email PIC", customer.pic_email],
    ["Alamat Penagihan", customer.billing_address],
    ["Termin Pembayaran", customer.payment_term_days == null ? null : customer.payment_term_days + " hari"]
  ];
  return (
    <section className="workspace-panel page-stack" aria-labelledby="customer-profile-title">
      <div className="section-title-row"><div><h2 id="customer-profile-title">Profil Customer</h2><p className="muted-text">Field existing tetap menjadi sumber profil.</p></div><StatusBadge tone={customer.status === "active" ? "success" : "warning"}>{customer.status === "active" ? "Aktif" : "Tidak Aktif"}</StatusBadge></div>
      <div className="detail-grid">{fields.map(([label, value]) => <div key={String(label)}><span>{label}</span><strong>{value || "Belum tersedia"}</strong></div>)}</div>
      <Link className="secondary-button" href="/master/customers">Kelola Data Customer</Link>
    </section>
  );
}

function CustomerJobHistory({ jobs, lastJob }: { jobs: JobSummary[]; lastJob: JobSummary | null }) {
  const active = jobs.filter((job) => !["completed", "cancelled"].includes(job.status)).length;
  const completed = jobs.filter((job) => job.status === "completed").length;
  return (
    <div className="page-stack">
      <section className="metric-grid inspection-summary-grid" aria-label="Ringkasan riwayat pekerjaan">
        <Metric label="Jumlah Pekerjaan" value={jobs.length} />
        <Metric label="Pekerjaan Aktif" value={active} />
        <Metric label="Pemeriksaan Selesai" value={completed} />
        <Metric label="Terakhir Diperiksa" value={lastJob ? formatDate(lastJob.updated_at ?? lastJob.created_at) : "-"} />
      </section>
      <DataTable rows={jobs} emptyText="Riwayat pekerjaan Customer belum tersedia." columns={[
        { key: "number", header: "Nomor Pekerjaan", render: (row) => <Link className="text-link" href={"/jobs/" + row.id}>{row.job_order_no}</Link> },
        { key: "date", header: "Tanggal", render: (row) => formatDate(row.job_date) },
        { key: "location", header: "Location", render: (row) => row.location_name },
        { key: "type", header: "Survey Type", render: (row) => row.survey_type_name },
        { key: "containers", header: "Peti Kemas", render: (row) => row.total_containers },
        { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "completed" ? "success" : "warning"}>{humanize(row.status)}</StatusBadge> }
      ]} />
    </div>
  );
}

function Metric({ label, value }: { label: string; value: string | number }) {
  return <div className="metric-tile"><p>{label}</p><strong>{value}</strong></div>;
}
function formatDate(value: string) {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : new Intl.DateTimeFormat("id-ID", { dateStyle: "medium" }).format(date);
}
function humanize(value: string) {
  return value.replaceAll("_", " ").replaceAll("-", " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}
