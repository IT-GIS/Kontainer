import { redirect } from "next/navigation";

export default function ReportVersionsPage() {
  redirect("/reports?view=archive&compat=versions");
}
