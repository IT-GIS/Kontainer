import { redirect } from "next/navigation";

export default function LegacySurveyInProgressPage() {
  redirect("/jobs?view=in-progress&compat=monitoring");
}
