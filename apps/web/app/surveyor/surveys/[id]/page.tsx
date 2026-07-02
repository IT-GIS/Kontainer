"use client";

import { Camera, Check, Grid3X3, ImagePlus, Plus, Save, Send, Trash2, TriangleAlert } from "lucide-react";
import { useParams } from "next/navigation";
import { useCallback, useEffect, useMemo, useState } from "react";
import type { Dispatch, SetStateAction } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PhotoEvidence } from "@/components/surveys/photo-evidence";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import { loadOptions } from "@/lib/options";
import type { OptionItem } from "@/types/jobs";
import type { ChecklistItem, SheetFace, SheetLocation, SurveyDamage, SurveyDetail, SurveyGeneralInfo, SurveyPhoto } from "@/types/surveyor";

const tabs = ["General Info", "Checklist", "Survey Sheet", "Damage List", "Photos", "Preview", "Submit"] as const;
type Tab = (typeof tabs)[number];

type DamageForm = {
  id?: string;
  face: string;
  internal_location: string;
  component_code_id: string;
  damage_code_id: string;
  repair_code_id: string;
  severity: string;
  quantity: string;
  length: string;
  width: string;
  depth: string;
  unit: string;
  is_repair_required: boolean;
  is_cargo_worthy_impact: boolean;
  remark: string;
};

const emptyDamage: DamageForm = {
  face: "left",
  internal_location: "L1",
  component_code_id: "",
  damage_code_id: "",
  repair_code_id: "",
  severity: "minor",
  quantity: "1",
  length: "",
  width: "",
  depth: "",
  unit: "cm",
  is_repair_required: false,
  is_cargo_worthy_impact: false,
  remark: ""
};

export default function SurveyDetailPage() {
  return <ProtectedRoute><AppShell title="Survey Detail"><SurveyDetailContent /></AppShell></ProtectedRoute>;
}

function SurveyDetailContent() {
  const params = useParams<{ id: string }>();
  const { accessToken } = useAuth();
  const [survey, setSurvey] = useState<SurveyDetail | null>(null);
  const [activeTab, setActiveTab] = useState<Tab>("General Info");
  const [sheetFaces, setSheetFaces] = useState<SheetFace[]>([]);
  const [activeFace, setActiveFace] = useState("left");
  const [general, setGeneral] = useState<SurveyGeneralInfo>({});
  const [checklist, setChecklist] = useState<ChecklistItem[]>([]);
  const [components, setComponents] = useState<OptionItem[]>([]);
  const [damageCodes, setDamageCodes] = useState<OptionItem[]>([]);
  const [repairs, setRepairs] = useState<OptionItem[]>([]);
  const [damageDialog, setDamageDialog] = useState(false);
  const [damageForm, setDamageForm] = useState<DamageForm>(emptyDamage);
  const [photoDamage, setPhotoDamage] = useState<SurveyDamage | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  const readonly = survey ? !["draft", "need_revision"].includes(survey.status) : true;
  const activeFaceData = useMemo(() => sheetFaces.find((face) => face.face === activeFace) ?? sheetFaces[0], [sheetFaces, activeFace]);

  const loadSurvey = useCallback(async () => {
    if (!accessToken || !params.id) return;
    setError(null);
    try {
      const [detail, sheet] = await Promise.all([
        apiData<SurveyDetail>(`/surveys/${params.id}/preview`, { accessToken }),
        apiData<{ faces: SheetFace[] }>(`/surveys/${params.id}/sheet`, { accessToken })
      ]);
      setSurvey(detail);
      setGeneral(detail.general_info ?? {});
      setChecklist(detail.checklist ?? []);
      setSheetFaces(sheet.faces ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil survey.");
    }
  }, [accessToken, params.id]);

  useEffect(() => { const timer = window.setTimeout(() => void loadSurvey(), 0); return () => window.clearTimeout(timer); }, [loadSurvey]);
  useEffect(() => {
    if (!accessToken) return;
    void Promise.all([
      loadOptions(accessToken, "/master/cedex/components", "name", "code"),
      loadOptions(accessToken, "/master/cedex/damages", "name", "code"),
      loadOptions(accessToken, "/master/cedex/repairs", "name", "code")
    ]).then(([componentRows, damageRows, repairRows]) => {
      setComponents(componentRows);
      setDamageCodes(damageRows);
      setRepairs(repairRows);
    }).catch(() => undefined);
  }, [accessToken]);

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

  function openNewDamage(location?: SheetLocation) {
    setDamageForm({ ...emptyDamage, face: activeFaceData?.face ?? "left", internal_location: location?.code ?? "L1" });
    setDamageDialog(true);
  }

  function openEditDamage(row: SurveyDamage) {
    setDamageForm({
      ...emptyDamage,
      id: row.id,
      face: row.face,
      internal_location: row.internal_location,
      component_code_id: row.component_id ?? "",
      damage_code_id: row.damage_code_id ?? "",
      severity: row.severity,
      quantity: String(row.quantity ?? 1),
      length: row.length ? String(row.length) : "",
      width: row.width ? String(row.width) : "",
      depth: row.depth ? String(row.depth) : "",
      unit: row.unit ?? "cm",
      remark: row.remark ?? ""
    });
    setDamageDialog(true);
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
      await apiData(`/surveys/${params.id}/checklist`, { method: "PUT", accessToken, body: JSON.stringify({ items: checklist.map((item) => ({ item_key: item.item_key, value: item.value ?? "", note: item.note ?? "" })) }) });
      setMessage("Checklist tersimpan.");
    });
  }

  async function saveDamage() {
    if (!accessToken) return;
    await runSave(async () => {
      const body = JSON.stringify(toDamagePayload(damageForm));
      if (damageForm.id) {
        await apiData(`/survey-damages/${damageForm.id}`, { method: "PUT", accessToken, body });
      } else {
        await apiData(`/surveys/${params.id}/damages`, { method: "POST", accessToken, body });
      }
      setDamageDialog(false);
      setDamageForm(emptyDamage);
      setMessage("Damage tersimpan.");
    });
  }

  async function deleteDamage(row: SurveyDamage) {
    if (!accessToken) return;
    await runSave(async () => {
      await apiData(`/survey-damages/${row.id}`, { method: "DELETE", accessToken });
      setMessage("Damage dihapus.");
    });
  }

  async function uploadDamagePhoto(file: File | null, caption: string) {
    if (!accessToken || !photoDamage || !file) return;
    await runSave(async () => {
      const form = new FormData();
      form.set("file", file);
      form.set("caption", caption);
      form.set("photo_type", "damage");
      await apiData(`/survey-damages/${photoDamage.id}/photos`, { method: "POST", accessToken, body: form });
      setPhotoDamage(null);
      setMessage("Foto evidence tersimpan.");
    });
  }

  async function submitSurvey() {
    if (!accessToken) return;
    await runSave(async () => {
      await apiData(`/surveys/${params.id}/submit`, { method: "POST", accessToken, body: JSON.stringify({ final_remark: general.general_remark ?? "" }) });
      setMessage("Survey berhasil disubmit.");
      setActiveTab("Preview");
    });
  }

  if (!survey) return <div className="center-screen">Memuat survey...</div>;

  return (
    <div className="page-stack">
      <PageHeader title={`Survey: ${survey.survey_no}`} description={`Container: ${survey.container_no} - ${survey.customer_name} - ${survey.location_name}`} />
      <div className="survey-strip">
        <StatusBadge tone={survey.status === "draft" ? "warning" : survey.status === "submitted" ? "neutral" : survey.status === "need_revision" ? "danger" : "success"}>{survey.status.toUpperCase()}</StatusBadge>
        <span>{survey.survey_type_name}</span><span>{survey.surveyor_name}</span><strong>{readonly ? "Readonly" : "Editable draft"}</strong>
      </div>
      {error ? <div className="alert alert-danger">{error}</div> : null}
      {message ? <div className="alert alert-success">{message}</div> : null}
      <div className="tab-list">{tabs.map((tab) => <button className={activeTab === tab ? "tab-active" : ""} key={tab} onClick={() => setActiveTab(tab)}>{tab}</button>)}</div>
      {activeTab === "General Info" ? <GeneralTab general={general} readonly={readonly} isSaving={isSaving} onChange={setGeneral} onSave={saveGeneral} /> : null}
      {activeTab === "Checklist" ? <ChecklistTab items={checklist} readonly={readonly} isSaving={isSaving} onChange={setChecklist} onSave={saveChecklist} /> : null}
      {activeTab === "Survey Sheet" ? <SheetTab faces={sheetFaces} activeFace={activeFace} activeFaceData={activeFaceData} damages={survey.damages ?? []} onFace={setActiveFace} onAdd={openNewDamage} /> : null}
      {activeTab === "Damage List" ? <DamageList rows={survey.damages ?? []} readonly={readonly} onAdd={() => openNewDamage()} onEdit={openEditDamage} onDelete={deleteDamage} onPhoto={setPhotoDamage} /> : null}
      {activeTab === "Photos" ? <PhotosTab damages={survey.damages ?? []} photos={survey.photos ?? []} readonly={readonly} onPhoto={setPhotoDamage} /> : null}
      {activeTab === "Preview" ? <PreviewTab survey={survey} /> : null}
      {activeTab === "Submit" ? <SubmitTab survey={survey} readonly={readonly} isSaving={isSaving} onSubmit={submitSurvey} /> : null}
      <FormDialog title={damageForm.id ? "Edit Damage" : "Tambah Damage"} open={damageDialog} onClose={() => setDamageDialog(false)} onSubmit={saveDamage} isSubmitting={isSaving} submitLabel="Save Damage">
        <DamageFormFields form={damageForm} setForm={setDamageForm} components={components} damageCodes={damageCodes} repairs={repairs} />
      </FormDialog>
      <PhotoDialog damage={photoDamage} open={Boolean(photoDamage)} onClose={() => setPhotoDamage(null)} onSubmit={uploadDamagePhoto} isSaving={isSaving} />
    </div>
  );
}

function GeneralTab({ general, readonly, isSaving, onChange, onSave }: { general: SurveyGeneralInfo; readonly: boolean; isSaving: boolean; onChange: (value: SurveyGeneralInfo) => void; onSave: () => void }) {
  return <section className="workspace-panel"><div className="form-grid">
    <Field label="Cargo Status"><select disabled={readonly} value={general.cargo_status ?? "unknown"} onChange={(e) => onChange({ ...general, cargo_status: e.target.value })}><option value="unknown">unknown</option><option value="empty">empty</option><option value="laden">laden</option></select></Field>
    <Field label="Seal No"><input disabled={readonly} value={general.seal_no ?? ""} onChange={(e) => onChange({ ...general, seal_no: e.target.value })} /></Field>
    <Field label="Truck No"><input disabled={readonly} value={general.truck_no ?? ""} onChange={(e) => onChange({ ...general, truck_no: e.target.value })} /></Field>
    <Field label="Driver Name"><input disabled={readonly} value={general.driver_name ?? ""} onChange={(e) => onChange({ ...general, driver_name: e.target.value })} /></Field>
    <Field label="Chassis No"><input disabled={readonly} value={general.chassis_no ?? ""} onChange={(e) => onChange({ ...general, chassis_no: e.target.value })} /></Field>
    <Field label="CSC Plate"><input disabled={readonly} value={general.csc_plate_status ?? ""} onChange={(e) => onChange({ ...general, csc_plate_status: e.target.value })} /></Field>
    <Field label="Door Status"><input disabled={readonly} value={general.door_status ?? ""} onChange={(e) => onChange({ ...general, door_status: e.target.value })} /></Field>
    <Field label="General Condition"><select disabled={readonly} value={general.general_condition ?? ""} onChange={(e) => onChange({ ...general, general_condition: e.target.value })}><option value="">Select</option><option value="sound">sound</option><option value="damage">damage</option><option value="dirty">dirty</option></select></Field>
    <Field label="Weather"><input disabled={readonly} value={general.weather ?? ""} onChange={(e) => onChange({ ...general, weather: e.target.value })} /></Field>
    <label className="field form-span-2"><span>General Remark</span><textarea disabled={readonly} rows={3} value={general.general_remark ?? ""} onChange={(e) => onChange({ ...general, general_remark: e.target.value })} /></label>
  </div><StickyActions><button className="primary-button" disabled={readonly || isSaving} onClick={onSave}><Save size={17} /><span>Save Draft</span></button></StickyActions></section>;
}

function ChecklistTab({ items, readonly, isSaving, onChange, onSave }: { items: ChecklistItem[]; readonly: boolean; isSaving: boolean; onChange: (value: ChecklistItem[]) => void; onSave: () => void }) {
  return <section className="workspace-panel checklist-list">{items.map((item, index) => <div className="check-row" key={item.item_key}><div><strong>{item.item_label ?? item.item_key}</strong>{item.is_critical ? <span>Critical</span> : null}</div><div className="segmented-control">{["yes", "no", "na"].map((value) => <button disabled={readonly} className={item.value === value ? "selected" : ""} key={value} onClick={() => onChange(items.map((row, rowIndex) => rowIndex === index ? { ...row, value } : row))}>{value.toUpperCase()}</button>)}</div></div>)}<StickyActions><button className="primary-button" disabled={readonly || isSaving} onClick={onSave}><Check size={17} /><span>Save Checklist</span></button></StickyActions></section>;
}

function SheetTab({ faces, activeFace, activeFaceData, damages, onFace, onAdd }: { faces: SheetFace[]; activeFace: string; activeFaceData?: SheetFace; damages: SurveyDamage[]; onFace: (face: string) => void; onAdd: (location?: SheetLocation) => void }) {
  return <section className="workspace-panel survey-sheet-layout"><div className="face-selector">{faces.map((face) => <button className={activeFace === face.face ? "selected" : ""} key={face.face} onClick={() => onFace(face.face)}>{face.label}</button>)}</div><div className="sheet-grid-wrap"><div className="sheet-grid">{(activeFaceData?.locations ?? []).map((location) => <button className={`sheet-cell ${location.has_damage ? "has-damage" : ""}`} key={location.code} onClick={() => onAdd(location)}><Grid3X3 size={15} /><span>{location.label}</span>{location.damage_markers.map((marker) => <strong key={marker.damage_id}>{marker.damage_no}</strong>)}</button>)}</div><aside className="damage-summary"><div className="section-title-row"><h3>Damage Summary</h3><button className="secondary-button" onClick={() => onAdd()}><Plus size={16} /><span>Add Damage</span></button></div>{damages.length === 0 ? <p className="muted-text">Belum ada damage.</p> : damages.map((damage) => <p key={damage.id}>{damage.damage_no} {damage.face} {damage.internal_location} {damage.damage_name ?? damage.damage_code}</p>)}</aside></div><div className="legend-row"><span>Minor</span><span>Major/Critical</span><span>Photo Required</span></div></section>;
}

function DamageList({ rows, readonly, onAdd, onEdit, onDelete, onPhoto }: { rows: SurveyDamage[]; readonly: boolean; onAdd: () => void; onEdit: (row: SurveyDamage) => void; onDelete: (row: SurveyDamage) => void; onPhoto: (row: SurveyDamage) => void }) {
  return <section className="workspace-panel"><div className="section-title-row"><h2>Damage List</h2><button className="primary-button" disabled={readonly} onClick={onAdd}><Plus size={17} /><span>Add Damage</span></button></div><DataTable rows={rows} columns={[
    { key: "damage_no", header: "Damage No", render: (row) => row.damage_no },
    { key: "location", header: "Location", render: (row) => `${row.face} ${row.internal_location}` },
    { key: "component", header: "Component", render: (row) => row.component_name ?? row.component_code ?? "-" },
    { key: "damage", header: "Damage", render: (row) => row.damage_name ?? row.damage_code ?? "-" },
    { key: "size", header: "Size", render: (row) => [row.length, row.width, row.depth].filter(Boolean).join("x") || "-" },
    { key: "severity", header: "Severity", render: (row) => <StatusBadge tone={row.severity === "minor" ? "warning" : "danger"}>{row.severity.toUpperCase()}</StatusBadge> },
    { key: "photo", header: "Photo", render: (row) => <button className="secondary-button table-action" disabled={readonly} onClick={() => onPhoto(row)}><Camera size={16} /><span>{row.photo_count ?? 0}</span></button> },
    { key: "actions", header: "Action", render: (row) => <div className="table-actions"><button className="secondary-button table-action" disabled={readonly} onClick={() => onEdit(row)}>Edit</button><button className="icon-button" disabled={readonly} onClick={() => void onDelete(row)} title="Delete damage"><Trash2 size={16} /></button></div> }
  ]} /></section>;
}

function PhotosTab({ damages, photos, readonly, onPhoto }: { damages: SurveyDamage[]; photos: SurveyPhoto[]; readonly: boolean; onPhoto: (row: SurveyDamage) => void }) {
  return <section className="workspace-panel photo-list">{damages.length === 0 ? <p className="muted-text">Belum ada damage photo.</p> : null}{damages.map((damage) => { const damagePhotos = photos.filter((photo) => photo.damage_id === damage.id); return <div className="photo-section" key={damage.id}><div className="section-title-row"><div><h3>{damage.damage_no} - {damage.face} {damage.internal_location}</h3><p className="muted-text">{damage.damage_name ?? damage.damage_code}</p></div><button className="secondary-button" disabled={readonly} onClick={() => onPhoto(damage)}><ImagePlus size={17} /><span>Upload</span></button></div>{damagePhotos.length === 0 ? <div className="alert alert-danger">Photo Required</div> : <div className="photo-grid">{damagePhotos.map((photo) => <PhotoEvidence id={photo.id} name={photo.original_file_name} caption={photo.caption} key={photo.id} />)}</div>}</div>; })}</section>;
}

function PreviewTab({ survey }: { survey: SurveyDetail }) {
  const warnings = survey.warnings ?? [];
  return <section className="workspace-panel preview-stack"><div className="detail-grid"><div><span>Survey No</span><strong>{survey.survey_no}</strong></div><div><span>Container</span><strong>{survey.container_no}</strong></div><div><span>Recommendation</span><strong>{survey.survey_result_recommendation ?? "-"}</strong></div><div><span>Can Submit</span><strong>{survey.can_submit ? "Yes" : "No"}</strong></div></div>{warnings.length === 0 ? <div className="alert alert-success">Validasi submit terlihat lengkap.</div> : warnings.map((warning) => <div className="alert alert-danger" key={warning.code}><TriangleAlert size={16} />{warning.message}</div>)}</section>;
}

function SubmitTab({ survey, readonly, isSaving, onSubmit }: { survey: SurveyDetail; readonly: boolean; isSaving: boolean; onSubmit: () => void }) {
  const warnings = survey.warnings ?? [];
  return <section className="workspace-panel submit-panel"><h2>Submit Survey</h2>{warnings.length > 0 ? warnings.map((warning) => <div className="alert alert-danger" key={warning.code}>{warning.message}</div>) : <div className="alert alert-success">Survey siap dikirim ke Supervisor.</div>}<button className="primary-button" disabled={readonly || isSaving || warnings.length > 0} onClick={onSubmit}><Send size={17} /><span>Submit Survey</span></button></section>;
}

function DamageFormFields({ form, setForm, components, damageCodes, repairs }: { form: DamageForm; setForm: Dispatch<SetStateAction<DamageForm>>; components: OptionItem[]; damageCodes: OptionItem[]; repairs: OptionItem[] }) {
  return <div className="form-grid"><Field label="Face"><select value={form.face} onChange={(e) => setDamageValue(setForm, "face", e.target.value)}>{["left", "right", "front", "door", "roof", "floor", "understructure"].map((item) => <option key={item} value={item}>{item}</option>)}</select></Field><Field label="Location"><input value={form.internal_location} onChange={(e) => setDamageValue(setForm, "internal_location", e.target.value.toUpperCase())} /></Field><Field label="Component"><Select value={form.component_code_id} options={components} onChange={(value) => setDamageValue(setForm, "component_code_id", value)} /></Field><Field label="Damage Type"><Select value={form.damage_code_id} options={damageCodes} onChange={(value) => setDamageValue(setForm, "damage_code_id", value)} /></Field><Field label="Repair"><Select value={form.repair_code_id} options={repairs} onChange={(value) => setDamageValue(setForm, "repair_code_id", value)} /></Field><Field label="Severity"><select value={form.severity} onChange={(e) => setDamageValue(setForm, "severity", e.target.value)}><option value="minor">minor</option><option value="major">major</option><option value="critical">critical</option></select></Field><Field label="Quantity"><input type="number" value={form.quantity} onChange={(e) => setDamageValue(setForm, "quantity", e.target.value)} /></Field><Field label="Unit"><select value={form.unit} onChange={(e) => setDamageValue(setForm, "unit", e.target.value)}><option value="cm">cm</option><option value="mm">mm</option><option value="m">m</option></select></Field><Field label="Length"><input type="number" value={form.length} onChange={(e) => setDamageValue(setForm, "length", e.target.value)} /></Field><Field label="Width"><input type="number" value={form.width} onChange={(e) => setDamageValue(setForm, "width", e.target.value)} /></Field><Field label="Depth"><input type="number" value={form.depth} onChange={(e) => setDamageValue(setForm, "depth", e.target.value)} /></Field><label className="field form-check"><input type="checkbox" checked={form.is_repair_required} onChange={(e) => setDamageValue(setForm, "is_repair_required", e.target.checked)} /> Repair Required</label><label className="field form-check"><input type="checkbox" checked={form.is_cargo_worthy_impact} onChange={(e) => setDamageValue(setForm, "is_cargo_worthy_impact", e.target.checked)} /> Cargo Worthy Impact</label><label className="field form-span-2"><span>Remark</span><textarea rows={3} value={form.remark} onChange={(e) => setDamageValue(setForm, "remark", e.target.value)} /></label></div>;
}

function PhotoDialog({ damage, open, isSaving, onClose, onSubmit }: { damage: SurveyDamage | null; open: boolean; isSaving: boolean; onClose: () => void; onSubmit: (file: File | null, caption: string) => void }) {
  const [file, setFile] = useState<File | null>(null);
  const [caption, setCaption] = useState("");
  useEffect(() => { if (!open) return; const timer = window.setTimeout(() => { setFile(null); setCaption(""); }, 0); return () => window.clearTimeout(timer); }, [open]);
  return <FormDialog title={`Upload Photo ${damage?.damage_no ?? ""}`} open={open} onClose={onClose} onSubmit={() => onSubmit(file, caption)} isSubmitting={isSaving} submitLabel="Upload"><div className="form-grid"><label className="field form-span-2"><span>Photo Evidence (JPG, PNG, WEBP)</span><input type="file" accept="image/jpeg,image/png,image/webp" onChange={(e) => setFile(e.target.files?.[0] ?? null)} /></label><label className="field form-span-2"><span>Caption</span><textarea rows={3} value={caption} onChange={(e) => setCaption(e.target.value)} /></label></div></FormDialog>;
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
    cedex_location_code: form.internal_location,
    component_code_id: form.component_code_id,
    damage_code_id: form.damage_code_id,
    repair_code_id: form.repair_code_id || undefined,
    severity: form.severity,
    quantity: form.quantity ? Number(form.quantity) : undefined,
    length: form.length ? Number(form.length) : undefined,
    width: form.width ? Number(form.width) : undefined,
    depth: form.depth ? Number(form.depth) : undefined,
    unit: form.unit,
    is_repair_required: form.is_repair_required,
    is_cargo_worthy_impact: form.is_cargo_worthy_impact,
    remark: form.remark
  };
}

