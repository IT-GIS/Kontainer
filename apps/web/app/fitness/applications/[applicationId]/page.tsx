import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessApplicationDetailWorkspace, type FitnessApplicationDetailTab } from "@/components/fitness/applications/application-detail-workspace";
import { AppShell } from "@/components/layout/app-shell";
import { ErrorState } from "@/components/ui/error-state";
import { getFitnessApplicationById } from "@/lib/fitness-dashboard-applications-mock-service";

const validTabs: FitnessApplicationDetailTab[] = ["summary", "containers", "assignment", "inspection", "review", "documents", "history"];

export default async function FitnessApplicationDetailPage({ params, searchParams }: { params: Promise<{ applicationId: string }>; searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const [{ applicationId }, query] = await Promise.all([params, searchParams]);
  const tabValue = Array.isArray(query.tab) ? query.tab[0] : query.tab;
  const activeTab = validTabs.includes(tabValue as FitnessApplicationDetailTab) ? tabValue as FitnessApplicationDetailTab : "summary";
  const state = await getFitnessApplicationById(applicationId);
  const application = state.status === "success" ? state.data : null;
  return <ProtectedRoute>
    <AppShell title="Detail Permohonan" subtitle={application?.applicationNumber ?? "Permohonan tidak ditemukan"} breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Permohonan", href: "/fitness/applications" }, { label: application?.applicationNumber ?? applicationId }, { label: activeTabLabel(activeTab) }]}>
      {application ? <FitnessApplicationDetailWorkspace application={application} activeTab={activeTab} /> : <ErrorState message="Permohonan tidak ditemukan pada mock UI-C." action={{ label: "Kembali ke Daftar", href: "/fitness/applications" }} />}
    </AppShell>
  </ProtectedRoute>;
}

function activeTabLabel(tab: FitnessApplicationDetailTab) {
  return ({ summary: "Ringkasan", containers: "Peti Kemas", assignment: "Penugasan", inspection: "Pemeriksaan", review: "Review", documents: "Dokumen", history: "Riwayat" } as const)[tab];
}
