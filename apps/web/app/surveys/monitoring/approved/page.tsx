import { redirect } from "next/navigation";

export default function LegacyApprovedSurveyPage() {
	redirect("/monitoring/surveys/approved");
}
