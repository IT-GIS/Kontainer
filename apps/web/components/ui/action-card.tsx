import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import { ArrowRight } from "lucide-react";
import { StatusBadge } from "@/components/ui/status-badge";

type ActionCardProps = {
  title: string;
  description: string;
  href?: string;
  icon?: LucideIcon;
  status?: string;
  statusTone?: "neutral" | "success" | "warning" | "danger" | "info";
  meta?: string;
};

export function ActionCard({
  title,
  description,
  href,
  icon: Icon,
  status,
  statusTone = "neutral",
  meta
}: ActionCardProps) {
  const content = (
    <>
      {Icon ? (
        <span className="ui-card-icon">
          <Icon size={20} />
        </span>
      ) : null}
      <span className="ui-action-card-copy">
        <strong>{title}</strong>
        <span>{description}</span>
        {meta ? <small>{meta}</small> : null}
      </span>
      {status ? <StatusBadge tone={statusTone}>{status}</StatusBadge> : null}
      {href ? <ArrowRight aria-hidden="true" size={16} /> : null}
    </>
  );

  if (href) {
    return (
      <Link className="ui-action-card" href={href}>
        {content}
      </Link>
    );
  }

  return <article className="ui-action-card">{content}</article>;
}
