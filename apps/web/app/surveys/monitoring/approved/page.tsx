import { redirect } from "next/navigation";

export default function LegacyApprovedSurveyPage() {
  redirect("/jobs?view=approved&compat=monitoring");
}
