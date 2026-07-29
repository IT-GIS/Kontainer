"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";

type CodeProposal = {
  id: string;
  survey_id: string;
  survey_no: string;
  container_no: string;
  customer_name: string;
  code_type: string;
  code: string;
  description: string;
  reason: string;
  status: string;
  review_note?: string | null;
  created_at?: string;
};

export default function SurveyorCodeProposalsPage() {
  return <ProtectedRoute><AppShell title="Pengajuan Kode CEDEX"><CodeProposalsContent /></AppShell></ProtectedRoute>;
}
function CodeProposalsContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<CodeProposal[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      setRows(await apiData<CodeProposal[]>("/surveyor/cedex-code-proposals", { accessToken }));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil pengajuan kode CEDEX.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  return <div className="page-stack">
    <PageHeader title="Pengajuan Kode CEDEX" description="Status pengajuan kode yang Anda kirim dari temuan Survey Sheet." />
    {error ? <div className="alert alert-danger">{error}</div> : null}
    <DataTable
      responsiveCards
      isLoading={isLoading}
      rows={rows}
      columns={[
        { key: "survey", header: "Survey", render: (row) => <Link className="text-link" href={`/surveyor/surveys/${row.survey_id}`}>{row.survey_no}</Link> },
        { key: "container", header: "Container", render: (row) => row.container_no },
        { key: "customer", header: "Customer", render: (row) => row.customer_name },
        { key: "type", header: "Jenis Kode", render: (row) => row.code_type.replaceAll("_", " ") },
        { key: "code", header: "Kode Usulan", render: (row) => row.code },
        { key: "description", header: "Description", render: (row) => row.description },
        { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "approved" ? "success" : row.status === "rejected" ? "danger" : "warning"}>{row.status.toUpperCase()}</StatusBadge> },
        { key: "note", header: "Catatan Review", render: (row) => row.review_note ?? "-" }
      ]}
    />
  </div>;
}
