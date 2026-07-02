"use client";

import { CheckCircle2, Download, Upload } from "lucide-react";
import { useParams, useRouter } from "next/navigation";
import { useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";

const apiBaseUrl = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080/api/v1";
const sample = `container_no,container_type_code,iso_type_code,seal_no,cargo_status,gross_weight,tare_weight,payload,manufacture_date,csc_plate_status,truck_no,driver_name,remark,check_digit_override_reason
MSKU1234565,20GP,22G1,ABC123,empty,30480,2200,28280,2020-01-01,valid,B1234ABC,Driver Name,Container masuk yard,`;

type ContainerInput = {
  container_no: string;
  container_type_code: string;
  iso_type_code: string;
  seal_no: string;
  cargo_status: string;
  gross_weight?: number;
  tare_weight?: number;
  payload?: number;
  manufacture_date?: string;
  csc_plate_status: string;
  truck_no: string;
  driver_name: string;
  remark: string;
  check_digit_override_reason: string;
};

type PreviewRow = { row: number; data: ContainerInput; valid: boolean; errors: string[] };
type ImportPreview = {
  total_rows: number;
  valid_rows: number;
  failed_rows: number;
  duplicate_rows: number;
  invalid_check_digit_rows: number;
  missing_required_rows: number;
  rows: PreviewRow[];
};
type ImportResult = { total_rows: number; imported: number; failed: number; errors?: Array<Record<string, unknown>> };

export default function ImportContainersPage() {
  return <ProtectedRoute><AppShell title="Import Container"><ImportContent /></AppShell></ProtectedRoute>;
}

function ImportContent() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { accessToken } = useAuth();
  const [content, setContent] = useState(sample);
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<ImportPreview | null>(null);
  const [result, setResult] = useState<ImportResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isPreviewing, setIsPreviewing] = useState(false);
  const [isConfirming, setIsConfirming] = useState(false);

  async function previewImport() {
    if (!accessToken) return;
    setIsPreviewing(true);
    setError(null);
    setResult(null);
    try {
      const formData = new FormData();
      formData.append("file", file ?? new File([content], "containers.csv", { type: "text/csv" }));
      const response = await apiData<ImportPreview>(`/jobs/${params.id}/containers/import/preview`, {
        method: "POST",
        accessToken,
        body: formData
      });
      setPreview(response);
    } catch (err) {
      setPreview(null);
      setError(err instanceof Error ? err.message : "Preview import gagal.");
    } finally {
      setIsPreviewing(false);
    }
  }

  async function confirmImport() {
    if (!accessToken || !preview) return;
    const validRows = preview.rows.filter((row) => row.valid).map((row) => row.data);
    if (validRows.length === 0) {
      setError("Tidak ada baris valid untuk di-import.");
      return;
    }
    setIsConfirming(true);
    setError(null);
    try {
      const response = await apiData<ImportResult>(`/jobs/${params.id}/containers/import/confirm`, {
        method: "POST",
        accessToken,
        body: JSON.stringify({ rows: validRows })
      });
      setResult(response);
      setPreview(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Konfirmasi import gagal.");
    } finally {
      setIsConfirming(false);
    }
  }

  async function downloadTemplate(format: "csv" | "xlsx") {
    if (!accessToken) return;
    setError(null);
    try {
      const response = await fetch(`${apiBaseUrl}/job-containers/import/template?format=${format}`, {
        headers: { Authorization: `Bearer ${accessToken}` }
      });
      if (!response.ok) throw new Error("Template gagal diunduh.");
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = url;
      anchor.download = `container-import-template.${format}`;
      anchor.click();
      URL.revokeObjectURL(url);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Template gagal diunduh.");
    }
  }

  return (
    <div className="page-stack">
      <PageHeader
        title="Import Container"
        description="Upload CSV/XLSX, periksa hasil validasi, lalu konfirmasi baris yang valid."
        action={{ label: isPreviewing ? "Memproses..." : "Preview Import", icon: Upload, onClick: () => void previewImport(), disabled: isPreviewing || isConfirming }}
      />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      {result ? <div className="alert alert-success"><CheckCircle2 size={18} /> Import selesai: {result.imported} dari {result.total_rows} baris berhasil.</div> : null}

      <section className="workspace-panel page-stack">
        <label className="field">
          <span>File CSV atau XLSX</span>
          <input type="file" accept=".csv,.xlsx,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" onChange={(event) => { setFile(event.target.files?.[0] ?? null); setPreview(null); }} />
        </label>
        <p className="muted-text">Atau gunakan data CSV berikut bila tidak memilih file.</p>
        <label className="field"><span>Data CSV</span><textarea className="code-area" rows={10} value={content} onChange={(event) => { setContent(event.target.value); setFile(null); setPreview(null); }} /></label>
        <div className="dialog-actions inline-actions">
          <button className="secondary-button" onClick={() => router.push(`/jobs/${params.id}`)}>Back to Job</button>
          <button className="secondary-button" onClick={() => void downloadTemplate("csv")}><Download size={18} /><span>Template CSV</span></button>
          <button className="secondary-button" onClick={() => void downloadTemplate("xlsx")}><Download size={18} /><span>Template XLSX</span></button>
          <button className="primary-button" onClick={() => void previewImport()} disabled={isPreviewing || isConfirming}><Upload size={18} /><span>Preview Import</span></button>
        </div>
      </section>

      {preview ? (
        <section className="page-stack">
          <div className="metric-grid">
            {[
              ["Total", preview.total_rows], ["Valid", preview.valid_rows], ["Failed", preview.failed_rows],
              ["Duplicate", preview.duplicate_rows], ["Invalid Check Digit", preview.invalid_check_digit_rows], ["Missing Required", preview.missing_required_rows]
            ].map(([label, value]) => <div className="metric-tile" key={label}><p>{label}</p><strong>{value}</strong></div>)}
          </div>
          <DataTable
            rows={preview.rows}
            columns={[
              { key: "row", header: "Row", render: (row) => row.row },
              { key: "container_no", header: "Container", render: (row) => row.data.container_no || "-" },
              { key: "type", header: "Type", render: (row) => row.data.container_type_code || "-" },
              { key: "cargo", header: "Cargo", render: (row) => row.data.cargo_status || "-" },
              { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.valid ? "success" : "danger"}>{row.valid ? "VALID" : "ERROR"}</StatusBadge> },
              { key: "errors", header: "Validation", render: (row) => row.errors.join("; ") || "Siap di-import" }
            ]}
          />
          <div className="dialog-actions inline-actions">
            <button className="primary-button" onClick={() => void confirmImport()} disabled={isConfirming || preview.valid_rows === 0}>
              <CheckCircle2 size={18} /><span>{isConfirming ? "Importing..." : `Confirm ${preview.valid_rows} Valid Rows`}</span>
            </button>
          </div>
        </section>
      ) : null}
    </div>
  );
}
