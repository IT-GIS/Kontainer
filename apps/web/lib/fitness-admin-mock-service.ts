import {
  fitnessDashboardSummary, fitnessMasterDataGroups, fitnessPlaceholders, fitnessUiBPreview
} from "@/mocks/fitness-admin";
import type {
  FitnessMasterDataGroup, FitnessMockMode, FitnessMockState, FitnessNavigationSummary, FitnessPlaceholder, FitnessUiBPreview
} from "@/types/fitness-admin";

const delayMs = 40;

export async function getFitnessPlaceholder(
  path: string,
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessPlaceholder | null>> {
  await wait();
  return mockState(findFitnessPlaceholder(path), null, mode);
}

export async function getFitnessMasterDataGroups(
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessMasterDataGroup[]>> {
  await wait();
  return mockState(fitnessMasterDataGroups, [], mode);
}

export async function getFitnessDashboardSummary(
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessNavigationSummary[]>> {
  await wait();
  return mockState(fitnessDashboardSummary, [], mode);
}


export async function getFitnessUiBPreview(
  mode: FitnessMockMode = "success"
): Promise<FitnessMockState<FitnessUiBPreview>> {
  await wait();
  return mockState(fitnessUiBPreview, emptyUiBPreview(), mode);
}
export function createFitnessMockState<T>(
  data: T,
  emptyData: T,
  mode: FitnessMockMode = "success"
): FitnessMockState<T> {
  return mockState(data, emptyData, mode);
}

export function findFitnessPlaceholder(path: string): FitnessPlaceholder | null {
  const normalizedPath = normalizeFitnessPath(path);
  return fitnessPlaceholders.find((item) => {
    if (item.path === normalizedPath) return true;
    return item.compatibilityRoutes?.includes(normalizedPath) ?? false;
  }) ?? null;
}

export function normalizeFitnessPath(path: string): string {
  const [pathname, query = ""] = path.split("?");
  const normalizedPathname = pathname.replace(/\/$/, "") || "/fitness/dashboard";
  const search = new URLSearchParams(query);
  const orderedQuery = Array.from(search.entries())
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([key, value]) => `${key}=${value}`)
    .join("&");
  return orderedQuery ? `${normalizedPathname}?${orderedQuery}` : normalizedPathname;
}


function emptyUiBPreview(): FitnessUiBPreview {
  return {
    metrics: [],
    steps: [],
    progress: [],
    activities: [],
    records: [],
    filters: [],
    attachments: []
  };
}
function mockState<T>(data: T, emptyData: T, mode: FitnessMockMode): FitnessMockState<T> {
  if (mode === "loading") return { status: "loading", data: null, isLoading: true, error: null };
  if (mode === "error") {
    return {
      status: "error",
      data: null,
      isLoading: false,
      error: "Data tampilan belum dapat dimuat. Silakan coba lagi beberapa saat lagi."
    };
  }
  if (mode === "empty") return { status: "empty", data: emptyData, isLoading: false, error: null };
  return { status: "success", data, isLoading: false, error: null };
}

function wait() {
  return new Promise((resolve) => {
    setTimeout(resolve, delayMs);
  });
}