# REDESIGN UI/UX DAN FORM ADMIN
## Sistem Kelaikan Peti Kemas — PT Global Inspeksi Forensik Teknik

**Repository:** `IT-GIS/Kontainer`  
**Fokus:** UI/UX, alur kerja, struktur menu, dan kelengkapan form Admin  
**Integrasi:** Database dan backend tidak diubah pada tahap ini  
**Nama aplikasi:** Sistem Kelaikan Peti Kemas  
**Istilah wajib:** Kelaikan  
**Istilah terlarang:** Kelayakan, PM25, PM 25, pm25

---

# 1. TUJUAN

Dokumen ini menjadi acuan utama redesign sisi Admin agar aplikasi:

1. mudah dipahami Admin nonteknis;
2. memiliki alur jelas dari permohonan sampai dokumen;
3. tidak terasa seperti kumpulan menu teknis;
4. memiliki form lengkap, terstruktur, dan mudah diisi;
5. menampilkan progres dan status secara visual;
6. modern, profesional, ringan, dan responsif;
7. siap disambungkan ke API/database di tahap berikutnya;
8. belum membangun UI Surveyor;
9. tidak mengubah database, migration, patch SQL, atau backend.

---

# 2. PRINSIP DESAIN

## 2.1 Karakter visual

- Corporate dan profesional.
- Dominan putih dan biru.
- Latar abu-abu sangat muda.
- Tidak gelap.
- Tidak terlalu ramai.
- Tidak berlebihan memakai gradient.
- Typography jelas.
- Spacing lega.
- Responsif desktop, tablet, dan mobile.

## 2.2 Warna status

| Status | Warna |
|---|---|
| Draf | Abu-abu |
| Belum Lengkap | Kuning |
| Siap Ditugaskan | Biru |
| Sedang Berjalan | Biru tua |
| Menunggu Review | Ungu lembut |
| Perlu Perbaikan | Oranye |
| Siap Pemeriksaan Ulang | Cyan |
| Layak | Hijau |
| Tidak Layak | Merah |
| Dibatalkan | Abu gelap |
| Tidak Aktif | Abu muda |

## 2.3 Istilah UI

Gunakan:

- Kelaikan
- Peti Kemas
- Penugasan Surveyor
- Pemeriksaan Ulang
- Tingkat Keparahan
- Kategori Bukti Foto
- Tahap Proses
- Hasil Akhir Kelaikan
- Status Pembatasan
- Pemohon
- Pemilik Peti Kemas

Hindari istilah campuran yang tidak perlu seperti Assign Surveyor, Re-Inspection, Severity, Evidence, Workflow Status, dan Final Fitness Result.

---

# 3. IDENTITAS APLIKASI

## 3.1 Branding sidebar

Gunakan:

**Sistem Kelaikan Peti Kemas**  
**PT Global Inspeksi Forensik Teknik**

Jangan tampilkan PT Global Inspeksi Sertifikasi pada workspace GIFT.

## 3.2 Subtitle topbar

> Kelola permohonan, pemeriksaan, review, dan dokumen kelaikan peti kemas.

## 3.3 Logo

- Gunakan logo GIFT dari repo.
- Jangan gepeng.
- Tetap jelas saat sidebar collapsed.
- Beri padding yang cukup.

---

# 4. STRUKTUR MENU ADMIN BARU

## Dashboard

`/fitness/dashboard`

## Permohonan

- Daftar Permohonan — `/fitness/applications`
- Buat Permohonan — `/fitness/applications/create`
- Permohonan Belum Lengkap — `/fitness/applications?status=incomplete`

## Peti Kemas

- Daftar Peti Kemas — `/fitness/containers`
- Import Peti Kemas — `/fitness/containers/import`
- Validasi Data Teknis — `/fitness/containers?filter=technical-incomplete`

## Penugasan

- Belum Ditugaskan — `/fitness/assignments?status=unassigned`
- Penugasan Aktif — `/fitness/assignments?status=active`
- Riwayat Penugasan — `/fitness/assignments?status=history`

## Monitoring Pemeriksaan

`/fitness/inspections`

Gunakan tab:

- Semua
- Menunggu
- Berjalan
- Perlu Perbaikan
- Siap Pemeriksaan Ulang
- Layak
- Tidak Layak

## Review & Keputusan

`/fitness/reviews`

Gunakan tab:

- Menunggu Review
- Perlu Revisi
- Selesai Direview
- Riwayat Keputusan

## Tindak Lanjut Perbaikan

`/fitness/repair-followups`

## Dokumen Kelaikan

`/fitness/documents`

Tab:

- Semua Dokumen
- Siap Disiapkan
- Draf
- Terbit
- Digantikan
- Dicabut

## Laporan

`/fitness/reports`

## Master Data

`/fitness/master-data`

Kelompok:

- Referensi Umum
- Konfigurasi Pemeriksaan
- Konfigurasi Hasil dan Dokumen

## Pengaturan

- Profil Badan Usaha
- Pengaturan Penomoran
- Audit Log
- Manajemen User
- Role & Permission

## Arsip Lama

`/fitness/legacy-archive`

---

# 5. ALUR KERJA ADMIN

Gunakan alur:

1. Buat Permohonan.
2. Tambahkan Peti Kemas.
3. Lengkapi Data Teknis.
4. Periksa Kesiapan Penugasan.
5. Tugaskan Surveyor.
6. Pantau Pemeriksaan.
7. Review Hasil.
8. Tindak Lanjut Perbaikan.
9. Pemeriksaan Ulang.
10. Tetapkan Keputusan.
11. Siapkan Dokumen.
12. Arsip dan Laporan.

## 5.1 Progress tracker

Pada detail permohonan tampilkan:

- Data Permohonan
- Peti Kemas
- Data Teknis
- Penugasan
- Pemeriksaan
- Review
- Dokumen

Contoh:

```text
Data Permohonan   ✓
Peti Kemas        ✓
Data Teknis       !
Penugasan         ○
Pemeriksaan       ○
Review            ○
Dokumen           ○
```

---

# 6. GLOBAL APP SHELL

## 6.1 Sidebar

- Collapsible.
- Active state jelas.
- Group menu tidak terlalu panjang.
- Tooltip saat collapsed.
- Mobile drawer.
- Identitas GIFT.
- Tombol keluar di footer.

## 6.2 Topbar

Tampilkan:

- judul halaman;
- breadcrumb;
- subtitle;
- role user;
- notifikasi;
- profil user.

## 6.3 Breadcrumb

Contoh:

```text
Admin Kelaikan / Permohonan / Detail / APP-2026-001
```

## 6.4 Page header

Setiap halaman harus memiliki:

- judul;
- deskripsi;
- primary action;
- secondary action;
- status badge bila relevan.

---

# 7. DASHBOARD ADMIN

## 7.1 Perlu Tindakan Anda

Card:

- Permohonan belum lengkap
- Peti kemas belum lengkap
- Belum ditugaskan
- Menunggu review
- Perbaikan belum selesai
- Dokumen siap disiapkan

Setiap card memiliki angka, deskripsi, CTA, icon, dan warna status.

## 7.2 Ringkasan Status

- Total Permohonan
- Pemeriksaan Berjalan
- Perlu Perbaikan
- Menunggu Pemeriksaan Ulang
- Layak
- Tidak Layak

## 7.3 Aktivitas Terbaru

Timeline:

- permohonan dibuat;
- peti kemas ditambahkan;
- Surveyor ditugaskan;
- pemeriksaan dikirim;
- reviewer memberi keputusan;
- dokumen disiapkan.

## 7.4 Quick action

- Buat Permohonan
- Tambah Peti Kemas
- Import Peti Kemas
- Penugasan Surveyor

## 7.5 Filter

- Periode
- Pemilik
- Lokasi
- Surveyor
- Kategori
- Tahap Proses

---

# 8. DAFTAR PERMOHONAN

## Toolbar

- Search
- Filter status
- Filter tanggal
- Filter pemilik
- Filter lokasi
- Filter kategori
- Reset filter
- Buat Permohonan

## Kolom

- Nomor Permohonan
- Tanggal
- Pemilik
- Lokasi
- Kategori
- Jumlah Peti Kemas
- Kelengkapan
- Tahap Proses
- Terakhir Diperbarui
- Aksi

## Aksi

- Lihat Detail
- Edit Draf
- Tambah Peti Kemas
- Penugasan
- Batalkan
- Lihat Riwayat

---

# 9. FORM BUAT PERMOHONAN

Gunakan stepper.

## Tahap 1 — Informasi Permohonan

- Nomor Permohonan — otomatis dan read-only
- Tanggal Permohonan
- Kategori Persetujuan Kelaikan
- Nomor Surat Permohonan
- Tanggal Surat Permohonan
- Lampiran Surat Permohonan

## Tahap 2 — Pemohon dan Pemilik

- Pemilik Peti Kemas
- Alamat Pemilik — otomatis
- Nama PIC
- Telepon PIC
- Email PIC
- Pabrik Pembuat Default — opsional

Pabrik default hanya nilai awal, bukan pabrik final seluruh container.

## Tahap 3 — Lokasi Pemeriksaan

- Lokasi Pemeriksaan
- Alamat Lokasi
- Kota
- PIC Lokasi
- Telepon PIC Lokasi
- Catatan Akses
- Rencana Tanggal Pemeriksaan

## Tahap 4 — Instruksi

- Jenis Pemeriksaan
- Instruksi Khusus
- Catatan Admin
- Lampiran Tambahan

## Tahap 5 — Ringkasan

Tampilkan seluruh data sebelum disimpan.

## Tombol

- Kembali
- Selanjutnya
- Simpan Draf
- Simpan & Tambah Peti Kemas
- Batal

Status tidak menjadi dropdown bebas. Gunakan action Simpan Draf, Ajukan, dan Batalkan.

---

# 10. DETAIL PERMOHONAN

## Header

- Nomor Permohonan
- Status
- Pemilik
- Lokasi
- Kategori
- Tanggal
- PIC
- Action utama

## Tab

- Ringkasan
- Peti Kemas
- Penugasan
- Pemeriksaan
- Review
- Dokumen
- Riwayat

## Checklist Kesiapan Penugasan

- Pemilik dipilih
- Lokasi dipilih
- Kategori dipilih
- Minimal satu peti kemas
- Nomor peti kemas valid
- Data teknis minimum lengkap
- Template checklist tersedia
- Surveyor aktif tersedia

Tombol Penugasan harus disabled bila belum siap.

---

# 11. DAFTAR PETI KEMAS

## Toolbar

- Search nomor peti kemas
- Filter pemilik
- Filter permohonan
- Filter jenis
- Filter kelengkapan
- Filter hasil
- Tambah Peti Kemas
- Import

## Kolom

- Nomor Peti Kemas
- Nomor Permohonan
- Pemilik
- Jenis
- Pabrik
- CSC No
- Kelengkapan Teknis
- Tahap Proses
- Hasil
- Aksi

---

# 12. FORM PETI KEMAS

Gunakan halaman penuh dengan tab.

## Tab Identitas

- Nomor Peti Kemas
- Owner Code
- Serial Number
- Check Digit
- Status Check Digit
- Jenis Peti Kemas
- Model Peti Kemas
- ISO Type Code
- Pabrik Pembuat
- Catatan

Validasi visual:

```text
ABCD 123456 7
✓ Format benar
✓ Check digit sesuai
```

Jika salah:

```text
⚠ Check digit tidak sesuai
```

Aksi:

- Periksa Ulang
- Override dengan Alasan

## Tab CSC Safety Approval Plate

- Nomor CSC
- Nomor Persetujuan
- Tanggal Pembuatan
- Manufacturer Serial Number
- Foto CSC Plate
- Status Keterbacaan Plate
- Catatan Plate

## Tab Berat dan Kapasitas

- Maximum Gross Weight kg/lbs
- Tare Weight kg/lbs
- Payload Weight kg/lbs
- Cube Capacity m³/ft³

## Tab Data Struktur

- Allowable Stacking Weight kg/lbs
- Racking Test Load kg/lbs
- End Wall Strength
- Side Wall Strength

## Tab Pemeliharaan

- Skema Pemeliharaan
- Next Examination Date
- Interval
- Catatan Pemeliharaan

## Tab Lampiran

- Foto Container Number
- Foto CSC Plate
- Dokumen Teknis
- Bukti Pemilik
- Lampiran Lain

## Tab Ringkasan

Tampilkan status kelengkapan setiap section dan status siap/belum siap ditugaskan.

---

# 13. IMPORT PETI KEMAS

Gunakan wizard:

1. Pilih Permohonan.
2. Upload File.
3. Mapping Kolom.
4. Preview.
5. Validasi.
6. Ringkasan Import.

Tampilkan status per baris:

- Valid
- Warning
- Error
- Duplikat

Aksi:

- Download Template
- Upload
- Kembali
- Validasi Ulang
- Import Data Valid
- Batalkan

---

# 14. PENUGASAN SURVEYOR

## Daftar

Tab:

- Belum Ditugaskan
- Aktif
- Selesai
- Dibatalkan

## Form

### Informasi Pekerjaan

- Nomor Permohonan
- Pemilik
- Lokasi
- Kategori

### Pilih Peti Kemas

Gunakan tabel checklist dengan status kelengkapan.

### Pilih Surveyor

Card Surveyor:

- Nama
- Kode
- Area Tugas
- Pekerjaan Aktif
- Status Ketersediaan

### Jadwal

- Tanggal Rencana
- Jatuh Tempo
- Instruksi
- Catatan Lokasi

### Ringkasan

- jumlah container;
- nama Surveyor;
- tanggal;
- lokasi.

---

# 15. MONITORING PEMERIKSAAN

Gunakan satu halaman dan tab.

## Tab

- Semua
- Menunggu
- Berjalan
- Perlu Perbaikan
- Siap Pemeriksaan Ulang
- Layak
- Tidak Layak

## Tabel

- No Pemeriksaan
- Peti Kemas
- Permohonan
- Surveyor
- Progress
- Temuan
- Foto
- Status
- Terakhir Diperbarui
- Aksi

## Detail

Tab:

- Ringkasan
- Checklist
- Pengujian
- Temuan
- Foto
- Riwayat

Progress visual:

- Checklist 18/20
- Pengujian 3/4
- Foto wajib 7/8
- Temuan 2

---

# 16. REVIEW DAN KEPUTUSAN

Gunakan dedicated page.

## Layout

- identitas peti kemas;
- permohonan;
- Surveyor;
- lokasi;
- tanggal pemeriksaan;
- status.

Tab:

- Ringkasan
- Checklist
- Pengujian
- Temuan
- Foto
- Riwayat

## Panel Keputusan

Pilihan:

- Layak
- Perlu Perbaikan
- Pemeriksaan Ulang
- Tidak Layak
- Minta Revisi Surveyor

Field:

- Keputusan
- Alasan
- Catatan Reviewer
- Status Pembatasan
- Tindakan Berikutnya

Gunakan confirmation dialog.

---

# 17. TINDAK LANJUT PERBAIKAN

## Tabel

- Nomor Tindak Lanjut
- Peti Kemas
- Pemilik
- Pihak Perbaikan
- Tanggal Mulai
- Tanggal Selesai
- Status
- Kesiapan Pemeriksaan Ulang
- Aksi

## Form

- Peti Kemas
- Temuan yang Diperbaiki
- Pihak Perbaikan
- Jenis Pihak
- Catatan Client
- Bukti Perbaikan
- Tanggal Selesai
- Siap Pemeriksaan Ulang

---

# 18. DOKUMEN KELAIKAN

## Tab

- Semua
- Siap Disiapkan
- Draf
- Terbit
- Digantikan
- Dicabut

## Tabel

- Nomor Dokumen
- Jenis
- Peti Kemas
- Pemilik
- Tanggal
- Penandatangan
- Status
- Aksi

## Detail

- Metadata
- Data teknis
- Hasil review
- Penandatangan
- Preview HTML
- Riwayat versi

Belum membuat PDF dan QR final.

---

# 19. LAPORAN

Gunakan card laporan.

Setiap card memiliki nama, deskripsi, filter, tombol lihat, dan tombol export placeholder bila belum aktif.

Laporan:

- Rekap Pemeriksaan
- Rekap Layak
- Rekap Tidak Layak
- Rekap Perlu Perbaikan
- Rekap Pemeriksaan Ulang
- Rekap Pemilik
- Rekap Pabrik
- Laporan 6 Bulanan

---

# 20. MASTER DATA INDEX

## Referensi Umum

- Pemilik Peti Kemas
- Pabrik Pembuat
- Lokasi
- Surveyor
- Jenis Peti Kemas

## Konfigurasi Pemeriksaan

- Kategori Persetujuan
- Skema Pemeliharaan
- Area Pemeriksaan
- Komponen Struktur
- Kriteria Kerusakan
- Tingkat Keparahan
- Parameter Pengujian

## Konfigurasi Hasil dan Dokumen

- Template Checklist
- Kategori Bukti Foto
- Rekomendasi Pemeriksaan
- Pejabat Penandatangan
- Profil Badan Usaha

Setiap card menampilkan nama master, deskripsi, jumlah aktif, jumlah tidak aktif, terakhir diperbarui, dan tombol Kelola.

---

# 21. JENIS FORM MASTER DATA

## Modal

- Area Pemeriksaan
- Tingkat Keparahan
- Kategori Bukti Foto
- Rekomendasi

## Drawer

- Pemilik
- Pabrik
- Lokasi
- Surveyor
- Komponen
- Kriteria Kerusakan
- Pejabat Penandatangan

## Dedicated page

- Template Checklist
- Checklist Builder
- Profil Badan Usaha
- Jenis Peti Kemas bila kompleks

---

# 22. CHECKLIST BUILDER

## Header

- Kode Template
- Nama Template
- Kategori
- Jenis Peti Kemas
- Versi
- Status
- Deskripsi

## Builder

- daftar section;
- tambah section;
- tambah item;
- duplicate item;
- drag-and-drop;
- ubah urutan;
- preview form Surveyor;
- toggle required;
- toggle critical;
- dampak jika gagal.

## Item

- Kode Item
- Label Pertanyaan
- Deskripsi
- Area
- Komponen
- Parameter
- Tipe Jawaban
- Nilai Harapan
- Wajib
- Critical
- Perlu Perbaikan jika gagal
- Tidak Layak jika gagal
- Urutan

---

# 23. PROFIL BADAN USAHA

Gunakan dedicated singleton page.

Section:

- Identitas
- Kontak
- Alamat
- Nomor Pajak
- Logo
- Tanda Tangan Default
- Preview Header Dokumen

Tombol:

- Edit
- Simpan
- Batalkan

Tidak ada tombol Tambah bila data sudah ada.

---

# 24. KOMPONEN UI WAJIB

- Breadcrumb
- PageHeader
- StatusBadge
- MetricCard
- ActionCard
- PageTabs
- Stepper
- ProgressTracker
- FormSection
- FormField
- SearchableSelect
- Drawer
- Modal
- ConfirmationDialog
- StickyActionBar
- EmptyState
- ErrorState
- Skeleton
- ActivityTimeline
- AttachmentUploader placeholder
- AttachmentPreview
- BulkSelectionTable
- FilterBar
- CompletionBadge
- UnsavedChangesGuard
- Toast/alert feedback
- Responsive table/card view

---

# 25. PERILAKU FORM

Setiap form harus memiliki:

- label jelas;
- help text;
- required marker;
- inline validation;
- error summary;
- disabled submit;
- loading state;
- success state;
- confirmation;
- cancel;
- unsaved changes warning;
- responsive layout;
- keyboard navigation;
- focus state;
- aria label;
- empty option yang jelas.

---

# 26. RESPONSIVE

## Desktop

- Sidebar penuh.
- Table.
- Form dua kolom.
- Sticky summary.

## Tablet

- Sidebar collapse.
- Drawer form.
- Table horizontal scroll.

## Mobile

- Sidebar drawer.
- Card list.
- Form satu kolom.
- Sticky bottom action.
- Tab horizontal scroll.

---

# 27. MOCK DATA

Karena database belum menjadi fokus:

1. gunakan mock data terstruktur;
2. jangan hardcode data langsung di component;
3. simpan pada file mock;
4. buat interface/type siap API;
5. gunakan mock service/adapter;
6. semua halaman memiliki loading, empty, error, dan success state;
7. jangan membuat mutation backend;
8. jangan mengubah schema database.

Lokasi yang disarankan:

- `apps/web/mocks/fitness-admin.ts`
- `apps/web/types/fitness-admin.ts`
- `apps/web/lib/fitness-admin-mock-service.ts`

---

# 28. STRUKTUR FILE

```text
apps/web/
├── app/fitness/
│   ├── dashboard/
│   ├── applications/
│   ├── containers/
│   ├── assignments/
│   ├── inspections/
│   ├── reviews/
│   ├── repair-followups/
│   ├── documents/
│   ├── reports/
│   ├── master-data/
│   └── legacy-archive/
├── components/fitness/
│   ├── dashboard/
│   ├── applications/
│   ├── containers/
│   ├── assignments/
│   ├── inspections/
│   ├── reviews/
│   ├── documents/
│   ├── reports/
│   ├── master/
│   └── shared/
├── mocks/
├── types/
└── lib/
```

---

# 29. TAHAP IMPLEMENTASI

## UI-A — Information Architecture dan Shell

- branding GIFT;
- struktur sidebar baru;
- route;
- breadcrumb;
- tabs;
- page header;
- placeholder production-ready;
- master data index.

## UI-B — Design System dan Komponen

- card;
- badge;
- tabs;
- stepper;
- drawer;
- confirmation;
- empty/error/loading;
- filter bar;
- sticky action;
- responsive.

## UI-C — Dashboard dan Permohonan

- dashboard;
- daftar permohonan;
- stepper buat permohonan;
- detail permohonan;
- progress tracker;
- readiness checklist.

## UI-D — Peti Kemas dan Penugasan

- daftar peti kemas;
- form full page;
- import wizard;
- penugasan Surveyor.

## UI-E — Monitoring, Review, Repair, Dokumen, Laporan

- monitoring;
- detail inspection;
- review workspace;
- repair follow-up;
- dokumen;
- laporan.

## UI-F — Master Khusus

- checklist builder;
- company profile singleton;
- signer drawer;
- lokasi dengan map placeholder;
- final responsive polish.

---

# 30. BATASAN

Jangan:

- mengubah database;
- membuat patch SQL;
- membuat migration;
- mengubah API backend;
- membuat UI Surveyor;
- membuat PDF final;
- membuat QR final;
- membuat finance;
- membuat VGM;
- membuat penimbangan;
- memakai istilah Kelayakan;
- memakai nama PT Global Inspeksi Sertifikasi pada branding GIFT;
- menghapus route lama tanpa compatibility;
- commit atau push kecuali diminta.

---

# 31. VALIDASI

Jalankan:

```bash
npm run typecheck --workspace apps/web
npm run build --workspace apps/web
git diff --check
```

Periksa:

- semua route dapat dibuka;
- tidak ada hydration error;
- sidebar aktif benar;
- mobile responsive;
- semua form memiliki state;
- tidak ada tombol palsu tanpa status;
- tidak ada istilah terlarang;
- tidak ada perubahan backend/database.

---

# 32. ACCEPTANCE CRITERIA

UI dianggap selesai jika:

1. Branding GIFT benar.
2. Sidebar tidak terlalu panjang.
3. Menu route sama menggunakan tabs.
4. Dashboard berorientasi tindakan.
5. Permohonan memakai stepper.
6. Detail permohonan punya progress tracker.
7. Form peti kemas dipisah per tab.
8. Penugasan memiliki readiness check.
9. Monitoring punya progress visual.
10. Review memakai dedicated workspace.
11. Checklist builder full page.
12. Company profile singleton page.
13. Semua form responsif.
14. Semua halaman memiliki loading, empty, error, dan success state.
15. Backend/database tidak berubah.
16. Build lulus.
17. Tidak ada Kelayakan/PM25/VGM baru.

---

# 33. OUTPUT CODEX

Setiap tahap melaporkan:

1. commit awal;
2. tahap yang dikerjakan;
3. file dibuat;
4. file diubah;
5. route baru;
6. komponen baru;
7. perubahan navigation;
8. perubahan branding;
9. perubahan form;
10. perubahan responsive;
11. mock data;
12. hasil typecheck;
13. hasil build;
14. hasil git diff;
15. deskripsi visual;
16. hal belum dikerjakan;
17. risiko UI;
18. rekomendasi tahap berikutnya.

Berhenti setelah tahap yang diminta.
Jangan commit dan jangan push.
