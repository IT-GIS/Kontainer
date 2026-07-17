import {
  Archive,
  BarChart3,
  Boxes,
  ClipboardCheck,
  ClipboardList,
  Container,
  Database,
  FileText,
  Gauge,
  Layers,
  MapPin,
  PackageCheck,
  Settings,
  ShieldCheck,
  Tags,
  UserRoundCheck,
  UsersRound,
  Wrench
} from "lucide-react";
import type { NavigationGroup, NavigationLink, NavigationRouteMatch, NavigationWorkspace } from "@/constants/navigation";
import { fitnessMasterDataIndexHref } from "@/constants/fitness-master-data-client-first";
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

const g = (label: string, icon: NavigationLink["icon"], roles: RoleCode[], children: NavigationLink[]): NavigationGroup => ({
  kind: "group", id: label.toLowerCase().replaceAll(" ", "-"), label, icon, roles, children
});

export const containerFitnessAdminWorkspace: NavigationWorkspace = {
  id: "admin",
  label: "Admin Kelaikan",
  roles: ["admin", "supervisor", "management"],
  items: [
    n("Dashboard", "/fitness/dashboard", Gauge, readOnly),
    g("Klien & Master Data", Database, admin, [
      n("Customer", "/fitness/master-data/customers", UsersRound, admin, [
        { path: "/fitness/master-data/customers", mode: "prefix" },
        { path: "/fitness/clients", mode: "prefix" },
        { path: "/fitness/client-master-data", mode: "prefix" }
      ]),
      n("Location", "/fitness/master-data/locations", MapPin, admin, [
        { path: "/fitness/master-data/locations", mode: "prefix" },
        { path: "/fitness/client-master-data", mode: "prefix", query: { tab: "locations" } }
      ]),
      n("Surveyor", "/fitness/master-data/surveyors", UserRoundCheck, admin, [
        { path: "/fitness/master-data/surveyors", mode: "prefix" },
        { path: "/fitness/client-master-data", mode: "prefix", query: { tab: "personnel" } }
      ]),
      n("Container Type", fitnessMasterDataIndexHref("container-type"), Container, admin, [
        { path: "/fitness/master-data/container-types", mode: "prefix" },
        { path: "/fitness/client-master-data", mode: "prefix", query: { tab: "container-types" } }
      ]),
      n("Survey Type", fitnessMasterDataIndexHref("survey-type"), ClipboardCheck, admin, [{ path: "/fitness/master-data/survey-types", mode: "prefix" }]),
      n("CEDEX Location", fitnessMasterDataIndexHref("cedex-location"), MapPin, admin, [{ path: "/fitness/master-data/cedex-locations", mode: "prefix" }]),
      n("CEDEX Component", fitnessMasterDataIndexHref("cedex-component"), PackageCheck, admin, [{ path: "/fitness/master-data/cedex-components", mode: "prefix" }]),
      n("CEDEX Damage", fitnessMasterDataIndexHref("cedex-damage"), Layers, admin, [{ path: "/fitness/master-data/cedex-damages", mode: "prefix" }]),
      n("CEDEX Repair", fitnessMasterDataIndexHref("cedex-repair"), Wrench, admin, [{ path: "/fitness/master-data/cedex-repairs", mode: "prefix" }]),
      n("CEDEX Material", fitnessMasterDataIndexHref("cedex-material"), Boxes, admin, [{ path: "/fitness/master-data/cedex-materials", mode: "prefix" }]),
      n("Responsibility Code", "/fitness/master-data/responsibility-codes", Tags, admin, [{ path: "/fitness/master-data/responsibility-codes", mode: "prefix" }])
    ]),
    n("Permohonan", "/fitness/applications", ClipboardList, admin, [{ path: "/fitness/applications", mode: "prefix" }]),
    n("Peti Kemas", "/fitness/containers", Container, admin, [{ path: "/fitness/containers", mode: "prefix" }]),
    n("Penugasan Surveyor GIFT", "/fitness/assignments", UserRoundCheck, admin, [{ path: "/fitness/assignments", mode: "prefix" }]),
    n("Monitoring Pemeriksaan", "/fitness/inspections", ClipboardCheck, readOnly, [{ path: "/fitness/inspections", mode: "prefix" }]),
    n("Review & Keputusan", "/fitness/reviews", ShieldCheck, reviewer, [{ path: "/fitness/reviews", mode: "prefix" }]),
    n("Tindak Lanjut Perbaikan", "/fitness/repair-followups", Wrench, reviewer, [{ path: "/fitness/repair-followups", mode: "prefix" }]),
    n("Dokumen Kelaikan", "/fitness/documents", FileText, reporter, [{ path: "/fitness/documents", mode: "prefix" }]),
    n("Laporan", "/fitness/reports", BarChart3, reporter, [{ path: "/fitness/reports", mode: "prefix" }]),
    n("Pengaturan Internal GIFT", "/settings/company-profile", Settings, admin, [{ path: "/settings", mode: "prefix" }]),
    n("Arsip Lama", "/fitness/legacy-archive", Archive, readOnly, [{ path: "/fitness/legacy-archive", mode: "prefix" }])
  ]
};
