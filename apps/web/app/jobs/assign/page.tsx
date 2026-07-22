import { redirect } from "next/navigation";

export default function LegacyJobAssignPage() {
  redirect("/jobs?view=unassigned&compat=assign");
}
