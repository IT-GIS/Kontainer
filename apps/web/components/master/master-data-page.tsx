"use client";

import { Edit, Plus, Search, Trash2 } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { masterResources, type MasterField, type MasterResource } from "@/constants/master-data";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";

type MasterRow = Record<string, string | number | boolean | null | undefined>;

type MasterDataPageProps = {
  resourceId: keyof typeof masterResources;
};

export function MasterDataPage({ resourceId }: MasterDataPageProps) {
  const resource = masterResources[resourceId];
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
  const [formData, setFormData] = useState<MasterRow>(() => defaultFormData(resource));
  const [isSubmitting, setIsSubmitting] = useState(false);

  const canCreate = can(user, `${resource.permissionModule}.create.all`);
  const canUpdate = can(user, `${resource.permissionModule}.update.all`);
  const canDelete = can(user, `${resource.permissionModule}.delete.all`);

  const loadRows = useCallback(async () => {
    if (!accessToken) {
      return;
    }
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<MasterRow>(
        `${resource.endpoint}${buildQuery({ page, per_page: 10, search, status })}`,
        { accessToken }
      );
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil data.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, page, resource.endpoint, search, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  const columns = [
    ...resource.columns.map((column) => ({
      key: column.key,
      header: column.label,
      render: (row: MasterRow) => renderCell(row[column.key], column.type)
    })),
    {
      key: "actions",
      header: "Action",
      render: (row: MasterRow) => (
        <div className="row-actions">
          {canUpdate ? (
            <button className="icon-button" onClick={() => openEdit(row)} title="Edit">
              <Edit size={16} />
            </button>
          ) : null}
          {canDelete ? (
            <button className="icon-button danger-action" onClick={() => void handleDelete(row)} title="Deactivate">
              <Trash2 size={16} />
            </button>
          ) : null}
        </div>
      )
    }
  ];

  function openCreate() {
    setSelected(null);
    setFormData(defaultFormData(resource));
    setDialogMode("create");
  }

  function openEdit(row: MasterRow) {
    setSelected(row);
    setFormData(formDataFromRow(resource, row));
    setDialogMode("edit");
  }

  function closeDialog() {
    setDialogMode(null);
    setSelected(null);
    setFormData(defaultFormData(resource));
  }

  async function handleSubmit() {
    if (!accessToken || !dialogMode) {
      return;
    }
    setIsSubmitting(true);
    setError(null);
    try {
      if (dialogMode === "create") {
        await apiData(resource.endpoint, { method: "POST", accessToken, body: JSON.stringify(cleanPayload(formData)) });
      } else if (selected?.id) {
        await apiData(`${resource.endpoint}/${selected.id}`, { method: "PUT", accessToken, body: JSON.stringify(cleanPayload(formData)) });
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
    if (!accessToken || !row.id || !window.confirm("Deactivate this item?")) {
      return;
    }
    setError(null);
    try {
      await apiData(`${resource.endpoint}/${row.id}`, { method: "DELETE", accessToken });
      await loadRows();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal menonaktifkan data.");
    }
  }

  return (
    <div className="page-stack">
      <PageHeader
        title={resource.title}
        description={resource.description}
        action={canCreate ? { label: "Add", icon: Plus, onClick: openCreate } : undefined}
      />

      <div className="toolbar">
        <label className="search-box">
          <Search size={17} />
          <input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Search" />
        </label>
        <select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}>
          <option value="">All Status</option>
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>

      {error ? <div className="alert alert-danger">{error}</div> : null}

      <DataTable columns={columns} rows={rows} isLoading={isLoading} page={page} totalPages={totalPages} onPageChange={setPage} />

      <FormDialog
        title={dialogMode === "create" ? `Add ${resource.title}` : `Edit ${resource.title}`}
        open={Boolean(dialogMode)}
        onClose={closeDialog}
        onSubmit={handleSubmit}
        isSubmitting={isSubmitting}
        submitLabel={dialogMode === "create" ? "Create" : "Update"}
      >
        <div className="form-grid">
          {resource.fields.map((field) => (
            <FieldInput
              field={field}
              key={field.name}
              value={formData[field.name]}
              onChange={(value) => setFormData((current) => ({ ...current, [field.name]: value }))}
            />
          ))}
        </div>
      </FormDialog>
    </div>
  );
}

function FieldInput({ field, value, onChange }: { field: MasterField; value: MasterRow[string]; onChange: (value: MasterRow[string]) => void }) {
  if (field.type === "checkbox") {
    return (
      <label className="check-row form-check">
        <input checked={Boolean(value)} onChange={(event) => onChange(event.target.checked)} type="checkbox" />
        <span>{field.label}</span>
      </label>
    );
  }

  return (
    <label className="field">
      <span>{field.label}{field.required ? " *" : ""}</span>
      {field.type === "select" ? (
        <select value={String(value ?? "")} onChange={(event) => onChange(event.target.value)} required={field.required}>
          <option value="">Select</option>
          {field.options?.map((option) => (
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
    </label>
  );
}

function renderCell(value: MasterRow[string], type?: "status" | "boolean") {
  if (type === "status") {
    const label = String(value || "inactive");
    return <StatusBadge tone={label === "active" ? "success" : "neutral"}>{label.toUpperCase()}</StatusBadge>;
  }
  if (type === "boolean") {
    return <StatusBadge tone={value ? "success" : "neutral"}>{value ? "YES" : "NO"}</StatusBadge>;
  }
  return value === undefined || value === null || value === "" ? <span className="muted-text">-</span> : String(value);
}

function defaultFormData(resource: MasterResource): MasterRow {
  const data: MasterRow = {};
  for (const field of resource.fields) {
    if (field.type === "checkbox") {
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