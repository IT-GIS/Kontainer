"use client";

import { AlertCircle, Check, Circle } from "lucide-react";

export type StepperItem = {
  id: string;
  label: string;
  description?: string;
  status: "complete" | "current" | "upcoming" | "error";
  clickable?: boolean;
};

type StepperProps = {
  steps: StepperItem[];
  onStepClick?: (step: StepperItem, index: number) => void;
  compact?: boolean;
};

export function Stepper({ steps, onStepClick, compact }: StepperProps) {
  if (steps.length === 0) return null;

  return (
    <ol className={`ui-stepper ${compact ? "ui-stepper-compact" : ""}`}>
      {steps.map((step, index) => {
        const complete = step.status === "complete";
        const current = step.status === "current";
        const canClick = Boolean(onStepClick && (step.clickable || complete || current));
        const marker = step.status === "error" ? <AlertCircle size={15} /> : complete ? <Check size={15} /> : <Circle size={13} />;
        const content = (
          <>
            <span className="ui-stepper-index" aria-label={`Langkah ${index + 1}`}>{marker}</span>
            <span>
              <strong>{index + 1}. {step.label}</strong>
              {step.description ? <small>{step.description}</small> : null}
            </span>
          </>
        );

        return (
          <li aria-current={current ? "step" : undefined} className={`ui-stepper-item ui-stepper-${step.status}`} key={step.id}>
            {canClick ? (
              <button onClick={() => onStepClick?.(step, index)} type="button">
                {content}
              </button>
            ) : content}
          </li>
        );
      })}
    </ol>
  );
}