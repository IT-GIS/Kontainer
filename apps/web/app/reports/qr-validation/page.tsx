import { ArrowLeft, QrCode } from "lucide-react";
import Link from "next/link";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";

export default function QRValidationCompatibilityPage() {
  return <ProtectedRoute><AppShell title="QR Validation"><div className="page-stack"><PageHeader title="QR Validation" description="Status ketersediaan validasi dokumen." /><section className="workspace-panel job-tab-stack"><div className="section-title-row"><div><QrCode size={22} /><h2>Fitur belum aktif</h2></div><StatusBadge tone="warning">BELUM AKTIF</StatusBadge></div><p className="muted-text">PDF final, QR, dan verifikasi publik belum tersedia.</p><Link className="secondary-button" href="/reports"><ArrowLeft size={17} /><span>Kembali ke Dokumen Kelaikan</span></Link></section></div></AppShell></ProtectedRoute>;
}
