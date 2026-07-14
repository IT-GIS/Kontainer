"use client";

import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import { ChevronDown, Filter, RotateCcw, Search } from "lucide-react";
import { useState } from "react";

export type FilterBarOption = {
  value: string;
  label: string;
  disabled?: boolean;
};

export type FilterBarField = {
  id: string;
  label: string;
  type?: "search" | "select" | "date" | "date-range" | "text";
  value?: string;
  endValue?: string;
  placeholder?: string;
  endPlaceholder?: string;
  icon?: LucideIcon;
  options?: FilterBarOption[];
  disabled?: boolean;
};

type FilterBarProps = {
  fields: FilterBarField[];
  resetHref?: string;
  loading?: boolean;
  disabled?: boolean;
  submitLabel?: string;
  resetLabel?: string;
  onChange?: (fieldId: string, value: string, endValue?: string) => void;
  onSubmit?: () => void;
  onReset?: () => void;
};

export function FilterBar({
  fields,
  resetHref,
  loading,
  disabled,
  submitLabel = "Terapkan",
  resetLabel = "Reset",
  onChange,
  onSubmit,
  onReset
}: FilterBarProps) {
  const [collapsed, setCollapsed] = useState(true);
  const activeCount = fields.reduce((count, field) => count + (field.value || field.endValue ? 1 : 0), 0);
  const controlsDisabled = disabled || loading;

  const content = (
    <>
      <div className="ui-filter-head">
        <div className="ui-filter-title">
          <Filter size={16} />
          <strong>Filter</strong>
          {activeCount > 0 ? <span>{activeCount}</span> : null}
        </div>
        <button
          aria-expanded={!collapsed}
          className="secondary-button ui-filter-collapse"
          onClick={() => setCollapsed((current) => !current)}
          type="button"
        >
          <span>{collapsed ? "Tampilkan" : "Sembunyikan"}</span>
          <ChevronDown size={15} />
        </button>
      </div>
      <div className={`ui-filter-fields ${collapsed ? "ui-filter-fields-collapsed" : ""}`}>
        {fields.map((field) => <FilterControl disabled={controlsDisabled} field={field} key={field.id} onChange={onChange} />)}
      </div>
      <div className="ui-filter-actions">
        {onSubmit ? (
          <button className="primary-button" disabled={controlsDisabled} type="submit">
            {loading ? "Memuat..." : submitLabel}
          </button>
        ) : null}
        {onReset ? (
          <button className="secondary-button" disabled={controlsDisabled} onClick={onReset} type="button">
            <RotateCcw size={15} />
            <span>{resetLabel}</span>
          </button>
        ) : resetHref ? (
          <Link className="secondary-button" href={resetHref}>
            <RotateCcw size={15} />
            <span>{resetLabel}</span>
          </Link>
        ) : null}
      </div>
    </>
  );

  if (onSubmit) {
    return (
      <form className="ui-filter-bar" onSubmit={(event) => { event.preventDefault(); onSubmit(); }}>
        {content}
      </form>
    );
  }

  return <section className="ui-filter-bar" aria-label="Filter data">{content}</section>;
}

function FilterControl({
  field,
  disabled,
  onChange
}: {
  field: FilterBarField;
  disabled?: boolean;
  onChange?: (fieldId: string, value: string, endValue?: string) => void;
}) {
  const Icon = field.icon ?? Search;
  const fieldDisabled = disabled || field.disabled;
  const type = field.type ?? "text";

  if (type === "select") {
    return (
      <label className="ui-filter-field">
        <span>{field.label}</span>
        <select
          disabled={fieldDisabled}
          onChange={(event) => onChange?.(field.id, event.target.value)}
          value={field.value ?? ""}
        >
          <option value="">{field.placeholder ?? "Semua"}</option>
          {(field.options ?? []).map((option) => (
            <option disabled={option.disabled} key={option.value} value={option.value}>{option.label}</option>
          ))}
        </select>
      </label>
    );
  }

  if (type === "date-range") {
    return (
      <label className="ui-filter-field ui-filter-date-range">
        <span>{field.label}</span>
        <span className="ui-filter-range-inputs">
          <input
            disabled={fieldDisabled}
            onChange={(event) => onChange?.(field.id, event.target.value, field.endValue ?? "")}
            placeholder={field.placeholder}
            type="date"
            value={field.value ?? ""}
          />
          <input
            disabled={fieldDisabled}
            onChange={(event) => onChange?.(field.id, field.value ?? "", event.target.value)}
            placeholder={field.endPlaceholder}
            type="date"
            value={field.endValue ?? ""}
          />
        </span>
      </label>
    );
  }

  return (
    <label className="ui-filter-field">
      <span>{field.label}</span>
      <span className="ui-filter-input">
        <Icon size={15} />
        <input
          disabled={fieldDisabled}
          onChange={(event) => onChange?.(field.id, event.target.value)}
          placeholder={field.placeholder}
          type={type === "date" ? "date" : type === "search" ? "search" : "text"}
          value={field.value ?? ""}
        />
      </span>
    </label>
  );
}