"use client";

import { ClipboardList, Edit, Eye, Plus, RotateCcw, Search, Trash2, X } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
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
  const [searchInput, setSearchInput] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
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
  const [relationOptions, setRelationOptions] = useState<RelationOptions>({});
  const [relationSearch, setRelationSearch] = useState<Record<string, string>>({});
  const listRequestSeq = useRef(0);
  const relationRequestSeq = useRef(0);

  const statusOptions = resource.statusOptions ?? defaultStatusOptions;
  const canCreate = can(user, `${resource.permissionModule}.create.all`);
  const canUpdate = can(user, `${resource.permissionModule}.update.all`);
  const canDelete = can(user, `${resource.permissionModule}.delete.all`);
  const relationFields = useMemo(() => resource.fields.filter((field) => field.relation), [resource.fields]);
  const selectedRelationValuesKey = relationFields.map((field) => String(formData[field.name] ?? selected?.[field.name] ?? "")).join("|");

  const loadRows = useCallback(async () => {
    if (!accessToken) {
      return;
    }
    const requestID = ++listRequestSeq.current;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<MasterRow>(
        `${resourceEndpoint}${buildQuery({ page, per_page: 10, search: debouncedSearch, status })}`,
        { accessToken }
      );
      if (requestID !== listRequestSeq.current) return;
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      if (requestID === listRequestSeq.current) {
        setError(err instanceof Error ? err.message : "Gagal mengambil data.");
      }
    } finally {
      if (requestID === listRequestSeq.current) {
        setIsLoading(false);
      }
    }
  }, [accessToken, debouncedSearch, page, resourceEndpoint, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setPage(1);
      setDebouncedSearch(searchInput);
    }, 350);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    void loadRows();
  }, [loadRows]);

  useEffect(() => {
    setFormData({ ...defaultFormData(resource), ...fixedPayload });
    setSelected(null);
    setDetailRow(null);
    setPage(1);
    setSearchInput("");
    setDebouncedSearch("");
    setSuccess(null);
    setFormError(null);
    setRelationSearch({});
    setRelationOptions({});
  }, [fixedPayload, resource, resourceEndpoint]);

  useEffect(() => {
    if (!accessToken || !dialogMode || relationFields.length === 0) {
      if (!dialogMode) setRelationOptions({});
      return;
    }
    const requestID = ++relationRequestSeq.current;
    setRelationOptions((current) => {
      const next = { ...current };
      for (const field of relationFields) {
        next[field.name] = { options: current[field.name]?.options ?? [], isLoading: true, error: null };
      }
      return next;
    });

    const timer = window.setTimeout(() => {
      void Promise.all(relationFields.map(async (field) => {
        const relation = field.relation;
        if (!relation) return [field.name, { options: [], isLoading: false, error: null }] as const;
        try {
          const currentValue = String(formData[field.name] ?? selected?.[field.name] ?? "");
          const query: Record<string, string | number> = { page: 1, per_page: 20, ...(relation.query ?? {}), search: relationSearch[field.name] ?? "" };
          if (!relation.query?.status) query.status = "active";
          const result = await apiPaginated<MasterRow>(`${relation.endpoint}${buildQuery(query)}`, { accessToken });
          const options = result.rows.map((row) => ({ value: String(row.id ?? ""), label: relationLabel(row, relation.labelKeys) })).filter((option) => option.value);
          if (currentValue && !options.some((option) => option.value === currentValue)) {
            const currentOption = await currentRelationOption(field, currentValue, selected, accessToken);
            options.unshift(currentOption);
          }
          return [field.name, { options, isLoading: false, error: null }] as const;
        } catch (err) {
          return [field.name, { options: [], isLoading: false, error: err instanceof Error ? err.message : "Gagal mengambil data referensi." }] as const;
        }
      })).then((entries) => {
        if (requestID === relationRequestSeq.current) {
          setRelationOptions((current) => ({ ...current, ...Object.fromEntries(entries) }));
        }
      });
    }, 300);

    return () => {
      window.clearTimeout(timer);
    };
  }, [accessToken, dialogMode, relationFields, relationSearch, resourceEndpoint, selected, selectedRelationValuesKey]);

  const columns = [
    ...resource.columns.map((column) => ({
      key: column.key,
      header: column.label,
      render: (row: MasterRow) => renderCell(row[column.key], column.type)
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
          {canUpdate && isInactiveRow(resource, row) ? (
            <button className="icon-button" onClick={() => void handleActivate(row)} title="Aktifkan">
              <RotateCcw size={16} />
            </button>
          ) : null}
          {canDelete && !isInactiveRow(resource, row) ? (
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
    setRelationSearch({});
    setDialogMode("create");
    setError(null);
    setFormError(null);
    setSuccess(null);
  }

  function openEdit(row: MasterRow) {
    setSelected(row);
    setFormData({ ...formDataFromRow(resource, row), ...fixedPayload });
    setRelationSearch({});
    setDialogMode("edit");
    setError(null);
    setFormError(null);
    setSuccess(null);
  }

  function closeDialog() {
    setDialogMode(null);
    setSelected(null);
    setFormData({ ...defaultFormData(resource), ...fixedPayload });
    setRelationSearch({});
    setRelationOptions({});
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
      const payload = serializePayload(resource, { ...formData, ...fixedPayload }, dialogMode);
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
    if (isInactiveRow(resource, row)) return;
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

  async function handleActivate(row: MasterRow) {
    const recordName = recordLabel(resource, row);
    if (!accessToken || !row.id || !window.confirm(`Aktifkan ${recordName}?`)) {
      return;
    }
    setError(null);
    setSuccess(null);
    try {
      await apiData(`${resourceEndpoint}/${row.id}`, { method: "PUT", accessToken, body: JSON.stringify(activePayload(resource)) });
      setSuccess("Data berhasil diaktifkan.");
      await loadRows();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengaktifkan data.");
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
          <input value={searchInput} onChange={(event) => setSearchInput(event.target.value)} placeholder="Cari" />
        </label>
        <select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}>
          <option value="">Semua Status</option>
          {statusOptions.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
        </select>
        {error ? <button className="secondary-button" onClick={() => void loadRows()} type="button"><RotateCcw size={16} /> Retry</button> : null}
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
                <strong>{renderDetailValue(detailValue(detailRow, field, relationOptions), field.type)}</strong>
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
              optionsOverride={relationOptions[field.name]?.options}
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

async function currentRelationOption(field: MasterField, currentValue: string, selected: MasterRow | null, accessToken: string): Promise<SelectOption> {
  const relation = field.relation;
  if (!relation) return { value: currentValue, label: "Referensi saat ini" };
  if (relation.endpoint === "/users" && selected) {
    const name = String(selected.name ?? selected.full_name ?? "User saat ini");
    return { value: currentValue, label: `${name} - profil saat ini` };
  }
  try {
    const current = await apiData<MasterRow>(`${relation.endpoint}/${currentValue}`, { accessToken });
    return { value: currentValue, label: relationLabel(current, relation.labelKeys) };
  } catch {
    return { value: currentValue, label: "Referensi lama tidak ditemukan" };
  }
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
    if (field.omitWhenEmpty && (field.type === "number" || field.type === "decimal")) {
      data[field.name] = "";
    } else if (field.defaultValue !== undefined) {
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

function serializePayload(resource: MasterResource, data: MasterRow, mode: "create" | "edit") {
  const payload: MasterRow = {};
  for (const field of resource.fields) {
    const value = data[field.name];
    if (field.type === "hidden" && value === undefined) continue;
    if (value === "" || value === undefined) {
      if (field.required) {
        payload[field.name] = "";
      } else if (field.omitWhenEmpty && mode === "create") {
        continue;
      } else if (field.omitWhenEmpty && mode === "edit" && field.defaultValue !== undefined) {
        payload[field.name] = field.defaultValue;
      } else if (field.nullable) {
        payload[field.name] = field.clearValue ?? null;
      }
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

function detailValue(row: MasterRow, field: MasterField, relationOptions: RelationOptions) {
  const labelKey = relationLabelKey(field.name);
  if (field.relation && labelKey && row[labelKey]) return row[labelKey];
  return displayValue(row[field.name], field, relationOptions);
}

function displayValue(value: MasterRow[string], field: MasterField | undefined, relationOptions: RelationOptions) {
  if (!field?.relation || value === undefined || value === null || value === "") return value;
  return relationOptions[field.name]?.options.find((option) => option.value === String(value))?.label ?? "Referensi tidak ditemukan";
}

function relationLabelKey(fieldName: string) {
  const mapping: Record<string, string> = {
    inspection_area_id: "inspection_area_label",
    component_id: "component_label",
    structural_component_id: "component_label",
    test_parameter_id: "test_parameter_label",
    approval_category_id: "approval_category_label",
    container_type_id: "container_type_label"
  };
  return mapping[fieldName];
}

function relationLabel(row: MasterRow, labelKeys: string[]) {
  const label = labelKeys.map((key) => String(row[key] ?? "").trim()).filter(Boolean).join(" - ");
  return label || "Referensi tidak ditemukan";
}
function recordLabel(resource: MasterResource, row: MasterRow) {
  const firstTextField = resource.fields.find((field) => field.name !== "status" && field.type !== "hidden" && typeof row[field.name] === "string" && String(row[field.name]).trim() !== "");
  return firstTextField ? String(row[firstTextField.name]) : "data ini";
}

function isInactiveRow(resource: MasterResource, row: MasterRow) {
  if ("is_active" in row) return row.is_active === false || row.is_active === 0 || row.is_active === "0";
  return String(row.status ?? "").toLowerCase() === "inactive";
}

function activePayload(resource: MasterResource) {
  if (resource.fields.some((field) => field.name === "is_active")) return { is_active: true };
  return { status: "active" };
}