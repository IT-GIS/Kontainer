import { redirect } from "next/navigation";

export default function LegacySurveyMonitoringPage() {
  redirect("/jobs?view=in-progress&compat=monitoring");
}
