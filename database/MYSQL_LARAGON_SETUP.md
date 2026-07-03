# Setup Database MySQL Laragon

`database/kontainer_db.sql` adalah sumber canonical skema dan seed database untuk
MySQL 8/Laragon. Import file tersebut melalui phpMyAdmin ke database
`kontainer_db`.

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

Untuk database baru, cukup import:

1. `database/kontainer_db.sql`

Dump utama sudah memuat permission workspace Admin, Surveyor, dan Finance serta
seluruh akun demo.

## Database yang sudah terlanjur dibuat

Jalankan patch berikut secara berurutan:

1. `database/patches/0009_navigation_permissions.sql`
2. `database/patches/0010_demo_users.sql`
3. `database/patches/0011_admin_stage1.sql`
4. `database/patches/0012_admin_stage2.sql`
5. `database/patches/0013_storage_relations.sql`
6. `database/patches/0014_uat_stabilization.sql`

Keenam patch aman dijalankan berulang. Patch `0009`
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

Jangan menyalin skema dari dokumentasi lain. Jika ada perbedaan, gunakan
`database/kontainer_db.sql` sebagai acuan.
