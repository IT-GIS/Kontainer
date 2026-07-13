import { CheckCircle2, CircleAlert, Info } from "lucide-react";

type ToastFeedbackProps = {
  title: string;
  description?: string;
  tone?: "success" | "warning" | "danger" | "info";
};

const iconMap = {
  success: CheckCircle2,
  warning: CircleAlert,
  danger: CircleAlert,
  info: Info
};

export function ToastFeedback({ title, description, tone = "info" }: ToastFeedbackProps) {
  const Icon = iconMap[tone];

  return (
    <div className={`ui-toast-feedback ui-toast-${tone}`} role="status">
      <Icon size={18} />
      <span>
        <strong>{title}</strong>
        {description ? <small>{description}</small> : null}
      </span>
    </div>
  );
}
