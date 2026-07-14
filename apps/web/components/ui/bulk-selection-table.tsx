"use client";

import { useEffect, useRef } from "react";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";

type BulkSelectionTableProps<T> = {
  columns: ResponsiveColumn<T>[];
  rows: T[];
  selectedIds: string[];
  onToggleRow: (rowId: string, checked: boolean, row: T) => void;
  onToggleAll?: (rowIds: string[], checked: boolean) => void;
  selectable?: (row: T) => boolean;
  getRowId: (row: T) => string;
  getRowTitle?: (row: T) => string;
  emptyText?: string;
  selectionLabel?: string;
};

export function BulkSelectionTable<T>({
  columns,
  rows,
  selectedIds,
  onToggleRow,
  onToggleAll,
  selectable = () => true,
  getRowId,
  getRowTitle,
  emptyText,
  selectionLabel = "Pilih data"
}: BulkSelectionTableProps<T>) {
  const selectableRows = rows.filter(selectable);
  const selectableIds = selectableRows.map(getRowId);
  const selectedSet = new Set(selectedIds);
  const selectedSelectableCount = selectableIds.filter((id) => selectedSet.has(id)).length;
  const allSelected = selectableIds.length > 0 && selectedSelectableCount === selectableIds.length;
  const indeterminate = selectedSelectableCount > 0 && !allSelected;

  const selectionColumn: ResponsiveColumn<T> = {
    key: "selection",
    header: (
      <IndeterminateCheckbox
        ariaLabel={allSelected ? "Batalkan semua pilihan" : "Pilih semua data"}
        checked={allSelected}
        disabled={selectableIds.length === 0}
        indeterminate={indeterminate}
        onChange={(checked) => onToggleAll?.(selectableIds, checked)}
      />
    ),
    render: (row) => {
      const rowId = getRowId(row);
      const canSelect = selectable(row);
      return (
        <input
          aria-label={`${selectionLabel} ${getRowTitle?.(row) ?? rowId}`}
          checked={selectedSet.has(rowId)}
          disabled={!canSelect}
          onChange={(event) => onToggleRow(rowId, event.target.checked, row)}
          type="checkbox"
        />
      );
    }
  };

  return (
    <div className="ui-bulk-selection">
      <div className="ui-bulk-summary" aria-live="polite">
        <strong>{selectedSelectableCount}</strong>
        <span>dipilih dari {selectableIds.length} data</span>
      </div>
      <ResponsiveTableCards
        columns={[selectionColumn, ...columns]}
        emptyText={emptyText}
        getRowId={getRowId}
        getRowTitle={getRowTitle}
        rows={rows}
      />
    </div>
  );
}

function IndeterminateCheckbox({
  checked,
  indeterminate,
  disabled,
  ariaLabel,
  onChange
}: {
  checked: boolean;
  indeterminate: boolean;
  disabled?: boolean;
  ariaLabel: string;
  onChange: (checked: boolean) => void;
}) {
  const ref = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    if (ref.current) ref.current.indeterminate = indeterminate;
  }, [indeterminate]);

  return (
    <input
      aria-label={ariaLabel}
      checked={checked}
      disabled={disabled}
      onChange={(event) => onChange(event.target.checked)}
      ref={ref}
      type="checkbox"
    />
  );
}