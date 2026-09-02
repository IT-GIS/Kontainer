"use client";

import { CheckCircle2, CircleAlert, LockKeyhole } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";
import { CustomerScopedMasterDetail } from "@/components/master/customer-scoped-master-data";
import type { CustomerReadiness } from "@/components/master/customer-readiness";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { SurveySheetFieldSourceBadge, type SurveySheetFieldSource } from "@/components/ui/survey-sheet-field-source-badge";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated } from "@/lib/api-client";

export type SurveySheetConfigurationSection = "overview" | "survey-types" | "container-types";

type CustomerIdentity = { customer_name: string; status: string };
type SurveyTypeRow = { id: string; code: string; name: string; status?: string };
type ContainerTypeRow = { id: string; code: string; type_name?: string; type?: string; size?: string | null; status?: string };
type LocationRow = { id: string; location_code: string; location_name: string; status?: string };

const sections: Array<{ id: SurveySheetConfigurationSection; label: string }> = [
  { id: "overview", label: "Ringkasan Sumber Data" },
  { id: "survey-types", label: "Survey Type" },
  { id: "container-types", label: "Container Type" }
];

export function SurveySheetConfiguration({
  customer,
  customerId,
  readiness,
  section
}: {
  customer: CustomerIdentity;
  customerId: string;
  readiness: CustomerReadiness | null;
  section: SurveySheetConfigurationSection;
}) {
  const baseHref = `/master/customers/customer/${customerId}?tab=survey-sheet`;
  return <div className="page-stack survey-sheet-configuration">
    <PageHeader
      eyebrow="Pusat Konfigurasi"
      title="Konfigurasi Survey Sheet"
      description={`Customer: ${customer.customer_name}. Halaman ini menghubungkan konfigurasi existing; data per peti kemas tetap diinput pada Job → Peti Kemas.`}
      meta={<StatusBadge tone={readiness?.overall_ready ? "success" : "warning"}>{readiness?.overall_ready ? "Siap digunakan" : "Konfigurasi belum lengkap"}</StatusBadge>}
    />
    <WorkspaceTabs activeID={section} label="Konfigurasi Survey Sheet" tabs={sections.map((item) => ({ ...item, href: `${baseHref}&section=${item.id}` }))} />
    {section === "overview" ? <SurveySheetConfigurationOverview customer={customer} customerId={customerId} readiness={readiness} /> : null}
    {section === "survey-types" ? <CustomerScopedMasterDetail category="survey-type" customerId={customerId} hideBackLink routeFamily="actual" showReferenceConfiguration={false} /> : null}
    {section === "container-types" ? <CustomerScopedMasterDetail category="container-type" customerId={customerId} hideBackLink routeFamily="actual" /> : null}
  </div>;
}

function SurveySheetConfigurationOverview({ customer, customerId, readiness }: { customer: CustomerIdentity; customerId: string; readiness: CustomerReadiness | null }) {
  const { accessToken } = useAuth();
  const [surveyTypes, setSurveyTypes] = useState<SurveyTypeRow[]>([]);
  const [containerTypes, setContainerTypes] = useState<ContainerTypeRow[]>([]);
  const [locations, setLocations] = useState<LocationRow[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!accessToken) return;
    Promise.all([
      apiPaginated<SurveyTypeRow>(`/customers/${customerId}/survey-types?page=1&per_page=100&status=active`, { accessToken }),
      apiPaginated<ContainerTypeRow>(`/customers/${customerId}/container-types?page=1&per_page=100&status=active`, { accessToken }),
      apiPaginated<LocationRow>(`/customers/${customerId}/locations?page=1&per_page=100&status=active`, { accessToken })
    ])
      .then(([surveyTypeResult, containerTypeResult, locationResult]) => {
        setSurveyTypes(surveyTypeResult.rows);
        setContainerTypes(containerTypeResult.rows);
        setLocations(locationResult.rows);
      })
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Konfigurasi Survey Sheet gagal dimuat."));
  }, [accessToken, customerId]);

  const checks = new Map(readiness?.checks.map((check) => [check.key, check]) ?? []);
  const sizes = unique(containerTypes.map((item) => normalizeSize(item.size)).filter(Boolean));
  const cedexKeys = ["cedex_location", "cedex_component", "cedex_damage", "cedex_action_repair", "cedex_material"];
  const cedexReady = cedexKeys.every((key) => checks.get(key)?.ready);
  const cedexSource = (readiness?.cedex_override_count ?? 0) > 0 ? "Global + Override Customer" : "Master CEDEX Global";

  return <div className="page-stack">
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    <section className="workspace-panel page-stack" aria-labelledby="survey-sheet-config-summary">
      <div className="section-title-row"><div><span className="eyebrow">Admin input / configuration</span><h2 id="survey-sheet-config-summary">Sumber yang otomatis digunakan Survey Sheet</h2><p className="muted-text">Nilai di bawah membaca source existing. Halaman ini tidak membuat salinan editable baru di Customer.</p></div></div>
      <div className="survey-sheet-config-grid">
        <ConfigurationItem label="Customer / Client" source="Customer" values={[customer.customer_name]} ready={customer.status === "active"} locked />
        <ConfigurationItem label="Type of Survey" source="Customer" values={surveyTypes.map((item) => `${item.code} — ${item.name}`)} ready={Boolean(checks.get("survey_type")?.ready)} manageHref={`/master/customers/customer/${customerId}?tab=survey-sheet&section=survey-types`} />
        <ConfigurationItem label="Container Size yang digunakan" source="Customer" values={sizes.map((size) => `${size} ft`)} ready={Boolean(checks.get("container_type")?.ready)} manageHref={`/master/customers/customer/${customerId}?tab=survey-sheet&section=container-types`} />
        <ConfigurationItem label="Survey Location" source="Customer" values={locations.map((item) => `${item.location_code} — ${item.location_name}`)} ready={Boolean(checks.get("location")?.ready && checks.get("location_pic_mapping")?.ready)} manageHref={`/master/customers/customer/${customerId}?tab=location-pic`} />
        <ConfigurationItem label="Checklist" source="Customer" values={[configuredText(checks.get("checklist_template")?.ready && checks.get("checklist_item")?.ready)]} ready={Boolean(checks.get("checklist_template")?.ready && checks.get("checklist_item")?.ready)} manageHref={`/master/customers/customer/${customerId}?tab=checklist`} />
        <ConfigurationItem label="Referensi Pemeriksaan" source="Customer" values={[configuredText(checks.get("test_parameter_mapping")?.ready)]} ready={Boolean(checks.get("test_parameter_mapping")?.ready)} manageHref={`/master/customers/customer/${customerId}?tab=references`} />
        <ConfigurationItem label="Photo / Evidence" source="Customer" values={[configuredText(checks.get("photo_category_mapping")?.ready)]} ready={Boolean(checks.get("photo_category_mapping")?.ready)} manageHref={`/master/customers/customer/${customerId}?tab=photo-evidence`} />
        <ConfigurationItem label="CEDEX" source="Master CEDEX" values={[cedexSource]} ready={cedexReady} manageHref={`/master/customers/customer/${customerId}?tab=cedex`} />
      </div>
    </section>

    <section className="workspace-panel page-stack" aria-labelledby="per-container-data-title">
      <div className="section-title-row"><div><span className="eyebrow">Data per peti kemas</span><h2 id="per-container-data-title">Diisi pada Job → Peti Kemas</h2><p className="muted-text">Setiap unit menyimpan nilainya sendiri. Surveyor, Reviewer, dan Laporan hanya membaca snapshot Survey.</p></div><Link className="secondary-button" href="/jobs">Buka Pekerjaan</Link></div>
      <div className="survey-field-source-grid">
        {perContainerFields.map((field) => <div className="survey-field-source-row" key={field}><span>{field}</span><SurveySheetFieldSourceBadge source="Peti Kemas" /></div>)}
      </div>
    </section>

    <section className="workspace-panel page-stack" aria-labelledby="field-ownership-title">
      <div className="section-title-row"><div><span className="eyebrow">Satu sumber editable</span><h2 id="field-ownership-title">Ownership header Survey Sheet</h2><p className="muted-text">Field administratif terkunci bagi Surveyor. Condition dan Cleanliness adalah hasil pemeriksaan lapangan.</p></div></div>
      <div className="survey-field-source-grid">
        {fieldOwnership.map((field) => <div className="survey-field-source-row" key={field.label}><span>{field.label}{field.locked ? <LockKeyhole aria-label="Read-only" size={15} /> : null}</span><SurveySheetFieldSourceBadge source={field.source} /></div>)}
      </div>
      <div className="alert alert-warning"><CircleAlert size={18} /><div><strong>DOMAIN GAP</strong><p>MGM, TCT, 3rd Scty Sys, dan Cu-Cap belum mempunyai definisi, tipe data, sumber, atau ownership yang disahkan. Field tersebut tidak dipetakan secara spekulatif.</p></div></div>
    </section>
  </div>;
}

function ConfigurationItem({ label, source, values, ready, locked, manageHref }: { label: string; source: SurveySheetFieldSource; values: string[]; ready: boolean; locked?: boolean; manageHref?: string }) {
  return <article className="survey-sheet-config-card">
    <header><div><h3>{label}</h3><SurveySheetFieldSourceBadge source={source} /></div><StatusBadge tone={ready ? "success" : "warning"}>{ready ? "Siap" : "Belum siap"}</StatusBadge></header>
    <div className="survey-sheet-config-values">{values.length ? values.map((value) => <span key={value}>{ready ? <CheckCircle2 size={15} /> : <CircleAlert size={15} />}{value}</span>) : <span><CircleAlert size={15} />Belum tersedia</span>}</div>
    <footer>{locked ? <span className="muted-text"><LockKeyhole size={14} /> Otomatis dan read-only</span> : null}{manageHref ? <Link className="text-link" href={manageHref}>Kelola konfigurasi</Link> : null}</footer>
  </article>;
}

const perContainerFields = [
  "Container Number", "Container Type", "Size", "ISO Type", "Manufacture Date", "Cargo Status",
  "CSC Plate Status", "CSC Plate Number", "CSC Approval Reference", "CSC Manufacture Date",
  "CSC Next Examination", "CSC Program Type", "Gross Weight", "Payload", "Tare"
];

const fieldOwnership: Array<{ label: string; source: SurveySheetFieldSource; locked: boolean }> = [
  { label: "Customer / Client", source: "Customer", locked: true },
  { label: "Container Nbrs", source: "Peti Kemas", locked: true },
  { label: "Type of Survey", source: "Job", locked: true },
  { label: "Survey Location", source: "Job", locked: true },
  { label: "Date of Survey", source: "Sistem", locked: true },
  { label: "Condition (DMG / AVL / AR)", source: "Surveyor", locked: false },
  { label: "Cleanliness (DTY / CTM)", source: "Surveyor", locked: false },
  { label: "Damage Location / Component / Damage / Action / Material", source: "Master CEDEX", locked: false }
];

function configuredText(value?: boolean) { return value ? "Sudah dikonfigurasi" : "Belum dikonfigurasi"; }
function normalizeSize(value?: string | null) { return (value ?? "").replace(/\s*(feet|foot|ft)$/i, "").trim(); }
function unique(values: string[]) { return Array.from(new Set(values)); }
