export { fitnessMasterDataGroups, fitnessPlaceholders } from "@/mocks/fitness-admin";
export type { FitnessPlaceholder } from "@/types/fitness-admin";

import { fitnessMasterDataGroups } from "@/mocks/fitness-admin";
import { findFitnessPlaceholder, normalizeFitnessPath } from "@/lib/fitness-admin-mock-service";

export const masterDataItems = fitnessMasterDataGroups.flatMap((group) =>
  group.items.map((item) => ({
    label: item.label,
    href: item.href,
    activeStage: item.status === "Aktif"
  }))
);

export function getFitnessPlaceholderByPath(path: string) {
  return findFitnessPlaceholder(path) ?? undefined;
}

export function getFitnessStageMessage(path: string): string {
  const normalizedPath = normalizeFitnessPath(path);
  if (normalizedPath === "/fitness/master-data") {
    return "Aktif - index Master Data Admin Kelaikan.";
  }
  if (masterDataItems.some((item) => item.href === normalizedPath && item.activeStage)) {
    return "Aktif - CRUD Master Data.";
  }
  return "Dalam Pengembangan - disiapkan untuk tahap UI berikutnya.";
}
