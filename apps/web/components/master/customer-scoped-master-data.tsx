"use client";

import { Plus, Search } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { CustomerReadinessIndex } from "@/components/master/customer-readiness";
import { MasterDataPage, type MasterDataPageProps } from "@/components/master/master-data-page";
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
  "cedex-action": { resourceId: "cedex-actions", endpoint: "cedex/repairs" },
  "cedex-reference": { resourceId: "cedex-references", endpoint: "/fitness/master-data/test-parameters", global: true },
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
  const [searchQuery, setSearchQuery] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(category !== "customer");

  useEffect(() => {
    if (!accessToken || category === "customer") return;
    apiPaginated<CustomerRow>("/master/customers?page=1&per_page=100", { accessToken })
      .then((result) => setCustomers(result.rows))
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Customer gagal dimuat."))
      .finally(() => setLoading(false));
  }, [accessToken, category]);

  const router = useRouter();

  const filteredCustomers = useMemo(() => {
    if (!searchQuery.trim()) return customers;
    const q = searchQuery.toLowerCase().trim();
    return customers.filter(
      (c) => c.customer_name.toLowerCase().includes(q) || c.customer_code.toLowerCase().includes(q)
    );
  }, [customers, searchQuery]);

  if (category === "customer") {
    return <CustomerReadinessIndex />;
  }

  return <div className="page-stack master-data-customer-picker">
    <PageHeader
      title={config.label}
      description="Pilih Customer terlebih dahulu. Data yang dikelola akan tersimpan untuk Customer tersebut."
      action={{ label: "Tambah Customer", icon: Plus, onClick: () => router.push("/master/customers/create") }}
    />
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    <div className="toolbar">
      <label className="search-box">
        <Search size={17} />
        <span className="sr-only">Search Customer</span>
        <input
          value={searchQuery}
          onChange={(event) => setSearchQuery(event.target.value)}
          placeholder="Search Customer..."
        />
      </label>
    </div>
    {loading ? <div className="workspace-panel" role="status">Memuat Customer...</div> : null}
    {!loading && customers.length === 0 ? <div className="workspace-panel"><p className="muted-text">Customer belum tersedia.</p></div> : null}
    {!loading && customers.length > 0 && filteredCustomers.length === 0 ? <div className="workspace-panel"><p className="muted-text">Customer tidak ditemukan sesuai pencarian.</p></div> : null}
    {!loading && filteredCustomers.length > 0 ? <section aria-labelledby="master-customer-picker-heading" className="workspace-panel master-customer-picker-panel">
      <div className="master-customer-picker-summary">
        <div>
          <h2 id="master-customer-picker-heading">DAFTAR CUSTOMER</h2>
          <p>Pilih Customer untuk membuka Master Data {config.label}.</p>
        </div>
        <strong aria-live="polite">{filteredCustomers.length} Customer</strong>
      </div>
      <div className="customer-master-picker-grid">
        {filteredCustomers.map((customer) => {
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

export function CustomerScopedMasterDetail({
  category,
  customerId,
  routeFamily,
  backHrefOverride,
  addButtonLabelOverride,
  dialogTitleOverride,
  forceReadOnly = false,
  forceReadOnlyMessage,
  hideBackLink = false,
  referenceConfigurationReadOnly,
  showReferenceConfiguration = true,
  referenceGroups,
  masterDataProps
}: {
  category: FitnessMasterDataCategory;
  customerId: string;
  routeFamily: MasterDataRouteFamily;
  backHrefOverride?: string;
  addButtonLabelOverride?: string;
  dialogTitleOverride?: string;
  forceReadOnly?: boolean;
  forceReadOnlyMessage?: string;
  hideBackLink?: boolean;
  referenceConfigurationReadOnly?: boolean;
  showReferenceConfiguration?: boolean;
  referenceGroups?: ReferenceOptionGroup[];
  masterDataProps?: Pick<MasterDataPageProps,
    "showResourceHeader" | "showToolbarAdd" | "showRichEmptyState" | "showImportUnavailable" | "enableExport" | "enableSaveAndNew" |
    "enableSorting" | "responsiveCards" | "dialogSize" | "actionIdPrefix" | "filters" | "relationEndpointOverrides" |
    "emptyTitle" | "emptyDescription" | "onSaved" | "renderRowActions" | "canMutateRow" | "locationGenerator" | "showHistoryAction"
  >;
}) {
  const { accessToken } = useAuth();
  const [customer, setCustomer] = useState<CustomerRow | null>(null);
  const [error, setError] = useState<string | null>(null);
  const mapping = category === "customer" ? null : scopedResource[category];
  const backHref = backHrefOverride ?? masterDataIndexHref(category, routeFamily);
  const endpoint = useMemo(() => {
    if (!mapping) return "/master/customers";
    return "global" in mapping && mapping.global ? mapping.endpoint : `/customers/${customerId}/${mapping.endpoint}`;
  }, [customerId, mapping]);

  useEffect(() => {
    if (!accessToken) return;
    apiData<CustomerRow>(`/master/customers/${customerId}`, { accessToken })
      .then(setCustomer)
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Customer tidak ditemukan."));
  }, [accessToken, customerId]);

  if (error) return <div className="alert alert-danger">{error}</div>;
  if (!customer) return <div className="workspace-panel">Memuat Customer...</div>;
  if (!mapping) return <MasterDataPage resourceId="customers" backHref={backHref} />;

  const customerReadOnly = customer.status !== "active";
  const readOnly = forceReadOnly || customerReadOnly;
  const mappingReadOnly = customerReadOnly || (referenceConfigurationReadOnly ?? readOnly);
  const fixedValues = "global" in mapping && mapping.global
    ? undefined
    : {
        customer_id: customerId,
        ...(category.startsWith("cedex-") && category !== "cedex-reference" ? { source_type: "customer_specific" } : {})
      };
  return <div className="page-stack">
    <div className="workspace-panel detail-grid">
      <div><span>Customer</span><strong>{customer.customer_name}</strong></div>
      <div><span>Kode</span><strong>{customer.customer_code}</strong></div>
      <div><span>Cakupan Data</span><strong>{"global" in mapping && mapping.global ? "Master global" : "Khusus Customer ini"}</strong></div>
    </div>
    <MasterDataPage
      resourceId={mapping.resourceId}
      endpointOverride={endpoint}
      fixedValues={fixedValues}
      backHref={hideBackLink ? undefined : backHref}
      readOnly={readOnly}
      readOnlyMessage={forceReadOnlyMessage ?? "Customer tidak aktif. Master Data hanya dapat dilihat dan tidak dapat diubah."}
      addButtonLabelOverride={addButtonLabelOverride}
      dialogTitleOverride={dialogTitleOverride}
      {...masterDataProps}
    />
    {category === "survey-type" && showReferenceConfiguration ? (
      <SurveyTypeReferenceConfiguration customerId={customerId} readOnly={mappingReadOnly} visibleGroups={referenceGroups} />
    ) : null}
  </div>;
}

type ReferenceRow = { id: string; code: string; name: string; enabled: boolean | number };
type ReferenceOptions = {
  finding_severities: ReferenceRow[];
  test_parameters: ReferenceRow[];
  photo_categories: ReferenceRow[];
};
export type ReferenceOptionGroup = keyof ReferenceOptions;

export function SurveyTypeReferenceConfiguration({
  customerId,
  readOnly,
  visibleGroups = ["finding_severities", "test_parameters", "photo_categories"]
}: {
  customerId: string;
  readOnly: boolean;
  visibleGroups?: ReferenceOptionGroup[];
}) {
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
    if (readOnly) return;
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
    <div className="section-title-row"><div><h2>Mapping Referensi Survey Type</h2><p className="muted-text">Mapping ini menentukan pilihan yang tersedia bagi Surveyor GIFT.</p></div>{!readOnly ? <button className="primary-button" disabled={saving || !options} onClick={() => void save()}>{saving ? "Menyimpan..." : "Simpan Mapping"}</button> : null}</div>
    <label className="field"><span>Survey Type</span><select value={surveyTypeId} onChange={(event) => setSurveyTypeId(event.target.value)}><option value="">Pilih Survey Type</option>{surveyTypes.map((item) => <option key={item.id} value={item.id}>{item.code} - {item.name}</option>)}</select></label>
    {message ? <div className="alert alert-warning">{message}</div> : null}
    {options ? <div className="detail-grid">
      {visibleGroups.includes("finding_severities") ? <ReferenceGroup title="Severity" rows={options.finding_severities} disabled={readOnly} onToggle={(id) => toggle("finding_severities", id)} /> : null}
      {visibleGroups.includes("test_parameters") ? <ReferenceGroup title="Referensi Pemeriksaan" rows={options.test_parameters} disabled={readOnly} onToggle={(id) => toggle("test_parameters", id)} /> : null}
      {visibleGroups.includes("photo_categories") ? <ReferenceGroup title="Kategori Foto / Evidence" rows={options.photo_categories} disabled={readOnly} onToggle={(id) => toggle("photo_categories", id)} /> : null}
    </div> : null}
  </section>;
}

function ReferenceGroup({ title, rows, disabled, onToggle }: { title: string; rows: ReferenceRow[]; disabled: boolean; onToggle: (id: string) => void }) {
  return <div><strong>{title}</strong>{rows.map((item) => <label className="field form-check" key={item.id}><input type="checkbox" checked={enabled(item.enabled)} disabled={disabled} onChange={() => onToggle(item.id)} /> {item.code} - {item.name}</label>)}</div>;
}

function enabled(value: boolean | number) {
  return value === true || Number(value) === 1;
}
