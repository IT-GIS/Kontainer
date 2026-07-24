import { redirect } from "next/navigation";

export default async function FitnessClientMasterDetailCompatibilityPage({
  params,
  searchParams
}: {
  params: Promise<{ clientId: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const [{ clientId }, query] = await Promise.all([params, searchParams]);
  const tab = first(query.tab) ?? "summary";
  const targetTab = ({ summary: "profile", locations: "location", personnel: "personnel", history: "history", readiness: "readiness" } as Record<string, string>)[tab] ?? "readiness";
  redirect(`/master/customers/customer/${clientId}?tab=${targetTab}`);
}

function first(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] : value;
}
