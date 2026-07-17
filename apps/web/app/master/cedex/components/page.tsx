import { ActualMasterDataIndexRoute, type ActualMasterDataSearchParams } from "@/components/master/customer-first-route";

export default function CedexComponentsPage({ searchParams }: { searchParams: ActualMasterDataSearchParams }) {
  return <ActualMasterDataIndexRoute category="cedex-component" searchParams={searchParams} />;
}
