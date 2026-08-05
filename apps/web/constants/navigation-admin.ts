import {
  BookOpenCheck, Building2, ClipboardList, Database, FilePlus2, FileText, Gauge,
  ListChecks, Settings, ShieldCheck, UserCog, UserRoundCheck, UsersRound
} from "lucide-react";
import type { NavigationGroup, NavigationLink, NavigationRouteMatch, NavigationWorkspace } from "@/constants/navigation";
import type { RoleCode } from "@/types/auth";

const admin: RoleCode[] = ["admin"];
const shared: RoleCode[] = ["admin", "supervisor", "management"];
const n = (label: string, href: string, icon: NavigationLink["icon"], roles: RoleCode[], permissions: string[], matches?: NavigationRouteMatch[]): NavigationLink =>
  ({ kind: "link", id: href, label, href, icon, roles, permissions, matches });

const g = (label: string, icon: NavigationLink["icon"], roles: RoleCode[], children: NavigationLink[]): NavigationGroup =>
  ({ kind: "group", id: label, label, icon, roles, children });

export const adminWorkspace: NavigationWorkspace = {
  id: "admin",
  label: "Admin",
  roles: shared,
  items: [
    { ...n("Dashboard", "/dashboard", Gauge, ["admin", "management"], ["dashboard.view.all"]), roleLabels: { management: "Dashboard" } },
    g("Pekerjaan Inspeksi", ClipboardList, admin, [
      n("Semua Pekerjaan", "/jobs", ClipboardList, admin, ["jobs.view.all", "jobs.manage.all"], [
        { path: "/jobs" },
        { path: "/jobs/:id", mode: "pattern" },
        { path: "/jobs/import" },
		{ path: "/jobs/assign" }
      ]),
      n("Buat Job/SPK", "/jobs/create", FilePlus2, admin, ["jobs.create.all", "jobs.manage.all"])
    ]),
	g("Monitoring Survey", Gauge, shared, [
		n("Semua Survey", "/monitoring/surveys", Gauge, shared, ["surveys.view.all"], [
			{ path: "/monitoring/surveys", mode: "prefix" },
			{ path: "/surveys/monitoring", mode: "prefix" }
		])
	]),
    g("Master Data", Database, shared, [
      n("Customer", "/master/customers", UsersRound, admin, ["customers.view.all"], [
        { path: "/master/customers", mode: "prefix" },
        { path: "/master/locations", mode: "prefix" }
      ]),
      n("ISO CEDEX", "/master/iso-cedex", BookOpenCheck, shared, [
        "cedex_locations.view.all", "cedex_components.view.all", "cedex_damages.view.all",
        "cedex_repairs.view.all", "cedex_materials.view.all", "inspection_test_parameters.view.all", "responsibility_codes.view.all"
      ], [
        { path: "/master/iso-cedex", mode: "prefix" },
        { path: "/master/cedex", mode: "prefix" },
        { path: "/master/responsibility-codes", mode: "prefix" }
		]),
		n("Referensi Pemeriksaan", "/master/inspection-references", ListChecks, shared, ["inspection_test_parameters.view.all"], [
			{ path: "/master/inspection-references", mode: "prefix" }
		])
    ]),
    g("Review & Keputusan", ShieldCheck, shared, [
      n("Menunggu Review", "/review/pending", ShieldCheck, shared, ["reviews.view.all", "reviews.manage.all"], [
        { path: "/review/pending" },
        { path: "/review/:id", mode: "pattern" }
      ]),
      n("Riwayat Keputusan", "/review/history", ClipboardList, shared, ["reviews.view.all"], [
        { path: "/review/history" },
        { path: "/review/need-revision" },
        { path: "/review/approved" }
      ])
    ]),
    g("Dokumen & Laporan", FileText, shared, [
      n("Laporan Pemeriksaan", "/reports", FileText, shared, ["reports.view.all"], [
        { path: "/reports" },
        { path: "/reports/:id", mode: "pattern" },
        { path: "/reports/qr-validation" }
      ]),
      n("Arsip Laporan", "/reports?view=archive", ClipboardList, shared, ["reports.view.all", "reports.version.all"], [
        { path: "/reports", query: { view: "archive" } },
        { path: "/reports/versions" }
      ])
    ]),
    g("Pengaturan", Settings, admin, [
      n("Surveyor GIFT", "/master/surveyors", UserRoundCheck, admin, ["surveyors.view.all"], [
        { path: "/master/surveyors", mode: "prefix" }
      ]),
      n("Company Profile", "/settings/company-profile", Building2, admin, ["company_profiles.view.all", "company_profiles.manage.all"]),
      n("Penomoran", "/settings/numbering", ListChecks, admin, ["numbering_settings.view.all", "numbering_settings.manage.all"]),
      n("User & Hak Akses", "/settings/users", UserCog, admin, ["users.view.all", "roles.view.all", "roles.manage.all"], [
        { path: "/settings/users", mode: "prefix" },
        { path: "/settings/roles", mode: "prefix" }
      ]),
      n("Audit Log", "/settings/audit-log", ShieldCheck, admin, ["audit.view.all"])
    ])
  ]
};
