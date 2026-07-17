import { notFound } from "next/navigation";
import {
  ActualCustomerCreate,
  ActualMasterDataDetailRoute,
  type ActualMasterDataSearchParams
} from "@/components/master/customer-first-route";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";

const categoryByActualPath: Record<string, FitnessMasterDataCategory> = {
  customers: "customer",
  locations: "location",
  surveyors: "surveyor",
  "container-types": "container-type",
  "survey-types": "survey-type",
  "cedex/locations": "cedex-location",
  "cedex/components": "cedex-component",
  "cedex/damages": "cedex-damage",
  "cedex/repairs": "cedex-repair",
  "cedex/materials": "cedex-material",
  "responsibility-codes": "responsibility-code"
};

export default async function ActualMasterDataDynamicPage({
  params,
  searchParams
}: {
  params: Promise<{ route: string[] }>;
  searchParams: ActualMasterDataSearchParams;
}) {
  const { route } = await params;
  if (route.join("/") === "customers/create") {
    return <ActualCustomerCreate />;
  }

  if (route.length < 3 || route.at(-2) !== "customer") {
    notFound();
  }

  const customerId = route.at(-1);
  const category = categoryByActualPath[route.slice(0, -2).join("/")];
  if (!category || !customerId) {
    notFound();
  }

  return <ActualMasterDataDetailRoute category={category} customerId={customerId} searchParams={searchParams} />;
}
