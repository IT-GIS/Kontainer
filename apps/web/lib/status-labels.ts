export const jobStatusLabels: Record<string, string> = {
  draft: "Draf",
  assigned: "Sedang Dikerjakan",
  in_progress: "Sedang Dikerjakan",
  all_survey_submitted: "Menunggu Review",
  under_review: "Menunggu Review",
  need_revision: "Perlu Revisi",
  all_survey_decided: "Selesai",
  all_survey_approved: "Selesai",
  completed_with_rejection: "Selesai dengan Penolakan",
  report_generated: "Selesai",
  completed: "Selesai",
  closed: "Selesai",
  cancelled: "Dibatalkan"
};

export const surveyStatusLabels: Record<string, string> = {
  assigned: "Belum Dimulai",
  not_started: "Belum Dimulai",
  draft: "Sedang Dikerjakan",
  in_progress: "Sedang Dikerjakan",
  submitted: "Menunggu Review",
  under_review: "Menunggu Review",
  need_revision: "Perlu Revisi",
  resubmitted: "Menunggu Review",
  approved: "Disetujui",
  rejected: "Ditolak",
  report_generated: "Selesai",
  cancelled: "Dibatalkan"
};

export const revisionStatusLabels: Record<string, string> = {
  requested: "Diminta",
  resubmitted: "Dikirim Ulang",
  resolved: "Selesai",
  cancelled: "Dibatalkan"
};

export const proposalStatusLabels: Record<string, string> = {
  pending: "Menunggu Review",
  approved: "Disetujui",
  rejected: "Ditolak"
};

export const cedexCodeTypeLabels: Record<string, string> = {
  location: "Lokasi",
  component: "Komponen",
  damage: "Kerusakan",
  action_repair: "Tindakan Perbaikan",
  material: "Material"
};

export function jobStatusLabel(status: string): string {
  return jobStatusLabels[status] ?? humanizeStatus(status);
}

export function surveyStatusLabel(status: string): string {
  return surveyStatusLabels[status] ?? humanizeStatus(status);
}

export function revisionStatusLabel(status: string): string {
  return revisionStatusLabels[status] ?? surveyStatusLabel(status);
}

export function proposalStatusLabel(status: string): string {
  return proposalStatusLabels[status] ?? humanizeStatus(status);
}

export function cedexCodeTypeLabel(codeType: string): string {
  return cedexCodeTypeLabels[codeType] ?? humanizeStatus(codeType);
}

export function humanizeStatus(value: string): string {
  return value
    .replaceAll("_", " ")
    .replaceAll("-", " ")
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
}
