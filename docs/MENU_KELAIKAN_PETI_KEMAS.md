# Menu Admin Kelaikan Peti Kemas

## Identitas Aplikasi

- Nama aplikasi: Sistem Kelaikan Peti Kemas
- Nama Inggris: Container Fitness Approval System
- Acuan regulasi dokumentasi: Permenhub 25/2022
- Scope aktif: Kelaikan Peti Kemas

## Aturan Scope Menu

Saat `NEXT_PUBLIC_APP_SCOPE=legacy`, menu legacy tetap tampil seperti sebelumnya.

Saat `NEXT_PUBLIC_APP_SCOPE=container_fitness`, Admin memakai menu Kelaikan dan menu general container survey disembunyikan dari workspace Admin aktif. Finance tetap workspace terpisah dan Surveyor legacy boleh tetap ada sementara.

## Menu Admin Final

```text
Dashboard Kelaikan

Master Data Kelaikan
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

Permohonan Kelaikan
- Daftar Permohonan
- Buat Permohonan
- Data Peti Kemas
- Import Data Peti Kemas
- Assign Surveyor

Pemeriksaan & Pengujian
- Monitoring Pemeriksaan
- Pemeriksaan Berjalan
- Perlu Perbaikan
- Siap Re-Inspection
- Re-Inspection
- Layak
- Tidak Layak

Review & Keputusan Kelaikan
- Pending Review
- Riwayat Review
- Keputusan Kelaikan
- Pembebasan Setelah Perbaikan

Dokumen Kelaikan
- Surat Persetujuan Kelaikan
- Surat Persetujuan Peti Kemas Baru Individual
- Surat Persetujuan Peti Kemas Lama
- Surat Pembebasan Setelah Perbaikan
- Data CSC Safety Approval Plate
- Validasi Dokumen

Laporan
- Rekap Pemeriksaan
- Rekap Peti Kemas Layak
- Rekap Peti Kemas Tidak Layak
- Rekap Perlu Perbaikan
- Rekap Re-Inspection
- Rekap Pemilik Peti Kemas
- Rekap Pabrik Pembuat
- Laporan Kegiatan 6 Bulanan

Setting
- Company Profile
- Numbering Setting
- Audit Log
- User Management
- Role & Permission

Arsip Survey Lama
```

## Route Placeholder

| Menu | Route |
|---|---|
| Dashboard Kelaikan | `/fitness/dashboard` |
| Master Data Kelaikan | `/fitness/master-data` |
| Daftar Permohonan | `/fitness/applications` |
| Buat Permohonan | `/fitness/applications/create` |
| Data Peti Kemas | `/fitness/containers` |
| Import Data Peti Kemas | `/fitness/containers/import` |
| Assign Surveyor | `/fitness/assignments` |
| Pemeriksaan & Pengujian | `/fitness/inspections` |
| Review & Keputusan Kelaikan | `/fitness/reviews` |
| Dokumen Kelaikan | `/fitness/documents` |
| Laporan | `/fitness/reports` |
| Arsip Survey Lama | `/fitness/legacy-archive` |

## Menu Legacy yang Disembunyikan dari Admin Kelaikan

- Survey Type
- CEDEX Location
- CEDEX Component
- CEDEX Damage
- CEDEX Repair
- CEDEX Material
- Responsibility Code
- Job Order legacy
- Monitoring Survey legacy
- Review legacy
- Report legacy
- Price List
- Invoice
- Payment
- Outstanding

Menu legacy tidak dihapus. Data lama tetap dapat diakses melalui mode `legacy` atau konsep `Arsip Survey Lama`.

## Peran Admin terhadap Surveyor

Admin menyiapkan master data agar Surveyor lapangan banyak memilih dari daftar yang sudah dikurasi, bukan mengetik bebas. Master yang paling penting untuk Surveyor adalah area pemeriksaan, komponen struktur, kriteria kerusakan, severity, parameter pengujian, checklist, kategori foto evidence, dan rekomendasi hasil pemeriksaan.
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
- Patch `0016_container_fitness_master_stage1_permissions.sql` menyelaraskan permission granular `create.all`, `update.all`, dan `delete.all` untuk `container_manufacturers` dan `fitness_approval_categories` agar CRUD Stage 1 berjalan dengan pola permission frontend dan backend saat ini.

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
