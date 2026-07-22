"use client";

import { ArrowLeft, Save } from "lucide-react";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated } from "@/lib/api-client";
import { loadOptions } from "@/lib/options";
import type { OptionItem } from "@/types/jobs";

type JobForm = Record<string, string>;
type CustomerRecord = {
  id: string;
  customer_name: string;
  status: string;
};
type CustomerPersonnel = {
  id: string;
  personnel_code: string;
  full_name: string;
  phone?: string | null;
  email?: string | null;
};

const initialForm: JobForm = {
  job_date: new Date().toISOString().slice(0, 10), customer_id: "", survey_type_id: "", location_id: "",
  pic_customer_personnel_id: "", pic_customer_name: "", pic_customer_phone: "", pic_customer_email: "", reference_no: "", booking_no: "", do_no: "", bl_no: "",
  vessel: "", voyage: "", trucking_company: "", priority: "normal", deadline: "", instruction: ""
};

export default function CreateJobPage() {
  return <ProtectedRoute><AppShell title="Buat Pekerjaan"><CreateJobContent /></AppShell></ProtectedRoute>;
}

function CreateJobContent() {
  const { accessToken } = useAuth();
  const router = useRouter();
  const [form, setForm] = useState<JobForm>(initialForm);
  const [customers, setCustomers] = useState<OptionItem[]>([]);
  const [surveyTypes, setSurveyTypes] = useState<OptionItem[]>([]);
  const [locations, setLocations] = useState<OptionItem[]>([]);
  const [personnel, setPersonnel] = useState<CustomerPersonnel[]>([]);
  const [selectedCustomer, setSelectedCustomer] = useState<CustomerRecord | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [dependencyNotice, setDependencyNotice] = useState<string | null>(null);
  const [isLoadingCustomers, setIsLoadingCustomers] = useState(true);
  const [isLoadingDependencies, setIsLoadingDependencies] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const isDirty = useMemo(() => JSON.stringify(form) !== JSON.stringify(initialForm), [form]);

  useEffect(() => {
    if (!accessToken) return;
    loadOptions(accessToken, "/master/customers", "customer_name", "customer_code")
      .then(setCustomers)
      .catch((err) => setError(err instanceof Error ? err.message : "Gagal mengambil Customer aktif."))
      .finally(() => setIsLoadingCustomers(false));
  }, [accessToken]);

  useEffect(() => {
    if (!accessToken || !form.customer_id) return;
    const timer = window.setTimeout(() => {
      setIsLoadingDependencies(true);
      setDependencyNotice(null);
      Promise.all([
        apiData<CustomerRecord>(`/master/customers/${form.customer_id}`, { accessToken }),
        loadOptions(accessToken, `/customers/${form.customer_id}/survey-types`, "name", "code"),
        loadOptions(accessToken, `/customers/${form.customer_id}/locations`, "location_name", "location_code"),
        apiPaginated<CustomerPersonnel>(`/customers/${form.customer_id}/personnel?page=1&per_page=100&status=active`, { accessToken })
      ]).then(([customer, nextSurveyTypes, nextLocations, personnelResult]) => {
        setSelectedCustomer(customer);
        setSurveyTypes(nextSurveyTypes);
        setLocations(nextLocations);
        setPersonnel(personnelResult.rows);
        setDependencyNotice(
          nextSurveyTypes.length > 0 && nextLocations.length > 0 && personnelResult.rows.length > 0
            ? null
            : "Master Data Customer belum lengkap. Pastikan Personnel/PIC, Location, dan Survey Type aktif sudah tersedia."
        );
      }).catch((err) => {
        setError(err instanceof Error ? err.message : "Gagal mengambil PIC, Location, dan Survey Type.");
        setSurveyTypes([]);
        setLocations([]);
        setPersonnel([]);
      }).finally(() => setIsLoadingDependencies(false));
    }, 0);
    return () => window.clearTimeout(timer);
  }, [accessToken, form.customer_id]);

  useEffect(() => {
    if (!isDirty) return;
    const handleBeforeUnload = (event: BeforeUnloadEvent) => event.preventDefault();
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [isDirty]);

  function update(key: string, value: string) {
    if (key === "customer_id") {
      setSelectedCustomer(null);
      setSurveyTypes([]);
      setLocations([]);
      setPersonnel([]);
      setDependencyNotice(null);
    }
    setForm((current) => {
      if (key !== "customer_id") return { ...current, [key]: value };
      return {
        ...current,
        customer_id: value,
        location_id: "",
        survey_type_id: "",
        pic_customer_personnel_id: "",
        pic_customer_name: "",
        pic_customer_phone: "",
        pic_customer_email: ""
      };
    });
  }

  function selectPersonnel(value: string) {
    const selected = personnel.find((item) => item.id === value);
    setForm((current) => ({
      ...current,
      pic_customer_personnel_id: value,
      pic_customer_name: selected?.full_name ?? "",
      pic_customer_phone: selected?.phone ?? "",
      pic_customer_email: selected?.email ?? ""
    }));
  }

  async function submit() {
    if (!accessToken) return;
    const validationError = validate(form);
    if (validationError) {
      setError(validationError);
      return;
    }
    setIsSubmitting(true);
    setError(null);
    try {
      const payload = { ...form, deadline: form.deadline ? new Date(form.deadline).toISOString() : undefined };
      const result = await apiData<{ id: string }>("/jobs", { method: "POST", accessToken, body: JSON.stringify(payload) });
      router.replace(`/jobs/${result.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal membuat pekerjaan.");
    } finally {
      setIsSubmitting(false);
    }
  }

  function leavePage() {
    if (!isDirty || window.confirm("Perubahan belum disimpan. Tinggalkan halaman?")) router.push("/jobs");
  }

  const dependenciesDisabled = !form.customer_id || isLoadingDependencies;
  return (
    <div className="page-stack">
      <PageHeader title="Buat Pekerjaan Inspeksi" description="Buat header pekerjaan sebelum menambah peti kemas dan menugaskan Surveyor GIFT." action={{ label: isSubmitting ? "Menyimpan" : "Simpan Pekerjaan", icon: Save, onClick: () => void submit(), disabled: isSubmitting || isLoadingDependencies }} />
      <div className="job-actions"><button className="secondary-button" onClick={leavePage} type="button"><ArrowLeft size={17} /><span>Kembali ke Semua Pekerjaan</span></button></div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      {dependencyNotice ? <div className="alert alert-warning">{dependencyNotice}</div> : null}
      <section className="workspace-panel">
        <div className="form-grid form-grid-wide">
          <Field label="Tanggal Pekerjaan"><input required type="date" value={form.job_date} onChange={(event) => update("job_date", event.target.value)} /></Field>
          <Field label="Customer"><Select disabled={isLoadingCustomers} value={form.customer_id} onChange={(value) => update("customer_id", value)} options={customers} placeholder={isLoadingCustomers ? "Memuat Customer..." : "Pilih Customer terlebih dahulu"} /></Field>
          <Field label="PIC Customer"><select disabled={dependenciesDisabled} value={form.pic_customer_personnel_id} onChange={(event) => selectPersonnel(event.target.value)}><option value="">{dependenciesDisabled ? "Pilih Customer terlebih dahulu" : "Pilih Personnel/PIC aktif"}</option>{personnel.map((item) => <option key={item.id} value={item.id}>{item.personnel_code} - {item.full_name}</option>)}</select></Field>
          <Field label="Telepon PIC"><input readOnly value={form.pic_customer_phone} placeholder="Belum tersedia" /></Field>
          <Field label="Email PIC"><input readOnly value={form.pic_customer_email} placeholder="Belum tersedia" /></Field>
          <Field label="Location"><Select disabled={dependenciesDisabled} value={form.location_id} onChange={(value) => update("location_id", value)} options={locations} placeholder={dependenciesDisabled ? "Pilih Customer terlebih dahulu" : "Pilih Location aktif"} /></Field>
          <Field label="Survey Type"><Select disabled={dependenciesDisabled} value={form.survey_type_id} onChange={(value) => update("survey_type_id", value)} options={surveyTypes} placeholder={dependenciesDisabled ? "Pilih Customer terlebih dahulu" : "Pilih Survey Type aktif"} /></Field>
          <Field label="Prioritas"><select value={form.priority} onChange={(event) => update("priority", event.target.value)}><option value="normal">Normal</option><option value="urgent">Urgent</option></select></Field>
          <Field label="Deadline"><input type="datetime-local" value={form.deadline} onChange={(event) => update("deadline", event.target.value)} /></Field>
          <Field label="Nomor Referensi"><input value={form.reference_no} onChange={(event) => update("reference_no", event.target.value)} /></Field>
          <Field label="Booking Number"><input value={form.booking_no} onChange={(event) => update("booking_no", event.target.value)} /></Field>
          <Field label="DO Number"><input value={form.do_no} onChange={(event) => update("do_no", event.target.value)} /></Field>
          <Field label="BL Number"><input value={form.bl_no} onChange={(event) => update("bl_no", event.target.value)} /></Field>
          <Field label="Vessel"><input value={form.vessel} onChange={(event) => update("vessel", event.target.value)} /></Field>
          <Field label="Voyage"><input value={form.voyage} onChange={(event) => update("voyage", event.target.value)} /></Field>
          <Field label="Trucking Company"><input value={form.trucking_company} onChange={(event) => update("trucking_company", event.target.value)} /></Field>
          <label className="field form-span-2"><span>Instruksi Admin</span><textarea rows={4} value={form.instruction} onChange={(event) => update("instruction", event.target.value)} /></label>
        </div>
        {selectedCustomer && personnel.length === 0 ? <p className="muted-text">Customer aktif ini belum mempunyai Personnel/PIC aktif di Master Data.</p> : null}
      </section>
    </div>
  );
}

function validate(form: JobForm) {
  if (!form.job_date) return "Tanggal pekerjaan wajib diisi.";
  if (!form.customer_id) return "Customer wajib dipilih terlebih dahulu.";
  if (!form.pic_customer_personnel_id) return "Personnel/PIC Customer wajib dipilih.";
  if (!form.location_id) return "Location wajib dipilih.";
  if (!form.survey_type_id) return "Survey Type wajib dipilih.";
  if (form.deadline && new Date(form.deadline).getTime() < new Date(form.job_date).getTime()) return "Deadline tidak boleh lebih awal dari tanggal pekerjaan.";
  return null;
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return <label className="field"><span>{label}</span>{children}</label>;
}

function Select({ value, options, onChange, disabled, placeholder }: { value: string; options: OptionItem[]; onChange: (value: string) => void; disabled?: boolean; placeholder: string }) {
  return <select disabled={disabled} value={value} onChange={(event) => onChange(event.target.value)}><option value="">{placeholder}</option>{options.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select>;
}
