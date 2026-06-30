import { ArrowLeft, Clock3 } from "lucide-react";
import Link from "next/link";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";

type NavigationPlaceholderPageProps = {
  title: string;
  backHref: string;
  backLabel: string;
};

export function NavigationPlaceholderPage({ title, backHref, backLabel }: NavigationPlaceholderPageProps) {
  return (
    <ProtectedRoute>
      <AppShell title={title}>
        <div className="page-stack">
          <PageHeader title={title} description="Halaman tujuan menu sudah tersedia dan siap dikembangkan pada tahap berikutnya." />
          <section className="workspace-panel">
            <div className="section-title-row">
              <div><Clock3 size={22} /><h2>Status fitur</h2></div>
              <StatusBadge tone="warning">BELUM TERSEDIA</StatusBadge>
            </div>
            <p className="muted-text">Fitur ini belum tersedia. Tidak ada API atau business logic baru yang dipanggil dari halaman ini.</p>
            <Link className="secondary-button" href={backHref}><ArrowLeft size={17} /><span>{backLabel}</span></Link>
          </section>
        </div>
      </AppShell>
    </ProtectedRoute>
  );
}
