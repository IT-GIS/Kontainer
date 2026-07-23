import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CustomerScopedMasterDetail, CustomerScopedMasterIndex } from "@/components/master/customer-scoped-master-data";
import { PageHeader } from "@/components/ui/page-header";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";

type Query = Promise<Record<string, string | string[] | undefined>>;
type TabID = "location" | "component" | "damage" | "action-repair" | "material" | "responsibility";

const tabs: Array<{ id: TabID; label: string; category: FitnessMasterDataCategory }> = [
  { id: "location", label: "Location Code", category: "cedex-location" },
  { id: "component", label: "Component Code", category: "cedex-component" },
  { id: "damage", label: "Damage Code", category: "cedex-damage" },
  { id: "action-repair", label: "Action Repair Code", category: "cedex-repair" },
  { id: "material", label: "Material Code", category: "cedex-material" },
  { id: "responsibility", label: "Responsibility Code", category: "responsibility-code" }
];

export default async function IsoCedexPage({ searchParams }: { searchParams: Query }) {
  const query = await searchParams;
  const requestedTab = first(query.tab);
  const active = tabs.find((tab) => tab.id === requestedTab) ?? tabs[0];
  const customerId = first(query.customerId);
  const baseHref = "/master/iso-cedex?tab=" + active.id;

  return (
    <ProtectedRoute>
      <AppShell
        title="Master ISO CEDEX"
        subtitle="Kelola referensi kode inspeksi peti kemas yang digunakan dalam Survey Sheet dan pencatatan temuan."
        breadcrumbs={[{ label: "Master Data" }, { label: "ISO CEDEX" }]}
      >
        <div className="page-stack">
          <PageHeader
            title="Master ISO CEDEX"
            description="Kelola referensi kode yang digunakan dalam pencatatan hasil pemeriksaan peti kemas."
          />
          <WorkspaceTabs
            activeID={active.id}
            label="Referensi ISO CEDEX"
            tabs={tabs.map((tab) => ({ id: tab.id, label: tab.label, href: "/master/iso-cedex?tab=" + tab.id }))}
          />
          <div className="alert alert-warning">
            Data ISO CEDEX ditampilkan sesuai Customer yang dipilih.
          </div>
          {active.id === "location" ? (
            <div className="alert alert-warning">Gunakan kode lokasi yang telah disahkan dalam referensi teknis GIFT.</div>
          ) : null}
          {active.id === "action-repair" ? (
            <div className="alert alert-warning">Action Repair Code digunakan sebagai referensi atau rekomendasi tindakan pemeriksaan.</div>
          ) : null}
          {customerId ? (
            <CustomerScopedMasterDetail
              backHrefOverride={baseHref}
              category={active.category}
              customerId={customerId}
              routeFamily="actual"
            />
          ) : (
            <CustomerScopedMasterIndex
              canonicalBaseHref={baseHref}
              category={active.category}
              routeFamily="actual"
            />
          )}
        </div>
      </AppShell>
    </ProtectedRoute>
  );
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
