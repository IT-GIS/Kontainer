import {
  Archive, BarChart3, Building2, CalendarCheck, CheckCircle2, ClipboardCheck, ClipboardList, Clock3, Container, Database,
  FileText, Gauge, History, Upload, ListChecks, MapPin, PackageCheck, PenLine,
  Settings, ShieldCheck, Tags, UserRoundCheck, UsersRound, Wrench
} from "lucide-react";
import type {
  FitnessMasterDataGroup, FitnessNavigationSummary, FitnessPlaceholder, FitnessUiBPreview, PageTabItem
} from "@/types/fitness-admin";

export const fitnessDashboardSummary: FitnessNavigationSummary[] = [
  {
    label: "Permohonan belum lengkap",
    href: "/fitness/applications?status=incomplete",
    description: "Lengkapi data permohonan sebelum peti kemas ditambahkan.",
    status: "Dalam Pengembangan",
    icon: ClipboardList
  },
  {
    label: "Validasi data teknis",
    href: "/fitness/containers?filter=technical-incomplete",
    description: "Pantau peti kemas yang masih butuh kelengkapan teknis.",
    status: "Dalam Pengembangan",
    icon: Container
  },
  {
    label: "Belum ditugaskan",
    href: "/fitness/assignments?status=unassigned",
    description: "Siapkan penugasan Surveyor untuk pekerjaan yang siap diperiksa.",
    status: "Dalam Pengembangan",
    icon: UserRoundCheck
  },
  {
    label: "Master Data",
    href: "/fitness/master-data",
    description: "Kelola referensi utama untuk proses kelaikan peti kemas.",
    status: "Aktif",
    icon: Database
  }
];

export const inspectionTabs: PageTabItem[] = [
  { id: "all", label: "Semua", href: "/fitness/inspections", count: 0 },
  { id: "waiting", label: "Menunggu", href: "/fitness/inspections?status=waiting", count: 0 },
  { id: "running", label: "Berjalan", href: "/fitness/inspections?status=running", count: 0 },
  { id: "repair", label: "Perlu Perbaikan", href: "/fitness/inspections?status=repair-needed", count: 0 },
  { id: "recheck", label: "Siap Pemeriksaan Ulang", href: "/fitness/inspections?status=ready-recheck", count: 0 },
  { id: "fit", label: "Layak", href: "/fitness/inspections?result=fit", count: 0 },
  { id: "unfit", label: "Tidak Layak", href: "/fitness/inspections?result=unfit", count: 0 }
];

export const reviewTabs: PageTabItem[] = [
  { id: "pending", label: "Menunggu Review", href: "/fitness/reviews?status=pending", count: 0 },
  { id: "revision", label: "Perlu Revisi", href: "/fitness/reviews?status=revision", count: 0 },
  { id: "reviewed", label: "Selesai Direview", href: "/fitness/reviews?status=reviewed", count: 0 },
  { id: "history", label: "Riwayat Keputusan", href: "/fitness/reviews?status=history", count: 0 }
];

export const documentTabs: PageTabItem[] = [
  { id: "all", label: "Semua", href: "/fitness/documents", count: 0 },
  { id: "ready", label: "Siap Disiapkan", href: "/fitness/documents?status=ready", count: 0 },
  { id: "draft", label: "Draf", href: "/fitness/documents?status=draft", count: 0 },
  { id: "issued", label: "Terbit", href: "/fitness/documents?status=issued", count: 0 },
  { id: "replaced", label: "Digantikan", href: "/fitness/documents?status=replaced", count: 0 },
  { id: "revoked", label: "Dicabut", href: "/fitness/documents?status=revoked", count: 0 }
];

export const assignmentTabs: PageTabItem[] = [
  { id: "unassigned", label: "Belum Ditugaskan", href: "/fitness/assignments?status=unassigned", count: 0 },
  { id: "active", label: "Penugasan Aktif", href: "/fitness/assignments?status=active", count: 0 },
  { id: "history", label: "Riwayat Penugasan", href: "/fitness/assignments?status=history", count: 0 }
];

export const fitnessMasterDataGroups: FitnessMasterDataGroup[] = [
  {
    title: "Referensi Umum",
    description: "Data referensi dasar untuk permohonan, lokasi, peti kemas, dan Surveyor.",
    items: [
      master("Pemilik Peti Kemas", "/fitness/master-data/owners", "Data pemilik/client yang digunakan pada permohonan dan dokumen.", UsersRound, 12, 1),
      master("Pabrik Pembuat", "/fitness/master-data/manufacturers", "Referensi pabrik pembuat peti kemas untuk data teknis.", Building2, 8, 0),
      master("Lokasi", "/fitness/master-data/locations", "Lokasi depo, pelabuhan, gudang, atau area pemeriksaan.", MapPin, 10, 2),
      master("Surveyor", "/fitness/master-data/surveyors", "Profil Surveyor atau pemeriksa yang dapat ditugaskan.", UserRoundCheck, 6, 1),
      master("Jenis Peti Kemas", "/fitness/master-data/container-types", "Jenis dan ukuran peti kemas untuk checklist dan dokumen.", Container, 9, 0)
    ]
  },
  {
    title: "Konfigurasi Pemeriksaan",
    description: "Referensi teknis untuk checklist, temuan, area, komponen, dan parameter pengujian.",
    items: [
      master("Kategori Persetujuan", "/fitness/master-data/approval-categories", "Kategori proses persetujuan kelaikan peti kemas.", ClipboardCheck, 3, 1),
      master("Skema Pemeliharaan", "/fitness/master-data/maintenance-schemes", "Skema pemeliharaan dan jadwal pemeriksaan berkala.", Wrench, 5, 0),
      master("Area Pemeriksaan", "/fitness/master-data/inspection-areas", "Area peti kemas yang dipakai pada checklist dan temuan.", MapPin, 11, 0),
      master("Komponen Struktur", "/fitness/master-data/structural-components", "Komponen struktur yang menjadi referensi pemeriksaan.", PackageCheck, 14, 0),
      master("Kriteria Kerusakan", "/fitness/master-data/damage-criteria", "Kriteria kerusakan atau ketidaksesuaian pemeriksaan.", Tags, 18, 2),
      master("Tingkat Keparahan", "/fitness/master-data/finding-severities", "Tingkat risiko temuan untuk review dan keputusan.", BarChart3, 3, 0),
      master("Parameter Pengujian", "/fitness/master-data/test-parameters", "Parameter pengujian kelaikan sesuai jenis peti kemas.", ListChecks, 7, 1)
    ]
  },
  {
    title: "Konfigurasi Hasil dan Dokumen",
    description: "Konfigurasi hasil pemeriksaan, bukti foto, penandatangan, dan profil dokumen.",
    items: [
      master("Template Checklist", "/fitness/master-data/checklist-templates", "Header template checklist untuk pemeriksaan lapangan.", ClipboardList, 4, 0),
      master("Kategori Bukti Foto", "/fitness/master-data/photo-categories", "Kategori foto pemeriksaan, temuan, pengujian, dan perbaikan.", Upload, 9, 0),
      master("Rekomendasi Pemeriksaan", "/fitness/master-data/inspection-recommendations", "Rekomendasi hasil pemeriksaan untuk proses review.", ShieldCheck, 5, 0),
      master("Pejabat Penandatangan", "/fitness/master-data/authorized-signers", "Pejabat yang berwenang menandatangani dokumen kelaikan.", PenLine, 2, 1),
      master("Profil Badan Usaha", "/fitness/master-data/company-profile", "Identitas badan usaha untuk header dokumen dan laporan.", Building2, 1, 0)
    ]
  }
];


export const fitnessUiBPreview: FitnessUiBPreview = {
  metrics: [
    {
      label: "Kesiapan Tampilan",
      value: "82%",
      description: "Komponen utama siap dipakai lintas halaman Admin Kelaikan.",
      tone: "success",
      trend: "Stabil",
      icon: CheckCircle2
    },
    {
      label: "Data Menunggu",
      value: "7",
      description: "Baris contoh untuk filter, tabel, dan kartu mobile.",
      tone: "warning",
      trend: "Perlu tindak lanjut",
      icon: Clock3
    },
    {
      label: "Tahap Proses",
      value: "3/5",
      description: "Stepper dan progress tracker siap untuk UI-C.",
      tone: "info",
      trend: "Berjalan",
      icon: CalendarCheck
    }
  ],
  steps: [
    { id: "request", label: "Permohonan", description: "Identitas dan lokasi pemeriksaan.", status: "complete" },
    { id: "container", label: "Peti Kemas", description: "Data teknis dan lampiran awal.", status: "current" },
    { id: "assignment", label: "Penugasan Surveyor", description: "Jadwal dan instruksi kerja.", status: "upcoming" },
    { id: "review", label: "Review", description: "Keputusan dan dokumen final.", status: "upcoming" }
  ],
  progress: [
    { id: "draft", label: "Draf", description: "Data awal sudah tersimpan.", status: "done" },
    { id: "process", label: "Tahap Proses", description: "Kelengkapan teknis sedang disiapkan.", status: "current" },
    { id: "result", label: "Hasil Akhir Kelaikan", description: "Menunggu hasil pemeriksaan.", status: "waiting" }
  ],
  activities: [
    {
      id: "activity-1",
      title: "Permohonan diperbarui",
      description: "Pemilik, lokasi, dan jenis peti kemas sudah dicek.",
      time: "13 Juli 2026, 09:10",
      tone: "success"
    },
    {
      id: "activity-2",
      title: "Kelengkapan teknis perlu dilanjutkan",
      description: "Beberapa data peti kemas masih menunggu verifikasi Admin.",
      time: "13 Juli 2026, 10:25",
      tone: "warning"
    }
  ],
  records: [
    { id: "row-1", code: "REQ-2026-0713-001", owner: "PT Nusantara Logistik", stage: "Draf", status: "Data Awal", complete: 4, total: 5 },
    { id: "row-2", code: "REQ-2026-0713-002", owner: "PT Samudra Jaya", stage: "Tahap Proses", status: "Teknis", complete: 3, total: 5 },
    { id: "row-3", code: "REQ-2026-0713-003", owner: "PT Pelabuhan Sentosa", stage: "Penugasan Surveyor", status: "Siap Ditugaskan", complete: 5, total: 5 }
  ],
  filters: [
    { id: "keyword", label: "Cari", value: "", placeholder: "Nomor permohonan atau pemilik" },
    { id: "stage", label: "Tahap", value: "Tahap Proses", placeholder: "Pilih tahap" },
    { id: "owner", label: "Pemilik", value: "", placeholder: "Pilih pemilik" }
  ],
  attachments: [
    { name: "Surat Permohonan.pdf", type: "document", sizeLabel: "420 KB" },
    { name: "Foto Peti Kemas.jpg", type: "image", sizeLabel: "1.2 MB" }
  ]
};

export const fitnessPlaceholders: FitnessPlaceholder[] = [
  placeholder("/fitness/dashboard", "Dashboard", "Ringkasan tindakan Admin Kelaikan", "Pantau pekerjaan yang membutuhkan tindakan dan akses cepat ke menu utama.", Gauge, [
    "Ringkasan permohonan, pemeriksaan, review, dan dokumen.",
    "Kartu tindakan untuk proses yang perlu dilengkapi.",
    "Akses cepat ke permohonan, peti kemas, penugasan, dan master data."
  ]),
  placeholder("/fitness/applications", "Daftar Permohonan", "Kelola permohonan kelaikan peti kemas", "Halaman daftar permohonan akan berisi pencarian, filter status, dan ringkasan kelengkapan.", ClipboardList, [
    "Daftar permohonan dengan status kelengkapan.",
    "Filter berdasarkan pemilik, lokasi, kategori, dan tanggal.",
    "Aksi lanjutan ke detail, peti kemas, atau penugasan."
  ], { label: "Buat Permohonan", href: "/fitness/applications/create" }, ["/fitness/applications?status=incomplete"]),
  placeholder("/fitness/applications/create", "Buat Permohonan", "Input awal permohonan kelaikan", "Form lengkap permohonan akan dibangun pada tahap berikutnya dengan stepper dan validasi pengguna.", PenLine, [
    "Informasi permohonan dan surat pemohon.",
    "Pemohon, pemilik, lokasi pemeriksaan, dan instruksi.",
    "Ringkasan sebelum simpan draf atau lanjut tambah peti kemas."
  ]),
  placeholder("/fitness/containers", "Daftar Peti Kemas", "Kelola data peti kemas untuk permohonan", "Daftar peti kemas akan menampilkan status kelengkapan teknis dan kesiapan pemeriksaan.", Container, [
    "Pencarian nomor peti kemas dan pemilik.",
    "Filter kelengkapan teknis dan hasil pemeriksaan.",
    "Aksi menuju detail teknis atau import data."
  ], { label: "Import Peti Kemas", href: "/fitness/containers/import" }, ["/fitness/containers?filter=technical-incomplete"]),
  placeholder("/fitness/containers/import", "Import Peti Kemas", "Import data peti kemas secara bertahap", "Wizard import akan membantu mapping kolom, preview, validasi, dan ringkasan hasil import.", Upload, [
    "Pilih permohonan tujuan import.",
    "Upload file dan mapping kolom.",
    "Preview validasi sebelum data digunakan."
  ]),
  placeholder("/fitness/assignments", "Penugasan Surveyor", "Kelola kesiapan dan riwayat penugasan", "Penugasan akan memakai status dan tab agar Admin tidak perlu membuka banyak submenu terpisah.", UserRoundCheck, [
    "Tab belum ditugaskan, aktif, dan riwayat.",
    "Ringkasan kesiapan peti kemas sebelum penugasan.",
    "Informasi Surveyor, jadwal, dan instruksi kerja."
  ], undefined, ["/fitness/assignments?status=unassigned", "/fitness/assignments?status=active", "/fitness/assignments?status=history"], assignmentTabs),
  placeholder("/fitness/inspections", "Monitoring Pemeriksaan", "Pantau progres pemeriksaan peti kemas", "Monitoring memakai tab status untuk melihat proses pemeriksaan tanpa submenu yang berulang.", ClipboardCheck, [
    "Tab status pemeriksaan dari menunggu sampai hasil akhir.",
    "Ringkasan progress checklist, pengujian, foto, dan temuan.",
    "Aksi menuju detail pemeriksaan pada tahap berikutnya."
  ], undefined, undefined, inspectionTabs),
  placeholder("/fitness/reviews", "Review & Keputusan", "Tinjau hasil pemeriksaan dan keputusan", "Ruang review akan memusatkan ringkasan hasil, temuan, foto, dan keputusan reviewer.", ShieldCheck, [
    "Tab menunggu review, revisi, selesai, dan riwayat.",
    "Panel ringkasan hasil pemeriksaan.",
    "Keputusan kelaikan disiapkan pada tahap lanjutan."
  ], undefined, undefined, reviewTabs),
  placeholder("/fitness/repair-followups", "Tindak Lanjut Perbaikan", "Pantau perbaikan dan kesiapan pemeriksaan ulang", "Halaman ini akan memusatkan tindak lanjut temuan yang perlu diperbaiki.", Wrench, [
    "Daftar temuan yang membutuhkan perbaikan.",
    "Status kesiapan pemeriksaan ulang.",
    "Catatan dan bukti perbaikan pada tahap berikutnya."
  ]),
  placeholder("/fitness/documents", "Dokumen Kelaikan", "Kelola metadata dan status dokumen kelaikan", "Dokumen memakai tab status agar draf, terbit, digantikan, dan dicabut mudah dipantau.", FileText, [
    "Tab status dokumen dan ringkasan kesiapan.",
    "Metadata dokumen, pemilik, peti kemas, dan penandatangan.",
    "Preview dokumen disiapkan pada tahap lanjutan."
  ], undefined, undefined, documentTabs),
  placeholder("/fitness/reports", "Laporan", "Ringkasan operasional kelaikan peti kemas", "Laporan akan berisi kartu rekap dan filter periode untuk kebutuhan Admin dan Management.", BarChart3, [
    "Rekap pemeriksaan dan hasil kelaikan.",
    "Rekap pemilik, pabrik, dan periode.",
    "Export disiapkan sebagai placeholder pada tahap berikutnya."
  ]),
  placeholder("/fitness/master-data", "Master Data", "Pusat referensi Admin Kelaikan", "Kelola referensi umum, konfigurasi pemeriksaan, dan konfigurasi dokumen dari satu index.", Database, [
    "Kelompok master data yang mudah dipindai.",
    "Status aktif dan ringkasan data per master.",
    "Akses cepat ke CRUD master yang sudah aktif."
  ], { label: "Kembali ke Dashboard", href: "/fitness/dashboard" }),
  placeholder("/fitness/legacy-archive", "Arsip Lama", "Akses read-only data lama", "Arsip lama tetap dipisahkan dari workflow aktif Sistem Kelaikan Peti Kemas.", Archive, [
    "Akses histori lama tanpa mencampur workflow baru.",
    "Read-only untuk rujukan internal.",
    "Migrasi selektif disiapkan pada tahap berbeda."
  ])
];

function master(
  label: string,
  href: string,
  description: string,
  icon: FitnessMasterDataGroup["items"][number]["icon"],
  activeCount: number,
  inactiveCount: number
) {
  return {
    label,
    href,
    description,
    status: "Aktif" as const,
    activeCount,
    inactiveCount,
    updatedAt: "13 Juli 2026",
    icon
  };
}

function placeholder(
  path: string,
  title: string,
  subtitle: string,
  description: string,
  icon: FitnessPlaceholder["icon"],
  features: string[],
  secondaryCta?: { label: string; href: string },
  compatibilityRoutes?: string[],
  tabs?: PageTabItem[]
): FitnessPlaceholder {
  return {
    path,
    title,
    subtitle,
    description,
    icon,
    status: path === "/fitness/master-data" ? "Aktif" : "Dalam Pengembangan",
    features,
    primaryCta: { label: "Kembali ke Dashboard", href: "/fitness/dashboard" },
    secondaryCta,
    tabs,
    compatibilityRoutes,
    breadcrumbs: buildBreadcrumbs(title)
  };
}

function buildBreadcrumbs(title: string) {
  return [
    { label: "Admin Kelaikan", href: "/fitness/dashboard" },
    { label: title }
  ];
}


