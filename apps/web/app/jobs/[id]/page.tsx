"use client";

import { useParams, useSearchParams } from "next/navigation";
import { useCallback, useEffect, useRef, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import {
  JobAssignmentTab,
  JobContainersTab,
  JobDocumentsTab,
  JobHistoryTab,
  JobProgressTab,
  JobReviewTab,
  JobSummaryTab,
  JobSurveyResultsTab
} from "@/components/jobs/job-detail-tabs";
import { AppShell } from "@/components/layout/app-shell";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import { loadOptions } from "@/lib/options";
import { can } from "@/lib/permissions";
import type { ContainerTypeOption, JobDetailSupportingData } from "@/types/job-detail-workspace";
import type { JobDetail, OptionItem } from "@/types/jobs";
import type { ReportSummary, ReportVersion, ReviewDetail } from "@/types/reviews";
import type { SurveyListItem } from "@/types/surveys";

const tabs = [
  { id: "ringkasan", label: "Ringkasan" },
  { id: "peti-kemas", label: "Peti Kemas" },
  { id: "penugasan", label: "Penugasan" },
  { id: "progress", label: "Progress Pemeriksaan" },
  { id: "hasil-survey", label: "Hasil Survey" },
  { id: "review", label: "Review" },
  { id: "dokumen", label: "Dokumen" },
  { id: "riwayat", label: "Riwayat" }
] as const;
type TabID = (typeof tabs)[number]["id"];

type ContainerForm = {
  container_no: string;
  container_type_id: string;
  iso_type_code: string;
  seal_no: string;
  cargo_status: string;
  gross_weight: string;
  tare_weight: string;
  payload: string;
  manufacture_date: string;
  check_digit_override_reason: string;
  truck_no: string;
  driver_name: string;
  csc_plate_status: string;
	csc_plate_number: string;
	csc_approval_reference: string;
	csc_manufacture_date: string;
	csc_next_examination_date: string;
	csc_program_type: string;
  remark: string;
};
type ContainerCheck = { is_format_valid: boolean; is_check_digit_valid: boolean };
type CustomerReadiness = { overall_ready: boolean; checks: Array<{ label: string; ready: boolean }> };

const emptyContainer: ContainerForm = {
  container_no: "", container_type_id: "", iso_type_code: "", seal_no: "", cargo_status: "unknown",
  gross_weight: "", tare_weight: "", payload: "", manufacture_date: "", check_digit_override_reason: "",
	truck_no: "", driver_name: "", csc_plate_status: "not_checked", csc_plate_number: "",
	csc_approval_reference: "", csc_manufacture_date: "", csc_next_examination_date: "",
	csc_program_type: "", remark: ""
};
const emptySupport: JobDetailSupportingData = { surveys: [], reviews: [], documents: [], versions: {} };

export default function JobDetailPage() {
  return <ProtectedRoute><AppShell title="Detail Pekerjaan"><JobDetailContent /></AppShell></ProtectedRoute>;
}

function JobDetailContent() {
  const params = useParams<{ id: string }>();
  const searchParams = useSearchParams();
  const jobID = params.id;
  const { accessToken, user } = useAuth();
  const [job, setJob] = useState<JobDetail | null>(null);
  const [support, setSupport] = useState<JobDetailSupportingData>(emptySupport);
  const [activeTab, setActiveTab] = useState<TabID>("ringkasan");
  const [error, setError] = useState<string | null>(null);
  const [supportWarning, setSupportWarning] = useState<string | null>(null);
	const [readiness, setReadiness] = useState<CustomerReadiness | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [containerDialog, setContainerDialog] = useState(false);
  const [assignDialog, setAssignDialog] = useState(false);
  const [reassignDialog, setReassignDialog] = useState(false);
  const [containerForm, setContainerForm] = useState<ContainerForm>(emptyContainer);
  const [selectedContainers, setSelectedContainers] = useState<string[]>([]);
  const [surveyorID, setSurveyorID] = useState("");
  const [assignmentStartDate, setAssignmentStartDate] = useState("");
  const [assignmentDueDate, setAssignmentDueDate] = useState("");
  const [assignmentInstruction, setAssignmentInstruction] = useState("");
  const [reassignSurveyorID, setReassignSurveyorID] = useState("");
  const [reassignReason, setReassignReason] = useState("");
  const [containerTypes, setContainerTypes] = useState<ContainerTypeOption[]>([]);
  const [surveyors, setSurveyors] = useState<OptionItem[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const assignmentOpened = useRef(false);

  const canAddContainer = can(user, "job_containers.create.all");
  const canImport = can(user, "job_containers.import.all");
	const canAssignPermission = can(user, "assignments.assign.all");
	const canAssign = canAssignPermission && readiness?.overall_ready === true;
  const canReassign = can(user, "job_containers.reassign.all");
  const canViewReviews = can(user, "reviews.view.all");
  const canViewReports = can(user, "reports.view.all");

  const loadSupportingData = useCallback(async (item: JobDetail) => {
    if (!accessToken) return;
    const warnings: string[] = [];
    let surveys: SurveyListItem[] = [];
    let reviews: ReviewDetail[] = [];
    let documents: ReportSummary[] = [];
    const versions: Record<string, ReportVersion[]> = {};
    if (canViewReviews) {
      try {
        const result = await apiPaginated<SurveyListItem>(`/surveys/monitoring${buildQuery({ page: 1, per_page: 100, search: item.job_order_no })}`, { accessToken });
        surveys = result.rows.filter((row) => row.job_order_no === item.job_order_no);
        const details = await Promise.all(surveys.map((survey) => apiData<ReviewDetail>(`/reviews/${survey.survey_id}`, { accessToken }).catch(() => null)));
        reviews = details.filter((detail): detail is ReviewDetail => detail !== null);
      } catch {
        warnings.push("Hasil survey dan review tidak dapat dimuat untuk sesi ini.");
      }
    }
    if (canViewReports) {
      try {
        const result = await apiPaginated<ReportSummary>(`/reports${buildQuery({ page: 1, per_page: 100, job_order_id: item.id })}`, { accessToken });
        documents = result.rows;
        await Promise.all(documents.map(async (document) => {
          versions[document.id] = await apiData<ReportVersion[]>(`/reports/${document.id}/versions`, { accessToken }).catch(() => []);
        }));
      } catch {
        warnings.push("Metadata dokumen tidak dapat dimuat untuk sesi ini.");
      }
    }
    setSupport({ surveys, reviews, documents, versions });
    setSupportWarning(warnings.join(" ") || null);
  }, [accessToken, canViewReports, canViewReviews]);

  const loadJob = useCallback(async () => {
    if (!accessToken || !jobID) return;
    setIsLoading(true);
    setError(null);
    try {
      const item = await apiData<JobDetail>(`/jobs/${jobID}`, { accessToken });
      setJob(item);
      await loadSupportingData(item);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil detail pekerjaan.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, jobID, loadSupportingData]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadJob(), 0);
    return () => window.clearTimeout(timer);
  }, [loadJob]);

  useEffect(() => {
    if (!accessToken) return;
    loadOptions(accessToken, "/master/surveyors", "name", "surveyor_code")
      .then(setSurveyors)
      .catch(() => setSupportWarning("Pilihan Surveyor GIFT tidak dapat dimuat."));
  }, [accessToken]);

  useEffect(() => {
    if (!accessToken || !job?.customer_id) return;
    apiPaginated<Record<string, unknown>>(
      `/customers/${job.customer_id}/container-types?page=1&per_page=100&status=active`,
      { accessToken }
    ).then((typeResult) => {
      setContainerTypes(typeResult.rows.map((row) => ({
        id: String(row.id),
        label: String(row.type ?? row.type_name ?? row.code ?? row.id),
        code: String(row.code ?? ""),
        isoCode: String(row.iso_code ?? "")
      })));
    }).catch(() => setSupportWarning("Pilihan Container Type milik Customer tidak dapat dimuat."));
  }, [accessToken, job?.customer_id]);

	useEffect(() => {
		if (!accessToken || !job?.customer_id) return;
		apiData<CustomerReadiness>(`/customers/${job.customer_id}/readiness`, { accessToken })
			.then(setReadiness)
			.catch(() => setSupportWarning("Status readiness Customer tidak dapat dimuat; backend tetap akan memvalidasi saat assign."));
	}, [accessToken, job?.customer_id]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      const requested = searchParams.get("tab");
      if (tabs.some((tab) => tab.id === requested)) setActiveTab(requested as TabID);
      if (!assignmentOpened.current && job && canAssign && searchParams.get("action") === "assign") {
        assignmentOpened.current = true;
        setActiveTab("penugasan");
        setAssignDialog(true);
      }
    }, 0);
    return () => window.clearTimeout(timer);
  }, [canAssign, job, searchParams]);

  async function addContainer() {
    if (!accessToken) return;
    setIsSubmitting(true);
    setError(null);
    try {
      if (!containerForm.container_no.trim()) throw new Error("Nomor peti kemas wajib diisi.");
      for (const [label, value] of [["Gross Weight", containerForm.gross_weight], ["Tare Weight", containerForm.tare_weight], ["Payload", containerForm.payload]]) {
        if (value !== "" && (!Number.isFinite(Number(value)) || Number(value) < 0)) throw new Error(`${label} tidak boleh negatif.`);
      }
      if (containerForm.manufacture_date && containerForm.manufacture_date > new Date().toISOString().slice(0, 10)) throw new Error("Tanggal pembuatan tidak boleh di masa depan.");
	  if (containerForm.csc_manufacture_date && containerForm.csc_manufacture_date > new Date().toISOString().slice(0, 10)) throw new Error("Tanggal manufacture CSC tidak boleh di masa depan.");
	  if (containerForm.csc_manufacture_date && containerForm.csc_next_examination_date && containerForm.csc_next_examination_date < containerForm.csc_manufacture_date) throw new Error("Next Examination CSC tidak boleh lebih awal dari tanggal manufacture CSC.");
      const validation = await apiData<ContainerCheck>("/job-containers/validate-container-no", { method: "POST", accessToken, body: JSON.stringify({ container_no: containerForm.container_no }) });
      if (!validation.is_format_valid) throw new Error("Format nomor peti kemas tidak valid.");
      if (!validation.is_check_digit_valid && !containerForm.check_digit_override_reason.trim()) throw new Error("Alasan override wajib diisi untuk check digit yang tidak valid.");
      await apiData(`/jobs/${jobID}/containers`, { method: "POST", accessToken, body: JSON.stringify(containerPayload(containerForm)) });
      setContainerDialog(false);
      setContainerForm(emptyContainer);
      await loadJob();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal menambah peti kemas.");
    } finally {
      setIsSubmitting(false);
    }
  }

  async function assignSurveyor() {
    if (!accessToken) return;
    setIsSubmitting(true);
    setError(null);
	try {
		if (readiness?.overall_ready === false) throw new Error("Master Data Customer belum siap untuk assignment.");
      if (!surveyorID) throw new Error("Surveyor GIFT wajib dipilih.");
      if (selectedContainers.length === 0) throw new Error("Pilih minimal satu peti kemas pada tab Peti Kemas.");
      if (assignmentStartDate && assignmentDueDate && assignmentDueDate < assignmentStartDate) throw new Error("Due Date tidak boleh lebih kecil dari Start Date.");
      await apiData(`/jobs/${jobID}/assign`, {
        method: "POST",
        accessToken,
        body: JSON.stringify({ surveyor_id: surveyorID, container_ids: selectedContainers, start_date: assignmentStartDate || undefined, due_date: assignmentDueDate || undefined, instruction: assignmentInstruction || undefined })
      });
      setAssignDialog(false);
      setSurveyorID("");
      setAssignmentStartDate("");
      setAssignmentDueDate("");
      setAssignmentInstruction("");
      setSelectedContainers([]);
      await loadJob();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal menugaskan Surveyor GIFT.");
    } finally {
      setIsSubmitting(false);
    }
  }

  async function reassignSurveyor() {
    if (!accessToken) return;
    setIsSubmitting(true);
    setError(null);
    try {
      if (selectedContainers.length === 0) throw new Error("Pilih minimal satu peti kemas pada tab Peti Kemas.");
      if (!reassignSurveyorID) throw new Error("Surveyor GIFT baru wajib dipilih.");
      if (!reassignReason.trim()) throw new Error("Alasan perubahan penugasan wajib diisi.");
      await Promise.all(selectedContainers.map((containerID) => apiData(`/job-containers/${containerID}/reassign`, {
        method: "POST",
        accessToken,
        body: JSON.stringify({ from_surveyor_id: job?.assignments?.[0]?.surveyor_id ?? "", to_surveyor_id: reassignSurveyorID, reason: reassignReason })
      })));
      setReassignDialog(false);
      setReassignSurveyorID("");
      setReassignReason("");
      setSelectedContainers([]);
      await loadJob();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengubah penugasan.");
    } finally {
      setIsSubmitting(false);
    }
  }

  function selectContainerType(value: string) {
    const selected = containerTypes.find((item) => item.id === value);
    setContainerForm((current) => ({ ...current, container_type_id: value, iso_type_code: selected?.isoCode ?? "" }));
  }

  if (isLoading && !job) return <div className="center-screen">Memuat detail pekerjaan...</div>;
  if (!job) return <div className="page-stack"><div className="alert alert-danger">{error ?? "Pekerjaan tidak ditemukan."}</div></div>;

  return (
    <div className="page-stack job-detail-workspace">
      <PageHeader title={job.job_order_no} description={`${job.customer?.customer_name ?? job.customer_name} — ${job.survey_type?.name ?? job.survey_type_name}`} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      {supportWarning ? <div className="alert alert-warning">{supportWarning}</div> : null}
	  {readiness?.overall_ready === false ? <div className="alert alert-danger"><div><strong>Assignment diblokir: Master Data Customer belum siap.</strong><p>{readiness.checks.filter((item) => !item.ready).map((item) => item.label).join(", ")}</p></div></div> : null}
      <div aria-label="Tab detail pekerjaan" className="tab-list" role="tablist">{tabs.map((tab) => <button aria-controls={`panel-${tab.id}`} aria-selected={activeTab === tab.id} className={activeTab === tab.id ? "tab-active" : ""} id={`tab-${tab.id}`} key={tab.id} onClick={() => setActiveTab(tab.id)} role="tab" type="button">{tab.label}</button>)}</div>

      <TabPanel active={activeTab === "ringkasan"} id="ringkasan"><JobSummaryTab job={job} support={support} /></TabPanel>
      <TabPanel active={activeTab === "peti-kemas"} id="peti-kemas"><JobContainersTab jobID={jobID} containers={job.containers ?? []} selected={selectedContainers} canAdd={canAddContainer} canImport={canImport} onSelected={setSelectedContainers} onAdd={() => setContainerDialog(true)} /></TabPanel>
      <TabPanel active={activeTab === "penugasan"} id="penugasan"><JobAssignmentTab assignments={job.assignments ?? []} selectedCount={selectedContainers.length} canAssign={canAssign} canReassign={canReassign} onAssign={() => setAssignDialog(true)} onReassign={() => setReassignDialog(true)} /></TabPanel>
      <TabPanel active={activeTab === "progress"} id="progress"><JobProgressTab containers={job.containers ?? []} support={support} /></TabPanel>
      <TabPanel active={activeTab === "hasil-survey"} id="hasil-survey"><JobSurveyResultsTab support={support} /></TabPanel>
      <TabPanel active={activeTab === "review"} id="review"><JobReviewTab support={support} /></TabPanel>
      <TabPanel active={activeTab === "dokumen"} id="dokumen"><JobDocumentsTab support={support} /></TabPanel>
      <TabPanel active={activeTab === "riwayat"} id="riwayat"><JobHistoryTab rows={job.timeline ?? []} /></TabPanel>

      <FormDialog title="Tambah Peti Kemas" open={containerDialog} onClose={() => setContainerDialog(false)} onSubmit={addContainer} isSubmitting={isSubmitting} submitLabel="Tambah">
        <div className="form-grid">
          <Field label="Nomor Peti Kemas"><input value={containerForm.container_no} onChange={(event) => updateContainer(setContainerForm, "container_no", event.target.value.toUpperCase())} /></Field>
          <Field label="Container Type"><select value={containerForm.container_type_id} onChange={(event) => selectContainerType(event.target.value)}><option value="">Pilih Container Type</option>{containerTypes.map((item) => <option key={item.id} value={item.id}>{item.code} - {item.label}</option>)}</select></Field>
          <Field label="ISO Type"><input readOnly value={containerForm.iso_type_code} placeholder="Otomatis dari Container Type" /></Field>
          <Field label="Seal Number"><input value={containerForm.seal_no} onChange={(event) => updateContainer(setContainerForm, "seal_no", event.target.value)} /></Field>
          <Field label="Cargo Status"><select value={containerForm.cargo_status} onChange={(event) => updateContainer(setContainerForm, "cargo_status", event.target.value)}><option value="unknown">Unknown</option><option value="empty">Empty</option><option value="laden">Laden</option></select></Field>
          <Field label="Gross Weight"><input min="0" step="0.01" type="number" value={containerForm.gross_weight} onChange={(event) => updateContainer(setContainerForm, "gross_weight", event.target.value)} /></Field>
          <Field label="Tare Weight"><input min="0" step="0.01" type="number" value={containerForm.tare_weight} onChange={(event) => updateContainer(setContainerForm, "tare_weight", event.target.value)} /></Field>
          <Field label="Payload"><input min="0" step="0.01" type="number" value={containerForm.payload} onChange={(event) => updateContainer(setContainerForm, "payload", event.target.value)} /></Field>
          <Field label="Tanggal Pembuatan"><input type="date" value={containerForm.manufacture_date} onChange={(event) => updateContainer(setContainerForm, "manufacture_date", event.target.value)} /></Field>
          <Field label="CSC Plate Status"><select value={containerForm.csc_plate_status} onChange={(event) => updateContainer(setContainerForm, "csc_plate_status", event.target.value)}><option value="not_checked">Not Checked</option><option value="available">Available</option><option value="missing">Missing</option><option value="damaged">Damaged</option></select></Field>
		  <Field label="CSC Plate Number"><input value={containerForm.csc_plate_number} onChange={(event) => updateContainer(setContainerForm, "csc_plate_number", event.target.value)} /></Field>
		  <Field label="CSC Approval Reference"><input value={containerForm.csc_approval_reference} onChange={(event) => updateContainer(setContainerForm, "csc_approval_reference", event.target.value)} /></Field>
		  <Field label="CSC Manufacture Date"><input type="date" value={containerForm.csc_manufacture_date} onChange={(event) => updateContainer(setContainerForm, "csc_manufacture_date", event.target.value)} /></Field>
		  <Field label="CSC Next Examination"><input min={containerForm.csc_manufacture_date || undefined} type="date" value={containerForm.csc_next_examination_date} onChange={(event) => updateContainer(setContainerForm, "csc_next_examination_date", event.target.value)} /></Field>
		  <Field label="CSC Program Type"><input value={containerForm.csc_program_type} onChange={(event) => updateContainer(setContainerForm, "csc_program_type", event.target.value)} placeholder="ACEP / PES / lainnya" /></Field>
          <Field label="Truck Number"><input value={containerForm.truck_no} onChange={(event) => updateContainer(setContainerForm, "truck_no", event.target.value)} /></Field>
          <Field label="Driver"><input value={containerForm.driver_name} onChange={(event) => updateContainer(setContainerForm, "driver_name", event.target.value)} /></Field>
          <label className="field form-span-2"><span>Alasan Override Check Digit</span><textarea rows={2} value={containerForm.check_digit_override_reason} onChange={(event) => updateContainer(setContainerForm, "check_digit_override_reason", event.target.value)} /></label>
          <label className="field form-span-2"><span>Remark</span><textarea rows={3} value={containerForm.remark} onChange={(event) => updateContainer(setContainerForm, "remark", event.target.value)} /></label>
        </div>
      </FormDialog>

      <FormDialog title="Tugaskan Surveyor GIFT" open={assignDialog} onClose={() => setAssignDialog(false)} onSubmit={assignSurveyor} isSubmitting={isSubmitting} submitLabel="Tugaskan">
        <div className="form-grid">
          <Field label="Surveyor GIFT"><OptionSelect value={surveyorID} options={surveyors} onChange={setSurveyorID} /></Field>
          <Field label="Start Date"><input type="date" value={assignmentStartDate} onChange={(event) => setAssignmentStartDate(event.target.value)} /></Field>
          <Field label="Due Date"><input min={assignmentStartDate || undefined} type="date" value={assignmentDueDate} onChange={(event) => setAssignmentDueDate(event.target.value)} /></Field>
          <div className="field form-span-2"><span>Peti Kemas Dipilih</span><p className="muted-text">{selectedContainers.length} peti kemas dipilih dari tab Peti Kemas.</p></div>
          <label className="field form-span-2"><span>Instruksi Penugasan</span><textarea rows={3} value={assignmentInstruction} onChange={(event) => setAssignmentInstruction(event.target.value)} /></label>
        </div>
      </FormDialog>

      <FormDialog title="Ubah Penugasan" description="Reassign hanya tersedia untuk peti kemas yang belum approved/reported." open={reassignDialog} onClose={() => setReassignDialog(false)} onSubmit={reassignSurveyor} isSubmitting={isSubmitting} submitLabel="Ubah Penugasan">
        <div className="form-grid">
          <div className="field"><span>Peti Kemas Dipilih</span><strong>{selectedContainers.length}</strong></div>
          <Field label="Surveyor GIFT Baru"><OptionSelect value={reassignSurveyorID} options={surveyors} onChange={setReassignSurveyorID} /></Field>
          <label className="field form-span-2"><span>Alasan Perubahan</span><textarea rows={3} value={reassignReason} onChange={(event) => setReassignReason(event.target.value)} /></label>
        </div>
      </FormDialog>
    </div>
  );
}

function TabPanel({ id, active, children }: { id: TabID; active: boolean; children: React.ReactNode }) {
  if (!active) return null;
  return <div aria-labelledby={`tab-${id}`} id={`panel-${id}`} role="tabpanel" tabIndex={0}>{children}</div>;
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return <label className="field"><span>{label}</span>{children}</label>;
}

function OptionSelect({ value, options, onChange }: { value: string; options: OptionItem[]; onChange: (value: string) => void }) {
  return <select value={value} onChange={(event) => onChange(event.target.value)}><option value="">Pilih</option>{options.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select>;
}

function updateContainer(setter: React.Dispatch<React.SetStateAction<ContainerForm>>, key: keyof ContainerForm, value: string) {
  setter((current) => ({ ...current, [key]: value }));
}

function containerPayload(values: ContainerForm) {
  const payload: Record<string, string | number> = { ...values };
  for (const key of ["gross_weight", "tare_weight", "payload"] as const) {
    if (values[key] === "") delete payload[key];
    else payload[key] = Number(values[key]);
  }
  return Object.fromEntries(Object.entries(payload).filter(([, value]) => value !== ""));
}
