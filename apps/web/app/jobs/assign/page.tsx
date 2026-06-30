import { ProtectedRoute } from "@/components/auth/protected-route";
import { JobActionPicker } from "@/components/jobs/job-action-picker";
import { AppShell } from "@/components/layout/app-shell";

export default function AssignJobPickerPage() {
  return <ProtectedRoute><AppShell title="Assign Surveyor"><JobActionPicker mode="assign" /></AppShell></ProtectedRoute>;
}
