import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { GlobalMasterWorkspace, type GlobalMasterTab } from "@/components/master/global-master-workspace";
import type { IsoCedexTab } from "@/components/master/iso-cedex-workspace";

type Query = Promise<Record<string, string | string[] | undefined>>;
const masterTabs: GlobalMasterTab[] = ["cedex", "checklist", "container-type", "survey-type", "photo-category", "inspection-reference"];
const cedexTabs: IsoCedexTab[] = ["location", "component", "damage", "action", "material"];

export default async function MasterGlobalPage({ searchParams }: { searchParams: Query }) {
  const query = await searchParams;
  const requested = first(query.tab);
  const activeTab = masterTabs.includes(requested as GlobalMasterTab) ? requested as GlobalMasterTab : "cedex";
  const requestedSection = first(query.section);
  const cedexSection = cedexTabs.includes(requestedSection as IsoCedexTab) ? requestedSection as IsoCedexTab : "location";
  return <ProtectedRoute roles={["admin", "supervisor", "management"]}><AppShell title="Master Global" breadcrumbs={[{ label: "Pengaturan", href: "/settings" }, { label: "Master Global" }]}><GlobalMasterWorkspace activeTab={activeTab} cedexSection={cedexSection} /></AppShell></ProtectedRoute>;
}

function first(value: string | string[] | undefined) { return Array.isArray(value) ? value[0] : value; }
