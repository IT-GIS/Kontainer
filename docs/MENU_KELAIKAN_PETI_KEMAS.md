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
| Permohonan Kelaikan | `/fitness/applications` |
| Data Peti Kemas | `/fitness/containers` |
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
