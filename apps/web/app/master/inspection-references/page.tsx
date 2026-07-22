import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { ChecklistReferenceTab } from "@/components/master/checklist-reference-tab";
import { CustomerScopedMasterDetail, CustomerScopedMasterIndex } from "@/components/master/customer-scoped-master-data";
import { MasterDataPage } from "@/components/master/master-data-page";
import { PageHeader } from "@/components/ui/page-header";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";

type Query = Promise<Record<string, string | string[] | undefined>>;
type TabID = "container-type" | "survey-type" | "checklist" | "test-parameter" | "photo-category" | "finding-severity";

const tabs: Array<{ id: TabID; label: string }> = [
  { id: "container-type", label: "Container Type" },
  { id: "survey-type", label: "Survey Type" },
  { id: "checklist", label: "Checklist" },
  { id: "test-parameter", label: "Test Parameter" },
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
        title="Referensi Pemeriksaan"
        subtitle="Kelola referensi pemeriksaan existing tanpa membuat nilai ambang, metode uji, atau standar baru."
        breadcrumbs={[{ label: "Master Data" }, { label: "Referensi Pemeriksaan" }]}
      >
        <div className="page-stack">
          <PageHeader title="Referensi Pemeriksaan" description="Container Type, Survey Type, Checklist, dan referensi teknis disatukan dalam enam tab." />
          <WorkspaceTabs
            activeID={active.id}
            label="Jenis Referensi Pemeriksaan"
            tabs={tabs.map((tab) => ({ id: tab.id, label: tab.label, href: "/master/inspection-references?tab=" + tab.id }))}
          />
          {category && customerId ? (
            <CustomerScopedMasterDetail backHrefOverride={baseHref} category={category} customerId={customerId} routeFamily="actual" />
          ) : null}
          {category && !customerId ? (
            <CustomerScopedMasterIndex canonicalBaseHref={baseHref} category={category} routeFamily="actual" />
          ) : null}
          {active.id === "checklist" ? <ChecklistReferenceTab baseHref={baseHref} customerId={customerId} /> : null}
          {globalResource ? <MasterDataPage resourceId={globalResource} /> : null}
        </div>
      </AppShell>
    </ProtectedRoute>
  );
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
