import { ProtectedRoute } from "@/components/auth/protected-route";
import { JobActionPicker } from "@/components/jobs/job-action-picker";
import { AppShell } from "@/components/layout/app-shell";

export default function ImportJobPickerPage() {
  return <ProtectedRoute><AppShell title="Import Container"><JobActionPicker mode="import" /></AppShell></ProtectedRoute>;
}
