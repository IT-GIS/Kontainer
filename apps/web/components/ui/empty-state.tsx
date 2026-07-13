import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import { SearchX } from "lucide-react";

type EmptyStateProps = {
  title: string;
  description: string;
  action?: { label: string; href: string };
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
      {action ? (
        <Link className="secondary-button" href={action.href}>
          {action.label}
        </Link>
      ) : null}
    </section>
  );
}
