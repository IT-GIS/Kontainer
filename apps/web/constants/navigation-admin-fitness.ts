import {
  Archive,
  BarChart3,
  ClipboardCheck,
  ClipboardList,
  Container,
  FileText,
  Gauge,
  Settings,
  ShieldCheck,
  UserRoundCheck,
  UsersRound,
  Wrench
} from "lucide-react";
import type { NavigationLink, NavigationRouteMatch, NavigationWorkspace } from "@/constants/navigation";
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
): NavigationLink => ({ kind: "link", id: href + "#" + label, label, href, icon, roles, permissions, matches });

export const containerFitnessAdminWorkspace: NavigationWorkspace = {
  id: "admin",
  label: "Admin Kelaikan",
  roles: ["admin", "supervisor", "management"],
  items: [
    n("Dashboard", "/fitness/dashboard", Gauge, readOnly),
    n("Klien & Master Data", "/fitness/clients", UsersRound, admin, [
      { path: "/fitness/clients", mode: "prefix" },
      { path: "/fitness/client-master-data", mode: "prefix" },
      { path: "/fitness/master-data", mode: "prefix" }
    ]),
    n("Permohonan", "/fitness/applications", ClipboardList, admin, [{ path: "/fitness/applications", mode: "prefix" }]),
    n("Peti Kemas", "/fitness/containers", Container, admin, [{ path: "/fitness/containers", mode: "prefix" }]),
    n("Penugasan Surveyor", "/fitness/assignments", UserRoundCheck, admin, [{ path: "/fitness/assignments", mode: "prefix" }]),
    n("Pemeriksaan", "/fitness/inspections", ClipboardCheck, readOnly, [{ path: "/fitness/inspections", mode: "prefix" }]),
    n("Review & Keputusan", "/fitness/reviews", ShieldCheck, reviewer, [{ path: "/fitness/reviews", mode: "prefix" }]),
    n("Tindak Lanjut Perbaikan", "/fitness/repair-followups", Wrench, reviewer, [{ path: "/fitness/repair-followups", mode: "prefix" }]),
    n("Dokumen Kelaikan", "/fitness/documents", FileText, reporter, [{ path: "/fitness/documents", mode: "prefix" }]),
    n("Laporan", "/fitness/reports", BarChart3, reporter, [{ path: "/fitness/reports", mode: "prefix" }]),
    n("Pengaturan Internal GIFT", "/settings/company-profile", Settings, admin, [{ path: "/settings", mode: "prefix" }]),
    n("Arsip Lama", "/fitness/legacy-archive", Archive, readOnly, [{ path: "/fitness/legacy-archive", mode: "prefix" }])
  ]
};
