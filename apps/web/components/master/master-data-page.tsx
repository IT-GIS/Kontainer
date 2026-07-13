"use client";

import { ClipboardList, Edit, Eye, Plus, RotateCcw, Search, Trash2, X } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import { masterResources, type MasterField, type MasterResource } from "@/constants/master-data";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";

type MasterRow = Record<string, string | number | boolean | null | undefined>;
type SelectOption = { value: string; label: string };
type RelationFieldState = { options: SelectOption[]; isLoading: boolean; error: string | null };
type RelationOptions = Record<string, RelationFieldState>;

type MasterDataPageProps = {
  resourceId: keyof typeof masterResources;
  endpointOverride?: string;
  fixedValues?: MasterRow;
  backHref?: string;
};

const defaultStatusOptions = [
  { label: "Aktif", value: "active" },
  { label: "Tidak Aktif", value: "inactive" }
];

export function MasterDataPage({ resourceId, endpointOverride, fixedValues, backHref }: MasterDataPageProps) {
  const resource = masterResources[resourceId];
  const resourceEndpoint = endpointOverride ?? resource.endpoint;
  const fixedPayload = useMemo(() => fixedValues ?? {}, [fixedValues]);
  const { accessToken, user } = useAuth();
  const [rows, setRows] = useState<MasterRow[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [dialogMode, setDialogMode] = useState<"create" | "edit" | null>(null);
  const [selected, setSelected] = useState<MasterRow | null>(null);
  const [detailRow, setDetailRow] = useState<MasterRow | null>(null);
  const [formData, setFormData] = useState<MasterRow>(() => ({ ...defaultFormData(resource), ...fixedPayload }));
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [surveyorUsers, setSurveyorUsers] = useState<SelectOption[]>([]);
  const [relationOptions, setRelationOptions] = useState<RelationOptions>({});
  const [relationSearch, setRelationSearch] = useState<Record<string, string>>({});

  const statusOptions = resource.statusOptions ?? defaultStatusOptions;
  const canCreate = can(user, `${resource.permissionModule}.create.all`);
  const canUpdate = can(user, `${resource.permissionModule}.update.all`);
  const canDelete = can(user, `${resource.permissionModule}.delete.all`);
  const fieldByName = useMemo(() => Object.fromEntries(resource.fields.map((field) => [field.name, field])), [resource.fields]);

  const loadRows = useCallback(async () => {
    if (!accessToken) {
      return;
    }
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<MasterRow>(
        `${resourceEndpoint}${buildQuery({ page, per_page: 10, search, status })}`,
        { accessToken }
      );
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil data.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, page, resourceEndpoint, search, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  useEffect(() => {
    setFormData({ ...defaultFormData(resource), ...fixedPayload });
    setSelected(null);
    setDetailRow(null);
    setPage(1);
    setSuccess(null);
    setFormError(null);
  }, [fixedPayload, resource, resourceEndpoint]);

  useEffect(() => {
    if (!accessToken || (resourceId !== "surveyors" && resourceId !== "fitness-surveyors")) return;
    void apiPaginated<{ id: string; name: string; email: string }>(
      "/users?page=1&per_page=100&status=active&role=surveyor&without_surveyor_profile=true",
      { accessToken }
    ).then((result) => setSurveyorUsers(result.rows.map((item) => ({ value: item.id, label: `${item.name} - ${item.email}` }))))
      .catch(() => setSurveyorUsers([]));
  }, [accessToken, resourceId]);

  useEffect(() => {
    if (!accessToken) return;
    const relationFields = resource.fields.filter((field) => field.relation);
    if (relationFields.length === 0) {
      setRelationOptions({});
      return;
    }
    setRelationOptions((current) => {
      const next = { ...current };
      for (const field of relationFields) {
        next[field.name] = { options: current[field.name]?.options ?? [], isLoading: true, error: null };
      }
      return next;
    });
    let active = true;
    const timer = window.setTimeout(() => {
      void Promise.all(relationFields.map(async (field) => {
        const relation = field.relation;
        if (!relation) return [field.name, { options: [], isLoading: false, error: null }] as const;
        try {
          const currentValue = String(formData[field.name] ?? selected?.[field.name] ?? "");
          const result = await apiPaginated<MasterRow>(`${relation.endpoint}${buildQuery({ page: 1, per_page: 20, search: relationSearch[field.name] ?? "", status: "active" })}`, { accessToken });
          const options = result.rows.map((row) => ({ value: String(row.id ?? ""), label: relationLabel(row, relation.labelKeys) })).filter((option) => option.value);
          if (currentValue && !options.some((option) => option.value === currentValue)) {
            try {
              const current = await apiData<MasterRow>(`${relation.endpoint}/${currentValue}`, { accessToken });
              options.unshift({ value: currentValue, label: relationLabel(current, relation.labelKeys) });
            } catch {
              options.unshift({ value: currentValue, label: `Data referensi tidak ditemukan: ${currentValue}` });
            }
          }
          return [field.name, { options, isLoading: false, error: null }] as const;
        } catch (err) {
          return [field.name, { options: [], isLoading: false, error: err instanceof Error ? err.message : "Gagal mengambil data referensi." }] as const;
        }
      })).then((entries) => {
        if (active) setRelationOptions((current) => ({ ...current, ...Object.fromEntries(entries) }));
      });
    }, 250);
    return () => { active = false; window.clearTimeout(timer); };
  }, [accessToken, resource.fields, relationSearch, selected, formData]);

  const columns = [
    ...resource.columns.map((column) => ({
      key: column.key,
      header: column.label,
      render: (row: MasterRow) => renderCell(displayValue(row[column.key], fieldByName[column.key], relationOptions), column.type)
    })),
    {
      key: "actions",
      header: "Aksi",
      render: (row: MasterRow) => (
        <div className="row-actions">
          <button className="icon-button" onClick={() => setDetailRow(row)} title="Detail">
            <Eye size={16} />
          </button>
          {resourceId === "fitness-checklist-templates" && row.id ? (
            <Link className="icon-button" href={`/fitness/master-data/checklist-templates/${row.id}/items`} title="Item checklist">
              <ClipboardList size={16} />
            </Link>
          ) : null}
          {canUpdate ? (
            <button className="icon-button" onClick={() => openEdit(row)} title="Edit">
              <Edit size={16} />
            </button>
          ) : null}
          {canDelete ? (
            <button className="icon-button danger-action" onClick={() => void handleDelete(row)} title="Nonaktifkan">
              <Trash2 size={16} />
            </button>
          ) : null}
        </div>
      )
    }
  ];

  function openCreate() {
    setSelected(null);
    setFormData({ ...defaultFormData(resource), ...fixedPayload });
    setDialogMode("create");
    setError(null);
    setFormError(null);
    setSuccess(null);
  }

  function openEdit(row: MasterRow) {
    setSelected(row);
    setFormData({ ...formDataFromRow(resource, row), ...fixedPayload });
    setDialogMode("edit");
    setError(null);
    setFormError(null);
    setSuccess(null);
  }

  function closeDialog() {
    setDialogMode(null);
    setSelected(null);
    setFormData({ ...defaultFormData(resource), ...fixedPayload });
    setFormError(null);
  }

  async function handleSubmit() {
    if (!accessToken || !dialogMode || isSubmitting) {
      return;
    }
    const validation = validateForm(resource, formData);
    if (validation) {
      setFormError(validation);
      return;
    }
    setIsSubmitting(true);
    setError(null);
    setFormError(null);
    setSuccess(null);
    try {
      const payload = serializePayload(resource, { ...formData, ...fixedPayload });
      if (dialogMode === "create") {
        await apiData(resourceEndpoint, { method: "POST", accessToken, body: JSON.stringify(payload) });
        setSuccess("Data berhasil dibuat.");
      } else if (selected?.id) {
        await apiData(`${resourceEndpoint}/${selected.id}`, { method: "PUT", accessToken, body: JSON.stringify(payload) });
        setSuccess("Data berhasil diperbarui.");
      }
      closeDialog();
      await loadRows();
    } catch (err) {
      setFormError(err instanceof Error ? err.message : "Gagal menyimpan data.");
    } finally {
      setIsSubmitting(false);
    }
  }

  async function handleDelete(row: MasterRow) {
    const recordName = recordLabel(resource, row);
    if (!accessToken || !row.id || !window.confirm(`Nonaktifkan ${recordName}? Data tetap bisa ditemukan melalui filter Tidak Aktif.`)) {
      return;
    }
    setError(null);
    setSuccess(null);
    try {
      await apiData(`${resourceEndpoint}/${row.id}`, { method: "DELETE", accessToken });
      setSuccess("Data berhasil dinonaktifkan.");
      await loadRows();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal menonaktifkan data.");
    }
  }

  return (
    <div className="page-stack">
      {backHref ? <Link className="secondary-button" href={backHref}>Kembali</Link> : null}
      <PageHeader
        title={resource.title}
        description={resource.description}
        action={canCreate ? { label: "Tambah", icon: Plus, onClick: openCreate } : undefined}
      />

      <div className="toolbar">
        <label className="search-box">
          <Search size={17} />
          <input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Cari" />
        </label>
        <select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}>
          <option value="">Semua Status</option>
          {statusOptions.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
        </select>
        <button className="secondary-button" onClick={() => void loadRows()} type="button"><RotateCcw size={16} /> Retry</button>
      </div>

      {success ? <div className="alert alert-success">{success}</div> : null}
      {error ? <div className="alert alert-danger">{error}</div> : null}

      <DataTable columns={columns} rows={rows} isLoading={isLoading} page={page} totalPages={totalPages} onPageChange={setPage} emptyText="Data belum tersedia." />

      {detailRow ? (
        <section className="workspace-panel">
          <div className="section-title-row">
            <div><Eye size={20} /><h2>Detail</h2></div>
            <button className="icon-button" onClick={() => setDetailRow(null)} title="Tutup detail"><X size={16} /></button>
          </div>
          <div className="detail-grid">
            {resource.fields.filter((field) => field.type !== "hidden").map((field) => (
              <div className="detail-item" key={field.name}>
                <span>{field.label}</span>
                <strong>{renderDetailValue(displayValue(detailRow[field.name], field, relationOptions), field.type)}</strong>
              </div>
            ))}
          </div>
        </section>
      ) : null}

      <FormDialog
        title={dialogMode === "create" ? `Tambah ${resource.title}` : `Edit ${resource.title}`}
        open={Boolean(dialogMode)}
        onClose={closeDialog}
        onSubmit={handleSubmit}
        isSubmitting={isSubmitting}
        submitLabel={dialogMode === "create" ? "Simpan" : "Update"}
      >
        {formError ? <div className="alert alert-danger">{formError}</div> : null}
        <div className="form-grid">
          {resource.fields.map((field) => (
            <FieldInput
              field={field}
              key={field.name}
              value={formData[field.name]}
              optionsOverride={(resourceId === "surveyors" || resourceId === "fitness-surveyors") && field.name === "user_id" ? surveyorUserOptions(surveyorUsers, selected) : relationOptions[field.name]?.options}
              relationState={relationOptions[field.name]}
              relationSearch={relationSearch[field.name] ?? ""}
              onRelationSearch={(value) => setRelationSearch((current) => ({ ...current, [field.name]: value }))}
              onChange={(value) => setFormData((current) => ({ ...current, [field.name]: value }))}
            />
          ))}
        </div>
      </FormDialog>
    </div>
  );
}

function FieldInput({ field, value, onChange, optionsOverride, relationState, relationSearch, onRelationSearch }: { field: MasterField; value: MasterRow[string]; onChange: (value: MasterRow[string]) => void; optionsOverride?: SelectOption[]; relationState?: RelationFieldState; relationSearch?: string; onRelationSearch?: (value: string) => void }) {
  if (field.type === "hidden") {
    return null;
  }

  if (field.type === "checkbox") {
    return (
      <label className="check-row form-check">
        <input checked={Boolean(value)} onChange={(event) => onChange(event.target.checked)} type="checkbox" />
        <span>{field.label}</span>
        {field.helpText ? <small className="muted-text">{field.helpText}</small> : null}
      </label>
    );
  }

  const inputType = field.type === "decimal" ? "number" : field.type ?? "text";
  const options = optionsOverride ?? field.options;
  const isRelation = Boolean(field.relation);

  return (
    <label className="field">
      <span>{field.label}{field.required ? " *" : ""}</span>
      {isRelation ? (
        <>
          <input value={relationSearch ?? ""} onChange={(event) => onRelationSearch?.(event.target.value)} placeholder="Cari data referensi" type="search" />
          <select value={String(value ?? "")} onChange={(event) => onChange(event.target.value)} required={field.required}>
            <option value="">Pilih</option>
            {options?.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
          </select>
          {relationState?.isLoading ? <small className="muted-text">Memuat referensi...</small> : null}
          {relationState?.error ? <small className="alert-danger">{relationState.error}</small> : null}
        </>
      ) : field.type === "select" || optionsOverride ? (
        <select value={String(value ?? "")} onChange={(event) => onChange(event.target.value)} required={field.required}>
          <option value="">Pilih</option>
          {options?.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
        </select>
      ) : field.type === "textarea" ? (
        <textarea value={String(value ?? "")} onChange={(event) => onChange(event.target.value)} required={field.required} maxLength={field.maxLength} />
      ) : (
        <input
          value={String(value ?? "")}
          onChange={(event) => onChange(field.type === "number" || field.type === "decimal" ? numberOrEmpty(event.target.value) : event.target.value)}
          required={field.required}
          type={inputType}
          min={field.min}
          max={field.max}
          step={field.step}
          pattern={field.pattern}
          maxLength={field.maxLength}
        />
      )}
      {field.helpText ? <small className="muted-text">{field.helpText}</small> : null}
    </label>
  );
}

function surveyorUserOptions(options: SelectOption[], selected: MasterRow | null) {
  const currentID = String(selected?.user_id ?? "");
  if (!currentID || options.some((option) => option.value === currentID)) return options;
  return [{ value: currentID, label: `${String(selected?.name ?? "User saat ini")} - profil saat ini` }, ...options];
}

function renderDetailValue(value: MasterRow[string], type?: MasterField["type"]) {
  if (value === undefined || value === null || value === "") return "-";
  if (type === "checkbox") return value ? "Ya" : "Tidak";
  return String(value);
}

function renderCell(value: MasterRow[string], type?: "status" | "boolean") {
  if (type === "status") {
    const label = String(value || "inactive");
    const normalized = label.toLowerCase();
    const tone = normalized === "active" ? "success" : normalized === "draft" ? "warning" : "neutral";
    const display = normalized === "active" ? "Aktif" : normalized === "inactive" ? "Tidak Aktif" : normalized === "draft" ? "Draf" : label;
    return <StatusBadge tone={tone}>{display}</StatusBadge>;
  }
  if (type === "boolean") {
    return <StatusBadge tone={value ? "success" : "neutral"}>{value ? "Ya" : "Tidak"}</StatusBadge>;
  }
  return value === undefined || value === null || value === "" ? <span className="muted-text">-</span> : String(value);
}

function defaultFormData(resource: MasterResource): MasterRow {
  const data: MasterRow = {};
  for (const field of resource.fields) {
    if (field.defaultValue !== undefined) {
      data[field.name] = field.defaultValue;
    } else if (field.type === "checkbox") {
      data[field.name] = false;
    } else if (field.name === "status") {
      data[field.name] = "active";
    } else {
      data[field.name] = "";
    }
  }
  return data;
}

function formDataFromRow(resource: MasterResource, row: MasterRow): MasterRow {
  const data = defaultFormData(resource);
  for (const field of resource.fields) {
    data[field.name] = row[field.name] ?? data[field.name];
  }
  return data;
}

function serializePayload(resource: MasterResource, data: MasterRow) {
  const payload: MasterRow = {};
  for (const field of resource.fields) {
    const value = data[field.name];
    if (field.type === "hidden" && value === undefined) continue;
    if (value === "" || value === undefined) {
      payload[field.name] = field.required ? "" : field.clearValue ?? null;
      continue;
    }
    payload[field.name] = typeof value === "string" && field.trim !== false ? value.trim() : value;
  }
  return payload;
}

function validateForm(resource: MasterResource, data: MasterRow) {
  for (const field of resource.fields) {
    if (!field.required) continue;
    const value = data[field.name];
    if (value === undefined || value === null || String(value).trim() === "") {
      return `${field.label} wajib diisi.`;
    }
  }
  return null;
}

function numberOrEmpty(value: string) {
  if (value === "") return "";
  return Number(value);
}

function displayValue(value: MasterRow[string], field: MasterField | undefined, relationOptions: RelationOptions) {
  if (!field?.relation || value === undefined || value === null || value === "") return value;
  return relationOptions[field.name]?.options.find((option) => option.value === String(value))?.label ?? `Data referensi tidak ditemukan: ${value}`;
}

function relationLabel(row: MasterRow, labelKeys: string[]) {
  const label = labelKeys.map((key) => String(row[key] ?? "").trim()).filter(Boolean).join(" - ");
  return label || `Data referensi tidak ditemukan: ${String(row.id ?? "")}`;
}

function recordLabel(resource: MasterResource, row: MasterRow) {
  const firstTextField = resource.fields.find((field) => field.name !== "status" && field.type !== "hidden" && typeof row[field.name] === "string" && String(row[field.name]).trim() !== "");
  return firstTextField ? String(row[firstTextField.name]) : "data ini";
}
