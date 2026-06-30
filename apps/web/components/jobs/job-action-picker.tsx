"use client";

import { ArrowRight, Plus } from "lucide-react";
import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated } from "@/lib/api-client";
import { can } from "@/lib/permissions";
import type { JobSummary } from "@/types/jobs";

type JobActionPickerProps = {
  mode: "import" | "assign";
};

export function JobActionPicker({ mode }: JobActionPickerProps) {
  const { accessToken, user } = useAuth();
  const [rows, setRows] = useState<JobSummary[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const canCreate = can(user, "jobs.create.all");
  const title = mode === "import" ? "Import Container" : "Assign Surveyor";
  const description = mode === "import"
    ? "Pilih job sebelum membuka halaman import container."
    : "Pilih job sebelum membuka dialog assignment surveyor.";

  const loadRows = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<JobSummary>("/jobs?page=1&per_page=100", { accessToken });
      setRows(result.rows);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil daftar job.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken]);

  useEffect(() => {
    const timer = window.setTimeout(() => void loadRows(), 0);
    return () => window.clearTimeout(timer);
  }, [loadRows]);

  return (
    <div className="page-stack">
      <PageHeader title={title} description={description} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      {!isLoading && !error && rows.length === 0 ? (
        <section className="workspace-panel">
          <h2>Belum ada job</h2>
          <p className="muted-text">Buat job terlebih dahulu sebelum melanjutkan proses ini.</p>
          <div className="job-actions">
            <Link className="secondary-button" href="/jobs">Kembali ke Job List</Link>
            {canCreate ? <Link className="primary-button" href="/jobs/create"><Plus size={17} /><span>Create Job</span></Link> : null}
          </div>
        </section>
      ) : (
        <DataTable
          rows={rows}
          isLoading={isLoading}
          columns={[
            { key: "job", header: "Job No", render: (row) => row.job_order_no },
            { key: "customer", header: "Customer", render: (row) => row.customer_name },
            { key: "type", header: "Survey Type", render: (row) => row.survey_type_name },
            { key: "containers", header: "Containers", render: (row) => row.total_containers ?? 0 },
            { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "cancelled" ? "danger" : "success"}>{row.status.toUpperCase()}</StatusBadge> },
            {
              key: "action",
              header: "Action",
              render: (row) => (
                <Link
                  className="primary-button table-action"
                  href={mode === "import" ? `/jobs/${row.id}/containers/import` : `/jobs/${row.id}?action=assign`}
                >
                  <span>Pilih</span><ArrowRight size={15} />
                </Link>
              )
            }
          ]}
        />
      )}
    </div>
  );
}
