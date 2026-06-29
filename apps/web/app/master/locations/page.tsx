"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function LocationsPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Master Location">
        <MasterDataPage resourceId="locations" />
      </AppShell>
    </ProtectedRoute>
  );
}