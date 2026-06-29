"use client";

import { FilePlus2, Search } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import type { ReadyInvoice } from "@/types/finance";

const initialInvoiceForm = { unit_price: "", payment_term_days: "30", taxable: true };

export default function ReadyToInvoicePage() {
  return (
    <ProtectedRoute>
      <AppShell title="Ready to Invoice">
        <ReadyContent />
      </AppShell>
    </ProtectedRoute>
  );
}

function ReadyContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<ReadyInvoice[]>([]);
  const [selected, setSelected] = useState<string[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [dialogOpen, setDialogOpen] = useState(false);
  const [invoiceForm, setInvoiceForm] = useState(initialInvoiceForm);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const selectedRows = useMemo(() => rows.filter((row) => selected.includes(row.report_id)), [rows, selected]);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setError(null);
    try {
      const result = await apiPaginated<ReadyInvoice>(`/finance/ready-to-invoice${buildQuery({ page, per_page: 10, search })}`, { accessToken });
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil ready invoice.");
    }
  }, [accessToken, page, search]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  function openCreateDialog() {
    if (selectedRows.length === 0) {
      setError("Pilih minimal satu report untuk dibuat invoice.");
      return;
    }
    const first = selectedRows[0];
    if (selectedRows.some((row) => row.customer_id !== first.customer_id)) {
      setError("Invoice hanya bisa dibuat untuk customer yang sama.");
      return;
    }
    setError(null);
    setDialogOpen(true);
  }

  async function createInvoice() {
    if (!accessToken || selectedRows.length === 0) return;
    const first = selectedRows[0];
    const unitPrice = Number(invoiceForm.unit_price);
    const paymentTermDays = Number(invoiceForm.payment_term_days);
    if (!Number.isFinite(unitPrice) || unitPrice <= 0) {
      setError("Unit price harus lebih dari 0.");
      return;
    }
    setIsSubmitting(true);
    try {
      const item = await apiData<{ id: string }>("/finance/invoices", {
        method: "POST",
        accessToken,
        body: JSON.stringify({
          customer_id: first.customer_id,
          invoice_date: new Date().toISOString().slice(0, 10),
          payment_term_days: Number.isFinite(paymentTermDays) ? paymentTermDays : 30,
          currency: "IDR",
          items: selectedRows.map((row) => ({
            job_order_id: row.job_order_id,
            report_id: row.report_id,
            description: `${row.survey_type_name} - ${row.report_no}`,
            quantity: 1,
            unit_price: unitPrice,
            taxable: invoiceForm.taxable
          }))
        })
      });
      window.location.assign(`/finance/invoices/${item.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal membuat invoice.");
      setIsSubmitting(false);
    }
  }

  return (
    <div className="page-stack">
      <PageHeader title="Ready to Invoice" description="Report approved/generated yang belum ditagih." action={{ label: "Create Invoice", icon: FilePlus2, onClick: openCreateDialog }} />
      <div className="toolbar">
        <label className="search-box">
          <Search size={17} />
          <input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Search report/customer" />
        </label>
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <DataTable
        rows={rows}
        page={page}
        totalPages={totalPages}
        onPageChange={setPage}
        columns={[
          { key: "select", header: "Select", render: (row) => <input type="checkbox" checked={selected.includes(row.report_id)} onChange={(event) => setSelected(event.target.checked ? [...selected, row.report_id] : selected.filter((id) => id !== row.report_id))} /> },
          { key: "report", header: "Report No", render: (row) => <Link className="text-link" href={`/reports/${row.report_id}`}>{row.report_no}</Link> },
          { key: "job", header: "Job No", render: (row) => row.job_order_no },
          { key: "customer", header: "Customer", render: (row) => row.customer_name },
          { key: "type", header: "Survey Type", render: (row) => row.survey_type_name },
          { key: "status", header: "Status", render: (row) => <StatusBadge tone="success">{row.status.toUpperCase()}</StatusBadge> }
        ]}
      />
      <FormDialog title="Create Invoice" open={dialogOpen} onClose={() => setDialogOpen(false)} onSubmit={createInvoice} submitLabel="Create Invoice" isSubmitting={isSubmitting}>
        <div className="form-grid">
          <label className="field">
            <span>Unit Price</span>
            <input type="number" value={invoiceForm.unit_price} onChange={(event) => setInvoiceForm({ ...invoiceForm, unit_price: event.target.value })} />
          </label>
          <label className="field">
            <span>Payment Term Days</span>
            <input type="number" value={invoiceForm.payment_term_days} onChange={(event) => setInvoiceForm({ ...invoiceForm, payment_term_days: event.target.value })} />
          </label>
          <label className="field checkbox-field">
            <input type="checkbox" checked={invoiceForm.taxable} onChange={(event) => setInvoiceForm({ ...invoiceForm, taxable: event.target.checked })} />
            <span>Taxable PPN 11%</span>
          </label>
        </div>
      </FormDialog>
    </div>
  );
}
