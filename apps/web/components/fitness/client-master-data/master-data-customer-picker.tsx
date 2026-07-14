"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { Database } from "lucide-react";
import type { FitnessMasterDataCategoryConfig } from "@/constants/fitness-master-data-client-first";
import { fitnessMasterDataCategoryHref } from "@/constants/fitness-master-data-client-first";
import { EmptyState } from "@/components/ui/empty-state";
import { FilterBar, type FilterBarField } from "@/components/ui/filter-bar";
import { PageHeader } from "@/components/ui/page-header";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { StatusBadge } from "@/components/ui/status-badge";
import type { FitnessClientSummary, FitnessMasterDataCategorySummary } from "@/types/fitness-admin";

export type MasterDataCustomerPickerItem = {
  customer: FitnessClientSummary;
  summary: FitnessMasterDataCategorySummary;
};

export function MasterDataCustomerPicker({ config, items }: { config: FitnessMasterDataCategoryConfig; items: MasterDataCustomerPickerItem[] }) {
  const [filters, setFilters] = useState<Record<string, string>>({});
  const regions = Array.from(new Set(items.flatMap(({ customer }) => [customer.city, customer.province])));
  const fields: FilterBarField[] = [
    { id: "keyword", label: "Cari", type: "search", value: filters.keyword ?? "", placeholder: "Nama atau kode Customer" },
    { id: "status", label: "Status", type: "select", value: filters.status ?? "", placeholder: "Semua status", options: [{ value: "Aktif", label: "Aktif" }, { value: "Tidak Aktif", label: "Tidak Aktif" }] },
    { id: "region", label: "Kota/Provinsi", type: "select", value: filters.region ?? "", placeholder: "Semua wilayah", options: regions.map((value) => ({ value, label: value })) }
  ];
  const visibleItems = useMemo(() => {
    const keyword = (filters.keyword ?? "").trim().toLowerCase();
    return items.filter(({ customer }) => {
      const matchesKeyword = !keyword || (customer.name + " " + customer.code).toLowerCase().includes(keyword);
      const matchesStatus = !filters.status || customer.status === filters.status;
      const matchesRegion = !filters.region || customer.city === filters.region || customer.province === filters.region;
      return matchesKeyword && matchesStatus && matchesRegion;
    });
  }, [filters, items]);
  const columns: ResponsiveColumn<MasterDataCustomerPickerItem>[] = [
    { key: "customer", header: "Customer", render: ({ customer }) => <span><strong>{customer.name}</strong><small className="client-cell-note">{customer.addressShort}</small></span> },
    { key: "code", header: "Kode", render: ({ customer }) => <strong>{customer.code}</strong> },
    { key: "pic", header: "PIC Utama", render: ({ customer }) => <span>{customer.primaryContactName}<small className="client-cell-note">{customer.email}</small></span> },
    { key: "region", header: "Kota/Provinsi", render: ({ customer }) => <span>{customer.city}<small className="client-cell-note">{customer.province}</small></span> },
    { key: "count", header: "Jumlah Data", render: ({ summary }) => <strong>{summary.count}</strong> },
    { key: "status", header: "Status", render: ({ customer }) => <StatusBadge tone={customer.status === "Aktif" ? "success" : "neutral"}>{customer.status}</StatusBadge> },
    { key: "updated", header: "Pembaruan", render: ({ summary }) => summary.updatedAt },
    {
      key: "action",
      header: "Aksi",
      render: ({ customer }) => (
        <Link
          aria-label={`Kelola ${config.label} ${customer.name}`}
          className="primary-button client-inline-action"
          href={fitnessMasterDataCategoryHref(config.id, customer.id)}
        >
          Kelola {config.label}
        </Link>
      )
    }
  ];

  return (
    <div className="page-stack master-data-customer-picker">
      <PageHeader
        eyebrow="Klien & Master Data"
        title={`Pilih Customer untuk ${config.label}`}
        description={`Daftar ${config.label} baru dimuat setelah Customer dipilih.`}
        meta={<span>{visibleItems.length} dari {items.length} Customer ditampilkan</span>}
      />
      <div className="client-isolation-notice" role="status">
        <Database size={18} />
        <span>Customer adalah sumber perusahaan. Data {config.label} selalu dibatasi oleh <strong>clientId</strong> dari route.</span>
      </div>
      <FilterBar fields={fields} onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))} onReset={() => setFilters({})} />
      {visibleItems.length ? (
        <ResponsiveTableCards columns={columns} rows={visibleItems} getRowId={({ customer }) => customer.id} getRowTitle={({ customer }) => customer.name} />
      ) : (
        <EmptyState title="Customer tidak ditemukan" description="Ubah pencarian atau reset filter untuk memilih Customer lain." />
      )}
    </div>
  );
}
