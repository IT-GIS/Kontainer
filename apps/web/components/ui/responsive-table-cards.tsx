"use client";

import { ChevronLeft, ChevronRight } from "lucide-react";
import { useState } from "react";

export type ResponsiveColumn<T> = {
  key: string;
  header: React.ReactNode;
  render: (row: T) => React.ReactNode;
};

type ResponsiveTableCardsProps<T> = {
  columns: ResponsiveColumn<T>[];
  rows: T[];
  getRowId: (row: T) => string;
  getRowTitle?: (row: T) => string;
  emptyText?: string;
  label?: string;
  pageSize?: number;
};

export function ResponsiveTableCards<T>({
  columns,
  rows,
  getRowId,
  getRowTitle,
  emptyText = "Data belum tersedia.",
  label = "Daftar data",
  pageSize
}: ResponsiveTableCardsProps<T>) {
  const [page, setPage] = useState(1);
  if (rows.length === 0) {
    return <div className="ui-responsive-empty">{emptyText}</div>;
  }
  const totalPages = pageSize ? Math.max(1, Math.ceil(rows.length / pageSize)) : 1;
  const currentPage = Math.min(page, totalPages);
  const visibleRows = pageSize ? rows.slice((currentPage - 1) * pageSize, currentPage * pageSize) : rows;

  return (
    <div className="ui-responsive-data">
      <div className="table-frame ui-responsive-table">
        <div className="table-scroll">
          <table aria-label={label} className="data-table">
            <thead>
              <tr>
                {columns.map((column) => (
                  <th key={column.key} scope="col">{column.header}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {visibleRows.map((row) => (
                <tr key={getRowId(row)}>
                  {columns.map((column) => (
                    <td key={column.key}>{column.render(row)}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
      <div className="ui-card-list">
        {visibleRows.map((row) => (
          <article aria-label={getRowTitle ? getRowTitle(row) : label} className="ui-row-card" key={getRowId(row)}>
            {getRowTitle ? <h3>{getRowTitle(row)}</h3> : null}
            <dl>
              {columns.map((column) => (
                <div key={column.key}>
                  <dt>{column.header}</dt>
                  <dd>{column.render(row)}</dd>
                </div>
              ))}
            </dl>
          </article>
        ))}
      </div>
      {pageSize && totalPages > 1 ? (
        <nav aria-label={`Pagination ${label}`} className="table-pagination">
          <button aria-label="Halaman sebelumnya" className="icon-button" disabled={currentPage <= 1} onClick={() => setPage(currentPage - 1)} type="button">
            <ChevronLeft size={18} />
          </button>
          <span>Halaman {currentPage} dari {totalPages}</span>
          <button aria-label="Halaman berikutnya" className="icon-button" disabled={currentPage >= totalPages} onClick={() => setPage(currentPage + 1)} type="button">
            <ChevronRight size={18} />
          </button>
        </nav>
      ) : null}
    </div>
  );
}
