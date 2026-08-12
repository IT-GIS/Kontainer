export const jobStatusLabels: Record<string, string> = {
  draft: "Draf",
  assigned: "Ditugaskan",
  in_progress: "Sedang Dikerjakan",
  all_survey_submitted: "Seluruh Survey Terkirim",
  under_review: "Sedang Direview",
  need_revision: "Perlu Revisi",
  all_survey_decided: "Seluruh Survey Diputuskan",
  all_survey_approved: "Seluruh Survey Disetujui",
  completed_with_rejection: "Selesai dengan Penolakan",
  report_generated: "Laporan Tersedia",
  cancelled: "Dibatalkan"
};

export const surveyStatusLabels: Record<string, string> = {
  assigned: "Ditugaskan",
  draft: "Draf",
  submitted: "Terkirim",
  under_review: "Sedang Direview",
  need_revision: "Perlu Revisi",
  resubmitted: "Dikirim Ulang",
  approved: "Disetujui",
  rejected: "Ditolak",
  report_generated: "Laporan Tersedia",
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
  return jobStatusLabels[status] ?? status;
}

export function surveyStatusLabel(status: string): string {
  return surveyStatusLabels[status] ?? status;
}

export function revisionStatusLabel(status: string): string {
  return revisionStatusLabels[status] ?? surveyStatusLabel(status);
}

export function proposalStatusLabel(status: string): string {
  return proposalStatusLabels[status] ?? status;
}

export function cedexCodeTypeLabel(codeType: string): string {
  return cedexCodeTypeLabels[codeType] ?? codeType;
}
