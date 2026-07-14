import type {
  FitnessApplicationDetail,
  FitnessApplicationDraft,
  FitnessApplicationReadiness,
  FitnessDashboardAction,
  FitnessDashboardActivity,
  FitnessDashboardMetric,
  FitnessDashboardQuickAction
} from "@/types/fitness-admin";


export const fitnessApplicationSteps = [
  { id: "client", label: "Klien dan Pemohon", description: "Pisahkan identitas Klien, Pemohon, dan Pemilik/Pengguna." },
  { id: "information", label: "Informasi Permohonan", description: "Tanggal, kategori layanan, dan surat." },
  { id: "location", label: "Lokasi dan PIC", description: "Pilihan aktif dari Master Data Klien." },
  { id: "containers", label: "Peti Kemas", description: "Data awal untuk UI-C, bukan form teknis UI-D." },
  { id: "instructions", label: "Instruksi Pemeriksaan", description: "Instruksi dan referensi khusus klien." },
  { id: "attachments", label: "Lampiran", description: "Lampiran lokal tanpa upload backend." },
  { id: "summary", label: "Ringkasan", description: "Periksa seluruh data sebelum diajukan." }
] as const;

export const fitnessApplicationServiceCategories = [
  "Pemeriksaan Kelaikan Awal",
  "Pemeriksaan Kelaikan Berkala",
  "Pemeriksaan Ulang"
];

export const fitnessApplicationAttachmentCategories = [
  "Surat Permohonan",
  "Daftar Peti Kemas",
  "Kepemilikan/Penguasaan",
  "Teknis",
  "Lainnya"
] as const;

const readyItems = [
  ["client", "Klien dipilih", true, "Klien aktif tersedia."],
  ["applicant", "Pemohon tersedia", true, "Identitas Pemohon lengkap."],
  ["location", "Lokasi dipilih", true, "Lokasi pemeriksaan aktif."],
  ["pic", "PIC tersedia", true, "PIC lokasi dapat dihubungi."],
  ["container", "Minimal satu peti kemas", true, "Dua peti kemas terdaftar."],
  ["number", "Nomor peti kemas valid", true, "Format nomor telah diperiksa."],
  ["technical", "Data teknis minimum lengkap", true, "Data minimum siap untuk penugasan."],
  ["reference", "Referensi pemeriksaan tersedia", true, "Referensi aktif milik klien tersedia."],
  ["checklist", "Checklist terverifikasi tersedia", true, "Ketersediaan checklist telah diverifikasi tanpa membuat seed baru."],
  ["surveyor", "Surveyor GIFT aktif tersedia", true, "Ketersediaan internal GIFT telah dikonfirmasi."]
] as const;

const draftItems = readyItems.map(([id, label, ready, detail], index) => ({
  id,
  label,
  ready: index < 4 ? ready : false,
  detail: index < 4 ? detail : [
    "Tambahkan minimal satu peti kemas.",
    "Nomor peti kemas belum tersedia.",
    "Data teknis minimum belum lengkap.",
    "Pilih referensi aktif klien.",
    "Checklist terverifikasi belum tersedia.",
    "Ketersediaan Surveyor GIFT belum dikonfirmasi."
  ][index - 4]
}));

export const fitnessApplicationDraft: FitnessApplicationDraft = {
  applicationNumber: "AUTO-SETELAH-DISIMPAN",
  clientId: "",
  applicantName: "",
  ownerUserName: "",
  ownerUserAddress: "",
  ownerUserPic: "",
  ownerUserPhone: "",
  ownerUserEmail: "",
  applicationDate: "2026-07-14",
  serviceCategory: "",
  letterNumber: "",
  letterDate: "",
  locationId: "",
  picPersonnelId: "",
  plannedInspectionDate: "",
  containers: [],
  specialInstructions: "",
  adminNotes: "",
  referenceIds: [],
  attachments: []
};

export const fitnessApplications: FitnessApplicationDetail[] = [
  {
    id: "application-nusantara-001",
    clientId: "client-nusantara",
    applicationNumber: "GIFT/KLK/2026/0018",
    applicationDate: "2026-07-12",
    clientName: "PT Nusantara Logistik",
    applicantName: "Rina Prameswari",
    ownerUserName: "PT Nusantara Logistik",
    locationId: "nl-loc-1",
    locationName: "Depo Nusantara Priok",
    containerCount: 2,
    completeness: { complete: 10, total: 10 },
    processStage: "Siap Penugasan",
    status: "Diajukan",
    updatedAt: "14 Juli 2026, 10.20 WIB",
    applicantAddress: "Jl. Pelabuhan Nusantara No. 18, Jakarta Utara",
    applicantPicName: "Rina Prameswari",
    applicantPhone: "+62 21 555 0101",
    applicantEmail: "rina.prameswari@example.test",
    serviceCategory: "Pemeriksaan Kelaikan Awal",
    letterNumber: "NL/OPS/VII/2026/018",
    letterDate: "2026-07-11",
    picPersonnelId: "nl-pic-1",
    picName: "Rina Prameswari",
    picPhone: "+62 21 555 0111",
    plannedInspectionDate: "2026-07-18",
    specialInstructions: "Koordinasikan akses gerbang depo dengan PIC klien.",
    adminNotes: "Dokumen awal telah diperiksa Admin.",
    containers: [
      { id: "nl-app-container-1", containerNumber: "GIFT1234567", containerTypeId: "nl-type-1", containerTypeName: "General Purpose 20 ft", numberValid: true, technicalComplete: true },
      { id: "nl-app-container-2", containerNumber: "GIFT7654321", containerTypeId: "nl-type-2", containerTypeName: "High Cube 40 ft", numberValid: true, technicalComplete: true }
    ],
    referenceIds: ["nl-ref-area", "nl-ref-component", "nl-ref-damage", "nl-ref-photo"],
    attachments: [
      { id: "nl-attachment-1", category: "Surat Permohonan", name: "Surat-Permohonan-NL-018.pdf", sizeLabel: "420 KB" },
      { id: "nl-attachment-2", category: "Daftar Peti Kemas", name: "Daftar-Peti-Kemas-NL.xlsx", sizeLabel: "96 KB" }
    ],
    progress: [
      { id: "application", label: "Data Permohonan", description: "Identitas dan surat lengkap.", status: "complete" },
      { id: "containers", label: "Peti Kemas", description: "Dua peti kemas terdaftar.", status: "complete" },
      { id: "technical", label: "Data Teknis", description: "Data minimum lengkap.", status: "complete" },
      { id: "assignment", label: "Penugasan", description: "Siap ditugaskan.", status: "current" },
      { id: "inspection", label: "Pemeriksaan", description: "Belum dimulai.", status: "incomplete" },
      { id: "review", label: "Review", description: "Menunggu pemeriksaan.", status: "incomplete" },
      { id: "documents", label: "Dokumen", description: "Belum disiapkan.", status: "incomplete" }
    ],
    readiness: makeReadiness("application-nusantara-001", "client-nusantara", readyItems.map(([id, label, ready, detail]) => ({ id, label, ready, detail }))),
    history: [
      { id: "nl-history-1", clientId: "client-nusantara", title: "Permohonan diajukan", description: "Admin mengajukan permohonan setelah ringkasan diperiksa.", time: "14 Juli 2026, 10.20 WIB", tone: "success" },
      { id: "nl-history-2", clientId: "client-nusantara", title: "Peti kemas ditambahkan", description: "Dua peti kemas ditambahkan ke permohonan.", time: "13 Juli 2026, 15.45 WIB", tone: "neutral" }
    ]
  },
  {
    id: "application-samudra-001",
    clientId: "client-samudra",
    applicationNumber: "DRAFT/KLK/2026/0021",
    applicationDate: "2026-07-13",
    clientName: "PT Samudra Jaya Terminal",
    applicantName: "Arief Setiawan",
    ownerUserName: "PT Samudra Jaya Terminal",
    locationId: "sj-loc-1",
    locationName: "Terminal Samudra Perak",
    containerCount: 0,
    completeness: { complete: 4, total: 10 },
    processStage: "Data Permohonan",
    status: "Draf",
    updatedAt: "14 Juli 2026, 08.40 WIB",
    applicantAddress: "Jl. Terminal Samudra No. 27, Surabaya",
    applicantPicName: "Arief Setiawan",
    applicantPhone: "+62 31 555 0202",
    applicantEmail: "arief.setiawan@example.test",
    serviceCategory: "Pemeriksaan Kelaikan Berkala",
    letterNumber: "SJ/TERM/VII/2026/021",
    letterDate: "2026-07-13",
    picPersonnelId: "sj-pic-1",
    picName: "Arief Setiawan",
    picPhone: "+62 31 555 0211",
    plannedInspectionDate: "",
    specialInstructions: "",
    adminNotes: "Lengkapi peti kemas dan referensi sebelum diajukan.",
    containers: [],
    referenceIds: [],
    attachments: [{ id: "sj-attachment-1", category: "Surat Permohonan", name: "Surat-Permohonan-SJ-021.pdf", sizeLabel: "310 KB" }],
    progress: [
      { id: "application", label: "Data Permohonan", description: "Masih berupa draf.", status: "current" },
      { id: "containers", label: "Peti Kemas", description: "Belum ditambahkan.", status: "warning" },
      { id: "technical", label: "Data Teknis", description: "Belum tersedia.", status: "incomplete" },
      { id: "assignment", label: "Penugasan", description: "Belum siap.", status: "incomplete" },
      { id: "inspection", label: "Pemeriksaan", description: "Belum dimulai.", status: "incomplete" },
      { id: "review", label: "Review", description: "Belum dimulai.", status: "incomplete" },
      { id: "documents", label: "Dokumen", description: "Belum disiapkan.", status: "incomplete" }
    ],
    readiness: makeReadiness("application-samudra-001", "client-samudra", draftItems),
    history: [{ id: "sj-history-1", clientId: "client-samudra", title: "Draf disimpan", description: "Permohonan disimpan sebagai draf lokal.", time: "14 Juli 2026, 08.40 WIB", tone: "warning" }]
  },
  {
    id: "application-nusantara-002",
    clientId: "client-nusantara",
    applicationNumber: "GIFT/KLK/2026/0016",
    applicationDate: "2026-07-08",
    clientName: "PT Nusantara Logistik",
    applicantName: "Dimas Kurnia",
    ownerUserName: "PT Mitra Peti Kemas",
    locationId: "nl-loc-2",
    locationName: "Gudang Marunda",
    containerCount: 1,
    completeness: { complete: 10, total: 10 },
    processStage: "Menunggu Review",
    status: "Menunggu Review",
    updatedAt: "13 Juli 2026, 17.10 WIB",
    applicantAddress: "Jl. Pelabuhan Nusantara No. 18, Jakarta Utara",
    applicantPicName: "Dimas Kurnia",
    applicantPhone: "+62 21 555 0102",
    applicantEmail: "dimas.kurnia@example.test",
    serviceCategory: "Pemeriksaan Kelaikan Berkala",
    letterNumber: "NL/OPS/VII/2026/016",
    letterDate: "2026-07-07",
    picPersonnelId: "nl-pic-2",
    picName: "Dimas Kurnia",
    picPhone: "+62 21 555 0112",
    plannedInspectionDate: "2026-07-10",
    specialInstructions: "Pemeriksaan dilakukan di area tertutup.",
    adminNotes: "Hasil pemeriksaan menunggu review.",
    containers: [{ id: "nl-app-container-3", containerNumber: "GIFT2468135", containerTypeId: "nl-type-1", containerTypeName: "General Purpose 20 ft", numberValid: true, technicalComplete: true }],
    referenceIds: ["nl-ref-area", "nl-ref-component", "nl-ref-damage"],
    attachments: [{ id: "nl-attachment-3", category: "Teknis", name: "Lampiran-Teknis-NL-016.pdf", sizeLabel: "680 KB" }],
    progress: [
      { id: "application", label: "Data Permohonan", description: "Lengkap.", status: "complete" },
      { id: "containers", label: "Peti Kemas", description: "Satu peti kemas.", status: "complete" },
      { id: "technical", label: "Data Teknis", description: "Lengkap.", status: "complete" },
      { id: "assignment", label: "Penugasan", description: "Selesai.", status: "complete" },
      { id: "inspection", label: "Pemeriksaan", description: "Hasil dikirim.", status: "complete" },
      { id: "review", label: "Review", description: "Menunggu reviewer.", status: "current" },
      { id: "documents", label: "Dokumen", description: "Menunggu keputusan.", status: "incomplete" }
    ],
    readiness: makeReadiness("application-nusantara-002", "client-nusantara", readyItems.map(([id, label, ready, detail]) => ({ id, label, ready, detail }))),
    history: [{ id: "nl-history-3", clientId: "client-nusantara", title: "Pemeriksaan dikirim", description: "Hasil pemeriksaan menunggu review.", time: "13 Juli 2026, 17.10 WIB", tone: "neutral" }]
  }
];

export const fitnessDashboardMetrics: FitnessDashboardMetric[] = [
  metric("nl-clients", "client-nusantara", "Total Klien Aktif", 1, "Klien aktif dalam filter.", "success", "clients"),
  metric("nl-applications", "client-nusantara", "Total Permohonan", 2, "Permohonan Nusantara.", "info", "applications"),
  metric("nl-inspection", "client-nusantara", "Pemeriksaan Berjalan", 1, "Pemeriksaan aktif.", "info", "inspection"),
  metric("nl-repair", "client-nusantara", "Perlu Perbaikan", 1, "Temuan belum selesai.", "warning", "repair"),
  metric("nl-reinspection", "client-nusantara", "Menunggu Pemeriksaan Ulang", 1, "Siap dijadwalkan.", "warning", "reinspection"),
  metric("nl-fit", "client-nusantara", "Layak", 5, "Hasil Kelaikan tercatat.", "success", "fit"),
  metric("nl-unfit", "client-nusantara", "Tidak Layak", 1, "Hasil perlu perhatian.", "danger", "unfit"),
  metric("sj-clients", "client-samudra", "Total Klien Aktif", 1, "Klien aktif dalam filter.", "success", "clients"),
  metric("sj-applications", "client-samudra", "Total Permohonan", 1, "Permohonan Samudra.", "info", "applications"),
  metric("sj-inspection", "client-samudra", "Pemeriksaan Berjalan", 0, "Belum ada pemeriksaan aktif.", "neutral", "inspection"),
  metric("sj-repair", "client-samudra", "Perlu Perbaikan", 0, "Tidak ada tindak lanjut aktif.", "neutral", "repair"),
  metric("sj-reinspection", "client-samudra", "Menunggu Pemeriksaan Ulang", 0, "Tidak ada antrean.", "neutral", "reinspection"),
  metric("sj-fit", "client-samudra", "Layak", 2, "Hasil Kelaikan tercatat.", "success", "fit"),
  metric("sj-unfit", "client-samudra", "Tidak Layak", 0, "Tidak ada hasil.", "neutral", "unfit")
];

export const fitnessDashboardActions: FitnessDashboardAction[] = [
  action("nl-client", "client-nusantara", "Klien belum lengkap", 0, "Master Data Klien perlu dilengkapi.", "/fitness/clients?completeness=incomplete", "success", "client"),
  action("nl-application", "client-nusantara", "Permohonan belum lengkap", 0, "Draf perlu dilengkapi.", "/fitness/applications?status=Draf", "success", "application"),
  action("nl-container", "client-nusantara", "Peti kemas belum lengkap", 1, "Data teknis minimum perlu ditinjau.", "/fitness/containers?filter=technical-incomplete", "warning", "container"),
  action("nl-assignment", "client-nusantara", "Belum ditugaskan", 1, "Pekerjaan siap untuk penugasan.", "/fitness/assignments?status=unassigned", "warning", "assignment"),
  action("nl-review", "client-nusantara", "Menunggu review", 1, "Hasil pemeriksaan menunggu reviewer.", "/fitness/reviews?status=pending", "warning", "review"),
  action("nl-repair", "client-nusantara", "Perbaikan belum selesai", 1, "Tindak lanjut perlu dipantau.", "/fitness/repair-followups", "danger", "repair"),
  action("nl-reinspection", "client-nusantara", "Siap pemeriksaan ulang", 1, "Pemeriksaan ulang siap dijadwalkan.", "/fitness/repair-followups?status=ready", "info", "reinspection"),
  action("nl-document", "client-nusantara", "Dokumen perlu disiapkan", 1, "Metadata dokumen perlu disiapkan.", "/fitness/documents?status=draft", "info", "document"),
  action("sj-client", "client-samudra", "Klien belum lengkap", 1, "Master Data Klien perlu dilengkapi.", "/fitness/clients?completeness=incomplete", "danger", "client"),
  action("sj-application", "client-samudra", "Permohonan belum lengkap", 1, "Draf perlu dilengkapi.", "/fitness/applications?status=Draf", "warning", "application"),
  action("sj-container", "client-samudra", "Peti kemas belum lengkap", 0, "Belum ada peti kemas pada draf.", "/fitness/containers?filter=technical-incomplete", "warning", "container"),
  action("sj-assignment", "client-samudra", "Belum ditugaskan", 0, "Belum siap untuk penugasan.", "/fitness/assignments?status=unassigned", "neutral", "assignment"),
  action("sj-review", "client-samudra", "Menunggu review", 0, "Tidak ada antrean review.", "/fitness/reviews?status=pending", "neutral", "review"),
  action("sj-repair", "client-samudra", "Perbaikan belum selesai", 0, "Tidak ada tindak lanjut aktif.", "/fitness/repair-followups", "neutral", "repair"),
  action("sj-reinspection", "client-samudra", "Siap pemeriksaan ulang", 0, "Tidak ada antrean pemeriksaan ulang.", "/fitness/repair-followups?status=ready", "neutral", "reinspection"),
  action("sj-document", "client-samudra", "Dokumen perlu disiapkan", 0, "Belum ada dokumen aktif.", "/fitness/documents?status=draft", "neutral", "document")
];

export const fitnessDashboardActivities: FitnessDashboardActivity[] = [
  { id: "activity-1", clientId: "client-nusantara", title: "Permohonan diajukan", description: "GIFT/KLK/2026/0018 siap ditinjau untuk penugasan.", time: "14 Juli 2026, 10.20 WIB", period: "7-days", tone: "success" },
  { id: "activity-2", clientId: "client-samudra", title: "Draf permohonan disimpan", description: "DRAFT/KLK/2026/0021 masih perlu peti kemas.", time: "14 Juli 2026, 08.40 WIB", period: "7-days", tone: "warning" },
  { id: "activity-3", clientId: "client-nusantara", title: "Pemeriksaan dikirim", description: "GIFT/KLK/2026/0016 menunggu review.", time: "13 Juli 2026, 17.10 WIB", period: "7-days", tone: "neutral" },
  { id: "activity-4", clientId: "client-samudra", title: "Master Data Klien diperbarui", description: "PIC utama Samudra Jaya diperiksa Admin.", time: "2 Juli 2026", period: "30-days", tone: "neutral" },
  { id: "activity-5", clientId: "client-nusantara", title: "Dokumen disiapkan", description: "Metadata dokumen Kelaikan terdahulu diperbarui.", time: "20 Mei 2026", period: "quarter", tone: "success" }
];

export const fitnessDashboardQuickActions: FitnessDashboardQuickAction[] = [
  { id: "add-client", label: "Tambah Klien", description: "Daftarkan perusahaan pengguna jasa.", href: "/fitness/clients/create", icon: "client" },
  { id: "master-data", label: "Kelola Master Data Klien", description: "Pilih klien dan lengkapi referensinya.", href: "/fitness/client-master-data", icon: "master" },
  { id: "create-application", label: "Buat Permohonan", description: "Mulai permohonan Kelaikan baru.", href: "/fitness/applications/create", icon: "application" },
  { id: "import-containers", label: "Import Peti Kemas", description: "Buka placeholder import tahap berikutnya.", href: "/fitness/containers/import", icon: "import" },
  { id: "assignments", label: "Buka Penugasan", description: "Lihat pekerjaan yang siap ditugaskan.", href: "/fitness/assignments", icon: "assignment" },
  { id: "reviews", label: "Buka Review", description: "Lihat pemeriksaan yang menunggu review.", href: "/fitness/reviews", icon: "review" }
];
function makeReadiness(applicationId: string, clientId: string, items: FitnessApplicationReadiness["items"]): FitnessApplicationReadiness {
  const readyCount = items.filter((item) => item.ready).length;
  return { applicationId, clientId, ready: readyCount === items.length, readyCount, totalCount: items.length, items };
}
function metric(id: string, clientId: string, label: string, value: number, description: string, tone: FitnessDashboardMetric["tone"], icon: FitnessDashboardMetric["icon"]): FitnessDashboardMetric {
  return { id, clientId, label, value, description, tone, icon };
}
function action(id: string, clientId: string, label: string, count: number, description: string, href: string, tone: FitnessDashboardAction["tone"], icon: FitnessDashboardAction["icon"]): FitnessDashboardAction {
  return { id, clientId, label, count, description, href, tone, icon };
}
