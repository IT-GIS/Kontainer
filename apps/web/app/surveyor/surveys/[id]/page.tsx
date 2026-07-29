"use client";

import { Camera, Check, FilePlus2, ImagePlus, Plus, Save, Send, Trash2, TriangleAlert } from "lucide-react";
import { useParams } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import type { Dispatch, SetStateAction } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { InteractiveSurveySheet } from "@/components/surveys/interactive-survey-sheet";
import { PhotoEvidence } from "@/components/surveys/photo-evidence";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { buildFindingDescription, formatCedexDamage, parseLocationSnapshot, selectionDescription, type LocationSelectionSnapshot } from "@/lib/survey-sheet";
import type { OptionItem } from "@/types/jobs";
import type { ChecklistItem, DamageDecisionPreview, DimensionProfile, SurveyDamage, SurveyDetail, SurveyGeneralInfo, SurveyMasterOption, SurveyMasterOptions, SurveyPhoto } from "@/types/surveyor";

const tabs = ["Ringkasan Pekerjaan", "Identitas Peti Kemas", "Checklist", "Survey Sheet Interaktif", "Daftar Temuan", "Foto", "Pratinjau & Submit"] as const;
type Tab = (typeof tabs)[number];

type DamageForm = {
  id?: string;
  cedex_location_id: string;
  face: string;
  internal_location: string;
  manual_location_reason: string;
  component_code_id: string;
  damage_code_id: string;
  repair_code_id: string;
  material_code_id: string;
  responsibility_code_id: string;
  severity: string;
  dimension_profile: DimensionProfile | "";
  location_selection_snapshot: LocationSelectionSnapshot | null;
  quantity: string;
  quantity_unit: string;
  length: string;
  width: string;
  depth: string;
  unit: string;
  is_repair_required: boolean;
  is_cargo_worthy_impact: boolean;
  remark: string;
};

const emptyDamage: DamageForm = {
  cedex_location_id: "",
  face: "",
  internal_location: "",
  manual_location_reason: "",
  component_code_id: "",
  damage_code_id: "",
  repair_code_id: "",
  material_code_id: "",
  responsibility_code_id: "",
  severity: "",
  dimension_profile: "",
  location_selection_snapshot: null,
  quantity: "",
  quantity_unit: "pc",
  length: "",
  width: "",
  depth: "",
  unit: "cm",
  is_repair_required: false,
  is_cargo_worthy_impact: false,
  remark: ""
};

type CodeProposalForm = {
  code_type: "location" | "component" | "damage" | "action_repair" | "material";
  code: string;
  description: string;
  reason: string;
  evidence_file_id: string;
  notes: string;
};

const emptyCodeProposal: CodeProposalForm = { code_type: "damage", code: "", description: "", reason: "", evidence_file_id: "", notes: "" };

export default function SurveyDetailPage() {
  return <ProtectedRoute><AppShell title="Detail Survei"><SurveyDetailContent /></AppShell></ProtectedRoute>;
}

function SurveyDetailContent() {
  const params = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const [survey, setSurvey] = useState<SurveyDetail | null>(null);
  const [activeTab, setActiveTab] = useState<Tab>("Ringkasan Pekerjaan");
  const [activeFace, setActiveFace] = useState("right");
  const [general, setGeneral] = useState<SurveyGeneralInfo>({});
  const [checklist, setChecklist] = useState<ChecklistItem[]>([]);
  const [components, setComponents] = useState<OptionItem[]>([]);
  const [damageCodes, setDamageCodes] = useState<OptionItem[]>([]);
  const [damageMasters, setDamageMasters] = useState<SurveyMasterOption[]>([]);
  const [repairs, setRepairs] = useState<OptionItem[]>([]);
  const [materials, setMaterials] = useState<OptionItem[]>([]);
  const [responsibilities, setResponsibilities] = useState<OptionItem[]>([]);
  const [cedexLocations, setCedexLocations] = useState<SurveyMasterOption[]>([]);
  const [severities, setSeverities] = useState<OptionItem[]>([]);
  const [photoCategories, setPhotoCategories] = useState<OptionItem[]>([]);
  const [damageDialog, setDamageDialog] = useState(false);
  const [damageForm, setDamageForm] = useState<DamageForm>(emptyDamage);
  const [damageBaseline, setDamageBaseline] = useState("");
  const [proposalDialog, setProposalDialog] = useState(false);
  const [proposalForm, setProposalForm] = useState<CodeProposalForm>(emptyCodeProposal);
  const [decisionPreview, setDecisionPreview] = useState<DamageDecisionPreview | null>(null);
  const [decisionLoading, setDecisionLoading] = useState(false);
  const [photoDamage, setPhotoDamage] = useState<SurveyDamage | null>(null);
  const [damagePhotoFile, setDamagePhotoFile] = useState<File | null>(null);
  const [damagePhotoCaption, setDamagePhotoCaption] = useState("");
  const [damagePhotoCategory, setDamagePhotoCategory] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  const readonly = survey ? !["draft", "need_revision"].includes(survey.status) : true;
  const loadSurvey = useCallback(async () => {
    if (!accessToken || !params.id) return;
    setError(null);
    try {
      const [detail, options] = await Promise.all([
        apiData<SurveyDetail>(`/surveys/${params.id}/preview`, { accessToken }),
        apiData<SurveyMasterOptions>(`/surveys/${params.id}/master-options`, { accessToken })
      ]);
      setSurvey(detail);
      setGeneral(detail.general_info ?? {});
      setChecklist(detail.checklist ?? []);
      setCedexLocations(options.cedex_locations ?? []);
      setComponents(toOptionItems(options.cedex_components));
      setDamageCodes(toOptionItems(options.cedex_damages));
      setRepairs(toOptionItems(options.cedex_repairs));
      setDamageMasters(options.cedex_damages ?? []);
      setMaterials(toOptionItems(options.cedex_materials));
      setResponsibilities(toOptionItems(options.responsibility_codes));
      setSeverities(toOptionItems(options.finding_severities));
      setPhotoCategories(toOptionItems(options.photo_categories));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil survey.");
    }
  }, [accessToken, params.id]);

  useEffect(() => { const timer = window.setTimeout(() => void loadSurvey(), 0); return () => window.clearTimeout(timer); }, [loadSurvey]);
  useEffect(() => {
    if (!damageDialog || JSON.stringify(damageForm) === damageBaseline) return;
    const handleBeforeUnload = (event: BeforeUnloadEvent) => event.preventDefault();
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [damageBaseline, damageDialog, damageForm]);
  useEffect(() => {
    const hasLocation = Boolean(damageForm.cedex_location_id || (damageForm.face && damageForm.internal_location && damageForm.manual_location_reason));
    const canPreview = Boolean(accessToken && params.id && damageDialog && hasLocation && damageForm.component_code_id && damageForm.damage_code_id);
    let activeRequest = true;
    const timer = window.setTimeout(() => {
      if (!canPreview || !accessToken) {
        setDecisionPreview(null);
        setDecisionLoading(false);
        return;
      }
      setDecisionLoading(true);
      void apiData<DamageDecisionPreview>(`/surveys/${params.id}/damage-decision-preview`, {
        method: "POST",
        accessToken,
        body: JSON.stringify(toDamagePayload(damageForm))
      })
        .then((result) => {
          if (activeRequest) setDecisionPreview(result);
        })
        .catch(() => {
          if (activeRequest) setDecisionPreview(null);
        })
        .finally(() => {
          if (activeRequest) setDecisionLoading(false);
        });
    }, canPreview ? 300 : 0);
    return () => {
      activeRequest = false;
      window.clearTimeout(timer);
    };
  }, [accessToken, damageDialog, damageForm, params.id]);

  async function runSave(action: () => Promise<void>) {
    setIsSaving(true);
    setError(null);
    setMessage(null);
    try {
      await action();
      await loadSurvey();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Aksi survey gagal.");
    } finally {
      setIsSaving(false);
    }
  }

  function openNewDamage(selection?: LocationSelectionSnapshot, location?: SurveyMasterOption) {
    const nextDamage = {
      ...emptyDamage,
      cedex_location_id: location?.id ?? "",
      face: location?.face ?? "",
      internal_location: location?.grid_code ?? location?.code ?? "",
      location_selection_snapshot: selection ?? null,
      severity: severities[0]?.code ?? ""
    };
    setDamagePhotoFile(null);
    setDamagePhotoCaption("");
    setDamagePhotoCategory(photoCategories[0]?.code ?? "");
    setDamageForm(nextDamage);
    setDamageBaseline(JSON.stringify(nextDamage));
    setDamageDialog(true);
  }

  function openLocationProposal(selection: LocationSelectionSnapshot) {
    setProposalForm({
      ...emptyCodeProposal,
      code_type: "location",
      description: selectionDescription(selection),
      reason: "Location Code belum tersedia untuk area Survey Sheet yang dipilih.",
      notes: JSON.stringify(selection)
    });
    setProposalDialog(true);
  }

  function openEditDamage(row: SurveyDamage) {
    const nextDamage = {
      ...emptyDamage,
      id: row.id,
      cedex_location_id: row.cedex_location_id ?? "",
      face: row.face,
      internal_location: row.internal_location,
      manual_location_reason: row.manual_location_reason ?? "",
      component_code_id: row.component_id ?? "",
      damage_code_id: row.damage_code_id ?? "",
      repair_code_id: row.repair_code_id ?? "",
      material_code_id: row.material_code_id ?? "",
      responsibility_code_id: row.responsibility_code_id ?? "",
      severity: row.severity,
      dimension_profile: row.dimension_profile ?? "manual_review",
      location_selection_snapshot: parseLocationSnapshot(row.location_selection_snapshot),
      quantity: row.quantity != null ? String(row.quantity) : "",
      quantity_unit: row.quantity_unit ?? "pc",
      length: row.length != null ? String(row.length) : "",
      width: row.width != null ? String(row.width) : "",
      depth: row.depth != null ? String(row.depth) : "",
      unit: row.unit ?? "cm",
      is_repair_required: Boolean(row.is_repair_required),
      is_cargo_worthy_impact: Boolean(row.is_cargo_worthy_impact),
      remark: row.remark ?? ""
    };
    setDamagePhotoFile(null);
    setDamagePhotoCaption("");
    setDamagePhotoCategory(photoCategories[0]?.code ?? "");
    setDamageForm(nextDamage);
    setDamageBaseline(JSON.stringify(nextDamage));
    setDamageDialog(true);
  }

  function closeDamageDialog(force = false) {
    if (!force && JSON.stringify(damageForm) !== damageBaseline && !window.confirm("Perubahan temuan belum disimpan. Tutup form?")) return;
    setDamageDialog(false);
    setDamageForm(emptyDamage);
    setDecisionPreview(null);
    setDecisionLoading(false);
    setDamageBaseline("");
    setDamagePhotoFile(null);
    setDamagePhotoCaption("");
    setDamagePhotoCategory("");
  }

  async function saveGeneral() {
    if (!accessToken) return;
    await runSave(async () => {
      await apiData(`/surveys/${params.id}/general-info`, { method: "PUT", accessToken, body: JSON.stringify(general) });
      setMessage("General info tersimpan.");
    });
  }

  async function saveChecklist() {
    if (!accessToken) return;
    await runSave(async () => {
      await apiData(`/surveys/${params.id}/checklist`, {
        method: "PUT",
        accessToken,
        body: JSON.stringify({
          items: checklist.map((item) => ({
            item_key: item.item_key,
            value: item.value ?? "",
            numeric_value: item.numeric_value ?? null,
            note: item.note ?? "",
            attachment_file_id: item.attachment_file_id ?? ""
          }))
        })
      });
      setMessage("Checklist tersimpan.");
    });
  }

  async function saveDamage() {
    if (!accessToken || isSaving) return;
    const selectedDamage = damageMasters.find((item) => item.id === damageForm.damage_code_id);
    const validationError = validateDamageForm(damageForm, Boolean(selectedDamage?.requires_dimension));
    if (validationError) {
      setError(validationError);
      return;
    }
    await runSave(async () => {
      if (damagePhotoFile && !damagePhotoCategory) throw new Error("Kategori Foto Evidence wajib dipilih.");
      const body = JSON.stringify(toDamagePayload(damageForm));
      let saved: { id?: string };
      if (damageForm.id) {
        saved = await apiData<{ id?: string }>(`/survey-damages/${damageForm.id}`, { method: "PUT", accessToken, body });
      } else {
        saved = await apiData<{ id?: string }>(`/surveys/${params.id}/damages`, { method: "POST", accessToken, body });
      }
      const savedDamageID = saved.id ?? damageForm.id;
      if (damagePhotoFile && savedDamageID) {
        const photoForm = new FormData();
        photoForm.set("file", damagePhotoFile);
        photoForm.set("caption", damagePhotoCaption);
        photoForm.set("photo_type", "damage");
        photoForm.set("photo_category", damagePhotoCategory);
        await apiData(`/survey-damages/${savedDamageID}/photos`, { method: "POST", accessToken, body: photoForm });
      }
      closeDamageDialog(true);
      setActiveTab("Daftar Temuan");
      setMessage(damagePhotoFile ? "Temuan dan Foto Evidence tersimpan." : "Temuan tersimpan.");
    });
  }

  async function submitCodeProposal() {
    if (!accessToken || isSaving) return;
    const expectedLength = proposalForm.code_type === "location" ? 4 : proposalForm.code_type === "component" ? 3 : 2;
    if (!new RegExp(`^[A-Za-z0-9]{${expectedLength}}$`).test(proposalForm.code)) {
      setError(`Code wajib terdiri dari tepat ${expectedLength} karakter huruf atau angka.`);
      return;
    }
    if (!proposalForm.description.trim() || !proposalForm.reason.trim()) {
      setError("Description dan Alasan Pengajuan wajib diisi.");
      return;
    }
    await runSave(async () => {
      await apiData(`/surveys/${params.id}/cedex-code-proposals`, { method: "POST", accessToken, body: JSON.stringify(proposalForm) });
      setProposalDialog(false);
      setProposalForm(emptyCodeProposal);
      setMessage("Pengajuan kode dikirim dengan status Menunggu Persetujuan.");
    });
  }

  async function deleteDamage(row: SurveyDamage) {
    if (!accessToken) return;
    await runSave(async () => {
      await apiData(`/survey-damages/${row.id}`, { method: "DELETE", accessToken });
      setMessage("Damage dihapus.");
    });
  }

  async function uploadDamagePhoto(file: File | null, caption: string, photoCategory: string) {
    if (!accessToken || !photoDamage || !file || !photoCategory) {
      setError("File dan kategori foto wajib dipilih.");
      return;
    }
    await runSave(async () => {
      const form = new FormData();
      form.set("file", file);
      form.set("caption", caption);
      form.set("photo_type", "damage");
      form.set("photo_category", photoCategory);
      await apiData(`/survey-damages/${photoDamage.id}/photos`, { method: "POST", accessToken, body: form });
      setPhotoDamage(null);
      setMessage("Foto evidence tersimpan.");
    });
  }

  async function deletePhoto(photo: SurveyPhoto) {
    if (!accessToken || !window.confirm("Hapus foto draft ini? Metadata akan dihapus secara soft-delete dari survei.")) return;
    await runSave(async () => {
      await apiData(`/survey-photos/${photo.id}`, { method: "DELETE", accessToken });
      setMessage("Foto draft dihapus.");
    });
  }

  async function submitSurvey() {
    if (!accessToken) return;
    await runSave(async () => {
      await apiData(`/surveys/${params.id}/submit`, { method: "POST", accessToken, body: JSON.stringify({ final_remark: general.general_remark ?? "" }) });
      setMessage("Survey berhasil disubmit.");
      setActiveTab("Pratinjau & Submit");
    });
  }

  if (!survey) return <div className="center-screen">Memuat survey...</div>;

  return (
    <div className="page-stack">
      <PageHeader title={`Survei: ${survey.survey_no}`} description={`Peti kemas: ${survey.container_no} - ${survey.customer_name} - ${survey.location_name}`} />
      <div className="survey-strip">
        <StatusBadge tone={survey.status === "draft" ? "warning" : survey.status === "submitted" ? "neutral" : survey.status === "need_revision" ? "danger" : "success"}>{survey.status.toUpperCase()}</StatusBadge>
        <span>{survey.survey_type_name}</span><span>{survey.container_type_code ?? "-"} / {survey.iso_type_code ?? "-"}</span>
        <span>{survey.surveyor_name}</span><strong>{readonly ? "Hanya baca" : "Draf dapat diedit"}</strong>
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      {message ? <div className="alert alert-success" aria-live="polite">{message}</div> : null}
      <div className="tab-list">{tabs.map((tab) => <button className={activeTab === tab ? "tab-active" : ""} key={tab} onClick={() => setActiveTab(tab)}>{tab}</button>)}</div>
      {activeTab === "Ringkasan Pekerjaan" ? <JobSummaryTab survey={survey} /> : null}
      {activeTab === "Identitas Peti Kemas" ? <IdentityTab survey={survey} general={general} readonly={readonly} isSaving={isSaving} onChange={setGeneral} onSave={saveGeneral} /> : null}
      {activeTab === "Checklist" ? <ChecklistTab items={checklist} readonly={readonly} isSaving={isSaving} onChange={setChecklist} onSave={saveChecklist} onFinding={() => setActiveTab("Survey Sheet Interaktif")} /> : null}
      {activeTab === "Survey Sheet Interaktif" ? <InteractiveSurveySheet containerSize={survey.container_size} activeFace={activeFace} locations={cedexLocations} damages={survey.damages ?? []} readonly={readonly} onFace={setActiveFace} onUseLocation={openNewDamage} onProposeLocation={openLocationProposal} onEditDamage={openEditDamage} /> : null}
      {activeTab === "Daftar Temuan" ? <DamageList rows={survey.damages ?? []} readonly={readonly} onAdd={() => openNewDamage()} onEdit={openEditDamage} onDelete={deleteDamage} onPhoto={setPhotoDamage} /> : null}
      {activeTab === "Foto" ? <PhotosTab damages={survey.damages ?? []} photos={survey.photos ?? []} readonly={readonly} onPhoto={setPhotoDamage} onDeletePhoto={deletePhoto} /> : null}
      {activeTab === "Pratinjau & Submit" ? <PreviewAndSubmitTab survey={survey} activeFace={activeFace} locations={cedexLocations} readonly={readonly} isSaving={isSaving} onFace={setActiveFace} onSubmit={submitSurvey} onBack={() => setActiveTab("Survey Sheet Interaktif")} onSaveDraft={() => setMessage("Draf yang sudah diisi tetap tersimpan.")} /> : null}
      <FormDialog title={damageForm.id ? "Edit Temuan CEDEX" : "Tambah Temuan CEDEX"} open={damageDialog} onClose={closeDamageDialog} onSubmit={saveDamage} isSubmitting={isSaving} submitLabel="Simpan Temuan" size="large">
        <DamageFormFields form={damageForm} setForm={setDamageForm} locations={cedexLocations} components={components} damageCodes={damageCodes} damageMasters={damageMasters} repairs={repairs} materials={materials} responsibilities={responsibilities} severities={severities} photoCategories={photoCategories} photoFile={damagePhotoFile} photoCaption={damagePhotoCaption} photoCategory={damagePhotoCategory} decisionPreview={decisionPreview} decisionLoading={decisionLoading} onPhotoFile={setDamagePhotoFile} onPhotoCaption={setDamagePhotoCaption} onPhotoCategory={setDamagePhotoCategory} onPropose={() => setProposalDialog(true)} />
      </FormDialog>
      <FormDialog title="Ajukan Kode Baru" open={proposalDialog} onClose={() => setProposalDialog(false)} onSubmit={submitCodeProposal} isSubmitting={isSaving} submitLabel="Kirim Pengajuan" size="large">
        <div className="alert alert-info">Pengajuan tidak langsung mengubah master aktif. Admin akan memeriksa kode, alasan, dan bukti sebelum menyetujui atau menolak.</div>
        <div className="form-grid">
          <Field label="Jenis Kode *"><select value={proposalForm.code_type} onChange={(event) => setProposalForm((current) => ({ ...current, code_type: event.target.value as CodeProposalForm["code_type"], code: "" }))}><option value="location">Location Code</option><option value="component">Component Code</option><option value="damage">Damage Code</option><option value="action_repair">Action Repair Code</option><option value="material">Material Code</option></select></Field>
          <Field label="Code *"><input maxLength={proposalForm.code_type === "location" ? 4 : proposalForm.code_type === "component" ? 3 : 2} value={proposalForm.code} onChange={(event) => setProposalForm((current) => ({ ...current, code: event.target.value.toUpperCase().replace(/[^A-Z0-9]/g, "") }))} /></Field>
          <label className="field form-span-2"><span>Description *</span><textarea rows={3} value={proposalForm.description} onChange={(event) => setProposalForm((current) => ({ ...current, description: event.target.value }))} /></label>
          <label className="field form-span-2"><span>Alasan Pengajuan *</span><textarea rows={3} value={proposalForm.reason} onChange={(event) => setProposalForm((current) => ({ ...current, reason: event.target.value }))} /></label>
          <Field label="Foto / Bukti (File ID)"><input value={proposalForm.evidence_file_id} onChange={(event) => setProposalForm((current) => ({ ...current, evidence_file_id: event.target.value }))} /></Field>
          <label className="field form-span-2"><span>Catatan</span><textarea rows={3} value={proposalForm.notes} onChange={(event) => setProposalForm((current) => ({ ...current, notes: event.target.value }))} /></label>
        </div>
      </FormDialog>
      <PhotoDialog damage={photoDamage} categories={photoCategories} open={Boolean(photoDamage)} onClose={() => setPhotoDamage(null)} onSubmit={uploadDamagePhoto} isSaving={isSaving} />
    </div>
  );
}

function JobSummaryTab({ survey }: { survey: SurveyDetail }) {
  return <section className="workspace-panel"><div className="detail-grid">
    <div><span>Nomor Job/SPK</span><strong>{survey.job_order_no}{survey.spk_no ? ` / ${survey.spk_no}` : ""}</strong></div>
    <div><span>Customer</span><strong>{survey.customer_name}</strong></div>
    <div><span>Lokasi pemeriksaan</span><strong>{survey.location_name}</strong></div>
    <div><span>PIC Customer</span><strong>{survey.pic_customer_name ?? "-"}{survey.pic_customer_phone ? ` / ${survey.pic_customer_phone}` : ""}</strong></div>
    <div><span>Tanggal / jadwal</span><strong>{survey.spk_date ?? survey.job_deadline ?? survey.assignment_due_at ?? "-"}</strong></div>
    <div><span>Nama Surveyor</span><strong>{survey.surveyor_name}</strong></div>
    <div><span>Status pekerjaan</span><strong>{survey.status.replaceAll("_", " " ).toUpperCase()}</strong></div>
    <div><span>Jenis pemeriksaan</span><strong>{survey.survey_type_name || "Inspeksi Kelaikan"}</strong></div>
    <div className="form-span-2"><span>Instruksi pekerjaan</span><strong>{survey.job_instruction ?? "-"}</strong></div>
    <div className="form-span-2"><span>Instruksi penugasan</span><strong>{survey.assignment_instruction ?? "-"}</strong></div>
  </div><div className="alert alert-info">Customer, Job/SPK, lokasi, PIC, dan assignment bersifat read-only pada workspace Surveyor.</div></section>;
}

function IdentityTab({ survey, general, readonly, isSaving, onChange, onSave }: { survey: SurveyDetail; general: SurveyGeneralInfo; readonly: boolean; isSaving: boolean; onChange: (value: SurveyGeneralInfo) => void; onSave: () => void }) {
  return <section className="workspace-panel"><div className="detail-grid identity-summary">
    <div><span>Nomor peti kemas</span><strong>{survey.container_no}</strong></div>
    <div><span>Check digit</span><strong>{survey.check_digit ?? "-"} · {survey.check_digit_status ?? "belum diperiksa"}</strong></div>
    <div><span>Ukuran</span><strong>{survey.container_size ? `${survey.container_size} feet` : "Belum tersedia"}</strong></div>
    <div><span>ISO Type</span><strong>{survey.iso_type_code ?? "-"}</strong></div>
    <div><span>Tahun / tanggal pembuatan</span><strong>{survey.manufacture_date ?? "-"}</strong></div>
    <div><span>Pemilik / operator</span><strong>{survey.owner_code ?? "-"}</strong></div>
    <div><span>Nomor CSC Plate</span><strong>Belum tersedia pada data Job Container</strong></div>
    <div><span>Tanggal CSC</span><strong>Belum tersedia pada data Job Container</strong></div>
    <div><span>Status CSC Plate</span><strong>{survey.csc_plate_status ?? general.csc_plate_status ?? "-"}</strong></div>
    <div><span>Container Type</span><strong>{survey.container_type_code ?? "-"} · {survey.container_type_name ?? "-"}</strong></div>
  </div><div className="form-grid">
    <Field label="Cargo Status"><select disabled={readonly} value={general.cargo_status ?? "unknown"} onChange={(e) => onChange({ ...general, cargo_status: e.target.value })}><option value="unknown">unknown</option><option value="empty">empty</option><option value="laden">laden</option></select></Field>
    <Field label="Container Lifecycle"><select disabled={readonly} value={general.container_lifecycle ?? ""} onChange={(e) => onChange({ ...general, container_lifecycle: (e.target.value || null) as SurveyGeneralInfo["container_lifecycle"] })}><option value="">Select</option><option value="new">Peti Kemas Baru</option><option value="existing">Peti Kemas Lama / Existing</option></select></Field>
    <Field label="Seal No"><input disabled={readonly} value={general.seal_no ?? ""} onChange={(e) => onChange({ ...general, seal_no: e.target.value })} /></Field>
    <Field label="Truck No"><input disabled={readonly} value={general.truck_no ?? ""} onChange={(e) => onChange({ ...general, truck_no: e.target.value })} /></Field>
    <Field label="Driver Name"><input disabled={readonly} value={general.driver_name ?? ""} onChange={(e) => onChange({ ...general, driver_name: e.target.value })} /></Field>
    <Field label="Chassis No"><input disabled={readonly} value={general.chassis_no ?? ""} onChange={(e) => onChange({ ...general, chassis_no: e.target.value })} /></Field>
    <Field label="CSC Plate"><input disabled={readonly} value={general.csc_plate_status ?? ""} onChange={(e) => onChange({ ...general, csc_plate_status: e.target.value })} /></Field>
    <Field label="Door Status"><input disabled={readonly} value={general.door_status ?? ""} onChange={(e) => onChange({ ...general, door_status: e.target.value })} /></Field>
    <Field label="General Condition"><select disabled={readonly} value={general.general_condition ?? ""} onChange={(e) => onChange({ ...general, general_condition: e.target.value })}><option value="">Select</option><option value="sound">sound</option><option value="damage">damage</option><option value="dirty">dirty</option></select></Field>
    <Field label="Weather"><input disabled={readonly} value={general.weather ?? ""} onChange={(e) => onChange({ ...general, weather: e.target.value })} /></Field>
    <label className="field form-span-2"><span>General Remark</span><textarea disabled={readonly} rows={3} value={general.general_remark ?? ""} onChange={(e) => onChange({ ...general, general_remark: e.target.value })} /></label>
  </div><div className="alert alert-info">Foto depan, belakang, dan CSC Plate tetap dikelola melalui kategori foto aktif pada tab Foto.</div><StickyActions><button className="primary-button" disabled={readonly || isSaving} onClick={onSave}><Save size={17} /><span>Simpan Identitas</span></button></StickyActions></section>;
}

function ChecklistTab({ items, readonly, isSaving, onChange, onSave, onFinding }: { items: ChecklistItem[]; readonly: boolean; isSaving: boolean; onChange: (value: ChecklistItem[]) => void; onSave: () => void; onFinding: (item: ChecklistItem) => void }) {
  return <section className="workspace-panel checklist-list"><div className="alert alert-info">Referensi inspeksi aktif disimpan bersama snapshot checklist saat survei dibuat.</div>{items.map((item, index) => <div className="check-row" key={item.item_key}><div><strong>{item.item_label ?? item.item_key}</strong>{item.is_critical ? <span>Kritis</span> : null}{item.standard_reference ? <small>{item.standard_reference}</small> : null}{item.value === "no" ? <button className="secondary-button checklist-finding-button" disabled={readonly} onClick={() => onFinding(item)} type="button"><Plus size={16} /><span>Buat Temuan CEDEX</span></button> : null}</div>{item.response_type === "numeric" ? <label className="field"><span>Hasil {item.unit ? `(${item.unit})` : ""}</span><input disabled={readonly} type="number" value={item.numeric_value ?? ""} onChange={(event) => onChange(items.map((row, rowIndex) => rowIndex === index ? { ...row, numeric_value: event.target.value === "" ? null : Number(event.target.value) } : row))} /></label> : item.response_type === "text" ? <input disabled={readonly} value={item.value ?? ""} onChange={(event) => onChange(items.map((row, rowIndex) => rowIndex === index ? { ...row, value: event.target.value } : row))} /> : <div className="segmented-control">{["yes", "no", "na"].map((value) => <button disabled={readonly} className={item.value === value ? "selected" : ""} key={value} onClick={() => onChange(items.map((row, rowIndex) => rowIndex === index ? { ...row, value } : row))}>{value.toUpperCase()}</button>)}</div>}</div>)}<StickyActions><button className="primary-button" disabled={readonly || isSaving} onClick={onSave}><Check size={17} /><span>Simpan Checklist</span></button></StickyActions></section>;
}

function DamageList({ rows, readonly, onAdd, onEdit, onDelete, onPhoto }: { rows: SurveyDamage[]; readonly: boolean; onAdd: () => void; onEdit: (row: SurveyDamage) => void; onDelete: (row: SurveyDamage) => void; onPhoto: (row: SurveyDamage) => void }) {
  return <section className="workspace-panel"><div className="section-title-row"><div><h2>Daftar Temuan</h2><p className="muted-text">Format CEDEX tidak menampilkan separator untuk bagian yang kosong.</p></div><button className="primary-button" disabled={readonly} onClick={onAdd}><Plus size={17} /><span>Tambah Temuan</span></button></div><DataTable responsiveCards rows={rows} columns={[
    { key: "damage_no", header: "No.", render: (row) => row.damage_no },
    { key: "cedex_format", header: "CEDEX Format", render: (row) => <strong>{formatCedexDamage(row)}</strong> },
    { key: "location", header: "Location", render: (row) => row.cedex_location_code ?? row.internal_location },
    { key: "component", header: "Component", render: (row) => row.component_name ?? row.component_code ?? "-" },
    { key: "damage", header: "Damage", render: (row) => row.damage_name ?? row.damage_code ?? "-" },
    { key: "dimension", header: "Dimension", render: (row) => [row.length, row.width, row.depth].filter((value) => value != null).join(" × ") + ([row.length, row.width, row.depth].some((value) => value != null) ? ` ${row.unit ?? ""}` : "") || "-" },
    { key: "quantity", header: "Quantity", render: (row) => row.quantity == null ? "-" : `${row.quantity} ${row.quantity_unit ?? ""}` },
    { key: "repair", header: "Action", render: (row) => row.repair_name ?? row.repair_code ?? "-" },
    { key: "material", header: "Material", render: (row) => row.material_name ?? row.material_code ?? "-" },
    { key: "photo", header: "Foto", render: (row) => <button className="secondary-button table-action" disabled={readonly} onClick={() => onPhoto(row)}><Camera size={16} /><span>{row.photo_count ?? 0}</span></button> },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone={requiresRepair(row) ? "warning" : "neutral"}>{decisionResultText(row.decision_result)}</StatusBadge> },
    { key: "actions", header: "Action", render: (row) => <div className="table-actions"><button className="secondary-button table-action" disabled={readonly} onClick={() => onEdit(row)}>Edit</button><button className="icon-button" disabled={readonly} onClick={() => void onDelete(row)} title="Delete damage"><Trash2 size={16} /></button></div> }
  ]} /></section>;
}

function PhotosTab({ damages, photos, readonly, onPhoto, onDeletePhoto }: { damages: SurveyDamage[]; photos: SurveyPhoto[]; readonly: boolean; onPhoto: (row: SurveyDamage) => void; onDeletePhoto: (photo: SurveyPhoto) => void }) {
  return <section className="workspace-panel photo-list">
    <div className="photo-category-overview">{["Foto Umum", "Foto Identitas", "Foto CSC Plate", "Foto per Temuan", "Foto Setelah Perbaikan", "Foto Reinspection"].map((label) => <span key={label}>{label}</span>)}</div>
    {damages.length === 0 ? <p className="muted-text">Belum ada temuan yang dapat diberi Foto Evidence.</p> : null}
    {damages.map((damage) => {
      const damagePhotos = photos.filter((photo) => photo.damage_id === damage.id);
      return <div className="photo-section" key={damage.id}><div className="section-title-row"><div><h3>{damage.damage_no} - {damage.cedex_location_code ?? damage.internal_location}</h3><p className="muted-text">{damage.damage_name ?? damage.damage_code}</p></div><button className="secondary-button" disabled={readonly} onClick={() => onPhoto(damage)}><ImagePlus size={17} /><span>Tambah Foto</span></button></div>{damagePhotos.length === 0 ? <div className="alert alert-info">Belum ada Foto Evidence. Tambahkan hanya jika rule atau kategori aktif mewajibkan, atau bila diperlukan sebagai bukti.</div> : <div className="photo-grid">{damagePhotos.map((photo) => <div className="photo-card" key={photo.id}><PhotoEvidence id={photo.id} name={photo.original_file_name} caption={photo.caption} /><div className="photo-card-actions"><span>{photo.photo_category ?? "damage_finding"}</span><button className="icon-button" disabled={readonly} onClick={() => onDeletePhoto(photo)} title="Hapus foto draft"><Trash2 size={16} /></button></div></div>)}</div>}</div>;
    })}
  </section>;
}

function PreviewAndSubmitTab({ survey, activeFace, locations, readonly, isSaving, onFace, onSubmit, onBack, onSaveDraft }: { survey: SurveyDetail; activeFace: string; locations: SurveyMasterOption[]; readonly: boolean; isSaving: boolean; onFace: (face: string) => void; onSubmit: () => void; onBack: () => void; onSaveDraft: () => void }) {
  const warnings = survey.warnings ?? [];
  return <div className="preview-stack">
    <section className="workspace-panel"><div className="section-title-row"><div><h2>Pratinjau &amp; Submit</h2><p className="muted-text">Periksa identitas, marker, format CEDEX, deskripsi, foto, dan hasil keputusan sebelum mengirim.</p></div><StatusBadge tone={warnings.length === 0 ? "success" : "danger"}>{warnings.length === 0 ? "LENGKAP" : `${warnings.length} KEKURANGAN`}</StatusBadge></div><div className="detail-grid"><div><span>Nomor Job/SPK</span><strong>{survey.job_order_no}</strong></div><div><span>Survey No</span><strong>{survey.survey_no}</strong></div><div><span>Customer</span><strong>{survey.customer_name}</strong></div><div><span>Container</span><strong>{survey.container_no} / {survey.container_size ?? "-"} feet</strong></div><div><span>Jumlah temuan</span><strong>{survey.damages?.length ?? 0}</strong></div><div><span>Jumlah foto</span><strong>{survey.photos?.length ?? 0}</strong></div><div><span>Decision Result</span><strong>{survey.survey_result_recommendation ?? "Manual Review"}</strong></div><div><span>Status kelengkapan</span><strong>{warnings.length === 0 ? "Lengkap" : "Perlu diperbaiki"}</strong></div></div></section>
    <InteractiveSurveySheet containerSize={survey.container_size} activeFace={activeFace} locations={locations} damages={survey.damages ?? []} readonly preview onFace={onFace} />
    <section className="workspace-panel"><h3>Format CEDEX dan Deskripsi Otomatis</h3><DataTable responsiveCards rows={survey.damages ?? []} columns={[{ key: "no", header: "No.", render: (row) => row.damage_no }, { key: "cedex", header: "CEDEX Format", render: (row) => formatCedexDamage(row) }, { key: "description", header: "Deskripsi otomatis", render: (row) => row.finding_description || "-" }, { key: "decision", header: "Decision Result", render: (row) => decisionResultText(row.decision_result) }, { key: "photo", header: "Foto", render: (row) => row.photo_count ?? 0 }]} /></section>
    <section className="workspace-panel submit-panel"><h3>Validasi Submit</h3>{warnings.length > 0 ? warnings.map((warning) => <div className="alert alert-danger" key={warning.code}><TriangleAlert size={16} />{warning.message}</div>) : <div className="alert alert-success">Survey siap dikirim ke Reviewer.</div>}<div className="preview-submit-actions"><button className="secondary-button" disabled={readonly || isSaving} onClick={onSaveDraft}><Save size={17} /><span>Simpan Draft</span></button><button className="secondary-button" disabled={isSaving} onClick={onBack}>Kembali Perbaiki</button><button className="primary-button" disabled={readonly || isSaving || warnings.length > 0} onClick={onSubmit}><Send size={17} /><span>Submit ke Reviewer</span></button></div></section>
  </div>;
}

function DamageFormFields({
  form,
  setForm,
  locations,
  components,
  damageCodes,
  damageMasters,
  repairs,
  materials,
  responsibilities,
  severities,
  photoCategories,
  photoFile,
  photoCaption,
  photoCategory,
  decisionPreview,
  decisionLoading,
  onPhotoFile,
  onPhotoCaption,
  onPhotoCategory,
  onPropose
}: {
  form: DamageForm;
  setForm: Dispatch<SetStateAction<DamageForm>>;
  locations: SurveyMasterOption[];
  components: OptionItem[];
  damageCodes: OptionItem[];
  damageMasters: SurveyMasterOption[];
  repairs: OptionItem[];
  materials: OptionItem[];
  responsibilities: OptionItem[];
  severities: OptionItem[];
  photoCategories: OptionItem[];
  photoFile: File | null;
  photoCaption: string;
  photoCategory: string;
  decisionPreview: DamageDecisionPreview | null;
  decisionLoading: boolean;
  onPhotoFile: (file: File | null) => void;
  onPhotoCaption: (value: string) => void;
  onPhotoCategory: (value: string) => void;
  onPropose: () => void;
}) {
  const legacyResponsibility = responsibilities.find((item) => item.id === form.responsibility_code_id);
  const selectedDamage = damageMasters.find((item) => item.id === form.damage_code_id);
  const selectedLocation = locations.find((item) => item.id === form.cedex_location_id);
  const selectedComponent = components.find((item) => item.id === form.component_code_id);
  const selectedDamageCode = damageCodes.find((item) => item.id === form.damage_code_id);
  const selectedRepair = repairs.find((item) => item.id === form.repair_code_id);
  const selectedMaterial = materials.find((item) => item.id === form.material_code_id);
  const findingDescription = buildFindingDescription({
    locationDescription: selectedLocation?.description,
    locationFallback: form.location_selection_snapshot ? selectionDescription(form.location_selection_snapshot) : [form.face, form.internal_location].filter(Boolean).join(" "),
    componentDescription: selectedComponent?.label,
    componentFallback: selectedComponent?.code,
    damageDescription: selectedDamageCode?.label,
    damageFallback: selectedDamageCode?.code,
    materialDescription: selectedMaterial?.label,
    materialFallback: selectedMaterial?.code,
    repairDescription: decisionPreview?.recommended_action_name || selectedRepair?.label,
    repairFallback: selectedRepair?.code,
    length: form.length,
    width: form.width,
    depth: form.depth,
    unit: form.unit,
    quantity: form.quantity,
    quantityUnit: form.quantity_unit
  });
  return <>
    <div className="section-title-row form-span-2"><div><strong>Temuan ISO CEDEX</strong><p className="muted-text">Pilih kode aktif. Jika kode belum tersedia, kirim pengajuan untuk direview Admin.</p></div><button className="secondary-button" onClick={onPropose} type="button"><FilePlus2 size={16} /><span>Ajukan Kode Baru</span></button></div>
    <DamageBaseFields
      form={form}
      setForm={setForm}
      locations={locations}
      components={components}
      damageCodes={damageCodes}
      damageMasters={damageMasters}
      repairs={repairs}
      materials={materials}
      severities={severities}
    />
    {selectedDamage?.requires_dimension ? (
      <div className="alert alert-warning">Damage ini memerlukan dimensi. Pilih Dimension Profile; hanya field yang relevan dengan profil tersebut yang diwajibkan.</div>
    ) : null}
    <div className="form-grid">
      {form.responsibility_code_id ? <Field label="Responsibility (Legacy - baca-saja)"><input readOnly value={legacyResponsibility ? `${legacyResponsibility.code ?? ""} - ${legacyResponsibility.label}` : "Referensi legacy tidak ditemukan"} /></Field> : null}
      <DecisionRuleCard preview={decisionPreview} loading={decisionLoading} />
      <div className="finding-description-preview form-span-2">
        <strong>Deskripsi temuan otomatis</strong>
        <p>{findingDescription}</p>
        <small className="muted-text">Deskripsi dibuat sistem dan disimpan sebagai snapshot. Remark di bawah hanya untuk catatan khusus Surveyor.</small>
      </div>
      <label className="field form-span-2"><span>Remark khusus</span><textarea rows={4} value={form.remark} onChange={(event) => setDamageValue(setForm, "remark", event.target.value)} /></label>
      <div className="damage-photo-fields form-span-2"><strong>Foto Evidence</strong><p className="muted-text">Simpan bersama temuan sekarang atau tambahkan foto lain dari tab Foto. Minimal satu foto hanya wajib bila rule atau kategori aktif mewajibkan.</p><div className="form-grid"><Field label="Kategori Foto"><select value={photoCategory} onChange={(event) => onPhotoCategory(event.target.value)}><option value="">Pilih kategori aktif</option>{photoCategories.map((item) => <option key={item.id} value={item.code}>{item.code} - {item.label}</option>)}</select></Field><label className="field"><span>Ambil Foto</span><input accept="image/jpeg,image/png,image/webp" capture="environment" type="file" onChange={(event) => onPhotoFile(event.target.files?.[0] ?? null)} /></label><label className="field"><span>Pilih dari Galeri</span><input accept="image/jpeg,image/png,image/webp" type="file" onChange={(event) => onPhotoFile(event.target.files?.[0] ?? null)} /></label><label className="field form-span-2"><span>Caption</span><textarea rows={2} value={photoCaption} onChange={(event) => onPhotoCaption(event.target.value)} /></label></div>{photoFile ? <div className="alert alert-success">Foto siap diunggah: {photoFile.name}</div> : null}</div>
    </div>
  </>;
}

function DamageBaseFields({ form, setForm, locations, components, damageCodes, damageMasters, repairs, materials, severities }: {
  form: DamageForm;
  setForm: Dispatch<SetStateAction<DamageForm>>;
  locations: SurveyMasterOption[];
  components: OptionItem[];
  damageCodes: OptionItem[];
  damageMasters: SurveyMasterOption[];
  repairs: OptionItem[];
  materials: OptionItem[];
  severities: OptionItem[];
}) {
  const profile = form.dimension_profile;
  const showLength = ["length_width", "length_width_depth", "linear_length", "area", "manual_review"].includes(profile);
  const showWidth = ["length_width", "length_width_depth", "area", "manual_review"].includes(profile);
  const showDepth = ["length_width_depth", "depth_only", "manual_review"].includes(profile);
  const showQuantity = ["quantity_only", "manual_review"].includes(profile);
  const hasStructuredSelection = Boolean(form.location_selection_snapshot);
  function selectLocation(value: string) {
    const selected = locations.find((item) => item.id === value);
    setForm((current) => ({ ...current, cedex_location_id: value, face: selected?.face ?? "", internal_location: selected?.grid_code ?? selected?.code ?? "", manual_location_reason: value ? "" : current.manual_location_reason, location_selection_snapshot: null }));
  }
  function selectDamage(value: string) {
    const selected = damageMasters.find((item) => item.id === value);
    setForm((current) => ({
      ...current,
      damage_code_id: value,
      severity: selected?.default_severity || current.severity,
      repair_code_id: selected?.default_action_id || current.repair_code_id
    }));
  }
  function selectDimensionProfile(value: DimensionProfile | "") {
    setForm((current) => {
      const keepLength = ["length_width", "length_width_depth", "linear_length", "area", "manual_review"].includes(value);
      const keepWidth = ["length_width", "length_width_depth", "area", "manual_review"].includes(value);
      const keepDepth = ["length_width_depth", "depth_only", "manual_review"].includes(value);
      const keepQuantity = ["quantity_only", "manual_review"].includes(value);
      return {
        ...current,
        dimension_profile: value,
        length: keepLength ? current.length : "",
        width: keepWidth ? current.width : "",
        depth: keepDepth ? current.depth : "",
        quantity: keepQuantity ? current.quantity : ""
      };
    });
  }
  return <div className="form-grid">
    {hasStructuredSelection ? <div className="selected-location-summary form-span-2"><strong>Lokasi CEDEX terpilih</strong><div className="detail-grid"><div><span>Location Code</span><b>{locations.find((item) => item.id === form.cedex_location_id)?.code ?? "Belum terpetakan"}</b></div><div><span>Face / Vertical</span><b>{form.location_selection_snapshot?.face} / {form.location_selection_snapshot?.vertical_position}</b></div><div><span>Section</span><b>{form.location_selection_snapshot?.section_start === form.location_selection_snapshot?.section_end ? form.location_selection_snapshot?.section_start : `${form.location_selection_snapshot?.section_start}-${form.location_selection_snapshot?.section_end}`}</b></div><div><span>Container Size</span><b>{form.location_selection_snapshot?.container_size} feet</b></div></div></div> : <><Field label="Location Code"><select value={form.cedex_location_id} onChange={(event) => selectLocation(event.target.value)}><option value="">Lokasi manual (fallback)</option>{locations.map((item) => <option key={item.id} value={item.id}>{item.code} - {item.description ?? item.grid_code ?? item.name}</option>)}</select></Field>{!form.cedex_location_id ? <><Field label="Face Manual"><select value={form.face} onChange={(event) => setDamageValue(setForm, "face", event.target.value)}><option value="">Pilih face</option>{["left", "right", "front", "door", "roof", "floor", "understructure"].map((item) => <option key={item} value={item}>{item}</option>)}</select></Field><Field label="Lokasi Internal Manual"><input value={form.internal_location} onChange={(event) => setDamageValue(setForm, "internal_location", event.target.value.toUpperCase())} /></Field><label className="field form-span-2"><span>Alasan Lokasi Manual</span><textarea rows={2} value={form.manual_location_reason} onChange={(event) => setDamageValue(setForm, "manual_location_reason", event.target.value)} /></label></> : null}</>}
    <Field label="Component Code *"><Select value={form.component_code_id} options={components} onChange={(value) => setDamageValue(setForm, "component_code_id", value)} /></Field>
    <Field label="Damage Code *"><Select value={form.damage_code_id} options={damageCodes} onChange={selectDamage} /></Field>
    <Field label="Dimension Profile"><select value={form.dimension_profile} onChange={(event) => selectDimensionProfile(event.target.value as DimensionProfile | "")}><option value="">Pilih jika dimensi diperlukan</option><option value="length_width">Panjang &times; Lebar</option><option value="length_width_depth">Panjang &times; Lebar &times; Kedalaman</option><option value="depth_only">Kedalaman saja</option><option value="quantity_only">Quantity saja</option><option value="linear_length">Panjang linear</option><option value="area">Area</option><option value="none">Tanpa dimensi</option><option value="manual_review">Manual Review</option></select></Field>
    {showLength ? <Field label="Length *"><input type="number" min="0" value={form.length} onChange={(event) => setDamageValue(setForm, "length", event.target.value)} /></Field> : null}
    {showWidth ? <Field label="Width *"><input type="number" min="0" value={form.width} onChange={(event) => setDamageValue(setForm, "width", event.target.value)} /></Field> : null}
    {showDepth ? <Field label="Depth / Thickness *"><input type="number" min="0" value={form.depth} onChange={(event) => setDamageValue(setForm, "depth", event.target.value)} /></Field> : null}
    {(showLength || showWidth || showDepth) ? <Field label="Dimension Unit *"><select value={form.unit} onChange={(event) => setDamageValue(setForm, "unit", event.target.value)}><option value="mm">mm</option><option value="cm">cm</option><option value="m">m</option></select></Field> : null}
    {showQuantity ? <><Field label="Quantity *"><input type="number" min="0" value={form.quantity} onChange={(event) => setDamageValue(setForm, "quantity", event.target.value)} /></Field>
    <Field label="Quantity Unit"><select value={form.quantity_unit} onChange={(event) => setDamageValue(setForm, "quantity_unit", event.target.value)}><option value="pc">pc</option><option value="m">m</option><option value="m²">m²</option><option value="set">set</option></select></Field>
    </> : null}
    <Field label="Action Repair Code *"><Select value={form.repair_code_id} options={repairs} onChange={(value) => setDamageValue(setForm, "repair_code_id", value)} /></Field>
    <Field label="Material Code"><Select value={form.material_code_id} options={materials} onChange={(value) => setDamageValue(setForm, "material_code_id", value)} /></Field>
    <Field label="Severity *"><Select value={severities.find((item) => item.code === form.severity)?.id ?? ""} options={severities} onChange={(value) => setDamageValue(setForm, "severity", severities.find((item) => item.id === value)?.code ?? "")} /></Field>
    <label className="field form-check"><input type="checkbox" checked={form.is_repair_required} onChange={(event) => setDamageValue(setForm, "is_repair_required", event.target.checked)} /> Perlu perbaikan</label>
    <label className="field form-check"><input type="checkbox" checked={form.is_cargo_worthy_impact} onChange={(event) => setDamageValue(setForm, "is_cargo_worthy_impact", event.target.checked)} /> Berdampak pada cargo worthy</label>
  </div>;
}

function DecisionRuleCard({ preview, loading }: { preview: DamageDecisionPreview | null; loading: boolean }) {
  if (loading) return <div className="alert alert-warning form-span-2">Mengevaluasi Tolerance &amp; Decision Rule...</div>;
  if (!preview) return <div className="alert alert-warning form-span-2">Lengkapi Location, Component, Damage, dan Dimension untuk melihat hasil Decision Rule.</div>;
  const tone = preview.matched ? "alert-success" : "alert-warning";
  return <div className={`decision-rule-preview ${tone} form-span-2`}>
    <strong>{preview.matched ? "Decision Rule ditemukan" : preview.configured ? "Belum ada rule yang cocok" : "Decision Rule belum dikonfigurasi"}</strong>
    <div className="detail-grid">
      <div><span>Inspection Reference</span><b>{[preview.inspection_reference_code, preview.inspection_reference_name].filter(Boolean).join(" - ") || "-"}</b></div>
      <div><span>Tolerance</span><b>{preview.tolerance || "-"}</b></div>
      <div><span>Measurement</span><b>{preview.measurement_value == null ? "-" : `${preview.measurement_value} ${preview.unit || ""}`.trim()}</b></div>
      <div><span>Decision Result</span><b>{decisionResultText(preview.decision_result)}</b></div>
      <div><span>Recommended Action</span><b>{preview.recommended_action_name || "-"}</b></div>
    </div>
    {preview.inspection_standard_reference ? <p>{preview.inspection_standard_reference}{preview.inspection_reference_clause ? ` - ${preview.inspection_reference_clause}` : ""}</p> : null}
    {preview.decision_reason ? <small>{preview.decision_reason}</small> : null}
  </div>;
}

function decisionResultText(value?: string | null) {
  const labels: Record<string, string> = {
    passed: "Passed",
    need_repair: "Need Repair",
    need_reinspection: "Need Reinspection",
    not_passed: "Not Passed",
    manual_review: "Manual Review"
  };
  return value ? labels[value] ?? value : "-";
}

function requiresRepair(row: SurveyDamage) {
  return Boolean(row.is_repair_required || row.repair_code_id);
}

function PhotoDialog({ damage, categories, open, isSaving, onClose, onSubmit }: { damage: SurveyDamage | null; categories: OptionItem[]; open: boolean; isSaving: boolean; onClose: () => void; onSubmit: (file: File | null, caption: string, category: string) => void }) {
  const [file, setFile] = useState<File | null>(null);
  const [caption, setCaption] = useState("");
  const [category, setCategory] = useState("");
  useEffect(() => { if (!open) return; const timer = window.setTimeout(() => { setFile(null); setCaption(""); setCategory(categories[0]?.code ?? ""); }, 0); return () => window.clearTimeout(timer); }, [categories, open]);
  return <FormDialog title={`Unggah Foto ${damage?.damage_no ?? ""}`} open={open} onClose={onClose} onSubmit={() => onSubmit(file, caption, category)} isSubmitting={isSaving} submitLabel="Unggah"><div className="form-grid"><Field label="Kategori Foto"><select value={category} onChange={(event) => setCategory(event.target.value)}><option value="">Pilih kategori</option>{categories.map((item) => <option key={item.id} value={item.code}>{item.code} - {item.label}</option>)}</select></Field><label className="field"><span>Ambil Foto</span><input type="file" accept="image/jpeg,image/png,image/webp" capture="environment" onChange={(e) => setFile(e.target.files?.[0] ?? null)} /></label><label className="field"><span>Pilih dari Galeri</span><input type="file" accept="image/jpeg,image/png,image/webp" onChange={(e) => setFile(e.target.files?.[0] ?? null)} /></label><label className="field form-span-2"><span>Caption</span><textarea rows={3} value={caption} onChange={(e) => setCaption(e.target.value)} /></label></div></FormDialog>;
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return <label className="field"><span>{label}</span>{children}</label>;
}

function Select({ value, options, onChange }: { value: string; options: OptionItem[]; onChange: (value: string) => void }) {
  return <select value={value} onChange={(e) => onChange(e.target.value)}><option value="">Select</option>{options.map((item) => <option key={item.id} value={item.id}>{item.code ? `${item.code} - ${item.label}` : item.label}</option>)}</select>;
}

function StickyActions({ children }: { children: React.ReactNode }) {
  return <div className="sticky-actions">{children}</div>;
}

function setDamageValue<K extends keyof DamageForm>(setter: Dispatch<SetStateAction<DamageForm>>, key: K, value: DamageForm[K]) {
  setter((current) => ({ ...current, [key]: value }));
}

function toDamagePayload(form: DamageForm) {
  return {
    face: form.face,
    internal_location: form.internal_location,
    cedex_location_id: form.cedex_location_id || undefined,
    manual_location_reason: form.manual_location_reason || undefined,
    component_code_id: form.component_code_id,
    damage_code_id: form.damage_code_id,
    repair_code_id: form.repair_code_id || undefined,
    material_code_id: form.material_code_id || undefined,
    responsibility_code_id: form.responsibility_code_id || undefined,
    severity: form.severity,
    dimension_profile: form.dimension_profile || undefined,
    location_selection_snapshot: form.location_selection_snapshot || undefined,
    quantity: form.quantity ? Number(form.quantity) : undefined,
    quantity_unit: form.quantity ? form.quantity_unit : undefined,
    length: form.length ? Number(form.length) : undefined,
    width: form.width ? Number(form.width) : undefined,
    depth: form.depth ? Number(form.depth) : undefined,
    unit: form.unit,
    is_repair_required: form.is_repair_required,
    is_cargo_worthy_impact: form.is_cargo_worthy_impact,
    remark: form.remark
  };
}

function validateDamageForm(form: DamageForm, requiresDimension: boolean) {
  const snapshot = form.location_selection_snapshot;
  if (snapshot && !form.cedex_location_id) return "Lokasi interaktif belum memiliki mapping CEDEX aktif. Ajukan kode baru atau pilih area yang sudah terpetakan.";
  if (!form.cedex_location_id && (!form.face || !form.internal_location.trim() || !form.manual_location_reason.trim())) return "Pilih Lokasi CEDEX atau isi Face, lokasi internal, dan alasan fallback manual.";
  if (!form.component_code_id || !form.damage_code_id || !form.repair_code_id) return "Component Code, Damage Code, dan Action Repair Code wajib dipilih.";
  if (!form.severity) return "Severity wajib dipilih dari mapping Customer dan Survey Type.";
  if (requiresDimension && !form.dimension_profile) return "Pilih Dimension Profile untuk jenis kerusakan ini.";
  const profile = form.dimension_profile;
  if (["length_width", "length_width_depth", "linear_length", "area"].includes(profile) && !form.length) return "Length wajib untuk Dimension Profile yang dipilih.";
  if (["length_width", "length_width_depth", "area"].includes(profile) && !form.width) return "Width wajib untuk Dimension Profile yang dipilih.";
  if (["length_width_depth", "depth_only"].includes(profile) && !form.depth) return "Depth wajib untuk Dimension Profile yang dipilih.";
  if (profile === "quantity_only" && (!form.quantity || !form.quantity_unit)) return "Quantity dan Quantity Unit wajib untuk Dimension Profile Quantity saja.";
  if ((form.length || form.width || form.depth) && !form.unit) return "Dimension Unit wajib dipilih jika dimensi diisi.";
  if (form.quantity && !form.quantity_unit) return "Quantity Unit wajib dipilih jika Quantity diisi.";
  const numericValues = [{ label: "Quantity", value: form.quantity }, { label: "Length", value: form.length }, { label: "Width", value: form.width }, { label: "Depth", value: form.depth }];
  for (const item of numericValues) {
    if (item.value !== "" && (!Number.isFinite(Number(item.value)) || Number(item.value) < 0)) return item.label + " tidak boleh negatif.";
  }
  return "";
}

function toOptionItems(rows: SurveyMasterOption[] = []): OptionItem[] {
  return rows.map((item) => ({ id: item.id, code: item.code, label: item.name }));
}

