"use client";

import { AlertTriangle, X } from "lucide-react";

type ConfirmationDialogProps = {
  open: boolean;
  title: string;
  description: string;
  confirmLabel?: string;
  cancelLabel?: string;
  tone?: "neutral" | "danger";
  isLoading?: boolean;
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
  onConfirm,
  onClose
}: ConfirmationDialogProps) {
  if (!open) return null;

  return (
    <div className="dialog-backdrop" role="presentation">
      <div className="dialog-panel ui-confirmation" role="dialog" aria-modal="true" aria-label={title}>
        <div className="dialog-head">
          <div className={`ui-confirmation-icon ui-confirmation-${tone}`}>
            <AlertTriangle size={18} />
          </div>
          <button className="icon-button" onClick={onClose} title="Tutup dialog" type="button">
            <X size={18} />
          </button>
        </div>
        <div className="dialog-body">
          <h3>{title}</h3>
          <p>{description}</p>
        </div>
        <div className="dialog-actions">
          <button className="secondary-button" onClick={onClose} type="button">
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
