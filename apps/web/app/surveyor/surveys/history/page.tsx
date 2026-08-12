import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { SurveyorSurveyList } from "@/components/surveys/surveyor-survey-list";

export default function SurveyHistoryPage() {
	return <ProtectedRoute><AppShell title="Riwayat Survey"><SurveyorSurveyList title="Riwayat Survey" description="Seluruh survey terminal lintas periode dengan filter hasil, Customer, peti kemas, dan tanggal." fixedStatus="terminal" history /></AppShell></ProtectedRoute>;
}
