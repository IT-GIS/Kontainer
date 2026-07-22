import { redirect } from "next/navigation";

export default function LegacyNeedRevisionSurveyPage() {
  redirect("/jobs?view=need-revision&compat=monitoring");
}
