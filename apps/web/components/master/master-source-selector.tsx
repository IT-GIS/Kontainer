import { CheckCircle2, GitMerge } from "lucide-react";

export function MasterSourceSelector({
  title,
  customerLabel = "Customer Override",
  globalLabel = "Global Fallback",
  note
}: {
  title: string;
  customerLabel?: string;
  globalLabel?: string;
  note: string;
}) {
  return (
    <section className="workspace-panel master-source-selector" aria-labelledby="master-source-title">
      <div><p className="page-header-eyebrow">Sumber Master</p><h2 id="master-source-title">{title}</h2><span className="muted-text">{note}</span></div>
      <div className="master-source-flow">
        <div><CheckCircle2 size={18} /><span><strong>{customerLabel}</strong><small>Prioritas ketika kode aktif tersedia untuk Customer.</small></span></div>
        <GitMerge aria-hidden="true" size={18} />
        <div><CheckCircle2 size={18} /><span><strong>{globalLabel}</strong><small>Dipakai otomatis ketika override Customer tidak tersedia.</small></span></div>
      </div>
    </section>
  );
}
