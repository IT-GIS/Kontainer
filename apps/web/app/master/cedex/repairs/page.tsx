import { ActualMasterDataIndexRoute, type ActualMasterDataSearchParams } from "@/components/master/customer-first-route";

export default function CedexRepairsPage({ searchParams }: { searchParams: ActualMasterDataSearchParams }) {
  return <ActualMasterDataIndexRoute category="cedex-repair" searchParams={searchParams} />;
}
