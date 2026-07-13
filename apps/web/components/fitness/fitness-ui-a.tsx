import Link from "next/link";
import { ArrowRight, CheckCircle2, CircleAlert, Sparkles } from "lucide-react";
import { ActionCard } from "@/components/ui/action-card";
import { ActivityTimeline } from "@/components/ui/activity-timeline";
import { AttachmentPreview } from "@/components/ui/attachment-preview";
import { AttachmentUploaderPlaceholder } from "@/components/ui/attachment-uploader-placeholder";
import { CompletionBadge } from "@/components/ui/completion-badge";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { FilterBar } from "@/components/ui/filter-bar";
import { MetricCard } from "@/components/ui/metric-card";
import { PageTabs } from "@/components/ui/page-tabs";
import { ProgressTracker } from "@/components/ui/progress-tracker";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { Skeleton } from "@/components/ui/skeleton";
import { StatusBadge } from "@/components/ui/status-badge";
import { Stepper } from "@/components/ui/stepper";
import { StickyActionBar } from "@/components/ui/sticky-action-bar";
import type {
  FitnessMasterDataGroup, FitnessMockState, FitnessNavigationSummary, FitnessPlaceholder,
  FitnessUiBPreview, FitnessUiBRecord
} from "@/types/fitness-admin";

type FeaturePlaceholderProps = {
  item: FitnessPlaceholder;
  activeHref: string;
};

export function FeaturePlaceholder({ item, activeHref }: FeaturePlaceholderProps) {
  const Icon = item.icon;

  return (
    <section className="feature-placeholder">
      <div className="feature-placeholder-hero">
        <span className="feature-placeholder-icon"><Icon size={28} /></span>
        <div>
          <div className="feature-placeholder-kicker">
            <StatusBadge tone={item.status === "Aktif" ? "success" : "warning"}>{item.status}</StatusBadge>
          </div>
          <h2>{item.title}</h2>
          <p>{item.description}</p>
        </div>
      </div>

      {item.tabs ? <PageTabs tabs={item.tabs} activeHref={activeHref} /> : null}

      <div className="feature-summary-grid">
        {item.features.map((feature, index) => (
          <div className="feature-summary-item" key={feature}>
            <CheckCircle2 size={18} />
            <span>{feature}</span>
            {index === 0 ? <CompletionBadge complete={2} total={3} label="UI-B" /> : null}
          </div>
        ))}
      </div>

      <div className="feature-placeholder-actions">
        <Link className="primary-button" href={item.primaryCta.href}>
          <span>{item.primaryCta.label}</span>
          <ArrowRight size={16} />
        </Link>
        {item.secondaryCta ? (
          <Link className="secondary-button" href={item.secondaryCta.href}>
            <span>{item.secondaryCta.label}</span>
          </Link>
        ) : null}
      </div>
    </section>
  );
}

type DashboardSummaryProps = {
  state: FitnessMockState<FitnessNavigationSummary[]>;
};

export function DashboardSummary({ state }: DashboardSummaryProps) {
  if (state.status === "loading") return <Skeleton variant="cards" />;
  if (state.status === "error") return <ErrorState message={state.error} />;
  if (state.status === "empty" || state.data.length === 0) {
    return (
      <EmptyState
        title="Ringkasan belum tersedia"
        description="Belum ada ringkasan navigasi yang dapat ditampilkan untuk tahap ini."
        action={{ label: "Kembali ke Dashboard", href: "/fitness/dashboard" }}
      />
    );
  }

  return (
    <section className="workspace-panel">
      <SectionHeader title="Ringkasan Navigasi" description="Akses cepat untuk pekerjaan Admin Kelaikan." />
      <div className="fitness-card-grid">
        {state.data.map((item) => (
          <ActionCard
            description={item.description}
            href={item.href}
            icon={item.icon}
            key={item.href}
            status={item.status}
            statusTone={item.status === "Aktif" ? "success" : "warning"}
            title={item.label}
          />
        ))}
      </div>
    </section>
  );
}

type MasterDataIndexProps = {
  state: FitnessMockState<FitnessMasterDataGroup[]>;
};

export function MasterDataIndex({ state }: MasterDataIndexProps) {
  if (state.status === "loading") return <Skeleton variant="master" />;
  if (state.status === "error") return <ErrorState message={state.error} />;
  if (state.status === "empty" || state.data.length === 0) {
    return (
      <EmptyState
        title="Master Data belum tersedia"
        description="Kelompok master data belum dapat ditampilkan pada tahap ini."
        action={{ label: "Kembali ke Dashboard", href: "/fitness/dashboard" }}
      />
    );
  }

  return (
    <div className="master-index-stack">
      {state.data.map((group) => (
        <section className="workspace-panel master-data-group" key={group.title}>
          <SectionHeader title={group.title} description={group.description} />
          <div className="master-data-card-grid">
            {group.items.map((item) => <MasterDataCard item={item} key={item.href} />)}
          </div>
        </section>
      ))}
    </div>
  );
}

export function FitnessDesignPatternPreview({ state }: { state: FitnessMockState<FitnessUiBPreview> }) {
  if (state.status === "loading") return <Skeleton variant="table" />;
  if (state.status === "error") return <ErrorState message={state.error} />;
  if (state.status === "empty" || state.data.records.length === 0) {
    return (
      <EmptyState
        title="Data operasional belum tersedia"
        description="Tampilan sudah menyiapkan state kosong sebelum data nyata dihubungkan."
      />
    );
  }

  const columns: ResponsiveColumn<FitnessUiBRecord>[] = [
    { key: "code", header: "Kode", render: (row) => <strong>{row.code}</strong> },
    { key: "owner", header: "Pemilik", render: (row) => row.owner },
    { key: "stage", header: "Tahap Proses", render: (row) => row.stage },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone="info">{row.status}</StatusBadge> },
    { key: "complete", header: "Kelengkapan", render: (row) => <CompletionBadge complete={row.complete} total={row.total} /> }
  ];

  return (
    <section className="workspace-panel ui-b-preview-panel">
      <SectionHeader title="Tampilan Operasional" description="Pola komponen siap untuk daftar, form bertahap, dan detail proses." />
      <div className="ui-b-metric-grid">
        {state.data.metrics.map((metric) => (
          <MetricCard
            description={metric.description}
            icon={metric.icon}
            key={metric.label}
            label={metric.label}
            tone={metric.tone}
            trend={metric.trend}
            value={metric.value}
          />
        ))}
      </div>
      <FilterBar fields={state.data.filters} resetHref="/fitness/dashboard" />
      <div className="ui-b-flow-grid">
        <Stepper steps={state.data.steps} />
        <ProgressTracker items={state.data.progress} />
      </div>
      <ResponsiveTableCards
        columns={columns}
        getRowId={(row) => row.id}
        getRowTitle={(row) => row.code}
        rows={state.data.records}
      />
      <div className="ui-b-support-grid">
        <div className="ui-b-support-panel">
          <h3>Aktivitas</h3>
          <ActivityTimeline items={state.data.activities} />
        </div>
        <div className="ui-b-support-panel">
          <h3>Lampiran</h3>
          <AttachmentUploaderPlaceholder
            title="Area lampiran"
            description="Siapkan dokumen permohonan, foto pemeriksaan, atau file pendukung."
          />
          {state.data.attachments.map((attachment) => (
            <AttachmentPreview
              key={attachment.name}
              name={attachment.name}
              sizeLabel={attachment.sizeLabel}
              type={attachment.type}
            />
          ))}
        </div>
      </div>
      <StickyActionBar
        primary={{ label: "Lanjutkan", disabled: true }}
        secondary={{ label: "Simpan Draf", disabled: true }}
        summary={<CompletionBadge complete={3} total={5} label="Kesiapan" />}
      />
    </section>
  );
}

function MasterDataCard({ item }: { item: FitnessMasterDataGroup["items"][number] }) {
  const Icon = item.icon;
  return (
    <article className="master-data-card">
      <div className="master-data-card-head">
        <span className="fitness-card-icon"><Icon size={20} /></span>
        <StatusBadge tone="success">{item.status}</StatusBadge>
      </div>
      <div>
        <h3>{item.label}</h3>
        <p>{item.description}</p>
      </div>
      <dl className="master-data-card-meta">
        <div><dt>Aktif</dt><dd>{item.activeCount}</dd></div>
        <div><dt>Tidak Aktif</dt><dd>{item.inactiveCount}</dd></div>
        <div><dt>Diperbarui</dt><dd>{item.updatedAt}</dd></div>
      </dl>
      <Link className="secondary-button master-data-card-action" href={item.href}>
        <span>Kelola</span>
        <ArrowRight size={15} />
      </Link>
    </article>
  );
}

export function SectionHeader({ title, description }: { title: string; description?: string }) {
  return (
    <div className="fitness-section-header">
      <div>
        <h2>{title}</h2>
        {description ? <p>{description}</p> : null}
      </div>
      <Sparkles aria-hidden="true" size={18} />
    </div>
  );
}

export function EmptyDevelopmentNote() {
  return (
    <div className="empty-development-note">
      <CircleAlert size={18} />
      <span>Data operasional belum dihubungkan pada tahap UI-B.</span>
    </div>
  );
}