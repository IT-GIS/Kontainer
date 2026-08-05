import { redirect } from "next/navigation";

export default function LegacySurveyInProgressPage() {
	redirect("/monitoring/surveys/in-progress");
}
