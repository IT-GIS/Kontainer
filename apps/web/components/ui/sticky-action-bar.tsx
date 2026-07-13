type StickyAction = {
  label: string;
  href?: string;
  disabled?: boolean;
};

type StickyActionBarProps = {
  primary: StickyAction;
  secondary?: StickyAction;
  summary?: React.ReactNode;
};

export function StickyActionBar({ primary, secondary, summary }: StickyActionBarProps) {
  return (
    <div className="ui-sticky-action-bar">
      {summary ? <div className="ui-sticky-summary">{summary}</div> : null}
      <div className="ui-sticky-actions">
        {secondary ? <ActionButton action={secondary} variant="secondary-button" /> : null}
        <ActionButton action={primary} variant="primary-button" />
      </div>
    </div>
  );
}

function ActionButton({ action, variant }: { action: StickyAction; variant: "primary-button" | "secondary-button" }) {
  if (action.href && !action.disabled) {
    return (
      <a className={variant} href={action.href}>
        {action.label}
      </a>
    );
  }

  return (
    <button className={variant} disabled={action.disabled} type="button">
      {action.label}
    </button>
  );
}
