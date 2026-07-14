"use client";

import { X } from "lucide-react";
import { useDialogBehavior } from "@/hooks/use-dialog-behavior";

type FormDialogProps = {
  title: string;
  open: boolean;
  children: React.ReactNode;
  description?: string;
  isSubmitting?: boolean;
  submitLabel?: string;
  closeOnBackdrop?: boolean;
  closeOnEscape?: boolean;
  onClose: () => void;
  onSubmit: () => void;
};

export function FormDialog({
  title,
  open,
  children,
  description,
  isSubmitting,
  submitLabel = "Simpan",
  closeOnBackdrop = true,
  closeOnEscape = true,
  onClose,
  onSubmit
}: FormDialogProps) {
  const { dialogRef, titleId, descriptionId, requestClose, handleBackdropMouseDown } = useDialogBehavior({
    open,
    onClose,
    closeOnBackdrop,
    closeOnEscape,
    preventClose: isSubmitting
  });

  if (!open) return null;

  return (
    <div className="dialog-backdrop" onMouseDown={handleBackdropMouseDown} role="presentation">
      <div
        aria-describedby={description ? descriptionId : undefined}
        aria-labelledby={titleId}
        aria-modal="true"
        className="dialog-panel"
        ref={dialogRef as React.RefObject<HTMLDivElement>}
        role="dialog"
        tabIndex={-1}
      >
        <div className="dialog-head">
          <div>
            <h3 id={titleId}>{title}</h3>
            {description ? <p id={descriptionId}>{description}</p> : null}
          </div>
          <button aria-label="Tutup dialog" className="icon-button" disabled={isSubmitting} onClick={requestClose} type="button">
            <X size={18} />
          </button>
        </div>
        <div className="dialog-body">{children}</div>
        <div className="dialog-actions">
          <button className="secondary-button" disabled={isSubmitting} onClick={requestClose} type="button">
            Batalkan
          </button>
          <button className="primary-button" disabled={isSubmitting} onClick={onSubmit} type="button">
            <span>{isSubmitting ? "Menyimpan..." : submitLabel}</span>
          </button>
        </div>
      </div>
    </div>
  );
}