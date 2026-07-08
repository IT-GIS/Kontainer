# PRD — Sistem Kelaikan Peti Kemas

**Nama Produk:** Sistem Kelaikan Peti Kemas
**Nama Inggris:** Container Fitness Approval System
**Nama Repo:** `IT-GIS/Kontainer`
**Versi PRD:** 0.1
**Status:** Draft untuk perubahan arah aplikasi
**Tanggal:** 2026-07-06
**Pemilik Produk:** PT Global Inspeksi Sertifikasi / Tim GIFT-GIS
**Acuan Utama:** Peraturan Menteri Perhubungan Nomor 25 Tahun 2022 tentang Kelaikan Peti Kemas dan Berat Kotor Peti Kemas Terverifikasi

---

## 1. Ringkasan Produk

Aplikasi ini akan difokuskan menjadi **Sistem Informasi Pemeriksaan, Pengujian, dan Persetujuan Kelaikan Peti Kemas** berdasarkan Permenhub 25/2022.

Aplikasi tidak lagi diposisikan sebagai aplikasi umum untuk container survey berbasis CEDEX repair atau VGM, tetapi sebagai sistem operasional untuk mengelola:

1. Permohonan kelaikan peti kemas.
2. Input data teknis peti kemas baru dan peti kemas lama.
3. Penugasan surveyor/pemeriksa.
4. Pemeriksaan dan pengujian kelaikan.
5. Pencatatan temuan kerusakan/ketidaksesuaian.
6. Status perbaikan oleh pemilik/client/depo/bengkel.
7. Re-inspection setelah perbaikan.
8. Review dan persetujuan kelaikan.
9. Penerbitan dokumen persetujuan kelaikan atau surat pembebasan.
10. QR validation dokumen.

---

## 2. Latar Belakang

Aplikasi sebelumnya dibangun sebagai **Container Survey Management System** dengan pendekatan yang masih luas, termasuk konsep `survey_type`, CEDEX repair, responsibility code, report umum, dan finance.

Setelah evaluasi terhadap Permenhub 25/2022, fokus aplikasi perlu dipersempit agar sesuai dengan lingkup organisasi, yaitu:

> **Kelaikan Peti Kemas**, bukan VGM, bukan operasional repair, dan bukan general container damage survey.

Permenhub 25/2022 membahas dua ruang besar:

1. Kelaikan Peti Kemas.
2. Berat Kotor Peti Kemas Terverifikasi / Verified Gross Mass (VGM).

Produk ini hanya mengambil ruang lingkup **Kelaikan Peti Kemas**.

---

## 3. Tujuan Produk

### 3.1 Tujuan Utama

Menyediakan aplikasi internal untuk membantu Badan Usaha/Surveyor dalam proses pemeriksaan, pengujian, monitoring, review, dan penerbitan dokumen kelaikan peti kemas berdasarkan Permenhub 25/2022.

### 3.2 Tujuan Operasional

1. Admin dapat membuat permohonan kelaikan peti kemas.
2. Admin dapat menginput atau mengimpor data peti kemas.
3. Admin dapat menugaskan surveyor.
4. Surveyor dapat melakukan pemeriksaan dan pengujian kelaikan.
5. Sistem dapat mencatat hasil pemeriksaan dan temuan.
6. Sistem dapat mengelola status jika peti kemas perlu perbaikan.
7. Sistem dapat mendukung re-inspection sampai peti kemas dinyatakan layak atau tidak layak.
8. Supervisor/Reviewer dapat melakukan review dan approval.
9. Sistem dapat menghasilkan dokumen persetujuan sesuai format Permenhub 25/2022.
10. Dokumen dapat diverifikasi melalui QR validation.

---

## 4. Non-Goal / Di Luar Lingkup

Fitur berikut **tidak termasuk** dalam ruang lingkup produk ini:

1. Verified Gross Mass (VGM).
2. Penentuan berat kotor peti kemas terverifikasi.
3. Sertifikat VGM.
4. Persetujuan alat timbang VGM.
5. Persetujuan metode VGM.
6. Operasional penimbangan.
7. Billing repair.
8. Manajemen bengkel repair secara penuh.
9. Penentuan kode repair CEDEX sebagai keputusan perusahaan.
10. Marketplace atau sistem pembayaran client.
11. Sistem ERP lengkap.
12. PDF final yang sangat kompleks pada tahap awal.
13. Integrasi pemerintah eksternal, kecuali nanti dibutuhkan setelah MVP stabil.

---

## 5. Dasar Regulasi dan Interpretasi Produk

### 5.1 Kelaikan Peti Kemas

Permenhub 25/2022 mengatur bahwa kelaikan peti kemas dilakukan terhadap:

1. Peti Kemas Baru.
2. Peti Kemas Lama.

Aplikasi harus membedakan minimal dua kategori ini.

### 5.2 Peti Kemas Baru

Peti Kemas Baru dapat berkaitan dengan:

1. Persetujuan Kelaikan Peti Kemas Type Design.
2. Persetujuan Kelaikan Peti Kemas Individual.

Untuk MVP, fokus minimal dapat diarahkan ke **Peti Kemas Baru Individual**, lalu Type Design dapat masuk tahap lanjutan.

### 5.3 Peti Kemas Lama

Peti Kemas Lama dapat mencakup:

1. Peti kemas lama yang telah digunakan untuk mengangkut muatan dan belum mendapat persetujuan kelaikan peti kemas individual.
2. Peti kemas yang sudah diproduksi dan belum mendapatkan persetujuan pada saat diproduksi oleh pabrik pembuat peti kemas.

### 5.4 Perbaikan dan Re-Inspection

Jika peti kemas mengalami kerusakan, pemilik peti kemas harus melakukan perbaikan agar memenuhi persyaratan kelaikan.

Aplikasi tidak mengelola pekerjaan repair secara teknis sebagai bengkel, tetapi mencatat:

1. Temuan kerusakan.
2. Status perlu perbaikan.
3. Bukti/catatan bahwa client telah melakukan repair.
4. Jadwal dan hasil re-inspection.
5. Keputusan akhir: layak, tidak layak, atau masih perlu perbaikan.

---

## 6. Persona Pengguna

### 6.1 Super Admin

Mengelola seluruh konfigurasi sistem, user, role, permission, numbering, dan master data utama.

### 6.2 Admin Operasional

Mengelola permohonan kelaikan, data peti kemas, import container, penugasan surveyor, monitoring status, dan dokumen.

### 6.3 Surveyor / Pemeriksa

Melakukan pemeriksaan dan pengujian peti kemas, mengisi checklist, mencatat temuan, mengunggah foto evidence, dan submit hasil pemeriksaan.

### 6.4 Supervisor / Reviewer

Melakukan review hasil pemeriksaan, meminta perbaikan/re-inspection, approve kelaikan, atau menyatakan tidak layak.

### 6.5 Management

Melihat dashboard, rekap kegiatan, rekap peti kemas layak/tidak layak, dan laporan berkala.

### 6.6 Client / Pemilik Peti Kemas

Pada tahap awal belum perlu login. Client menerima dokumen, melakukan repair bila ada temuan, dan dapat melakukan validasi dokumen melalui QR publik.

---

## 7. Istilah Produk

| Istilah Lama | Status | Istilah Baru yang Disarankan |
|---|---|---|
| Customer | Diubah | Pemilik Peti Kemas |
| Job Order | Diubah | Permohonan Kelaikan |
| Survey Type | Dihapus/diganti | Kategori Kelaikan / Kategori Persetujuan |
| CEDEX Repair | Dihapus dari menu utama | Catatan Tindak Lanjut / Rekomendasi Perbaikan |
| Responsibility Code | Dihapus dari menu utama | Pihak Tindak Lanjut |
| Container Survey | Diubah | Pemeriksaan Kelaikan Peti Kemas |
| Report | Diubah | Dokumen Persetujuan / Dokumen Hasil Pemeriksaan |
| Approved | Disesuaikan | Layak / Persetujuan Kelaikan Terbit |
| Rejected | Disesuaikan | Tidak Layak / Tidak Disetujui |

---

## 8. Menu Admin Baru

### 8.1 Dashboard

- Ringkasan permohonan.
- Jumlah peti kemas diperiksa.
- Jumlah layak.
- Jumlah tidak layak.
- Jumlah perlu perbaikan.
- Jumlah menunggu re-inspection.
- Jumlah dokumen persetujuan terbit.
- Jumlah dokumen pembebasan terbit.

### 8.2 Master Data

1. Pemilik Peti Kemas.
2. Pabrik Pembuat Peti Kemas.
3. Lokasi Pemeriksaan.
4. Surveyor / Pemeriksa.
5. Jenis / Model Peti Kemas.
6. Komponen Struktur Peti Kemas.
7. Kriteria Kerusakan Struktur.
8. Parameter Pengujian.
9. Template Checklist Kelaikan.
10. Pejabat Penandatangan.
11. Profil Badan Usaha / Company Profile.

### 8.3 Permohonan Kelaikan

1. Daftar Permohonan.
2. Buat Permohonan.
3. Data Peti Kemas.
4. Import Data Peti Kemas.
5. Assign Surveyor.

### 8.4 Pemeriksaan & Pengujian

1. Monitoring Pemeriksaan.
2. Pemeriksaan Berjalan.
3. Perlu Perbaikan.
4. Siap Re-Inspection.
5. Layak.
6. Tidak Layak.

### 8.5 Review & Persetujuan

1. Pending Review.
2. Review History.
3. Persetujuan Kelaikan.
4. Pembebasan Setelah Perbaikan.

### 8.6 Dokumen

1. Surat Persetujuan Kelaikan.
2. Sertifikat / Approval Letter.
3. Data CSC Safety Approval Plate.
4. Surat Pembebasan.
5. QR Validation.

### 8.7 Laporan

1. Laporan Kegiatan 6 Bulanan.
2. Rekap Peti Kemas Layak.
3. Rekap Peti Kemas Tidak Layak / Tidak Disetujui.
4. Rekap Pemilik.
5. Rekap Pabrik Pembuat.

### 8.8 Setting

1. Company Profile.
2. Numbering Setting.
3. User Management.
4. Role & Permission.
5. Audit Log.

---

## 9. Menu yang Harus Dihapus atau Diubah

### 9.1 Dihapus dari Menu Utama

1. Survey Type.
2. CEDEX Repair.
3. Responsibility Code.
4. Modul VGM.
5. Modul penimbangan.
6. Sertifikat VGM.

### 9.2 Dipertahankan tetapi Diubah Konsep

1. CEDEX Location → dapat diganti menjadi Lokasi/Area Komponen Peti Kemas.
2. CEDEX Component → diganti menjadi Komponen Struktur Peti Kemas.
3. CEDEX Damage → diganti menjadi Kriteria Kerusakan.
4. Reports → diganti menjadi Dokumen Persetujuan / Dokumen Pemeriksaan.
5. Customer → diganti menjadi Pemilik Peti Kemas.
6. Job Order → diganti menjadi Permohonan Kelaikan.

---

## 10. Alur Utama Produk

### 10.1 Alur Permohonan Kelaikan

1. Admin membuat Permohonan Kelaikan.
2. Admin memilih Pemilik Peti Kemas.
3. Admin memilih kategori:
   - Peti Kemas Baru.
   - Peti Kemas Lama.
4. Admin memilih kategori persetujuan:
   - Baru Type Design.
   - Baru Individual.
   - Lama telah digunakan.
   - Lama diproduksi tanpa persetujuan awal.
5. Admin menginput data teknis peti kemas.
6. Admin menugaskan surveyor.
7. Surveyor melakukan pemeriksaan/pengujian.
8. Surveyor submit hasil.
9. Supervisor melakukan review.
10. Jika layak, dokumen persetujuan diterbitkan.
11. Jika belum layak, status menjadi Perlu Perbaikan.
12. Setelah repair oleh client, dilakukan re-inspection.
13. Jika hasil re-inspection layak, dokumen pembebasan/persetujuan diterbitkan.

---

## 11. Status Lifecycle

### 11.1 Status Permohonan

| Status | Keterangan |
|---|---|
| `draft` | Permohonan baru dibuat |
| `submitted` | Permohonan siap diproses |
| `assigned` | Surveyor telah ditugaskan |
| `inspection_in_progress` | Pemeriksaan berlangsung |
| `inspection_submitted` | Hasil pemeriksaan disubmit |
| `under_review` | Menunggu review |
| `need_repair` | Peti kemas perlu perbaikan |
| `repair_in_progress` | Client/pemilik melakukan perbaikan |
| `ready_for_reinspection` | Siap diperiksa ulang |
| `reinspection_in_progress` | Pemeriksaan ulang berlangsung |
| `fit` | Layak |
| `unfit` | Tidak layak |
| `suspended` | Dilarang/dihentikan sementara |
| `released` | Dibebaskan setelah diperbaiki |
| `approval_issued` | Dokumen persetujuan terbit |
| `closed` | Proses selesai |
| `cancelled` | Permohonan dibatalkan |

### 11.2 Status Peti Kemas

| Status | Keterangan |
|---|---|
| `not_started` | Belum diperiksa |
| `assigned` | Ditugaskan |
| `in_inspection` | Pemeriksaan berjalan |
| `submitted` | Hasil disubmit |
| `need_repair` | Perlu repair |
| `repair_in_progress` | Repair oleh client |
| `ready_for_reinspection` | Siap re-inspection |
| `reinspection` | Re-inspection berjalan |
| `fit` | Layak |
| `unfit` | Tidak layak |
| `suspended` | Tidak boleh digunakan sementara |
| `released` | Dapat digunakan kembali setelah repair |
| `certificate_issued` | Sertifikat/surat terbit |

---

## 12. Form Requirement

### 12.1 Form Pemilik Peti Kemas

Field minimal:

1. Kode Pemilik.
2. Nama Pemilik.
3. Alamat.
4. NPWP.
5. PIC.
6. Telepon PIC.
7. Email PIC.
8. Status.

### 12.2 Form Pabrik Pembuat Peti Kemas

Field minimal:

1. Kode Pabrik.
2. Nama Pabrik.
3. Alamat.
4. Negara.
5. PIC.
6. Telepon.
7. Email.
8. Status.

### 12.3 Form Permohonan Kelaikan

Field minimal:

1. Nomor permohonan.
2. Tanggal permohonan.
3. Pemilik Peti Kemas.
4. Pabrik Pembuat Peti Kemas.
5. Kategori Peti Kemas:
   - Baru.
   - Lama.
6. Kategori Persetujuan:
   - Baru Type Design.
   - Baru Individual.
   - Lama telah digunakan.
   - Lama diproduksi tanpa persetujuan awal.
7. Lokasi pemeriksaan.
8. PIC pemilik.
9. Nomor surat permohonan client.
10. Tanggal surat permohonan client.
11. Catatan/instruksi.
12. Status.

### 12.4 Form Data Teknis Peti Kemas

Field minimal mengikuti Contoh 8/9/10 Permenhub 25/2022:

1. Nomor Peti Kemas.
2. Nomor CSC.
3. Tanggal pembuatan.
4. Nomor seri pembuat.
5. Jenis/Model.
6. Berat kotor maksimal kg.
7. Berat kotor maksimal lb.
8. Berat kosong / tare kg.
9. Berat kosong / tare lb.
10. Berat muatan maksimum / payload kg.
11. Berat muatan maksimum / payload lb.
12. Kapasitas peti kemas m3.
13. Kapasitas peti kemas ft3.
14. Berat tumpukan yang diizinkan untuk 1.8g kg.
15. Berat tumpukan yang diizinkan untuk 1.8g lb.
16. Nilai pengujian pembebanan / racking test load value kg.
17. Nilai pengujian pembebanan / racking test load value lb.
18. Catatan.

### 12.5 Form Assign Surveyor

Field minimal:

1. Surveyor.
2. Tanggal mulai.
3. Tanggal jatuh tempo.
4. Daftar peti kemas.
5. Instruksi pemeriksaan.

### 12.6 Form Pemeriksaan Kelaikan

Field minimal:

1. Tanggal pemeriksaan.
2. Lokasi pemeriksaan.
3. Surveyor.
4. Nomor peti kemas.
5. Kategori peti kemas.
6. Checklist kelaikan.
7. Parameter pengujian.
8. Hasil pemeriksaan visual.
9. Hasil pengujian.
10. Temuan kerusakan.
11. Foto evidence.
12. Rekomendasi:
    - Layak.
    - Perlu perbaikan.
    - Tidak layak.
    - Dilarang digunakan sementara.
13. Catatan surveyor.

### 12.7 Form Temuan Kerusakan

Field minimal:

1. Komponen struktur.
2. Area/lokasi kerusakan.
3. Jenis kerusakan.
4. Tingkat kerusakan.
5. Ukuran kerusakan.
6. Kriteria berdasarkan Lampiran III.
7. Dampak terhadap kelaikan.
8. Rekomendasi tindak lanjut.
9. Foto evidence.
10. Catatan.

### 12.8 Form Repair Follow-up

Field minimal:

1. Nomor temuan.
2. Status repair:
   - Belum dilakukan.
   - Dalam perbaikan.
   - Selesai diperbaiki.
   - Perlu re-inspection.
3. Tanggal informasi repair.
4. Pihak yang melakukan repair.
5. Catatan repair dari client.
6. Bukti repair.
7. Status re-inspection.

### 12.9 Form Review

Field minimal:

1. Hasil pemeriksaan.
2. Hasil checklist.
3. Temuan kerusakan.
4. Foto.
5. Rekomendasi surveyor.
6. Keputusan reviewer:
   - Approve layak.
   - Need repair.
   - Need re-inspection.
   - Tidak layak.
   - Suspended.
7. Catatan reviewer.
8. Final result.

---

## 13. Dokumen Output

### 13.1 Surat Persetujuan Kelaikan Peti Kemas Baru Individual

Mengacu pada Contoh 8 Permenhub 25/2022.

Field dokumen:

1. Nomor surat.
2. Lampiran.
3. Perihal.
4. Nama pemilik/pabrik pembuat.
5. Nomor surat permohonan.
6. Tanggal surat permohonan.
7. Nama dan alamat pemilik.
8. Nama dan alamat pabrik pembuat.
9. Spesifikasi teknis peti kemas.
10. Pernyataan persetujuan.
11. Kewajiban menyediakan dan melekatkan pelat persetujuan kelaikan.
12. Tanda tangan pejabat berwenang.

### 13.2 Surat Persetujuan Peti Kemas Lama yang Telah Digunakan

Mengacu pada Contoh 9 Permenhub 25/2022.

Field dokumen:

1. Nomor surat.
2. Klasifikasi.
3. Lampiran.
4. Perihal.
5. Nama pemilik peti kemas.
6. Data teknis peti kemas.
7. Pernyataan persetujuan.
8. Kewajiban memasang pelat.
9. Kewajiban pemeliharaan.

### 13.3 Surat Persetujuan Peti Kemas yang Sudah Diproduksi dan Belum Mendapat Persetujuan

Mengacu pada Contoh 10 Permenhub 25/2022.

Field dokumen sama dengan peti kemas lama, tetapi narasi mengikuti kategori peti kemas yang sudah diproduksi dan belum mendapat persetujuan pada waktu pembuatan.

### 13.4 Data CSC Safety Approval Plate

Mengacu pada Contoh 11 Permenhub 25/2022.

Field minimal:

1. RI + identitas penerbit + referensi persetujuan + tahun.
2. Date Manufactured.
3. Identification Number.
4. Maximum Operating Gross Mass.
5. Allowable Stacking Load for 1.8g.
6. Transverse Racking Test Force.
7. End Wall Strength jika ada.
8. Side Wall Strength jika ada.
9. NED / pemeriksaan berikutnya jika digunakan.

### 13.5 Surat Pembebasan Peti Kemas Setelah Diperbaiki

Mengacu pada Contoh 23 Permenhub 25/2022.

Field dokumen:

1. Nomor surat.
2. Klasifikasi.
3. Lampiran.
4. Perihal.
5. Nama pemilik/nakhoda.
6. Lokasi pemeriksaan.
7. Nama pemeriksa.
8. Pemilik.
9. Nomor CSC.
10. Nomor peti kemas.
11. Nomor ISO Code.
12. Pernyataan telah memenuhi persyaratan kelaikan.
13. Rekomendasi pencabutan tanda larangan.
14. Tanda tangan pejabat.

---

## 14. Database Conceptual Model

### 14.1 Foundation Kelaikan Aktif

Tahap database foundation bersifat additive-only. Canonical model kelaikan dimulai dari:

1. `fitness_applications`
2. `application_containers`
3. `container_technical_specs`
4. `fitness_application_events`
5. `fitness_container_import_batches`
6. `fitness_container_import_rows`

Master foundation kelaikan:

1. `container_manufacturers`
2. `fitness_approval_categories`
3. `maintenance_schemes`
4. `inspection_areas`
5. `structural_components`
6. `structural_damage_criteria`
7. `finding_severities`
8. `inspection_test_parameters`
9. `fitness_checklist_templates`
10. `fitness_checklist_template_items`
11. `evidence_photo_categories`
12. `inspection_recommendations`
13. `authorized_signers`

Tabel inspection penuh, structural findings aktif, repair follow-up, re-inspection, approval final, approval documents, CSC plate records, release letters, dan QR final adalah tahap lanjutan.

### 14.2 Tabel Existing yang Dipakai Ulang Tanpa Rename Fisik

| Existing | Pemakaian dalam Kelaikan |
|---|---|
| `customers` | Pemilik Peti Kemas |
| `locations` | Lokasi Pemeriksaan |
| `surveyor_profiles` | Surveyor / Pemeriksa |
| `container_types` | Jenis / Model Peti Kemas |
| `users` | Akun dan actor |
| `roles` | Role aplikasi |
| `permissions` | Permission aplikasi |
| `role_permissions` | Mapping role permission |
| `user_roles` | Mapping user role |
| `company_profiles` | Profil Badan Usaha |
| `numbering_settings` | Konfigurasi nomor dokumen |
| `numbering_sequences` | Sequence nomor dokumen |
| `file_objects` | Metadata file |
| `audit_logs` | Audit log |

### 14.3 Legacy Archive

Tabel legacy seperti `job_orders`, `job_containers`, `assignments`, `surveys`, `survey_damages`, `reports`, finance legacy, `survey_types`, CEDEX tables, `responsibility_codes`, dan `container_import_batches` tetap dipertahankan sebagai archive/compatibility layer. Tabel tersebut tidak di-drop/rename dan tidak menjadi canonical model kelaikan.

`container_import_batches` tidak dipakai untuk import kelaikan karena masih terkait `job_order_id`; import kelaikan memakai `fitness_container_import_batches` dan `fitness_container_import_rows`.

---
## 15. API Requirement

### 15.1 Permohonan Kelaikan

- `GET /fitness-applications`
- `POST /fitness-applications`
- `GET /fitness-applications/:id`
- `PUT /fitness-applications/:id`
- `POST /fitness-applications/:id/containers`
- `POST /fitness-applications/:id/containers/import`
- `POST /fitness-applications/:id/assign`

### 15.2 Pemeriksaan

- `GET /fitness-inspections`
- `GET /fitness-inspections/:id`
- `POST /fitness-inspections/:id/start`
- `PUT /fitness-inspections/:id/general-info`
- `PUT /fitness-inspections/:id/checklist`
- `POST /fitness-inspections/:id/findings`
- `PUT /fitness-inspections/:id/findings/:finding_id`
- `POST /fitness-inspections/:id/photos`
- `POST /fitness-inspections/:id/submit`

### 15.3 Repair dan Re-inspection

- `POST /fitness-inspections/:id/need-repair`
- `POST /repair-followups/:id/mark-in-progress`
- `POST /repair-followups/:id/mark-completed`
- `POST /fitness-inspections/:id/ready-for-reinspection`
- `POST /fitness-inspections/:id/reinspection/start`
- `POST /fitness-inspections/:id/reinspection/submit`

### 15.4 Review dan Dokumen

- `GET /fitness-reviews/pending`
- `GET /fitness-reviews/history`
- `POST /fitness-reviews/:id/approve`
- `POST /fitness-reviews/:id/need-repair`
- `POST /fitness-reviews/:id/reject`
- `POST /approval-documents/generate`
- `GET /approval-documents/:id`
- `GET /approval-documents/:id/download`
- `GET /qr/validate/:token`

---

## 16. Role dan Permission

### 16.1 Super Admin

- Semua akses.

### 16.2 Admin

- Mengelola master data.
- Mengelola permohonan.
- Mengelola data peti kemas.
- Assign surveyor.
- Monitoring.
- Melihat dokumen.
- Tidak mengelola role & permission.

### 16.3 Surveyor

- Melihat assignment.
- Memulai pemeriksaan.
- Mengisi hasil pemeriksaan.
- Mengisi temuan.
- Upload foto.
- Submit hasil.
- Melakukan re-inspection jika ditugaskan.

### 16.4 Supervisor / Reviewer

- Melihat pending review.
- Approve.
- Need repair.
- Need re-inspection.
- Reject / unfit.
- Generate dokumen.

### 16.5 Management

- Dashboard read-only.
- Laporan read-only.
- Dokumen read-only.

---

## 17. Acceptance Criteria MVP

MVP dianggap selesai jika:

1. Admin bisa membuat permohonan kelaikan.
2. Admin bisa memilih kategori peti kemas baru/lama.
3. Admin bisa input data teknis sesuai Contoh 8/9/10.
4. Admin bisa assign surveyor.
5. Surveyor bisa melakukan pemeriksaan.
6. Surveyor bisa mengisi checklist dan temuan.
7. Surveyor bisa submit hasil.
8. Reviewer bisa approve layak.
9. Reviewer bisa memberi status perlu perbaikan.
10. Sistem mendukung re-inspection.
11. Sistem bisa menerbitkan draft dokumen persetujuan.
12. Sistem bisa menerbitkan surat pembebasan setelah repair.
13. QR validation tidak broken.
14. VGM tidak muncul di menu dan workflow utama.
15. CEDEX Repair dan Responsibility Code tidak muncul sebagai menu utama.
16. Survey Type tidak lagi menjadi input wajib aplikasi.

---

## 18. Migration Strategy

### 18.1 Tahap 0 — Dokumentasi dan Keputusan Scope

1. Tambahkan dokumen `.md`.
2. Update README.
3. Kunci scope: Kelaikan Peti Kemas saja.
4. Tandai VGM sebagai out of scope.

### 18.2 Tahap 1 — Rename Menu dan Konsep UI

1. Customer → Pemilik Peti Kemas.
2. Job Order → Permohonan Kelaikan.
3. Survey → Pemeriksaan Kelaikan.
4. Report → Dokumen Persetujuan.
5. Hide Survey Type.
6. Hide CEDEX Repair.
7. Hide Responsibility Code.

### 18.3 Tahap 2 — Database Compatibility Layer

1. Tambahkan field kategori peti kemas dan approval category.
2. Tambahkan field teknis sertifikat.
3. Tambahkan status lifecycle baru.
4. Buat view atau alias agar kode lama tidak langsung rusak.

### 18.4 Tahap 3 — Form Kelaikan Peti Kemas

1. Form Permohonan Kelaikan.
2. Form Data Teknis Peti Kemas.
3. Form Pemeriksaan Kelaikan.
4. Form Temuan Struktur.
5. Form Repair Follow-up.
6. Form Re-inspection.

### 18.5 Tahap 4 — Dokumen Kelaikan Peti Kemas

1. Template Contoh 8.
2. Template Contoh 9.
3. Template Contoh 10.
4. Template Contoh 23.
5. QR validation.

### 18.6 Tahap 5 — Hardening

1. Audit log.
2. Numbering final.
3. PDF final.
4. Permission hardening.
5. UAT role.
6. Import/export laporan.

---

## 19. Risiko Produk

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Refactor database terlalu cepat | Banyak fitur rusak | Gunakan compatibility layer |
| Menu lama masih muncul | User bingung | Hide dulu sebelum delete |
| VGM tercampur | Scope melebar | Tegaskan out of scope |
| Repair dianggap tanggung jawab internal | Salah lingkup | Jadikan repair sebagai status client follow-up |
| Sertifikat tidak sesuai Permenhub 25/2022 | Tidak memenuhi kebutuhan regulasi | Ikuti field Contoh 8/9/10/23 |
| Survey Type masih dipakai backend | Flow tidak sesuai | Ganti dengan kategori kelaikan |
| CEDEX terlalu dominan | Aplikasi jadi damage survey, bukan kelaikan | Fokus pada komponen struktur dan kriteria kelaikan |

---

## 20. Open Questions

1. Apakah MVP hanya fokus **Peti Kemas Lama** dulu, atau langsung Baru dan Lama?
2. Apakah Type Design masuk MVP atau tahap 2?
3. Siapa pejabat final penandatangan dokumen?
4. Apakah dokumen persetujuan diterbitkan per peti kemas atau bisa batch?
5. Apakah client perlu portal untuk upload bukti repair?
6. Apakah finance tetap dipakai atau dikeluarkan dari MVP?
7. Apakah integrasi QR validation cukup public page atau perlu API eksternal?
8. Apakah laporan 6 bulanan wajib masuk MVP?
9. Apakah data CSC Safety Approval Plate harus dicetak sebagai plate layout atau hanya data dokumen?
10. Apakah checklist kelaikan mengikuti template internal GIFT atau langsung dibangun dari Permenhub 25/2022 Lampiran II/III?

---

## 21. Rekomendasi Keputusan Produk

Keputusan yang disarankan:

1. Produk dinamai **Sistem Kelaikan Peti Kemas**.
2. VGM dinyatakan out of scope.
3. Survey Type dihapus sebagai konsep utama.
4. CEDEX Repair dihapus dari menu utama.
5. Responsibility Code dihapus dari menu utama.
6. Kategori utama adalah Peti Kemas Baru dan Peti Kemas Lama.
7. Repair dicatat sebagai tindak lanjut client/pemilik, bukan pekerjaan internal.
8. Re-inspection wajib ada.
9. Dokumen utama mengikuti Contoh 8, 9, 10, dan 23.
10. Database direstruktur bertahap agar aplikasi lama tidak langsung rusak.

---

## 22. Prompt Singkat untuk Codex Setelah PRD Disetujui

```text
Baca PRD_CONTAINER_FITNESS_KELAIKAN_PETI_KEMAS.md dan dokumen docs kelaikan peti kemas.
Buat plan implementasi bertahap untuk mengubah aplikasi dari Container Survey Management System menjadi Sistem Kelaikan Peti Kemas.
Jangan implement code dulu.
Fokus pada mapping menu, database, form, status lifecycle, dan dokumen.
Outputkan plan tahap 1 yang aman tanpa refactor besar.
```
## Addendum — Tahap Menu Admin Kelaikan Peti Kemas

Tahap menu Admin mengunci menu, placeholder halaman, dan dokumentasi form. Tahap database foundation menambahkan schema, numbering, permission, dan role mapping kelaikan secara additive. Belum ada CRUD API penuh, submit form aktif, PDF final, QR final, MinIO/watermark, finance kelaikan, atau cleanup legacy.

### Menu Admin saat Scope `container_fitness`

1. Dashboard Kelaikan
2. Master Data Kelaikan
3. Permohonan Kelaikan
   - Daftar Permohonan: `/fitness/applications`
   - Buat Permohonan: `/fitness/applications/create`
   - Data Peti Kemas: `/fitness/containers`
   - Import Data Peti Kemas: `/fitness/containers/import`
   - Assign Surveyor: `/fitness/assignments`
4. Pemeriksaan & Pengujian
5. Review & Keputusan Kelaikan
6. Dokumen Kelaikan
7. Laporan
8. Setting
9. Arsip Survey Lama

### Master Data Kelaikan

Master Data Kelaikan menjadi sumber pilihan bagi Surveyor lapangan:

- Pemilik Peti Kemas
- Pabrik Pembuat Peti Kemas
- Lokasi Pemeriksaan
- Surveyor / Pemeriksa
- Jenis / Model Peti Kemas
- Kategori Persetujuan Kelaikan
- Skema Pemeliharaan Peti Kemas
- Area Pemeriksaan Peti Kemas
- Komponen Struktur Peti Kemas
- Kriteria Kerusakan / Ketidaksesuaian
- Tingkat Temuan / Severity
- Parameter Pengujian Kelaikan
- Template Checklist Kelaikan
- Kategori Foto Evidence
- Rekomendasi Hasil Pemeriksaan
- Pejabat Penandatangan
- Profil Badan Usaha

### Placeholder Route Tahap Ini

Route `/fitness/*` hanya menampilkan placeholder tanpa API request, tanpa tombol simpan, dan tanpa mutation aktif. Setiap placeholder wajib menampilkan tujuan menu, field form, validasi ringkas, menu pemakai, dan hubungan ke Surveyor lapangan. Route placeholder khusus tahap ini mencakup `/fitness/applications/create` untuk Buat Permohonan dan `/fitness/containers/import` untuk Import Data Peti Kemas.

### Menu Legacy

Menu Survey Type, CEDEX, Responsibility Code, Job Order legacy, Monitoring Survey legacy, Review legacy, Report legacy, dan finance legacy tidak tampil di Admin Kelaikan aktif. Data lama tidak dihapus dan hanya diarahkan ke konsep Arsip Survey Lama atau mode `legacy`.
## Admin Master Data CRUD Stage 1

Tahap ini mengaktifkan CRUD nyata untuk 6 master data prioritas Sistem Kelaikan Peti Kemas:

1. Pemilik Peti Kemas (`/fitness/master-data/owners`) memakai tabel `customers`.
2. Pabrik Pembuat Peti Kemas (`/fitness/master-data/manufacturers`) memakai tabel `container_manufacturers`.
3. Lokasi Pemeriksaan (`/fitness/master-data/locations`) memakai tabel `locations`.
4. Surveyor / Pemeriksa (`/fitness/master-data/surveyors`) memakai tabel `surveyor_profiles`.
5. Jenis / Model Peti Kemas (`/fitness/master-data/container-types`) memakai tabel `container_types`.
6. Kategori Persetujuan Kelaikan (`/fitness/master-data/approval-categories`) memakai tabel `fitness_approval_categories`.

Setiap halaman aktif menyediakan list, pencarian, filter status, tambah, detail, edit, validasi dasar, dan aksi nonaktifkan sesuai endpoint REST `/api/v1/fitness/master-data/*`.

Menu yang masih placeholder:

- Master Data Kelaikan selain 6 menu Stage 1 menunggu tahap Master Data CRUD Stage 2.
- Assign Surveyor menunggu tahap Assignment Surveyor.
- Pemeriksaan & Pengujian menunggu tahap Surveyor Inspection Flow.
- Review & Keputusan menunggu tahap Review & Approval.
- Dokumen Kelaikan menunggu tahap Document & QR.

Batasan tahap ini:

- Tidak mengaktifkan workflow transaksi permohonan, assignment, pemeriksaan lapangan, review final, PDF, QR, import aktif, upload aktif, finance, repair, atau re-inspection.
- Tidak mengubah `database/kontainer_db.sql`, tabel legacy, atau patch `0015_container_fitness_foundation.sql`.
- Permission yang dipakai mengikuti foundation yang sudah ada: `*.view.all` untuk baca dan `*.manage.all` atau permission CRUD existing yang setara untuk perubahan data.
- Patch `0016_container_fitness_master_stage1_permissions.sql` menyelaraskan permission granular `create.all`, `update.all`, dan `delete.all` untuk `container_manufacturers` dan `fitness_approval_categories` agar CRUD Stage 1 berjalan dengan pola permission frontend dan backend saat ini.

Tahap berikutnya adalah Master Data CRUD Stage 2 untuk master pendukung checklist, temuan, foto evidence, rekomendasi, penandatangan, dan profil badan usaha sebelum workflow assignment dan inspection diaktifkan.
