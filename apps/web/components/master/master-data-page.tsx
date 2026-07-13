"use client";

import { ClipboardList, Edit, Eye, Plus, Search, Trash2, X } from "lucide-react";
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
type RelationOptions = Record<string, SelectOption[]>;

type MasterDataPageProps = {
  resourceId: keyof typeof masterResources;
  endpointOverride?: string;
  fixedValues?: MasterRow;
  backHref?: string;
};

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
  const [dialogMode, setDialogMode] = useState<"create" | "edit" | null>(null);
  const [selected, setSelected] = useState<MasterRow | null>(null);
  const [detailRow, setDetailRow] = useState<MasterRow | null>(null);
  const [formData, setFormData] = useState<MasterRow>(() => ({ ...defaultFormData(resource), ...fixedPayload }));
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [surveyorUsers, setSurveyorUsers] = useState<SelectOption[]>([]);
  const [relationOptions, setRelationOptions] = useState<RelationOptions>({});

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
    let active = true;
    void Promise.all(relationFields.map(async (field) => {
      const relation = field.relation;
      if (!relation) return [field.name, []] as const;
      const result = await apiPaginated<MasterRow>(`${relation.endpoint}${buildQuery({ page: 1, per_page: 100, status: "active" })}`, { accessToken });
      return [field.name, result.rows.map((row) => ({ value: String(row.id ?? ""), label: relationLabel(row, relation.labelKeys) })).filter((option) => option.value)] as const;
    })).then((entries) => {
      if (active) setRelationOptions(Object.fromEntries(entries));
    }).catch(() => {
      if (active) setRelationOptions({});
    });
    return () => { active = false; };
  }, [accessToken, resource.fields]);

  const columns = [
    ...resource.columns.map((column) => ({
      key: column.key,
      header: column.label,
      render: (row: MasterRow) => renderCell(displayValue(row[column.key], fieldByName[column.key], relationOptions), column.type)
    })),
    {
      key: "actions",
      header: "Action",
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
  }

  function openEdit(row: MasterRow) {
    setSelected(row);
    setFormData({ ...formDataFromRow(resource, row), ...fixedPayload });
    setDialogMode("edit");
  }

  function closeDialog() {
    setDialogMode(null);
    setSelected(null);
    setFormData({ ...defaultFormData(resource), ...fixedPayload });
  }

  async function handleSubmit() {
    if (!accessToken || !dialogMode) {
      return;
    }
    setIsSubmitting(true);
    setError(null);
    try {
      const payload = cleanPayload({ ...formData, ...fixedPayload });
      if (dialogMode === "create") {
        await apiData(resourceEndpoint, { method: "POST", accessToken, body: JSON.stringify(payload) });
      } else if (selected?.id) {
        await apiData(`${resourceEndpoint}/${selected.id}`, { method: "PUT", accessToken, body: JSON.stringify(payload) });
      }
      closeDialog();
      await loadRows();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal menyimpan data.");
    } finally {
      setIsSubmitting(false);
    }
  }

  async function handleDelete(row: MasterRow) {
    if (!accessToken || !row.id || !window.confirm("Nonaktifkan data ini?")) {
      return;
    }
    setError(null);
    try {
      await apiData(`${resourceEndpoint}/${row.id}`, { method: "DELETE", accessToken });
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
          <option value="active">Aktif</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>

      {error ? <div className="alert alert-danger">{error}</div> : null}

      <DataTable columns={columns} rows={rows} isLoading={isLoading} page={page} totalPages={totalPages} onPageChange={setPage} />

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
        <div className="form-grid">
          {resource.fields.map((field) => (
            <FieldInput
              field={field}
              key={field.name}
              value={formData[field.name]}
              optionsOverride={(resourceId === "surveyors" || resourceId === "fitness-surveyors") && field.name === "user_id" ? surveyorUserOptions(surveyorUsers, selected) : relationOptions[field.name]}
              onChange={(value) => setFormData((current) => ({ ...current, [field.name]: value }))}
            />
          ))}
        </div>
      </FormDialog>
    </div>
  );
}

function FieldInput({ field, value, onChange, optionsOverride }: { field: MasterField; value: MasterRow[string]; onChange: (value: MasterRow[string]) => void; optionsOverride?: SelectOption[] }) {
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

  return (
    <label className="field">
      <span>{field.label}{field.required ? " *" : ""}</span>
      {field.type === "select" || optionsOverride ? (
        <select value={String(value ?? "")} onChange={(event) => onChange(event.target.value)} required={field.required}>
          <option value="">Pilih</option>
          {(optionsOverride ?? field.options)?.map((option) => (
            <option value={option.value} key={option.value}>{option.label}</option>
          ))}
        </select>
      ) : (
        <input
          value={String(value ?? "")}
          onChange={(event) => onChange(field.type === "number" ? numberOrEmpty(event.target.value) : event.target.value)}
          required={field.required}
          type={field.type ?? "text"}
        />
      )}
      {field.helpText ? <small className="muted-text">{field.helpText}</small> : null}
    </label>
  );
}

function surveyorUserOptions(options: SelectOption[], selected: MasterRow | null) {
  const currentID = String(selected?.user_id ?? "");
  if (!currentID || options.some((option) => option.value === currentID)) return options;
  return [{ value: currentID, label: `${String(selected?.name ?? "Current user")} - current profile` }, ...options];
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
    const display = normalized === "active" ? "Aktif" : normalized === "inactive" ? "Inactive" : label;
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

function cleanPayload(data: MasterRow) {
  return Object.fromEntries(
    Object.entries(data).filter(([, value]) => value !== "")
  );
}

function numberOrEmpty(value: string) {
  if (value === "") {
    return "";
  }
  return Number(value);
}

function displayValue(value: MasterRow[string], field: MasterField | undefined, relationOptions: RelationOptions) {
  if (!field?.relation || value === undefined || value === null || value === "") return value;
  return relationOptions[field.name]?.find((option) => option.value === String(value))?.label ?? value;
}

function relationLabel(row: MasterRow, labelKeys: string[]) {
  const label = labelKeys.map((key) => String(row[key] ?? "").trim()).filter(Boolean).join(" - ");
  return label || String(row.id ?? "");
}