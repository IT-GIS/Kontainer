"use client";

import { X } from "lucide-react";
import { useDialogBehavior } from "@/hooks/use-dialog-behavior";

type DrawerProps = {
  open: boolean;
  title: string;
  description?: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
  closeOnBackdrop?: boolean;
  closeOnEscape?: boolean;
  preventClose?: boolean;
  onClose: () => void;
};

export function Drawer({
  open,
  title,
  description,
  children,
  footer,
  closeOnBackdrop = true,
  closeOnEscape = true,
  preventClose,
  onClose
}: DrawerProps) {
  const { dialogRef, titleId, descriptionId, requestClose, handleBackdropMouseDown } = useDialogBehavior({
    open,
    onClose,
    closeOnBackdrop,
    closeOnEscape,
    preventClose
  });

  if (!open) return null;

  return (
    <div className="ui-drawer-layer" onMouseDown={handleBackdropMouseDown} role="presentation">
      <aside
        aria-describedby={description ? descriptionId : undefined}
        aria-labelledby={titleId}
        aria-modal="true"
        className="ui-drawer"
        ref={dialogRef as React.RefObject<HTMLElement>}
        role="dialog"
        tabIndex={-1}
      >
        <header className="ui-drawer-head">
          <div>
            <h2 id={titleId}>{title}</h2>
            {description ? <p id={descriptionId}>{description}</p> : null}
          </div>
          <button aria-label="Tutup drawer" className="icon-button" disabled={preventClose} onClick={requestClose} type="button">
            <X size={18} />
          </button>
        </header>
        <div className="ui-drawer-body">{children}</div>
        {footer ? <footer className="ui-drawer-footer">{footer}</footer> : null}
      </aside>
    </div>
  );
}