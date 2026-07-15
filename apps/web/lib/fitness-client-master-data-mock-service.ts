import {
  fitnessClientContainerTypes,
  fitnessClientInspectionReferences,
  fitnessClientLocations,
  fitnessClientMasterDataReferences,
  fitnessClientPersonnel,
  fitnessClientSurveyors,
  fitnessClients
} from "@/mocks/fitness-client-master-data";
import type {
  FitnessClientContainerType,
  FitnessClientDetail,
  FitnessClientInspectionReference,
  FitnessClientLocation,
  FitnessClientMasterDataRecord,
  FitnessClientMasterDataReference,
  FitnessClientPersonnel,
  FitnessClientReferenceCategory,
  FitnessClientSummary,
  FitnessClientSurveyor,
  FitnessInspectionReferenceSection,
  FitnessMasterDataCategory,
  FitnessMasterDataCategorySummary,
  FitnessMockMode,
  FitnessMockState
} from "@/types/fitness-admin";

const delayMs = 40;
const customerOverviewCategories: Exclude<FitnessMasterDataCategory, "customer">[] = [
  "location",
  "surveyor",
  "container-type",
  "survey-type",
  "cedex-location",
  "cedex-component",
  "cedex-damage",
  "cedex-repair",
  "cedex-material",
  "responsibility-code"
];

export async function getFitnessClients(mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientSummary[]>> {
  await wait();
  return state(fitnessClients.map(toSummary), [], mode);
}

export async function getFitnessCustomers(mode: FitnessMockMode = "success") {
  return getFitnessClients(mode);
}

export async function getFitnessClientById(clientId: string, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientDetail | null>> {
  await wait();
  return state(fitnessClients.find((item) => item.id === clientId) ?? null, null, mode);
}

export async function getFitnessCustomerById(clientId: string, mode: FitnessMockMode = "success") {
  return getFitnessClientById(clientId, mode);
}

export async function getFitnessClientLocations(clientId: string, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientLocation[]>> {
  await wait();
  return state(fitnessClientLocations.filter((item) => item.clientId === clientId), [], mode);
}

export async function getFitnessClientPersonnel(clientId: string, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientPersonnel[]>> {
  await wait();
  return state(fitnessClientPersonnel.filter((item) => item.clientId === clientId), [], mode);
}

export async function getFitnessClientContainerTypes(clientId: string, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientContainerType[]>> {
  await wait();
  return state(fitnessClientContainerTypes.filter((item) => item.clientId === clientId), [], mode);
}

export async function getFitnessClientSurveyors(clientId: string, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientSurveyor[]>> {
  await wait();
  return state(fitnessClientSurveyors.filter((item) => item.clientId === clientId), [], mode);
}

export async function getFitnessClientSurveyTypes(clientId: string, mode: FitnessMockMode = "success") {
  return getFitnessClientMasterDataReferences(clientId, "survey-type", mode);
}

export async function getFitnessClientCedexLocations(clientId: string, mode: FitnessMockMode = "success") {
  return getFitnessClientMasterDataReferences(clientId, "cedex-location", mode);
}

export async function getFitnessClientCedexComponents(clientId: string, mode: FitnessMockMode = "success") {
  return getFitnessClientMasterDataReferences(clientId, "cedex-component", mode);
}

export async function getFitnessClientCedexDamages(clientId: string, mode: FitnessMockMode = "success") {
  return getFitnessClientMasterDataReferences(clientId, "cedex-damage", mode);
}

export async function getFitnessClientCedexRepairs(clientId: string, mode: FitnessMockMode = "success") {
  return getFitnessClientMasterDataReferences(clientId, "cedex-repair", mode);
}

export async function getFitnessClientCedexMaterials(clientId: string, mode: FitnessMockMode = "success") {
  return getFitnessClientMasterDataReferences(clientId, "cedex-material", mode);
}

export async function getFitnessClientResponsibilityCodes(clientId: string, mode: FitnessMockMode = "success") {
  return getFitnessClientMasterDataReferences(clientId, "responsibility-code", mode);
}

export async function getFitnessClientInspectionReferences(clientId: string, section: FitnessInspectionReferenceSection, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientInspectionReference[]>> {
  await wait();
  return state(fitnessClientInspectionReferences.filter((item) => item.clientId === clientId && item.section === section), [], mode);
}

export async function getFitnessClientMasterDataReferences(
  clientId: string,
  category: FitnessClientReferenceCategory,
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessClientMasterDataReference[]>> {
  await wait();
  return state(
    fitnessClientMasterDataReferences.filter((item) => item.clientId === clientId && item.category === category),
    [],
    mode
  );
}

export async function getFitnessMasterDataCategoryRecords(
  clientId: string,
  category: FitnessMasterDataCategory,
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessClientMasterDataRecord[]>> {
  await wait();
  return state(recordsForCategory(clientId, category), [], mode);
}

export async function getMasterDataCategorySummary(
  clientId: string,
  category: FitnessMasterDataCategory,
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessMasterDataCategorySummary | null>> {
  await wait();
  return state(categorySummary(clientId, category), null, mode);
}

export async function getFitnessCustomerMasterDataOverview(
  clientId: string,
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessMasterDataCategorySummary[] | null>> {
  await wait();
  const client = fitnessClients.find((item) => item.id === clientId);
  const overview = client ? customerOverviewCategories.map((category) => categorySummary(clientId, category)!) : null;
  return state(overview, null, mode);
}

function recordsForCategory(clientId: string, category: FitnessMasterDataCategory): FitnessClientMasterDataRecord[] {
  if (category === "location") return fitnessClientLocations.filter((item) => item.clientId === clientId);
  if (category === "surveyor") return fitnessClientSurveyors.filter((item) => item.clientId === clientId);
  if (category === "container-type") return fitnessClientContainerTypes.filter((item) => item.clientId === clientId);
  if (category === "customer") return [];
  return fitnessClientMasterDataReferences.filter((item) => item.clientId === clientId && item.category === category);
}

function categorySummary(clientId: string, category: FitnessMasterDataCategory): FitnessMasterDataCategorySummary | null {
  const client = fitnessClients.find((item) => item.id === clientId);
  if (!client) return null;
  if (category === "customer") {
    return {
      clientId,
      category,
      count: 1,
      activeCount: client.status === "Aktif" ? 1 : 0,
      inactiveCount: client.status === "Tidak Aktif" ? 1 : 0,
      updatedAt: client.updatedAt,
      completeness: "Lengkap"
    };
  }

  const records = recordsForCategory(clientId, category);
  const activeCount = records.filter((item) => item.status === "Aktif").length;
  return {
    clientId,
    category,
    count: records.length,
    activeCount,
    inactiveCount: records.length - activeCount,
    updatedAt: records[0]?.updatedAt ?? client.updatedAt,
    completeness: records.length > 0 ? "Lengkap" : "Belum Lengkap"
  };
}

function toSummary(client: FitnessClientDetail): FitnessClientSummary {
  const {
    address: _address,
    postalCode: _postalCode,
    legalIdentity: _legalIdentity,
    adminNotes: _adminNotes,
    accessInformation: _accessInformation,
    ...summary
  } = client;
  return summary;
}

function state<T>(data: T, emptyData: T, mode: FitnessMockMode): FitnessMockState<T> {
  if (mode === "loading") return { status: "loading", data: null, isLoading: true, error: null };
  if (mode === "error") return { status: "error", data: null, isLoading: false, error: "Data mock Customer belum dapat dimuat." };
  if (mode === "empty") return { status: "empty", data: emptyData, isLoading: false, error: null };
  return { status: "success", data, isLoading: false, error: null };
}

function wait() {
  return new Promise((resolve) => setTimeout(resolve, delayMs));
}
