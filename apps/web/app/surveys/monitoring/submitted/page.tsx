import { redirect } from "next/navigation";

export default function LegacySubmittedSurveyPage() {
  redirect("/jobs?view=pending-review&compat=monitoring");
}
