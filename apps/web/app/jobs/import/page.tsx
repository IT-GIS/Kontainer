import { redirect } from "next/navigation";

export default function LegacyJobImportPage() {
  redirect("/jobs?view=unassigned&compat=import");
}
