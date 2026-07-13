import {
  Archive, BarChart3, Bell, Building2, ClipboardCheck, ClipboardList, Container,
  Database, FileText, Gauge, History, Upload, ListChecks, PenLine, Settings,
  ShieldCheck, UserCog, UserRoundCheck, Wrench
} from "lucide-react";
import type { NavigationGroup, NavigationLink, NavigationRouteMatch, NavigationWorkspace } from "@/constants/navigation";
import type { RoleCode } from "@/types/auth";

const admin: RoleCode[] = ["admin"];
const reviewer: RoleCode[] = ["admin", "supervisor"];
const reporter: RoleCode[] = ["admin", "supervisor", "management"];
const readOnly: RoleCode[] = ["admin", "supervisor", "management"];
const placeholderPermission = [""];

const n = (
  label: string,
  href: string,
  icon: NavigationLink["icon"],
  roles: RoleCode[],
  matches?: NavigationRouteMatch[],
  permissions: string[] = placeholderPermission
): NavigationLink => ({ kind: "link", id: `${href}#${label}`, label, href, icon, roles, permissions, matches });

const g = (label: string, icon: NavigationLink["icon"], roles: RoleCode[], children: NavigationLink[]): NavigationGroup => ({
  kind: "group",
  id: label.toLowerCase().replaceAll(" ", "-"),
  label,
  icon,
  roles,
  children
});

export const containerFitnessAdminWorkspace: NavigationWorkspace = {
  id: "admin",
  label: "Admin Kelaikan",
  roles: ["admin", "supervisor", "management"],
  items: [
    n("Dashboard", "/fitness/dashboard", Gauge, readOnly),
    g("Permohonan", ClipboardList, admin, [
      n("Daftar Permohonan", "/fitness/applications", ClipboardList, admin, [{ path: "/fitness/applications" }]),
      n("Buat Permohonan", "/fitness/applications/create", PenLine, admin),
      n("Permohonan Belum Lengkap", "/fitness/applications?status=incomplete", ClipboardCheck, admin, [
        { path: "/fitness/applications", query: { status: "incomplete" } }
      ])
    ]),
    g("Peti Kemas", Container, admin, [
      n("Daftar Peti Kemas", "/fitness/containers", Container, admin, [{ path: "/fitness/containers" }]),
      n("Import Peti Kemas", "/fitness/containers/import", Upload, admin),
      n("Validasi Data Teknis", "/fitness/containers?filter=technical-incomplete", ClipboardCheck, admin, [
        { path: "/fitness/containers", query: { filter: "technical-incomplete" } }
      ])
    ]),
    g("Penugasan", UserRoundCheck, admin, [
      n("Belum Ditugaskan", "/fitness/assignments?status=unassigned", UserRoundCheck, admin, [
        { path: "/fitness/assignments", query: { status: "unassigned" } },
        { path: "/fitness/assignments" }
      ]),
      n("Penugasan Aktif", "/fitness/assignments?status=active", ClipboardCheck, admin, [
        { path: "/fitness/assignments", query: { status: "active" } }
      ]),
      n("Riwayat Penugasan", "/fitness/assignments?status=history", History, admin, [
        { path: "/fitness/assignments", query: { status: "history" } }
      ])
    ]),
    n("Monitoring Pemeriksaan", "/fitness/inspections", ClipboardCheck, readOnly),
    n("Review & Keputusan", "/fitness/reviews", ShieldCheck, reviewer),
    n("Tindak Lanjut Perbaikan", "/fitness/repair-followups", Wrench, reviewer),
    n("Dokumen Kelaikan", "/fitness/documents", FileText, reporter),
    n("Laporan", "/fitness/reports", BarChart3, reporter),
    n("Master Data", "/fitness/master-data", Database, admin, [{ path: "/fitness/master-data" }]),
    g("Pengaturan", Settings, admin, [
      n("Profil Badan Usaha", "/settings/company-profile", Building2, admin),
      n("Pengaturan Penomoran", "/settings/numbering", ListChecks, admin),
      n("Audit Log", "/settings/audit-log", Bell, admin),
      n("Manajemen User", "/settings/users", UserCog, admin),
      { ...n("Role & Permission", "/settings/roles", ShieldCheck, admin), exactRoles: ["super_admin"] }
    ]),
    n("Arsip Lama", "/fitness/legacy-archive", Archive, readOnly)
  ]
};
