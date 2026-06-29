"use client";

import { Play, RotateCcw } from "lucide-react";
import { useParams, useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import type { SurveyorContainer, SurveyorJobDetail } from "@/types/surveyor";

export default function SurveyorJobDetailPage() {
  return <ProtectedRoute><AppShell title="Detail Job Saya"><SurveyorJobDetailContent /></AppShell></ProtectedRoute>;
}

function SurveyorJobDetailContent() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { accessToken } = useAuth();
  const [job, setJob] = useState<SurveyorJobDetail | null>(null);
  const [containers, setContainers] = useState<SurveyorContainer[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [isStarting, setIsStarting] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    if (!accessToken || !params.id) return;
    setError(null);
    try {
      const [detail, assignedContainers] = await Promise.all([
        apiData<SurveyorJobDetail>(`/surveyor/jobs/${params.id}`, { accessToken }),
        apiData<SurveyorContainer[]>(`/surveyor/jobs/${params.id}/containers`, { accessToken })
      ]);
      setJob(detail);
      setContainers(assignedContainers);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil detail job.");
    }
  }, [accessToken, params.id]);

  useEffect(() => { const timer = window.setTimeout(() => void loadData(), 0); return () => window.clearTimeout(timer); }, [loadData]);

  async function startSurvey(container: SurveyorContainer) {
    if (!accessToken) return;
    if (container.survey_id) {
      router.push(`/surveyor/surveys/${container.survey_id}`);
      return;
    }
    setIsStarting(container.id);
    setError(null);
    try {
      const survey = await apiData<{ id: string }>("/surveys/start", { method: "POST", accessToken, body: JSON.stringify({ job_container_id: container.id }) });
      router.push(`/surveyor/surveys/${survey.id}`);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal memulai survey.");
    } finally {
      setIsStarting(null);
    }
  }

  if (!job) {
    return <div className="center-screen">Memuat job...</div>;
  }

  return (
    <div className="page-stack">
      <PageHeader title={`Job Detail: ${job.job_order_no}`} description={`${job.customer_name} - ${job.location_name} - ${job.survey_type_name}`} />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <section className="workspace-panel detail-grid">
        <div><span>Status</span><strong><StatusBadge tone={job.status === "assigned" ? "warning" : "success"}>{job.status.toUpperCase()}</StatusBadge></strong></div>
        <div><span>Job Date</span><strong>{job.job_date ?? "-"}</strong></div>
        <div><span>Deadline</span><strong>{job.deadline ?? "-"}</strong></div>
        <div><span>Instruction</span><strong>{job.instruction ?? "-"}</strong></div>
      </section>
      <section className="workspace-panel">
        <div className="section-title-row">
          <div>
            <h2>Container List</h2>
            <p className="muted-text">Hanya container yang ditugaskan kepada Anda yang ditampilkan.</p>
          </div>
          <button className="secondary-button" onClick={() => void loadData()}><RotateCcw size={17} /><span>Refresh</span></button>
        </div>
        <DataTable
          rows={containers}
          columns={[
            { key: "container_no", header: "Container No", render: (row) => row.container_no },
            { key: "type", header: "Type", render: (row) => row.container_type_code ?? "-" },
            { key: "seal", header: "Seal", render: (row) => row.seal_no ?? "-" },
            { key: "cargo", header: "Cargo", render: (row) => row.cargo_status },
            { key: "status", header: "Survey Status", render: (row) => <StatusBadge tone={row.status === "assigned" ? "warning" : row.status === "submitted" ? "neutral" : "success"}>{statusLabel(row.status)}</StatusBadge> },
            { key: "action", header: "Action", render: (row) => <button className="primary-button table-action" disabled={isStarting === row.id} onClick={() => void startSurvey(row)}><Play size={16} /><span>{actionLabel(row)}</span></button> }
          ]}
        />
      </section>
    </div>
  );
}

function actionLabel(row: SurveyorContainer) {
  if (row.survey_id && row.status === "need_revision") return "Revise";
  if (row.survey_id && row.status === "draft") return "Continue";
  if (row.survey_id) return "View";
  return "Start Survey";
}

function statusLabel(status: string) {
  return status.replaceAll("_", " ").toUpperCase();
}

