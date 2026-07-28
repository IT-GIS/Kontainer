import { redirect } from "next/navigation";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CustomerScopedMasterIndex } from "@/components/master/customer-scoped-master-data";
import { IsoCedexWorkspace, type IsoCedexTab } from "@/components/master/iso-cedex-workspace";

type Query = Promise<Record<string, string | string[] | undefined>>;

const canonicalTabs: IsoCedexTab[] = ["location", "component", "damage", "material", "action", "reference"];

export default async function IsoCedexPage({ searchParams }: { searchParams: Query }) {
  const query = await searchParams;
  const requestedTab = first(query.tab);
  const customerId = first(query.customerId);
  const requestedLegacy = first(query.legacy);

  if (requestedTab === "action-repair") {
    redirect(canonicalHref(customerId, "action"));
  }
  if (requestedTab === "responsibility") {
    redirect(legacyHref(customerId));
  }

  const activeTab = canonicalTabs.includes(requestedTab as IsoCedexTab) ? requestedTab as IsoCedexTab : "location";
  const legacyResponsibility = requestedLegacy === "responsibility";
  const pickerHref = legacyResponsibility
    ? "/master/iso-cedex?legacy=responsibility"
    : `/master/iso-cedex?tab=${activeTab}`;

  return (
    <ProtectedRoute roles={["super_admin", "admin", "supervisor", "management"]}>
      <AppShell
        title={legacyResponsibility ? "Responsibility Code (Legacy)" : "Master ISO CEDEX"}
        subtitle="Referensi inspeksi peti kemas yang aman terhadap konteks Customer."
        breadcrumbs={[{ label: "Master Data" }, { label: legacyResponsibility ? "Responsibility Code" : "ISO CEDEX" }]}
      >
        {!customerId ? (
          <CustomerScopedMasterIndex
            canonicalBaseHref={pickerHref}
            category={legacyResponsibility ? "responsibility-code" : "cedex-location"}
            routeFamily="actual"
          />
        ) : (
          <IsoCedexWorkspace
            customerId={customerId}
            initialTab={activeTab}
            showLegacyResponsibility={legacyResponsibility}
          />
        )}
      </AppShell>
    </ProtectedRoute>
  );
}

function canonicalHref(customerId: string | undefined, tab: IsoCedexTab) {
  const customer = customerId ? `customerId=${encodeURIComponent(customerId)}&` : "";
  return `/master/iso-cedex?${customer}tab=${tab}`;
}

function legacyHref(customerId: string | undefined) {
  const customer = customerId ? `customerId=${encodeURIComponent(customerId)}&` : "";
  return `/master/iso-cedex?${customer}legacy=responsibility`;
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
