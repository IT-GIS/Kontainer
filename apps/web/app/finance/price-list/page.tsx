"use client";

import { Plus } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated } from "@/lib/api-client";
import { loadOptions } from "@/lib/options";
import { can } from "@/lib/permissions";
import type { OptionItem } from "@/types/jobs";
import type { PriceList } from "@/types/finance";

type Form = { survey_type_id: string; container_type_id: string; description: string; unit_price: string; currency: string; tax_type: string; effective_date: string; status: string };
const emptyForm: Form = { survey_type_id: "", container_type_id: "", description: "", unit_price: "", currency: "IDR", tax_type: "ppn", effective_date: new Date().toISOString().slice(0, 10), status: "active" };

export default function PriceListPage() { return <ProtectedRoute><AppShell title="Price List"><PriceListContent /></AppShell></ProtectedRoute>; }

function PriceListContent() {
  const { accessToken, user } = useAuth();
  const canManage = can(user, "finance.manage.all");
  const [rows, setRows] = useState<PriceList[]>([]);
  const [dialog, setDialog] = useState(false);
  const [form, setForm] = useState<Form>(emptyForm);
  const [surveyTypes, setSurveyTypes] = useState<OptionItem[]>([]);
  const [containerTypes, setContainerTypes] = useState<OptionItem[]>([]);
  const [error, setError] = useState<string | null>(null);
  const loadRows = useCallback(async () => { if (!accessToken) return; try { const result = await apiPaginated<PriceList>("/finance/price-list?page=1&per_page=100", { accessToken }); setRows(result.rows); } catch (err) { setError(err instanceof Error ? err.message : "Gagal mengambil price list."); } }, [accessToken]);
  useEffect(() => { const timer = window.setTimeout(() => void loadRows(), 0); return () => window.clearTimeout(timer); }, [loadRows]);
  useEffect(() => { if (!accessToken) return; void Promise.all([loadOptions(accessToken, "/master/survey-types", "name", "code"), loadOptions(accessToken, "/master/container-types", "type", "code")]).then(([a, b]) => { setSurveyTypes(a); setContainerTypes(b); }); }, [accessToken]);
  async function save() { if (!accessToken || !canManage) return; try { await apiData("/finance/price-list", { method: "POST", accessToken, body: JSON.stringify({ ...form, unit_price: Number(form.unit_price), container_type_id: form.container_type_id || null }) }); setDialog(false); setForm(emptyForm); await loadRows(); } catch (err) { setError(err instanceof Error ? err.message : "Gagal menyimpan price list."); } }
  return <div className="page-stack"><PageHeader title="Price List" description="Harga dasar per survey type/container type." action={canManage ? { label: "Add Price", icon: Plus, onClick: () => setDialog(true) } : undefined} />{error ? <div className="alert alert-danger">{error}</div> : null}<DataTable rows={rows} columns={[{ key: "customer", header: "Customer", render: (row) => row.customer_name ?? "Default" }, { key: "survey_type", header: "Survey Type", render: (row) => row.survey_type_name }, { key: "container_type", header: "Container Type", render: (row) => row.container_type_code ?? "All" }, { key: "price", header: "Unit Price", render: (row) => money(row.unit_price) }, { key: "currency", header: "Currency", render: (row) => row.currency }, { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "active" ? "success" : "warning"}>{row.status.toUpperCase()}</StatusBadge> }]} /><FormDialog title="Add Price" open={canManage && dialog} onClose={() => setDialog(false)} onSubmit={save} submitLabel="Save"><div className="form-grid"><Field label="Survey Type"><Select value={form.survey_type_id} options={surveyTypes} onChange={(value) => setForm({ ...form, survey_type_id: value })} /></Field><Field label="Container Type"><Select value={form.container_type_id} options={containerTypes} onChange={(value) => setForm({ ...form, container_type_id: value })} /></Field><Field label="Unit Price"><input type="number" value={form.unit_price} onChange={(event) => setForm({ ...form, unit_price: event.target.value })} /></Field><Field label="Currency"><input value={form.currency} onChange={(event) => setForm({ ...form, currency: event.target.value })} /></Field><Field label="Tax Type"><input value={form.tax_type} onChange={(event) => setForm({ ...form, tax_type: event.target.value })} /></Field><Field label="Effective Date"><input type="date" value={form.effective_date} onChange={(event) => setForm({ ...form, effective_date: event.target.value })} /></Field><label className="field form-span-2"><span>Description</span><textarea rows={3} value={form.description} onChange={(event) => setForm({ ...form, description: event.target.value })} /></label></div></FormDialog></div>;
}
function Field({ label, children }: { label: string; children: React.ReactNode }) { return <label className="field"><span>{label}</span>{children}</label>; }
function Select({ value, options, onChange }: { value: string; options: OptionItem[]; onChange: (value: string) => void }) { return <select value={value} onChange={(event) => onChange(event.target.value)}><option value="">Select</option>{options.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select>; }
function money(value: number) { return new Intl.NumberFormat("id-ID", { style: "currency", currency: "IDR", maximumFractionDigits: 0 }).format(Number(value ?? 0)); }
