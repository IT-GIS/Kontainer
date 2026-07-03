"use client";

import { QrCode, Search } from "lucide-react";
import { useSearchParams } from "next/navigation";
import { Suspense, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { apiData } from "@/lib/api-client";

type ValidationResult = {
  report_no: string;
  revision_no: number;
  container_no: string;
  customer_name: string;
  survey_date?: string | null;
  status: string;
  surveyor_name: string;
  approver_name?: string | null;
};

export default function QRValidationPage() {
  return <ProtectedRoute><AppShell title="QR Validation"><Suspense fallback={<div className="center-screen">Memuat validator...</div>}><QRValidationContent /></Suspense></AppShell></ProtectedRoute>;
}

function QRValidationContent() {
  const searchParams = useSearchParams();
  const [token, setToken] = useState(searchParams.get("token") ?? "");
  const [result, setResult] = useState<ValidationResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function validate(value = token) {
    if (!value.trim()) {
      setError("QR token wajib diisi.");
      return;
    }
    setLoading(true);
    setError(null);
    setResult(null);
    try {
      setResult(await apiData<ValidationResult>(`/public/reports/validate/${encodeURIComponent(value.trim())}`));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Token report tidak valid.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    const initial = searchParams.get("token");
    if (!initial) return;
    const timer = window.setTimeout(() => void validate(initial), 0);
    return () => window.clearTimeout(timer);
    // initial URL token is intentionally validated once
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return <div className="page-stack">
    <PageHeader title="QR Validation" description="Validasi keaslian report menggunakan token QR." />
    <section className="workspace-panel">
      <div className="toolbar"><label className="search-box"><QrCode size={17} /><input value={token} onChange={(event) => setToken(event.target.value)} placeholder="Masukkan QR token" /></label><button className="primary-button" disabled={loading} onClick={() => void validate()}><Search size={17} /><span>{loading ? "Validating..." : "Validate"}</span></button></div>
    </section>
    {error ? <div className="alert alert-danger">{error}</div> : null}
    {result ? <section className="workspace-panel detail-grid">
      <div><span>Status</span><strong><StatusBadge tone={result.status === "valid" ? "success" : "danger"}>{result.status.toUpperCase()}</StatusBadge></strong></div>
      <div><span>Report</span><strong>{result.report_no} / Rev. {result.revision_no}</strong></div>
      <div><span>Container</span><strong>{result.container_no}</strong></div>
      <div><span>Customer</span><strong>{result.customer_name}</strong></div>
      <div><span>Survey Date</span><strong>{result.survey_date ?? "-"}</strong></div>
      <div><span>Surveyor</span><strong>{result.surveyor_name}</strong></div>
      <div><span>Approver</span><strong>{result.approver_name ?? "-"}</strong></div>
    </section> : null}
  </div>;
}
