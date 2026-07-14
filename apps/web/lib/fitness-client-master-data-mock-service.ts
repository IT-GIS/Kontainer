import {
  fitnessClientContainerTypes,
  fitnessClientInspectionReferences,
  fitnessClientLocations,
  fitnessClientMasterSummaries,
  fitnessClientPersonnel,
  fitnessClients,
  fitnessLegacyMappings
} from "@/mocks/fitness-client-master-data";
import type {
  FitnessClientContainerType,
  FitnessClientDetail,
  FitnessClientInspectionReference,
  FitnessClientLocation,
  FitnessClientMasterSummary,
  FitnessClientPersonnel,
  FitnessClientSummary,
  FitnessInspectionReferenceSection,
  FitnessLegacyMappingRecord,
  FitnessLegacyMappingSection,
  FitnessMockMode,
  FitnessMockState
} from "@/types/fitness-admin";

const delayMs = 40;

export async function getFitnessClients(mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientSummary[]>> {
  await wait();
  return state(fitnessClients.map(toSummary), [], mode);
}

export async function getFitnessClientById(clientId: string, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientDetail | null>> {
  await wait();
  return state(fitnessClients.find((item) => item.id === clientId) ?? null, null, mode);
}

export async function getFitnessClientMasterSummary(clientId: string, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientMasterSummary | null>> {
  await wait();
  return state(fitnessClientMasterSummaries.find((item) => item.clientId === clientId) ?? null, null, mode);
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

export async function getFitnessClientInspectionReferences(clientId: string, section: FitnessInspectionReferenceSection, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessClientInspectionReference[]>> {
  await wait();
  return state(fitnessClientInspectionReferences.filter((item) => item.clientId === clientId && item.section === section), [], mode);
}

export async function getFitnessClientLegacyMappings(clientId: string, section: FitnessLegacyMappingSection, mode: FitnessMockMode = "success"): Promise<FitnessMockState<FitnessLegacyMappingRecord[]>> {
  await wait();
  return state(fitnessLegacyMappings.filter((item) => item.clientId === clientId && item.section === section), [], mode);
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
  if (mode === "error") return { status: "error", data: null, isLoading: false, error: "Data mock Klien belum dapat dimuat." };
  if (mode === "empty") return { status: "empty", data: emptyData, isLoading: false, error: null };
  return { status: "success", data, isLoading: false, error: null };
}

function wait() {
  return new Promise((resolve) => setTimeout(resolve, delayMs));
}
