"use client";

import { Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import type { PaymentSummary } from "@/types/finance";

export default function PaymentsPage() {
  return <ProtectedRoute><AppShell title="Payment"><PaymentsContent /></AppShell></ProtectedRoute>;
}

function PaymentsContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<PaymentSummary[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const load = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<PaymentSummary>(`/finance/payments${buildQuery({ page, per_page: 10, search })}`, { accessToken });
      setRows(result.rows);
      setTotalPages(Math.max(1, Number(result.meta.total_pages ?? 1)));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil payment.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, page, search]);
  useEffect(() => { const timer = window.setTimeout(() => void load(), 0); return () => window.clearTimeout(timer); }, [load]);

  return <div className="page-stack">
    <PageHeader title="Payment" description="Riwayat pembayaran invoice. Pencatatan pembayaran dilakukan dari detail invoice." />
    <div className="toolbar"><label className="search-box"><Search size={17} /><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Cari payment atau invoice" /></label><Link className="secondary-button" href="/finance/invoices">Invoice List</Link></div>
    {error ? <div className="alert alert-danger">{error}</div> : null}
    <DataTable rows={rows} isLoading={isLoading} page={page} totalPages={totalPages} onPageChange={setPage} emptyText="Payment belum tersedia." columns={[
      { key: "payment", header: "Payment No", render: (row) => row.payment_no },
      { key: "invoice", header: "Invoice", render: (row) => <Link className="text-link" href={`/finance/invoices/${row.invoice_id}`}>{row.invoice_no}</Link> },
      { key: "date", header: "Date", render: (row) => row.payment_date },
      { key: "amount", header: "Amount", render: (row) => money(row.amount) },
      { key: "method", header: "Method / Bank", render: (row) => `${row.payment_method ?? "-"} / ${row.bank_account ?? "-"}` },
      { key: "note", header: "Note", render: (row) => row.note ?? "-" }
    ]} />
  </div>;
}

function money(value: number) {
  return new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 }).format(Number(value ?? 0));
}
