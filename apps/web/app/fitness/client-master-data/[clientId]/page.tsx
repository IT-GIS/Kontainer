import { redirect } from "next/navigation";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessMasterCompatibilityNotice } from "@/components/fitness/client-master-data/client-pages";
import { AppShell } from "@/components/layout/app-shell";

export default async function FitnessClientMasterDetailCompatibilityPage({
  params,
  searchParams
}: {
  params: Promise<{ clientId: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const [{ clientId }, query] = await Promise.all([params, searchParams]);
  const tab = first(query.tab) ?? "summary";
  if (tab === "summary") redirect("/fitness/master-data/customers/" + clientId);
  if (tab === "locations") redirect("/fitness/master-data/locations/" + clientId);
  if (tab === "personnel") redirect("/fitness/master-data/surveyors/" + clientId);
  if (tab === "container-types") redirect("/fitness/master-data/container-types/" + clientId);

  return (
    <ProtectedRoute>
      <AppShell title="Master Data Customer lama" subtitle="Compatibility route Admin Kelaikan" breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/master-data/customers" }, { label: "Compatibility" }]}>
        <FitnessMasterCompatibilityNotice
          title="Master Data Customer lama"
          description="Tab lama ini tidak mempunyai padanan semantik langsung pada struktur client-first dan tidak dipetakan secara spekulatif."
          primary={{ label: "Buka Customer", href: "/fitness/master-data/customers/" + clientId }}
          secondary={{ label: "Pilih Kategori Master Data", href: "/fitness/master-data/customers" }}
        />
      </AppShell>
    </ProtectedRoute>
  );
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
