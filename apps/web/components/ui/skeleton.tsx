type SkeletonProps = {
  variant?: "cards" | "master" | "table" | "form";
  count?: number;
  label?: string;
};

export function Skeleton({ variant = "cards", count, label = "Memuat data" }: SkeletonProps) {
  const itemCount = count ?? (variant === "master" ? 6 : variant === "table" ? 5 : 4);
  const gridClass = variant === "master" ? "master-data-card-grid" : "fitness-card-grid";

  return (
    <section className={`workspace-panel skeleton-panel ui-skeleton-${variant}`} aria-busy="true" aria-label={label}>
      <div className="skeleton-line skeleton-title" />
      {variant === "table" ? (
        <div className="ui-skeleton-table">
          {Array.from({ length: itemCount }, (_, index) => (
            <div className="skeleton-line" key={index} />
          ))}
        </div>
      ) : (
        <div className={variant === "form" ? "ui-skeleton-form" : gridClass}>
          {Array.from({ length: itemCount }, (_, index) => (
            <div className="skeleton-card" key={index}>
              <div className="skeleton-icon" />
              <div className="skeleton-line" />
              <div className="skeleton-line skeleton-short" />
            </div>
          ))}
        </div>
      )}
    </section>
  );
}
