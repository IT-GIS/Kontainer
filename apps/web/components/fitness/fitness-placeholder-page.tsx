import Link from "next/link";
import { ClipboardList, Database, Route, ShieldCheck } from "lucide-react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import type { FitnessPlaceholder } from "@/constants/fitness-admin";
import { masterDataItems } from "@/constants/fitness-admin";

type FitnessPlaceholderPageProps = {
  item: FitnessPlaceholder;
};

export function FitnessPlaceholderPage({ item }: FitnessPlaceholderPageProps) {
  const isMasterDataIndex = item.path === "/fitness/master-data";

  return (
    <ProtectedRoute>
      <AppShell title={item.title}>
        <div className="page-stack">
          <PageHeader title={item.title} description={item.purpose} />

          <section className="workspace-panel">
            <div className="section-title-row">
              <div><ShieldCheck size={22} /><h2>Status tahap ini</h2></div>
              <StatusBadge tone="warning">PLACEHOLDER</StatusBadge>
            </div>
            <p className="muted-text">Placeholder — belum ada API/mutation pada tahap ini.</p>
          </section>

          {isMasterDataIndex ? (
            <section className="workspace-panel">
              <div className="section-title-row">
                <div><Database size={22} /><h2>Sub menu Master Data Kelaikan</h2></div>
              </div>
              <div className="data-table-wrapper">
                <table className="data-table">
                  <thead>
                    <tr><th>Sub menu</th><th>Route</th></tr>
                  </thead>
                  <tbody>
                    {masterDataItems.map((master) => (
                      <tr key={master.href}>
                        <td><Link href={master.href}>{master.label}</Link></td>
                        <td>{master.href}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </section>
          ) : null}

          <section className="workspace-panel">
            <div className="section-title-row">
              <div><ClipboardList size={22} /><h2>Field form yang akan dibuat</h2></div>
            </div>
            <ul>
              {item.fields.map((field) => <li key={field}>{field}</li>)}
            </ul>
          </section>

          <section className="workspace-panel">
            <div className="section-title-row">
              <div><ShieldCheck size={22} /><h2>Validasi ringkas</h2></div>
            </div>
            <ul>
              {item.validations.map((validation) => <li key={validation}>{validation}</li>)}
            </ul>
          </section>

          <section className="workspace-panel">
            <div className="section-title-row">
              <div><Route size={22} /><h2>Dipakai oleh menu</h2></div>
            </div>
            <ul>
              {item.usedBy.map((usage) => <li key={usage}>{usage}</li>)}
            </ul>
            <p className="muted-text"><strong>Hubungan ke Surveyor lapangan:</strong> {item.surveyorUsage}</p>
          </section>
        </div>
      </AppShell>
    </ProtectedRoute>
  );
}
