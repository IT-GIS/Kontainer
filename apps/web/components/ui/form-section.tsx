type FormSectionProps = {
  title: string;
  description?: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
};

export function FormSection({ title, description, children, footer }: FormSectionProps) {
  return (
    <section className="ui-form-section">
      <header>
        <h2>{title}</h2>
        {description ? <p>{description}</p> : null}
      </header>
      <div className="ui-form-section-grid">{children}</div>
      {footer ? <div className="ui-form-section-footer">{footer}</div> : null}
    </section>
  );
}
