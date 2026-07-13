import {
  fitnessDashboardSummary, fitnessMasterDataGroups, fitnessPlaceholders
} from "@/mocks/fitness-admin";
import type {
  FitnessMasterDataGroup, FitnessMockState, FitnessNavigationSummary, FitnessPlaceholder
} from "@/types/fitness-admin";

const delayMs = 40;

export async function getFitnessPlaceholder(path: string): Promise<FitnessMockState<FitnessPlaceholder | null>> {
  await wait();
  return {
    status: "success",
    data: findFitnessPlaceholder(path),
    isLoading: false,
    error: null
  };
}

export async function getFitnessMasterDataGroups(): Promise<FitnessMockState<FitnessMasterDataGroup[]>> {
  await wait();
  return {
    status: "success",
    data: fitnessMasterDataGroups,
    isLoading: false,
    error: null
  };
}

export async function getFitnessDashboardSummary(): Promise<FitnessMockState<FitnessNavigationSummary[]>> {
  await wait();
  return {
    status: "success",
    data: fitnessDashboardSummary,
    isLoading: false,
    error: null
  };
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

function wait() {
  return new Promise((resolve) => {
    setTimeout(resolve, delayMs);
  });
}
