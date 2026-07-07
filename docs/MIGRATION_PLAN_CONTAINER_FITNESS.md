# Migration Plan ke Sistem Kelaikan Peti Kemas

Dokumen ini mengatur migrasi bertahap dari schema general Container Survey Management System menuju **Sistem Kelaikan Peti Kemas**.

## Tahap Saat Ini - Database Foundation

Tahap ini additive-only:

- Menambahkan tabel foundation baru.
- Menambahkan seed master data kelaikan.
- Menambahkan numbering foundation.
- Menambahkan permission dan role mapping foundation.
- Tidak drop/rename tabel legacy.
- Tidak cleanup data legacy.
- Tidak mengubah `database/kontainer_db.sql`.
- Tidak membuat CRUD API.
- Tidak membuat repository, service, handler backend, atau route mutation baru.
- Tidak mengaktifkan submit form frontend.
- Tidak membuat upload aktif, PDF final, QR final, approval final, finance kelaikan, Type Design aktif, repair cycle penuh, atau re-inspection cycle penuh.

Patch tahap ini:

- `database/patches/0015_container_fitness_foundation.sql`
- `services/api/migrations/0010_container_fitness_foundation.up.sql`
- `services/api/migrations/0010_container_fitness_foundation.down.sql`

Patch harus dijalankan setelah base schema aplikasi tersedia dan harus valid pada salinan database existing terbaru.

## Legacy Compatibility

Tabel legacy general survey tetap dipertahankan sebagai archive/compatibility layer:

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
- CEDEX master tables
- `responsibility_codes`
- `container_import_batches`

`container_import_batches` tidak dipakai untuk kelaikan karena terkait `job_order_id`. Import kelaikan memakai `fitness_container_import_batches` dan `fitness_container_import_rows`.

## Existing Tables Yang Dipakai Ulang

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

Tabel fisik existing tidak di-rename.

## Tahap Berikutnya

Setelah database foundation tervalidasi, tahap berikutnya dapat dilakukan bertahap:

1. API read-only untuk master foundation.
2. CRUD master data kelaikan.
3. CRUD permohonan kelaikan dan data peti kemas.
4. Import preview dan proses import kelaikan.
5. Assignment surveyor untuk kelaikan.
6. Pemeriksaan surveyor, temuan struktur, foto evidence, dan submit hasil.
7. Review, repair follow-up, re-inspection, approval, dokumen, dan QR.

Setiap tahap harus tetap menjaga scope: fokus hanya Kelaikan Peti Kemas. VGM, penimbangan, sertifikat VGM, billing repair, finance utama, dan operasional bengkel repair bukan scope.

## Validasi Wajib

Untuk tahap database foundation:

```powershell
go test ./...
npm run typecheck --workspace apps/web
npm run build --workspace apps/web
git diff --check
```

Validasi SQL:

1. Import base schema aplikasi.
2. Jalankan patch foundation.
3. Jalankan patch pada salinan database existing terbaru.
4. Jalankan patch kedua kali untuk cek idempotency.
5. Pastikan tidak ada tabel legacy yang berubah/drop/rename.
6. Pastikan istilah terlarang tidak muncul di filename, identifier, route, config, permission, migration, atau module.
