import { redirect } from "next/navigation";

export default function LegacySubmittedSurveyPage() {
	redirect("/monitoring/surveys/submitted");
}
