"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function SurveyTypesPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Master Survey Type">
        <MasterDataPage resourceId="survey-types" />
      </AppShell>
    </ProtectedRoute>
  );
}