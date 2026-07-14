"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { Eye, Plus } from "lucide-react";
import { CompletionBadge } from "@/components/ui/completion-badge";
import { EmptyState } from "@/components/ui/empty-state";
import { FilterBar, type FilterBarField } from "@/components/ui/filter-bar";
import { PageHeader } from "@/components/ui/page-header";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { StatusBadge } from "@/components/ui/status-badge";
import type { FitnessApplicationSummary, FitnessClientSummary } from "@/types/fitness-admin";

export function FitnessApplicationsList({ applications, clients, initialFilters = {} }: { applications: FitnessApplicationSummary[]; clients: FitnessClientSummary[]; initialFilters?: Record<string, string> }) {
  const [filters, setFilters] = useState<Record<string, string>>(initialFilters);
  const locationOptions = useMemo(() => {
    const rows = filters.clientId ? applications.filter((item) => item.clientId === filters.clientId) : applications;
    return Array.from(new Map(rows.map((item) => [item.locationId, item.locationName])).entries()).map(([value, label]) => ({ value, label }));
  }, [applications, filters.clientId]);
  const stages = Array.from(new Set(applications.map((item) => item.processStage))).map((value) => ({ value, label: value }));
  const statuses = Array.from(new Set(applications.map((item) => item.status))).map((value) => ({ value, label: value }));

  const fields: FilterBarField[] = [
    { id: "keyword", label: "Pencarian", type: "search", value: filters.keyword ?? "", placeholder: "Nomor, klien, pemohon, atau pemilik/pengguna" },
    { id: "clientId", label: "Klien", type: "select", value: filters.clientId ?? "", placeholder: "Seluruh klien", options: clients.map((client) => ({ value: client.id, label: client.name })) },
    { id: "status", label: "Status", type: "select", value: filters.status ?? "", placeholder: "Seluruh status", options: statuses },
    { id: "date", label: "Tanggal", type: "date-range", value: filters.date ?? "", endValue: filters.dateEnd ?? "" },
    { id: "locationId", label: "Lokasi", type: "select", value: filters.locationId ?? "", placeholder: "Seluruh lokasi", options: locationOptions },
    { id: "stage", label: "Tahap Proses", type: "select", value: filters.stage ?? "", placeholder: "Seluruh tahap", options: stages }
  ];

  const visible = applications.filter((item) => {
    const keyword = (filters.keyword ?? "").trim().toLowerCase();
    const searchable = [item.applicationNumber, item.clientName, item.applicantName, item.ownerUserName, item.locationName].join(" ").toLowerCase();
    return (!keyword || searchable.includes(keyword))
      && (!filters.clientId || item.clientId === filters.clientId)
      && (!filters.status || item.status === filters.status)
      && (!filters.locationId || item.locationId === filters.locationId)
      && (!filters.stage || item.processStage === filters.stage)
      && (!filters.date || item.applicationDate >= filters.date)
      && (!filters.dateEnd || item.applicationDate <= filters.dateEnd);
  });

  const columns: ResponsiveColumn<FitnessApplicationSummary>[] = [
    { key: "number", header: "Nomor Permohonan", render: (row) => <span><strong>{row.applicationNumber}</strong><small className="client-cell-note">{row.status}</small></span> },
    { key: "date", header: "Tanggal", render: (row) => row.applicationDate },
    { key: "client", header: "Klien", render: (row) => row.clientName },
    { key: "applicant", header: "Pemohon", render: (row) => row.applicantName },
    { key: "owner", header: "Pemilik/Pengguna Peti Kemas", render: (row) => row.ownerUserName },
    { key: "location", header: "Lokasi", render: (row) => row.locationName },
    { key: "containers", header: "Jumlah Peti Kemas", render: (row) => row.containerCount },
    { key: "complete", header: "Kelengkapan", render: (row) => <CompletionBadge complete={row.completeness.complete} total={row.completeness.total} /> },
    { key: "stage", header: "Tahap Proses", render: (row) => <StatusBadge tone={stageTone(row.status)}>{row.processStage}</StatusBadge> },
    { key: "updated", header: "Pembaruan Terakhir", render: (row) => row.updatedAt },
    { key: "action", header: "Aksi", render: (row) => <Link className="icon-button" href={"/fitness/applications/" + row.id} aria-label={"Lihat detail " + row.applicationNumber}><Eye size={16} /></Link> }
  ];

  return (
    <div className="page-stack">
      <PageHeader
        eyebrow="Permohonan"
        title="Daftar Permohonan"
        description="Pantau permohonan berdasarkan klien, kelengkapan, dan tahap proses."
        meta={<span>{visible.length} dari {applications.length} permohonan ditampilkan</span>}
        action={{ label: "Buat Permohonan", icon: Plus, href: "/fitness/applications/create" }}
      />
      <FilterBar
        fields={fields}
        onChange={(id, value, endValue) => setFilters((current) => ({ ...current, [id]: value, ...(endValue !== undefined ? { [id + "End"]: endValue } : {}) }))}
        onReset={() => setFilters({})}
      />
      {visible.length ? <ResponsiveTableCards columns={columns} rows={visible} getRowId={(row) => row.id} getRowTitle={(row) => row.applicationNumber} /> : <EmptyState title="Permohonan tidak ditemukan" description="Ubah filter atau buat Permohonan baru." action={{ label: "Buat Permohonan", href: "/fitness/applications/create" }} />}
    </div>
  );
}

function stageTone(status: FitnessApplicationSummary["status"]) {
  if (status === "Selesai") return "success" as const;
  if (status === "Perlu Perbaikan") return "danger" as const;
  if (status === "Draf") return "warning" as const;
  return "info" as const;
}
