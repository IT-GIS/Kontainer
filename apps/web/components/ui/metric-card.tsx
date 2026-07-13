import type { LucideIcon } from "lucide-react";
import { StatusBadge } from "@/components/ui/status-badge";

type MetricCardProps = {
  label: string;
  value: string | number;
  description?: string;
  icon?: LucideIcon;
  tone?: "neutral" | "success" | "warning" | "danger" | "info";
  trend?: string;
};

export function MetricCard({ label, value, description, icon: Icon, tone = "neutral", trend }: MetricCardProps) {
  return (
    <article className={`ui-metric-card ui-metric-${tone}`}>
      <div className="ui-metric-head">
        <div>
          <span>{label}</span>
          <strong>{value}</strong>
        </div>
        {Icon ? (
          <span className="ui-card-icon">
            <Icon size={20} />
          </span>
        ) : null}
      </div>
      {description ? <p>{description}</p> : null}
      {trend ? <StatusBadge tone={tone}>{trend}</StatusBadge> : null}
    </article>
  );
}
