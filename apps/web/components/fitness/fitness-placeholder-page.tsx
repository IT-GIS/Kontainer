import { ProtectedRoute } from "@/components/auth/protected-route";
import {
  DashboardSummary, EmptyDevelopmentNote, FeaturePlaceholder, MasterDataIndex
} from "@/components/fitness/fitness-ui-a";
import { AppShell } from "@/components/layout/app-shell";
import {
  getFitnessDashboardSummary, getFitnessMasterDataGroups
} from "@/lib/fitness-admin-mock-service";
import type { FitnessPlaceholder } from "@/types/fitness-admin";

type FitnessPlaceholderPageProps = {
  item: FitnessPlaceholder;
  activeHref?: string;
};

export async function FitnessPlaceholderPage({ item, activeHref = item.path }: FitnessPlaceholderPageProps) {
  const [dashboardSummary, masterDataGroups] = await Promise.all([
    getFitnessDashboardSummary(),
    getFitnessMasterDataGroups()
  ]);
  const isDashboard = item.path === "/fitness/dashboard";
  const isMasterDataIndex = item.path === "/fitness/master-data";

  return (
    <ProtectedRoute>
      <AppShell
        title={item.title}
        subtitle={item.subtitle}
        breadcrumbs={item.breadcrumbs}
        actions={item.secondaryCta ? [{ label: item.secondaryCta.label, href: item.secondaryCta.href, variant: "secondary" }] : []}
      >
        <div className="page-stack">
          <FeaturePlaceholder item={item} activeHref={activeHref} />
          {isDashboard ? <DashboardSummary items={dashboardSummary.data} /> : null}
          {isMasterDataIndex ? <MasterDataIndex groups={masterDataGroups.data} /> : null}
          {!isDashboard && !isMasterDataIndex ? <EmptyDevelopmentNote /> : null}
        </div>
      </AppShell>
    </ProtectedRoute>
  );
}
