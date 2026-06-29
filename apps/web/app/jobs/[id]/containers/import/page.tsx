"use client";

import { Upload } from "lucide-react";
import { useParams, useRouter } from "next/navigation";
import { useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";

const sample = `container_no,container_type_code,iso_type_code,seal_no,cargo_status,truck_no,driver_name,remark
MSKU1234567,20GP,22G1,ABC123,empty,B1234ABC,Driver Name,Container masuk yard`;

export default function ImportContainersPage() {
  return <ProtectedRoute><AppShell title="Import Container"><ImportContent /></AppShell></ProtectedRoute>;
}

function ImportContent() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { accessToken } = useAuth();
  const [content, setContent] = useState(sample);
  const [result, setResult] = useState<Record<string, unknown> | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function submit() {
    if (!accessToken) return;
    setIsSubmitting(true); setError(null); setResult(null);
    try {
      const formData = new FormData();
      formData.append("file", new Blob([content], { type: "text/csv" }), "containers.csv");
      const response = await apiData<Record<string, unknown>>(`/jobs/${params.id}/containers/import`, { method: "POST", accessToken, body: formData });
      setResult(response);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Import gagal.");
    } finally { setIsSubmitting(false); }
  }

  return (
    <div className="page-stack">
      <PageHeader title="Import Container" description="Paste CSV or JSON array data for this job." action={{ label: isSubmitting ? "Importing" : "Import", icon: Upload, onClick: () => void submit(), disabled: isSubmitting }} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <section className="workspace-panel">
        <label className="field"><span>Import Data</span><textarea className="code-area" rows={14} value={content} onChange={(event) => setContent(event.target.value)} /></label>
        <div className="dialog-actions inline-actions">
          <button className="secondary-button" onClick={() => router.push(`/jobs/${params.id}`)}>Back to Job</button>
          <button className="primary-button" onClick={() => void submit()} disabled={isSubmitting}><Upload size={18} /><span>Import</span></button>
        </div>
      </section>
      {result ? <section className="workspace-panel"><pre>{JSON.stringify(result, null, 2)}</pre></section> : null}
    </div>
  );
}
