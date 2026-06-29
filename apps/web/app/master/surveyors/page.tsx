"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function SurveyorsPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Master Surveyor">
        <MasterDataPage resourceId="surveyors" />
      </AppShell>
    </ProtectedRoute>
  );
}