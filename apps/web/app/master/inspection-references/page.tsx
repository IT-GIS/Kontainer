import { ProtectedRoute } from "@/components/auth/protected-route";
import Link from "next/link";
import { AppShell } from "@/components/layout/app-shell";
import { ChecklistReferenceTab } from "@/components/master/checklist-reference-tab";
import { CustomerScopedMasterDetail, CustomerScopedMasterIndex } from "@/components/master/customer-scoped-master-data";
import { MasterDataPage } from "@/components/master/master-data-page";
import { PageHeader } from "@/components/ui/page-header";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";

type Query = Promise<Record<string, string | string[] | undefined>>;
type TabID = "container-type" | "survey-type" | "checklist" | "test-parameter" | "decision-rule" | "photo-category" | "finding-severity";

const tabs: Array<{ id: TabID; label: string }> = [
  { id: "container-type", label: "Container Type" },
  { id: "survey-type", label: "Survey Type" },
  { id: "checklist", label: "Checklist" },
  { id: "test-parameter", label: "Test Parameter" },
  { id: "decision-rule", label: "Tolerance & Decision Rule" },
  { id: "photo-category", label: "Photo Category" },
  { id: "finding-severity", label: "Finding Severity" }
];

const scopedCategories: Partial<Record<TabID, FitnessMasterDataCategory>> = {
  "container-type": "container-type",
  "survey-type": "survey-type"
};

const globalResources = {
  "test-parameter": "fitness-test-parameters",
  "photo-category": "fitness-photo-categories",
  "finding-severity": "fitness-finding-severities"
} as const;

export default async function InspectionReferencesPage({ searchParams }: { searchParams: Query }) {
  const query = await searchParams;
  const active = tabs.find((tab) => tab.id === first(query.tab)) ?? tabs[0];
  const customerId = first(query.customerId);
  const baseHref = "/master/inspection-references?tab=" + active.id;
  const category = scopedCategories[active.id];
  const globalResource = globalResources[active.id as keyof typeof globalResources];

  return (
    <ProtectedRoute>
      <AppShell
        title="Acuan & Kriteria Pemeriksaan"
        subtitle="Kelola Inspection Reference dan Decision Rule tervalidasi untuk Inspeksi Kelaikan."
        breadcrumbs={[{ label: "Pengaturan", href: "/settings" }, { label: "Master Global", href: "/settings/master-global" }, { label: "Referensi Pemeriksaan" }]}
      >
        <div className="page-stack">
          <Link className="secondary-button" href="/master/iso-cedex">&larr; Kembali ke ISO CEDEX Code</Link>
          <PageHeader title="Acuan & Kriteria Pemeriksaan" description="Inspection Reference menyediakan dasar pemeriksaan; Tolerance & Decision Rule hanya boleh diisi dari sumber teknis yang telah diverifikasi." />
          <WorkspaceTabs
            activeID={active.id}
            label="Jenis Referensi Pemeriksaan"
            tabs={tabs.map((tab) => ({ id: tab.id, label: tab.label, href: "/master/inspection-references?tab=" + tab.id }))}
          />
          {category && customerId ? (
            <>
              {active.id === "survey-type" ? (
                <div className="alert alert-warning">Survey Type adalah referensi legacy baca-saja. Mapping Inspection Reference untuk tipe yang sudah ada tetap dapat dikelola melalui konfigurasi di bawah.</div>
              ) : null}
              <CustomerScopedMasterDetail
                backHrefOverride={baseHref}
                category={category}
                customerId={customerId}
                routeFamily="actual"
                forceReadOnly={active.id === "survey-type"}
                forceReadOnlyMessage="Survey Type lama dipertahankan dalam mode baca-saja; sistem tidak membuat tipe atau kode baru."
                referenceConfigurationReadOnly={active.id === "survey-type" ? false : undefined}
              />
            </>
          ) : null}
          {category && !customerId ? (
            <CustomerScopedMasterIndex canonicalBaseHref={baseHref} category={category} routeFamily="actual" />
          ) : null}
          {active.id === "checklist" ? <ChecklistReferenceTab baseHref={baseHref} customerId={customerId} /> : null}
          {active.id === "decision-rule" ? <MasterDataPage
            resourceId="cedex-decision-rules"
            endpointOverride="/master/cedex/decision-rules"
            relationEndpointOverrides={{
              damage_id: "/master/cedex/damages",
              component_id: "/master/cedex/components",
              location_id: "/master/cedex/locations",
              material_id: "/master/cedex/materials",
              container_type_id: "/master/container-types",
              recommended_action_id: "/master/cedex/repairs"
            }}
            showToolbarAdd
            showRichEmptyState
            enableExport
            enableSaveAndNew
            enableSorting
            responsiveCards
            dialogSize="large"
            addButtonLabelOverride="+ Tambah Decision Rule"
            dialogTitleOverride="Decision Rule"
            emptyTitle="Belum ada Decision Rule global"
            emptyDescription="Tambahkan hanya rule yang memiliki Inspection Reference dan nilai tolerance tervalidasi."
          /> : null}
          {globalResource ? <MasterDataPage resourceId={globalResource} /> : null}
        </div>
      </AppShell>
    </ProtectedRoute>
  );
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
