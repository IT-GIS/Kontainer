import { redirect } from "next/navigation";
export default async function LegacyCedexRepairsPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const query = await searchParams;
  const customerId = first(query.customerId);
  redirect(`/master/iso-cedex?${customerId ? `customerId=${encodeURIComponent(customerId)}&` : ""}tab=action`);
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
