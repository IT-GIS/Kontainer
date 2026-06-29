"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated } from "@/lib/api-client";
import type { InvoiceSummary } from "@/types/finance";

export default function OutstandingPage() { return <ProtectedRoute><AppShell title="Outstanding"><OutstandingContent /></AppShell></ProtectedRoute>; }
function OutstandingContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<InvoiceSummary[]>([]);
  const [error, setError] = useState<string | null>(null);
  const loadRows = useCallback(async () => { if (!accessToken) return; try { const result = await apiPaginated<InvoiceSummary>("/finance/outstanding?page=1&per_page=100", { accessToken }); setRows(result.rows); } catch (err) { setError(err instanceof Error ? err.message : "Gagal mengambil outstanding."); } }, [accessToken]);
  useEffect(() => { const timer = window.setTimeout(() => void loadRows(), 0); return () => window.clearTimeout(timer); }, [loadRows]);
  return <div className="page-stack"><PageHeader title="Outstanding" description="Invoice aktif dengan sisa tagihan." />{error ? <div className="alert alert-danger">{error}</div> : null}<DataTable rows={rows} columns={[{ key: "invoice", header: "Invoice", render: (row) => <Link className="text-link" href={`/finance/invoices/${row.id}`}>{row.invoice_no}</Link> }, { key: "customer", header: "Customer", render: (row) => row.customer_name }, { key: "due", header: "Due Date", render: (row) => row.due_date ?? "-" }, { key: "outstanding", header: "Outstanding", render: (row) => money(row.outstanding_amount) }, { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "overdue" ? "danger" : "warning"}>{row.status.toUpperCase()}</StatusBadge> }]} /></div>;
}
function money(value: number) { return new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 }).format(Number(value ?? 0)); }
