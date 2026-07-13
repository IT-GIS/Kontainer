type FormFieldProps = {
  label: string;
  children: React.ReactNode;
  helpText?: string;
  error?: string;
  required?: boolean;
};

export function FormField({ label, children, helpText, error, required }: FormFieldProps) {
  return (
    <label className={`ui-form-field ${error ? "ui-form-field-error" : ""}`}>
      <span className="ui-form-label">
        {label}
        {required ? <strong aria-label="wajib">*</strong> : null}
      </span>
      {children}
      {helpText ? <small>{helpText}</small> : null}
      {error ? <em>{error}</em> : null}
    </label>
  );
}
