import { ActualMasterDataIndexRoute, type ActualMasterDataSearchParams } from "@/components/master/customer-first-route";

export default function CedexMaterialsPage({ searchParams }: { searchParams: ActualMasterDataSearchParams }) {
  return <ActualMasterDataIndexRoute category="cedex-material" searchParams={searchParams} />;
}
