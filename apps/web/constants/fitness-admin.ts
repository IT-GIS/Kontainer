export type FitnessPlaceholder = {
  path: string;
  title: string;
  purpose: string;
  fields: string[];
  validations: string[];
  usedBy: string[];
  surveyorUsage: string;
};

export const masterDataItems = [
  { label: "Pemilik Peti Kemas", href: "/fitness/master-data/owners", activeStage: true },
  { label: "Pabrik Pembuat Peti Kemas", href: "/fitness/master-data/manufacturers", activeStage: true },
  { label: "Lokasi Pemeriksaan", href: "/fitness/master-data/locations", activeStage: true },
  { label: "Surveyor / Pemeriksa", href: "/fitness/master-data/surveyors", activeStage: true },
  { label: "Jenis / Model Peti Kemas", href: "/fitness/master-data/container-types", activeStage: true },
  { label: "Kategori Persetujuan Kelaikan", href: "/fitness/master-data/approval-categories", activeStage: true },
  { label: "Skema Pemeliharaan Peti Kemas", href: "/fitness/master-data/maintenance-schemes" },
  { label: "Area Pemeriksaan Peti Kemas", href: "/fitness/master-data/inspection-areas" },
  { label: "Komponen Struktur Peti Kemas", href: "/fitness/master-data/structural-components" },
  { label: "Kriteria Kerusakan / Ketidaksesuaian", href: "/fitness/master-data/damage-criteria" },
  { label: "Tingkat Temuan / Severity", href: "/fitness/master-data/finding-severities" },
  { label: "Parameter Pengujian Kelaikan", href: "/fitness/master-data/test-parameters" },
  { label: "Template Checklist Kelaikan", href: "/fitness/master-data/checklist-templates" },
  { label: "Kategori Foto Evidence", href: "/fitness/master-data/photo-categories" },
  { label: "Rekomendasi Hasil Pemeriksaan", href: "/fitness/master-data/inspection-recommendations" },
  { label: "Pejabat Penandatangan", href: "/fitness/master-data/authorized-signers" },
  { label: "Profil Badan Usaha", href: "/fitness/master-data/company-profile" }
] as const;

const commonPlaceholderStatus = "Belum aktif - menunggu tahap berikutnya.";

export const fitnessPlaceholders: FitnessPlaceholder[] = [
  {
    path: "/fitness/dashboard",
    title: "Dashboard Kelaikan",
    purpose: "Menampilkan ringkasan proses kelaikan peti kemas dari permohonan sampai dokumen terbit.",
    fields: ["Total Permohonan", "Permohonan Draft", "Pemeriksaan Berjalan", "Menunggu Review", "Perlu Perbaikan", "Siap Re-Inspection", "Peti Kemas Layak", "Peti Kemas Tidak Layak", "Dokumen Kelaikan Terbit", "Aktivitas Terbaru"],
    validations: ["Filter periode wajib memakai rentang tanggal valid", "Filter pemilik, lokasi, surveyor, status, dan kategori bersifat opsional"],
    usedBy: ["Admin", "Supervisor / Reviewer", "Management"],
    surveyorUsage: "Surveyor tidak mengisi dashboard, tetapi ringkasan ini memakai status hasil pemeriksaan yang dikirim Surveyor."
  },
  {
    path: "/fitness/master-data",
    title: "Master Data Kelaikan",
    purpose: "Pusat pengaturan data referensi yang akan dipakai Admin dan Surveyor agar input lapangan tidak bergantung pada ketikan bebas.",
    fields: masterDataItems.map((item) => item.label),
    validations: ["Data master aktif saja yang boleh dipakai pada permohonan baru", "Kode master wajib unik pada submenu masing-masing", "Master inactive tetap boleh tampil untuk arsip jika sudah pernah dipakai"],
    usedBy: ["Permohonan Kelaikan", "Assignment Surveyor", "Pemeriksaan Lapangan", "Review", "Dokumen Kelaikan", "Laporan"],
    surveyorUsage: "Surveyor memilih area, komponen, kriteria, severity, parameter pengujian, checklist, kategori foto, dan rekomendasi dari master yang disiapkan Admin."
  },
  {
    path: "/fitness/applications",
    title: "Permohonan Kelaikan",
    purpose: "Mengelola daftar dan pembuatan permohonan kelaikan sebelum data peti kemas dan penugasan Surveyor dilengkapi.",
    fields: ["Nomor Permohonan", "Tanggal Permohonan", "Pemilik Peti Kemas", "Pabrik Pembuat", "Lokasi Pemeriksaan", "Kategori Persetujuan Kelaikan", "Nomor Surat Permohonan Client", "Tanggal Surat Permohonan Client", "PIC", "Instruksi / Catatan", "Status draft/submitted"],
    validations: ["Pemilik, lokasi, kategori, dan tanggal permohonan wajib", "Email PIC harus valid jika diisi", "Pabrik pembuat disarankan wajib untuk peti kemas baru"],
    usedBy: ["Data Peti Kemas", "Assign Surveyor", "Monitoring Pemeriksaan", "Dokumen Kelaikan"],
    surveyorUsage: "Surveyor menerima konteks permohonan, pemilik, lokasi, kategori persetujuan, dan instruksi pemeriksaan dari data ini."
  },
  {
    path: "/fitness/applications/create",
    title: "Buat Permohonan Kelaikan",
    purpose: "Membuat permohonan kelaikan peti kemas sebelum data peti kemas dan surveyor dilengkapi.",
    fields: ["Nomor Permohonan, auto numbering", "Tanggal Permohonan", "Pemilik Peti Kemas", "Pabrik Pembuat, optional", "Lokasi Pemeriksaan", "Kategori Persetujuan Kelaikan", "Nomor Surat Permohonan Client", "Tanggal Surat Permohonan Client", "Nama PIC", "Telepon PIC", "Email PIC", "Instruksi / Catatan", "Status draft/submitted"],
    validations: ["Pemilik wajib diisi", "Lokasi wajib dipilih", "Kategori persetujuan wajib dipilih", "Tanggal permohonan wajib", "Email PIC harus valid jika diisi", "Pabrik pembuat disarankan wajib untuk peti kemas baru"],
    usedBy: ["Data Peti Kemas", "Assign Surveyor", "Pemeriksaan Lapangan", "Dokumen Kelaikan"],
    surveyorUsage: "Surveyor menerima konteks permohonan, pemilik, lokasi, kategori persetujuan, dan instruksi pemeriksaan dari data ini."
  },
  {
    path: "/fitness/containers",
    title: "Data Peti Kemas",
    purpose: "Menyiapkan data identitas dan spesifikasi teknis peti kemas yang akan diperiksa.",
    fields: ["Nomor Peti Kemas", "Owner Code", "Serial Number", "Check Digit Status", "Jenis / Model", "ISO Type Code", "Nomor CSC", "Tanggal Pembuatan", "Nomor Seri Pabrik", "Max Gross Weight", "Tare Weight", "Payload Weight", "Cube Capacity", "Allowable Stacking Weight", "Racking Test Load Value", "End Wall Strength", "Side Wall Strength", "Next Examination Date", "Skema Pemeliharaan", "Status"],
    validations: ["Nomor peti kemas wajib", "Check digit harus dicek atau diberi alasan override", "Field teknis wajib sebelum dokumen diterbitkan"],
    usedBy: ["Permohonan Kelaikan", "Pemeriksaan Lapangan", "Review", "Dokumen Kelaikan"],
    surveyorUsage: "Surveyor memakai data teknis sebagai pembanding saat memeriksa plate, struktur, dan parameter pengujian."
  },
  {
    path: "/fitness/containers/import",
    title: "Import Data Peti Kemas",
    purpose: "Mengimpor batch data peti kemas dari Excel/CSV agar Admin tidak input satu per satu.",
    fields: ["Pilih Permohonan", "Upload file Excel/CSV", "Mapping kolom", "Preview data", "Validasi hasil import", "Status import", "Kolom import minimal: container_no", "Kolom import minimal: container_type", "Kolom import minimal: iso_type_code", "Kolom import minimal: csc_no", "Kolom import minimal: manufacture_date", "Kolom import minimal: manufacturer_serial_no", "Kolom import minimal: type_model", "Kolom import minimal: max_gross_weight_kg", "Kolom import minimal: tare_weight_kg", "Kolom import minimal: payload_weight_kg"],
    validations: ["File wajib Excel/CSV", "Nomor peti kemas wajib", "Format nomor peti kemas harus divalidasi", "Data duplicate harus ditandai", "Data invalid tidak boleh langsung masuk", "Import hanya placeholder, belum ada proses upload aktif"],
    usedBy: ["Data Peti Kemas", "Assign Surveyor", "Pemeriksaan Lapangan", "Dokumen Kelaikan"],
    surveyorUsage: "Data hasil import akan menjadi daftar peti kemas yang ditugaskan kepada Surveyor."
  },
  {
    path: "/fitness/assignments",
    title: "Assign Surveyor",
    purpose: "Menugaskan Surveyor / Pemeriksa aktif ke permohonan dan peti kemas tertentu.",
    fields: ["Pilih Permohonan", "Pilih Peti Kemas", "Surveyor / Pemeriksa", "Tanggal Mulai", "Tanggal Jatuh Tempo", "Instruksi Pemeriksaan", "Catatan Lokasi", "Status Assignment"],
    validations: ["Surveyor wajib aktif", "Minimal satu peti kemas dipilih", "Tanggal jatuh tempo tidak boleh sebelum tanggal mulai"],
    usedBy: ["Pemeriksaan Lapangan", "Monitoring Pemeriksaan", "Laporan"],
    surveyorUsage: "Surveyor hanya melihat pekerjaan yang ditugaskan kepadanya beserta instruksi dan daftar peti kemas."
  },
  {
    path: "/fitness/inspections",
    title: "Pemeriksaan & Pengujian",
    purpose: "Monitoring Admin atas pemeriksaan awal, re-inspection, hasil pengujian, temuan, dan rekomendasi Surveyor.",
    fields: ["Nomor Pemeriksaan", "Nomor Permohonan", "Nomor Peti Kemas", "Pemilik", "Surveyor", "Lokasi", "Jenis Pemeriksaan", "Round", "Status Pemeriksaan", "Rekomendasi Surveyor", "Jumlah Temuan", "Jumlah Foto", "Submitted At"],
    validations: ["Halaman Admin bersifat monitoring", "Tidak ada mutation pemeriksaan pada tahap placeholder", "Status re-inspection mengikuti hasil review dan tindak lanjut perbaikan"],
    usedBy: ["Review & Keputusan Kelaikan", "Dokumen Kelaikan", "Laporan"],
    surveyorUsage: "Data yang tampil berasal dari checklist, pengujian, temuan, foto, dan rekomendasi yang dikirim Surveyor."
  },
  {
    path: "/fitness/reviews",
    title: "Review & Keputusan Kelaikan",
    purpose: "Menyiapkan ruang review hasil pemeriksaan dan keputusan kelaikan tanpa approval final pada tahap ini.",
    fields: ["Nomor Pemeriksaan", "Nomor Peti Kemas", "Pemilik", "Submitted At", "Rekomendasi Surveyor", "Jumlah Critical Finding", "Keputusan Reviewer", "Catatan Reviewer", "Final Fitness Result", "Restriction Status"],
    validations: ["Keputusan reviewer belum aktif sebagai mutation", "Keputusan final wajib berdasarkan checklist, pengujian, temuan, dan foto", "Pembebasan setelah perbaikan hanya untuk container yang sudah re-inspection"],
    usedBy: ["Dokumen Kelaikan", "Surat Pembebasan", "Laporan"],
    surveyorUsage: "Surveyor melihat tindak lanjut review seperti perlu revisi, perlu perbaikan, atau re-inspection pada tahap berikutnya."
  },
  {
    path: "/fitness/documents",
    title: "Dokumen Kelaikan",
    purpose: "Menyiapkan metadata dokumen kelaikan dan surat pembebasan tanpa PDF atau QR final.",
    fields: ["Nomor Dokumen", "Jenis Dokumen", "Nomor Permohonan", "Nomor Peti Kemas", "Pemilik", "Pabrik Pembuat", "Lokasi", "Tanggal Terbit", "Kota Terbit", "Pejabat Penandatangan", "Status Dokumen"],
    validations: ["Dokumen hanya bisa diterbitkan jika data teknis dan review lengkap", "QR Token dan snapshot dokumen belum final pada tahap ini"],
    usedBy: ["Validasi Dokumen", "Laporan", "Arsip"],
    surveyorUsage: "Surveyor tidak menerbitkan dokumen, tetapi hasil lapangan menjadi sumber data dokumen."
  },
  {
    path: "/fitness/reports",
    title: "Laporan",
    purpose: "Menyiapkan rekap pemeriksaan, status kelaikan, pemilik, pabrik pembuat, dan kegiatan periodik.",
    fields: ["Periode", "Pemilik", "Lokasi", "Surveyor", "Kategori Persetujuan", "Status Kelaikan", "Status Dokumen", "Nomor Permohonan", "Nomor Peti Kemas", "Nomor CSC", "Tanggal Pemeriksaan", "Status Akhir"],
    validations: ["Filter periode harus valid", "Laporan enam bulanan belum final pada tahap ini", "Data laporan bersifat read-only"],
    usedBy: ["Admin", "Management", "Audit Internal"],
    surveyorUsage: "Kinerja dan hasil pemeriksaan Surveyor menjadi sumber rekap, tetapi Surveyor tidak mengelola laporan."
  },
  {
    path: "/fitness/legacy-archive",
    title: "Arsip Survey Lama",
    purpose: "Memberi akses read-only ke data legacy tanpa menjadikannya workflow aktif kelaikan.",
    fields: ["Job Order Lama", "Survey Lama", "Report Lama", "Nomor Peti Kemas", "Customer Legacy", "Tanggal Survey", "Status Legacy"],
    validations: ["Read-only concept", "Tidak boleh mengubah data legacy", "Tidak menjadi sumber workflow kelaikan aktif"],
    usedBy: ["Admin", "Supervisor", "Management"],
    surveyorUsage: "Surveyor tidak mengisi arsip lama; arsip hanya untuk rujukan histori jika diperlukan."
  },
  {
    path: "/fitness/master-data/owners",
    title: "Pemilik Peti Kemas",
    purpose: "Menyimpan data pemilik/client peti kemas untuk permohonan, dokumen, laporan, dan validasi dokumen.",
    fields: ["Kode Pemilik", "Nama Pemilik Peti Kemas", "Alamat", "NPWP", "Nama PIC", "Nomor Telepon PIC", "Email PIC", "Alamat Billing", "Catatan", "Status active/inactive"],
    validations: ["Kode pemilik wajib unik", "Nama pemilik wajib diisi", "Email harus valid jika diisi", "Status wajib dipilih"],
    usedBy: ["Permohonan Kelaikan", "Data Peti Kemas", "Dokumen Kelaikan", "Laporan"],
    surveyorUsage: "Surveyor melihat pemilik untuk memastikan konteks pekerjaan dan identitas peti kemas di lapangan."
  },
  {
    path: "/fitness/master-data/manufacturers",
    title: "Pabrik Pembuat Peti Kemas",
    purpose: "Menyimpan data pabrik pembuat peti kemas untuk data teknis dan dokumen persetujuan kelaikan.",
    fields: ["Kode Pabrik", "Nama Pabrik Pembuat", "Alamat Pabrik", "Negara", "Nama PIC", "Telepon PIC", "Email PIC", "Website", "Catatan", "Status active/inactive"],
    validations: ["Kode pabrik wajib unik", "Nama pabrik wajib diisi", "Negara wajib diisi", "Email harus valid jika diisi"],
    usedBy: ["Permohonan Kelaikan", "Data Teknis Peti Kemas", "Surat Persetujuan Kelaikan"],
    surveyorUsage: "Surveyor memakai data pabrik sebagai referensi ketika memeriksa plate dan data teknis peti kemas."
  },
  {
    path: "/fitness/master-data/locations",
    title: "Lokasi Pemeriksaan",
    purpose: "Mengatur lokasi depo, pelabuhan, pabrik, gudang, workshop, atau lokasi lain tempat pemeriksaan dilakukan.",
    fields: ["Kode Lokasi", "Nama Lokasi", "Jenis Lokasi", "Alamat", "Kota", "Latitude", "Longitude", "Nama PIC Lokasi", "Telepon PIC Lokasi", "Status active/inactive"],
    validations: ["Kode lokasi wajib unik", "Nama lokasi wajib diisi", "Jenis lokasi wajib dipilih"],
    usedBy: ["Permohonan Kelaikan", "Assignment Surveyor", "Pemeriksaan Lapangan", "Laporan"],
    surveyorUsage: "Surveyor memakai lokasi untuk tujuan pekerjaan, bukti GPS, dan konteks pemeriksaan lapangan."
  },
  {
    path: "/fitness/master-data/surveyors",
    title: "Surveyor / Pemeriksa",
    purpose: "Mengatur profil Surveyor atau Pemeriksa yang dapat ditugaskan ke pemeriksaan kelaikan.",
    fields: ["User Akun", "Kode Surveyor", "Nama Lengkap", "Nomor Telepon", "Area Tugas", "Tanda Tangan", "Status active/inactive"],
    validations: ["User wajib dipilih", "Kode surveyor wajib unik", "Nama lengkap wajib diisi", "Surveyor inactive tidak boleh di-assign"],
    usedBy: ["Assign Surveyor", "Pemeriksaan Lapangan", "Dokumen Hasil Pemeriksaan", "Laporan"],
    surveyorUsage: "Surveyor memakai akun ini untuk menerima assignment dan mengirim hasil pemeriksaan."
  },
  {
    path: "/fitness/master-data/container-types",
    title: "Jenis / Model Peti Kemas",
    purpose: "Mengatur jenis, ukuran, ISO code, dan model peti kemas yang menjadi basis checklist dan dokumen.",
    fields: ["Kode Jenis", "ISO Code", "Ukuran", "Nama Tipe", "Deskripsi", "Status active/inactive", "Catatan Scope"],
    validations: ["Kode jenis wajib unik", "Ukuran wajib diisi", "Nama tipe wajib diisi", "Jenis di luar scope internal tidak aktif default"],
    usedBy: ["Data Peti Kemas", "Template Checklist", "Pemeriksaan Lapangan", "Dokumen Kelaikan"],
    surveyorUsage: "Surveyor mendapat checklist dan parameter yang sesuai jenis/model peti kemas."
  },
  {
    path: "/fitness/master-data/approval-categories",
    title: "Kategori Persetujuan Kelaikan",
    purpose: "Menentukan jenis proses kelaikan yang diajukan pada MVP.",
    fields: ["Kode Kategori", "Nama Kategori", "Deskripsi", "Berlaku Untuk", "Aktif di MVP", "Status active/inactive", "Display Order"],
    validations: ["Kode kategori wajib unik", "Kategori aktif MVP hanya untuk peti kemas baru individual dan peti kemas lama sesuai scope", "Kategori future/inactive tidak tampil aktif di UI MVP"],
    usedBy: ["Permohonan Kelaikan", "Template Checklist", "Dokumen Kelaikan", "Laporan"],
    surveyorUsage: "Surveyor mendapat checklist dan parameter sesuai kategori persetujuan yang dipilih Admin."
  },
  {
    path: "/fitness/master-data/maintenance-schemes",
    title: "Skema Pemeliharaan Peti Kemas",
    purpose: "Mengatur skema pemeliharaan atau pemeriksaan berkala peti kemas seperti ACEP, PES, IICL, ISO, NED, atau Other.",
    fields: ["Kode Skema", "Nama Skema", "Deskripsi", "Membutuhkan Next Examination Date", "Interval Pemeriksaan", "Status active/inactive"],
    validations: ["Kode skema wajib unik", "Nama skema wajib diisi", "Interval wajib numeric jika diisi"],
    usedBy: ["Data Teknis Peti Kemas", "CSC Safety Approval Plate", "Dokumen Kelaikan", "Laporan"],
    surveyorUsage: "Surveyor memeriksa kesesuaian skema pemeliharaan dan Next Examination Date pada plate/data teknis."
  },
  {
    path: "/fitness/master-data/inspection-areas",
    title: "Area Pemeriksaan Peti Kemas",
    purpose: "Mengatur area peti kemas yang dipilih Surveyor saat input temuan dan foto evidence.",
    fields: ["Kode Area", "Nama Area", "Deskripsi", "Urutan Tampil", "Status active/inactive"],
    validations: ["Kode area wajib unik", "Nama area wajib diisi", "Urutan tampil wajib numeric jika diisi"],
    usedBy: ["Komponen Struktur", "Form Temuan Surveyor", "Foto Evidence"],
    surveyorUsage: "Surveyor memilih area seperti roof, floor, door end, understructure, atau CSC plate area saat mencatat temuan."
  },
  {
    path: "/fitness/master-data/structural-components",
    title: "Komponen Struktur Peti Kemas",
    purpose: "Mengatur komponen struktur yang dipilih Surveyor saat input temuan.",
    fields: ["Kode Komponen", "Nama Komponen", "Area Pemeriksaan", "Komponen Struktural Kritis", "Deskripsi", "Urutan Tampil", "Status active/inactive"],
    validations: ["Kode komponen wajib unik", "Nama komponen wajib diisi", "Area pemeriksaan opsional tetapi disarankan"],
    usedBy: ["Form Temuan Surveyor", "Kriteria Kerusakan", "Keputusan Kelaikan"],
    surveyorUsage: "Surveyor memilih komponen seperti corner post, cross member, floor, roof, door panel, atau CSC plate saat mencatat kondisi."
  },
  {
    path: "/fitness/master-data/damage-criteria",
    title: "Kriteria Kerusakan / Ketidaksesuaian",
    purpose: "Mengatur jenis kerusakan atau ketidaksesuaian yang dapat dipilih Surveyor.",
    fields: ["Kode Kriteria", "Nama Kriteria", "Komponen Terkait", "Deskripsi", "Tingkat Temuan Default", "Default Memengaruhi Kelaikan", "Default Perlu Perbaikan", "Catatan Pemeriksaan", "Status active/inactive"],
    validations: ["Kode kriteria wajib unik", "Nama kriteria wajib diisi", "Severity default harus aktif jika dipilih"],
    usedBy: ["Form Temuan Surveyor", "Review Kelaikan", "Repair Follow-up", "Laporan Kerusakan"],
    surveyorUsage: "Surveyor memilih kriteria seperti dent, crack, hole, corrosion, missing plate, unreadable plate, atau watertightness failure."
  },
  {
    path: "/fitness/master-data/finding-severities",
    title: "Tingkat Temuan / Severity",
    purpose: "Mengatur tingkat temuan yang memengaruhi review dan keputusan kelaikan.",
    fields: ["Kode Severity", "Nama Severity", "Deskripsi", "Level Angka", "Default Memengaruhi Kelaikan", "Default Perlu Review Supervisor", "Warna Badge", "Status active/inactive"],
    validations: ["Kode severity wajib unik", "Level angka wajib numeric", "Minor, major, dan critical menjadi data awal"],
    usedBy: ["Kriteria Kerusakan", "Form Temuan Surveyor", "Review Kelaikan"],
    surveyorUsage: "Surveyor memilih severity temuan agar reviewer memahami risiko dan prioritas tindak lanjut."
  },
  {
    path: "/fitness/master-data/test-parameters",
    title: "Parameter Pengujian Kelaikan",
    purpose: "Mengatur parameter pengujian yang harus diisi Surveyor sesuai kategori dan jenis peti kemas.",
    fields: ["Kode Parameter", "Nama Parameter", "Deskripsi", "Satuan", "Referensi Standar", "Berlaku untuk Peti Kemas Baru", "Berlaku untuk Peti Kemas Lama", "Wajib Hasil Angka", "Wajib Lampiran/Foto", "Urutan Tampil", "Status active/inactive"],
    validations: ["Kode parameter wajib unik", "Nama parameter wajib diisi", "Satuan wajib jika hasil angka diwajibkan"],
    usedBy: ["Form Pengujian Surveyor", "Review Hasil Pengujian", "Dokumen Kelaikan"],
    surveyorUsage: "Surveyor mengisi hasil uji seperti watertightness, racking, stacking, wall strength, atau NDT jika diperlukan."
  },
  {
    path: "/fitness/master-data/checklist-templates",
    title: "Template Checklist Kelaikan",
    purpose: "Mengatur checklist yang tampil pada form Surveyor berdasarkan kategori persetujuan dan jenis/model peti kemas.",
    fields: ["Kode Template", "Nama Template", "Kategori Persetujuan", "Jenis / Model Peti Kemas", "Versi", "Status draft/active/inactive", "Kode Item", "Label Pertanyaan", "Area Pemeriksaan", "Komponen Struktur", "Parameter Pengujian", "Response Type", "Expected Value", "Wajib Diisi", "Critical Item", "Jika Gagal Perlu Perbaikan", "Jika Gagal Tidak Layak", "Urutan Tampil"],
    validations: ["Template active wajib punya minimal satu item", "Critical item wajib punya aturan dampak", "Response type wajib dipilih"],
    usedBy: ["Form Surveyor", "Review Hasil Pemeriksaan", "Audit Trail", "Dokumen Kelaikan"],
    surveyorUsage: "Surveyor mengisi checklist dari template ini sehingga struktur pemeriksaan konsisten."
  },
  {
    path: "/fitness/master-data/photo-categories",
    title: "Kategori Foto Evidence",
    purpose: "Mengatur kategori foto yang harus di-upload Surveyor untuk pemeriksaan, temuan, pengujian, repair, dan re-inspection.",
    fields: ["Kode Kategori Foto", "Nama Kategori Foto", "Deskripsi", "Wajib Default", "Berlaku Untuk", "Urutan Tampil", "Status active/inactive"],
    validations: ["Kode kategori foto wajib unik", "Nama kategori wajib diisi", "Berlaku untuk minimal satu konteks"],
    usedBy: ["Upload Foto Surveyor", "Temuan Kerusakan", "Re-Inspection", "Dokumen Evidence"],
    surveyorUsage: "Surveyor memilih kategori foto seperti general container, container number, CSC plate, damage finding, test result, repair evidence, atau reinspection evidence."
  },
  {
    path: "/fitness/master-data/inspection-recommendations",
    title: "Rekomendasi Hasil Pemeriksaan",
    purpose: "Mengatur rekomendasi yang bisa dipilih Surveyor setelah pemeriksaan.",
    fields: ["Kode Rekomendasi", "Nama Rekomendasi", "Deskripsi", "Final Fitness Result Mapping", "Workflow Status Mapping", "Restriction Status Mapping", "Perlu Review Supervisor", "Status active/inactive"],
    validations: ["Kode rekomendasi wajib unik", "Mapping status wajib dipilih", "Rekomendasi aktif saja yang tampil di form Surveyor"],
    usedBy: ["Form Surveyor", "Review Kelaikan", "Status Monitoring"],
    surveyorUsage: "Surveyor memilih rekomendasi seperti layak, perlu perbaikan, tidak layak, perlu re-inspection, atau dilarang digunakan sementara."
  },
  {
    path: "/fitness/master-data/authorized-signers",
    title: "Pejabat Penandatangan",
    purpose: "Mengatur pejabat yang berwenang menandatangani dokumen kelaikan.",
    fields: ["Nama Pejabat", "Jabatan", "NIP / ID Pegawai", "Email", "Nomor Telepon", "File Tanda Tangan", "Berlaku Mulai", "Berlaku Sampai", "Status active/inactive"],
    validations: ["Nama dan jabatan wajib diisi", "Email harus valid jika diisi", "Tanggal berlaku sampai tidak boleh sebelum berlaku mulai"],
    usedBy: ["Surat Persetujuan Kelaikan", "Surat Pembebasan Setelah Perbaikan", "Dokumen Final"],
    surveyorUsage: "Surveyor tidak memilih penandatangan, tetapi hasil pemeriksaan yang lengkap menjadi dasar dokumen yang ditandatangani."
  },
  {
    path: "/fitness/master-data/company-profile",
    title: "Profil Badan Usaha",
    purpose: "Mengatur identitas badan usaha untuk header dokumen, surat persetujuan, validasi dokumen, dan laporan.",
    fields: ["Nama Badan Usaha", "Brand", "Alamat", "Telepon", "Email", "Website", "Nomor Pajak", "Logo", "Tanda Tangan Default", "Status Aktif"],
    validations: ["Nama badan usaha wajib diisi", "Email harus valid jika diisi", "Hanya satu profil aktif yang digunakan sebagai default"],
    usedBy: ["Header Dokumen", "Surat Persetujuan", "Validasi Dokumen", "Report"],
    surveyorUsage: "Surveyor tidak mengubah profil badan usaha, tetapi dokumen hasil pemeriksaan memakai profil ini."
  }
].map((item) => ({ ...item, validations: [...item.validations, commonPlaceholderStatus] }));

export function getFitnessPlaceholderByPath(path: string): FitnessPlaceholder | undefined {
  const normalizedPath = path.replace(/\/$/, "") || "/fitness/dashboard";
  return fitnessPlaceholders.find((item) => item.path === normalizedPath);
}

export function getFitnessStageMessage(path: string): string {
  const normalizedPath = path.replace(/\/$/, "") || "/fitness/dashboard";
  if (masterDataItems.some((item) => item.href === normalizedPath && "activeStage" in item && item.activeStage)) {
    return "Aktif - CRUD Master Data Stage 1.";
  }
  if (normalizedPath.startsWith("/fitness/master-data/")) {
    return "Belum aktif - menunggu tahap Master Data CRUD Stage 2.";
  }
  if (normalizedPath === "/fitness/assignments") {
    return "Belum aktif - menunggu tahap Assignment Surveyor.";
  }
  if (normalizedPath.startsWith("/fitness/inspections")) {
    return "Belum aktif - menunggu tahap Surveyor Inspection Flow.";
  }
  if (normalizedPath.startsWith("/fitness/reviews")) {
    return "Belum aktif - menunggu tahap Review & Approval.";
  }
  if (normalizedPath.startsWith("/fitness/documents")) {
    return "Belum aktif - menunggu tahap Document & QR.";
  }
  return "Belum aktif - menunggu tahap berikutnya.";
}