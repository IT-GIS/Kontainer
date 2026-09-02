import { redirect } from "next/navigation";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CustomerScopedMasterDetail, CustomerScopedMasterIndex } from "@/components/master/customer-scoped-master-data";
import { IsoCedexWorkspace, type IsoCedexTab } from "@/components/master/iso-cedex-workspace";

type Query = Promise<Record<string, string | string[] | undefined>>;

const canonicalTabs: IsoCedexTab[] = ["location", "component", "damage", "action", "material"];

export default async function IsoCedexPage({ searchParams }: { searchParams: Query }) {
  const query = await searchParams;
  const requestedSection = first(query.section);
  const requestedTab = requestedSection ?? first(query.tab);
  const customerId = first(query.customerId);
  const requestedLegacy = first(query.legacy);

  if (requestedTab === "action-repair") {
    redirect(canonicalHref("action"));
  }
  if (requestedTab === "responsibility") {
    redirect(legacyHref(customerId));
  }
  if (requestedTab === "reference") {
    redirect("/master/inspection-references?tab=test-parameter");
  }

  const activeTab = canonicalTabs.includes(requestedTab as IsoCedexTab) ? requestedTab as IsoCedexTab : "location";
  const legacyResponsibility = requestedLegacy === "responsibility";

  if (!legacyResponsibility && (first(query.scope) === "customer" || customerId)) {
    redirect(canonicalHref(activeTab));
  }

  return (
    <ProtectedRoute roles={["super_admin", "admin", "supervisor", "management"]}>
      <AppShell
        title={legacyResponsibility ? "Responsibility Code (Legacy)" : "Master CEDEX"}
        subtitle="Kamus teknis global dan override Customer untuk Temuan Surveyor."
        breadcrumbs={[{ label: "Customer & Master", href: "/master/customers" }, { label: legacyResponsibility ? "Responsibility Code" : "Master CEDEX" }]}
      >
        {legacyResponsibility && !customerId ? (
          <CustomerScopedMasterIndex
            canonicalBaseHref="/master/iso-cedex?legacy=responsibility"
            category="responsibility-code"
            routeFamily="actual"
          />
        ) : legacyResponsibility && customerId ? (
          <CustomerScopedMasterDetail
            category="responsibility-code"
            customerId={customerId}
            forceReadOnly
            forceReadOnlyMessage="Responsibility Code adalah referensi legacy dan hanya dapat dibaca."
            routeFamily="actual"
          />
        ) : (
          <IsoCedexWorkspace initialTab={activeTab} />
        )}
      </AppShell>
    </ProtectedRoute>
  );
}

function canonicalHref(tab: IsoCedexTab) {
  return `/master/iso-cedex?section=${tab}`;
}

function legacyHref(customerId: string | undefined) {
  const customer = customerId ? `customerId=${encodeURIComponent(customerId)}&` : "";
  return `/master/iso-cedex?${customer}legacy=responsibility`;
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
