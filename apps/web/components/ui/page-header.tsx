import type { LucideIcon } from "lucide-react";

type PageHeaderProps = {
  title: string;
  description?: string;
  action?: {
    label: string;
    icon?: LucideIcon;
    onClick: () => void;
    disabled?: boolean;
  };
};

export function PageHeader({ title, description, action }: PageHeaderProps) {
  const Icon = action?.icon;
  return (
    <div className="page-header">
      <div>
        <h2>{title}</h2>
        {description ? <p>{description}</p> : null}
      </div>
      {action ? (
        <button className="primary-button" onClick={action.onClick} disabled={action.disabled}>
          {Icon ? <Icon size={18} /> : null}
          <span>{action.label}</span>
        </button>
      ) : null}
    </div>
  );
}