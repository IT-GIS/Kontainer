import {
  Archive, BarChart3, Building2, ClipboardCheck, ClipboardList, Container, Database,
  FileText, Gauge, History, ListChecks, MapPin, PackageCheck, PenLine, Settings,
  ShieldCheck, Tags, Upload, UserCog, UserRoundCheck, UsersRound, Wrench
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
  matches?: NavigationRouteMatch[]
): NavigationLink => ({ kind: "link", id: `${href}#${label}`, label, href, icon, roles, permissions: placeholderPermission, matches });

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
    n("Dashboard Kelaikan", "/fitness/dashboard", Gauge, readOnly),
    g("Master Data Kelaikan", Database, admin, [
      n("Pemilik Peti Kemas", "/fitness/master-data/owners", UsersRound, admin),
      n("Pabrik Pembuat Peti Kemas", "/fitness/master-data/manufacturers", Building2, admin),
      n("Lokasi Pemeriksaan", "/fitness/master-data/locations", MapPin, admin),
      n("Surveyor / Pemeriksa", "/fitness/master-data/surveyors", UserRoundCheck, admin),
      n("Jenis / Model Peti Kemas", "/fitness/master-data/container-types", Container, admin),
      n("Kategori Persetujuan Kelaikan", "/fitness/master-data/approval-categories", ClipboardCheck, admin),
      n("Skema Pemeliharaan Peti Kemas", "/fitness/master-data/maintenance-schemes", Wrench, admin),
      n("Area Pemeriksaan Peti Kemas", "/fitness/master-data/inspection-areas", MapPin, admin),
      n("Komponen Struktur Peti Kemas", "/fitness/master-data/structural-components", PackageCheck, admin),
      n("Kriteria Kerusakan / Ketidaksesuaian", "/fitness/master-data/damage-criteria", Tags, admin),
      n("Tingkat Temuan / Severity", "/fitness/master-data/finding-severities", BarChart3, admin),
      n("Parameter Pengujian Kelaikan", "/fitness/master-data/test-parameters", ListChecks, admin),
      n("Template Checklist Kelaikan", "/fitness/master-data/checklist-templates", ClipboardList, admin),
      n("Kategori Foto Evidence", "/fitness/master-data/photo-categories", Upload, admin),
      n("Rekomendasi Hasil Pemeriksaan", "/fitness/master-data/inspection-recommendations", ShieldCheck, admin),
      n("Pejabat Penandatangan", "/fitness/master-data/authorized-signers", PenLine, admin),
      n("Profil Badan Usaha", "/fitness/master-data/company-profile", Building2, admin)
    ]),
    g("Permohonan Kelaikan", ClipboardList, admin, [
      n("Daftar Permohonan", "/fitness/applications", ClipboardList, admin, [{ path: "/fitness/applications", mode: "prefix" }]),
      n("Data Peti Kemas", "/fitness/containers", Container, admin),
      n("Import Data Peti Kemas", "/fitness/containers", Upload, admin),
      n("Assign Surveyor", "/fitness/assignments", UserRoundCheck, admin)
    ]),
    g("Pemeriksaan & Pengujian", ClipboardCheck, readOnly, [
      n("Monitoring Pemeriksaan", "/fitness/inspections", ClipboardCheck, readOnly),
      n("Pemeriksaan Berjalan", "/fitness/inspections", Gauge, readOnly),
      n("Perlu Perbaikan", "/fitness/inspections", Wrench, readOnly),
      n("Siap Re-Inspection", "/fitness/inspections", History, readOnly),
      n("Re-Inspection", "/fitness/inspections", History, readOnly),
      n("Layak", "/fitness/inspections", ShieldCheck, readOnly),
      n("Tidak Layak", "/fitness/inspections", Archive, readOnly)
    ]),
    g("Review & Keputusan Kelaikan", ShieldCheck, reviewer, [
      n("Pending Review", "/fitness/reviews", ShieldCheck, reviewer),
      n("Riwayat Review", "/fitness/reviews", History, reviewer),
      n("Keputusan Kelaikan", "/fitness/reviews", ClipboardCheck, reviewer),
      n("Pembebasan Setelah Perbaikan", "/fitness/reviews", FileText, reviewer)
    ]),
    g("Dokumen Kelaikan", FileText, reporter, [
      n("Surat Persetujuan Kelaikan", "/fitness/documents", FileText, reporter),
      n("Surat Persetujuan Peti Kemas Baru Individual", "/fitness/documents", FileText, reporter),
      n("Surat Persetujuan Peti Kemas Lama", "/fitness/documents", FileText, reporter),
      n("Surat Pembebasan Setelah Perbaikan", "/fitness/documents", FileText, reporter),
      n("Data CSC Safety Approval Plate", "/fitness/documents", ClipboardCheck, reporter),
      n("Validasi Dokumen", "/fitness/documents", ShieldCheck, reporter)
    ]),
    g("Laporan", BarChart3, reporter, [
      n("Rekap Pemeriksaan", "/fitness/reports", BarChart3, reporter),
      n("Rekap Peti Kemas Layak", "/fitness/reports", ShieldCheck, reporter),
      n("Rekap Peti Kemas Tidak Layak", "/fitness/reports", Archive, reporter),
      n("Rekap Perlu Perbaikan", "/fitness/reports", Wrench, reporter),
      n("Rekap Re-Inspection", "/fitness/reports", History, reporter),
      n("Rekap Pemilik Peti Kemas", "/fitness/reports", UsersRound, reporter),
      n("Rekap Pabrik Pembuat", "/fitness/reports", Building2, reporter),
      n("Laporan Kegiatan 6 Bulanan", "/fitness/reports", FileText, reporter)
    ]),
    g("Setting", Settings, admin, [
      n("Company Profile", "/settings/company-profile", Building2, admin),
      n("Numbering Setting", "/settings/numbering", ListChecks, admin),
      n("Audit Log", "/settings/audit-log", BarChart3, admin),
      n("User Management", "/settings/users", UserCog, admin),
      { ...n("Role & Permission", "/settings/roles", ShieldCheck, admin), exactRoles: ["super_admin"] }
    ]),
    n("Arsip Survey Lama", "/fitness/legacy-archive", Archive, readOnly)
  ]
};
