# FINALISASI FULL MENU ADMIN  
## Sistem Kelaikan Peti Kemas — Rencana Implementasi Bertahap

**Repository:** `IT-GIS/Kontainer`  
**Scope:** Finalisasi penuh sisi Admin sebelum masuk ke UI/flow Surveyor  
**Nama aplikasi:** Sistem Kelaikan Peti Kemas  
**Nama Inggris:** Container Fitness Approval System  
**Referensi hukum:** Permenhub 25/2022  

---

# 1. TUJUAN DOKUMEN

Dokumen ini menjadi instruksi kerja bertahap untuk Codex dalam menyelesaikan seluruh menu Admin Sistem Kelaikan Peti Kemas sampai:

- setiap menu Admin memiliki status implementasi yang jelas;
- setiap form sesuai dengan kolom database;
- setiap dropdown relasi mengambil data nyata dari database;
- setiap endpoint memiliki permission yang benar;
- dashboard, permohonan, data peti kemas, import, assignment, monitoring, review, dokumen metadata, laporan, setting, dan arsip tersambung dengan benar;
- database siap deploy;
- data runtime lokal tidak ikut dalam canonical dump;
- seluruh build, test, migrasi, dan UAT lulus;
- flow Surveyor belum dibuat pada tahap ini.

Dokumen ini harus dikerjakan **bertahap**, bukan sekaligus tanpa kontrol.

---

# 2. ATURAN GLOBAL WAJIB

## 2.1 Istilah

Gunakan:

- **Kelaikan**
- **Sistem Kelaikan Peti Kemas**
- **Container Fitness Approval System**
- **Permenhub 25/2022** hanya sebagai referensi hukum pada dokumentasi/help text

Jangan gunakan:

- `PM25`
- `PM 25`
- `pm25`
- `Kelayakan`

Larangan berlaku pada:

- nama file;
- route;
- nama tabel;
- permission;
- module;
- variable;
- config;
- identifier kode;
- menu;
- dokumentasi baru.

## 2.2 Fitur di luar scope

Jangan membuat:

- VGM;
- penimbangan;
- sertifikat VGM;
- data verified gross mass;
- finance kelaikan;
- invoice kelaikan;
- payment kelaikan;
- billing repair;
- operasional bengkel;
- Type Design aktif;
- PDF final;
- QR final;
- public verification final.

## 2.3 Legacy

Tabel legacy tidak boleh menjadi canonical workflow kelaikan.

Jangan gunakan untuk flow aktif:

- `job_orders`
- `job_containers`
- `assignments`
- `assignment_containers`
- `surveys`
- `survey_general_infos`
- `survey_checklist_responses`
- `survey_damages`
- `survey_photos`
- `survey_approvals`
- `reports`
- `report_versions`
- `report_snapshots`
- `invoices`
- `invoice_items`
- `payments`
- `price_lists`
- `survey_types`
- tabel CEDEX
- `responsibility_codes`

Tabel legacy hanya boleh:

- dibaca;
- ditampilkan pada Arsip Survey Lama;
- dipertahankan untuk compatibility.

Jangan drop atau rename tabel legacy.

---

# 3. STATUS IMPLEMENTASI YANG DIPAKAI

Setiap submenu Admin wajib memiliki salah satu status:

| Status | Arti |
|---|---|
| `ACTIVE_DB_CONNECTED` | Halaman, form, API, permission, dan database aktif |
| `ACTIVE_READ_ONLY` | Halaman mengambil data nyata dari database tanpa mutation |
| `PLACEHOLDER_LOCKED` | Fitur belum aktif dan tidak boleh punya tombol palsu |
| `LEGACY_ARCHIVE` | Data lama hanya dapat dibaca |
| `OUT_OF_SCOPE` | Tidak ditampilkan dalam workspace Admin Kelaikan |

---

# 4. TAHAP 0 — AUDIT BASELINE REPO DAN DATABASE

## 4.1 Tujuan

Mendapatkan gambaran aktual sebelum coding.

## 4.2 Pekerjaan

Periksa:

- branch aktif;
- commit terbaru;
- `.env.example`;
- route frontend;
- navigation Admin;
- component setiap halaman;
- endpoint API;
- permission;
- role mapping;
- migration terakhir;
- patch SQL terakhir;
- `database/kontainer_db.sql`;
- dump database lokal terbaru;
- dokumentasi yang sudah tersedia.

## 4.3 File audit wajib

Buat:

`docs/ADMIN_FINAL_AUDIT.md`

Isi tabel:

| Grup Menu | Submenu | Route Frontend | Component | Endpoint API | Permission | Tabel DB | Status Sebelum | Gap | Status Target | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|

## 4.4 Validasi

Sebuah menu hanya boleh diberi status `ACTIVE_DB_CONNECTED` jika:

- route frontend nyata ada;
- component bukan placeholder;
- API tersedia;
- permission tersedia;
- tabel tersedia;
- create/read/update/nonaktifkan berhasil;
- loading state tersedia;
- empty state tersedia;
- error state tersedia.

## 4.5 Output Tahap 0

Laporkan:

1. commit awal;
2. daftar route;
3. daftar API;
4. daftar permission;
5. daftar tabel;
6. daftar placeholder;
7. gap setiap submenu;
8. risiko migrasi.

---

# 5. TAHAP 1 — HARDENING GENERIC MASTER DATA

## 5.1 File utama

Periksa dan perbaiki:

- `apps/web/components/master/master-data-page.tsx`
- `apps/web/constants/master-data.ts`
- `services/api/internal/masterdata/*`

## 5.2 Tipe field yang harus didukung

Tambahkan:

- `text`
- `textarea`
- `number`
- `decimal`
- `email`
- `tel`
- `url`
- `date`
- `datetime-local`
- `select`
- `searchable-select`
- `checkbox`
- `hidden`

## 5.3 Perbaikan form generik

Wajib:

- textarea untuk field panjang;
- date input untuk field tanggal;
- url input untuk website;
- tel input untuk telepon;
- decimal step yang benar;
- validasi required frontend dan backend;
- success message;
- error message yang ramah;
- double-submit prevention;
- tombol Simpan disabled saat request;
- debounce pada search;
- retry saat API gagal;
- empty state informatif;
- relation dropdown tidak menampilkan UUID;
- relation dropdown mendukung data inactive saat edit;
- searchable dropdown untuk data besar;
- tidak dibatasi 100 record tanpa mekanisme search;
- warning ketika record masih dipakai oleh foreign key;
- nonaktifkan, bukan hard delete.

## 5.4 Status filter per resource

Master umum:

- `active`
- `inactive`

Checklist template:

- `draft`
- `active`
- `inactive`

Company profile:

- boolean aktif/tidak aktif

Application:

- `draft`
- `submitted`
- `assigned`
- `in_progress`
- `under_review`
- `need_repair`
- `ready_for_reinspection`
- `completed`
- `cancelled`

## 5.5 Label Bahasa Indonesia

Gunakan:

- Aktif
- Tidak Aktif
- Draf
- Menunggu
- Layak
- Tidak Layak
- Perlu Perbaikan
- Dibatalkan

## 5.6 Acceptance Criteria Tahap 1

- semua master bisa list/search/filter/create/detail/edit/nonaktifkan;
- tidak ada UUID mentah pada kolom relasi;
- semua tipe input sesuai data;
- filter status resource-specific;
- error API tampil jelas;
- tidak ada double-submit;
- tidak ada hard delete master.

---

# 6. TAHAP 2 — AUDIT DAN FINALISASI SEMUA FORM MASTER DATA

## 6.1 Pemilik Peti Kemas

**Route:** `/fitness/master-data/owners`  
**Endpoint:** `/api/v1/fitness/master-data/owners`  
**Table:** `customers`

Field:

- `customer_code` wajib unik;
- `customer_name` wajib;
- `address` textarea;
- `npwp`;
- `pic_name`;
- `pic_phone` tel;
- `pic_email` email;
- `billing_address` textarea;
- `status`.

Aturan:

- label UI harus “Pemilik Peti Kemas”;
- field finance lama tidak perlu ditonjolkan;
- nonaktifkan, bukan hard delete;
- warning jika masih punya permohonan aktif.

## 6.2 Pabrik Pembuat Peti Kemas

**Table:** `container_manufacturers`

Field:

- `manufacturer_code`
- `manufacturer_name`
- `address`
- `country`
- `pic_name`
- `pic_phone`
- `pic_email`
- `website`
- `note`
- `status`

Validasi:

- kode unik;
- nama wajib;
- email valid;
- website valid;
- address/note textarea.

## 6.3 Lokasi Pemeriksaan

**Table:** `locations`

Field:

- `location_code`
- `location_name`
- `location_type`
- `address`
- `city`
- `gps_latitude`
- `gps_longitude`
- `pic_name`
- `pic_phone`
- `status`

Validasi:

- latitude `-90` s.d. `90`;
- longitude `-180` s.d. `180`;
- code unik;
- name dan type wajib.

## 6.4 Surveyor/Pemeriksa

**Table:** `surveyor_profiles`

Field:

- `user_id`
- `surveyor_code`
- `name`
- `phone`
- `area`
- `signature_file_id`
- `status`

Aturan:

- `user_id` dropdown akun aktif role Surveyor;
- satu user satu profile;
- nilai aktif lama tetap tampil saat edit;
- UUID tidak boleh diinput manual;
- `surveyor_code` unik.

## 6.5 Jenis/Model Peti Kemas

**Table:** `container_types`

Field:

- `code`
- `iso_code`
- `size`
- `type`
- `description`
- `status`

Aturan:

- tidak hard delete;
- tipe luar MVP dapat dinonaktifkan;
- field alias backend/frontend harus konsisten.

## 6.6 Kategori Persetujuan Kelaikan

**Table:** `fitness_approval_categories`

Field:

- `code`
- `name`
- `description`
- `container_lifecycle`
- `is_mvp_active`
- `display_order`
- `status`

Aturan:

- lifecycle hanya `new` atau `existing`;
- Type Design tetap inactive;
- Type Design tidak muncul di form permohonan aktif.

## 6.7 Skema Pemeliharaan

**Table:** `maintenance_schemes`

Field:

- `code`
- `name`
- `description`
- `requires_next_examination_date`
- `default_interval_months`
- `status`

Aturan:

- interval > 0;
- ACEP/PES tidak boleh terhapus;
- beri help text NED.

## 6.8 Area Pemeriksaan

**Table:** `inspection_areas`

Field:

- `code`
- `area_name`
- `description`
- `display_order`
- `status`

## 6.9 Komponen Struktur

**Table:** `structural_components`

Field:

- `code`
- `component_name`
- `inspection_area_id`
- `is_structural_critical`
- `description`
- `display_order`
- `status`

Aturan:

- `inspection_area_id` dropdown;
- list/detail menampilkan nama area;
- filter area tersedia.

## 6.10 Kriteria Kerusakan/Ketidaksesuaian

**Table:** `structural_damage_criteria`

Field:

- `code`
- `criteria_name`
- `component_id`
- `description`
- `severity_default`
- `affects_fitness_default`
- `repair_required_default`
- `inspection_note`
- `status`

Aturan:

- component dropdown;
- severity `minor/major/critical`;
- tampilkan warning jika memengaruhi kelaikan.

## 6.11 Tingkat Temuan/Severity

**Table:** `finding_severities`

Field:

- `code`
- `name`
- `description`
- `level_no`
- `affects_fitness_default`
- `requires_supervisor_review`
- `badge_tone`
- `status`

Aturan:

- level positif;
- critical wajib review supervisor;
- critical wajib memengaruhi kelaikan.

## 6.12 Parameter Pengujian

**Table:** `inspection_test_parameters`

Field:

- `code`
- `parameter_name`
- `description`
- `unit`
- `standard_reference`
- `applies_to_new_container`
- `applies_to_existing_container`
- `requires_numeric_result`
- `requires_attachment`
- `display_order`
- `status`

Aturan:

- minimal satu lifecycle aktif;
- unit dianjurkan wajib bila hasil numerik;
- jangan memasukkan klaim standar yang tidak terverifikasi.

## 6.13 Template Checklist

**Table:** `fitness_checklist_templates`

Field:

- `template_code`
- `template_name`
- `approval_category_id`
- `container_type_id`
- `description`
- `version_no`
- `status`

Aturan:

- relation dropdown;
- tampilkan jumlah item aktif;
- tombol Kelola Item;
- template tidak boleh aktif tanpa item;
- version minimal 1;
- filter mendukung draft/active/inactive.

## 6.14 Item Template Checklist

**Route:** `/fitness/master-data/checklist-templates/[id]/items`  
**Table:** `fitness_checklist_template_items`

Field:

- `template_id` fixed;
- `item_code`;
- `item_label`;
- `description`;
- `inspection_area_id`;
- `structural_component_id`;
- `test_parameter_id`;
- `response_type`;
- `expected_value`;
- `is_required`;
- `is_critical`;
- `fail_requires_repair`;
- `fail_marks_unfit`;
- `display_order`;
- `status`.

Response type:

- `ok_not_ok`
- `yes_no`
- `text`
- `number`
- `date`
- `photo_required`
- `not_applicable`

Aturan:

- item code unik per template;
- template id tidak boleh diubah dari payload;
- `fail_marks_unfit` hanya untuk item critical;
- list menampilkan label relation, bukan UUID.

## 6.15 Kategori Foto Evidence

**Table:** `evidence_photo_categories`

Field:

- `code`
- `name`
- `description`
- `is_required_default`
- `applies_to`
- `display_order`
- `status`

`applies_to` menjadi select:

- inspection
- finding
- test
- repair
- reinspection
- document

## 6.16 Rekomendasi Hasil Pemeriksaan

**Table:** `inspection_recommendations`

Field:

- `code`
- `name`
- `description`
- `final_fitness_result_mapping`
- `workflow_status_mapping`
- `restriction_status_mapping`
- `requires_supervisor_review`
- `status`

Allowed:

Final result:

- pending
- fit
- unfit

Workflow:

- under_review
- need_repair
- ready_for_reinspection
- completed

Restriction:

- none
- suspended
- prohibited
- released

## 6.17 Pejabat Penandatangan

**Table:** `authorized_signers`

Field:

- `signer_name`
- `position_title`
- `employee_no`
- `email`
- `phone`
- `signature_file_id`
- `valid_from`
- `valid_until`
- `status`

Aturan:

- date input;
- valid until tidak boleh sebelum valid from;
- signer expired tidak boleh dipakai;
- upload tanda tangan belum aktif.

## 6.18 Profil Badan Usaha

**Table:** `company_profiles`

Field:

- `company_name`
- `brand_name`
- `address`
- `phone`
- `email`
- `website`
- `tax_no`
- `logo_file_id`
- `default_signature_file_id`
- `is_active`

Aturan:

- singleton;
- jika sudah ada, tombol Tambah disembunyikan;
- hanya Edit;
- tidak boleh ada dua profile aktif;
- Master Data dan Setting memakai record fisik yang sama.

## 6.19 Acceptance Criteria Tahap 2

- semua field frontend cocok dengan backend dan DB;
- semua dropdown terhubung DB;
- semua validasi berjalan;
- tidak ada form ID manual;
- company profile singleton;
- semua list/detail menampilkan label relasi.

---

# 7. TAHAP 3 — CHECKLIST SEED DEFAULT

## 7.1 Patch

Buat:

`database/patches/0019_container_fitness_admin_finalization.sql`

Gunakan patch ini juga untuk hardening additive kecil bila diperlukan.

Jangan mengubah patch `0015` sampai `0018`.

## 7.2 Template Default

Seed:

- `template_code`: `FIT-GENERAL-DEFAULT`
- `template_name`: `Template Pemeriksaan Kelaikan Peti Kemas Umum`
- `version_no`: `1`
- `status`: `active`
- `approval_category_id`: nullable
- `container_type_id`: nullable

## 7.3 Item minimal

1. Identitas nomor peti kemas terbaca dan sesuai.
2. Check digit nomor peti kemas sesuai.
3. CSC Safety Approval Plate tersedia dan terbaca.
4. Nomor CSC sesuai data teknis.
5. Tanggal pembuatan dapat diverifikasi.
6. Corner fitting tidak rusak kritis.
7. Corner post tidak deformasi kritis.
8. Top side rail layak.
9. Bottom side rail layak.
10. Cross member dan struktur bawah layak.
11. Roof tidak bocor atau rusak berat.
12. Side wall tidak berlubang atau rusak berat.
13. End wall layak.
14. Door panel berfungsi.
15. Locking bar dan keeper berfungsi.
16. Door gasket baik.
17. Lantai layak.
18. Ventilator baik.
19. Watertightness sesuai kebutuhan.
20. Tidak ada kondisi yang memengaruhi kelaikan.

## 7.4 Aturan seed

- idempotent;
- tidak duplikat;
- aman dijalankan berulang;
- tidak mengubah data user;
- gunakan relation jika dapat dipetakan dengan aman.

---

# 8. TAHAP 4 — DASHBOARD ADMIN KELAIKAN

## 8.1 Route

`/fitness/dashboard`

## 8.2 Endpoint

`GET /api/v1/fitness/dashboard`

## 8.3 Permission

`dashboard.view.all`

## 8.4 Data dashboard

Card:

- Total Permohonan
- Permohonan Draf
- Permohonan Siap Ditugaskan
- Permohonan Berjalan
- Permohonan Perlu Perbaikan
- Permohonan Selesai
- Total Peti Kemas
- Peti Kemas Pending
- Peti Kemas Layak
- Peti Kemas Tidak Layak
- Peti Kemas Dibatasi
- Checklist Template Aktif

Section:

- permohonan terbaru;
- peti kemas terbaru;
- ringkasan kategori;
- ringkasan pemilik;
- ringkasan status;
- kelengkapan master data.

Aturan:

- jangan angka dummy;
- jika kosong tampilkan 0;
- tidak error pada database kosong;
- query read-only;
- permission diterapkan.

---

# 9. TAHAP 5 — PERMOHONAN KELAIKAN

## 9.1 Route

- `/fitness/applications`
- `/fitness/applications/create`
- `/fitness/applications/[id]`
- `/fitness/applications/[id]/edit`

## 9.2 API

- `GET /api/v1/fitness/applications`
- `POST /api/v1/fitness/applications`
- `GET /api/v1/fitness/applications/:id`
- `PUT /api/v1/fitness/applications/:id`
- `POST /api/v1/fitness/applications/:id/cancel`
- `GET /api/v1/fitness/applications/:id/events`
- `GET /api/v1/fitness/applications/:id/containers`

## 9.3 Table

- `fitness_applications`
- `fitness_application_events`

## 9.4 Form

- `application_no` generated backend, read-only;
- `application_date` wajib, default hari ini;
- `owner_id` wajib;
- `manufacturer_id` optional;
- `location_id` wajib;
- `approval_category_id` wajib;
- `client_letter_no`;
- `client_letter_date`;
- `pic_name`;
- `pic_phone`;
- `pic_email`;
- `instruction`;
- `workflow_status` default draft.

## 9.5 Numbering

Gunakan:

- `numbering_settings.document_type = fitness_application`
- `numbering_sequences`

Gunakan transaction + row locking.

Jangan hardcode nomor.

## 9.6 Daftar Permohonan

Kolom:

- No Permohonan
- Tanggal
- Pemilik
- Pabrik
- Lokasi
- Kategori
- Jumlah Peti Kemas
- Status
- Dibuat Oleh
- Waktu Dibuat
- Aksi

Filter:

- tanggal;
- pemilik;
- lokasi;
- kategori;
- status.

## 9.7 Pembatalan

Tidak hard delete.

Tambahkan jika belum ada:

- `cancel_reason`
- `cancelled_at`
- `cancelled_by`

Cancel:

- alasan wajib;
- event dicatat;
- status jadi `cancelled`.

## 9.8 Event

- `application.created`
- `application.updated`
- `application.cancelled`
- `container.added`
- `container.updated`
- `container.deactivated`
- `assignment.created`

## 9.9 Acceptance Criteria Tahap 5

- create application;
- nomor otomatis unik;
- detail tampil;
- edit draft;
- cancel dengan alasan;
- timeline event;
- dropdown hanya data aktif;
- Type Design tidak muncul;
- permission benar.

---

# 10. TAHAP 6 — DATA PETI KEMAS DAN SPESIFIKASI TEKNIS

## 10.1 Route

- `/fitness/containers`
- `/fitness/containers/[id]`
- `/fitness/applications/[id]/containers`

## 10.2 API

- `GET /api/v1/fitness/containers`
- `POST /api/v1/fitness/containers`
- `GET /api/v1/fitness/containers/:id`
- `PUT /api/v1/fitness/containers/:id`
- `DELETE /api/v1/fitness/containers/:id`
- `GET /api/v1/fitness/containers/:id/technical-specs`
- `PUT /api/v1/fitness/containers/:id/technical-specs`
- `POST /api/v1/fitness/applications/:id/containers`

## 10.3 Table

- `application_containers`
- `container_technical_specs`

## 10.4 Form Identitas

- `fitness_application_id`
- `container_no`
- `owner_code`
- `serial_number`
- `check_digit`
- `check_digit_status`
- `check_digit_override_reason`
- `container_type_id`
- `iso_type_code`
- `remark`

## 10.5 Form Teknis

- `csc_no`
- `manufacture_date`
- `manufacturer_serial_no`
- `type_model`
- `iso_code`
- `max_gross_weight_kg`
- `max_gross_weight_lbs`
- `tare_weight_kg`
- `tare_weight_lbs`
- `payload_weight_kg`
- `payload_weight_lbs`
- `cube_capacity_m3`
- `cube_capacity_ft3`
- `allowable_stacking_weight_kg`
- `allowable_stacking_weight_lbs`
- `racking_test_load_value_kg`
- `racking_test_load_value_lbs`
- `end_wall_strength`
- `side_wall_strength`
- `next_examination_date`
- `maintenance_scheme_id`

## 10.6 Check Digit

- uppercase;
- hapus spasi/karakter tidak perlu;
- format 4 huruf + 7 angka;
- parse owner code;
- parse serial number;
- parse check digit;
- hitung ISO 6346;
- simpan:
  - `not_checked`
  - `valid`
  - `invalid`
  - `overridden`

Override:

- wajib alasan;
- audit log;
- tidak otomatis menjadi valid.

## 10.7 Validasi Berat

- tidak negatif;
- payload tidak lebih besar max gross;
- tare tidak lebih besar max gross;
- relasi payload/tare/max gross masuk akal;
- jangan menyebut VGM.

## 10.8 Status

Workflow:

- draft
- assigned
- inspection_in_progress
- inspection_submitted
- under_review
- need_repair
- repair_in_progress
- ready_for_reinspection
- reinspection_in_progress
- completed
- cancelled

Final result:

- pending
- fit
- unfit

Restriction:

- none
- suspended
- prohibited
- released

Approval:

- not_ready
- pending_issue
- issued
- superseded
- revoked

---

# 11. TAHAP 7 — IMPORT DATA PETI KEMAS

## 11.1 Route

`/fitness/containers/import`

## 11.2 Table

- `fitness_container_import_batches`
- `fitness_container_import_rows`

Jangan gunakan `container_import_batches` legacy.

## 11.3 API

- `POST /api/v1/fitness/container-imports/preview`
- `GET /api/v1/fitness/container-imports`
- `GET /api/v1/fitness/container-imports/:id`
- `POST /api/v1/fitness/container-imports/:id/commit`
- `POST /api/v1/fitness/container-imports/:id/cancel`

## 11.4 Format

- CSV
- XLSX

## 11.5 Workflow

1. Pilih permohonan.
2. Upload.
3. Baca header.
4. Mapping kolom.
5. Preview.
6. Validasi baris.
7. Tampilkan sukses/gagal.
8. Commit baris valid.
9. Simpan error per baris.
10. Catat event.

## 11.6 Kolom minimal

- container_no
- container_type
- iso_type_code
- csc_no
- manufacture_date
- manufacturer_serial_no
- type_model
- max_gross_weight_kg
- tare_weight_kg
- payload_weight_kg

## 11.7 Keamanan

- batas ukuran;
- validasi MIME/ext;
- jangan eksekusi formula;
- tidak simpan permanen bila tidak perlu;
- MinIO belum aktif.

---

# 12. TAHAP 8 — ASSIGN SURVEYOR DARI SISI ADMIN

## 12.1 Patch

Buat:

`database/patches/0020_container_fitness_assignment_inspection_foundation.sql`

## 12.2 Table `fitness_assignments`

Field:

- id
- assignment_no
- fitness_application_id
- surveyor_id
- assigned_by
- assigned_at
- planned_date
- due_date
- instruction
- status
- cancel_reason
- cancelled_at
- cancelled_by
- created_at
- updated_at

## 12.3 Table `fitness_assignment_containers`

Field:

- id
- fitness_assignment_id
- application_container_id
- assigned_at
- unassigned_at
- unassigned_reason

## 12.4 Constraint

- assignment no unik;
- satu container tidak punya dua assignment aktif;
- surveyor harus aktif;
- application tidak cancelled;
- container tidak cancelled.

## 12.5 API

- `GET /api/v1/fitness/assignments`
- `POST /api/v1/fitness/assignments`
- `GET /api/v1/fitness/assignments/:id`
- `PUT /api/v1/fitness/assignments/:id`
- `POST /api/v1/fitness/assignments/:id/cancel`
- `POST /api/v1/fitness/assignments/:id/reassign`
- `GET /api/v1/fitness/assignments/:id/containers`

## 12.6 Form

- assignment_no otomatis;
- application dropdown;
- surveyor dropdown;
- container multi-select;
- planned_date;
- due_date;
- instruction.

## 12.7 Setelah assignment

- workflow container jadi assigned;
- status aggregate application diperbarui;
- event dicatat;
- tidak memakai tabel legacy.

---

# 13. TAHAP 9 — FOUNDATION MONITORING PEMERIKSAAN ADMIN

## 13.1 Table additive

Buat jika belum tersedia:

- `fitness_inspections`
- `fitness_inspection_general_infos`
- `fitness_checklist_responses`
- `fitness_test_results`
- `structural_findings`
- `finding_photos`
- `repair_followups`
- `repair_followup_findings`

## 13.2 Menu Admin

Route:

`/fitness/inspections`

Status:

`ACTIVE_READ_ONLY`

Admin hanya:

- melihat;
- mencari;
- filter;
- detail;
- monitoring status.

Jangan membuat UI Surveyor.

## 13.3 Filter

- waiting
- in_progress
- submitted
- need_revision
- need_repair
- ready_for_reinspection
- completed
- fit
- unfit

---

# 14. TAHAP 10 — TINDAK LANJUT PERBAIKAN

## 14.1 Route

`/fitness/repair-followups`

## 14.2 API

- `GET /api/v1/fitness/repair-followups`
- `POST /api/v1/fitness/repair-followups`
- `GET /api/v1/fitness/repair-followups/:id`
- `PUT /api/v1/fitness/repair-followups/:id`
- `POST /api/v1/fitness/repair-followups/:id/mark-completed`
- `POST /api/v1/fitness/repair-followups/:id/ready-for-reinspection`

## 14.3 Field

- application_container_id
- fitness_inspection_id
- followup_no
- repair_party_name
- repair_party_type
- client_note
- repair_completed_date
- ready_for_reinspection_at
- status

`repair_party_type`:

- owner
- depot
- workshop
- manufacturer
- other

Status:

- required
- in_progress
- completed_by_owner
- ready_for_reinspection
- accepted
- still_defective
- closed

Batasan:

- bukan operasional bengkel;
- bukan billing;
- bukan finance.

---

# 15. TAHAP 11 — REVIEW DAN KEPUTUSAN

## 15.1 Patch

Buat:

`database/patches/0021_container_fitness_review_document_foundation.sql`

## 15.2 Table

- `fitness_reviews`
- `fitness_approvals`
- `approval_documents`
- `approval_document_versions`
- `csc_plate_records`

## 15.3 Route

`/fitness/reviews`

## 15.4 API

- `GET /api/v1/fitness/reviews`
- `GET /api/v1/fitness/reviews/:id`
- `POST /api/v1/fitness/reviews/:id/decision`
- `POST /api/v1/fitness/reviews/:id/request-revision`

## 15.5 Decision

- fit
- need_repair
- unfit
- need_reinspection

## 15.6 Aturan

- inspection harus submitted;
- reason wajib untuk repair/unfit/revision;
- audit log;
- workflow, restriction, final result konsisten;
- dual control bila diberlakukan.

---

# 16. TAHAP 12 — DOKUMEN METADATA DAN PREVIEW

## 16.1 Route

`/fitness/documents`

## 16.2 Status

`ACTIVE_DB_CONNECTED` untuk metadata dan preview HTML.

Belum boleh:

- PDF final;
- QR final;
- watermark final;
- public verification final.

## 16.3 Document type

- approval_new_individual
- approval_existing_used
- approval_existing_without_initial_approval
- release_after_repair

## 16.4 Data

- pemilik;
- pabrik;
- container number;
- CSC no;
- manufacture date;
- serial;
- type/model;
- ISO code;
- maximum gross;
- tare;
- payload;
- cube;
- stacking;
- racking;
- end wall;
- side wall;
- NED;
- maintenance scheme;
- signer.

## 16.5 Fitur

- metadata;
- versioning;
- immutable snapshot;
- signer selection;
- CSC plate record;
- preview HTML.

---

# 17. TAHAP 13 — LAPORAN ADMIN

## 17.1 Route

`/fitness/reports`

## 17.2 API

- `GET /api/v1/fitness/reports/summary`
- `GET /api/v1/fitness/reports/inspections`
- `GET /api/v1/fitness/reports/containers`
- `GET /api/v1/fitness/reports/owners`
- `GET /api/v1/fitness/reports/manufacturers`
- `GET /api/v1/fitness/reports/six-monthly-preview`

## 17.3 Laporan

- Rekap Pemeriksaan
- Rekap Peti Kemas Layak
- Rekap Peti Kemas Tidak Layak
- Rekap Perlu Perbaikan
- Rekap Re-Inspection
- Rekap Pemilik
- Rekap Pabrik
- Preview Laporan 6 Bulanan

## 17.4 Filter

- tanggal
- pemilik
- pabrik
- lokasi
- surveyor
- kategori
- hasil
- workflow

Belum membuat:

- PDF final;
- submit regulator final.

---

# 18. TAHAP 14 — SETTING DAN ARSIP LEGACY

## 18.1 Setting

Pastikan tersedia:

- Company Profile
- Numbering Setting
- Audit Log
- User Management
- Role & Permission

Aturan:

- company profile tidak duplikat;
- numbering kelaikan tampil;
- secret tidak tampil;
- audit log read-only;
- permission dapat diperiksa;
- super_admin wildcard tetap ada.

## 18.2 Arsip Survey Lama

Route:

`/fitness/legacy-archive`

Tab:

- Job Order Lama
- Survey Lama
- Report Lama

Aturan:

- read-only;
- tanpa create/edit/delete;
- badge Legacy;
- memakai tabel legacy;
- tidak mengubah record lama.

---

# 19. TAHAP 15 — PERMISSION DAN ROLE MAPPING

## 19.1 Permission

Dashboard:

- `dashboard.view.all`

Application:

- `fitness_applications.view.all`
- `fitness_applications.create.all`
- `fitness_applications.update.all`
- `fitness_applications.cancel.all`

Container:

- `application_containers.view.all`
- `application_containers.create.all`
- `application_containers.update.all`
- `application_containers.delete.all`

Import:

- `fitness_container_imports.view.all`
- `fitness_container_imports.manage.all`

Assignment:

- `fitness_assignments.view.all`
- `fitness_assignments.manage.all`

Inspection:

- `fitness_inspections.view.all`

Repair:

- `repair_followups.view.all`
- `repair_followups.manage.all`

Review:

- `fitness_reviews.view.all`
- `fitness_reviews.manage.all`

Approval:

- `fitness_approvals.view.all`
- `fitness_approvals.issue.all`

Document:

- `fitness_documents.view.all`
- `fitness_documents.manage.all`

Reports:

- `fitness_reports.view.all`

Legacy:

- `legacy_archive.view.all`

## 19.2 Role mapping

### super_admin

- wildcard tetap.

### admin

- seluruh mutation Admin;
- seluruh monitoring.

### supervisor

- dashboard;
- monitoring;
- review;
- approval;
- document;
- reports.

### management

- dashboard read-only;
- monitoring read-only;
- document read-only;
- reports read-only.

### surveyor

- tidak mendapatkan mutation Admin.

### finance

- tidak masuk workspace Admin Kelaikan.

---

# 20. TAHAP 16 — CLEAN CANONICAL DATABASE

## 20.1 File

`database/kontainer_db.sql`

Jangan mengganti canonical dump dengan dump lokal mentah.

## 20.2 Harus ada

- struktur seluruh tabel terbaru;
- roles;
- permissions;
- role mappings;
- users demo jika dipertahankan;
- master seed;
- checklist seed;
- numbering settings;
- numbering sequences.

## 20.3 Harus kosong

- data `audit_logs` lokal;
- data `refresh_tokens` lokal;
- session;
- token aktif;
- transaksi testing.

Struktur tabel tetap ada, hanya data runtime dikosongkan.

## 20.4 Validasi fresh database

1. Buat database kosong.
2. Import canonical dump.
3. Jalankan patch terbaru.
4. Start API.
5. Smoke test.
6. Jalankan patch ulang.
7. Pastikan idempotent.
8. Cek foreign key.
9. Cek index unik.

---

# 21. TAHAP 17 — TRANSACTION SAFETY

Semua mutation harus:

- memakai DB transaction;
- rollback jika gagal;
- numbering memakai row locking;
- mencegah duplicate number;
- mencegah assignment ganda;
- mencegah duplicate container;
- mencatat audit log;
- menyimpan actor, role, action, entity, old/new value, request id, timestamp.

HTTP status:

- 400 validasi;
- 401 tidak login;
- 403 permission;
- 404 tidak ditemukan;
- 409 konflik;
- 422 business rule;
- 500 internal error.

Jangan membocorkan:

- SQL;
- credential;
- stack trace;
- JWT secret.

---

# 22. TAHAP 18 — UAT MENYELURUH

## 22.1 File

Buat:

`docs/ADMIN_FINAL_UAT.md`

## 22.2 Test case setiap submenu

- route terbuka;
- permission benar;
- list dari DB;
- search;
- filter;
- pagination;
- create;
- detail;
- edit;
- nonaktifkan;
- required;
- email;
- phone;
- date;
- numeric;
- duplicate;
- FK;
- empty state;
- loading state;
- error state;
- refresh;
- role access;
- audit log.

## 22.3 Integration test minimal

Master:

- owner
- manufacturer
- location
- surveyor
- container type
- approval category
- checklist template
- checklist item

Transaction:

- create application;
- duplicate application number;
- add container;
- duplicate container;
- check digit;
- update specs;
- import preview;
- import commit;
- assign surveyor;
- cancel assignment;
- dashboard;
- review;
- repair follow-up;
- document metadata.

---

# 23. TAHAP 19 — VALIDASI CODE DAN REPO

Jalankan:

```bash
go test ./...
npm run typecheck --workspace apps/web
npm run build --workspace apps/web
git diff --check
```

Sebelum build:

- catat hash `apps/web/next-env.d.ts`.

Setelah build:

- restore jika hanya berubah karena build.

Jangan commit:

- `.next`
- `node_modules`
- cache
- temp upload
- local DB backup
- secret
- `.env` production

---

# 24. TAHAP 20 — PENCARIAN ISTILAH TERLARANG

Cari seluruh repo:

- `PM25`
- `PM 25`
- `pm25`
- `Kelayakan`

Pastikan tidak ada pada:

- kode baru;
- route;
- table;
- permission;
- menu;
- config;
- variable;
- dokumentasi baru.

Cari juga:

- VGM;
- weighing;
- VGM certificate;
- finance kelaikan.

Pastikan tidak muncul pada workspace Admin Kelaikan.

---

# 25. DOKUMENTASI WAJIB

Update:

- `docs/ADMIN_FINAL_AUDIT.md`
- `docs/ADMIN_FINAL_UAT.md`
- `docs/MENU_KELAIKAN_PETI_KEMAS.md`
- `docs/ADMIN_FORMS_KELAIKAN_PETI_KEMAS.md`
- `docs/DATABASE_REDESIGN_CONTAINER_FITNESS.md`
- `docs/MIGRATION_PLAN_CONTAINER_FITNESS.md`
- `docs/DEPLOY_ADMIN_KELAIKAN.md`
- `docs/prd.md`
- `database/MYSQL_LARAGON_SETUP.md`

Setiap submenu harus mencantumkan:

- status;
- route;
- endpoint;
- permission;
- table;
- field;
- validation;
- role;
- batasan.

---

# 26. URUTAN EKSEKUSI WAJIB

Kerjakan dalam urutan:

1. Audit baseline.
2. Hardening form generik.
3. Finalisasi semua Master Data.
4. Checklist seed.
5. Dashboard.
6. Permohonan.
7. Data Peti Kemas.
8. Import.
9. Assignment Admin.
10. Monitoring inspection foundation.
11. Repair follow-up.
12. Review.
13. Dokumen metadata.
14. Laporan.
15. Setting dan arsip.
16. Permission.
17. Canonical dump.
18. Transaction safety.
19. UAT.
20. Build dan final validation.

Jangan lompat ke tahap berikutnya sebelum tahap aktif lulus test.

---

# 27. ACCEPTANCE CRITERIA FINAL MENU ADMIN

Menu Admin dianggap final jika:

1. Tidak ada route kosong.
2. Menu aktif memakai database nyata.
3. Menu belum aktif memiliki `PLACEHOLDER_LOCKED`.
4. Tidak ada tombol palsu.
5. Semua master lulus CRUD.
6. Dropdown tidak menampilkan UUID.
7. Permohonan dapat dibuat, diedit, dilihat, dibatalkan.
8. Container dan spesifikasi dapat dikelola.
9. Import preview dan commit berjalan.
10. Assignment tidak memakai tabel legacy.
11. Dashboard memakai query nyata.
12. Monitoring memakai tabel kelaikan.
13. Review dan repair punya audit trail.
14. Dokumen metadata dan preview tersedia.
15. PDF/QR final tetap belum aktif.
16. Laporan memakai query nyata.
17. Arsip legacy read-only.
18. Dump deploy bersih.
19. Role dan permission lulus.
20. Build dan test lulus.

---

# 28. FORMAT OUTPUT AKHIR CODEX

Berikan laporan:

1. Commit awal.
2. Audit sebelum perubahan.
3. `ACTIVE_DB_CONNECTED`.
4. `ACTIVE_READ_ONLY`.
5. `PLACEHOLDER_LOCKED`.
6. `LEGACY_ARCHIVE`.
7. `OUT_OF_SCOPE`.
8. Form yang diperbaiki.
9. Field frontend/backend/DB yang diselaraskan.
10. Endpoint baru.
11. Tabel baru.
12. Patch baru.
13. Migration baru.
14. Permission baru.
15. Role mapping.
16. Checklist seed.
17. Dashboard query.
18. Permohonan aktif.
19. Container aktif.
20. Import aktif.
21. Assignment aktif.
22. Monitoring aktif.
23. Review/repair/document metadata aktif.
24. Laporan aktif.
25. Data runtime yang dibersihkan.
26. Fresh DB test.
27. Existing DB migration test.
28. Idempotency test.
29. API integration test.
30. `go test`.
31. typecheck.
32. build.
33. `git diff --check`.
34. forbidden terms scan.
35. Hal yang belum dikerjakan.
36. Risiko tahap Surveyor.

---

# 29. BATASAN TERAKHIR

Pada seluruh tahapan ini:

- jangan membuat UI Surveyor;
- jangan membuat PDF final;
- jangan membuat QR final;
- jangan membuat finance;
- jangan membuat VGM;
- jangan memakai tabel legacy sebagai workflow aktif;
- jangan commit;
- jangan push;
- jangan mengubah patch lama;
- jangan menghapus data legacy.
