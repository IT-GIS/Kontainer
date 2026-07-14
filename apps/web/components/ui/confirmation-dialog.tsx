"use client";

import { AlertTriangle, X } from "lucide-react";
import { useDialogBehavior } from "@/hooks/use-dialog-behavior";

type ConfirmationDialogProps = {
  open: boolean;
  title: string;
  description: string;
  confirmLabel?: string;
  cancelLabel?: string;
  tone?: "neutral" | "danger";
  isLoading?: boolean;
  closeOnBackdrop?: boolean;
  closeOnEscape?: boolean;
  onConfirm: () => void;
  onClose: () => void;
};

export function ConfirmationDialog({
  open,
  title,
  description,
  confirmLabel = "Konfirmasi",
  cancelLabel = "Batalkan",
  tone = "neutral",
  isLoading,
  closeOnBackdrop = true,
  closeOnEscape = true,
  onConfirm,
  onClose
}: ConfirmationDialogProps) {
  const { dialogRef, titleId, descriptionId, requestClose, handleBackdropMouseDown } = useDialogBehavior({
    open,
    onClose,
    closeOnBackdrop,
    closeOnEscape,
    preventClose: isLoading
  });

  if (!open) return null;

  return (
    <div className="dialog-backdrop" onMouseDown={handleBackdropMouseDown} role="presentation">
      <div
        aria-describedby={descriptionId}
        aria-labelledby={titleId}
        aria-modal="true"
        className="dialog-panel ui-confirmation"
        ref={dialogRef as React.RefObject<HTMLDivElement>}
        role="dialog"
        tabIndex={-1}
      >
        <div className="dialog-head">
          <div className={`ui-confirmation-icon ui-confirmation-${tone}`}>
            <AlertTriangle size={18} />
          </div>
          <button aria-label="Tutup dialog" className="icon-button" disabled={isLoading} onClick={requestClose} type="button">
            <X size={18} />
          </button>
        </div>
        <div className="dialog-body">
          <h3 id={titleId}>{title}</h3>
          <p id={descriptionId}>{description}</p>
        </div>
        <div className="dialog-actions">
          <button className="secondary-button" disabled={isLoading} onClick={requestClose} type="button">
            {cancelLabel}
          </button>
          <button
            className={tone === "danger" ? "primary-button ui-danger-button" : "primary-button"}
            disabled={isLoading}
            onClick={onConfirm}
            type="button"
          >
            {isLoading ? "Memproses..." : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}