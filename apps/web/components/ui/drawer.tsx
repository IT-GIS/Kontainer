"use client";

import { X } from "lucide-react";

type DrawerProps = {
  open: boolean;
  title: string;
  description?: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
  onClose: () => void;
};

export function Drawer({ open, title, description, children, footer, onClose }: DrawerProps) {
  if (!open) return null;

  return (
    <div className="ui-drawer-layer" role="presentation">
      <button aria-label="Tutup drawer" className="ui-drawer-scrim" onClick={onClose} type="button" />
      <aside className="ui-drawer" role="dialog" aria-modal="true" aria-label={title}>
        <header className="ui-drawer-head">
          <div>
            <h2>{title}</h2>
            {description ? <p>{description}</p> : null}
          </div>
          <button className="icon-button" onClick={onClose} title="Tutup drawer" type="button">
            <X size={18} />
          </button>
        </header>
        <div className="ui-drawer-body">{children}</div>
        {footer ? <footer className="ui-drawer-footer">{footer}</footer> : null}
      </aside>
    </div>
  );
}
