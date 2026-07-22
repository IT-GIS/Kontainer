import { Suspense } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { InspectionWorkList } from "@/components/jobs/inspection-work-list";
import { AppShell } from "@/components/layout/app-shell";

export default function JobsPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Pekerjaan Inspeksi">
        <Suspense fallback={<div className="center-screen">Memuat pekerjaan inspeksi...</div>}>
          <InspectionWorkList />
        </Suspense>
      </AppShell>
    </ProtectedRoute>
  );
}
