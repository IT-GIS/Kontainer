"use client";

import { useRef, useState } from "react";
import { CheckCircle2, ChevronLeft, ChevronRight, Plus, Save, Send, Trash2 } from "lucide-react";
import { AttachmentPreview } from "@/components/ui/attachment-preview";
import { AttachmentUploaderPlaceholder } from "@/components/ui/attachment-uploader-placeholder";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";
import { FormField } from "@/components/ui/form-field";
import { FormSection } from "@/components/ui/form-section";
import { PageHeader } from "@/components/ui/page-header";
import { SearchableSelect } from "@/components/ui/searchable-select";
import { Stepper } from "@/components/ui/stepper";
import { StickyActionBar } from "@/components/ui/sticky-action-bar";
import { ToastFeedback } from "@/components/ui/toast-feedback";
import { UnsavedChangesGuard } from "@/components/ui/unsaved-changes-guard";
import {
  getFitnessClientById, getFitnessClientContainerTypes, getFitnessClientInspectionReferences,
  getFitnessClientLocations, getFitnessClientPersonnel
} from "@/lib/fitness-client-master-data-mock-service";
import {
  fitnessApplicationAttachmentCategories, fitnessApplicationServiceCategories, fitnessApplicationSteps
} from "@/mocks/fitness-dashboard-applications";
import type {
  FitnessApplicationAttachment, FitnessApplicationDraft, FitnessClientContainerType,
  FitnessClientDetail, FitnessClientInspectionReference, FitnessClientLocation,
  FitnessClientPersonnel, FitnessClientSummary, FitnessInspectionReferenceSection
} from "@/types/fitness-admin";

type ClientOptions = {
  client: FitnessClientDetail | null;
  locations: FitnessClientLocation[];
  personnel: FitnessClientPersonnel[];
  containerTypes: FitnessClientContainerType[];
  references: FitnessClientInspectionReference[];
};

const emptyOptions: ClientOptions = { client: null, locations: [], personnel: [], containerTypes: [], references: [] };
const referenceSections: FitnessInspectionReferenceSection[] = [
  "inspection-areas", "structural-components", "damage-criteria", "finding-severities",
  "test-parameters", "photo-categories", "inspection-recommendations"
];

export function FitnessApplicationCreateWorkspace({ clients, initialDraft }: { clients: FitnessClientSummary[]; initialDraft: FitnessApplicationDraft }) {
  const loadSequence = useRef(0);
  const [draft, setDraft] = useState(initialDraft);
  const [options, setOptions] = useState<ClientOptions>(emptyOptions);
  const [currentStep, setCurrentStep] = useState(0);
  const [dirty, setDirty] = useState(false);
  const [loadingOptions, setLoadingOptions] = useState(false);
  const [optionError, setOptionError] = useState<string | null>(null);
  const [pendingAction, setPendingAction] = useState<"draft" | "submit" | null>(null);
  const [toast, setToast] = useState<{ title: string; description: string } | null>(null);

  const steps = fitnessApplicationSteps.map((step, index) => ({
    ...step,
    status: (index < currentStep ? "complete" : index === currentStep ? "current" : "upcoming") as "complete" | "current" | "upcoming",
    clickable: index <= currentStep
  }));
  const currentValid = validateStep(currentStep, draft);
  const allValid = fitnessApplicationSteps.every((_, index) => validateStep(index, draft));
  const selectedLocation = options.locations.find((item) => item.id === draft.locationId);
  const selectedPic = options.personnel.find((item) => item.id === draft.picPersonnelId);

  function update<K extends keyof FitnessApplicationDraft>(field: K, value: FitnessApplicationDraft[K]) {
    setDraft((current) => ({ ...current, [field]: value }));
    setDirty(true);
  }

  async function selectClient(clientId: string) {
    const sequence = ++loadSequence.current;
    setOptions(emptyOptions);
    setOptionError(null);
    setLoadingOptions(Boolean(clientId));
    setDraft((current) => ({
      ...current,
      clientId,
      applicantName: "",
      ownerUserName: "",
      ownerUserAddress: "",
      ownerUserPic: "",
      ownerUserPhone: "",
      ownerUserEmail: "",
      locationId: "",
      picPersonnelId: "",
      containers: [],
      referenceIds: []
    }));
    setDirty(true);
    if (!clientId) return;

    const [clientState, locationState, personnelState, typeState, ...referenceStates] = await Promise.all([
      getFitnessClientById(clientId),
      getFitnessClientLocations(clientId),
      getFitnessClientPersonnel(clientId),
      getFitnessClientContainerTypes(clientId),
      ...referenceSections.map((section) => getFitnessClientInspectionReferences(clientId, section))
    ]);
    if (sequence !== loadSequence.current) return;
    const ready = clientState.status === "success" && locationState.status === "success"
      && personnelState.status === "success" && typeState.status === "success"
      && referenceStates.every((state) => state.status === "success");
    if (!ready) {
      setOptionError("Master Data Klien belum dapat dimuat.");
      setLoadingOptions(false);
      return;
    }
    const client = clientState.data;
    const personnel = personnelState.data.filter((item) => item.status === "Aktif");
    setOptions({
      client,
      locations: locationState.data.filter((item) => item.status === "Aktif"),
      personnel,
      containerTypes: typeState.data.filter((item) => item.status === "Aktif"),
      references: referenceStates.flatMap((state) => state.status === "success" ? state.data.filter((item) => item.status === "Aktif") : [])
    });
    setDraft((current) => ({
      ...current,
      applicantName: client?.primaryContactName ?? "",
      ownerUserName: client?.name ?? "",
      ownerUserAddress: client?.address ?? "",
      ownerUserPic: client?.primaryContactName ?? "",
      ownerUserPhone: client?.phone ?? "",
      ownerUserEmail: client?.email ?? ""
    }));
    setLoadingOptions(false);
  }

  function nextStep() {
    if (!currentValid) return;
    setCurrentStep((current) => Math.min(current + 1, fitnessApplicationSteps.length - 1));
  }

  function previousStep() {
    setCurrentStep((current) => Math.max(current - 1, 0));
  }

  function addContainer() {
    update("containers", [...draft.containers, {
      id: "local-container-" + Date.now(),
      containerNumber: "",
      containerTypeId: "",
      numberValid: false,
      technicalComplete: false
    }]);
  }

  function updateContainer(id: string, field: "containerNumber" | "containerTypeId", value: string) {
    update("containers", draft.containers.map((container) => {
      if (container.id !== id) return container;
      if (field === "containerNumber") return { ...container, containerNumber: value.toUpperCase(), numberValid: /^[A-Z]{4}[0-9]{7}$/.test(value.toUpperCase()) };
      const type = options.containerTypes.find((item) => item.id === value);
      return { ...container, containerTypeId: value, containerTypeName: type?.name, technicalComplete: Boolean(value) };
    }));
  }

  function addAttachment(category: FitnessApplicationAttachment["category"]) {
    if (draft.attachments.some((item) => item.category === category)) return;
    update("attachments", [...draft.attachments, {
      id: "local-attachment-" + Date.now(),
      category,
      name: category.replace("/", "-") + "-contoh.pdf",
      sizeLabel: "State lokal"
    }]);
  }

  function confirmAction() {
    if (!pendingAction) return;
    const submitted = pendingAction === "submit";
    setPendingAction(null);
    setDirty(false);
    setToast({
      title: submitted ? "Permohonan diajukan secara lokal" : "Draf tersimpan secara lokal",
      description: "Tidak ada API mutation atau perubahan database. Data kembali ke mock awal setelah reload."
    });
  }

  return (
    <div className="page-stack application-create-page">
      <PageHeader
        eyebrow="Permohonan"
        title="Buat Permohonan"
        description="Klien dipilih terlebih dahulu agar seluruh pilihan turunan tetap terisolasi."
        meta={<span>Nomor: {draft.applicationNumber}</span>}
      />
      <Stepper steps={steps} onStepClick={(_, index) => setCurrentStep(index)} />
      <div className="application-step-panel">
        <div className="application-step-heading">
          <span>Langkah {currentStep + 1} dari {fitnessApplicationSteps.length}</span>
          <h2>{fitnessApplicationSteps[currentStep].label}</h2>
          <p>{fitnessApplicationSteps[currentStep].description}</p>
        </div>
        {optionError ? <div className="alert alert-danger" role="alert">{optionError}</div> : null}
        {renderStep(currentStep, {
          draft, options, clients, loadingOptions, selectedLocation, selectedPic,
          update, selectClient, addContainer, updateContainer,
          removeContainer: (id) => update("containers", draft.containers.filter((item) => item.id !== id)),
          toggleReference: (id) => update("referenceIds", draft.referenceIds.includes(id) ? draft.referenceIds.filter((item) => item !== id) : [...draft.referenceIds, id]),
          addAttachment,
          removeAttachment: (id) => update("attachments", draft.attachments.filter((item) => item.id !== id))
        })}
      </div>
      {!currentValid ? <div className="alert alert-warning" role="alert">{validationMessage(currentStep)}</div> : null}
      <div className="application-step-navigation">
        <button className="secondary-button" disabled={currentStep === 0} onClick={previousStep} type="button"><ChevronLeft size={16} />Kembali</button>
        <button className="primary-button" disabled={!currentValid || currentStep === fitnessApplicationSteps.length - 1} onClick={nextStep} type="button">Selanjutnya<ChevronRight size={16} /></button>
      </div>
      <UnsavedChangesGuard active={dirty} message="Perubahan Permohonan belum disimpan." />
      <ConfirmationDialog
        open={Boolean(pendingAction)}
        title={pendingAction === "submit" ? "Ajukan Permohonan?" : "Simpan draf lokal?"}
        description="Tindakan ini hanya mengubah state frontend UI-C dan tidak memanggil backend."
        confirmLabel={pendingAction === "submit" ? "Ajukan" : "Simpan Draf"}
        onClose={() => setPendingAction(null)}
        onConfirm={confirmAction}
      />
      {toast ? <ToastFeedback title={toast.title} description={toast.description} tone="success" onDismiss={() => setToast(null)} /> : null}
      <StickyActionBar
        summary={<span>{options.client ? "Klien aktif: " + options.client.name : "Pilih Klien terlebih dahulu"}</span>}
        tertiary={{ label: "Batalkan", href: "/fitness/applications" }}
        secondary={{ label: "Simpan Draf", icon: Save, disabled: !dirty, onClick: () => setPendingAction("draft") }}
        primary={{ label: "Ajukan", icon: Send, disabled: currentStep !== fitnessApplicationSteps.length - 1 || !allValid || !dirty, onClick: () => setPendingAction("submit") }}
      />
    </div>
  );
}

type RenderContext = {
  draft: FitnessApplicationDraft;
  options: ClientOptions;
  clients: FitnessClientSummary[];
  loadingOptions: boolean;
  selectedLocation?: FitnessClientLocation;
  selectedPic?: FitnessClientPersonnel;
  update: <K extends keyof FitnessApplicationDraft>(field: K, value: FitnessApplicationDraft[K]) => void;
  selectClient: (clientId: string) => void;
  addContainer: () => void;
  updateContainer: (id: string, field: "containerNumber" | "containerTypeId", value: string) => void;
  removeContainer: (id: string) => void;
  toggleReference: (id: string) => void;
  addAttachment: (category: FitnessApplicationAttachment["category"]) => void;
  removeAttachment: (id: string) => void;
};

function renderStep(step: number, context: RenderContext) {
  const { draft, options, clients, loadingOptions, selectedLocation, selectedPic, update } = context;

  if (step === 0) {
    return <>
      <FormSection title="Klien" description="Pilihan pertama menentukan seluruh Master Data turunan.">
        <FormField id="application-client" label="Klien" required helpText="Mengganti Klien akan mengosongkan lokasi, PIC, peti kemas, dan referensi sebelumnya.">
          <SearchableSelect id="application-client" label="Klien" showLabel={false} required loading={loadingOptions}
            value={draft.clientId} onChange={(value) => context.selectClient(value ?? "")}
            options={clients.map((client) => ({ value: client.id, label: client.name, description: client.code + " · " + client.city }))} />
        </FormField>
        <TextField id="application-applicant" label="Pemohon" value={draft.applicantName} onChange={(value) => update("applicantName", value)} required />
      </FormSection>
      <FormSection title="Pemilik/Pengguna Peti Kemas" description="Konsep ini tetap terpisah dari Klien dan Pemohon.">
        <TextField id="owner-name" label="Pemilik/Pengguna Peti Kemas" value={draft.ownerUserName} onChange={(value) => update("ownerUserName", value)} required />
        <TextArea id="owner-address" label="Alamat" value={draft.ownerUserAddress} onChange={(value) => update("ownerUserAddress", value)} />
        <TextField id="owner-pic" label="PIC" value={draft.ownerUserPic} onChange={(value) => update("ownerUserPic", value)} />
        <TextField id="owner-phone" label="Telepon" value={draft.ownerUserPhone} onChange={(value) => update("ownerUserPhone", value)} />
        <TextField id="owner-email" label="Email" type="email" value={draft.ownerUserEmail} onChange={(value) => update("ownerUserEmail", value)} />
      </FormSection>
      {options.client ? <ClientContext client={options.client} /> : null}
    </>;
  }

  if (step === 1) {
    return <FormSection title="Informasi Permohonan" description="Status workflow ditentukan sistem dan tidak tersedia sebagai dropdown bebas.">
      <TextField id="application-number" label="Nomor Permohonan" value={draft.applicationNumber} readOnly />
      <TextField id="application-date" label="Tanggal Permohonan" type="date" value={draft.applicationDate} onChange={(value) => update("applicationDate", value)} required />
      <FormField id="service-category" label="Kategori Layanan/Persetujuan" required>
        <select id="service-category" value={draft.serviceCategory} onChange={(event) => update("serviceCategory", event.target.value)} required>
          <option value="">Pilih kategori layanan</option>
          {fitnessApplicationServiceCategories.map((item) => <option key={item} value={item}>{item}</option>)}
        </select>
      </FormField>
      <TextField id="letter-number" label="Nomor Surat Permohonan" value={draft.letterNumber} onChange={(value) => update("letterNumber", value)} />
      <TextField id="letter-date" label="Tanggal Surat" type="date" value={draft.letterDate} onChange={(value) => update("letterDate", value)} />
      <AttachmentUploaderPlaceholder title="Lampiran Surat" description="Lampiran aktual ditambahkan pada langkah Lampiran." />
    </FormSection>;
  }

  if (step === 2) {
    return <>
      <FormSection title="Lokasi Pemeriksaan" description="Hanya lokasi aktif milik clientId terpilih.">
        <FormField id="application-location" label="Lokasi Pemeriksaan" required>
          <SearchableSelect id="application-location" label="Lokasi Pemeriksaan" showLabel={false} required disabled={!draft.clientId}
            value={draft.locationId} onChange={(value) => { update("locationId", value ?? ""); update("picPersonnelId", ""); }}
            options={options.locations.map((item) => ({ value: item.id, label: item.name, description: item.code + " · " + item.city }))} />
        </FormField>
        <TextArea id="location-address" label="Alamat Lokasi" value={selectedLocation?.address ?? ""} readOnly />
        <TextField id="location-city" label="Kota/Kabupaten" value={selectedLocation?.city ?? ""} readOnly />
        <TextArea id="location-access" label="Catatan Akses" value={selectedLocation?.accessNotes ?? ""} readOnly />
      </FormSection>
      <FormSection title="PIC dan Rencana">
        <FormField id="application-pic" label="PIC Lokasi" required>
          <SearchableSelect id="application-pic" label="PIC Lokasi" showLabel={false} required disabled={!draft.locationId}
            value={draft.picPersonnelId} onChange={(value) => update("picPersonnelId", value ?? "")}
            options={options.personnel.filter((item) => item.locationIds.length === 0 || item.locationIds.includes(draft.locationId)).map((item) => ({ value: item.id, label: item.name, description: item.title + " · " + item.type }))} />
        </FormField>
        <TextField id="pic-phone" label="Telepon PIC" value={selectedPic?.phone ?? ""} readOnly />
        <TextField id="inspection-plan" label="Rencana Tanggal Pemeriksaan" type="date" value={draft.plannedInspectionDate} onChange={(value) => update("plannedInspectionDate", value)} required />
      </FormSection>
    </>;
  }

  if (step === 3) {
    return <section className="application-container-step">
      <div className="fitness-section-header"><div><h3>Peti Kemas</h3><p>Data identitas awal saja. Form teknis lengkap tetap menjadi scope UI-D.</p></div><button className="secondary-button" onClick={context.addContainer} type="button"><Plus size={16} />Tambah Peti Kemas</button></div>
      {draft.containers.length === 0 ? <div className="application-empty-inline">Belum ada peti kemas. Tambahkan minimal satu data.</div> : null}
      {draft.containers.map((container, index) => <div className="application-container-row" key={container.id}>
        <TextField id={"container-number-" + index} label="Nomor Peti Kemas" value={container.containerNumber} onChange={(value) => context.updateContainer(container.id, "containerNumber", value)} required />
        <FormField id={"container-type-" + index} label="Jenis Peti Kemas" required>
          <SearchableSelect id={"container-type-" + index} label="Jenis Peti Kemas" showLabel={false} required
            value={container.containerTypeId} onChange={(value) => context.updateContainer(container.id, "containerTypeId", value ?? "")}
            options={options.containerTypes.map((item) => ({ value: item.id, label: item.name, description: item.code + " · " + item.size }))} />
        </FormField>
        <span className={container.numberValid ? "application-valid" : "application-invalid"}>{container.numberValid ? "Nomor valid" : "Gunakan 4 huruf + 7 angka"}</span>
        <button className="icon-button" aria-label={"Hapus peti kemas " + (index + 1)} onClick={() => context.removeContainer(container.id)} type="button"><Trash2 size={16} /></button>
      </div>)}
    </section>;
  }

  if (step === 4) {
    return <>
      <FormSection title="Instruksi Pemeriksaan">
        <TextArea id="special-instructions" label="Instruksi Khusus" value={draft.specialInstructions} onChange={(value) => update("specialInstructions", value)} />
        <TextArea id="admin-notes" label="Catatan Admin" value={draft.adminNotes} onChange={(value) => update("adminNotes", value)} />
        <AttachmentUploaderPlaceholder title="Lampiran Tambahan" description="Disimpan sebagai placeholder state lokal pada UI-C." />
      </FormSection>
      <fieldset className="application-reference-fieldset">
        <legend>Referensi Pemeriksaan yang Berlaku</legend>
        <p>Seluruh pilihan berasal dari referensi aktif clientId {draft.clientId || "yang belum dipilih"}.</p>
        <div className="application-reference-grid">
          {options.references.map((reference) => <label key={reference.id}>
            <input type="checkbox" checked={draft.referenceIds.includes(reference.id)} onChange={() => context.toggleReference(reference.id)} />
            <span><strong>{reference.name}</strong><small>{reference.code} · {reference.section}</small></span>
          </label>)}
        </div>
      </fieldset>
    </>;
  }

  if (step === 5) {
    return <section className="application-attachments-step">
      <div className="fitness-section-header"><div><h3>Lampiran</h3><p>File contoh hanya disimpan pada state lokal frontend.</p></div></div>
      <div className="application-upload-grid">
        {fitnessApplicationAttachmentCategories.map((category) => <div key={category}>
          <AttachmentUploaderPlaceholder title={category} description="Tambahkan placeholder lampiran lokal." />
          <button className="secondary-button" disabled={draft.attachments.some((item) => item.category === category)} onClick={() => context.addAttachment(category)} type="button">Tambahkan contoh</button>
        </div>)}
      </div>
      <div className="application-attachment-list">
        {draft.attachments.map((attachment) => <div key={attachment.id}><AttachmentPreview name={attachment.name} sizeLabel={attachment.sizeLabel} /><button className="icon-button" aria-label={"Hapus " + attachment.name} onClick={() => context.removeAttachment(attachment.id)} type="button"><Trash2 size={16} /></button></div>)}
      </div>
    </section>;
  }

  return <section className="application-summary-review">
    <div className="application-summary-banner"><CheckCircle2 size={22} /><div><strong>Ringkasan Permohonan</strong><span>Periksa konsep Klien, Pemohon, Pemilik/Pengguna, dan seluruh data client-scoped.</span></div></div>
    <SummaryGroup title="Identitas" items={[
      ["Klien", options.client?.name ?? "-"], ["Pemohon", draft.applicantName || "-"],
      ["Pemilik/Pengguna", draft.ownerUserName || "-"], ["Kategori", draft.serviceCategory || "-"]
    ]} />
    <SummaryGroup title="Lokasi dan PIC" items={[
      ["Lokasi", selectedLocation?.name ?? "-"], ["Alamat", selectedLocation?.address ?? "-"],
      ["PIC", selectedPic?.name ?? "-"], ["Rencana Pemeriksaan", draft.plannedInspectionDate || "-"]
    ]} />
    <SummaryGroup title="Kelengkapan" items={[
      ["Peti Kemas", String(draft.containers.length)], ["Referensi", String(draft.referenceIds.length)],
      ["Lampiran", String(draft.attachments.length)], ["Status workflow", "Ditentukan sistem setelah tindakan"]
    ]} />
  </section>;
}

function TextField({ id, label, value, onChange, required, type = "text", readOnly }: { id: string; label: string; value: string; onChange?: (value: string) => void; required?: boolean; type?: string; readOnly?: boolean }) {
  return <FormField id={id} label={label} required={required}><input id={id} type={type} value={value} onChange={(event) => onChange?.(event.target.value)} required={required} readOnly={readOnly} /></FormField>;
}

function TextArea({ id, label, value, onChange, readOnly }: { id: string; label: string; value: string; onChange?: (value: string) => void; readOnly?: boolean }) {
  return <FormField id={id} label={label}><textarea id={id} rows={3} value={value} onChange={(event) => onChange?.(event.target.value)} readOnly={readOnly} /></FormField>;
}

function ClientContext({ client }: { client: FitnessClientDetail }) {
  return <div className="client-context-strip" role="status" aria-label={"Klien aktif " + client.name}><strong>Klien aktif:</strong><span>{client.name}</span><span>{client.code}</span><span>clientId: {client.id}</span></div>;
}

function SummaryGroup({ title, items }: { title: string; items: string[][] }) {
  return <section><h3>{title}</h3><dl>{items.map(([label, value]) => <div key={label}><dt>{label}</dt><dd>{value}</dd></div>)}</dl></section>;
}

function validateStep(step: number, draft: FitnessApplicationDraft): boolean {
  if (step === 0) return Boolean(draft.clientId && draft.applicantName.trim() && draft.ownerUserName.trim());
  if (step === 1) return Boolean(draft.applicationDate && draft.serviceCategory);
  if (step === 2) return Boolean(draft.locationId && draft.picPersonnelId && draft.plannedInspectionDate);
  if (step === 3) return draft.containers.length > 0 && draft.containers.every((item) => item.numberValid && item.containerTypeId);
  if (step === 4) return draft.referenceIds.length > 0;
  if (step === 5) return draft.attachments.some((item) => item.category === "Surat Permohonan");
  return [0, 1, 2, 3, 4, 5].every((index) => validateStep(index, draft));
}

function validationMessage(step: number) {
  return [
    "Pilih Klien dan lengkapi Pemohon serta Pemilik/Pengguna Peti Kemas.",
    "Lengkapi tanggal dan kategori layanan.",
    "Pilih lokasi, PIC, dan rencana tanggal pemeriksaan.",
    "Tambahkan minimal satu peti kemas dengan nomor dan jenis yang valid.",
    "Pilih minimal satu referensi pemeriksaan milik klien.",
    "Tambahkan minimal lampiran Surat Permohonan.",
    "Lengkapi seluruh langkah sebelum mengajukan."
  ][step];
}
