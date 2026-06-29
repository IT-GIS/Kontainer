"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function CedexComponentsPage() {
  return (
    <ProtectedRoute>
      <AppShell title="CEDEX Component">
        <MasterDataPage resourceId="cedex-components" />
      </AppShell>
    </ProtectedRoute>
  );
}