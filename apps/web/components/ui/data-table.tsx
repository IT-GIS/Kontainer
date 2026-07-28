import { ArrowUpDown, ChevronDown, ChevronLeft, ChevronRight, ChevronUp } from "lucide-react";

type SortOrder = "asc" | "desc";

type Column<T> = {
  key: string;
  header: string;
  render: (row: T) => React.ReactNode;
  sortable?: boolean;
};

type DataTableProps<T> = {
  columns: Column<T>[];
  rows: T[];
  isLoading?: boolean;
  emptyText?: React.ReactNode;
  page?: number;
  totalPages?: number;
  totalRows?: number;
  onPageChange?: (page: number) => void;
  sortBy?: string;
  sortOrder?: SortOrder;
  onSort?: (key: string, order: SortOrder) => void;
  responsiveCards?: boolean;
};

export function DataTable<T>({
  columns,
  rows,
  isLoading,
  emptyText = "Data belum tersedia.",
  page = 1,
  totalPages = 1,
  totalRows,
  onPageChange,
  sortBy,
  sortOrder = "asc",
  onSort,
  responsiveCards = false
}: DataTableProps<T>) {
  return (
    <div className={`table-frame${responsiveCards ? " table-frame-responsive-cards" : ""}`}>
      <div className="table-scroll">
        <table className="data-table">
          <thead>
            <tr>
              {columns.map((column) => (
                <th key={column.key} scope="col">
                  {column.sortable && onSort ? (
                    <button
                      aria-label={`Urutkan berdasarkan ${column.header}`}
                      className="table-sort-button"
                      onClick={() => onSort(column.key, sortBy === column.key && sortOrder === "asc" ? "desc" : "asc")}
                      type="button"
                    >
                      <span>{column.header}</span>
                      {sortBy !== column.key ? <ArrowUpDown size={14} /> : sortOrder === "asc" ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
                    </button>
                  ) : column.header}
                </th>
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
                <td className="table-empty-cell" colSpan={columns.length}>{emptyText}</td>
              </tr>
            ) : (
              rows.map((row, index) => (
                <tr key={index}>
                  {columns.map((column) => (
                    <td data-label={column.header} key={column.key}>{column.render(row)}</td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
      {onPageChange ? (
        <div className="table-pagination">
          <span className="table-pagination-total">{typeof totalRows === "number" ? `${totalRows} data` : null}</span>
          <button aria-label="Halaman sebelumnya" className="icon-button" disabled={page <= 1} onClick={() => onPageChange(page - 1)} title="Halaman sebelumnya">
            <ChevronLeft size={18} />
          </button>
          <span>
            Halaman {page} dari {Math.max(totalPages, 1)}
          </span>
          <button aria-label="Halaman berikutnya" className="icon-button" disabled={page >= totalPages} onClick={() => onPageChange(page + 1)} title="Halaman berikutnya">
            <ChevronRight size={18} />
          </button>
        </div>
      ) : null}
    </div>
  );
}
