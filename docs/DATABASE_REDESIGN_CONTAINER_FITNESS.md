# Database Redesign Container Fitness

Dokumen ini mengunci tahap **Database Foundation Sistem Kelaikan Peti Kemas**. Tahap ini additive-only dan menjadi dasar schema baru tanpa menghapus workflow legacy.

## Prinsip

1. Canonical model kelaikan dimulai dari `fitness_applications` dan `application_containers`.
2. Tabel legacy general survey tetap dipertahankan sebagai arsip/compatibility layer.
3. Tabel fisik existing yang stabil digunakan ulang; label UI boleh berubah, nama tabel tidak.
4. Patch tahap ini tidak membuat API CRUD, backend handler, submit form aktif, upload aktif, approval final, PDF final, QR final, finance kelaikan, Type Design aktif, atau cleanup data legacy.
5. Acuan regulasi produk tetap Permenhub 25/2022 di dokumentasi Markdown.

## Kenapa Legacy Tidak Menjadi Canonical

Schema existing masih berbasis **Container Survey Management System** umum:

- `job_orders` masih bergantung pada `survey_type_id`.
- `survey_types` berisi survey umum seperti Gate In, Gate Out, Damage Survey, Cargo Worthy, dan sejenisnya.
- `survey_damages` masih berbasis CEDEX dan responsibility code.
- `reports`, `report_versions`, dan `report_snapshots` masih merepresentasikan report survey umum.
- `invoices`, `invoice_items`, `payments`, dan `price_lists` adalah finance legacy dan bukan foundation kelaikan.
- `container_import_batches` adalah import legacy karena terkait `job_order_id`.

Karena itu, tabel legacy tidak dihapus, tetapi tidak dipakai sebagai canonical model Sistem Kelaikan Peti Kemas.

## Tabel Legacy Yang Dipertahankan

Tabel berikut tetap ada dan tidak di-drop/rename pada tahap ini:

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
- `survey_revision_items`
- `reports`
- `report_versions`
- `report_snapshots`
- `invoices`
- `invoice_items`
- `payments`
- `price_lists`
- `survey_types`
- `cedex_locations`
- `cedex_components`
- `cedex_damages`
- `cedex_repairs`
- `cedex_materials`
- `responsibility_codes`
- `container_import_batches`

## Tabel Existing Yang Digunakan Ulang

Tabel stabil berikut digunakan ulang oleh foundation kelaikan:

- `customers` sebagai Pemilik Peti Kemas
- `locations` sebagai Lokasi Pemeriksaan
- `surveyor_profiles` sebagai Surveyor / Pemeriksa
- `container_types` sebagai Jenis / Model Peti Kemas
- `users`
- `roles`
- `permissions`
- `role_permissions`
- `user_roles`
- `company_profiles`
- `numbering_settings`
- `numbering_sequences`
- `file_objects`
- `audit_logs`

Tidak ada rename fisik untuk tabel existing.

## Tabel Master Baru

Patch `database/patches/0015_container_fitness_foundation.sql` menambahkan master data foundation:

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

Type Design disimpan sebagai kategori future/inactive dan tidak aktif untuk MVP.

## Tabel Transaksi Foundation Baru

Tabel transaksi awal kelaikan:

- `fitness_applications`
- `application_containers`
- `container_technical_specs`
- `fitness_application_events`

Status foundation yang dipakai:

- `workflow_status`: `draft`, `assigned`, `inspection_in_progress`, `inspection_submitted`, `under_review`, `need_repair`, `repair_in_progress`, `ready_for_reinspection`, `reinspection_in_progress`, `completed`, `cancelled`
- `final_fitness_result`: `pending`, `fit`, `unfit`
- `restriction_status`: `none`, `suspended`, `prohibited`, `released`
- `approval_status`: `not_ready`, `pending_issue`, `issued`, `superseded`, `revoked`
- `finding_status`: `open`, `repair_required`, `repaired`, `still_defective`, `accepted`, `closed`

Tahap ini belum membuat tabel inspection penuh, structural findings aktif, approval final, repair cycle penuh, atau re-inspection cycle.

## Tabel Import Kelaikan Baru

Import data peti kemas kelaikan memakai tabel baru:

- `fitness_container_import_batches`
- `fitness_container_import_rows`

Tabel existing `container_import_batches` tidak dipakai untuk kelaikan karena masih terkait `job_order_id` dan merupakan legacy import.

## Relasi Utama

- `fitness_applications` -> `customers`
- `fitness_applications` -> `locations`
- `fitness_applications` -> `container_manufacturers`
- `fitness_applications` -> `fitness_approval_categories`
- `application_containers` -> `fitness_applications`
- `application_containers` -> `container_types`
- `container_technical_specs` -> `application_containers`
- `container_technical_specs` -> `maintenance_schemes`
- `structural_components` -> `inspection_areas`
- `structural_damage_criteria` -> `structural_components`
- `fitness_checklist_template_items` -> `fitness_checklist_templates`
- `fitness_checklist_template_items` -> `inspection_areas`
- `fitness_checklist_template_items` -> `structural_components`
- `fitness_checklist_template_items` -> `inspection_test_parameters`
- `fitness_container_import_batches` -> `fitness_applications`
- `fitness_container_import_rows` -> `fitness_container_import_batches`
- `fitness_container_import_rows` -> `application_containers`

Tidak ada foreign key baru dari foundation kelaikan ke tabel legacy transaksi seperti `job_orders`, `surveys`, `survey_damages`, `reports`, `invoices`, `payments`, `price_lists`, `survey_types`, CEDEX tables, responsibility code, atau `container_import_batches`.

## Numbering dan Permission

Patch foundation menambahkan document type baru:

- `fitness_application`
- `fitness_container_import`
- `fitness_assignment`
- `fitness_inspection`
- `repair_followup`
- `fitness_review`
- `fitness_approval`
- `approval_document`
- `release_letter`

Patch juga menambahkan permission foundation untuk master data, permohonan, data peti kemas, import, assignment, pemeriksaan, temuan, repair follow-up, review, approval, dan dokumen kelaikan.

Role mapping tahap ini:

- `super_admin`: semua permission foundation.
- `admin`: master data, permohonan, data peti kemas, import, assignment, repair follow-up, dan dokumen.
- `surveyor`: pemeriksaan dan temuan assigned.
- `supervisor`: view pemeriksaan, manage review, view approval, view dokumen.
- `management`: seluruh `view.all` foundation.

`fitness_approvals.issue.all` hanya diberikan ke `super_admin` pada foundation stage.

Patch `0016_container_fitness_master_stage1_permissions.sql` menambahkan permission CRUD granular untuk master baru Stage 1. Patch `0017_container_fitness_master_stage2_permissions.sql` menambahkan permission CRUD granular `view.all`, `create.all`, `update.all`, dan `delete.all` untuk 11 master Stage 2 dan mapping ke `super_admin`/`admin` tanpa menghapus permission `manage.all` yang sudah ada.
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

- Item Template Checklist Kelaikan belum menjadi CRUD nested aktif dan belum dipakai flow Surveyor.
- Assign Surveyor menunggu tahap Assignment Surveyor.
- Pemeriksaan & Pengujian menunggu tahap Surveyor Inspection Flow.
- Review & Keputusan menunggu tahap Review & Approval.
- Dokumen Kelaikan menunggu tahap Document & QR.

Batasan tahap ini:

- Tidak mengaktifkan workflow transaksi permohonan, assignment, pemeriksaan lapangan, review final, PDF, QR, import aktif, upload aktif, finance, repair, atau re-inspection.
- Tidak mengubah `database/kontainer_db.sql`, tabel legacy, atau patch `0015_container_fitness_foundation.sql`.
- Permission yang dipakai mengikuti foundation yang sudah ada: `*.view.all` untuk baca dan `*.manage.all` atau permission CRUD existing yang setara untuk perubahan data.

## Admin Master Data CRUD Stage 2

Tahap ini mengaktifkan CRUD nyata untuk 11 master data pendukung Surveyor lapangan:

1. Skema Pemeliharaan Peti Kemas (`/fitness/master-data/maintenance-schemes`) memakai tabel `maintenance_schemes`.
2. Area Pemeriksaan Peti Kemas (`/fitness/master-data/inspection-areas`) memakai tabel `inspection_areas`.
3. Komponen Struktur Peti Kemas (`/fitness/master-data/structural-components`) memakai tabel `structural_components`.
4. Kriteria Kerusakan / Ketidaksesuaian (`/fitness/master-data/damage-criteria`) memakai tabel `structural_damage_criteria`.
5. Tingkat Temuan / Severity (`/fitness/master-data/finding-severities`) memakai tabel `finding_severities`.
6. Parameter Pengujian Kelaikan (`/fitness/master-data/test-parameters`) memakai tabel `inspection_test_parameters`.
7. Template Checklist Kelaikan (`/fitness/master-data/checklist-templates`) memakai tabel `fitness_checklist_templates` untuk header template saja.
8. Kategori Foto Evidence (`/fitness/master-data/photo-categories`) memakai tabel `evidence_photo_categories`.
9. Rekomendasi Hasil Pemeriksaan (`/fitness/master-data/inspection-recommendations`) memakai tabel `inspection_recommendations`.
10. Pejabat Penandatangan (`/fitness/master-data/authorized-signers`) memakai tabel `authorized_signers`.
11. Profil Badan Usaha (`/fitness/master-data/company-profile`) memakai tabel `company_profiles`.

Setiap halaman Stage 2 aktif menyediakan list, pencarian, filter status, tambah, detail, edit, dan aksi nonaktifkan melalui endpoint REST `/api/v1/fitness/master-data/*`.

Batasan Stage 2:

- Item checklist pada `fitness_checklist_template_items` belum menjadi CRUD nested aktif.
- Tidak mengaktifkan Assignment Surveyor, Pemeriksaan Lapangan, Review/Approval final, Dokumen PDF/QR final, Import Excel proses nyata, Finance, atau workflow transaksi lain.
- Tidak mengubah tabel legacy, tidak drop/rename tabel, dan tidak mengubah patch `0015` maupun `0016`.
- Patch `0017_container_fitness_master_stage2_permissions.sql` menyelaraskan permission granular `view.all`, `create.all`, `update.all`, dan `delete.all` untuk 11 master Stage 2 dan mapping `super_admin`/`admin`.
