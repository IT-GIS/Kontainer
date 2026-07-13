import type { LucideIcon } from "lucide-react";

type PageHeaderProps = {
  title: string;
  description?: string;
  eyebrow?: string;
  meta?: React.ReactNode;
  action?: {
    label: string;
    icon?: LucideIcon;
    onClick: () => void;
    disabled?: boolean;
  };
  secondaryAction?: {
    label: string;
    icon?: LucideIcon;
    onClick: () => void;
    disabled?: boolean;
  };
};

export function PageHeader({ title, description, eyebrow, meta, action, secondaryAction }: PageHeaderProps) {
  const Icon = action?.icon;
  const SecondaryIcon = secondaryAction?.icon;

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
          {secondaryAction ? (
            <button className="secondary-button" onClick={secondaryAction.onClick} disabled={secondaryAction.disabled}>
              {SecondaryIcon ? <SecondaryIcon size={18} /> : null}
              <span>{secondaryAction.label}</span>
            </button>
          ) : null}
          {action ? (
            <button className="primary-button" onClick={action.onClick} disabled={action.disabled}>
              {Icon ? <Icon size={18} /> : null}
              <span>{action.label}</span>
            </button>
          ) : null}
        </div>
      ) : null}
    </div>
  );
}