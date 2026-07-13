# Admin Final Audit - Tahap 0

Audit baseline untuk Admin Kelaikan pada Sistem Kelaikan Peti Kemas. Audit ini hanya membaca repo dan canonical dump, tanpa implementasi fitur, tanpa menjalankan patch, tanpa commit, dan tanpa push.

## 1. Baseline Repo

| Item | Hasil |
|---|---|
| Branch diperiksa | `main` |
| HEAD | `cc4ba7d8dd9ea89b3e071848eb869c6ede70409e` |
| Short commit | `cc4ba7d` |
| Commit message | `feat: prepare admin kelaikan deploy readiness` |
| Commit time | `2026-07-13 09:34:17 +0700` |
| Tracking lokal | `main...origin/main`, local tracking parity |
| Worktree sebelum audit | Untracked `docs/FINALISASI_FULL_MENU_ADMIN_KELAIKAN_BERTAHAP.md` |
| File baru audit | `docs/ADMIN_FINAL_AUDIT.md` |

Catatan: audit ini tidak melakukan `fetch`, commit, push, migrasi, import dump, atau mutation database.

## 2. Struktur Repo Yang Diperiksa

| Area | File utama |
|---|---|
| Frontend route Admin Kelaikan | `apps/web/app/fitness/[[...slug]]/page.tsx` |
| Navigasi Admin Kelaikan | `apps/web/constants/navigation-admin-fitness.ts` |
| Metadata placeholder dan stage | `apps/web/constants/fitness-admin.ts` |
| Konfigurasi generic master data | `apps/web/constants/master-data.ts` |
| Component CRUD generik | `apps/web/components/master/master-data-page.tsx` |
| Component placeholder Kelaikan | `apps/web/components/fitness/fitness-placeholder-page.tsx` |
| Component placeholder setting | `apps/web/components/navigation/navigation-placeholder-page.tsx` |
| API router | `services/api/internal/http/router.go` |
| Backend master data | `services/api/internal/masterdata/*` |
| Backend setting placeholder | `services/api/internal/modules/routes.go` |
| Backend user read-only | `services/api/internal/users/users.go` |
| Backend dashboard legacy | `services/api/internal/dashboard/dashboard.go` |
| Canonical dump | `database/kontainer_db.sql` |
| Patch terakhir | `database/patches/0018_container_fitness_deploy_readiness.sql` |
| Migration terakhir | `services/api/migrations/0010_container_fitness_foundation.up.sql` |

## 3. Matrix Status Submenu

Status yang dipakai:

- `ACTIVE_DB_CONNECTED`: route, component, API, permission, dan tabel tersedia untuk data nyata.
- `ACTIVE_READ_ONLY`: halaman mengambil data nyata tanpa mutation aktif.
- `PLACEHOLDER_LOCKED`: route ada tetapi masih placeholder atau endpoint belum aktif.
- `LEGACY_ARCHIVE`: hanya untuk akses arsip legacy read-only.
- `OUT_OF_SCOPE`: tidak masuk workspace Admin Kelaikan aktif.

| Grup Menu | Submenu | Route Frontend | Component | Endpoint API | Permission | Tabel DB | Status Sebelum | Gap | Status Target | Catatan |
|---|---|---|---|---|---|---|---|---|---|---|
| Dashboard | Dashboard Kelaikan | `/fitness/dashboard` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/dashboard`; ada legacy `/api/v1/dashboard/admin` | Navigasi masih placeholder permission kosong; target `dashboard.view.all` tersedia | Target memakai `fitness_applications`, `application_containers`, `fitness_checklist_templates`; endpoint legacy memakai tabel legacy | `PLACEHOLDER_LOCKED` | Belum ada UI dan query dashboard Kelaikan nyata | `ACTIVE_READ_ONLY` | Jangan pakai query dashboard legacy sebagai dashboard Kelaikan final |
| Master Data | Pemilik Peti Kemas | `/fitness/master-data/owners` | `MasterDataPage` resource `fitness-owners` | CRUD `/api/v1/fitness/master-data/owners` | `customers.view/create/update/delete.all` | `customers` | `ACTIVE_DB_CONNECTED` | Field `Catatan` ada di placeholder/docs tetapi tidak ada di form/resource/table | `ACTIVE_DB_CONNECTED` | Reuse tabel customer lama untuk pemilik |
| Master Data | Pabrik Pembuat Peti Kemas | `/fitness/master-data/manufacturers` | `MasterDataPage` resource `fitness-manufacturers` | CRUD `/api/v1/fitness/master-data/manufacturers` | `container_manufacturers.view/create/update/delete.all` | `container_manufacturers` | `ACTIVE_DB_CONNECTED` | `country` belum required di backend; field panjang belum textarea | `ACTIVE_DB_CONNECTED` | Stage 1 permission granular ada di patch 0016 |
| Master Data | Lokasi Pemeriksaan | `/fitness/master-data/locations` | `MasterDataPage` resource `fitness-locations` | CRUD `/api/v1/fitness/master-data/locations` | `locations.view/create/update/delete.all` | `locations` | `ACTIVE_DB_CONNECTED` | Latitude/longitude belum validasi range backend; field alamat belum textarea | `ACTIVE_DB_CONNECTED` | Reuse tabel lokasi lama |
| Master Data | Surveyor / Pemeriksa | `/fitness/master-data/surveyors` | `MasterDataPage` resource `fitness-surveyors` | CRUD `/api/v1/fitness/master-data/surveyors`; relation `/api/v1/users` | `surveyors.view/create/update/delete.all`; relation `users.view.all` | `surveyor_profiles`, `users` | `ACTIVE_DB_CONNECTED` | Permission resource memakai `surveyors.*`, seed lama juga punya `surveyor_profiles.manage.all`; upload tanda tangan belum aktif | `ACTIVE_DB_CONNECTED` | Form user dropdown mengambil user aktif role surveyor |
| Master Data | Jenis / Model Peti Kemas | `/fitness/master-data/container-types` | `MasterDataPage` resource `fitness-container-types` | CRUD `/api/v1/fitness/master-data/container-types` | `container_types.view/create/update/delete.all` | `container_types` | `ACTIVE_DB_CONNECTED` | DB field `type_name` diekspos sebagai API `type`; perlu dijaga agar label tetap konsisten | `ACTIVE_DB_CONNECTED` | Alias backend/frontend sudah ada |
| Master Data | Kategori Persetujuan Kelaikan | `/fitness/master-data/approval-categories` | `MasterDataPage` resource `fitness-approval-categories` | CRUD `/api/v1/fitness/master-data/approval-categories` | `fitness_approval_categories.view/create/update/delete.all` | `fitness_approval_categories` | `ACTIVE_DB_CONNECTED` | Type Design masih harus tetap inactive pada form permohonan aktif nanti | `ACTIVE_DB_CONNECTED` | Seed 0015 memuat kategori aktif dan inactive |
| Master Data | Skema Pemeliharaan Peti Kemas | `/fitness/master-data/maintenance-schemes` | `MasterDataPage` resource `fitness-maintenance-schemes` | CRUD `/api/v1/fitness/master-data/maintenance-schemes` | `maintenance_schemes.view/create/update/delete.all` | `maintenance_schemes` | `ACTIVE_DB_CONNECTED` | Interval > 0 belum tervalidasi spesifik | `ACTIVE_DB_CONNECTED` | Stage 2 permission granular ada di patch 0017 |
| Master Data | Area Pemeriksaan Peti Kemas | `/fitness/master-data/inspection-areas` | `MasterDataPage` resource `fitness-inspection-areas` | CRUD `/api/v1/fitness/master-data/inspection-areas` | `inspection_areas.view/create/update/delete.all` | `inspection_areas` | `ACTIVE_DB_CONNECTED` | Field deskripsi belum textarea; urutan belum validasi positif | `ACTIVE_DB_CONNECTED` | Seed area ada di 0015 dan dump |
| Master Data | Komponen Struktur Peti Kemas | `/fitness/master-data/structural-components` | `MasterDataPage` resource `fitness-structural-components` | CRUD `/api/v1/fitness/master-data/structural-components` | `structural_components.view/create/update/delete.all` | `structural_components`, relasi `inspection_areas` | `ACTIVE_DB_CONNECTED` | Kolom list masih menampilkan `inspection_area_id` bila relation option tidak termuat; filter area belum ada di UI | `ACTIVE_DB_CONNECTED` | Relation dropdown aktif dari DB |
| Master Data | Kriteria Kerusakan / Ketidaksesuaian | `/fitness/master-data/damage-criteria` | `MasterDataPage` resource `fitness-damage-criteria` | CRUD `/api/v1/fitness/master-data/damage-criteria` | `structural_damage_criteria.view/create/update/delete.all` | `structural_damage_criteria`, relasi `structural_components` | `ACTIVE_DB_CONNECTED` | Belum ada warning visual untuk kriteria yang memengaruhi kelaikan | `ACTIVE_DB_CONNECTED` | Severity enum backend hanya validasi umum dari select frontend |
| Master Data | Tingkat Temuan / Severity | `/fitness/master-data/finding-severities` | `MasterDataPage` resource `fitness-finding-severities` | CRUD `/api/v1/fitness/master-data/finding-severities` | `finding_severities.view/create/update/delete.all` | `finding_severities` | `ACTIVE_DB_CONNECTED` | Aturan critical wajib review dan memengaruhi kelaikan belum enforced khusus | `ACTIVE_DB_CONNECTED` | Seed minor, major, critical ada |
| Master Data | Parameter Pengujian Kelaikan | `/fitness/master-data/test-parameters` | `MasterDataPage` resource `fitness-test-parameters` | CRUD `/api/v1/fitness/master-data/test-parameters` | `inspection_test_parameters.view/create/update/delete.all` | `inspection_test_parameters` | `ACTIVE_DB_CONNECTED` | Minimal satu lifecycle aktif belum enforced; unit saat numeric belum enforced | `ACTIVE_DB_CONNECTED` | Field `standard_reference` ada, perlu dijaga tanpa klaim tidak terverifikasi |
| Master Data | Template Checklist Kelaikan | `/fitness/master-data/checklist-templates` | `MasterDataPage` resource `fitness-checklist-templates` | CRUD `/api/v1/fitness/master-data/checklist-templates` | `fitness_checklist_templates.view/create/update/delete.all` | `fitness_checklist_templates` | `ACTIVE_DB_CONNECTED` | Tidak ada validasi template active wajib punya item; jumlah item aktif belum tampil di list | `ACTIVE_DB_CONNECTED` | Header aktif, belum mengaktifkan flow Surveyor |
| Master Data | Item Template Checklist | `/fitness/master-data/checklist-templates/[id]/items` | `MasterDataPage` resource `fitness-checklist-template-items` | CRUD `/api/v1/fitness/master-data/checklist-templates/:id/items` | `fitness_checklist_templates.view/create/update/delete.all` | `fitness_checklist_template_items` dan relasi master lain | `ACTIVE_DB_CONNECTED` | Belum ada validasi `fail_marks_unfit` hanya untuk critical; list bisa fallback ke UUID bila relation option belum termuat | `ACTIVE_DB_CONNECTED` | Nested route nyata ada walau tidak muncul sebagai sidebar utama |
| Master Data | Kategori Foto Evidence | `/fitness/master-data/photo-categories` | `MasterDataPage` resource `fitness-photo-categories` | CRUD `/api/v1/fitness/master-data/photo-categories` | `evidence_photo_categories.view/create/update/delete.all` | `evidence_photo_categories` | `ACTIVE_DB_CONNECTED` | `applies_to` masih input text, belum select terbatas | `ACTIVE_DB_CONNECTED` | Upload evidence belum aktif |
| Master Data | Rekomendasi Hasil Pemeriksaan | `/fitness/master-data/inspection-recommendations` | `MasterDataPage` resource `fitness-inspection-recommendations` | CRUD `/api/v1/fitness/master-data/inspection-recommendations` | `inspection_recommendations.view/create/update/delete.all` | `inspection_recommendations` | `ACTIVE_DB_CONNECTED` | `workflow_status_mapping` masih input text; restriction option belum memuat `released` | `ACTIVE_DB_CONNECTED` | Mapping dipakai tahap review nanti |
| Master Data | Pejabat Penandatangan | `/fitness/master-data/authorized-signers` | `MasterDataPage` resource `fitness-authorized-signers` | CRUD `/api/v1/fitness/master-data/authorized-signers` | `authorized_signers.view/create/update/delete.all` | `authorized_signers`, relasi `file_objects` | `ACTIVE_DB_CONNECTED` | `valid_from` dan `valid_until` masih text input; valid until >= valid from belum enforced; upload tanda tangan belum aktif | `ACTIVE_DB_CONNECTED` | Tabel punya FK ke file object |
| Master Data | Profil Badan Usaha | `/fitness/master-data/company-profile` | `MasterDataPage` resource `fitness-company-profile` | CRUD `/api/v1/fitness/master-data/company-profile` | `company_profiles.view/create/update/delete.all` | `company_profiles`, relasi `file_objects` | `ACTIVE_DB_CONNECTED` | Singleton belum enforced di UI/backend; setting `/settings/company-profile` masih placeholder terpisah | `ACTIVE_DB_CONNECTED` | Resource memakai `is_active`, bukan `status` |
| Permohonan | Daftar Permohonan | `/fitness/applications` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/applications` | `fitness_applications.view/manage.all` tersedia, granular target belum lengkap | `fitness_applications`, `fitness_application_events` | `PLACEHOLDER_LOCKED` | UI dan API belum aktif | `ACTIVE_DB_CONNECTED` | Tabel foundation sudah ada |
| Permohonan | Buat Permohonan | `/fitness/applications/create` | `FitnessPlaceholderPage` | Belum ada `POST /api/v1/fitness/applications` | `fitness_applications.manage.all` tersedia; target `create/update/cancel` belum ada | `fitness_applications`, `numbering_settings`, `numbering_sequences` | `PLACEHOLDER_LOCKED` | Numbering transaction dan form belum aktif | `ACTIVE_DB_CONNECTED` | Sequence document type sudah disiapkan 0018 |
| Permohonan | Data Peti Kemas | `/fitness/containers` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/containers` | `application_containers.view/manage.all` tersedia, granular target belum lengkap | `application_containers`, `container_technical_specs` | `PLACEHOLDER_LOCKED` | UI identitas dan teknis belum aktif | `ACTIVE_DB_CONNECTED` | Tabel foundation sudah ada |
| Permohonan | Import Data Peti Kemas | `/fitness/containers/import` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/container-imports/*` | `fitness_container_imports.view/manage.all` tersedia | `fitness_container_import_batches`, `fitness_container_import_rows` | `PLACEHOLDER_LOCKED` | Preview, mapping, commit belum aktif | `ACTIVE_DB_CONNECTED` | Tabel foundation sudah ada |
| Permohonan | Assign Surveyor | `/fitness/assignments` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/assignments` | `fitness_assignments.view/manage.all` tersedia | Belum ada `fitness_assignments`, `fitness_assignment_containers` | `PLACEHOLDER_LOCKED` | Tabel dan endpoint belum ada | `ACTIVE_DB_CONNECTED` | Jangan pakai tabel legacy assignment sebagai workflow aktif |
| Pemeriksaan & Pengujian | Monitoring Pemeriksaan | `/fitness/inspections` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/inspections`; ada legacy `/api/v1/surveys/monitoring` | `fitness_inspections.view.all` tersedia | Belum ada tabel pemeriksaan kelaikan baru | `PLACEHOLDER_LOCKED` | Foundation inspection belum ada | `ACTIVE_READ_ONLY` | Menu lain dalam grup memakai route sama dan status sama |
| Pemeriksaan & Pengujian | Pemeriksaan Berjalan | `/fitness/inspections` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/inspections` | `fitness_inspections.view.all` tersedia | Belum ada tabel pemeriksaan kelaikan baru | `PLACEHOLDER_LOCKED` | Filter status belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Pemeriksaan & Pengujian | Perlu Perbaikan | `/fitness/inspections` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/inspections` | `fitness_inspections.view.all` tersedia | Belum ada tabel pemeriksaan kelaikan baru | `PLACEHOLDER_LOCKED` | Filter status belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Pemeriksaan & Pengujian | Siap Re-Inspection | `/fitness/inspections` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/inspections` | `fitness_inspections.view.all` tersedia | Belum ada tabel pemeriksaan kelaikan baru | `PLACEHOLDER_LOCKED` | Filter status belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Pemeriksaan & Pengujian | Re-Inspection | `/fitness/inspections` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/inspections` | `fitness_inspections.view.all` tersedia | Belum ada tabel pemeriksaan kelaikan baru | `PLACEHOLDER_LOCKED` | Filter status belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Pemeriksaan & Pengujian | Layak | `/fitness/inspections` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/inspections` | `fitness_inspections.view.all` tersedia | Belum ada tabel pemeriksaan kelaikan baru | `PLACEHOLDER_LOCKED` | Filter final result belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Pemeriksaan & Pengujian | Tidak Layak | `/fitness/inspections` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/inspections` | `fitness_inspections.view.all` tersedia | Belum ada tabel pemeriksaan kelaikan baru | `PLACEHOLDER_LOCKED` | Filter final result belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Review & Keputusan | Pending Review | `/fitness/reviews` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reviews`; ada legacy `/api/v1/reviews` | `fitness_reviews.view/manage.all` tersedia | Belum ada `fitness_reviews`, `fitness_approvals` | `PLACEHOLDER_LOCKED` | Tabel dan endpoint Kelaikan belum ada | `ACTIVE_DB_CONNECTED` | Jangan memakai endpoint legacy review sebagai final Kelaikan |
| Review & Keputusan | Riwayat Review | `/fitness/reviews` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reviews` | `fitness_reviews.view.all` tersedia | Belum ada `fitness_reviews` | `PLACEHOLDER_LOCKED` | Riwayat belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Review & Keputusan | Keputusan Kelaikan | `/fitness/reviews` | `FitnessPlaceholderPage` | Belum ada decision endpoint Kelaikan | `fitness_reviews.manage.all`, `fitness_approvals.issue.all` tersedia | Belum ada `fitness_reviews`, `fitness_approvals` | `PLACEHOLDER_LOCKED` | Decision workflow belum ada | `ACTIVE_DB_CONNECTED` | Butuh audit trail dan status consistency |
| Review & Keputusan | Pembebasan Setelah Perbaikan | `/fitness/reviews` | `FitnessPlaceholderPage` | Belum ada release endpoint Kelaikan | `repair_followups.view/manage.all` dan `fitness_approvals.issue.all` tersedia | Belum ada `repair_followups`, `fitness_approvals` | `PLACEHOLDER_LOCKED` | Foundation repair/release belum ada | `ACTIVE_DB_CONNECTED` | Bukan operasional bengkel |
| Dokumen | Surat Persetujuan Kelaikan | `/fitness/documents` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/documents` | `fitness_documents.view/manage.all` tersedia | Belum ada `approval_documents`, `approval_document_versions` | `PLACEHOLDER_LOCKED` | Metadata dan preview belum aktif | `ACTIVE_DB_CONNECTED` | PDF final dan QR final tetap belum aktif |
| Dokumen | Surat Persetujuan Peti Kemas Baru Individual | `/fitness/documents` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/documents` | `fitness_documents.view/manage.all` tersedia | Belum ada document tables | `PLACEHOLDER_LOCKED` | Belum ada document type spesifik | `ACTIVE_DB_CONNECTED` | Submenu alias ke route yang sama |
| Dokumen | Surat Persetujuan Peti Kemas Lama | `/fitness/documents` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/documents` | `fitness_documents.view/manage.all` tersedia | Belum ada document tables | `PLACEHOLDER_LOCKED` | Belum ada document type spesifik | `ACTIVE_DB_CONNECTED` | Submenu alias ke route yang sama |
| Dokumen | Surat Pembebasan Setelah Perbaikan | `/fitness/documents` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/documents` | `fitness_documents.view/manage.all` tersedia | Belum ada document tables | `PLACEHOLDER_LOCKED` | Belum ada release letter metadata | `ACTIVE_DB_CONNECTED` | Submenu alias ke route yang sama |
| Dokumen | Data CSC Safety Approval Plate | `/fitness/documents` | `FitnessPlaceholderPage` | Belum ada CSC plate endpoint Kelaikan | Permission target belum spesifik; `fitness_documents.*` tersedia | Belum ada `csc_plate_records` | `PLACEHOLDER_LOCKED` | Tabel CSC plate belum ada | `ACTIVE_DB_CONNECTED` | Dibutuhkan tahap dokumen/review |
| Dokumen | Validasi Dokumen | `/fitness/documents` | `FitnessPlaceholderPage` | Belum ada validation endpoint Kelaikan | `fitness_documents.view.all` tersedia | Belum ada document tables | `PLACEHOLDER_LOCKED` | Validasi final belum aktif | `PLACEHOLDER_LOCKED` | Public verification final belum scope Admin baseline |
| Laporan | Rekap Pemeriksaan | `/fitness/reports` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reports/*`; ada legacy `/api/v1/reports` | Target `fitness_reports.view.all` belum ada di dump; legacy `reports.view.all` ada | Belum ada report query Kelaikan khusus | `PLACEHOLDER_LOCKED` | Permission target dan endpoint belum ada | `ACTIVE_READ_ONLY` | Jangan pakai laporan legacy sebagai final Kelaikan |
| Laporan | Rekap Peti Kemas Layak | `/fitness/reports` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reports/*` | Target `fitness_reports.view.all` belum ada | `application_containers` ada | `PLACEHOLDER_LOCKED` | Query belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Laporan | Rekap Peti Kemas Tidak Layak | `/fitness/reports` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reports/*` | Target `fitness_reports.view.all` belum ada | `application_containers` ada | `PLACEHOLDER_LOCKED` | Query belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Laporan | Rekap Perlu Perbaikan | `/fitness/reports` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reports/*` | Target `fitness_reports.view.all` belum ada | Belum ada `repair_followups` | `PLACEHOLDER_LOCKED` | Foundation repair belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Laporan | Rekap Re-Inspection | `/fitness/reports` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reports/*` | Target `fitness_reports.view.all` belum ada | Belum ada inspection/reinspection tables | `PLACEHOLDER_LOCKED` | Foundation inspection belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Laporan | Rekap Pemilik Peti Kemas | `/fitness/reports` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reports/owners` | Target `fitness_reports.view.all` belum ada | `customers`, `fitness_applications` | `PLACEHOLDER_LOCKED` | Query belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Laporan | Rekap Pabrik Pembuat | `/fitness/reports` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reports/manufacturers` | Target `fitness_reports.view.all` belum ada | `container_manufacturers`, `fitness_applications` | `PLACEHOLDER_LOCKED` | Query belum ada | `ACTIVE_READ_ONLY` | Submenu alias ke route yang sama |
| Laporan | Laporan Kegiatan 6 Bulanan | `/fitness/reports` | `FitnessPlaceholderPage` | Belum ada `/api/v1/fitness/reports/six-monthly-preview` | Target `fitness_reports.view.all` belum ada | Aggregasi Kelaikan belum tersedia | `PLACEHOLDER_LOCKED` | Preview belum ada | `ACTIVE_READ_ONLY` | Tidak membuat output final pada tahap audit |
| Setting | Company Profile | `/settings/company-profile` | `NavigationPlaceholderPage` | Placeholder `/api/v1/settings/company-profile` return 501; CRUD nyata ada `/api/v1/fitness/master-data/company-profile` | `company_profiles.view/manage.*` tersedia | `company_profiles` | `PLACEHOLDER_LOCKED` | Route setting belum memakai resource fisik yang sama | `ACTIVE_DB_CONNECTED` | Harus disatukan dengan Profil Badan Usaha |
| Setting | Numbering Setting | `/settings/numbering` | `NavigationPlaceholderPage` | Placeholder `/api/v1/settings/numbering` return 501 | `numbering_settings.view/manage.all` tersedia | `numbering_settings`, `numbering_sequences` | `PLACEHOLDER_LOCKED` | UI/API setting belum aktif | `ACTIVE_DB_CONNECTED` | Data numbering Kelaikan ada di 0015/0018 |
| Setting | Audit Log | `/settings/audit-log` | `NavigationPlaceholderPage` | Placeholder `/api/v1/audit-logs` return 501 | `audit.view.all` tersedia | `audit_logs` | `PLACEHOLDER_LOCKED` | Read-only audit log belum aktif | `ACTIVE_READ_ONLY` | Canonical dump menjaga struktur, tanpa data runtime |
| Setting | User Management | `/settings/users` | Custom `UsersContent` read-only | `GET /api/v1/users` | `users.view.all` | `users`, `user_roles`, `roles` | `ACTIVE_READ_ONLY` | Belum ada mutation user di UI; memang read-only untuk non super admin | `ACTIVE_READ_ONLY` | Mengambil data nyata dari DB |
| Setting | Role & Permission | `/settings/roles` | `NavigationPlaceholderPage` | Placeholder `/api/v1/roles` dan `/api/v1/permissions` return 501 | `roles.view.all`, `roles.manage.all` | `roles`, `permissions`, `role_permissions` | `PLACEHOLDER_LOCKED` | UI/API role permission belum aktif | `ACTIVE_READ_ONLY` | Navigasi dibatasi `exactRoles: super_admin` |
| Arsip | Arsip Survey Lama | `/fitness/legacy-archive` | `FitnessPlaceholderPage` | Belum ada endpoint arsip Kelaikan; legacy endpoint tersebar | Permission target `legacy_archive.view.all` belum ada | Tabel legacy `job_orders`, `surveys`, `reports`, dll ada | `LEGACY_ARCHIVE` | Arsip read-only belum aktif | `LEGACY_ARCHIVE` | Jangan dipakai sebagai workflow aktif |
| Di luar workspace | Finance | `/finance/*` | Finance pages lama | `/api/v1/finance/*` | `finance.*` | `invoices`, `payments`, `price_lists` | `OUT_OF_SCOPE` | Tidak masuk Admin Kelaikan | `OUT_OF_SCOPE` | Tetap di workspace finance lama |
| Di luar workspace | Master legacy CEDEX dan Responsibility | `/master/cedex/*`, `/master/responsibility-codes` | `MasterDataPage` legacy | `/api/v1/master/*` | `cedex_*`, `responsibility_codes.*` | Tabel CEDEX dan `responsibility_codes` | `OUT_OF_SCOPE` | Tidak boleh jadi workflow Kelaikan aktif | `OUT_OF_SCOPE` | Boleh dipertahankan untuk compatibility |

## 4. Route Frontend

Route Admin Kelaikan aktif atau placeholder:

| Route | Status | Catatan |
|---|---|---|
| `/fitness/dashboard` | `PLACEHOLDER_LOCKED` | Catch-all placeholder |
| `/fitness/master-data` | `PLACEHOLDER_LOCKED` | Index daftar master, bukan CRUD |
| `/fitness/master-data/owners` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/manufacturers` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/locations` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/surveyors` | `ACTIVE_DB_CONNECTED` | CRUD generik plus user dropdown |
| `/fitness/master-data/container-types` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/approval-categories` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/maintenance-schemes` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/inspection-areas` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/structural-components` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/damage-criteria` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/finding-severities` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/test-parameters` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/checklist-templates` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/checklist-templates/[id]/items` | `ACTIVE_DB_CONNECTED` | Nested CRUD generik |
| `/fitness/master-data/photo-categories` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/inspection-recommendations` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/authorized-signers` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/master-data/company-profile` | `ACTIVE_DB_CONNECTED` | CRUD generik |
| `/fitness/applications` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/applications/create` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/containers` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/containers/import` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/assignments` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/inspections` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/reviews` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/documents` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/reports` | `PLACEHOLDER_LOCKED` | Placeholder |
| `/fitness/legacy-archive` | `LEGACY_ARCHIVE` | Placeholder arsip |
| `/settings/company-profile` | `PLACEHOLDER_LOCKED` | Placeholder setting |
| `/settings/numbering` | `PLACEHOLDER_LOCKED` | Placeholder setting |
| `/settings/audit-log` | `PLACEHOLDER_LOCKED` | Placeholder setting |
| `/settings/users` | `ACTIVE_READ_ONLY` | Read-only data user |
| `/settings/roles` | `PLACEHOLDER_LOCKED` | Placeholder role |

## 5. Endpoint API

Endpoint aktif untuk Admin Kelaikan saat ini:

| Submenu | Endpoint |
|---|---|
| Semua master data aktif | `GET/POST /api/v1/fitness/master-data/{resource}` |
| Semua master data aktif | `GET/PUT/DELETE /api/v1/fitness/master-data/{resource}/:id` |
| Item Template Checklist | `GET/POST /api/v1/fitness/master-data/checklist-templates/:id/items` |
| Item Template Checklist | `GET/PUT/DELETE /api/v1/fitness/master-data/checklist-templates/:id/items/:item_id` |
| Surveyor user dropdown | `GET /api/v1/users?page=1&per_page=100&status=active&role=surveyor&without_surveyor_profile=true` |
| User Management | `GET /api/v1/users` |

Endpoint placeholder atau belum sesuai namespace Kelaikan:

| Area | Kondisi |
|---|---|
| Dashboard Kelaikan | Belum ada `/api/v1/fitness/dashboard`; endpoint `/api/v1/dashboard/admin` memakai tabel legacy |
| Permohonan Kelaikan | Belum ada `/api/v1/fitness/applications` |
| Data Peti Kemas | Belum ada `/api/v1/fitness/containers` |
| Import Data Peti Kemas | Belum ada `/api/v1/fitness/container-imports/*` |
| Assignment Kelaikan | Belum ada `/api/v1/fitness/assignments` |
| Inspection Kelaikan | Belum ada `/api/v1/fitness/inspections` |
| Review Kelaikan | Belum ada `/api/v1/fitness/reviews`; legacy `/api/v1/reviews` ada |
| Dokumen Kelaikan | Belum ada `/api/v1/fitness/documents` |
| Laporan Kelaikan | Belum ada `/api/v1/fitness/reports/*`; legacy `/api/v1/reports` ada |
| Setting Company Profile | `/api/v1/settings/company-profile` masih 501 placeholder |
| Setting Numbering | `/api/v1/settings/numbering` masih 501 placeholder |
| Audit Log | `/api/v1/audit-logs` masih 501 placeholder |
| Roles/Permissions | `/api/v1/roles`, `/api/v1/permissions` masih 501 placeholder |

## 6. Permission dan Role Mapping

Permission aktif yang cocok dengan master CRUD:

| Modul | Permission |
|---|---|
| Pemilik | `customers.view.all`, `customers.create.all`, `customers.update.all`, `customers.delete.all` |
| Pabrik Pembuat | `container_manufacturers.view.all`, `container_manufacturers.create.all`, `container_manufacturers.update.all`, `container_manufacturers.delete.all` |
| Lokasi | `locations.view.all`, `locations.create.all`, `locations.update.all`, `locations.delete.all` |
| Surveyor | `surveyors.view.all`, `surveyors.create.all`, `surveyors.update.all`, `surveyors.delete.all` |
| Jenis Peti Kemas | `container_types.view.all`, `container_types.create.all`, `container_types.update.all`, `container_types.delete.all` |
| Kategori Persetujuan | `fitness_approval_categories.view.all`, `fitness_approval_categories.create.all`, `fitness_approval_categories.update.all`, `fitness_approval_categories.delete.all` |
| Stage 2 master | Granular `view/create/update/delete.all` tersedia untuk `maintenance_schemes`, `inspection_areas`, `structural_components`, `structural_damage_criteria`, `finding_severities`, `inspection_test_parameters`, `fitness_checklist_templates`, `evidence_photo_categories`, `inspection_recommendations`, `authorized_signers`, `company_profiles` |

Role mapping dari patch dan dump:

| Role | Kondisi |
|---|---|
| `super_admin` | Memiliki wildcard `*.*.all`; patch 0015-0017 juga menambahkan mapping eksplisit |
| `admin` | Mendapat mutation master data dan beberapa permission Kelaikan foundation |
| `supervisor` | Mendapat permission review/document/inspection foundation, tetapi UI Admin Kelaikan masih banyak placeholder |
| `management` | Mendapat read-only beberapa permission Kelaikan foundation |
| `surveyor` | Mendapat assigned inspection/finding foundation, bukan mutation Admin |
| `finance` | Tetap di luar workspace Admin Kelaikan |

Gap permission utama:

- Navigasi placeholder memakai permission kosong sehingga visible berdasarkan role, bukan permission target.
- Target `fitness_reports.view.all` dan `legacy_archive.view.all` belum ditemukan di dump.
- Beberapa target final di dokumen tahap lanjut meminta granular `fitness_applications.create/update/cancel.all`, `application_containers.create/update/delete.all`, dan `fitness_approvals.issue.all`; dump saat ini sebagian masih memakai `manage.all`.
- `settings/company-profile`, `settings/numbering`, `audit-log`, dan `roles` belum tersambung ke endpoint nyata walau permission tersedia.

## 7. Tabel Database

Tabel Kelaikan/foundation yang ada di `database/kontainer_db.sql`:

- `fitness_applications`
- `fitness_application_events`
- `application_containers`
- `container_technical_specs`
- `fitness_container_import_batches`
- `fitness_container_import_rows`
- `container_manufacturers`
- `fitness_approval_categories`
- `maintenance_schemes`
- `inspection_areas`
- `structural_components`
- `structural_damage_criteria`
- `finding_severities`
- `inspection_test_parameters`
- `fitness_checklist_templates`
- `fitness_checklist_template_items`
- `evidence_photo_categories`
- `inspection_recommendations`
- `authorized_signers`
- `company_profiles`
- `numbering_settings`
- `numbering_sequences`

Tabel yang belum ada untuk target tahap berikutnya:

- `fitness_assignments`
- `fitness_assignment_containers`
- `fitness_inspections`
- `fitness_inspection_general_infos`
- `fitness_checklist_responses`
- `fitness_test_results`
- `structural_findings`
- `finding_photos`
- `repair_followups`
- `repair_followup_findings`
- `fitness_reviews`
- `fitness_approvals`
- `approval_documents`
- `approval_document_versions`
- `csc_plate_records`

Tabel legacy masih ada dan tidak boleh menjadi workflow Kelaikan aktif:

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

## 8. Form Yang Sudah Tersambung DB

Form CRUD generik yang sudah tersambung endpoint dan tabel:

1. Pemilik Peti Kemas
2. Pabrik Pembuat Peti Kemas
3. Lokasi Pemeriksaan
4. Surveyor / Pemeriksa
5. Jenis / Model Peti Kemas
6. Kategori Persetujuan Kelaikan
7. Skema Pemeliharaan Peti Kemas
8. Area Pemeriksaan Peti Kemas
9. Komponen Struktur Peti Kemas
10. Kriteria Kerusakan / Ketidaksesuaian
11. Tingkat Temuan / Severity
12. Parameter Pengujian Kelaikan
13. Template Checklist Kelaikan
14. Item Template Checklist
15. Kategori Foto Evidence
16. Rekomendasi Hasil Pemeriksaan
17. Pejabat Penandatangan
18. Profil Badan Usaha

Fitur pendukung CRUD generik yang ditemukan:

- list data DB;
- search;
- status filter;
- pagination;
- create;
- detail panel;
- edit;
- nonaktifkan via `DELETE`;
- loading state;
- empty state;
- error state;
- disabled submit saat request;
- audit log insert pada mutation backend.

## 9. Form Yang Belum Tersambung DB

1. Dashboard Kelaikan.
2. Daftar Permohonan.
3. Buat Permohonan.
4. Detail/edit Permohonan.
5. Data Peti Kemas.
6. Spesifikasi Teknis Peti Kemas.
7. Import Data Peti Kemas.
8. Assign Surveyor.
9. Monitoring Pemeriksaan Admin.
10. Tindak Lanjut Perbaikan.
11. Review dan Keputusan Kelaikan.
12. Dokumen metadata dan preview.
13. Laporan Admin Kelaikan.
14. Company Profile pada route `/settings/company-profile`.
15. Numbering Setting.
16. Audit Log.
17. Role & Permission.
18. Arsip Survey Lama.

## 10. Mismatch Frontend, Backend, dan Database

| Area | Mismatch |
|---|---|
| Pemilik Peti Kemas | Placeholder/docs menyebut `Catatan`, tetapi form/resource/table aktif tidak punya field catatan khusus |
| Generic field type | Frontend belum punya `textarea`, `tel`, `url`, `date`, `datetime-local`, `decimal`, `searchable-select`; banyak field panjang/tanggal masih text |
| Relation display | Relation dropdown ada, tetapi list/detail masih bisa fallback ke UUID jika option relation tidak termuat dalam 100 record |
| Surveyor permission | Backend memakai module `surveyors`, sementara seed awal juga punya `surveyor_profiles.manage.all`; perlu konsistensi naming |
| Container type | DB memakai `type_name`, frontend memakai `type`, backend alias sudah menjembatani; harus dijaga pada tahap berikutnya |
| Company profile | `/fitness/master-data/company-profile` aktif, tetapi `/settings/company-profile` masih placeholder; singleton belum enforced |
| Checklist template | UI punya tombol item, tetapi template active tanpa item belum dicegah |
| Photo category | `applies_to` masih text, bukan select enum |
| Inspection recommendation | `workflow_status_mapping` masih text; `restriction_status_mapping` belum memuat `released` |
| Authorized signer | Date masih text; valid until sebelum valid from belum dicegah |
| Dashboard | UI `/fitness/dashboard` placeholder; API nyata yang ada memakai tabel legacy |
| Reports | Target permission `fitness_reports.view.all` belum ada; API `/api/v1/fitness/reports/*` belum ada |
| Legacy archive | Target permission `legacy_archive.view.all` belum ada; route masih placeholder |
| Non-master workflow | Tabel foundation sebagian ada, tetapi endpoint dan form belum ada |

## 11. Placeholder Yang Ditemukan

Frontend placeholder:

- `/fitness/dashboard`
- `/fitness/master-data`
- `/fitness/applications`
- `/fitness/applications/create`
- `/fitness/containers`
- `/fitness/containers/import`
- `/fitness/assignments`
- `/fitness/inspections`
- `/fitness/reviews`
- `/fitness/documents`
- `/fitness/reports`
- `/fitness/legacy-archive`
- `/settings/company-profile`
- `/settings/numbering`
- `/settings/audit-log`
- `/settings/roles`

Backend placeholder 501:

- `/api/v1/settings/company-profile`
- `/api/v1/settings/numbering`
- `/api/v1/audit-logs`
- `/api/v1/roles`
- `/api/v1/permissions`
- beberapa module placeholder lain di `services/api/internal/modules/routes.go`

## 12. Patch SQL dan Migration Terakhir

| Jenis | Terakhir | Catatan |
|---|---|---|
| Patch SQL | `0018_container_fitness_deploy_readiness.sql` | Menyiapkan `numbering_sequences` periode `2026` untuk document type Kelaikan; tidak mengaktifkan workflow |
| Patch foundation | `0015_container_fitness_foundation.sql` | Additive foundation tabel Kelaikan, seed master, permission, role mapping |
| Patch permission Stage 1 | `0016_container_fitness_master_stage1_permissions.sql` | Permission CRUD granular untuk pabrik pembuat dan kategori persetujuan |
| Patch permission Stage 2 | `0017_container_fitness_master_stage2_permissions.sql` | Permission CRUD granular untuk 11 master Stage 2 |
| Migration service API | `0010_container_fitness_foundation.up.sql` | Migration terakhir pada folder `services/api/migrations` |
| Canonical dump | `database/kontainer_db.sql` | Sudah memuat tabel foundation, master seed, permission, role mapping, demo user, numbering settings/sequences |

## 13. Risiko Database

1. Canonical dump punya tabel foundation transaksi Kelaikan, tetapi sebagian endpoint belum ada; UI placeholder harus tetap terkunci agar tidak memberi kesan workflow aktif.
2. Tabel assignment, inspection, repair, review, approval, document, dan CSC plate target belum ada; tahap berikutnya perlu patch additive baru, bukan reuse tabel legacy.
3. `audit_logs` dan `refresh_tokens` strukturnya ada; dokumen deploy menyatakan data runtime tidak ikut disimpan. Audit ini tidak menjalankan import fresh DB untuk memverifikasi isi runtime secara live.
4. Permission report dan legacy archive target belum lengkap (`fitness_reports.view.all`, `legacy_archive.view.all`).
5. Generic CRUD menulis audit log, tetapi belum semua mutation dibungkus transaction eksplisit per operasi bisnis kompleks.
6. Relation dropdown saat ini mengambil maksimal 100 record aktif; untuk data besar perlu searchable-select atau server-side relation search.
7. Beberapa validasi bisnis masih belum enforced backend, terutama date range, numeric range, singleton company profile, template active wajib punya item, dan status mapping.

## 14. Rekomendasi Tahap Berikutnya

1. Mulai Tahap 1 dari hardening generic master data, terutama tipe field, relation search, label relasi, empty/loading/error consistency, validasi backend, dan nonaktifkan tanpa hard delete.
2. Jangan lanjut workflow permohonan sebelum generic CRUD lebih kuat, karena hampir semua master aktif bergantung pada component dan service yang sama.
3. Pada Tahap 2, selaraskan field form terhadap DB satu per satu, termasuk input tanggal, URL, telepon, textarea, enum select, dan relation label.
4. Siapkan patch additive baru hanya setelah audit dan hardening disetujui; jangan mengubah patch 0015 sampai 0018.
5. Untuk dashboard dan laporan, bangun endpoint namespace `/api/v1/fitness/*` yang query tabel Kelaikan, bukan endpoint/tabel legacy.
6. Untuk arsip legacy, buat read-only route dan permission terpisah agar legacy tidak tercampur dengan workflow Kelaikan aktif.
7. Saat masuk tahap database lanjutan, tambahkan permission target yang belum ada sebelum menghubungkan navigasi ke permission nyata.

## 15. Addendum Verifikasi Audit

### 15.1 Repository Freshness

Verifikasi dilakukan setelah audit awal dengan perintah:

- `git fetch --prune origin`
- `git rev-parse HEAD`
- `git rev-parse origin/main`

Hasil:

| Item | Commit |
|---|---|
| `HEAD` | `cc4ba7d8dd9ea89b3e071848eb869c6ede70409e` |
| `origin/main` | `cc4ba7d8dd9ea89b3e071848eb869c6ede70409e` |

Kesimpulan: `HEAD` sudah sesuai `origin/main`. Tidak dilakukan checkout, reset, merge, rebase, commit, atau push.

### 15.2 Runtime Verification

Status `ACTIVE_DB_CONNECTED` pada Tahap 0 berarti koneksi dinilai berdasarkan source code: route frontend, component, API handler, permission, dan tabel database tersedia serta saling mengarah.

Status tersebut belum membuktikan operasi CRUD runtime berhasil di API nyata. Untuk audit awal ini, status runtime semua submenu adalah:

| Status Runtime | Arti | Hasil Audit Awal |
|---|---|---|
| `NOT_TESTED` | Belum diuji dengan mutation API nyata | Digunakan untuk Tahap 0 |
| `PASSED` | Sudah diuji dan berhasil | Belum digunakan |
| `FAILED` | Sudah diuji dan gagal | Belum digunakan |

Kesimpulan: semua `ACTIVE_DB_CONNECTED` pada Tahap 0 memiliki runtime status `NOT_TESTED`.

### 15.3 Database Comparison

Pencarian file database dump lokal terbaru di workspace dilakukan tanpa menebak nama/path. File `.sql`, `.dump`, dan `.bak` yang ditemukan hanya:

- `database/kontainer_db.sql`
- `database/patches/*.sql`
- `services/api/migrations/*.sql`

Tidak ditemukan file dump lokal terpisah yang dapat dibandingkan terhadap canonical dump.

Perbandingan database lokal terbaru belum dilakukan karena file tidak tersedia pada workspace Codex.

Karena tidak ada dump lokal terpisah, item berikut belum dapat dibandingkan secara aktual:

- daftar tabel;
- daftar kolom tabel Kelaikan;
- foreign key;
- index;
- permissions;
- role_permissions;
- numbering_settings;
- numbering_sequences;
- master seed;
- checklist template/items;
- keberadaan data runtime `audit_logs`;
- keberadaan data runtime `refresh_tokens`.

Tidak ada dump lokal mentah yang disalin ke Git dan tidak ada perubahan pada `database/kontainer_db.sql`.

### 15.4 Gap Tambahan

| Area | Catatan Tambahan |
|---|---|
| Semantik DELETE versus Nonaktifkan | UI memakai label Nonaktifkan, tetapi resource dengan `SoftDelete` mengisi `deleted_at`, sehingga data hilang dari list aktif/inaktif dan sulit diaktifkan kembali. |
| Kemampuan mengosongkan field optional saat edit | `cleanPayload` frontend membuang field kosong secara global, sehingga optional field yang dikosongkan tidak selalu tersimpan sebagai `NULL`. |
| Validasi required pada update backend | Backend awal hanya memeriksa required field pada create; update masih bisa mengosongkan field wajib bila payload mengirim string kosong. |
| Audit log mutation | Mutation master data sudah memanggil audit log, tetapi error audit awal diabaikan dan tidak ikut menentukan sukses/gagal mutation. |
| Relation dropdown dibatasi 100 data | Relation option awal mengambil `per_page=100` dan dapat gagal menampilkan data lama/inactive atau data di luar halaman pertama. |
| Status runtime | `ACTIVE_DB_CONNECTED` belum membuktikan create/read/update/nonaktifkan berhasil pada runtime API nyata. |
## Tahap 1.1 - Corrective Hardening

Corrective Tahap 1.1 menutup blocker hardening generic Master Data Admin Kelaikan:

- empty field semantics kini membedakan required, nullable, non-null default, dan omitted field;
- default database seperti `display_order=0`, `version_no=1`, `severity_default=minor`, dan `final_fitness_result_mapping=pending` dijaga;
- mutation master data dan audit log dibungkus dalam satu transaction;
- relation fetch tidak lagi dipicu oleh perubahan field non-relation;
- list search memakai debounce 350 ms;
- user Surveyor memakai searchable relation `/users`;
- aksi Nonaktifkan disembunyikan untuk row inactive dan backend mencegah audit deactivate berulang.

Laporan detail: `docs/ADMIN_STAGE_1_1_CORRECTIVE_REPORT.md`.
Matrix field: `docs/ADMIN_STAGE_1_FIELD_NULLABILITY_MATRIX.md`.
## Tahap 1.2 - Final Correction Generic Master Data

Tahap 1.2 memperbaiki koreksi akhir generic Master Data Admin Kelaikan tanpa melanjutkan ke Tahap 2.

Ringkasan:

- Nullable frontend diselaraskan dengan backend dan DDL untuk optional field, termasuk owner, manufacturer, location, surveyor, container type, FK nullable, authorized signer, company profile, dan field optional lain pada matrix.
- Empty update optional field nullable dikirim sebagai `null` dan diproses backend sebagai `NULL`.
- Backend list/detail mengembalikan label relation dari DB: `inspection_area_label`, `component_label`, `test_parameter_label`, `approval_category_label`, dan `container_type_label`.
- List/detail frontend memakai label relation dari row response, bukan `relationOptions` milik dialog.
- `finding_severities.requires_supervisor_review` diselaraskan ke default patch 0015/canonical dump `0/false`; aturan critical wajib review tetap Tahap 2.
- Smoke test DB test terpisah ditambahkan dengan env `MASTERDATA_SMOKE_DSN`; test menolak DSN yang tidak mengandung `test` agar tidak memakai database kerja utama.
- Tidak ada patch SQL, migration, tabel baru, endpoint baru, commit, atau push pada tahap ini.

Risiko tersisa:

- Smoke runtime DB nyata hanya berjalan jika database test eksplisit tersedia.
- Business rule Tahap 2 seperti singleton company profile, template aktif wajib punya item, dan aturan critical severity belum diaktifkan.
