"use client";

import { Plus, Search } from "lucide-react";
import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { DataTable } from "@/components/ui/data-table";
import { CompletionBadge } from "@/components/ui/completion-badge";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { can } from "@/lib/permissions";

export type CustomerReadiness = {
  id: string;
  customer_code: string;
  customer_name: string;
  status: string;
  personnel_count: number;
  location_count: number;
  job_count: number;
  ready_count: number;
  total_checks: number;
  overall_ready: boolean;
  checks: Array<{ key: string; label: string; count: number; ready: boolean }>;
};

export function CustomerReadinessIndex() {
  const { accessToken, user } = useAuth();
  const [rows, setRows] = useState<CustomerReadiness[]>([]);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [readiness, setReadiness] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!accessToken) return;
    apiData<CustomerReadiness[]>("/customers/readiness", { accessToken })
      .then(setRows)
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Kelengkapan Customer gagal dimuat."))
      .finally(() => setLoading(false));
  }, [accessToken]);

  const filtered = useMemo(() => rows.filter((row) => {
    if (status && row.status !== status) return false;
    if (readiness === "ready" && !row.overall_ready) return false;
    if (readiness === "not-ready" && row.overall_ready) return false;
    const needle = search.trim().toLowerCase();
    return !needle || `${row.customer_code} ${row.customer_name}`.toLowerCase().includes(needle);
  }), [readiness, rows, search, status]);

  return <div className="page-stack">
    <PageHeader
      title="Customer & Master"
      description="Siapkan seluruh data Customer dari satu workspace sampai siap operasional. Persentase berasal dari readiness backend."
      action={can(user, "customers.create.all") ? { label: "Tambah Customer", icon: Plus, onClick: () => window.location.assign("/master/customers/create") } : undefined}
    />
    <div className="toolbar">
      <label className="search-box"><Search size={17} /><span className="sr-only">Cari Customer</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Cari nama atau kode Customer" /></label>
      <label className="field"><span>Status</span><select value={status} onChange={(event) => setStatus(event.target.value)}><option value="">Semua Status</option><option value="active">Aktif</option><option value="inactive">Tidak Aktif</option></select></label>
      <label className="field"><span>Kesiapan</span><select value={readiness} onChange={(event) => setReadiness(event.target.value)}><option value="">Semua Kesiapan</option><option value="ready">Customer Siap</option><option value="not-ready">Belum Siap</option></select></label>
    </div>
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    <DataTable responsiveCards rows={filtered} isLoading={loading} emptyText="Customer belum tersedia." columns={[
      { key: "name", header: "Customer", render: (row) => <><strong>{row.customer_name}</strong><br /><span className="muted-text">{row.customer_code}</span></> },
      { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "active" ? "success" : "warning"}>{row.status === "active" ? "Aktif" : "Tidak Aktif"}</StatusBadge> },
      { key: "setup", header: "Setup", render: (row) => <CompletionBadge complete={row.ready_count} total={row.total_checks} label="Setup" /> },
      { key: "readiness", header: "Kesiapan", render: (row) => <StatusBadge tone={row.overall_ready ? "success" : "warning"}>{row.overall_ready ? "Customer Siap" : "Belum Siap"}</StatusBadge> },
      { key: "missing", header: "Data Kurang", render: (row) => row.overall_ready ? <span className="muted-text">Tidak ada</span> : <span className="muted-text">{row.checks.filter((check) => !check.ready).map((check) => check.label).join(", ")}</span> },
      { key: "locations", header: "Location", render: (row) => row.location_count },
      { key: "personnel", header: "Personel/PIC", render: (row) => row.personnel_count },
      { key: "jobs", header: "Pekerjaan", render: (row) => row.job_count },
      { key: "action", header: "Aksi", render: (row) => <Link className="primary-button table-action" href={`/master/customers/customer/${row.id}`}>{row.overall_ready ? "Buka Customer" : "Lanjutkan Setup"}</Link> }
    ]} />
  </div>;
}

export function CustomerReadinessPanel({ customerId }: { customerId: string }) {
  const { accessToken } = useAuth();
  const [item, setItem] = useState<CustomerReadiness | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!accessToken) return;
    apiData<CustomerReadiness>(`/customers/${customerId}/readiness`, { accessToken })
      .then(setItem)
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Kelengkapan Customer gagal dimuat."));
  }, [accessToken, customerId]);

  if (error) return <div className="alert alert-danger" role="alert">{error}</div>;
  if (!item) return <div className="workspace-panel" role="status">Menghitung kelengkapan Master Data...</div>;

  return <section className="workspace-panel page-stack" aria-labelledby="customer-readiness-title">
    <div className="section-title-row"><div><h2 id="customer-readiness-title">Kelengkapan Master Data</h2><p className="muted-text">Perhitungan baca-saja dari data Customer yang tersimpan saat ini.</p></div><StatusBadge tone={item.overall_ready ? "success" : "warning"}>{item.overall_ready ? "SIAP" : "PERLU DILENGKAPI"}</StatusBadge></div>
    <div className="metric-grid inspection-summary-grid"><div className="metric-tile"><p>Pemeriksaan Siap</p><strong>{item.ready_count}</strong></div><div className="metric-tile"><p>Total Pemeriksaan</p><strong>{item.total_checks}</strong></div><div className="metric-tile"><p>Location Aktif</p><strong>{item.location_count}</strong></div><div className="metric-tile"><p>Personel/PIC Aktif</p><strong>{item.personnel_count}</strong></div></div>
    <div className="detail-grid">{item.checks.map((check) => <div key={check.key}><span>{check.label}</span><strong><StatusBadge tone={check.ready ? "success" : "warning"}>{check.ready ? `Siap (${check.count})` : "Belum siap"}</StatusBadge></strong></div>)}</div>
  </section>;
}
