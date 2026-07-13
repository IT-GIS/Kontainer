import { CheckCircle2, Clock3, CircleAlert } from "lucide-react";

export type ActivityTimelineItem = {
  id: string;
  title: string;
  description?: string;
  time?: string;
  tone?: "neutral" | "success" | "warning" | "danger";
};

type ActivityTimelineProps = {
  items: ActivityTimelineItem[];
};

const iconMap = {
  neutral: Clock3,
  success: CheckCircle2,
  warning: CircleAlert,
  danger: CircleAlert
};

export function ActivityTimeline({ items }: ActivityTimelineProps) {
  if (items.length === 0) return null;

  return (
    <ol className="ui-activity-timeline">
      {items.map((item) => {
        const Icon = iconMap[item.tone ?? "neutral"];
        return (
          <li className={`ui-activity-item ui-activity-${item.tone ?? "neutral"}`} key={item.id}>
            <span className="ui-activity-marker">
              <Icon size={16} />
            </span>
            <span className="ui-activity-copy">
              <strong>{item.title}</strong>
              {item.description ? <span>{item.description}</span> : null}
              {item.time ? <small>{item.time}</small> : null}
            </span>
          </li>
        );
      })}
    </ol>
  );
}
