import { ProtectedRoute } from "@/components/auth/protected-route";
import {
  DashboardSummary, EmptyDevelopmentNote, FeaturePlaceholder, FitnessDesignPatternPreview, MasterDataIndex
} from "@/components/fitness/fitness-ui-a";
import { AppShell } from "@/components/layout/app-shell";
import {
  getFitnessDashboardSummary, getFitnessMasterDataGroups, getFitnessUiBPreview
} from "@/lib/fitness-admin-mock-service";
import type { FitnessPlaceholder } from "@/types/fitness-admin";

type FitnessPlaceholderPageProps = {
  item: FitnessPlaceholder;
  activeHref?: string;
};

export async function FitnessPlaceholderPage({ item, activeHref = item.path }: FitnessPlaceholderPageProps) {
  const [dashboardSummary, masterDataGroups, uiBPreview] = await Promise.all([
    getFitnessDashboardSummary(),
    getFitnessMasterDataGroups(),
    getFitnessUiBPreview()
  ]);
  const isDashboard = item.path === "/fitness/dashboard";
  const isMasterDataIndex = item.path === "/fitness/master-data";

  return (
    <ProtectedRoute>
      <AppShell
        title={item.title}
        subtitle={item.subtitle}
        breadcrumbs={item.breadcrumbs}
      >
        <div className="page-stack">
          <FeaturePlaceholder item={item} activeHref={activeHref} />
          {isDashboard ? <DashboardSummary state={dashboardSummary} /> : null}
          {isMasterDataIndex ? <MasterDataIndex state={masterDataGroups} /> : null}
          {!isDashboard && !isMasterDataIndex ? <FitnessDesignPatternPreview state={uiBPreview} /> : null}
          {!isDashboard && !isMasterDataIndex ? <EmptyDevelopmentNote /> : null}
        </div>
      </AppShell>
    </ProtectedRoute>
  );
}