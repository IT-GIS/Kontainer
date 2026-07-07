export type AppScope = "legacy" | "container_fitness";

const validScopes: AppScope[] = ["legacy", "container_fitness"];

export function getAppScope(): AppScope {
  const scope = process.env.NEXT_PUBLIC_APP_SCOPE;
  return validScopes.includes(scope as AppScope) ? (scope as AppScope) : "legacy";
}

export function isContainerFitnessScope(): boolean {
  return getAppScope() === "container_fitness";
}
