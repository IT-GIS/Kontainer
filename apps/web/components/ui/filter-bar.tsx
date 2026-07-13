import type { LucideIcon } from "lucide-react";
import { Filter, RotateCcw, Search } from "lucide-react";

export type FilterBarField = {
  id: string;
  label: string;
  value?: string;
  placeholder?: string;
  icon?: LucideIcon;
};

type FilterBarProps = {
  fields: FilterBarField[];
  resetHref?: string;
};

export function FilterBar({ fields, resetHref }: FilterBarProps) {
  return (
    <section className="ui-filter-bar" aria-label="Filter data">
      <div className="ui-filter-title">
        <Filter size={16} />
        <strong>Filter</strong>
      </div>
      <div className="ui-filter-fields">
        {fields.map((field) => {
          const Icon = field.icon ?? Search;
          return (
            <label className="ui-filter-field" key={field.id}>
              <span>{field.label}</span>
              <span className="ui-filter-input">
                <Icon size={15} />
                <input readOnly aria-label={field.label} placeholder={field.placeholder} value={field.value ?? ""} />
              </span>
            </label>
          );
        })}
      </div>
      {resetHref ? (
        <a className="secondary-button" href={resetHref}>
          <RotateCcw size={15} />
          <span>Reset</span>
        </a>
      ) : null}
    </section>
  );
}
