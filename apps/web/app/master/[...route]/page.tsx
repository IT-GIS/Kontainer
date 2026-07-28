import { notFound, redirect } from "next/navigation";
import { ActualCustomerCreate } from "@/components/master/customer-first-route";

const canonicalTabByPath: Record<string, string> = {
  "container-types": "/master/inspection-references?tab=container-type",
  "survey-types": "/master/inspection-references?tab=survey-type",
  "cedex/locations": "/master/iso-cedex?tab=location",
  "cedex/components": "/master/iso-cedex?tab=component",
  "cedex/damages": "/master/iso-cedex?tab=damage",
  "cedex/repairs": "/master/iso-cedex?tab=action",
  "cedex/materials": "/master/iso-cedex?tab=material",
  "responsibility-codes": "/master/iso-cedex?legacy=responsibility"
};

export default async function ActualMasterDataDynamicPage({ params }: { params: Promise<{ route: string[] }> }) {
  const { route } = await params;
  if (route.join("/") === "customers/create") return <ActualCustomerCreate />;
  if (route.length < 3 || route.at(-2) !== "customer") notFound();

  const customerId = route.at(-1);
  const legacyPath = route.slice(0, -2).join("/");
  if (!customerId) notFound();
  if (legacyPath === "customers") redirect("/master/customers/customer/" + customerId);
  if (legacyPath === "locations") redirect("/master/customers/customer/" + customerId + "?tab=location");
  if (legacyPath === "surveyors") redirect("/master/customers/customer/" + customerId + "?tab=personnel");

  const canonical = canonicalTabByPath[legacyPath];
  if (canonical) redirect(canonical + "&customerId=" + customerId);
  notFound();
}
