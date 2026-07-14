import { AlertCircle, CheckCircle2, Circle, CircleDashed } from "lucide-react";

export type ProgressTrackerItem = {
  id: string;
  label: string;
  description?: string;
  status: "complete" | "current" | "incomplete" | "warning" | "error" | "done" | "waiting";
};

type ProgressTrackerProps = {
  items: ProgressTrackerItem[];
};

const statusIcon = {
  complete: CheckCircle2,
  current: CircleDashed,
  incomplete: Circle,
  warning: AlertCircle,
  error: AlertCircle,
  done: CheckCircle2,
  waiting: Circle
};

const statusLabel = {
  complete: "Selesai",
  current: "Berjalan",
  incomplete: "Belum lengkap",
  warning: "Perlu perhatian",
  error: "Bermasalah",
  done: "Selesai",
  waiting: "Menunggu"
};

export function ProgressTracker({ items }: ProgressTrackerProps) {
  if (items.length === 0) return null;

  return (
    <ol className="ui-progress-tracker">
      {items.map((item) => {
        const Icon = statusIcon[item.status];
        const normalizedStatus = item.status === "done" ? "complete" : item.status === "waiting" ? "incomplete" : item.status;
        return (
          <li
            aria-label={`${item.label}: ${statusLabel[item.status]}`}
            className={`ui-progress-item ui-progress-${normalizedStatus}`}
            key={item.id}
          >
            <Icon aria-hidden="true" size={18} />
            <span>
              <strong>{item.label}</strong>
              {item.description ? <small>{item.description}</small> : null}
            </span>
          </li>
        );
      })}
    </ol>
  );
}