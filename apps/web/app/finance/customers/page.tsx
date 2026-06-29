"use client";

import { Search } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import type { CustomerFinanceSummary } from "@/types/finance";

export default function CustomerRecapPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Rekap Customer">
        <CustomerRecapContent />
      </AppShell>
    </ProtectedRoute>
  );
}

function CustomerRecapContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<CustomerFinanceSummary[]>([]);
  const [search, setSearch] = useState("");
  const [error, setError] = useState<string | null>(null);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setError(null);
    try {
      const result = await apiPaginated<CustomerFinanceSummary>(`/finance/customer-summary${buildQuery({ page: 1, per_page: 100, search })}`, { accessToken });
      setRows(result.rows);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil rekap customer.");
    }
  }, [accessToken, search]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  return (
    <div className="page-stack">
      <PageHeader title="Rekap Customer" description="Agregasi invoice, payment, dan outstanding per customer." />
      <div className="toolbar">
        <label className="search-box">
          <Search size={17} />
          <input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search customer" />
        </label>
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <DataTable
        rows={rows}
        columns={[
          { key: "customer", header: "Customer", render: (row) => row.customer_name },
          { key: "invoice_count", header: "Invoices", render: (row) => String(row.invoice_count ?? 0) },
          { key: "total_invoiced", header: "Total Invoiced", render: (row) => money(row.total_invoiced) },
          { key: "total_paid", header: "Paid", render: (row) => money(row.total_paid) },
          { key: "outstanding", header: "Outstanding", render: (row) => money(row.outstanding_amount) }
        ]}
      />
    </div>
  );
}

function money(value: number) {
  return new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 }).format(Number(value ?? 0));
}
