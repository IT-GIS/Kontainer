import { redirect } from "next/navigation";
export default async function LegacyResponsibilityCodesPage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const query = await searchParams;
  const customerId = first(query.customerId);
  redirect(`/master/iso-cedex?${customerId ? `customerId=${encodeURIComponent(customerId)}&` : ""}legacy=responsibility`);
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
