"use client";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";

export default function SurveyorProfilePage() {
  return <ProtectedRoute><AppShell title="Profil"><SurveyorProfileContent /></AppShell></ProtectedRoute>;
}

function SurveyorProfileContent() {
  const { user } = useAuth();
  return <div className="page-stack">
    <PageHeader title="Profil" description="Identitas akun Surveyor yang sedang aktif." />
    <section className="workspace-panel">
      <div className="detail-grid">
        <div><span>Nama</span><strong>{user?.name ?? "-"}</strong></div>
        <div><span>Email</span><strong>{user?.email ?? "-"}</strong></div>
        <div><span>Role aktif</span><strong>{user?.roles.join(", ") ?? "-"}</strong></div>
        <div><span>Surveyor Profile ID</span><strong>{user?.profile?.surveyor_profile_id ?? "-"}</strong></div>
      </div>
    </section>
  </div>;
}
