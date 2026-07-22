"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { MasterDataPage } from "@/components/master/master-data-page";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { getFitnessMasterDataCategoryConfigByID, masterDataDetailHref, masterDataIndexHref, type MasterDataRouteFamily } from "@/constants/fitness-master-data-client-first";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated } from "@/lib/api-client";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";

type CustomerRow = {
  id: string;
  customer_code: string;
  customer_name: string;
  status: string;
};

const scopedResource = {
  location: { resourceId: "locations", endpoint: "locations" },
  surveyor: { resourceId: "customer-personnel", endpoint: "personnel" },
  "container-type": { resourceId: "container-types", endpoint: "container-types" },
  "survey-type": { resourceId: "survey-types", endpoint: "survey-types" },
  "cedex-location": { resourceId: "cedex-locations", endpoint: "cedex/locations" },
  "cedex-component": { resourceId: "cedex-components", endpoint: "cedex/components" },
  "cedex-damage": { resourceId: "cedex-damages", endpoint: "cedex/damages" },
  "cedex-repair": { resourceId: "cedex-repairs", endpoint: "cedex/repairs" },
  "cedex-material": { resourceId: "cedex-materials", endpoint: "cedex/materials" },
  "responsibility-code": { resourceId: "responsibility-codes", endpoint: "responsibility-codes" }
} as const;

export function CustomerScopedMasterIndex({
  category,
  routeFamily,
  canonicalBaseHref,
  customerDetailTab
}: {
  category: FitnessMasterDataCategory;
  routeFamily: MasterDataRouteFamily;
  canonicalBaseHref?: string;
  customerDetailTab?: string;
}) {
  const { accessToken } = useAuth();
  const config = getFitnessMasterDataCategoryConfigByID(category);
  const [customers, setCustomers] = useState<CustomerRow[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(category !== "customer");

  useEffect(() => {
    if (!accessToken || category === "customer") return;
    apiPaginated<CustomerRow>("/master/customers?page=1&per_page=100", { accessToken })
      .then((result) => setCustomers(result.rows))
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Customer gagal dimuat."))
      .finally(() => setLoading(false));
  }, [accessToken, category]);

  if (category === "customer") {
    return <MasterDataPage
      resourceId="customers"
      detailBaseHref={routeFamily === "actual" ? "/master/customers/customer" : undefined}
      detailQuery={customerDetailTab ? "?tab=" + customerDetailTab : undefined}
    />;
  }

  return <div className="page-stack master-data-customer-picker">
    <PageHeader title={config.label} description="Pilih Customer terlebih dahulu. Seluruh CRUD setelahnya disimpan melalui API customer-scoped." />
    {error ? <div className="alert alert-danger">{error}</div> : null}
    {loading ? <div className="workspace-panel" role="status">Memuat Customer...</div> : null}
    {!loading && customers.length === 0 ? <div className="workspace-panel"><p className="muted-text">Customer belum tersedia.</p></div> : null}
    {!loading && customers.length > 0 ? <section aria-labelledby="master-customer-picker-heading" className="workspace-panel master-customer-picker-panel">
      <div className="master-customer-picker-summary">
        <div>
          <h2 id="master-customer-picker-heading">Customer tersedia</h2>
          <p>Pilih Customer untuk membuka Master Data {config.label}.</p>
        </div>
        <strong aria-live="polite">{customers.length} Customer</strong>
      </div>
      <div className="customer-master-picker-grid">
        {customers.map((customer) => {
          const status = customerStatus(customer.status);
          return <article className="master-customer-card" key={customer.id}>
            <div className="master-customer-card__content">
              <div className="master-customer-card__identity">
                <h3 className="master-customer-card__name">{customer.customer_name}</h3>
                <p className="master-customer-card__code">
                  <span>Kode Customer</span>
                  <strong>{customer.customer_code}</strong>
                </p>
              </div>
              <div className="master-customer-card__meta" aria-label={`Status Customer: ${status.label}`}>
                <StatusBadge tone={status.tone}>{status.label}</StatusBadge>
              </div>
            </div>
            <div className="master-customer-card__actions">
              <Link
                aria-label={`Kelola ${config.label} untuk ${customer.customer_name}`}
                className="primary-button"
                href={canonicalBaseHref
                  ? canonicalBaseHref + (canonicalBaseHref.includes("?") ? "&" : "?") + "customerId=" + customer.id
                  : masterDataDetailHref(category, customer.id, routeFamily)}
              >
                Kelola {config.label}
              </Link>
            </div>
          </article>;
        })}
      </div>
    </section> : null}
  </div>;
}

function customerStatus(value: string) {
  const normalized = value.trim().toLowerCase();
  if (normalized === "active" || normalized === "aktif") return { label: "Aktif", tone: "success" as const };
  if (normalized === "inactive" || normalized === "tidak aktif") return { label: "Tidak Aktif", tone: "warning" as const };
  return { label: value || "Status tidak diketahui", tone: "neutral" as const };
}

export function CustomerScopedMasterDetail({ category, customerId, routeFamily, backHrefOverride }: { category: FitnessMasterDataCategory; customerId: string; routeFamily: MasterDataRouteFamily; backHrefOverride?: string }) {
  const { accessToken } = useAuth();
  const [customer, setCustomer] = useState<CustomerRow | null>(null);
  const [error, setError] = useState<string | null>(null);
  const mapping = category === "customer" ? null : scopedResource[category];
  const backHref = backHrefOverride ?? masterDataIndexHref(category, routeFamily);
  const endpoint = useMemo(() => mapping ? `/customers/${customerId}/${mapping.endpoint}` : "/master/customers", [customerId, mapping]);

  useEffect(() => {
    if (!accessToken) return;
    apiData<CustomerRow>(`/master/customers/${customerId}`, { accessToken })
      .then(setCustomer)
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Customer tidak ditemukan."));
  }, [accessToken, customerId]);

  if (error) return <div className="alert alert-danger">{error}</div>;
  if (!customer) return <div className="workspace-panel">Memuat Customer...</div>;
  if (!mapping) return <MasterDataPage resourceId="customers" backHref={backHref} />;

  return <div className="page-stack">
    <div className="workspace-panel detail-grid">
      <div><span>Customer</span><strong>{customer.customer_name}</strong></div>
      <div><span>Kode</span><strong>{customer.customer_code}</strong></div>
      <div><span>Scope API</span><strong>Customer terkunci</strong></div>
    </div>
    <MasterDataPage resourceId={mapping.resourceId} endpointOverride={endpoint} fixedValues={{ customer_id: customerId }} backHref={backHref} />
    {category === "survey-type" ? <SurveyTypeReferenceConfiguration customerId={customerId} /> : null}
  </div>;
}

type ReferenceRow = { id: string; code: string; name: string; enabled: boolean | number };
type ReferenceOptions = {
  finding_severities: ReferenceRow[];
  test_parameters: ReferenceRow[];
  photo_categories: ReferenceRow[];
};

function SurveyTypeReferenceConfiguration({ customerId }: { customerId: string }) {
  const { accessToken } = useAuth();
  const [surveyTypes, setSurveyTypes] = useState<Array<{ id: string; code: string; name: string }>>([]);
  const [surveyTypeId, setSurveyTypeId] = useState("");
  const [options, setOptions] = useState<ReferenceOptions | null>(null);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    if (!accessToken) return;
    apiPaginated<{ id: string; code: string; name: string }>(`/customers/${customerId}/survey-types?page=1&per_page=100&status=active`, { accessToken })
      .then((result) => {
        setSurveyTypes(result.rows);
        setSurveyTypeId((current) => current || result.rows[0]?.id || "");
      })
      .catch((cause) => setMessage(cause instanceof Error ? cause.message : "Survey Type gagal dimuat."));
  }, [accessToken, customerId]);

  useEffect(() => {
    if (!accessToken || !surveyTypeId) return;
    apiData<ReferenceOptions>(`/customers/${customerId}/survey-types/${surveyTypeId}/reference-options`, { accessToken })
      .then(setOptions)
      .catch((cause) => setMessage(cause instanceof Error ? cause.message : "Mapping referensi gagal dimuat."));
  }, [accessToken, customerId, surveyTypeId]);

  function toggle(group: keyof ReferenceOptions, id: string) {
    setOptions((current) => current ? {
      ...current,
      [group]: current[group].map((item) => item.id === id ? { ...item, enabled: !enabled(item.enabled) } : item)
    } : current);
  }

  async function save() {
    if (!accessToken || !surveyTypeId || !options) return;
    setSaving(true);
    setMessage(null);
    try {
      const updated = await apiData<ReferenceOptions>(`/customers/${customerId}/survey-types/${surveyTypeId}/reference-options`, {
        method: "PUT",
        accessToken,
        body: JSON.stringify({
          severity_ids: options.finding_severities.filter((item) => enabled(item.enabled)).map((item) => item.id),
          test_parameter_ids: options.test_parameters.filter((item) => enabled(item.enabled)).map((item) => item.id),
          photo_category_ids: options.photo_categories.filter((item) => enabled(item.enabled)).map((item) => item.id)
        })
      });
      setOptions(updated);
      setMessage("Mapping Severity, Test Parameter, dan Photo Category tersimpan.");
    } catch (cause) {
      setMessage(cause instanceof Error ? cause.message : "Mapping referensi gagal disimpan.");
    } finally {
      setSaving(false);
    }
  }

  return <section className="workspace-panel page-stack">
    <div className="section-title-row"><div><h2>Mapping Referensi Survey Type</h2><p className="muted-text">Mapping ini menentukan opsi teknis yang boleh dipakai Surveyor.</p></div><button className="primary-button" disabled={saving || !options} onClick={() => void save()}>{saving ? "Menyimpan..." : "Simpan Mapping"}</button></div>
    <label className="field"><span>Survey Type</span><select value={surveyTypeId} onChange={(event) => setSurveyTypeId(event.target.value)}><option value="">Pilih Survey Type</option>{surveyTypes.map((item) => <option key={item.id} value={item.id}>{item.code} - {item.name}</option>)}</select></label>
    {message ? <div className="alert alert-warning">{message}</div> : null}
    {options ? <div className="detail-grid">
      <ReferenceGroup title="Severity" rows={options.finding_severities} onToggle={(id) => toggle("finding_severities", id)} />
      <ReferenceGroup title="Test Parameter" rows={options.test_parameters} onToggle={(id) => toggle("test_parameters", id)} />
      <ReferenceGroup title="Photo Category" rows={options.photo_categories} onToggle={(id) => toggle("photo_categories", id)} />
    </div> : null}
  </section>;
}

function ReferenceGroup({ title, rows, onToggle }: { title: string; rows: ReferenceRow[]; onToggle: (id: string) => void }) {
  return <div><strong>{title}</strong>{rows.map((item) => <label className="field form-check" key={item.id}><input type="checkbox" checked={enabled(item.enabled)} onChange={() => onToggle(item.id)} /> {item.code} - {item.name}</label>)}</div>;
}

function enabled(value: boolean | number) {
  return value === true || Number(value) === 1;
}
