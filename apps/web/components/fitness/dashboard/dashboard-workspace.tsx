"use client";

import { useEffect, useState } from "react";
import {
  ArchiveRestore, Building2, ClipboardCheck, ClipboardList, Container, FileSearch,
  FileText, Gauge, Import, RefreshCw, ShieldCheck, UserRoundCheck, UsersRound, Wrench
} from "lucide-react";
import { ActionCard } from "@/components/ui/action-card";
import { ActivityTimeline } from "@/components/ui/activity-timeline";
import { ErrorState } from "@/components/ui/error-state";
import { FilterBar, type FilterBarField } from "@/components/ui/filter-bar";
import { MetricCard } from "@/components/ui/metric-card";
import { PageHeader } from "@/components/ui/page-header";
import { Skeleton } from "@/components/ui/skeleton";
import { getFitnessDashboardSnapshot } from "@/lib/fitness-dashboard-applications-mock-service";
import type {
  FitnessClientSummary, FitnessDashboardAction, FitnessDashboardMetric,
  FitnessDashboardQuickAction, FitnessDashboardSnapshot
} from "@/types/fitness-admin";

export function FitnessDashboardWorkspace({ initialSnapshot, clients }: { initialSnapshot: FitnessDashboardSnapshot; clients: FitnessClientSummary[] }) {
  const [snapshot, setSnapshot] = useState(initialSnapshot);
  const [filters, setFilters] = useState({ period: "30-days", clientId: "" });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    const timer = window.setTimeout(() => {
      setLoading(true);
      setError(null);
      getFitnessDashboardSnapshot({
        clientId: filters.clientId || undefined,
        period: filters.period as "7-days" | "30-days" | "quarter"
      }).then((state) => {
        if (!active) return;
        if (state.status === "success") setSnapshot(state.data);
        else if (state.status === "error") setError(state.error);
        setLoading(false);
      });
    }, 0);
    return () => { active = false; window.clearTimeout(timer); };
  }, [filters.clientId, filters.period]);

  const fields: FilterBarField[] = [
    {
      id: "period", label: "Periode", type: "select", value: filters.period,
      options: [
        { value: "7-days", label: "7 hari terakhir" },
        { value: "30-days", label: "30 hari terakhir" },
        { value: "quarter", label: "Kuartal berjalan" }
      ]
    },
    {
      id: "clientId", label: "Klien", type: "select", value: filters.clientId, placeholder: "Seluruh klien",
      options: clients.map((client) => ({ value: client.id, label: client.name }))
    }
  ];

  return (
    <div className="page-stack">
      <PageHeader
        eyebrow="Admin Kelaikan"
        title="Dashboard"
        description="Pusat tindakan Admin untuk pekerjaan yang perlu ditindaklanjuti."
        meta={<span>{filters.clientId ? "Konteks satu klien" : "Seluruh klien aktif"} · {filters.period === "7-days" ? "7 hari" : filters.period === "quarter" ? "Kuartal berjalan" : "30 hari"}</span>}
        action={{ label: "Buat Permohonan", icon: ClipboardList, href: "/fitness/applications/create" }}
        secondaryAction={{ label: "Lihat Permohonan", href: "/fitness/applications" }}
      />
      <FilterBar
        fields={fields}
        loading={loading}
        onChange={(id, value) => setFilters((current) => ({ ...current, [id]: value }))}
        onReset={() => setFilters({ period: "30-days", clientId: "" })}
      />
      {error ? <ErrorState message={error} /> : null}
      {loading ? <Skeleton variant="cards" /> : (
        <>
          <section className="workspace-panel">
            <SectionTitle title="Perlu Tindakan Anda" description="Urutkan pekerjaan berdasarkan kebutuhan tindak lanjut." />
            <div className="fitness-dashboard-actions">
              {snapshot.actions.map((item) => <DashboardActionCard item={item} key={item.id} />)}
            </div>
          </section>
          <section className="workspace-panel">
            <SectionTitle title="Ringkasan Status" description="Ringkasan operasional pada periode dan klien terpilih." />
            <div className="ui-metric-grid">
              {snapshot.metrics.map((item) => <DashboardMetricCard item={item} key={item.id} />)}
            </div>
          </section>
          <div className="fitness-dashboard-split">
            <section className="workspace-panel">
              <SectionTitle title="Aktivitas Terbaru" description="Perubahan terbaru pada workflow Kelaikan." />
              <ActivityTimeline items={snapshot.activities} />
            </section>
            <section className="workspace-panel">
              <SectionTitle title="Quick Action" description="Akses cepat untuk pekerjaan Admin yang umum." />
              <div className="fitness-dashboard-quick">
                {snapshot.quickActions.map((item) => <QuickAction item={item} key={item.id} />)}
              </div>
            </section>
          </div>
        </>
      )}
    </div>
  );
}

function DashboardActionCard({ item }: { item: FitnessDashboardAction }) {
  const Icon = actionIcons[item.icon];
  return <ActionCard title={item.label} description={item.description} href={item.href} icon={Icon} status={String(item.count)} statusTone={item.count === 0 ? "neutral" : item.tone} meta={item.count === 0 ? "Tidak ada antrean" : "Buka daftar tindak lanjut"} />;
}

function DashboardMetricCard({ item }: { item: FitnessDashboardMetric }) {
  const Icon = metricIcons[item.icon];
  return <MetricCard label={item.label} value={item.value} description={item.description} icon={Icon} tone={item.tone} />;
}

function QuickAction({ item }: { item: FitnessDashboardQuickAction }) {
  return <ActionCard title={item.label} description={item.description} href={item.href} icon={quickIcons[item.icon]} />;
}

function SectionTitle({ title, description }: { title: string; description: string }) {
  return <div className="fitness-section-header"><div><h2>{title}</h2><p>{description}</p></div><RefreshCw aria-hidden="true" size={18} /></div>;
}

const metricIcons = {
  clients: UsersRound,
  applications: ClipboardList,
  inspection: ClipboardCheck,
  repair: Wrench,
  reinspection: ArchiveRestore,
  fit: ShieldCheck,
  unfit: FileSearch
};

const actionIcons = {
  client: Building2,
  application: ClipboardList,
  container: Container,
  assignment: UserRoundCheck,
  review: FileSearch,
  repair: Wrench,
  reinspection: ArchiveRestore,
  document: FileText
};

const quickIcons = {
  client: Building2,
  master: Gauge,
  application: ClipboardList,
  import: Import,
  assignment: UserRoundCheck,
  review: FileSearch
};
