import {
  ClipboardList, FileText, Gauge, Settings, ShieldCheck, UsersRound
} from "lucide-react";
import type { NavigationLink, NavigationRouteMatch, NavigationWorkspace } from "@/constants/navigation";
import type { RoleCode } from "@/types/auth";

const admin: RoleCode[] = ["admin"];
const shared: RoleCode[] = ["admin", "supervisor", "management"];

const n = (
  label: string,
  href: string,
  icon: NavigationLink["icon"],
  roles: RoleCode[],
  permissions: string[],
  matches?: NavigationRouteMatch[]
): NavigationLink => ({ kind: "link", id: href, label, href, icon, roles, permissions, matches });

export const adminWorkspace: NavigationWorkspace = {
  id: "admin",
  label: "Admin",
  roles: shared,
  items: [
    n("Dashboard", "/dashboard", Gauge, ["admin", "management"], ["dashboard.view.all"]),
    n("Customer & Master", "/master/customers", UsersRound, admin, ["customers.view.all"], [
      { path: "/master/customers", mode: "prefix" },
      { path: "/master/locations", mode: "prefix" },
      { path: "/master/container-types", mode: "prefix" },
      { path: "/master/survey-types", mode: "prefix" }
    ]),
    n("Pekerjaan Inspeksi", "/jobs", ClipboardList, admin, ["jobs.view.all", "jobs.manage.all"], [
      { path: "/jobs", mode: "prefix" },
      { path: "/monitoring/surveys", mode: "prefix" },
      { path: "/surveys/monitoring", mode: "prefix" }
    ]),
    n("Review & Keputusan", "/review", ShieldCheck, shared, ["reviews.view.all", "reviews.manage.all"], [
      { path: "/review", mode: "prefix" }
    ]),
    n("Laporan", "/reports", FileText, shared, ["reports.view.all"], [
      { path: "/reports", mode: "prefix" }
    ]),
    n("Pengaturan", "/settings", Settings, shared, [
      "surveyors.view.all", "cedex_locations.view.all", "cedex_components.view.all",
      "cedex_damages.view.all", "cedex_repairs.view.all", "cedex_materials.view.all",
      "inspection_test_parameters.view.all", "fitness_checklist_templates.view.all",
      "evidence_photo_categories.view.all", "container_types.view.all", "survey_types.view.all",
      "users.view.all", "roles.view.all", "numbering_settings.view.all",
      "company_profiles.view.all", "audit.view.all"
    ], [
      { path: "/settings", mode: "prefix" },
      { path: "/master/surveyors", mode: "prefix" },
      { path: "/master/iso-cedex", mode: "prefix" },
      { path: "/master/cedex", mode: "prefix" },
      { path: "/master/responsibility-codes", mode: "prefix" },
      { path: "/master/inspection-references", mode: "prefix" }
    ])
  ]
};
