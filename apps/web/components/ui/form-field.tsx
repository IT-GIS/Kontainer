type FormFieldProps = {
  label?: string;
  children: React.ReactNode;
  id?: string;
  htmlFor?: string;
  helpText?: string;
  helpTextId?: string;
  error?: string;
  errorId?: string;
  required?: boolean;
  optionalLabel?: string;
  errorSummaryId?: string;
};

export function FormField({
  label,
  children,
  id,
  htmlFor,
  helpText,
  helpTextId,
  error,
  errorId,
  required,
  optionalLabel = "Opsional",
  errorSummaryId
}: FormFieldProps) {
  const controlId = htmlFor ?? id;
  const resolvedHelpTextId = helpTextId ?? (controlId ? `${controlId}-help` : undefined);
  const resolvedErrorId = errorId ?? (controlId ? `${controlId}-error` : undefined);
  const describedBy = [helpText ? resolvedHelpTextId : null, error ? resolvedErrorId : null, errorSummaryId].filter(Boolean).join(" ") || undefined;

  return (
    <div aria-describedby={describedBy} className={`ui-form-field ${error ? "ui-form-field-error" : ""}`}>
      {label ? (
        <label className="ui-form-label" htmlFor={controlId}>
          {label}
          {required ? <strong aria-label="wajib">*</strong> : <span>{optionalLabel}</span>}
        </label>
      ) : null}
      {children}
      {helpText ? <small id={resolvedHelpTextId}>{helpText}</small> : null}
      {error ? <em id={resolvedErrorId}>{error}</em> : null}
    </div>
  );
}