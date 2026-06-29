"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default function CustomersPage() {
  return (
    <ProtectedRoute>
      <AppShell title="Master Customer">
        <MasterDataPage resourceId="customers" />
      </AppShell>
    </ProtectedRoute>
  );
}