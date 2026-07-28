import Link from "next/link";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { IsoCedexCodeProposals } from "@/components/master/iso-cedex-code-proposals";

export default function IsoCedexCodeProposalsPage() {
  return <ProtectedRoute roles={["super_admin", "admin", "supervisor", "management"]}><AppShell title="Pengajuan Kode ISO CEDEX" subtitle="Review aman sebelum kode tersedia pada pekerjaan berikutnya." breadcrumbs={[{ label: "Master Data" }, { label: "ISO CEDEX Code", href: "/master/iso-cedex" }, { label: "Pengajuan Kode" }]}><div className="page-stack"><Link className="secondary-button" href="/master/iso-cedex">&larr; Kembali ke ISO CEDEX Code</Link><IsoCedexCodeProposals /></div></AppShell></ProtectedRoute>;
}
