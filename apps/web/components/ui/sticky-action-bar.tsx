import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import { Loader2 } from "lucide-react";

type StickyAction = {
  label: string;
  href?: string;
  onClick?: () => void;
  type?: "button" | "submit" | "reset";
  form?: string;
  disabled?: boolean;
  loading?: boolean;
  loadingLabel?: string;
  icon?: LucideIcon;
  ariaLabel?: string;
};

type StickyActionBarProps = {
  primary: StickyAction;
  secondary?: StickyAction;
  tertiary?: StickyAction;
  summary?: React.ReactNode;
};

export function StickyActionBar({ primary, secondary, tertiary, summary }: StickyActionBarProps) {
  return (
    <div className="ui-sticky-action-bar">
      {summary ? <div className="ui-sticky-summary">{summary}</div> : null}
      <div className="ui-sticky-actions">
        {tertiary ? <ActionButton action={tertiary} variant="secondary-button" /> : null}
        {secondary ? <ActionButton action={secondary} variant="secondary-button" /> : null}
        <ActionButton action={primary} variant="primary-button" />
      </div>
    </div>
  );
}

function ActionButton({ action, variant }: { action: StickyAction; variant: "primary-button" | "secondary-button" }) {
  const Icon = action.loading ? Loader2 : action.icon;
  const label = action.loading ? action.loadingLabel ?? "Memproses..." : action.label;
  const className = `${variant} ${action.loading ? "ui-loading-button" : ""}`;

  if (action.href && !action.disabled && !action.loading) {
    return (
      <Link aria-label={action.ariaLabel} className={className} href={action.href}>
        {Icon ? <Icon size={16} /> : null}
        <span>{label}</span>
      </Link>
    );
  }

  return (
    <button
      aria-label={action.ariaLabel}
      className={className}
      disabled={action.disabled || action.loading}
      form={action.form}
      onClick={action.onClick}
      type={action.type ?? "button"}
    >
      {Icon ? <Icon size={16} /> : null}
      <span>{label}</span>
    </button>
  );
}