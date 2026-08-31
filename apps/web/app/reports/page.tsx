import { Suspense } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DocumentReportWorkspace } from "@/components/reports/document-report-workspace";

export default function ReportsPage() {
  return <ProtectedRoute><AppShell title="Laporan" breadcrumbs={[{ label: "Laporan" }]}><Suspense fallback={<div className="center-screen">Memuat Laporan...</div>}><DocumentReportWorkspace /></Suspense></AppShell></ProtectedRoute>;
}
