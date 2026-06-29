import { X } from "lucide-react";

type FormDialogProps = {
  title: string;
  open: boolean;
  children: React.ReactNode;
  isSubmitting?: boolean;
  submitLabel?: string;
  onClose: () => void;
  onSubmit: () => void;
};

export function FormDialog({ title, open, children, isSubmitting, submitLabel = "Save", onClose, onSubmit }: FormDialogProps) {
  if (!open) {
    return null;
  }

  return (
    <div className="dialog-backdrop" role="presentation">
      <div className="dialog-panel" role="dialog" aria-modal="true" aria-label={title}>
        <div className="dialog-head">
          <h3>{title}</h3>
          <button className="icon-button" onClick={onClose} title="Close dialog">
            <X size={18} />
          </button>
        </div>
        <div className="dialog-body">{children}</div>
        <div className="dialog-actions">
          <button className="secondary-button" onClick={onClose} type="button">
            Cancel
          </button>
          <button className="primary-button" onClick={onSubmit} disabled={isSubmitting} type="button">
            <span>{isSubmitting ? "Saving..." : submitLabel}</span>
          </button>
        </div>
      </div>
    </div>
  );
}