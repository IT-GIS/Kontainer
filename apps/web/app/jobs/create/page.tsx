"use client";

import { Save } from "lucide-react";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { loadOptions } from "@/lib/options";
import type { OptionItem } from "@/types/jobs";

type JobForm = Record<string, string>;

const initialForm: JobForm = {
  job_date: new Date().toISOString().slice(0, 10), customer_id: "", survey_type_id: "", location_id: "",
  pic_customer_name: "", pic_customer_phone: "", pic_customer_email: "", reference_no: "", booking_no: "", do_no: "", bl_no: "",
  vessel: "", voyage: "", trucking_company: "", priority: "normal", deadline: "", instruction: ""
};

export default function CreateJobPage() {
  return <ProtectedRoute><AppShell title="Create Job"><CreateJobContent /></AppShell></ProtectedRoute>;
}

function CreateJobContent() {
  const { accessToken } = useAuth();
  const router = useRouter();
  const [form, setForm] = useState<JobForm>(initialForm);
  const [customers, setCustomers] = useState<OptionItem[]>([]);
  const [surveyTypes, setSurveyTypes] = useState<OptionItem[]>([]);
  const [locations, setLocations] = useState<OptionItem[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (!accessToken) return;
    void Promise.all([
      loadOptions(accessToken, "/master/customers", "customer_name", "customer_code"),
      loadOptions(accessToken, "/master/survey-types", "name", "code"),
      loadOptions(accessToken, "/master/locations", "location_name", "location_code")
    ]).then(([nextCustomers, nextSurveyTypes, nextLocations]) => {
      setCustomers(nextCustomers); setSurveyTypes(nextSurveyTypes); setLocations(nextLocations);
    }).catch((err) => setError(err instanceof Error ? err.message : "Gagal mengambil master data."));
  }, [accessToken]);

  async function submit() {
    if (!accessToken) return;
    setIsSubmitting(true); setError(null);
    try {
      const payload = { ...form, deadline: form.deadline ? new Date(form.deadline).toISOString() : undefined };
      const result = await apiData<{ id: string }>("/jobs", { method: "POST", accessToken, body: JSON.stringify(payload) });
      router.replace(`/jobs/${result.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal membuat job.");
    } finally { setIsSubmitting(false); }
  }

  return (
    <div className="page-stack">
      <PageHeader title="Create Job Order" description="Create the job header before adding containers and assigning surveyors." action={{ label: isSubmitting ? "Saving" : "Save Job", icon: Save, onClick: () => void submit(), disabled: isSubmitting }} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <section className="workspace-panel">
        <div className="form-grid form-grid-wide">
          <Field label="Job Date"><input type="date" value={form.job_date} onChange={(e) => setFormValue(setForm, "job_date", e.target.value)} /></Field>
          <Field label="Customer"><Select value={form.customer_id} onChange={(value) => setFormValue(setForm, "customer_id", value)} options={customers} /></Field>
          <Field label="Survey Type"><Select value={form.survey_type_id} onChange={(value) => setFormValue(setForm, "survey_type_id", value)} options={surveyTypes} /></Field>
          <Field label="Location"><Select value={form.location_id} onChange={(value) => setFormValue(setForm, "location_id", value)} options={locations} /></Field>
          <Field label="Priority"><select value={form.priority} onChange={(e) => setFormValue(setForm, "priority", e.target.value)}><option value="normal">normal</option><option value="urgent">urgent</option></select></Field>
          <Field label="Deadline"><input type="datetime-local" value={form.deadline} onChange={(e) => setFormValue(setForm, "deadline", e.target.value)} /></Field>
          {['pic_customer_name','pic_customer_phone','pic_customer_email','reference_no','booking_no','do_no','bl_no','vessel','voyage','trucking_company'].map((key) => <Field key={key} label={labelize(key)}><input value={form[key]} onChange={(e) => setFormValue(setForm, key, e.target.value)} /></Field>)}
          <label className="field form-span-2"><span>Instruction</span><textarea rows={4} value={form.instruction} onChange={(e) => setFormValue(setForm, "instruction", e.target.value)} /></label>
        </div>
      </section>
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) { return <label className="field"><span>{label}</span>{children}</label>; }
function Select({ value, options, onChange }: { value: string; options: OptionItem[]; onChange: (value: string) => void }) { return <select value={value} onChange={(e) => onChange(e.target.value)}><option value="">Select</option>{options.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select>; }
function setFormValue(setter: React.Dispatch<React.SetStateAction<JobForm>>, key: string, value: string) { setter((current) => ({ ...current, [key]: value })); }
function labelize(value: string) { return value.split("_").map((part) => part.toUpperCase()).join(" "); }