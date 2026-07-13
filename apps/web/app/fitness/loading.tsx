import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { Skeleton } from "@/components/ui/skeleton";

export default function FitnessLoading() {
  return (
    <ProtectedRoute>
      <AppShell
        title="Admin Kelaikan"
        subtitle="Kelola permohonan, pemeriksaan, review, dan dokumen kelaikan peti kemas."
        breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Memuat" }]}
      >
        <div className="page-stack">
          <section className="feature-placeholder skeleton-panel" aria-busy="true" aria-label="Memuat halaman">
            <div className="feature-placeholder-hero">
              <div className="skeleton-icon" />
              <div className="skeleton-copy">
                <div className="skeleton-line skeleton-title" />
                <div className="skeleton-line" />
                <div className="skeleton-line skeleton-short" />
              </div>
            </div>
          </section>
          <Skeleton variant="cards" />
        </div>
      </AppShell>
    </ProtectedRoute>
  );
}