import { redirect } from "next/navigation";

export default async function FitnessClientDetailCompatibilityPage({ params }: { params: Promise<{ clientId: string }> }) {
  const { clientId } = await params;
  redirect("/master/customers/customer/" + clientId);
}
