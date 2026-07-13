import Link from "next/link";
import type { ComponentType } from "react";
import { ArrowRight, CheckCircle2, CircleAlert, Sparkles } from "lucide-react";
import { PageTabs } from "@/components/ui/page-tabs";
import { StatusBadge } from "@/components/ui/status-badge";
import type { FitnessMasterDataGroup, FitnessPlaceholder } from "@/types/fitness-admin";

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
        {item.features.map((feature) => (
          <div className="feature-summary-item" key={feature}>
            <CheckCircle2 size={18} />
            <span>{feature}</span>
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
  items: Array<{
    label: string;
    href: string;
    description: string;
    status: "Aktif" | "Dalam Pengembangan";
    icon: ComponentType<{ size?: number }>;
  }>;
};

export function DashboardSummary({ items }: DashboardSummaryProps) {
  return (
    <section className="workspace-panel">
      <SectionHeader title="Ringkasan Navigasi" description="Akses cepat untuk pekerjaan Admin Kelaikan." />
      <div className="fitness-card-grid">
        {items.map((item) => {
          const Icon = item.icon;
          return (
            <Link className="fitness-action-card" href={item.href} key={item.href}>
              <div className="fitness-card-icon"><Icon size={20} /></div>
              <div>
                <strong>{item.label}</strong>
                <p>{item.description}</p>
              </div>
              <StatusBadge tone={item.status === "Aktif" ? "success" : "warning"}>{item.status}</StatusBadge>
            </Link>
          );
        })}
      </div>
    </section>
  );
}

type MasterDataIndexProps = {
  groups: FitnessMasterDataGroup[];
};

export function MasterDataIndex({ groups }: MasterDataIndexProps) {
  return (
    <div className="master-index-stack">
      {groups.map((group) => (
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
      <span>Data operasional belum dihubungkan pada tahap UI-A.</span>
    </div>
  );
}
