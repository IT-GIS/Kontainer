"use client";

import { useEffect } from "react";
import { CheckCircle2, CircleAlert, Info, X } from "lucide-react";

type ToastFeedbackProps = {
  title: string;
  description?: string;
  tone?: "success" | "warning" | "danger" | "info";
  onDismiss?: () => void;
  duration?: number;
};

const iconMap = {
  success: CheckCircle2,
  warning: CircleAlert,
  danger: CircleAlert,
  info: Info
};

export function ToastFeedback({ title, description, tone = "info", onDismiss, duration }: ToastFeedbackProps) {
  const Icon = iconMap[tone];
  const role = tone === "danger" || tone === "warning" ? "alert" : "status";

  useEffect(() => {
    if (!duration || !onDismiss) return;
    const timeout = window.setTimeout(onDismiss, duration);
    return () => window.clearTimeout(timeout);
  }, [duration, onDismiss]);

  return (
    <div className={`ui-toast-feedback ui-toast-${tone}`} role={role}>
      <Icon size={18} />
      <span>
        <strong>{title}</strong>
        {description ? <small>{description}</small> : null}
      </span>
      {onDismiss ? (
        <button aria-label="Tutup pesan" onClick={onDismiss} type="button">
          <X size={15} />
        </button>
      ) : null}
    </div>
  );
}