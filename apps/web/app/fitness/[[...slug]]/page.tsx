import { Gauge } from "lucide-react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessPlaceholderPage } from "@/components/fitness/fitness-placeholder-page";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";
import { getFitnessPlaceholderByPath, type FitnessPlaceholder } from "@/constants/fitness-admin";
import { masterResources } from "@/constants/master-data";

const activeMasterDataRoutes: Record<string, { resourceId: keyof typeof masterResources; title: string }> = {
  "/fitness/master-data/owners": { resourceId: "fitness-owners", title: "Pemilik Peti Kemas" },
  "/fitness/master-data/manufacturers": { resourceId: "fitness-manufacturers", title: "Pabrik Pembuat" },
  "/fitness/master-data/locations": { resourceId: "fitness-locations", title: "Lokasi" },
  "/fitness/master-data/surveyors": { resourceId: "fitness-surveyors", title: "Surveyor" },
  "/fitness/master-data/container-types": { resourceId: "fitness-container-types", title: "Jenis Peti Kemas" },
  "/fitness/master-data/approval-categories": { resourceId: "fitness-approval-categories", title: "Kategori Persetujuan" },
  "/fitness/master-data/maintenance-schemes": { resourceId: "fitness-maintenance-schemes", title: "Skema Pemeliharaan" },
  "/fitness/master-data/inspection-areas": { resourceId: "fitness-inspection-areas", title: "Area Pemeriksaan" },
  "/fitness/master-data/structural-components": { resourceId: "fitness-structural-components", title: "Komponen Struktur" },
  "/fitness/master-data/damage-criteria": { resourceId: "fitness-damage-criteria", title: "Kriteria Kerusakan" },
  "/fitness/master-data/finding-severities": { resourceId: "fitness-finding-severities", title: "Tingkat Keparahan" },
  "/fitness/master-data/test-parameters": { resourceId: "fitness-test-parameters", title: "Parameter Pengujian" },
  "/fitness/master-data/checklist-templates": { resourceId: "fitness-checklist-templates", title: "Template Checklist" },
  "/fitness/master-data/photo-categories": { resourceId: "fitness-photo-categories", title: "Kategori Bukti Foto" },
  "/fitness/master-data/inspection-recommendations": { resourceId: "fitness-inspection-recommendations", title: "Rekomendasi Pemeriksaan" },
  "/fitness/master-data/authorized-signers": { resourceId: "fitness-authorized-signers", title: "Pejabat Penandatangan" },
  "/fitness/master-data/company-profile": { resourceId: "fitness-company-profile", title: "Profil Badan Usaha" }
};

type FitnessRouteProps = {
  params: Promise<{ slug?: string[] }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const fallbackPlaceholder: FitnessPlaceholder = {
  path: "/fitness/dashboard",
  title: "Dashboard",
  subtitle: "Ringkasan Admin Kelaikan",
  description: "Pilih salah satu menu Admin Kelaikan dari sidebar.",
  icon: Gauge,
  status: "Dalam Pengembangan",
  features: ["Navigasi Admin Kelaikan tersedia dari sidebar."],
  primaryCta: { label: "Kembali ke Dashboard", href: "/fitness/dashboard" },
  breadcrumbs: [
    { label: "Admin Kelaikan", href: "/fitness/dashboard" },
    { label: "Dashboard" }
  ]
};

export default async function FitnessRoutePage({ params, searchParams }: FitnessRouteProps) {
  const [resolvedParams, resolvedSearchParams] = await Promise.all([params, searchParams]);
  const slug = resolvedParams.slug ?? ["dashboard"];
  const path = `/fitness/${slug.join("/")}`;
  const activeHref = buildActiveHref(path, resolvedSearchParams);
  const activeResource = activeMasterDataRoutes[path];

  const checklistTemplateItemsMatch = slug.length === 4 && slug[0] === "master-data" && slug[1] === "checklist-templates" && slug[3] === "items";
  if (checklistTemplateItemsMatch) {
    const templateId = slug[2];
    return (
      <ProtectedRoute>
        <AppShell
          title="Item Template Checklist"
          breadcrumbs={[
            { label: "Admin Kelaikan", href: "/fitness/dashboard" },
            { label: "Master Data", href: "/fitness/master-data" },
            { label: "Template Checklist", href: "/fitness/master-data/checklist-templates" },
            { label: "Item" }
          ]}
        >
          <MasterDataPage
            resourceId="fitness-checklist-template-items"
            endpointOverride={`/fitness/master-data/checklist-templates/${templateId}/items`}
            fixedValues={{ template_id: templateId }}
            backHref="/fitness/master-data/checklist-templates"
          />
        </AppShell>
      </ProtectedRoute>
    );
  }

  if (activeResource) {
    return (
      <ProtectedRoute>
        <AppShell
          title={activeResource.title}
          breadcrumbs={[
            { label: "Admin Kelaikan", href: "/fitness/dashboard" },
            { label: "Master Data", href: "/fitness/master-data" },
            { label: activeResource.title }
          ]}
        >
          <MasterDataPage resourceId={activeResource.resourceId} />
        </AppShell>
      </ProtectedRoute>
    );
  }

  const item = getFitnessPlaceholderByPath(activeHref) ?? getFitnessPlaceholderByPath(path) ?? fallbackPlaceholder;
  return <FitnessPlaceholderPage item={item} activeHref={activeHref} />;
}

function buildActiveHref(path: string, searchParams: Record<string, string | string[] | undefined>) {
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(searchParams)) {
    if (Array.isArray(value)) {
      value.forEach((item) => query.append(key, item));
    } else if (value !== undefined) {
      query.set(key, value);
    }
  }
  const queryText = query.toString();
  return queryText ? `${path}?${queryText}` : path;
}
