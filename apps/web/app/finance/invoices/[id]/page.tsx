"use client";

import { CreditCard, Download, Send, X } from "lucide-react";
import { useParams } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import type { InvoiceDetail } from "@/types/finance";

const apiBase = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080/api/v1";

export default function InvoiceDetailPage() {
  return <ProtectedRoute><AppShell title="Invoice Detail"><InvoiceDetailContent /></AppShell></ProtectedRoute>;
}

function InvoiceDetailContent() {
  const params = useParams<{ id: string }>();
  const { accessToken, user } = useAuth();
  const canManage = can(user, "finance.manage.all");
  const canPay = can(user, "finance.payment.create.all");
  const [invoice, setInvoice] = useState<InvoiceDetail | null>(null);
  const [dialog, setDialog] = useState<"payment" | "cancel" | null>(null);
  const [amount, setAmount] = useState("");
  const [note, setNote] = useState("");
  const [error, setError] = useState<string | null>(null);

  const loadInvoice = useCallback(async () => {
    if (!accessToken || !params.id) return;
    try {
      setInvoice(await apiData<InvoiceDetail>(`/finance/invoices/${params.id}`, { accessToken }));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil invoice.");
    }
  }, [accessToken, params.id]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadInvoice(), 0);
    return () => window.clearTimeout(timer);
  }, [loadInvoice]);

  async function issue() {
    if (!accessToken || !canManage) return;
    try {
      await apiData(`/finance/invoices/${params.id}/issue`, { method: "POST", accessToken, body: "{}" });
      await loadInvoice();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal issue invoice.");
    }
  }

  async function cancel() {
    if (!accessToken || !canManage) return;
    try {
      await apiData(`/finance/invoices/${params.id}/cancel`, {
        method: "POST", accessToken, body: JSON.stringify({ reason: note })
      });
      setDialog(null);
      setNote("");
      await loadInvoice();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal cancel invoice.");
    }
  }

  async function payment() {
    if (!accessToken || !canPay) return;
    try {
      await apiData("/finance/payments", {
        method: "POST",
        accessToken,
        body: JSON.stringify({
          invoice_id: params.id,
          payment_date: new Date().toISOString().slice(0, 10),
          amount: Number(amount),
          payment_method: "bank_transfer",
          note
        })
      });
      setDialog(null);
      setAmount("");
      setNote("");
      await loadInvoice();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mencatat payment.");
    }
  }

  if (!invoice) return <div className="center-screen">Memuat invoice...</div>;
  return (
    <div className="page-stack">
      <PageHeader title={`Invoice: ${invoice.invoice_no}`} description={`${invoice.customer_name} - ${money(invoice.grand_total)}`} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <div className="job-actions">
        {canManage ? <button className="primary-button" disabled={invoice.status !== "draft"} onClick={() => void issue()}><Send size={17} /><span>Issue</span></button> : null}
        {canPay ? <button className="secondary-button" disabled={!["unpaid", "partial_paid", "overdue"].includes(invoice.status)} onClick={() => setDialog("payment")}><CreditCard size={17} /><span>Payment</span></button> : null}
        {canManage ? <button className="secondary-button" disabled={["paid", "cancelled", "void"].includes(invoice.status)} onClick={() => setDialog("cancel")}><X size={17} /><span>Cancel</span></button> : null}
        <button className="secondary-button" onClick={() => void downloadInvoice(invoice.id, invoice.invoice_no, accessToken)}><Download size={17} /><span>PDF</span></button>
      </div>
      <section className="workspace-panel detail-grid">
        <div><span>Status</span><strong><StatusBadge tone={invoice.status === "paid" ? "success" : ["cancelled", "void"].includes(invoice.status) ? "danger" : "warning"}>{invoice.status.toUpperCase()}</StatusBadge></strong></div>
        <div><span>Grand Total</span><strong>{money(invoice.grand_total)}</strong></div>
        <div><span>Paid</span><strong>{money(invoice.paid_amount)}</strong></div>
        <div><span>Outstanding</span><strong>{money(invoice.outstanding_amount)}</strong></div>
        <div><span>Due Date</span><strong>{invoice.due_date ?? "-"}</strong></div>
        <div><span>Currency</span><strong>{invoice.currency}</strong></div>
      </section>
      <section className="workspace-panel">
        <h2>Items</h2>
        <DataTable rows={invoice.items ?? []} columns={[
          { key: "report", header: "Report", render: (row) => String(row.report_no ?? row.report_id ?? "-") },
          { key: "description", header: "Description", render: (row) => String(row.description ?? "-") },
          { key: "qty", header: "Qty", render: (row) => String(row.quantity ?? 0) },
          { key: "price", header: "Unit Price", render: (row) => money(Number(row.unit_price ?? 0)) },
          { key: "total", header: "Total", render: (row) => money(Number(row.total ?? 0)) }
        ]} />
      </section>
      <FormDialog
        title={dialog === "payment" ? "Payment Form" : "Cancel Invoice"}
        open={(dialog === "payment" && canPay) || (dialog === "cancel" && canManage)}
        onClose={() => setDialog(null)}
        onSubmit={dialog === "payment" ? payment : cancel}
        submitLabel={dialog === "payment" ? "Save Payment" : "Cancel Invoice"}
      >
        <div className="form-grid">
          {dialog === "payment" ? <label className="field"><span>Amount</span><input type="number" value={amount} onChange={(event) => setAmount(event.target.value)} /></label> : null}
          <label className="field form-span-2"><span>Note</span><textarea rows={4} value={note} onChange={(event) => setNote(event.target.value)} /></label>
        </div>
      </FormDialog>
    </div>
  );
}

async function downloadInvoice(id: string, invoiceNo: string, accessToken: string | null) {
  if (!accessToken) return;
  const response = await fetch(`${apiBase}/finance/invoices/${id}/download`, {
    headers: { Authorization: `Bearer ${accessToken}` }
  });
  if (!response.ok) return;
  const blob = await response.blob();
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `${invoiceNo}.pdf`;
  link.click();
  window.URL.revokeObjectURL(url);
}

function money(value: number) {
  return new Intl.NumberFormat("id-ID", {
    style: "currency", currency: "IDR", maximumFractionDigits: 0
  }).format(Number(value ?? 0));
}
