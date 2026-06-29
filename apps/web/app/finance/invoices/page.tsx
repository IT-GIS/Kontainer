"use client";

import { Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";
import type { InvoiceSummary } from "@/types/finance";

export default function InvoiceListPage() { return <ProtectedRoute><AppShell title="Invoice List"><InvoiceListContent /></AppShell></ProtectedRoute>; }
function InvoiceListContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<InvoiceSummary[]>([]);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [error, setError] = useState<string | null>(null);
  const loadRows = useCallback(async () => { if (!accessToken) return; try { const result = await apiPaginated<InvoiceSummary>(`/finance/invoices${buildQuery({ page: 1, per_page: 100, search, status })}`, { accessToken }); setRows(result.rows); } catch (err) { setError(err instanceof Error ? err.message : "Gagal mengambil invoice."); } }, [accessToken, search, status]);
  useEffect(() => { const timer = window.setTimeout(() => void loadRows(), 0); return () => window.clearTimeout(timer); }, [loadRows]);
  return <div className="page-stack"><PageHeader title="Invoice List" description="Draft, issued, payment, dan status invoice." /><div className="toolbar"><label className="search-box"><Search size={17} /><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search invoice/customer" /></label><select value={status} onChange={(event) => setStatus(event.target.value)}><option value="">All Status</option>{["draft","unpaid","partial_paid","paid","overdue","cancelled","void"].map((item) => <option key={item} value={item}>{item}</option>)}</select></div>{error ? <div className="alert alert-danger">{error}</div> : null}<DataTable rows={rows} columns={[{ key: "invoice", header: "Invoice", render: (row) => <Link className="text-link" href={`/finance/invoices/${row.id}`}>{row.invoice_no}</Link> }, { key: "date", header: "Date", render: (row) => row.invoice_date }, { key: "customer", header: "Customer", render: (row) => row.customer_name }, { key: "total", header: "Grand Total", render: (row) => money(row.grand_total) }, { key: "outstanding", header: "Outstanding", render: (row) => money(row.outstanding_amount) }, { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "paid" ? "success" : row.status === "cancelled" || row.status === "void" ? "danger" : "warning"}>{row.status.toUpperCase()}</StatusBadge> }]} /></div>;
}
function money(value: number) { return new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 }).format(Number(value ?? 0)); }
