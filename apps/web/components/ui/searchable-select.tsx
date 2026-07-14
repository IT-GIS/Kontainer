"use client";

import { useEffect, useId, useMemo, useRef, useState } from "react";
import { Check, ChevronDown, Loader2, X } from "lucide-react";

export type SearchableSelectOption = {
  value: string;
  label: string;
  description?: string;
  disabled?: boolean;
};

type SearchableSelectProps = {
  label: string;
  value?: string | null;
  onChange?: (value: string | null, option?: SearchableSelectOption) => void;
  searchValue?: string;
  onSearchChange?: (value: string) => void;
  options: SearchableSelectOption[];
  placeholder?: string;
  disabled?: boolean;
  required?: boolean;
  loading?: boolean;
  error?: string;
  emptyText?: string;
  clearable?: boolean;
  id?: string;
  name?: string;
  showLabel?: boolean;
};

export function SearchableSelect({
  label,
  value = null,
  onChange,
  searchValue,
  onSearchChange,
  options,
  placeholder = "Pilih data",
  disabled,
  required,
  loading,
  error,
  emptyText = "Data tidak ditemukan.",
  clearable,
  id,
  name,
  showLabel = true
}: SearchableSelectProps) {
  const generatedId = useId();
  const inputId = id ?? generatedId;
  const listboxId = `${inputId}-listbox`;
  const errorId = `${inputId}-error`;
  const rootRef = useRef<HTMLDivElement | null>(null);
  const inputRef = useRef<HTMLInputElement | null>(null);
  const [open, setOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const [internalSearch, setInternalSearch] = useState("");
  const selectedOption = options.find((option) => option.value === value);
  const search = searchValue ?? internalSearch;
  const usesExternalSearch = typeof searchValue === "string" || typeof onSearchChange === "function";

  const visibleOptions = useMemo(() => {
    const normalized = search.trim().toLowerCase();
    if (usesExternalSearch || normalized.length === 0) return options;
    return options.filter((option) => {
      return [option.label, option.description].filter(Boolean).some((part) => part!.toLowerCase().includes(normalized));
    });
  }, [options, search, usesExternalSearch]);

  const enabledOptions = visibleOptions.filter((option) => !option.disabled);
  const activeOption = visibleOptions[activeIndex];
  const activeOptionId = activeOption ? `${listboxId}-${activeOption.value}` : undefined;

  useEffect(() => {
    if (!open) return;
    const handlePointerDown = (event: MouseEvent) => {
      if (!rootRef.current?.contains(event.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handlePointerDown);
    return () => document.removeEventListener("mousedown", handlePointerDown);
  }, [open]);

  useEffect(() => {
    if (!open) return;
    const firstEnabledIndex = visibleOptions.findIndex((option) => !option.disabled);
    setActiveIndex(firstEnabledIndex >= 0 ? firstEnabledIndex : 0);
  }, [open, visibleOptions]);

  const updateSearch = (nextValue: string) => {
    if (onSearchChange) onSearchChange(nextValue);
    if (typeof searchValue !== "string") setInternalSearch(nextValue);
  };

  const selectOption = (option: SearchableSelectOption) => {
    if (option.disabled || disabled) return;
    onChange?.(option.value, option);
    updateSearch(option.label);
    setOpen(false);
  };

  const clearValue = () => {
    if (disabled) return;
    onChange?.(null);
    updateSearch("");
    setOpen(false);
    inputRef.current?.focus();
  };

  const moveActive = (direction: 1 | -1) => {
    if (enabledOptions.length === 0) return;
    const currentValue = visibleOptions[activeIndex]?.value;
    const enabledIndex = Math.max(0, enabledOptions.findIndex((option) => option.value === currentValue));
    const nextEnabled = enabledOptions[(enabledIndex + direction + enabledOptions.length) % enabledOptions.length];
    const nextIndex = visibleOptions.findIndex((option) => option.value === nextEnabled.value);
    setActiveIndex(nextIndex >= 0 ? nextIndex : 0);
  };

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "ArrowDown") {
      event.preventDefault();
      setOpen(true);
      moveActive(1);
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      setOpen(true);
      moveActive(-1);
    } else if (event.key === "Enter") {
      if (!open) return;
      event.preventDefault();
      if (activeOption) selectOption(activeOption);
    } else if (event.key === "Escape") {
      if (!open) return;
      event.preventDefault();
      setOpen(false);
    }
  };

  const handleFocus = () => {
    if (disabled) return;
    setOpen(true);
    if (!search && selectedOption) updateSearch(selectedOption.label);
  };

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    updateSearch(event.target.value);
    setOpen(true);
  };

  const displayValue = open || search ? search : selectedOption?.label ?? "";

  return (
    <div className={`ui-searchable-select ${disabled ? "ui-control-disabled" : ""}`} ref={rootRef}>
      {showLabel ? (
        <label className="ui-form-label" htmlFor={inputId}>
          {label}
          {required ? <strong aria-label="wajib">*</strong> : null}
        </label>
      ) : null}
      <div className={`ui-combobox-shell ${error ? "ui-control-error" : ""}`}>
        <input
          aria-activedescendant={open ? activeOptionId : undefined}
          aria-controls={listboxId}
          aria-describedby={error ? errorId : undefined}
          aria-expanded={open}
          aria-invalid={error ? true : undefined}
          aria-required={required}
          autoComplete="off"
          disabled={disabled}
          id={inputId}
          name={name}
          onChange={handleInputChange}
          onFocus={handleFocus}
          onKeyDown={handleKeyDown}
          placeholder={placeholder}
          ref={inputRef}
          role="combobox"
          type="text"
          value={displayValue}
        />
        {loading ? <Loader2 className="ui-spin" size={16} /> : null}
        {clearable && value ? (
          <button aria-label={`Bersihkan ${label}`} disabled={disabled} onClick={clearValue} type="button">
            <X size={15} />
          </button>
        ) : null}
        <button
          aria-label={open ? "Tutup pilihan" : "Buka pilihan"}
          disabled={disabled}
          onClick={() => setOpen((current) => !current)}
          type="button"
        >
          <ChevronDown size={16} />
        </button>
      </div>
      {error ? <p className="ui-control-message" id={errorId}>{error}</p> : null}
      {open ? (
        <div className="ui-searchable-options" id={listboxId} role="listbox">
          {visibleOptions.length === 0 || loading ? (
            <div className="ui-searchable-empty" role="status">{loading ? "Memuat data..." : emptyText}</div>
          ) : visibleOptions.map((option, index) => {
            const selected = option.value === value;
            return (
              <button
                aria-disabled={option.disabled}
                aria-selected={selected}
                className={`${selected ? "ui-searchable-option-active" : ""} ${index === activeIndex ? "ui-searchable-option-focus" : ""}`}
                disabled={option.disabled}
                id={`${listboxId}-${option.value}`}
                key={option.value}
                onClick={() => selectOption(option)}
                role="option"
                type="button"
              >
                <span>
                  <strong>{option.label}</strong>
                  {option.description ? <small>{option.description}</small> : null}
                </span>
                {selected ? <Check size={15} /> : null}
              </button>
            );
          })}
        </div>
      ) : null}
    </div>
  );
}