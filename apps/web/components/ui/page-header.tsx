import Link from "next/link";
import type { LucideIcon } from "lucide-react";

type HeaderAction = {
  label: string;
  ariaLabel?: string;
  icon?: LucideIcon;
  href?: string;
  onClick?: () => void;
  disabled?: boolean;
};

type PageHeaderProps = {
  title: string;
  description?: string;
  eyebrow?: string;
  meta?: React.ReactNode;
  action?: HeaderAction;
  secondaryAction?: HeaderAction;
};

export function PageHeader({ title, description, eyebrow, meta, action, secondaryAction }: PageHeaderProps) {
  return (
    <div className="page-header">
      <div>
        {eyebrow ? <span className="page-header-eyebrow">{eyebrow}</span> : null}
        <h2>{title}</h2>
        {description ? <p>{description}</p> : null}
        {meta ? <div className="page-header-meta">{meta}</div> : null}
      </div>
      {action || secondaryAction ? (
        <div className="page-header-actions">
          {secondaryAction ? <HeaderActionControl action={secondaryAction} className="secondary-button" /> : null}
          {action ? <HeaderActionControl action={action} className="primary-button" /> : null}
        </div>
      ) : null}
    </div>
  );
}

function HeaderActionControl({ action, className }: { action: HeaderAction; className: string }) {
  const Icon = action.icon;
  const content = <>{Icon ? <Icon size={18} /> : null}<span>{action.label}</span></>;
  if (action.href && !action.disabled) return <Link aria-label={action.ariaLabel} className={className} href={action.href}>{content}</Link>;
  return <button aria-label={action.ariaLabel} className={className} onClick={action.onClick} disabled={action.disabled} type="button">{content}</button>;
}
