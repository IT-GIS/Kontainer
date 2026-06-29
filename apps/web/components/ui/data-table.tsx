import { ChevronLeft, ChevronRight } from "lucide-react";

type Column<T> = {
  key: string;
  header: string;
  render: (row: T) => React.ReactNode;
};

type DataTableProps<T> = {
  columns: Column<T>[];
  rows: T[];
  isLoading?: boolean;
  emptyText?: string;
  page?: number;
  totalPages?: number;
  onPageChange?: (page: number) => void;
};

export function DataTable<T>({ columns, rows, isLoading, emptyText = "Data belum tersedia.", page = 1, totalPages = 1, onPageChange }: DataTableProps<T>) {
  return (
    <div className="table-frame">
      <div className="table-scroll">
        <table className="data-table">
          <thead>
            <tr>
              {columns.map((column) => (
                <th key={column.key}>{column.header}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr>
                <td colSpan={columns.length}>Memuat data...</td>
              </tr>
            ) : rows.length === 0 ? (
              <tr>
                <td colSpan={columns.length}>{emptyText}</td>
              </tr>
            ) : (
              rows.map((row, index) => (
                <tr key={index}>
                  {columns.map((column) => (
                    <td key={column.key}>{column.render(row)}</td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
      {onPageChange ? (
        <div className="table-pagination">
          <button className="icon-button" disabled={page <= 1} onClick={() => onPageChange(page - 1)} title="Previous page">
            <ChevronLeft size={18} />
          </button>
          <span>
            Page {page} of {Math.max(totalPages, 1)}
          </span>
          <button className="icon-button" disabled={page >= totalPages} onClick={() => onPageChange(page + 1)} title="Next page">
            <ChevronRight size={18} />
          </button>
        </div>
      ) : null}
    </div>
  );
}