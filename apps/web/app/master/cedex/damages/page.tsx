"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function CedexDamagesPage() {
  return (
    <ProtectedRoute>
      <AppShell title="CEDEX Damage">
        <MasterDataPage resourceId="cedex-damages" />
      </AppShell>
    </ProtectedRoute>
  );
}