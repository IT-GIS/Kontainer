# Setup Database MySQL Laragon

`services/api/migrations` adalah sumber canonical skema untuk MySQL 8/Laragon.
`database/kontainer_db.sql` adalah baseline export dan seed, sedangkan
`database/patches` hanya jalur kompatibilitas untuk deployment lama. Perubahan
schema baru wajib dibuat di migration terlebih dahulu.

Buat database dengan character set `utf8mb4` dan collation
`utf8mb4_0900_ai_ci` sebelum import agar seluruh foreign key pada dump
memakai collation UUID yang sama.

## Akun development

Semua akun memakai password `password`:

- `superadmin@gift.local`
- `admin@gift.local`
- `surveyor@gift.local`
- `supervisor@gift.local`
- `finance@gift.local`
- `management@gift.local`

Akun surveyor sudah dilengkapi profil surveyor aktif agar dapat membuka alur job
dan survey yang ditugaskan.

## Database baru

Untuk instalasi baru yang memerlukan akun/data demo, import baseline lalu
jalankan seluruh compatibility patch yang tercantum di bagian berikutnya:

1. `database/kontainer_db.sql`

Jangan menganggap dump sebagai source pengembangan schema. Baseline harus
diekspor ulang hanya setelah rangkaian migration, UAT, dan pemeriksaan orphan
lulus. Data runtime `refresh_tokens` dan `audit_logs` tidak boleh ikut disimpan
sebagai data deploy.

## Database yang sudah terlanjur dibuat

Jalankan patch berikut secara berurutan:

1. `database/patches/0009_navigation_permissions.sql`
2. `database/patches/0010_demo_users.sql`
3. `database/patches/0011_admin_stage1.sql`
4. `database/patches/0012_admin_stage2.sql`
5. `database/patches/0013_storage_relations.sql`
6. `database/patches/0014_uat_stabilization.sql`
7. `database/patches/0015_container_fitness_foundation.sql`
8. `database/patches/0016_container_fitness_master_stage1_permissions.sql`
9. `database/patches/0017_container_fitness_master_stage2_permissions.sql`
10. `database/patches/0018_container_fitness_deploy_readiness.sql`
11. `database/patches/0019_iso_cedex_decision_rules.sql`
12. `database/patches/0020_iso_cedex_governance.sql`
13. `database/patches/0021_interactive_survey_sheet.sql`
14. `database/patches/0022_survey_workflow_integrity.sql`
15. `database/patches/0023_workflow_operational_closure.sql`

Patch aman dijalankan berulang sejauh memungkinkan. Patch `0009`
menyelaraskan permission menu dan role. Patch `0010` menambahkan akun demo,
role masing-masing, serta profil aktif untuk surveyor demo. Patch `0011`
menambahkan permission Monitoring Survey Admin dan status container `rejected`.
Patch `0012` menginisialisasi sequence nomor dokumen dari data yang sudah ada
agar generator transaksional tidak mengulang nomor lama.
Patch `0013` menambahkan relasi foreign key operasional dan referensi file
watermark. Foreign key dengan data orphan akan dilewati dan dilaporkan agar
patch existing database tidak berhenti di tengah.
Patch `0014` menyelaraskan ulang permission Admin, Supervisor, Finance, dan
Management untuk UAT, termasuk akses read-only User Management dan Monitoring
Survey bagi Admin.

Patch `0015` menambahkan database foundation Sistem Kelaikan Peti Kemas
tanpa menghapus workflow legacy dan tanpa memakai `container_import_batches`
untuk kelaikan. Dump canonical sekarang sudah diperbarui untuk deploy Admin Kelaikan.

Patch `0016` menyelaraskan permission granular CRUD untuk master baru Stage 1,
yaitu pabrik pembuat peti kemas dan kategori persetujuan kelaikan, tanpa
menghapus permission `view.all` atau `manage.all` yang sudah ada.

Patch `0017` menyelaraskan permission granular CRUD untuk 11 master Stage 2:
skema pemeliharaan, area pemeriksaan, komponen struktur, kriteria kerusakan,
severity, parameter pengujian kelaikan, template checklist header, kategori foto
evidence, rekomendasi hasil pemeriksaan, pejabat penandatangan, dan profil
badan usaha.

Patch `0018` menyiapkan `numbering_sequences` periode `2026` untuk document
type Kelaikan: `fitness_application`, `fitness_container_import`,
`fitness_assignment`, `fitness_inspection`, `repair_followup`,
`fitness_review`, `fitness_approval`, `approval_document`, dan
`release_letter`. Patch ini tidak menghapus data runtime dan tidak
mengaktifkan workflow lapangan.

Patch `0019` sampai `0022` menambahkan decision rule ISO CEDEX, governance
referensi pemeriksaan, Survey Sheet Interaktif, dan integritas workflow
Surveyor-Reviewer. Patch `0023` menutup workflow operasional: status Job
terpusat, round/phase Survey, claim reviewer, item revisi terstruktur, audit
check digit dan CSC, metadata laporan internal, profil Surveyor, serta antrean
purge foto dengan retensi. Jalankan perintah dari root repository karena patch
`0023` memakai `SOURCE` ke migration canonical.

Jangan menyalin skema dari dokumentasi lain. Jika ada perbedaan struktur,
gunakan urutan `services/api/migrations` sebagai acuan; gunakan dump hanya
sebagai baseline import dan patch sebagai kompatibilitas deployment lama.
