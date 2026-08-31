"use client";

import { Stepper, type StepperItem } from "@/components/ui/stepper";

export type JobCreationStep = "information" | "containers" | "assignment" | "confirmation";

const definitions: Array<{ id: JobCreationStep; label: string; description: string }> = [
  { id: "information", label: "Informasi Pekerjaan", description: "Customer, Location, PIC, SPK, dan jadwal" },
  { id: "containers", label: "Peti Kemas", description: "Tambah atau import peti kemas" },
  { id: "assignment", label: "Penugasan", description: "Pilih peti kemas dan Surveyor GIFT" },
  { id: "confirmation", label: "Konfirmasi", description: "Periksa kesiapan dan selesaikan" }
];

export function JobCreationStepper({
  current,
  completed = [],
  onStepClick
}: {
  current: JobCreationStep;
  completed?: JobCreationStep[];
  onStepClick?: (step: JobCreationStep) => void;
}) {
  const steps: StepperItem[] = definitions.map((step) => ({
    ...step,
    status: step.id === current ? "current" : completed.includes(step.id) ? "complete" : "upcoming",
    clickable: step.id === current || completed.includes(step.id)
  }));
  return <section className="job-creation-stepper" aria-label="Tahap pembuatan pekerjaan"><Stepper compact steps={steps} onStepClick={onStepClick ? (step) => onStepClick(step.id as JobCreationStep) : undefined} /></section>;
}
