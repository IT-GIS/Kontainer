# Sistem Kelaikan Peti Kemas

**English name:** Container Fitness Approval System  
**Acuan regulasi:** Peraturan Menteri Perhubungan Nomor 25 Tahun 2022 tentang Kelaikan Peti Kemas dan Berat Kotor Peti Kemas Terverifikasi

Aplikasi ini adalah sistem internal untuk mengelola **pemeriksaan, pengujian, tindak lanjut perbaikan, re-inspection, dan penerbitan dokumen persetujuan kelaikan peti kemas** berdasarkan ruang lingkup Permenhub 25/2022.

> Fokus aplikasi: **Kelaikan Peti Kemas**.
> Modul VGM / Verified Gross Mass tidak termasuk lingkup aplikasi ini.

## Tujuan Aplikasi

1. Mengelola permohonan kelaikan peti kemas.
2. Mencatat data pemilik peti kemas, pabrik pembuat, lokasi pemeriksaan, dan surveyor/pemeriksa.
3. Mengelola pemeriksaan dan pengujian peti kemas baru dan peti kemas lama.
4. Mencatat temuan kerusakan struktural dan status tindak lanjut.
5. Mengelola status perbaikan oleh pemilik/client dan re-inspection.
6. Menerbitkan dokumen persetujuan kelaikan sesuai format Permenhub 25/2022.
7. Menyediakan QR validation untuk dokumen kelaikan.
8. Menyediakan laporan kegiatan dan rekap kelaikan peti kemas.

## In Scope

- Kelaikan Peti Kemas Baru.
- Kelaikan Peti Kemas Lama.
- Permohonan kelaikan.
- Pemeriksaan dan pengujian kelaikan.
- Temuan kerusakan struktur.
- Status perlu perbaikan.
- Re-inspection setelah perbaikan.
- Persetujuan kelaikan.
- Surat pembebasan setelah peti kemas diperbaiki dan memenuhi kelaikan.
- CSC Safety Approval Plate data.
- QR validation dokumen kelaikan.
- Laporan kegiatan kelaikan.

## Out of Scope

- Verified Gross Mass / VGM.
- Penimbangan berat kotor peti kemas terverifikasi.
- Sertifikat VGM.
- Persetujuan peralatan VGM.
- CEDEX Repair sebagai keputusan repair.
- Operasional bengkel repair.
- Billing repair.

## Stack

- Web: Next.js + TypeScript
- API: Go + Gin
- Database: MySQL 8 / Laragon
- Queue/cache: Redis
- Object storage: MinIO / S3

## Dokumen Desain Kelaikan Peti Kemas

Dokumen desain aplikasi berada di folder `docs/`:

1. `docs/SCOPE_KELAIKAN_PETI_KEMAS.md`
2. `docs/MENU_KELAIKAN_PETI_KEMAS.md`
3. `docs/DATABASE_REDESIGN_CONTAINER_FITNESS.md`
4. `docs/WORKFLOW_KELAIKAN_PETI_KEMAS.md`
5. `docs/CERTIFICATE_FIELDS_KELAIKAN_PETI_KEMAS.md`
6. `docs/MIGRATION_PLAN_CONTAINER_FITNESS.md`
7. `docs/STATUS_LIFECYCLE_KELAIKAN_PETI_KEMAS.md`
8. `docs/FORM_REQUIREMENTS_KELAIKAN_PETI_KEMAS.md`

## Prinsip Perubahan dari Versi Lama

Versi lama menggunakan pendekatan umum `Container Survey Management System` dengan konsep survey type, CEDEX repair, responsibility code, report survey, dan finance. Versi Kelaikan Peti Kemas harus diarahkan ulang menjadi sistem kelaikan peti kemas dengan fokus pada:

- permohonan kelaikan,
- data teknis peti kemas,
- pemeriksaan dan pengujian,
- status kelaikan,
- perbaikan oleh pemilik/client,
- re-inspection,
- persetujuan kelaikan,
- dokumen kelaikan.

## Catatan Implementasi

Perubahan ini merupakan perubahan scope besar. Implementasi wajib dilakukan bertahap:

1. Kunci scope dan menu Admin.
2. Redesign database canonical.
3. Migrasi label dan route dari `survey` menjadi `kelaikan`/`inspection`.
4. Hapus modul yang di luar scope.
5. Implement dokumen persetujuan kelaikan yang mengacu pada Permenhub 25/2022.
6. Lakukan UAT alur kelaikan peti kemas baru dan lama.
