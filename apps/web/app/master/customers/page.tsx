import { ActualMasterDataIndexRoute, type ActualMasterDataSearchParams } from "@/components/master/customer-first-route";

export default function CustomersPage({ searchParams }: { searchParams: ActualMasterDataSearchParams }) {
  return <ActualMasterDataIndexRoute category="customer" searchParams={searchParams} />;
}
