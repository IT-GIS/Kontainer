import {
  fitnessApplicationDraft,
  fitnessApplications,
  fitnessDashboardActions,
  fitnessDashboardActivities,
  fitnessDashboardMetrics,
  fitnessDashboardQuickActions
} from "@/mocks/fitness-dashboard-applications";
import type {
  FitnessApplicationDetail,
  FitnessApplicationDraft,
  FitnessApplicationReadiness,
  FitnessApplicationSummary,
  FitnessDashboardAction,
  FitnessDashboardMetric,
  FitnessDashboardSnapshot,
  FitnessMockMode,
  FitnessMockState
} from "@/types/fitness-admin";

const delayMs = 45;

export async function getFitnessDashboardSnapshot(
  filters: { clientId?: string; period?: "7-days" | "30-days" | "quarter" } = {},
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessDashboardSnapshot>> {
  await wait();
  const metricRows = filters.clientId ? fitnessDashboardMetrics.filter((item) => item.clientId === filters.clientId) : fitnessDashboardMetrics;
  const actionRows = filters.clientId ? fitnessDashboardActions.filter((item) => item.clientId === filters.clientId) : fitnessDashboardActions;
  const period = filters.period ?? "30-days";
  const activities = fitnessDashboardActivities.filter((item) => {
    const clientMatch = !filters.clientId || item.clientId === filters.clientId;
    const periodMatch = period === "quarter" || item.period === "7-days" || (period === "30-days" && item.period === "30-days");
    return clientMatch && periodMatch;
  });
  const data = {
    metrics: filters.clientId ? metricRows : aggregateMetrics(metricRows),
    actions: filters.clientId ? actionRows : aggregateActions(actionRows),
    activities,
    quickActions: fitnessDashboardQuickActions
  };
  return state(data, { metrics: [], actions: [], activities: [], quickActions: [] }, mode);
}

export async function getFitnessApplications(
  filters: { clientId?: string } = {},
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessApplicationSummary[]>> {
  await wait();
  const rows = fitnessApplications.filter((item) => !filters.clientId || item.clientId === filters.clientId).map(toSummary);
  return state(rows, [], mode);
}

export async function getFitnessApplicationById(
  applicationId: string,
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessApplicationDetail | null>> {
  await wait();
  return state(fitnessApplications.find((item) => item.id === applicationId) ?? null, null, mode);
}

export async function getFitnessApplicationReadiness(
  applicationId: string,
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessApplicationReadiness | null>> {
  await wait();
  return state(fitnessApplications.find((item) => item.id === applicationId)?.readiness ?? null, null, mode);
}

export async function getFitnessApplicationDraft(
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessApplicationDraft>> {
  await wait();
  return state(structuredClone(fitnessApplicationDraft), structuredClone(fitnessApplicationDraft), mode);
}

function toSummary(item: FitnessApplicationDetail): FitnessApplicationSummary {
  return {
    id: item.id,
    clientId: item.clientId,
    applicationNumber: item.applicationNumber,
    applicationDate: item.applicationDate,
    clientName: item.clientName,
    applicantName: item.applicantName,
    ownerUserName: item.ownerUserName,
    locationId: item.locationId,
    locationName: item.locationName,
    containerCount: item.containerCount,
    completeness: item.completeness,
    processStage: item.processStage,
    status: item.status,
    updatedAt: item.updatedAt
  };
}

function aggregateMetrics(rows: FitnessDashboardMetric[]): FitnessDashboardMetric[] {
  const grouped = new Map<string, FitnessDashboardMetric>();
  rows.forEach((row) => {
    const current = grouped.get(row.label);
    grouped.set(row.label, current ? { ...current, value: current.value + row.value, description: "Ringkasan seluruh klien aktif." } : { ...row, id: "all-" + row.icon, clientId: undefined, description: "Ringkasan seluruh klien aktif." });
  });
  return Array.from(grouped.values());
}

function aggregateActions(rows: FitnessDashboardAction[]): FitnessDashboardAction[] {
  const grouped = new Map<string, FitnessDashboardAction>();
  rows.forEach((row) => {
    const current = grouped.get(row.label);
    if (!current) {
      grouped.set(row.label, { ...row, id: "all-" + row.icon, clientId: undefined });
      return;
    }
    const count = current.count + row.count;
    grouped.set(row.label, { ...current, count, tone: count > 0 ? highestTone(current.tone, row.tone) : "neutral" });
  });
  return Array.from(grouped.values());
}

function highestTone(left: FitnessDashboardAction["tone"], right: FitnessDashboardAction["tone"]) {
  const rank = { neutral: 0, success: 1, info: 2, warning: 3, danger: 4 };
  return rank[right] > rank[left] ? right : left;
}

function state<T>(data: T, emptyData: T, mode: FitnessMockMode): FitnessMockState<T> {
  if (mode === "loading") return { status: "loading", data: null, isLoading: true, error: null };
  if (mode === "error") return { status: "error", data: null, isLoading: false, error: "Data mock Dashboard dan Permohonan belum dapat dimuat." };
  if (mode === "empty") return { status: "empty", data: emptyData, isLoading: false, error: null };
  return { status: "success", data, isLoading: false, error: null };
}

function wait() {
  return new Promise((resolve) => setTimeout(resolve, delayMs));
}
