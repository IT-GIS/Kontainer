"use client";

import { ArrowLeft, Save } from "lucide-react";
import { useRouter } from "next/navigation";
import { useEffect, useMemo, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
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
type CustomerReadiness = {
	overall_ready: boolean;
	checks: Array<{ key: string; label: string; ready: boolean; count: number }>;
};

const initialForm: JobForm = {
  job_date: new Date().toISOString().slice(0, 10), customer_id: "", survey_type_id: "", location_id: "",
  pic_customer_personnel_id: "", pic_customer_name: "", pic_customer_phone: "", pic_customer_email: "", reference_no: "", spk_no: "", spk_date: "", spk_notes: "", booking_no: "", do_no: "", bl_no: "",
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
	const [readiness, setReadiness] = useState<CustomerReadiness | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [dependencyNotice, setDependencyNotice] = useState<string | null>(null);
  const [personnelNotice, setPersonnelNotice] = useState<string | null>(null);
  const [isLoadingCustomers, setIsLoadingCustomers] = useState(true);
  const [isLoadingDependencies, setIsLoadingDependencies] = useState(false);
  const [isLoadingPersonnel, setIsLoadingPersonnel] = useState(false);
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
		apiData<CustomerReadiness>(`/customers/${form.customer_id}/readiness`, { accessToken })
	  ]).then(([customer, nextSurveyTypes, nextLocations, nextReadiness]) => {
        setSelectedCustomer(customer);
		setReadiness(nextReadiness);
        setSurveyTypes(nextSurveyTypes);
        setLocations(nextLocations);
        setForm((current) => ({ ...current, survey_type_id: nextSurveyTypes.length === 1 ? nextSurveyTypes[0].id : "" }));
		if (!nextReadiness.overall_ready) {
			setDependencyNotice(`Master Data Customer belum siap: ${nextReadiness.checks.filter((item) => !item.ready).map((item) => item.label).join(", ")}.`);
		} else if (nextLocations.length === 0) {
          setDependencyNotice("Master Data Customer belum lengkap: Location aktif belum tersedia.");
        } else if (nextSurveyTypes.length === 0) {
			setDependencyNotice("Survey Type aktif untuk Customer belum tersedia.");
        } else {
          setDependencyNotice(null);
        }
      }).catch((err) => {
        setError(err instanceof Error ? err.message : "Gagal mengambil PIC, Location, dan Survey Type.");
        setSurveyTypes([]);
        setLocations([]);
        setPersonnel([]);
		setReadiness(null);
        setForm((current) => ({ ...current, survey_type_id: "" }));
      }).finally(() => setIsLoadingDependencies(false));
    }, 0);
    return () => window.clearTimeout(timer);
  }, [accessToken, form.customer_id]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      if (!accessToken || !form.customer_id || !form.location_id) {
        setPersonnel([]);
        return;
      }
      setIsLoadingPersonnel(true);
      apiData<CustomerPersonnel[]>(`/customers/${form.customer_id}/locations/${form.location_id}/personnel`, { accessToken })
        .then((items) => {
          setPersonnel(items);
          setPersonnelNotice(items.length === 0 ? "Location terpilih belum mempunyai mapping Personel/PIC aktif. Atur mapping pada detail Customer terlebih dahulu." : null);
        })
        .catch((err) => {
          setPersonnel([]);
          setPersonnelNotice(null);
          setError(err instanceof Error ? err.message : "Personel/PIC Location gagal dimuat.");
        })
        .finally(() => setIsLoadingPersonnel(false));
    }, 0);
    return () => window.clearTimeout(timer);
  }, [accessToken, form.customer_id, form.location_id]);

  useEffect(() => {
    if (!isDirty) return;
    const handleBeforeUnload = (event: BeforeUnloadEvent) => event.preventDefault();
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [isDirty]);

  function update(key: string, value: string) {
    if (key === "customer_id") {
      setSelectedCustomer(null);
		setReadiness(null);
      setSurveyTypes([]);
      setLocations([]);
      setPersonnel([]);
      setDependencyNotice(null);
      setPersonnelNotice(null);
    }
    setForm((current) => {
      if (key !== "customer_id" && key !== "location_id") return { ...current, [key]: value };
      if (key === "location_id") return {
        ...current,
        location_id: value,
        pic_customer_personnel_id: "",
        pic_customer_name: "",
        pic_customer_phone: "",
        pic_customer_email: ""
      };
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
	const validationError = validate(form, readiness?.overall_ready ?? false);
    if (validationError) {
      setError(validationError);
      return;
    }
    setIsSubmitting(true);
    setError(null);
    try {
      const payload = { ...form, spk_date: form.spk_date || undefined, deadline: form.deadline ? new Date(form.deadline).toISOString() : undefined };
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
  const personnelDisabled = dependenciesDisabled || !form.location_id || isLoadingPersonnel;
  return (
    <div className="page-stack">
	  <PageHeader title="Buat Pekerjaan Inspeksi" description="Buat header pekerjaan setelah Master Data Customer dinyatakan siap." action={{ label: isSubmitting ? "Menyimpan" : "Simpan Pekerjaan", icon: Save, onClick: () => void submit(), disabled: isSubmitting || isLoadingDependencies || !form.survey_type_id || readiness?.overall_ready !== true }} />
      <div className="job-actions"><button className="secondary-button" onClick={leavePage} type="button"><ArrowLeft size={17} /><span>Kembali ke Semua Pekerjaan</span></button></div>
      {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
      {dependencyNotice ? <div className="alert alert-warning">{dependencyNotice}</div> : null}
      {personnelNotice ? <div className="alert alert-warning">{personnelNotice}</div> : null}
      <section className="workspace-panel">
        <div className="form-grid form-grid-wide">
          <Field label="Tanggal Pekerjaan"><input required type="date" value={form.job_date} onChange={(event) => update("job_date", event.target.value)} /></Field>
          <Field label="Customer"><Select disabled={isLoadingCustomers} value={form.customer_id} onChange={(value) => update("customer_id", value)} options={customers} placeholder={isLoadingCustomers ? "Memuat Customer..." : "Pilih Customer terlebih dahulu"} /></Field>
          <Field label="Location Pemeriksaan"><Select disabled={dependenciesDisabled} value={form.location_id} onChange={(value) => update("location_id", value)} options={locations} placeholder={dependenciesDisabled ? "Pilih Customer terlebih dahulu" : "Pilih Location aktif"} /></Field>
          <Field label="Personel/PIC Customer"><select disabled={personnelDisabled} value={form.pic_customer_personnel_id} onChange={(event) => selectPersonnel(event.target.value)}><option value="">{!form.location_id ? "Pilih Location terlebih dahulu" : isLoadingPersonnel ? "Memuat Personel/PIC..." : "Pilih Personel/PIC yang dipetakan"}</option>{personnel.map((item) => <option key={item.id} value={item.id}>{item.personnel_code} - {item.full_name}</option>)}</select></Field>
          <Field label="Telepon PIC"><input readOnly value={form.pic_customer_phone} placeholder="Belum tersedia" /></Field>
          <Field label="Email PIC"><input readOnly value={form.pic_customer_email} placeholder="Belum tersedia" /></Field>
		  <Field label="Jenis Pemeriksaan"><Select disabled={dependenciesDisabled} value={form.survey_type_id} onChange={(value) => update("survey_type_id", value)} options={surveyTypes} placeholder={dependenciesDisabled ? "Pilih Customer terlebih dahulu" : "Pilih Survey Type aktif"} /></Field>
          <Field label="Prioritas"><select value={form.priority} onChange={(event) => update("priority", event.target.value)}><option value="normal">Normal</option><option value="urgent">Urgent</option></select></Field>
          <Field label="Deadline"><input type="datetime-local" value={form.deadline} onChange={(event) => update("deadline", event.target.value)} /></Field>
          <Field label="Nomor Referensi"><input value={form.reference_no} onChange={(event) => update("reference_no", event.target.value)} /></Field>
          <Field label="Nomor SPK"><input value={form.spk_no} onChange={(event) => update("spk_no", event.target.value)} /></Field>
          <Field label="Tanggal SPK"><input type="date" value={form.spk_date} onChange={(event) => update("spk_date", event.target.value)} /></Field>
          <Field label="Booking Number"><input value={form.booking_no} onChange={(event) => update("booking_no", event.target.value)} /></Field>
          <Field label="DO Number"><input value={form.do_no} onChange={(event) => update("do_no", event.target.value)} /></Field>
          <Field label="BL Number"><input value={form.bl_no} onChange={(event) => update("bl_no", event.target.value)} /></Field>
          <Field label="Vessel"><input value={form.vessel} onChange={(event) => update("vessel", event.target.value)} /></Field>
          <Field label="Voyage"><input value={form.voyage} onChange={(event) => update("voyage", event.target.value)} /></Field>
          <Field label="Trucking Company"><input value={form.trucking_company} onChange={(event) => update("trucking_company", event.target.value)} /></Field>
          <label className="field form-span-2"><span>Keterangan SPK</span><textarea rows={3} value={form.spk_notes} onChange={(event) => update("spk_notes", event.target.value)} /></label>
          <label className="field form-span-2"><span>Instruksi Admin</span><textarea rows={4} value={form.instruction} onChange={(event) => update("instruction", event.target.value)} /></label>
        </div>
        <div className="alert alert-warning">Lampiran SPK belum dapat diunggah pada tahap ini karena penyimpanan objek belum diverifikasi. Nomor, tanggal, dan keterangan SPK tetap dapat disimpan.</div>
        {selectedCustomer && form.location_id && personnel.length === 0 ? <p className="muted-text">Location terpilih belum mempunyai Personel/PIC aktif yang dipetakan.</p> : null}
      </section>
    </div>
  );
}

function validate(form: JobForm, customerReady: boolean) {
  if (!form.job_date) return "Tanggal pekerjaan wajib diisi.";
  if (!form.customer_id) return "Customer wajib dipilih terlebih dahulu.";
  if (!form.location_id) return "Location Pemeriksaan wajib dipilih.";
  if (!form.pic_customer_personnel_id) return "Personel/PIC Customer yang dipetakan ke Location wajib dipilih.";
	if (!form.survey_type_id) return "Survey Type aktif wajib dipilih.";
	if (!customerReady) return "Master Data Customer belum siap. Lengkapi seluruh item readiness sebelum membuat Job.";
  if (form.deadline && new Date(form.deadline).getTime() < new Date(form.job_date).getTime()) return "Deadline tidak boleh lebih awal dari tanggal pekerjaan.";
  return null;
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return <label className="field"><span>{label}</span>{children}</label>;
}

function Select({ value, options, onChange, disabled, placeholder }: { value: string; options: OptionItem[]; onChange: (value: string) => void; disabled?: boolean; placeholder: string }) {
  return <select disabled={disabled} value={value} onChange={(event) => onChange(event.target.value)}><option value="">{placeholder}</option>{options.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select>;
}
