import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default async function CustomerChecklistTemplateItemsPage({ params }: { params: Promise<{ clientId: string; templateId: string }> }) {
  const { clientId, templateId } = await params;
  const backHref = `/fitness/master-data/checklist-templates/${clientId}`;
  return <ProtectedRoute><AppShell title="Item Template Checklist" subtitle="Item ini akan disnapshot saat Start Survey.">
    <MasterDataPage
      resourceId="fitness-checklist-template-items"
      endpointOverride={`/fitness/master-data/checklist-templates/${templateId}/items`}
      fixedValues={{ template_id: templateId }}
      backHref={backHref}
    />
  </AppShell></ProtectedRoute>;
}
