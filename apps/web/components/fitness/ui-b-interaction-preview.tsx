"use client";

import { useMemo, useState } from "react";
import { ArrowRight, Save } from "lucide-react";
import { BulkSelectionTable } from "@/components/ui/bulk-selection-table";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";
import { Drawer } from "@/components/ui/drawer";
import { EmptyState } from "@/components/ui/empty-state";
import { ErrorState } from "@/components/ui/error-state";
import { FilterBar, type FilterBarField } from "@/components/ui/filter-bar";
import { FormField } from "@/components/ui/form-field";
import { ProgressTracker } from "@/components/ui/progress-tracker";
import { SearchableSelect, type SearchableSelectOption } from "@/components/ui/searchable-select";
import { Skeleton } from "@/components/ui/skeleton";
import { StatusBadge } from "@/components/ui/status-badge";
import { Stepper, type StepperItem } from "@/components/ui/stepper";
import { StickyActionBar } from "@/components/ui/sticky-action-bar";
import { ToastFeedback } from "@/components/ui/toast-feedback";
import { UnsavedChangesGuard, useUnsavedChangesGuard } from "@/components/ui/unsaved-changes-guard";
import type { ResponsiveColumn } from "@/components/ui/responsive-table-cards";

type PreviewRow = {
  id: string;
  code: string;
  owner: string;
  stage: string;
  status: string;
};

const options: SearchableSelectOption[] = [
  { value: "owner-1", label: "PT Nusantara Logistik", description: "Pemilik aktif" },
  { value: "owner-2", label: "PT Samudra Jaya", description: "Menunggu verifikasi" },
  { value: "owner-3", label: "PT Pelabuhan Sentosa", description: "Tidak dapat dipilih", disabled: true }
];

const rows: PreviewRow[] = [
  { id: "row-1", code: "REQ-2026-0713-001", owner: "PT Nusantara Logistik", stage: "Draf", status: "Data Awal" },
  { id: "row-2", code: "REQ-2026-0713-002", owner: "PT Samudra Jaya", stage: "Tahap Proses", status: "Teknis" },
  { id: "row-3", code: "REQ-2026-0713-003", owner: "PT Pelabuhan Sentosa", stage: "Penugasan Surveyor", status: "Siap Ditugaskan" }
];

export function UiBInteractionPreview() {
  const [selectedOwner, setSelectedOwner] = useState<string | null>("owner-1");
  const [filters, setFilters] = useState<Record<string, string>>({ stage: "process" });
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [toastOpen, setToastOpen] = useState(true);
  const [activeStep, setActiveStep] = useState(1);
  const [selectedIds, setSelectedIds] = useState<string[]>(["row-1"]);
  const guard = useUnsavedChangesGuard({ active: true, message: "Perubahan contoh belum disimpan." });

  const filterFields: FilterBarField[] = [
    { id: "keyword", label: "Cari", type: "search", value: filters.keyword ?? "", placeholder: "Cari permohonan" },
    {
      id: "stage",
      label: "Tahap",
      type: "select",
      value: filters.stage ?? "",
      placeholder: "Semua tahap",
      options: [
        { value: "draft", label: "Draf" },
        { value: "process", label: "Tahap Proses" },
        { value: "assignment", label: "Penugasan Surveyor" }
      ]
    },
    { id: "date", label: "Tanggal", type: "date-range", value: filters.date ?? "", endValue: filters.dateEnd ?? "" }
  ];

  const columns: ResponsiveColumn<PreviewRow>[] = [
    { key: "code", header: "Kode", render: (row) => <strong>{row.code}</strong> },
    { key: "owner", header: "Pemilik", render: (row) => row.owner },
    { key: "stage", header: "Tahap Proses", render: (row) => row.stage },
    { key: "status", header: "Status", render: (row) => <StatusBadge tone="info">{row.status}</StatusBadge> }
  ];

  const steps = useMemo<StepperItem[]>(() => [
    { id: "request", label: "Permohonan", description: "Data dasar", status: activeStep === 0 ? "current" : "complete", clickable: true },
    { id: "container", label: "Peti Kemas", description: "Data teknis", status: activeStep === 1 ? "current" : activeStep > 1 ? "complete" : "upcoming", clickable: true },
    { id: "assign", label: "Penugasan Surveyor", description: "Jadwal kerja", status: activeStep === 2 ? "current" : "upcoming", clickable: true },
    { id: "review", label: "Review", description: "Keputusan", status: "upcoming" }
  ], [activeStep]);

  const toggleRow = (rowId: string, checked: boolean) => {
    setSelectedIds((current) => checked ? [...new Set([...current, rowId])] : current.filter((id) => id !== rowId));
  };

  return (
    <section className="workspace-panel ui-b-preview-panel">
      <h2>UI-B.1 Interaction Harness</h2>
      <FormField helpText="Combobox controlled dengan pencarian dan clear." id="owner-select" label="Pemilik" required>
        <SearchableSelect
          clearable
          id="owner-select"
          label="Pemilik"
          showLabel={false}
          onChange={setSelectedOwner}
          options={options}
          value={selectedOwner}
        />
      </FormField>
      <FilterBar
        fields={filterFields}
        onChange={(fieldId, value, endValue) => setFilters((current) => ({ ...current, [fieldId]: value, [`${fieldId}End`]: endValue ?? current[`${fieldId}End`] ?? "" }))}
        onReset={() => setFilters({})}
        onSubmit={() => setToastOpen(true)}
      />
      <Stepper steps={steps} onStepClick={(_, index) => setActiveStep(index)} />
      <ProgressTracker items={[
        { id: "done", label: "Draf", description: "Tersimpan", status: "complete" },
        { id: "current", label: "Tahap Proses", description: "Sedang dilengkapi", status: "current" },
        { id: "warning", label: "Lampiran", description: "Perlu perhatian", status: "warning" }
      ]} />
      <BulkSelectionTable
        columns={columns}
        getRowId={(row) => row.id}
        getRowTitle={(row) => row.code}
        onToggleAll={(ids, checked) => setSelectedIds(checked ? ids : [])}
        onToggleRow={toggleRow}
        rows={rows}
        selectable={(row) => row.id !== "row-3"}
        selectedIds={selectedIds}
      />
      <div className="job-actions">
        <button className="secondary-button" onClick={() => setDrawerOpen(true)} type="button">Buka Drawer</button>
        <button className="secondary-button" onClick={() => setConfirmOpen(true)} type="button">Buka Konfirmasi</button>
        <button className="secondary-button" onClick={() => guard.requestNavigation(() => setToastOpen(true))} type="button">Tes Guard</button>
      </div>
      {toastOpen ? (
        <ToastFeedback
          description="Toast dapat ditutup dan tidak dipasang sebagai global provider."
          duration={5000}
          onDismiss={() => setToastOpen(false)}
          title="Interaksi berhasil"
          tone="success"
        />
      ) : null}
      <Drawer
        description="Drawer mengunci scroll, trap focus, Escape, dan restore focus."
        onClose={() => setDrawerOpen(false)}
        open={drawerOpen}
        title="Detail Singkat"
      >
        <p className="muted-text">Konten drawer untuk validasi interaksi internal.</p>
      </Drawer>
      <ConfirmationDialog
        description="Konfirmasi custom untuk aksi berisiko."
        onClose={() => setConfirmOpen(false)}
        onConfirm={() => setConfirmOpen(false)}
        open={confirmOpen}
        title="Lanjutkan aksi?"
      />
      <UnsavedChangesGuard active message="Perubahan contoh belum disimpan." />
      <ConfirmationDialog
        description="Guard internal memakai konfirmasi custom tanpa patch router."
        onClose={guard.cancelLeave}
        onConfirm={guard.confirmLeave}
        open={guard.confirmationOpen}
        title="Tinggalkan contoh?"
        tone="danger"
      />
      <div className="ui-b-support-grid">
        <EmptyState title="State kosong" description="Contoh state kosong untuk halaman UI-C." />
        <ErrorState message="Contoh state error untuk halaman UI-C." />
        <Skeleton variant="cards" count={2} />
      </div>
      <StickyActionBar
        primary={{ label: "Selanjutnya", onClick: () => setActiveStep((current) => Math.min(current + 1, 2)), icon: ArrowRight }}
        secondary={{ label: "Simpan Draf", onClick: () => setToastOpen(true), icon: Save }}
        tertiary={{ label: "Kembali", onClick: () => guard.requestNavigation(() => setActiveStep(0)) }}
      />
    </section>
  );
}
