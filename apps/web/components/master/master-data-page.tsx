"use client";

import { ClipboardList, Download, Edit, Eye, History, Plus, RotateCcw, Search, Trash2, X } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useId, useMemo, useRef, useState } from "react";
import { masterResources, type MasterField, type MasterResource } from "@/constants/master-data";
import type { Dispatch, ReactNode, SetStateAction } from "react";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import { DataTable } from "@/components/ui/data-table";
import { FormDialog } from "@/components/ui/form-dialog";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";

export type MasterRow = Record<string, string | number | boolean | null | undefined>;
type SelectOption = { value: string; label: string };
type RelationFieldState = { options: SelectOption[]; isLoading: boolean; error: string | null };
type RelationOptions = Record<string, RelationFieldState>;
export type MasterDataFilter = { key: string; label: string; options: Array<{ label: string; value: string }> };

export type MasterDataPageProps = {
  resourceId: keyof typeof masterResources;
  endpointOverride?: string;
  fixedValues?: MasterRow;
  backHref?: string;
  detailBaseHref?: string;
  detailQuery?: string;
  relationEndpointOverrides?: Record<string, string>;
  checklistItemsBaseHref?: string;
  readOnly?: boolean;
  readOnlyMessage?: string;
  startInCreateMode?: boolean;
  addButtonLabelOverride?: string;
  dialogTitleOverride?: string;
  showResourceHeader?: boolean;
  showToolbarAdd?: boolean;
  showRichEmptyState?: boolean;
  showImportUnavailable?: boolean;
  enableExport?: boolean;
  enableSaveAndNew?: boolean;
  enableSorting?: boolean;
  responsiveCards?: boolean;
  dialogSize?: "medium" | "large" | "drawer";
  actionIdPrefix?: string;
  filters?: MasterDataFilter[];
  emptyTitle?: string;
  emptyDescription?: string;
  onSaved?: (row: MasterRow, mode: "create" | "edit") => void;
  renderRowActions?: (row: MasterRow) => ReactNode;
  canMutateRow?: (row: MasterRow) => boolean;
  locationGenerator?: boolean;
  showHistoryAction?: boolean;
};

const defaultStatusOptions = [
  { label: "Aktif", value: "active" },
  { label: "Tidak Aktif", value: "inactive" }
];

export function MasterDataPage({
  resourceId,
  endpointOverride,
  fixedValues,
  backHref,
  detailBaseHref,
  detailQuery,
  relationEndpointOverrides,
  checklistItemsBaseHref,
  readOnly = false,
  readOnlyMessage,
  startInCreateMode = false,
  addButtonLabelOverride,
  dialogTitleOverride,
  showResourceHeader = true,
  showToolbarAdd = false,
  showRichEmptyState = false,
  showImportUnavailable = false,
  enableExport = false,
  enableSaveAndNew = false,
  enableSorting = false,
  responsiveCards = false,
  dialogSize = "medium",
  actionIdPrefix,
  filters = [],
  emptyTitle = "Data belum tersedia",
  emptyDescription = "Tambahkan data pertama agar referensi dapat digunakan.",
  onSaved,
  renderRowActions,
  canMutateRow,
  locationGenerator = false,
  showHistoryAction = false
}: MasterDataPageProps) {
  const resource = masterResources[resourceId];
  const accessibilityID = useId();
  const formErrorID = `${accessibilityID}-form-error`;
  const resourceEndpoint = endpointOverride ?? resource.endpoint;
  const fixedPayload = useMemo(() => fixedValues ?? {}, [fixedValues]);
  const { accessToken, user } = useAuth();
  const [rows, setRows] = useState<MasterRow[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalRows, setTotalRows] = useState(0);
  const [searchInput, setSearchInput] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [status, setStatus] = useState("");
  const [filterValues, setFilterValues] = useState<Record<string, string>>({});
  const [sortBy, setSortBy] = useState("");
  const [sortOrder, setSortOrder] = useState<"asc" | "desc">("asc");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [dialogMode, setDialogMode] = useState<"create" | "edit" | null>(null);
  const [selected, setSelected] = useState<MasterRow | null>(null);
  const [detailRow, setDetailRow] = useState<MasterRow | null>(null);
  const [formData, setFormData] = useState<MasterRow>(() => createFormData(resource, fixedPayload, locationGenerator));
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [relationOptions, setRelationOptions] = useState<RelationOptions>({});
  const [relationSearch, setRelationSearch] = useState<Record<string, string>>({});
  const listRequestSeq = useRef(0);
  const relationRequestSeq = useRef(0);
  const createOpenedRef = useRef(false);
  const formBaselineRef = useRef("");

  const statusOptions = resource.statusOptions ?? defaultStatusOptions;
  const canCreate = !readOnly && can(user, `${resource.permissionModule}.create.all`);
  const canUpdate = !readOnly && can(user, `${resource.permissionModule}.update.all`);
  const canDelete = !readOnly && can(user, `${resource.permissionModule}.delete.all`);
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
        `${resourceEndpoint}${buildQuery({
          page,
          per_page: 10,
          search: debouncedSearch,
          status,
          ...(enableSorting && sortBy ? { sort_by: sortBy, sort_order: sortOrder } : {}),
          ...filterValues
        })}`,
        { accessToken }
      );
      if (requestID !== listRequestSeq.current) return;
      setRows(result.rows);
      setTotalPages(Number(result.meta.total_pages ?? 1));
      setTotalRows(Number(result.meta.total ?? result.rows.length));
    } catch (err) {
      if (requestID === listRequestSeq.current) {
        setError(err instanceof Error ? err.message : "Gagal mengambil data.");
      }
    } finally {
      if (requestID === listRequestSeq.current) {
        setIsLoading(false);
      }
    }
  }, [accessToken, debouncedSearch, enableSorting, filterValues, page, resourceEndpoint, sortBy, sortOrder, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setPage(1);
      setDebouncedSearch(searchInput);
    }, 350);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setFormData(createFormData(resource, fixedPayload, locationGenerator));
      setSelected(null);
      setDetailRow(null);
      setPage(1);
      setTotalRows(0);
      setSearchInput("");
      setDebouncedSearch("");
      setStatus("");
      setFilterValues({});
      setSortBy("");
      setSortOrder("asc");
      setSuccess(null);
      setFormError(null);
      setRelationSearch({});
      setRelationOptions({});
    }, 0);
    return () => window.clearTimeout(timer);
  }, [fixedPayload, locationGenerator, resource, resourceEndpoint]);

  useEffect(() => {
    if (!startInCreateMode || readOnly || createOpenedRef.current) return;
    createOpenedRef.current = true;
    setSelected(null);
    const nextForm = createFormData(resource, fixedPayload, locationGenerator);
    setFormData(nextForm);
    formBaselineRef.current = JSON.stringify(nextForm);
    setDialogMode("create");
    setError(null);
    setFormError(null);
  }, [fixedPayload, locationGenerator, readOnly, resource, startInCreateMode]);

  useEffect(() => {
    if (!dialogMode || JSON.stringify(formData) === formBaselineRef.current) return;
    const handleBeforeUnload = (event: BeforeUnloadEvent) => event.preventDefault();
    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [dialogMode, formData]);

  useEffect(() => {
    if (!accessToken || !dialogMode || relationFields.length === 0) return;
    const requestID = ++relationRequestSeq.current;

    const timer = window.setTimeout(() => {
      setRelationOptions((current) => {
        const next = { ...current };
        for (const field of relationFields) {
          next[field.name] = { options: current[field.name]?.options ?? [], isLoading: true, error: null };
        }
        return next;
      });
      const selectedValues = selectedRelationValuesKey.split("|");
      void Promise.all(relationFields.map(async (field, fieldIndex) => {
        const relation = field.relation;
        if (!relation) return [field.name, { options: [], isLoading: false, error: null }] as const;
        try {
          const currentValue = selectedValues[fieldIndex] ?? "";
          const query: Record<string, string | number> = { page: 1, per_page: 20, ...(relation.query ?? {}), search: relationSearch[field.name] ?? "" };
          if (!relation.query?.status) query.status = "active";
          const relationEndpoint = relationEndpointOverrides?.[field.name] ?? relation.endpoint;
          const result = await apiPaginated<MasterRow>(`${relationEndpoint}${buildQuery(query)}`, { accessToken });
          const options = result.rows.map((row) => ({ value: String(row.id ?? ""), label: relationLabel(row, relation.labelKeys) })).filter((option) => option.value);
          if (currentValue && !options.some((option) => option.value === currentValue)) {
            const currentOption = await currentRelationOption(field, currentValue, selected, accessToken, relationEndpoint);
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
  }, [accessToken, dialogMode, relationEndpointOverrides, relationFields, relationSearch, resourceEndpoint, selected, selectedRelationValuesKey]);

  const columns = [
    ...resource.columns.map((column) => ({
      key: column.key,
      header: column.label,
      render: (row: MasterRow) => renderMasterCell(row, column.key, column.type),
      sortable: enableSorting && resource.fields.some((field) => field.name === column.key)
    })),
    {
      key: "actions",
      header: "Aksi",
      render: (row: MasterRow) => (
        <div className="row-actions">
          {detailBaseHref && row.id ? (
            <Link aria-label={`Buka detail ${recordLabel(resource, row)}`} className="icon-button" href={detailBaseHref + "/" + row.id + (detailQuery ?? "")} title="Buka detail">
              <Eye size={16} />
            </Link>
          ) : (
            <button aria-label={`Lihat detail ${recordLabel(resource, row)}`} className="icon-button" onClick={() => setDetailRow(row)} title="Detail">
              <Eye size={16} />
            </button>
          )}
          {resourceId === "fitness-checklist-templates" && row.id ? (
            <Link aria-label={`Kelola item ${recordLabel(resource, row)}`} className="icon-button" href={`${checklistItemsBaseHref ?? "/fitness/master-data/checklist-templates"}/${row.id}/items`} title="Item checklist">
              <ClipboardList size={16} />
            </Link>
          ) : null}
          {canUpdate && (canMutateRow?.(row) ?? true) ? (
            <button aria-label={`Edit ${recordLabel(resource, row)}`} className="icon-button" onClick={() => openEdit(row)} title="Edit">
              <Edit size={16} />
            </button>
          ) : null}
          {canUpdate && (canMutateRow?.(row) ?? true) && isInactiveRow(resource, row) ? (
            <button aria-label={`Aktifkan ${recordLabel(resource, row)}`} className="icon-button" onClick={() => void handleActivate(row)} title="Aktifkan">
              <RotateCcw size={16} />
            </button>
          ) : null}
          {canDelete && (canMutateRow?.(row) ?? true) && !isInactiveRow(resource, row) ? (
            <button aria-label={`Nonaktifkan ${recordLabel(resource, row)}`} className="icon-button danger-action" onClick={() => void handleDelete(row)} title="Nonaktifkan">
              <Trash2 size={16} />
            </button>
          ) : null}
          {renderRowActions?.(row)}
          {showHistoryAction ? (
            <Link aria-label={`Riwayat ${recordLabel(resource, row)}`} className="icon-button" href={`/settings/audit-log?search=${encodeURIComponent(String(row.id ?? recordLabel(resource, row)))}`} title="Riwayat">
              <History size={16} />
            </Link>
          ) : null}
        </div>
      )
    }
  ];

  function openCreate() {
    setSelected(null);
    const nextForm = createFormData(resource, fixedPayload, locationGenerator);
    setFormData(nextForm);
    formBaselineRef.current = JSON.stringify(nextForm);
    setRelationSearch({});
    setDialogMode("create");
    setError(null);
    setFormError(null);
    setSuccess(null);
  }

  function openEdit(row: MasterRow) {
    setSelected(row);
    const nextForm = { ...formDataFromRow(resource, row), ...fixedPayload };
    setFormData(nextForm);
    formBaselineRef.current = JSON.stringify(nextForm);
    setRelationSearch({});
    setDialogMode("edit");
    setError(null);
    setFormError(null);
    setSuccess(null);
  }

  function closeDialog(force = false) {
    if (!force && dialogMode && JSON.stringify(formData) !== formBaselineRef.current && !window.confirm("Perubahan belum disimpan. Tutup form?")) {
      return;
    }
    setDialogMode(null);
    setSelected(null);
    setFormData(createFormData(resource, fixedPayload, locationGenerator));
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
      const savedMode = dialogMode;
      let saved: MasterRow | undefined;
      if (dialogMode === "create") {
        saved = await apiData<MasterRow>(resourceEndpoint, { method: "POST", accessToken, body: JSON.stringify(payload) });
        setSuccess("Data berhasil dibuat.");
      } else if (selected?.id) {
        saved = await apiData<MasterRow>(`${resourceEndpoint}/${selected.id}`, { method: "PUT", accessToken, body: JSON.stringify(payload) });
        setSuccess("Data berhasil diperbarui.");
      }
      closeDialog(true);
      await loadRows();
      if (saved) onSaved?.(saved, savedMode);
    } catch (err) {
      setFormError(err instanceof Error ? err.message : "Gagal menyimpan data.");
    } finally {
      setIsSubmitting(false);
    }
  }

  async function handleSaveAndNew() {
    if (!accessToken || dialogMode !== "create" || isSubmitting) {
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
      const payload = serializePayload(resource, { ...formData, ...fixedPayload }, "create");
      const saved = await apiData<MasterRow>(resourceEndpoint, { method: "POST", accessToken, body: JSON.stringify(payload) });
      onSaved?.(saved, "create");
      setSuccess("Data berhasil dibuat. Silakan isi data baru.");
      const nextForm = createFormData(resource, fixedPayload, locationGenerator);
      setFormData(nextForm);
      formBaselineRef.current = JSON.stringify(nextForm);
      setRelationSearch({});
      setFormError(null);
      await loadRows();
    } catch (err) {
      setFormError(err instanceof Error ? err.message : "Gagal menyimpan data.");
    } finally {
      setIsSubmitting(false);
    }
  }

  async function handleExport() {
    if (!accessToken) return;
    setError(null);
    try {
      const baseQuery = {
        per_page: 100,
        search: debouncedSearch,
        status,
        ...(enableSorting && sortBy ? { sort_by: sortBy, sort_order: sortOrder } : {}),
        ...filterValues
      };
      const firstPage = await apiPaginated<MasterRow>(`${resourceEndpoint}${buildQuery({ ...baseQuery, page: 1 })}`, { accessToken });
      const allRows = [...firstPage.rows];
      const exportPages = Number(firstPage.meta.total_pages ?? 1);
      for (let exportPage = 2; exportPage <= exportPages; exportPage += 1) {
        const result = await apiPaginated<MasterRow>(`${resourceEndpoint}${buildQuery({ ...baseQuery, page: exportPage })}`, { accessToken });
        allRows.push(...result.rows);
      }
      const exportColumns = resource.columns.filter((col) => col.key !== "actions");
      const header = exportColumns.map((col) => col.label).join(",");
      const csvRows = allRows.map((row) =>
        exportColumns.map((col) => {
          const value = String(row[col.key] ?? "");
          return value.includes(",") || value.includes('"') || value.includes("\n")
            ? `"${value.replace(/"/g, '""')}"`
            : value;
        }).join(",")
      );
      const csv = [header, ...csvRows].join("\n");
      const blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `${resource.title.replace(/\s+/g, "_")}_${new Date().toISOString().slice(0, 10)}.csv`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengekspor data.");
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

  function resetFilters() {
    setPage(1);
    setSearchInput("");
    setDebouncedSearch("");
    setStatus("");
    setFilterValues({});
    setSortBy("");
    setSortOrder("asc");
  }

  return (
    <div className="page-stack">
      {backHref ? <Link className="secondary-button" href={backHref}>Kembali</Link> : null}
      {showResourceHeader ? (
        <PageHeader
          title={resource.title}
          description={resource.description}
          action={canCreate ? { label: addButtonLabelOverride ?? "Tambah", icon: Plus, onClick: openCreate } : undefined}
        />
      ) : null}

      {readOnly ? <div className="alert alert-warning">{readOnlyMessage ?? "Data ditampilkan dalam mode baca-saja."}</div> : null}

      <div className="toolbar">
      {!readOnly && user && !canCreate && showToolbarAdd ? <div className="alert alert-warning">Anda tidak memiliki izin untuk menambah data ISO CEDEX.</div> : null}
        <label className="search-box">
          <Search size={17} />
          <span className="sr-only">Cari {resource.title}</span>
          <input value={searchInput} onChange={(event) => setSearchInput(event.target.value)} placeholder="Cari" />
        </label>
        <label>
          <span className="sr-only">Filter status {resource.title}</span>
          <select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}>
            <option value="">Semua Status</option>
            {statusOptions.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
          </select>
        </label>
        {filters.map((filter) => (
          <label key={filter.key}>
            <span className="sr-only">{filter.label}</span>
            <select
              aria-label={filter.label}
              value={filterValues[filter.key] ?? ""}
              onChange={(event) => {
                setPage(1);
                setFilterValues((current) => ({ ...current, [filter.key]: event.target.value }));
              }}
            >
              <option value="">Semua {filter.label}</option>
              {filter.options.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
            </select>
          </label>
        ))}
        {canCreate && showToolbarAdd ? (
          <button className="primary-button" id={actionIdPrefix ? `${actionIdPrefix}-add` : undefined} onClick={openCreate} type="button">
            <Plus size={16} /><span>{addButtonLabelOverride ?? "Tambah"}</span>
          </button>
        ) : null}
        {showImportUnavailable ? (
          <button className="secondary-button" disabled id={actionIdPrefix ? `${actionIdPrefix}-import` : undefined} title="Belum tersedia" type="button">
            <span>Import</span>
          </button>
        ) : null}
        {enableExport ? (
          <button className="secondary-button" id={actionIdPrefix ? `${actionIdPrefix}-export` : undefined} onClick={() => void handleExport()} type="button">
            <Download size={16} /><span>Export</span>
          </button>
        ) : null}
        <button className="secondary-button" onClick={resetFilters} type="button">Reset Filter</button>
        <button className="icon-button" id={actionIdPrefix ? `${actionIdPrefix}-refresh` : undefined} onClick={() => void loadRows()} title="Refresh" aria-label="Refresh data" type="button">
          <RotateCcw size={16} />
        </button>
      </div>

      {success ? <div className="alert alert-success">{success}</div> : null}
      {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}

      <DataTable
        columns={columns}
        rows={rows}
        isLoading={isLoading}
        page={page}
        totalPages={totalPages}
        totalRows={totalRows}
        onPageChange={setPage}
        sortBy={sortBy}
        sortOrder={sortOrder}
        onSort={enableSorting ? (key, order) => { setPage(1); setSortBy(key); setSortOrder(order); } : undefined}
        responsiveCards={responsiveCards}
        emptyText={showRichEmptyState ? (
          <div className="master-empty-state">
            <strong>{emptyTitle}</strong>
            <span>{emptyDescription}</span>
            {canCreate && showToolbarAdd ? <button className="primary-button" onClick={openCreate} type="button"><Plus size={16} /><span>{addButtonLabelOverride ?? "Tambah"}</span></button> : null}
          </div>
        ) : "Data belum tersedia."}
      />

      {detailRow ? (
        <section className="workspace-panel">
          <div className="section-title-row">
            <div><Eye size={20} /><h2>Detail</h2></div>
            <button aria-label="Tutup detail" className="icon-button" onClick={() => setDetailRow(null)} title="Tutup detail"><X size={16} /></button>
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
        title={dialogMode === "create" ? `Tambah ${dialogTitleOverride ?? resource.title}` : `Edit ${dialogTitleOverride ?? resource.title}`}
        open={Boolean(dialogMode)}
        onClose={closeDialog}
        onSubmit={handleSubmit}
        isSubmitting={isSubmitting}
        submitLabel={dialogMode === "create" ? "Simpan" : "Update"}
        onSaveAndNew={enableSaveAndNew && dialogMode === "create" ? () => void handleSaveAndNew() : undefined}
        saveAndNewLabel="Simpan & Tambah Lagi"
        size={dialogSize}
      >
        {formError ? <div className="alert alert-danger" id={formErrorID} role="alert">{formError}</div> : null}
        {locationGenerator ? <LocationCodeGenerator formData={formData} setFormData={setFormData} /> : null}
        <div className="form-grid">
          {visibleFormFields(resource, formData, locationGenerator).map((field) => (
            <FieldInput
              field={field}
              key={field.name}
              value={formData[field.name]}
              optionsOverride={relationOptions[field.name]?.options}
              relationState={relationOptions[field.name]}
              relationSearch={relationSearch[field.name] ?? ""}
              errorID={formError ? formErrorID : undefined}
              onRelationSearch={(value) => setRelationSearch((current) => ({ ...current, [field.name]: value }))}
              onChange={(value) => setFormData((current) => locationGenerator ? updateLocationManualField(current, field.name, value) : ({ ...current, [field.name]: value }))}
            />
          ))}
        </div>
      </FormDialog>
    </div>
  );
}

function LocationCodeGenerator({ formData, setFormData }: { formData: MasterRow; setFormData: Dispatch<SetStateAction<MasterRow>> }) {
  const mode = String(formData.input_mode ?? "structured");
  const size = String(formData.container_size ?? "20");
  const sections = size === "20" ? ["1", "2", "3", "4", "5"] : ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
  const span = String(formData.transverse_span ?? "N");

  function setMode(nextMode: "structured" | "manual") {
    setFormData((current) => ({
      ...current,
      input_mode: nextMode,
      sector_code: "",
      vertical_code: "",
      start_section: "",
      end_section: "",
      transverse_span: nextMode === "structured" ? "N" : "",
      container_size: nextMode === "structured" ? "20" : current.container_size,
      code: "",
      face: "",
      grid_code: ""
    }));
  }

  function updateStructure(key: string, value: string) {
    setFormData((current) => {
      const next = { ...current, [key]: value };
      if (key === "container_size") {
        next.start_section = "";
        next.end_section = "";
      }
      if (key === "transverse_span" && value === "N") next.end_section = "";
      const preview = structuredLocationPreview(next);
      next.code = preview;
      next.grid_code = preview;
      next.face = sectorFace(String(next.sector_code ?? ""));
      return next;
    });
  }

  return <div className="location-code-generator page-stack">
    <div className="segmented-control" aria-label="Mode input Location Code">
      <button className={mode === "structured" ? "selected" : ""} onClick={() => setMode("structured")} type="button">Generate dari Struktur</button>
      <button className={mode === "manual" ? "selected" : ""} onClick={() => setMode("manual")} type="button">Input Manual</button>
    </div>
    {mode === "structured" ? <div className="form-grid location-structure-grid">
      <label className="field"><span>Sector *</span><select value={String(formData.sector_code ?? "")} onChange={(event) => updateStructure("sector_code", event.target.value)}><option value="">Pilih Sector</option>{[["D", "Rear / Door End"], ["L", "Left Hand"], ["R", "Right Hand"], ["F", "Front End"], ["U", "Understructure"], ["T", "Top / Roof"], ["B", "Base / Floor"]].map(([value, label]) => <option key={value} value={value}>{value} — {label}</option>)}</select></label>
      <label className="field"><span>Vertical Position *</span><select value={String(formData.vertical_code ?? "")} onChange={(event) => updateStructure("vertical_code", event.target.value)}><option value="">Pilih Vertical</option>{[["G", "Ground"], ["B", "Bottom"], ["T", "Top"], ["H", "Height"], ["X", "Half Position"]].map(([value, label]) => <option key={value} value={value}>{value} — {label}</option>)}</select></label>
      <label className="field"><span>Container Size *</span><select value={size} onChange={(event) => updateStructure("container_size", event.target.value)}><option value="20">20 feet</option><option value="40">40 feet</option><option value="45">45 feet</option></select></label>
      <label className="field"><span>Start Section *</span><select value={String(formData.start_section ?? "")} onChange={(event) => updateStructure("start_section", event.target.value)}><option value="">Pilih Section</option>{sections.map((section) => <option key={section} value={section}>{section}</option>)}</select></label>
      <label className="field"><span>Transverse / Span *</span><select value={span} onChange={(event) => updateStructure("transverse_span", event.target.value)}><option value="N">N — Satu titik</option><option value="RANGE">Range — Rentang section</option></select></label>
      {span === "RANGE" ? <label className="field"><span>End Section *</span><select value={String(formData.end_section ?? "")} onChange={(event) => updateStructure("end_section", event.target.value)}><option value="">Pilih End Section</option>{sections.map((section) => <option key={section} value={section}>{section}</option>)}</select></label> : null}
      <label className="field form-span-2"><span>Location Code Preview</span><input className="code-preview" readOnly value={String(formData.code ?? "")} placeholder="Contoh: TB5N" /></label>
    </div> : <div className="alert alert-warning">Input manual hanya tersedia untuk Admin dan tetap divalidasi sebagai empat karakter alfanumerik.</div>}
  </div>;
}

function FieldInput({ field, value, onChange, optionsOverride, relationState, relationSearch, onRelationSearch, errorID }: { field: MasterField; value: MasterRow[string]; onChange: (value: MasterRow[string]) => void; optionsOverride?: SelectOption[]; relationState?: RelationFieldState; relationSearch?: string; onRelationSearch?: (value: string) => void; errorID?: string }) {
  if (field.type === "hidden") {
    return null;
  }

  if (field.type === "checkbox") {
    return (
      <label className="check-row form-check">
        <input aria-describedby={errorID} checked={Boolean(value)} onChange={(event) => onChange(event.target.checked)} type="checkbox" />
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
          <input aria-describedby={errorID} aria-label={`Cari ${field.label}`} value={relationSearch ?? ""} onChange={(event) => onRelationSearch?.(event.target.value)} placeholder="Cari data referensi" type="search" />
          <select aria-describedby={errorID} aria-label={`Pilih ${field.label}`} value={String(value ?? "")} onChange={(event) => onChange(event.target.value)} required={field.required}>
            <option value="">Pilih</option>
            {options?.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
          </select>
          {relationState?.isLoading ? <small className="muted-text">Memuat referensi...</small> : null}
          {relationState?.error ? <small className="alert-danger">{relationState.error}</small> : null}
        </>
      ) : field.type === "select" || optionsOverride ? (
        <select aria-describedby={errorID} value={String(value ?? "")} onChange={(event) => onChange(event.target.value)} required={field.required}>
          <option value="">Pilih</option>
          {options?.map((option) => <option value={option.value} key={option.value}>{option.label}</option>)}
        </select>
      ) : field.type === "textarea" ? (
        <textarea aria-describedby={errorID} value={String(value ?? "")} onChange={(event) => onChange(event.target.value)} required={field.required} maxLength={field.maxLength} />
      ) : (
        <input
          aria-describedby={errorID}
          value={String(value ?? "")}
          onChange={(event) => onChange(field.type === "number" || field.type === "decimal" ? numberOrEmpty(event.target.value) : field.uppercase ? event.target.value.toUpperCase() : event.target.value)}
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

async function currentRelationOption(field: MasterField, currentValue: string, selected: MasterRow | null, accessToken: string, relationEndpoint?: string): Promise<SelectOption> {
  const relation = field.relation;
  if (!relation) return { value: currentValue, label: "Referensi saat ini" };
  if (relation.endpoint === "/users" && selected) {
    const name = String(selected.name ?? selected.full_name ?? "User saat ini");
    return { value: currentValue, label: `${name} - profil saat ini` };
  }
  try {
    const current = await apiData<MasterRow>(`${relationEndpoint ?? relation.endpoint}/${currentValue}`, { accessToken });
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

function renderMasterCell(row: MasterRow, key: string, type?: "status" | "boolean" | "source") {
  if (key === "section_range") {
    const start = String(row.start_section ?? "");
    const end = String(row.end_section ?? "");
    return start ? (end ? `${start}–${end}` : start) : renderCell(row.grid_code, undefined);
  }
  return renderCell(row[key], type);
}

function renderCell(value: MasterRow[string], type?: "status" | "boolean" | "source") {
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
  if (type === "source") {
    const source = String(value ?? "legacy");
    const labels: Record<string, string> = { standard_global: "Standar Global", customer_specific: "Khusus Customer", legacy: "Legacy" };
    return <StatusBadge tone={source === "standard_global" ? "success" : source === "customer_specific" ? "warning" : "neutral"}>{labels[source] ?? source}</StatusBadge>;
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

function createFormData(resource: MasterResource, fixedValues: MasterRow, locationGenerator: boolean) {
  const data = { ...defaultFormData(resource), ...fixedValues };
  if (!locationGenerator) return data;
  return {
    ...data,
    input_mode: "structured",
    sector_code: "",
    vertical_code: "",
    start_section: "",
    end_section: "",
    transverse_span: "N",
    container_size: "20",
    code: "",
    face: "",
    grid_code: ""
  };
}

function visibleFormFields(resource: MasterResource, data: MasterRow, locationGenerator: boolean) {
  if (!locationGenerator) return resource.fields;
  const mode = String(data.input_mode ?? "structured");
  const structuredFields = new Set(["description", "source_type", "source_reason", "display_order", "status"]);
  const manualFields = new Set(["input_mode", "code", "container_size", "description", "source_type", "source_reason", "display_order", "status"]);
  return resource.fields.filter((field) => (mode === "structured" ? structuredFields : manualFields).has(field.name));
}

function updateLocationManualField(current: MasterRow, fieldName: string, value: MasterRow[string]) {
  const next = { ...current, [fieldName]: value };
  if (String(next.input_mode ?? "") === "manual" && fieldName === "code") {
    const code = String(value ?? "").toUpperCase();
    next.code = code;
    next.grid_code = code;
    next.face = sectorFace(code.slice(0, 1));
  }
  return next;
}

function structuredLocationPreview(data: MasterRow) {
  const sector = String(data.sector_code ?? "");
  const vertical = String(data.vertical_code ?? "");
  const start = String(data.start_section ?? "");
  const span = String(data.transverse_span ?? "N");
  const end = String(data.end_section ?? "");
  if (!sector || !vertical || !start || (span === "RANGE" && !end)) return "";
  return `${sector}${vertical}${start}${span === "RANGE" ? end : "N"}`.toUpperCase();
}

function sectorFace(sector: string) {
  const faces: Record<string, string> = { D: "door", L: "left", R: "right", F: "front", U: "understructure", T: "roof", B: "floor" };
  return faces[sector.toUpperCase()] ?? "";
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
  const codeSpec = codeValidationSpec(resource.id);
  if (codeSpec) {
    const code = String(data.code ?? "").trim();
    if (!new RegExp(`^[A-Za-z0-9]{${codeSpec.length}}$`).test(code)) {
      return `${codeSpec.label} wajib terdiri dari tepat ${codeSpec.length} karakter huruf atau angka.`;
    }
  }
  for (const field of resource.fields) {
    const value = data[field.name];
    const empty = value === undefined || value === null || String(value).trim() === "";
    if (field.required && empty) {
      return `${field.label} wajib diisi.`;
    }
    if (empty) continue;
    const text = String(value);
    if (field.maxLength && text.length > field.maxLength) {
      return `${field.label} maksimal ${field.maxLength} karakter.`;
    }
    if (field.pattern && !new RegExp(field.pattern).test(text)) {
      return `${field.label} tidak sesuai format yang diwajibkan.`;
    }
    const numericValue = Number(value);
    if ((field.type === "number" || field.type === "decimal") && !Number.isFinite(numericValue)) {
      return `${field.label} harus berupa angka.`;
    }
    if (field.min !== undefined && numericValue < field.min) {
      return `${field.label} minimal ${field.min}.`;
    }
    if (field.max !== undefined && numericValue > field.max) {
      return `${field.label} maksimal ${field.max}.`;
    }
  }
  return null;
}

function codeValidationSpec(resourceID: string) {
  const specs: Record<string, { length: number; label: string }> = {
    "cedex-locations": { length: 4, label: "Location Code" },
    "cedex-components": { length: 3, label: "Component Code" },
    "cedex-damages": { length: 2, label: "Damage Code" },
    "cedex-actions": { length: 2, label: "Action Repair Code" },
    "cedex-materials": { length: 2, label: "Material Code" }
  };
  return specs[resourceID];
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
    container_type_id: "container_type_label",
    damage_id: "damage_label",
    location_id: "location_label",
    material_id: "material_label",
    inspection_reference_id: "inspection_reference_label",
    recommended_action_id: "recommended_action_label",
    default_action_id: "default_action_label",
    default_inspection_reference_id: "default_inspection_reference_label"
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
