"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function CedexRepairsPage() {
  return (
    <ProtectedRoute>
      <AppShell title="CEDEX Repair">
        <MasterDataPage resourceId="cedex-repairs" />
      </AppShell>
    </ProtectedRoute>
  );
}