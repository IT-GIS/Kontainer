import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import { SearchX } from "lucide-react";

type EmptyStateAction = {
  label: string;
  ariaLabel?: string;
  icon?: LucideIcon;
  variant?: "primary" | "secondary";
} & (
  | { href: string; onClick?: never }
  | { href?: never; onClick: () => void }
);

type EmptyStateProps = {
  title: string;
  description: string;
  action?: EmptyStateAction;
  icon?: LucideIcon;
};

export function EmptyState({ title, description, action, icon: Icon = SearchX }: EmptyStateProps) {
  return (
    <section className="ui-state-panel">
      <div className="ui-state-icon">
        <Icon size={22} />
      </div>
      <div>
        <h2>{title}</h2>
        <p>{description}</p>
      </div>
      {action ? <EmptyStateActionControl action={action} /> : null}
    </section>
  );
}

function EmptyStateActionControl({ action }: { action: EmptyStateAction }) {
  const ActionIcon = action.icon;
  const className = action.variant === "primary" ? "primary-button" : "secondary-button";
  const content = <>{ActionIcon ? <ActionIcon size={18} /> : null}<span>{action.label}</span></>;

  if (action.href) {
    return <Link aria-label={action.ariaLabel} className={className} href={action.href}>{content}</Link>;
  }

  return <button aria-label={action.ariaLabel} className={className} onClick={action.onClick} type="button">{content}</button>;
}
