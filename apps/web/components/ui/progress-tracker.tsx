import { CheckCircle2, Circle, CircleDashed } from "lucide-react";

export type ProgressTrackerItem = {
  id: string;
  label: string;
  description?: string;
  status: "done" | "current" | "waiting";
};

type ProgressTrackerProps = {
  items: ProgressTrackerItem[];
};

const statusIcon = {
  done: CheckCircle2,
  current: CircleDashed,
  waiting: Circle
};

export function ProgressTracker({ items }: ProgressTrackerProps) {
  if (items.length === 0) return null;

  return (
    <ol className="ui-progress-tracker">
      {items.map((item) => {
        const Icon = statusIcon[item.status];
        return (
          <li className={`ui-progress-item ui-progress-${item.status}`} key={item.id}>
            <Icon size={18} />
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
