import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { CustomerDetailWorkspace } from "@/components/master/customer-detail-workspace";
import { customerSetupTabs, type CustomerSetupTab } from "@/components/master/customer-setup-tabs";
import type { SurveySheetConfigurationSection } from "@/components/master/survey-sheet-configuration";
import type { IsoCedexTab } from "@/components/master/iso-cedex-workspace";

type Query = Promise<Record<string, string | string[] | undefined>>;
const cedexTabs: IsoCedexTab[] = ["location", "component", "damage", "action", "material"];
const surveySheetSections: SurveySheetConfigurationSection[] = ["overview", "survey-types", "container-types"];

export default async function CustomerDetailPage({
  params,
  searchParams
}: {
  params: Promise<{ customerId: string }>;
  searchParams: Query;
}) {
  const { customerId } = await params;
  const query = await searchParams;
  const requested = first(query.tab);
  const legacyTab = requested === "personnel" || requested === "location"
    ? "location-pic"
    : requested === "history"
      ? "profile"
      : requested === "survey-type" || requested === "container-type"
        ? "survey-sheet"
        : requested;
  const activeTab = customerSetupTabs.some((tab) => tab.id === legacyTab) ? legacyTab as CustomerSetupTab : "profile";
  const requestedSection = first(query.section);
  const cedexSection = cedexTabs.includes(requestedSection as IsoCedexTab) ? requestedSection as IsoCedexTab : "location";
  const legacySurveySheetSection = requested === "survey-type" ? "survey-types" : requested === "container-type" ? "container-types" : requestedSection;
  const surveySheetSection = surveySheetSections.includes(legacySurveySheetSection as SurveySheetConfigurationSection)
    ? legacySurveySheetSection as SurveySheetConfigurationSection
    : "overview";

  return (
    <ProtectedRoute>
      <AppShell
        title="Setup Customer"
        subtitle="Lengkapi Customer sampai siap operasional dari satu workspace."
        breadcrumbs={[{ label: "Customer & Master", href: "/master/customers" }, { label: "Setup Customer" }]}
      >
        <CustomerDetailWorkspace activeTab={activeTab} cedexSection={cedexSection} customerId={customerId} surveySheetSection={surveySheetSection} />
      </AppShell>
    </ProtectedRoute>
  );
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
