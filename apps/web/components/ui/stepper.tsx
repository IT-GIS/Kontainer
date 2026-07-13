import { Check, Circle } from "lucide-react";

export type StepperItem = {
  id: string;
  label: string;
  description?: string;
  status: "complete" | "current" | "upcoming";
};

type StepperProps = {
  steps: StepperItem[];
};

export function Stepper({ steps }: StepperProps) {
  if (steps.length === 0) return null;

  return (
    <ol className="ui-stepper">
      {steps.map((step, index) => {
        const complete = step.status === "complete";
        return (
          <li className={`ui-stepper-item ui-stepper-${step.status}`} key={step.id}>
            <span className="ui-stepper-index" aria-label={`Langkah ${index + 1}`}>
              {complete ? <Check size={15} /> : <Circle size={13} />}
            </span>
            <span>
              <strong>{step.label}</strong>
              {step.description ? <small>{step.description}</small> : null}
            </span>
          </li>
        );
      })}
    </ol>
  );
}
