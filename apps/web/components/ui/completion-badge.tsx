import { CheckCircle2, CircleAlert } from "lucide-react";

type CompletionBadgeProps = {
  complete: number;
  total: number;
  label?: string;
};

export function CompletionBadge({ complete, total, label = "Kelengkapan" }: CompletionBadgeProps) {
  const safeTotal = Math.max(total, 1);
  const percent = Math.round((complete / safeTotal) * 100);
  const done = complete >= total;
  const Icon = done ? CheckCircle2 : CircleAlert;

  return (
    <span className={`ui-completion-badge ${done ? "ui-completion-done" : "ui-completion-progress"}`}>
      <Icon size={14} />
      <span>{label}</span>
      <strong>{percent}%</strong>
    </span>
  );
}
