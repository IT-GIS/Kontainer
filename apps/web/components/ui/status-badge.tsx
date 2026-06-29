type StatusBadgeProps = {
  children: string;
  tone?: "neutral" | "success" | "warning" | "danger";
};

const toneClass = {
  neutral: "badge-neutral",
  success: "badge-success",
  warning: "badge-warning",
  danger: "badge-danger"
};

export function StatusBadge({ children, tone = "neutral" }: StatusBadgeProps) {
  return <span className={`status-badge ${toneClass[tone]}`}>{children}</span>;
}