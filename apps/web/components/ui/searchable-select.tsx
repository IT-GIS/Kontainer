type SearchableSelectOption = {
  value: string;
  label: string;
  description?: string;
};

type SearchableSelectProps = {
  label: string;
  value?: string;
  options: SearchableSelectOption[];
  placeholder?: string;
};

export function SearchableSelect({ label, value, options, placeholder = "Pilih data" }: SearchableSelectProps) {
  const selected = options.find((option) => option.value === value);

  return (
    <div className="ui-searchable-select" aria-label={label}>
      <input readOnly aria-label={`${label} pencarian`} placeholder={placeholder} value={selected?.label ?? ""} />
      <div className="ui-searchable-options">
        {options.map((option) => (
          <span className={option.value === value ? "ui-searchable-option-active" : ""} key={option.value}>
            <strong>{option.label}</strong>
            {option.description ? <small>{option.description}</small> : null}
          </span>
        ))}
      </div>
    </div>
  );
}
