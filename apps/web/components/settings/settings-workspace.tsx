"use client";

import { BookOpenCheck, Building2, Hash, ShieldCheck, UserCog, UserRoundCheck } from "lucide-react";
import { ActionCard } from "@/components/ui/action-card";
import { useAuth } from "@/hooks/use-auth";
import { canAny } from "@/lib/permissions";

const settings = [
  { title: "Surveyor GIFT", description: "Kelola profil Surveyor internal yang menerima penugasan.", href: "/master/surveyors", icon: UserRoundCheck, permissions: ["surveyors.view.all"] },
  { title: "Master Global", description: "CEDEX, Container Type, Survey Type, Photo Category, Checklist, dan Referensi Pemeriksaan.", href: "/settings/master-global", icon: BookOpenCheck, permissions: ["cedex_locations.view.all", "cedex_components.view.all", "cedex_damages.view.all", "cedex_repairs.view.all", "cedex_materials.view.all", "fitness_checklist_templates.view.all", "container_types.view.all", "survey_types.view.all", "evidence_photo_categories.view.all", "inspection_test_parameters.view.all"] },
  { title: "User & Hak Akses", description: "Kelola akun, role, dan permission tanpa menjadikan sidebar sebagai security boundary.", href: "/settings/users", icon: UserCog, permissions: ["users.view.all", "roles.view.all"] },
  { title: "Penomoran", description: "Konfigurasi sequence nomor operasional existing.", href: "/settings/numbering", icon: Hash, permissions: ["numbering_settings.view.all", "numbering_settings.manage.all"] },
  { title: "Company Profile", description: "Profil perusahaan untuk metadata internal yang tersedia.", href: "/settings/company-profile", icon: Building2, permissions: ["company_profiles.view.all", "company_profiles.manage.all"] },
  { title: "Audit Log", description: "Telusuri aktivitas dan perubahan yang tercatat oleh backend.", href: "/settings/audit-log", icon: ShieldCheck, permissions: ["audit.view.all"] }
];

export function SettingsWorkspace() {
  const { user } = useAuth();
  const visible = settings.filter((item) => canAny(user, item.permissions));
  return <div className="page-stack settings-workspace">
    <section className="workspace-panel"><h2>Pengaturan</h2><p className="muted-text">Tampilkan hanya area yang diizinkan untuk peran dan permission aktif.</p></section>
    <div className="settings-card-grid">
      {visible.map((item) => <ActionCard key={item.title} {...item} />)}
    </div>
    {visible.length === 0 ? <div className="alert alert-warning">Tidak ada workspace Pengaturan yang tersedia untuk permission aktif.</div> : null}
  </div>;
}
