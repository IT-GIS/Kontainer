import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import { RefreshCw } from "lucide-react";

type ErrorStateProps = {
  title?: string;
  message: string;
  action?: { label: string; href: string };
  icon?: LucideIcon;
};

export function ErrorState({
  title = "Data belum dapat dimuat",
  message,
  action = { label: "Kembali ke Dashboard", href: "/fitness/dashboard" },
  icon: Icon = RefreshCw
}: ErrorStateProps) {
  return (
    <section className="ui-state-panel ui-state-error">
      <div className="ui-state-icon">
        <Icon size={22} />
      </div>
      <div>
        <h2>{title}</h2>
        <p>{message}</p>
      </div>
      {action ? (
        <Link className="secondary-button" href={action.href}>
          {action.label}
        </Link>
      ) : null}
    </section>
  );
}
