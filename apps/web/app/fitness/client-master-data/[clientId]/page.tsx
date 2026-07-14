import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessClientMasterWorkspace, type ClientMasterSection, type ClientMasterTab } from "@/components/fitness/client-master-data/client-master-workspace";
import { AppShell } from "@/components/layout/app-shell";
import { ErrorState } from "@/components/ui/error-state";
import {
  getFitnessClientById,
  getFitnessClientContainerTypes,
  getFitnessClientInspectionReferences,
  getFitnessClientLegacyMappings,
  getFitnessClientLocations,
  getFitnessClientMasterSummary,
  getFitnessClientPersonnel
} from "@/lib/fitness-client-master-data-mock-service";
import type { FitnessInspectionReferenceSection, FitnessLegacyMappingSection } from "@/types/fitness-admin";

const validTabs: ClientMasterTab[] = ["summary", "locations", "personnel", "container-types", "inspection-references", "legacy-mapping"];
const referenceSections: FitnessInspectionReferenceSection[] = ["inspection-areas", "structural-components", "damage-criteria", "finding-severities", "test-parameters", "photo-categories", "inspection-recommendations"];
const legacySections: FitnessLegacyMappingSection[] = ["location", "component", "damage", "material"];

export default async function FitnessClientMasterDetailPage({ params, searchParams }: { params: Promise<{ clientId: string }>; searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const [{ clientId }, query] = await Promise.all([params, searchParams]);
  const tabValue = first(query.tab);
  const activeTab = validTabs.includes(tabValue as ClientMasterTab) ? tabValue as ClientMasterTab : "summary";
  const sectionValue = first(query.section);
  const referenceSection = referenceSections.includes(sectionValue as FitnessInspectionReferenceSection) ? sectionValue as FitnessInspectionReferenceSection : "inspection-areas";
  const legacySection = legacySections.includes(sectionValue as FitnessLegacyMappingSection) ? sectionValue as FitnessLegacyMappingSection : "location";
  const activeSection: ClientMasterSection = activeTab === "legacy-mapping" ? legacySection : referenceSection;

  const [clientState, summaryState, locationsState, personnelState, typesState, referencesState, legacyState] = await Promise.all([
    getFitnessClientById(clientId),
    getFitnessClientMasterSummary(clientId),
    getFitnessClientLocations(clientId),
    getFitnessClientPersonnel(clientId),
    getFitnessClientContainerTypes(clientId),
    getFitnessClientInspectionReferences(clientId, referenceSection),
    getFitnessClientLegacyMappings(clientId, legacySection)
  ]);

  const client = clientState.status === "success" ? clientState.data : null;
  const summary = summaryState.status === "success" ? summaryState.data : null;
  const ready = client && summary && locationsState.status === "success" && personnelState.status === "success" && typesState.status === "success" && referencesState.status === "success" && legacyState.status === "success";

  return (
    <ProtectedRoute>
      <AppShell title="Master Data Klien" subtitle={client ? client.name : "Konteks klien tidak tersedia"} breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/clients" }, { label: "Master Data Klien", href: "/fitness/client-master-data" }, { label: client?.name ?? clientId }, { label: tabLabel(activeTab) }]}>
        {ready ? (
          <FitnessClientMasterWorkspace
            client={client}
            summary={summary}
            locations={locationsState.data}
            personnel={personnelState.data}
            containerTypes={typesState.data}
            references={referencesState.data}
            legacyMappings={legacyState.data}
            activeTab={activeTab}
            activeSection={activeSection}
          />
        ) : (
          <ErrorState message="clientId tidak ditemukan atau data mock klien tidak lengkap." action={{ label: "Pilih Klien", href: "/fitness/client-master-data" }} />
        )}
      </AppShell>
    </ProtectedRoute>
  );
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}

function tabLabel(tab: ClientMasterTab) {
  return ({ summary: "Ringkasan", locations: "Lokasi", personnel: "Personel/PIC Klien", "container-types": "Jenis Peti Kemas", "inspection-references": "Referensi Pemeriksaan", "legacy-mapping": "Mapping Legacy" } as const)[tab];
}
