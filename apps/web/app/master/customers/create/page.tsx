"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage, type MasterRow } from "@/components/master/master-data-page";
import { useRouter } from "next/navigation";

export default function CreateCustomerPage() {
  const router = useRouter();

  function continueOnboarding(row: MasterRow, mode: "create" | "edit") {
    if (mode !== "create" || !row.id) return;
    router.replace(`/master/customers/customer/${encodeURIComponent(String(row.id))}?tab=location-pic`);
  }

  return <ProtectedRoute><AppShell title="Tambah Customer" subtitle="Langkah 1 dari onboarding Customer. Setelah profil tersimpan, lanjutkan Location, PIC, dan mapping tanpa kembali ke daftar." breadcrumbs={[{ label: "Customer & Master", href: "/master/customers" }, { label: "Tambah Customer" }]}><MasterDataPage backHref="/master/customers" dialogTitleOverride="Profil Customer" onSaved={continueOnboarding} resourceId="customers" startInCreateMode submitLabelOverride="Simpan & Lanjut" /></AppShell></ProtectedRoute>;
}
