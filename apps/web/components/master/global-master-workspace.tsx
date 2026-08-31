"use client";

import Link from "next/link";
import { IsoCedexWorkspace, type IsoCedexTab } from "@/components/master/iso-cedex-workspace";
import { MasterDataPage } from "@/components/master/master-data-page";
import { PageHeader } from "@/components/ui/page-header";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { useAuth } from "@/hooks/use-auth";
import { canAny } from "@/lib/permissions";

export type GlobalMasterTab = "cedex" | "checklist" | "container-type" | "survey-type" | "photo-category" | "inspection-reference";

const tabs: Array<{ id: GlobalMasterTab; label: string; permissions: string[] }> = [
  { id: "cedex", label: "CEDEX", permissions: ["cedex_locations.view.all", "cedex_components.view.all", "cedex_damages.view.all", "cedex_repairs.view.all", "cedex_materials.view.all"] },
  { id: "checklist", label: "Checklist", permissions: ["fitness_checklist_templates.view.all"] },
  { id: "container-type", label: "Container Type", permissions: ["container_types.view.all"] },
  { id: "survey-type", label: "Survey Type", permissions: ["survey_types.view.all"] },
  { id: "photo-category", label: "Photo Category", permissions: ["evidence_photo_categories.view.all"] },
  { id: "inspection-reference", label: "Referensi Pemeriksaan", permissions: ["inspection_test_parameters.view.all"] }
];

export function GlobalMasterWorkspace({ activeTab, cedexSection }: { activeTab: GlobalMasterTab; cedexSection: IsoCedexTab }) {
  const { user } = useAuth();
  const visibleTabs = tabs.filter((tab) => canAny(user, tab.permissions));
  const allowed = visibleTabs.some((tab) => tab.id === activeTab);
  const effectiveTab = allowed ? activeTab : visibleTabs[0]?.id;
  return <div className="page-stack global-master-workspace">
    <PageHeader title="Master Global" description="Sumber global dikelola oleh role berwenang; override Customer tetap berada di Customer & Master." />
    <WorkspaceTabs activeID={effectiveTab ?? ""} label="Jenis Master Global" tabs={visibleTabs.map((tab) => ({ id: tab.id, label: tab.label, href: `/settings/master-global?tab=${tab.id}` }))} />
    {!effectiveTab ? <div className="alert alert-danger" role="alert">Permission untuk Master Global tidak tersedia. Backend tetap menjadi authority pada direct URL/API.</div> : null}
    {effectiveTab === "cedex" ? <IsoCedexWorkspace initialTab={cedexSection} /> : null}
    {effectiveTab === "checklist" ? <section className="workspace-panel page-stack"><h2>Checklist Global</h2><div className="alert alert-warning">Kontrak backend saat ini menyimpan template checklist per Customer dan belum menyediakan inheritance Global Template yang setara dengan effective CEDEX. Sistem tidak menyalin atau mengarang template global.</div><Link className="primary-button" href="/master/customers">Kelola Checklist per Customer</Link></section> : null}
    {effectiveTab === "container-type" ? <MasterDataPage resourceId="container-types" /> : null}
    {effectiveTab === "survey-type" ? <MasterDataPage resourceId="survey-types" /> : null}
    {effectiveTab === "photo-category" ? <MasterDataPage resourceId="fitness-photo-categories" /> : null}
    {effectiveTab === "inspection-reference" ? <MasterDataPage resourceId="fitness-test-parameters" /> : null}
  </div>;
}
