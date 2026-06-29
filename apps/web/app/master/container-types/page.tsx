"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function ContainerTypesPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Master Container Type">
        <MasterDataPage resourceId="container-types" />
      </AppShell>
    </ProtectedRoute>
  );
}