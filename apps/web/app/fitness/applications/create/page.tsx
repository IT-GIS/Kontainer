import { redirect } from "next/navigation";

export default async function FitnessApplicationCreatePage() {
  redirect("/jobs/create");
}
