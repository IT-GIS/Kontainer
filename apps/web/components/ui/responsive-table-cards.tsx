export type ResponsiveColumn<T> = {
  key: string;
  header: string;
  render: (row: T) => React.ReactNode;
};

type ResponsiveTableCardsProps<T> = {
  columns: ResponsiveColumn<T>[];
  rows: T[];
  getRowId: (row: T) => string;
  getRowTitle?: (row: T) => string;
  emptyText?: string;
};

export function ResponsiveTableCards<T>({
  columns,
  rows,
  getRowId,
  getRowTitle,
  emptyText = "Data belum tersedia."
}: ResponsiveTableCardsProps<T>) {
  if (rows.length === 0) {
    return <div className="ui-responsive-empty">{emptyText}</div>;
  }

  return (
    <div className="ui-responsive-data">
      <div className="table-frame ui-responsive-table">
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
              {rows.map((row) => (
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
        {rows.map((row) => (
          <article className="ui-row-card" key={getRowId(row)}>
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
    </div>
  );
}
