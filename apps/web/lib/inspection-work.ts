import { apiData, apiPaginated, buildQuery } from "@/lib/api-client";
import type { InspectionWorkDataset, InspectionWorkRow, InspectionWorkStage } from "@/types/inspection-work";
import type { JobDetail, JobSummary } from "@/types/jobs";
import type { ReportSummary, ReviewDetail } from "@/types/reviews";
import type { SurveyListItem } from "@/types/surveys";

const completedContainerStatuses = new Set(["approved", "reported", "report_generated"]);

export async function loadInspectionWorkDataset(accessToken: string): Promise<InspectionWorkDataset> {
  const warnings: string[] = [];
  const jobs = await loadAllPages<JobSummary>("/jobs", accessToken);
  const [surveys, documents] = await Promise.all([
    loadAllPages<SurveyListItem>("/surveys/monitoring", accessToken).catch(() => {
      warnings.push("Data monitoring survey tidak dapat dimuat untuk sesi ini.");
      return [];
    }),
    loadAllPages<ReportSummary>("/reports", accessToken).catch(() => {
      warnings.push("Metadata dokumen tidak dapat dimuat untuk sesi ini.");
      return [];
    })
  ]);

  const details = await mapConcurrent(jobs, 6, async (job) => {
    try {
      return await apiData<JobDetail>(`/jobs/${job.id}`, { accessToken });
    } catch {
      warnings.push(`Detail ${job.job_order_no} tidak dapat dimuat lengkap.`);
      return { ...job, containers: [], assignments: [], timeline: [] } satisfies JobDetail;
    }
  });
  const reviewDetails = await mapConcurrent(surveys, 6, async (survey) => {
    try {
      return await apiData<ReviewDetail>(`/reviews/${survey.survey_id}`, { accessToken });
    } catch {
      return null;
    }
  });

  const surveysByJob = groupBy(surveys, (item) => item.job_order_no);
  const reviewsByJob = groupBy(
    reviewDetails.filter((item): item is ReviewDetail => item !== null),
    (item) => item.job_order_no
  );
  const documentsByJob = groupBy(documents, (item) => item.job_order_no);

  return {
    rows: details.map((job) => buildInspectionRow(
      job,
      surveysByJob.get(job.job_order_no) ?? [],
      reviewsByJob.get(job.job_order_no) ?? [],
      documentsByJob.get(job.job_order_no) ?? []
    )),
    warnings: Array.from(new Set(warnings))
  };
}

export function matchesInspectionView(row: InspectionWorkRow, view: string): boolean {
  if (view === "all") return true;
  if (view === "pending-review") return row.stage === "submitted";
  return row.stage === view;
}

export async function loadAllPages<T>(endpoint: string, accessToken: string): Promise<T[]> {
  const rows: T[] = [];
  let page = 1;
  let totalPages = 1;
  do {
    const result = await apiPaginated<T>(`${endpoint}${buildQuery({ page, per_page: 100 })}`, { accessToken });
    rows.push(...result.rows);
    totalPages = Math.max(1, Number(result.meta.total_pages ?? 1));
    page += 1;
  } while (page <= totalPages);
  return rows;
}

function buildInspectionRow(
  job: JobDetail,
  surveys: SurveyListItem[],
  surveyDetails: ReviewDetail[],
  documents: ReportSummary[]
): InspectionWorkRow {
  const containers = job.containers ?? [];
  const assignments = job.assignments ?? [];
  const surveyorNames = Array.from(new Set(assignments.map((item) => item.surveyor_name).filter(Boolean)));
  const completedContainers = containers.filter((item) => completedContainerStatuses.has(item.status)).length;
  const revisionOpen = surveys.some((item) => item.status === "need_revision");
  const allContainersCompleted = containers.length > 0 && completedContainers === containers.length;
  const approvalHistory = surveyDetails.flatMap((item) => item.approval_history ?? []);
  const rejected = surveys.some((item) => item.status === "rejected") || approvalHistory.some((item) => String(item.decision) === "rejected");
  const stage = deriveStage(job, surveys, documents.length > 0, allContainersCompleted, revisionOpen, rejected);
  const deadline = job.deadline ? new Date(job.deadline).getTime() : Number.NaN;
  const isOverdue = Number.isFinite(deadline) && deadline < Date.now() && stage !== "completed";
  const progressPercent = calculateProgress(containers.map((item) => item.status));
  const updatedCandidates = [
    job.updated_at,
    job.created_at,
    ...surveys.flatMap((item) => [item.approved_at, item.submitted_at, item.started_at]),
    ...documents.map((item) => item.created_at)
  ].filter((item): item is string => Boolean(item));

  return {
    id: job.id,
    job,
    surveys,
    surveyDetails,
    documents,
    stage,
    assignmentStatus: assignments.length > 0 ? "Sudah ditugaskan" : "Belum ditugaskan",
    surveyorNames,
    progressPercent,
    completedContainers,
    findingCount: surveyDetails.reduce((total, item) => total + (item.damages?.length ?? 0), 0),
    photoCount: surveyDetails.reduce((total, item) => total + (item.photos?.length ?? 0), 0),
    reviewStatus: rejected
      ? "Ditolak"
      : revisionOpen
        ? "Perlu revisi"
        : surveys.some((item) => item.status === "submitted")
          ? "Sudah dikirim"
          : surveys.length > 0 && surveys.every((item) => item.status === "approved")
            ? "Disetujui"
            : "Belum direview",
    documentStatus: documents[0]?.status ?? "Belum tersedia",
    lastUpdated: latestDate(updatedCandidates) ?? job.created_at,
    isOverdue,
    readiness: [
      { label: "Customer tersedia", ready: Boolean(job.customer_id) },
      { label: "PIC tersedia", ready: Boolean(job.pic_customer_name) },
      { label: "Location tersedia", ready: Boolean(job.location_id) },
      { label: "Survey Type tersedia", ready: Boolean(job.survey_type_id) },
      { label: "Minimal satu peti kemas", ready: containers.length > 0 },
      { label: "Container Type tersedia", ready: containers.length > 0 && containers.every((item) => Boolean(item.container_type_id ?? item.container_type_code)) },
      { label: "Instruksi tersedia", ready: Boolean(job.instruction?.trim()) },
      { label: "Surveyor GIFT aktif tersedia", ready: assignments.length > 0 }
    ]
  };
}

function deriveStage(
  job: JobDetail,
  surveys: SurveyListItem[],
  hasDocument: boolean,
  allContainersCompleted: boolean,
  revisionOpen: boolean,
  rejected: boolean
): InspectionWorkStage {
  if (rejected) return "rejected";
  if (revisionOpen) return "need-revision";
  if (surveys.some((item) => item.status === "submitted")) return "submitted";
  if (surveys.length > 0 && surveys.every((item) => item.status === "approved")) {
    return allContainersCompleted && hasDocument && job.status !== "cancelled" ? "completed" : "approved";
  }
  if (job.status === "closed" && hasDocument) return "completed";
  if (job.status === "in_progress" || surveys.some((item) => item.status === "draft" || item.status === "in_progress")) {
    return "in-progress";
  }
  if ((job.assignments?.length ?? 0) > 0 || job.status === "assigned") return "assigned";
  if ((job.containers?.length ?? 0) > 0 && (job.assignments?.length ?? 0) === 0) {
    return "unassigned";
  }
  return "draft";
}

function calculateProgress(statuses: string[]): number {
  if (statuses.length === 0) return 0;
  const weights: Record<string, number> = {
    not_started: 0,
    assigned: 10,
    draft: 40,
    in_progress: 50,
    need_revision: 60,
    submitted: 75,
    rejected: 75,
    approved: 90,
    reported: 100,
    report_generated: 100
  };
  return Math.round(statuses.reduce((total, status) => total + (weights[status] ?? 0), 0) / statuses.length);
}

function latestDate(values: string[]): string | null {
  return values.reduce<string | null>((latest, value) => {
    if (!latest) return value;
    return new Date(value).getTime() > new Date(latest).getTime() ? value : latest;
  }, null);
}

function groupBy<T>(items: T[], key: (item: T) => string): Map<string, T[]> {
  const grouped = new Map<string, T[]>();
  for (const item of items) {
    const value = key(item);
    grouped.set(value, [...(grouped.get(value) ?? []), item]);
  }
  return grouped;
}

async function mapConcurrent<T, R>(items: T[], limit: number, worker: (item: T) => Promise<R>): Promise<R[]> {
  const results = new Array<R>(items.length);
  let cursor = 0;
  async function run() {
    while (cursor < items.length) {
      const index = cursor;
      cursor += 1;
      results[index] = await worker(items[index]);
    }
  }
  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, () => run()));
  return results;
}
