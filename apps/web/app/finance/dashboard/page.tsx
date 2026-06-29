"use client";

import { CreditCard, FilePlus2, Receipt, WalletCards } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import type { FinanceDashboard } from "@/types/finance";

export default function FinanceDashboardPage() {
  return <ProtectedRoute><AppShell title="Dashboard Finance"><FinanceDashboardContent /></AppShell></ProtectedRoute>;
}

function FinanceDashboardContent() {
  const { accessToken } = useAuth();
  const [data, setData] = useState<FinanceDashboard | null>(null);
  const [error, setError] = useState<string | null>(null);
  const loadData = useCallback(async () => {
    if (!accessToken) return;
    setError(null);
    try { setData(await apiData<FinanceDashboard>("/finance/dashboard", { accessToken })); }
    catch (err) { setError(err instanceof Error ? err.message : "Gagal mengambil dashboard finance."); }
  }, [accessToken]);
  useEffect(() => { const timer = window.setTimeout(() => void loadData(), 0); return () => window.clearTimeout(timer); }, [loadData]);
  const metrics = [
    ["Ready to Invoice", data?.ready_to_invoice ?? 0, FilePlus2],
    ["Invoices", data?.invoice_count ?? 0, Receipt],
    ["Paid", data?.paid_count ?? 0, CreditCard],
    ["Unpaid", data?.unpaid_count ?? 0, WalletCards],
    ["Overdue", data?.overdue_count ?? 0, WalletCards],
    ["Outstanding", money(data?.outstanding_amount ?? 0), WalletCards]
  ] as const;
  return <div className="page-stack"><PageHeader title="Dashboard Finance" description="Invoice, payment, outstanding, dan readiness billing." />{error ? <div className="alert alert-danger">{error}</div> : null}<section className="metric-grid">{metrics.map(([label, value, Icon]) => <div className="metric-tile metric-rich" key={label}><Icon size={20} /><p>{label}</p><strong>{value}</strong></div>)}</section><section className="workspace-panel"><div className="job-actions"><Link className="primary-button" href="/finance/ready-to-invoice"><span>Ready to Invoice</span></Link><Link className="secondary-button" href="/finance/invoices"><span>Invoice List</span></Link><Link className="secondary-button" href="/finance/price-list"><span>Price List</span></Link><Link className="secondary-button" href="/finance/outstanding"><span>Outstanding</span></Link><Link className="secondary-button" href="/finance/customers"><span>Rekap Customer</span></Link></div></section></div>;
}
function money(value: number) { return new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 }).format(value); }


