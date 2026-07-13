import { CheckSquare, Square } from "lucide-react";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";

type BulkSelectionTableProps<T> = {
  columns: ResponsiveColumn<T>[];
  rows: T[];
  selectedCount?: number;
  getRowId: (row: T) => string;
  isSelected?: (row: T) => boolean;
  getRowTitle?: (row: T) => string;
  emptyText?: string;
};

export function BulkSelectionTable<T>({
  columns,
  rows,
  selectedCount = 0,
  getRowId,
  isSelected = () => false,
  getRowTitle,
  emptyText
}: BulkSelectionTableProps<T>) {
  const selectionColumn: ResponsiveColumn<T> = {
    key: "selection",
    header: `${selectedCount} dipilih`,
    render: (row) => {
      const selected = isSelected(row);
      return selected ? <CheckSquare aria-label="Dipilih" size={18} /> : <Square aria-label="Belum dipilih" size={18} />;
    }
  };

  return (
    <ResponsiveTableCards
      columns={[selectionColumn, ...columns]}
      emptyText={emptyText}
      getRowId={getRowId}
      getRowTitle={getRowTitle}
      rows={rows}
    />
  );
}
