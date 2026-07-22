import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { MasterDataPage } from "@/components/master/master-data-page";

export default async function CustomerChecklistTemplatePage({ params }: { params: Promise<{ clientId: string }> }) {
  const { clientId } = await params;
  const backHref = "/fitness/master-data/checklist-templates";
  return <ProtectedRoute><AppShell title="Template Checklist Customer" subtitle="Customer terkunci dari route.">
    <MasterDataPage
      resourceId="fitness-checklist-templates"
      endpointOverride={`/customers/${clientId}/checklist-templates`}
      fixedValues={{ customer_id: clientId }}
      relationEndpointOverrides={{
        survey_type_id: `/customers/${clientId}/survey-types`,
        container_type_id: `/customers/${clientId}/container-types`
      }}
      checklistItemsBaseHref={`/fitness/master-data/checklist-templates/${clientId}`}
      backHref={backHref}
    />
  </AppShell></ProtectedRoute>;
}
