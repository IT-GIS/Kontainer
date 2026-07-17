import {
  Activity, BarChart3, BookOpenCheck, Boxes, Building2, CheckCircle2, ClipboardCheck,
  ClipboardList, Clock3, Container, Database, FileClock, FilePlus2, FileText,
  Gauge, History, Layers, ListChecks, MapPin, PackageCheck, QrCode, RotateCcw, ScanSearch, Send,
  Settings,
  ShieldCheck, Tags, Truck, Upload, UserCog, UserRoundCheck, UsersRound, Wrench
} from "lucide-react";
import type {
  NavigationGroup, NavigationLink, NavigationRouteMatch, NavigationWorkspace
} from "@/constants/navigation";
import type { RoleCode } from "@/types/auth";

const admin: RoleCode[] = ["admin"];
const reviewer: RoleCode[] = ["admin", "supervisor"];
const reporter: RoleCode[] = ["admin", "supervisor", "management"];
const n = (
  label: string, href: string, icon: NavigationLink["icon"], roles: RoleCode[],
  permissions: string[], matches?: NavigationRouteMatch[]
): NavigationLink => ({ kind: "link", id: href, label, href, icon, roles, permissions, matches });
const g = (label: string, icon: NavigationLink["icon"], roles: RoleCode[], children: NavigationLink[]): NavigationGroup => ({
  kind: "group", id: label.toLowerCase().replaceAll(" ", "-"), label, icon, roles, children
});

export const adminWorkspace: NavigationWorkspace = {
  id: "admin",
  label: "Admin",
  roles: ["admin", "supervisor", "management"],
  items: [
    {
      ...n("Dashboard Admin", "/dashboard", Gauge, ["admin", "management"], ["dashboard.view.all"]),
      roleLabels: { management: "Dashboard" }
    },
    g("Master Data", Database, admin, [
      n("Customer", "/master/customers", UsersRound, admin, ["customers.view.all"], [{ path: "/master/customers", mode: "prefix" }]),
      n("Location", "/master/locations", MapPin, admin, ["locations.view.all"], [{ path: "/master/locations", mode: "prefix" }]),
      n("Surveyor", "/master/surveyors", UserRoundCheck, admin, ["surveyors.view.all"], [{ path: "/master/surveyors", mode: "prefix" }]),
      n("Container Type", "/master/container-types", Container, admin, ["container_types.view.all"], [{ path: "/master/container-types", mode: "prefix" }]),
      n("Survey Type", "/master/survey-types", ClipboardCheck, admin, ["survey_types.view.all"], [{ path: "/master/survey-types", mode: "prefix" }]),
      n("CEDEX Location", "/master/cedex/locations", MapPin, admin, ["cedex_locations.view.all"], [{ path: "/master/cedex/locations", mode: "prefix" }]),
      n("CEDEX Component", "/master/cedex/components", PackageCheck, admin, ["cedex_components.view.all"], [{ path: "/master/cedex/components", mode: "prefix" }]),
      n("CEDEX Damage", "/master/cedex/damages", Layers, admin, ["cedex_damages.view.all"], [{ path: "/master/cedex/damages", mode: "prefix" }]),
      n("CEDEX Repair", "/master/cedex/repairs", Wrench, admin, ["cedex_repairs.view.all"], [{ path: "/master/cedex/repairs", mode: "prefix" }]),
      n("CEDEX Material", "/master/cedex/materials", Boxes, admin, ["cedex_materials.view.all"], [{ path: "/master/cedex/materials", mode: "prefix" }]),
      n("Responsibility Code", "/master/responsibility-codes", Tags, admin, ["responsibility_codes.view.all"], [{ path: "/master/responsibility-codes", mode: "prefix" }])
    ]),
    g("Job Order", Truck, admin, [
      n("Job List", "/jobs", ClipboardList, admin, ["jobs.view.all", "jobs.manage.all"], [
        { path: "/jobs" }, { path: "/jobs/:id", mode: "pattern" }
      ]),
      n("Create Job", "/jobs/create", FilePlus2, admin, ["jobs.create.all", "jobs.manage.all"]),
      n("Import Container", "/jobs/import", Upload, admin, ["job_containers.import.all"], [
        { path: "/jobs/import" }, { path: "/jobs/:id/containers/import", mode: "pattern" }
      ]),
      n("Assign Surveyor", "/jobs/assign", UserRoundCheck, admin, ["assignments.assign.all", "assignments.manage.all"], [
        { path: "/jobs/assign" }, { path: "/jobs/:id", mode: "pattern", query: { action: "assign" } }
      ])
    ]),
    g("Monitoring Survey", ScanSearch, admin, [
      n("All Survey", "/surveys/monitoring", ClipboardCheck, admin, ["surveys.view.all"]),
      n("In Progress", "/surveys/monitoring/in-progress", Activity, admin, ["surveys.view.all"]),
      n("Submitted", "/surveys/monitoring/submitted", Send, admin, ["surveys.view.all"]),
      n("Need Revision", "/surveys/monitoring/need-revision", RotateCcw, admin, ["surveys.view.all"]),
      n("Approved", "/surveys/monitoring/approved", CheckCircle2, admin, ["surveys.view.all"])
    ]),
    g("Review", ShieldCheck, reviewer, [
      n("Pending Review", "/review/pending", Clock3, reviewer, ["reviews.view.all", "reviews.manage.all"], [
        { path: "/review/pending" }, { path: "/review/:id", mode: "pattern" }
      ]),
      n("Review History", "/review/history", History, reviewer, ["reviews.view.all"], [
        { path: "/review/history" }, { path: "/review/need-revision" }, { path: "/review/approved" }
      ])
    ]),
    g("Report", FileText, reporter, [
      n("Report Archive", "/reports", BookOpenCheck, reporter, ["reports.view.all"], [
        { path: "/reports" }, { path: "/reports/:id", mode: "pattern" }
      ]),
      n("Report Version", "/reports/versions", FileClock, ["admin", "supervisor"], ["reports.version.all"]),
      n("QR Validation", "/reports/qr-validation", QrCode, ["admin", "supervisor"], ["reports.view.all"])
    ]),
    g("Setting", Settings, admin, [
      n("Company Profile", "/settings/company-profile", Building2, admin, ["company_profiles.view.all", "company_profiles.manage.all"]),
      n("Numbering Setting", "/settings/numbering", ListChecks, admin, ["numbering_settings.view.all", "numbering_settings.manage.all"]),
      n("Audit Log", "/settings/audit-log", BarChart3, admin, ["audit.view.all"]),
      n("User Management", "/settings/users", UserCog, admin, ["users.view.all"]),
      {
        ...n("Role & Permission", "/settings/roles", ShieldCheck, admin, ["roles.view.all", "roles.manage.all"]),
        exactRoles: ["super_admin"]
      }
    ])
  ]
};
