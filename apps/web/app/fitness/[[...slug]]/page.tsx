import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessPlaceholderPage } from "@/components/fitness/fitness-placeholder-page";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";
import { getFitnessPlaceholderByPath, type FitnessPlaceholder } from "@/constants/fitness-admin";

const activeMasterDataRoutes: Record<string, string> = {
  "/fitness/master-data/owners": "fitness-owners",
  "/fitness/master-data/manufacturers": "fitness-manufacturers",
  "/fitness/master-data/locations": "fitness-locations",
  "/fitness/master-data/surveyors": "fitness-surveyors",
  "/fitness/master-data/container-types": "fitness-container-types",
  "/fitness/master-data/approval-categories": "fitness-approval-categories"
};

type FitnessRouteProps = {
  params: Promise<{ slug?: string[] }>;
};

const fallbackPlaceholder: FitnessPlaceholder = {
  path: "/fitness/dashboard",
  title: "Dashboard Kelaikan",
  purpose: "Halaman placeholder Sistem Kelaikan Peti Kemas.",
  fields: ["Pilih salah satu menu Admin Kelaikan dari sidebar"],
  validations: ["Belum aktif - menunggu tahap berikutnya."],
  usedBy: ["Admin Kelaikan"],
  surveyorUsage: "Surveyor akan memakai data yang disiapkan Admin pada tahap berikutnya."
};

export default async function FitnessRoutePage({ params }: FitnessRouteProps) {
  const resolvedParams = await params;
  const slug = resolvedParams.slug ?? ["dashboard"];
  const path = `/fitness/${slug.join("/")}`;
  const activeResourceId = activeMasterDataRoutes[path];

  if (activeResourceId) {
    const item = getFitnessPlaceholderByPath(path) ?? fallbackPlaceholder;
    return (
      <ProtectedRoute>
        <AppShell title={item.title}>
          <MasterDataPage resourceId={activeResourceId} />
        </AppShell>
      </ProtectedRoute>
    );
  }

  const item = getFitnessPlaceholderByPath(path) ?? fallbackPlaceholder;
  return <FitnessPlaceholderPage item={item} />;
}
