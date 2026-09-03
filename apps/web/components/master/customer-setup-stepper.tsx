"use client";

import { useRouter } from "next/navigation";
import { CompletionBadge } from "@/components/ui/completion-badge";
import { Stepper, type StepperItem } from "@/components/ui/stepper";
import type { CustomerReadiness } from "@/components/master/customer-readiness";
import { customerSetupTabs, type CustomerSetupTab } from "@/components/master/customer-setup-tabs";

export type { CustomerSetupTab } from "@/components/master/customer-setup-tabs";

export function CustomerSetupStepper({
  customerId,
  activeTab,
  readiness
}: {
  customerId: string;
  activeTab: CustomerSetupTab;
  readiness: CustomerReadiness | null;
}) {
  const router = useRouter();
  const baseHref = `/master/customers/customer/${customerId}`;
  const steps: StepperItem[] = customerSetupTabs.map((step) => ({
    id: step.id,
    label: step.label,
    description: step.description,
    status: step.id === activeTab ? "current" : stepReady(step.id, readiness) ? "complete" : "upcoming",
    clickable: true
  }));

  return (
    <section className="customer-setup-navigation" aria-labelledby="customer-setup-title">
      <div className="customer-setup-heading">
        <div><p>Setup Customer</p><h2 id="customer-setup-title">Selesaikan tanpa kembali ke sidebar</h2></div>
        {readiness ? <CompletionBadge complete={readiness.ready_count} total={readiness.total_checks} label="Setup" /> : null}
      </div>
      <Stepper steps={steps} onStepClick={(step) => router.push(`${baseHref}?tab=${step.id}`)} />
    </section>
  );
}

function stepReady(step: CustomerSetupTab, readiness: CustomerReadiness | null) {
  if (!readiness) return false;
  const checks = new Map(readiness.checks.map((check) => [check.key, check.ready]));
  const all = (...keys: string[]) => keys.every((key) => checks.get(key) === true);
  if (step === "profile") return all("profile");
  if (step === "location-pic") return all("location", "personnel", "location_pic_mapping");
  if (step === "survey-sheet") return all("survey_type", "container_type", "location");
  if (step === "checklist") return all("checklist_template", "checklist_item");
  if (step === "cedex") return all("cedex_location", "cedex_component", "cedex_damage", "cedex_action_repair", "cedex_material", "responsibility");
  if (step === "references") return all("test_parameter_mapping", "severity_mapping");
  if (step === "photo-evidence") return all("photo_category_mapping");
  return readiness.overall_ready;
}
