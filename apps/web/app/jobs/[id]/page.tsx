"use client";

import { PackagePlus, Send, Upload } from "lucide-react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { loadOptions } from "@/lib/options";
import { can } from "@/lib/permissions";
import type { AssignmentSummary, JobContainer, JobDetail, JobEvent, OptionItem } from "@/types/jobs";

const tabs = ["Overview", "Containers", "Assignment", "Survey Progress", "Reports", "Timeline"] as const;
type Tab = (typeof tabs)[number];

type ContainerForm = { container_no: string; container_type_id: string; iso_type_code: string; seal_no: string; cargo_status: string; truck_no: string; driver_name: string; csc_plate_status: string; remark: string };
const emptyContainer: ContainerForm = { container_no: "", container_type_id: "", iso_type_code: "", seal_no: "", cargo_status: "unknown", truck_no: "", driver_name: "", csc_plate_status: "not_checked", remark: "" };

export default function JobDetailPage() {
  return <ProtectedRoute><AppShell title="Job Detail"><JobDetailContent /></AppShell></ProtectedRoute>;
}

function JobDetailContent() {
  const params = useParams<{ id: string }>();
  const jobID = params.id;
  const { accessToken, user } = useAuth();
  const [job, setJob] = useState<JobDetail | null>(null);
  const [activeTab, setActiveTab] = useState<Tab>("Overview");
  const [error, setError] = useState<string | null>(null);
  const [containerDialog, setContainerDialog] = useState(false);
  const [assignDialog, setAssignDialog] = useState(false);
  const [containerForm, setContainerForm] = useState<ContainerForm>(emptyContainer);
  const [selectedContainers, setSelectedContainers] = useState<string[]>([]);
  const [surveyorID, setSurveyorID] = useState("");
  const [containerTypes, setContainerTypes] = useState<OptionItem[]>([]);
  const [surveyors, setSurveyors] = useState<OptionItem[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const canAddContainer = can(user, "job_containers.create.all");
  const canImport = can(user, "job_containers.import.all");
  const canAssign = can(user, "assignments.assign.all");

  const loadJob = useCallback(async () => {
    if (!accessToken || !jobID) return;
    setError(null);
    try {
      const item = await apiData<JobDetail>(`/jobs/${jobID}`, { accessToken });
      setJob(item);
    } catch (err) { setError(err instanceof Error ? err.message : "Gagal mengambil job."); }
  }, [accessToken, jobID]);

  useEffect(() => { const timer = window.setTimeout(() => void loadJob(), 0); return () => window.clearTimeout(timer); }, [loadJob]);
  useEffect(() => {
    if (!accessToken) return;
    void Promise.all([
      loadOptions(accessToken, "/master/container-types", "type", "code"),
      loadOptions(accessToken, "/master/surveyors", "name", "surveyor_code")
    ]).then(([types, people]) => { setContainerTypes(types); setSurveyors(people); }).catch(() => undefined);
  }, [accessToken]);

  async function addContainer() {
    if (!accessToken) return;
    setIsSubmitting(true); setError(null);
    try {
      await apiData(`/jobs/${jobID}/containers`, { method: "POST", accessToken, body: JSON.stringify(clean(containerForm)) });
      setContainerDialog(false); setContainerForm(emptyContainer); await loadJob();
    } catch (err) { setError(err instanceof Error ? err.message : "Gagal menambah container."); }
    finally { setIsSubmitting(false); }
  }

  async function assignSurveyor() {
    if (!accessToken) return;
    setIsSubmitting(true); setError(null);
    try {
      await apiData(`/jobs/${jobID}/assign`, { method: "POST", accessToken, body: JSON.stringify({ surveyor_id: surveyorID, container_ids: selectedContainers }) });
      setAssignDialog(false); setSurveyorID(""); setSelectedContainers([]); await loadJob();
    } catch (err) { setError(err instanceof Error ? err.message : "Gagal assign surveyor."); }
    finally { setIsSubmitting(false); }
  }

  if (!job) {
    return <div className="center-screen">Memuat job...</div>;
  }

  return (
    <div className="page-stack">
      <PageHeader title={job.job_order_no} description={`${job.customer?.customer_name ?? job.customer_name ?? "-"} - ${job.survey_type?.name ?? job.survey_type_name ?? "-"}`} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <div className="job-actions">
        {canAddContainer ? <button className="secondary-button" onClick={() => setContainerDialog(true)}><PackagePlus size={18} /><span>Add Container</span></button> : null}
        {canImport ? <Link className="secondary-button" href={`/jobs/${jobID}/containers/import`}><Upload size={18} /><span>Import Container</span></Link> : null}
        {canAssign ? <button className="primary-button" onClick={() => setAssignDialog(true)}><Send size={18} /><span>Assign Surveyor</span></button> : null}
      </div>
      <div className="tab-list">{tabs.map((tab) => <button className={activeTab === tab ? "tab-active" : ""} key={tab} onClick={() => setActiveTab(tab)}>{tab}</button>)}</div>
      {activeTab === "Overview" ? <Overview job={job} /> : null}
      {activeTab === "Containers" ? <Containers containers={job.containers ?? []} selected={selectedContainers} onSelected={setSelectedContainers} /> : null}
      {activeTab === "Assignment" ? <Assignments rows={job.assignments ?? []} /> : null}
      {activeTab === "Survey Progress" ? <Progress containers={job.containers ?? []} /> : null}
      {activeTab === "Reports" ? <section className="workspace-panel"><h2>Reports</h2><p className="muted-text">Report records will appear after supervisor approval in Prompt 9.</p></section> : null}
      {activeTab === "Timeline" ? <Timeline rows={job.timeline ?? []} /> : null}

      <FormDialog title="Add Container" open={containerDialog} onClose={() => setContainerDialog(false)} onSubmit={addContainer} isSubmitting={isSubmitting} submitLabel="Add">
        <div className="form-grid">
          <Field label="Container No"><input value={containerForm.container_no} onChange={(e) => setContainerFormValue(setContainerForm, "container_no", e.target.value.toUpperCase())} /></Field>
          <Field label="Container Type"><Select value={containerForm.container_type_id} options={containerTypes} onChange={(value) => setContainerFormValue(setContainerForm, "container_type_id", value)} /></Field>
          <Field label="ISO Type"><input value={containerForm.iso_type_code} onChange={(e) => setContainerFormValue(setContainerForm, "iso_type_code", e.target.value)} /></Field>
          <Field label="Seal No"><input value={containerForm.seal_no} onChange={(e) => setContainerFormValue(setContainerForm, "seal_no", e.target.value)} /></Field>
          <Field label="Cargo Status"><select value={containerForm.cargo_status} onChange={(e) => setContainerFormValue(setContainerForm, "cargo_status", e.target.value)}><option value="unknown">unknown</option><option value="empty">empty</option><option value="laden">laden</option></select></Field>
          <Field label="CSC Plate"><input value={containerForm.csc_plate_status} onChange={(e) => setContainerFormValue(setContainerForm, "csc_plate_status", e.target.value)} /></Field>
          <Field label="Truck No"><input value={containerForm.truck_no} onChange={(e) => setContainerFormValue(setContainerForm, "truck_no", e.target.value)} /></Field>
          <Field label="Driver"><input value={containerForm.driver_name} onChange={(e) => setContainerFormValue(setContainerForm, "driver_name", e.target.value)} /></Field>
          <label className="field form-span-2"><span>Remark</span><textarea rows={3} value={containerForm.remark} onChange={(e) => setContainerFormValue(setContainerForm, "remark", e.target.value)} /></label>
        </div>
      </FormDialog>

      <FormDialog title="Assign Surveyor" open={assignDialog} onClose={() => setAssignDialog(false)} onSubmit={assignSurveyor} isSubmitting={isSubmitting} submitLabel="Assign">
        <div className="form-grid">
          <Field label="Surveyor"><Select value={surveyorID} options={surveyors} onChange={setSurveyorID} /></Field>
          <div className="field form-span-2"><span>Selected Containers</span><p className="muted-text">{selectedContainers.length} container selected from Containers tab.</p></div>
        </div>
      </FormDialog>
    </div>
  );
}

function Overview({ job }: { job: JobDetail }) {
  const rows: Array<[string, React.ReactNode]> = [
    ["Status", <StatusBadge key="status" tone={job.status === "cancelled" ? "danger" : "success"}>{job.status.toUpperCase()}</StatusBadge>],
    ["Job Date", job.job_date], ["Priority", job.priority], ["Location", job.location?.location_name ?? job.location_name],
    ["Reference", job.reference_no ?? "-"], ["Booking", job.booking_no ?? "-"], ["Vessel", job.vessel ?? "-"], ["Instruction", job.instruction ?? "-"]
  ];
  return <section className="workspace-panel detail-grid">{rows.map(([label, value]) => <div key={String(label)}><span>{label}</span><strong>{value}</strong></div>)}</section>;
}

function Containers({ containers, selected, onSelected }: { containers: JobContainer[]; selected: string[]; onSelected: (ids: string[]) => void }) {
  return <DataTable rows={containers} columns={[
    { key: "select", header: "Select", render: (row) => <input type="checkbox" checked={selected.includes(row.id)} onChange={(e) => onSelected(e.target.checked ? [...selected, row.id] : selected.filter((id) => id !== row.id))} /> },
    { key: "container_no", header: "Container No", render: (row) => row.container_no },
    { key: "check", header: "Check Digit", render: (row) => <StatusBadge tone={row.check_digit_status === "valid" ? "success" : "warning"}>{row.check_digit_status.toUpperCase()}</StatusBadge> },
    { key: "type", header: "Type", render: (row) => row.container_type_code ?? "-" },
    { key: "seal", header: "Seal", render: (row) => row.seal_no ?? "-" },
    { key: "cargo", header: "Cargo", render: (row) => row.cargo_status },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "not_started" ? "warning" : "success"}>{row.status.toUpperCase()}</StatusBadge> }
  ]} />;
}

function Assignments({ rows }: { rows: AssignmentSummary[] }) { return <DataTable rows={rows} columns={[{ key: "assignment_no", header: "Assignment No", render: (r) => r.assignment_no }, { key: "surveyor", header: "Surveyor", render: (r) => r.surveyor_name }, { key: "containers", header: "Containers", render: (r) => r.total_containers }, { key: "status", header: "Status", render: (r) => <StatusBadge tone="success">{r.status.toUpperCase()}</StatusBadge> }]} />; }
function Progress({ containers }: { containers: JobContainer[] }) { return <section className="metric-grid">{["not_started","assigned","in_progress","submitted","approved"].map((status) => <div className="metric-tile" key={status}><p>{status}</p><strong>{containers.filter((c) => c.status === status).length}</strong></div>)}</section>; }
function Timeline({ rows }: { rows: JobEvent[] }) { return <section className="workspace-panel timeline-list">{rows.length === 0 ? <p className="muted-text">Timeline kosong.</p> : rows.map((row) => <div key={row.id}><strong>{row.event_title}</strong><p>{row.description}</p><span>{row.actor ?? "System"} - {row.created_at}</span></div>)}</section>; }
function Field({ label, children }: { label: string; children: React.ReactNode }) { return <label className="field"><span>{label}</span>{children}</label>; }
function Select({ value, options, onChange }: { value: string; options: OptionItem[]; onChange: (value: string) => void }) { return <select value={value} onChange={(e) => onChange(e.target.value)}><option value="">Select</option>{options.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select>; }
function setContainerFormValue(setter: React.Dispatch<React.SetStateAction<ContainerForm>>, key: keyof ContainerForm, value: string) { setter((current) => ({ ...current, [key]: value })); }
function clean(values: ContainerForm) { return Object.fromEntries(Object.entries(values).filter(([, value]) => value !== "")); }
