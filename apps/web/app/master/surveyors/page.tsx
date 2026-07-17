import { ActualMasterDataIndexRoute, type ActualMasterDataSearchParams } from "@/components/master/customer-first-route";

export default function SurveyorsPage({ searchParams }: { searchParams: ActualMasterDataSearchParams }) {
  return <ActualMasterDataIndexRoute category="surveyor" searchParams={searchParams} />;
}
