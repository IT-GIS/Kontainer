# Sistem Kelaikan Peti Kemas

**English name:** Container Fitness Approval System  
**Acuan regulasi:** Peraturan Menteri Perhubungan Nomor 25 Tahun 2022 tentang Kelaikan Peti Kemas dan Berat Kotor Peti Kemas Terverifikasi

Monorepo aplikasi internal untuk mengelola pemeriksaan, pengujian, tindak lanjut perbaikan, re-inspection, dan penerbitan dokumen persetujuan kelaikan peti kemas berdasarkan ruang lingkup Permenhub 25/2022.

> Fokus aplikasi hanya **Kelaikan Peti Kemas**. VGM / Verified Gross Mass, penimbangan peti kemas, dan sertifikat VGM tidak termasuk lingkup aplikasi.

## Status Transisi

Repositori sedang berada pada tahap dokumentasi dan perencanaan perubahan scope. Code aplikasi dan database masih menggunakan sebagian konsep Container Survey Management System lama. Implementasi Sistem Kelaikan Peti Kemas akan dilakukan bertahap setelah plan disetujui; fitur lama belum dihapus pada tahap ini.

## Tujuan Aplikasi

1. Mengelola permohonan kelaikan peti kemas baru dan peti kemas lama.
2. Mencatat pemilik, pabrik pembuat, lokasi pemeriksaan, dan surveyor/pemeriksa.
3. Mengelola pemeriksaan dan pengujian kelaikan.
4. Mencatat temuan kerusakan struktural dan tindak lanjut perbaikan oleh pemilik/client.
5. Mengelola re-inspection hingga keputusan layak atau tidak layak.
6. Menerbitkan dokumen persetujuan kelaikan sesuai kebutuhan Permenhub 25/2022.

## Batas Lingkup

Termasuk dalam scope:

- kelaikan peti kemas baru dan peti kemas lama;
- permohonan, pemeriksaan, pengujian, dan review kelaikan;
- temuan struktur, tindak lanjut perbaikan, dan re-inspection;
- persetujuan kelaikan, surat pembebasan setelah perbaikan, dan data CSC Safety Approval Plate;
- laporan kegiatan dan validasi dokumen kelaikan.

Tidak termasuk dalam scope:

- VGM, penimbangan, sertifikat VGM, dan persetujuan peralatan VGM;
- CEDEX Repair sebagai keputusan atau operasional repair;
- operasional bengkel dan billing repair;
- Finance sebagai lingkup utama sistem kelaikan pada tahap awal.

## Dokumen Desain Kelaikan Peti Kemas

- [Scope aplikasi](docs/SCOPE_KELAIKAN_PETI_KEMAS.md)
- [Rancangan menu Admin](docs/MENU_KELAIKAN_PETI_KEMAS.md)
- [Rancangan ulang database](docs/DATABASE_REDESIGN_CONTAINER_FITNESS.md)
- [Workflow kelaikan](docs/WORKFLOW_KELAIKAN_PETI_KEMAS.md)
- [Lifecycle status](docs/STATUS_LIFECYCLE_KELAIKAN_PETI_KEMAS.md)
- [Kebutuhan form](docs/FORM_REQUIREMENTS_KELAIKAN_PETI_KEMAS.md)
- [Field dokumen persetujuan](docs/CERTIFICATE_FIELDS_KELAIKAN_PETI_KEMAS.md)
- [Rencana migrasi](docs/MIGRATION_PLAN_CONTAINER_FITNESS.md)

## Stack

- Web: Next.js + TypeScript
- API: Go + Gin
- Database: MySQL 8 / Laragon
- Queue/cache: Redis
- Object storage: MinIO / S3

## Menjalankan dengan MySQL Laragon

Prasyarat: Node.js, npm, Go 1.22+, Laragon dengan MySQL 8+.

1. Nyalakan MySQL dari Laragon.
2. Import `database/kontainer_db.sql` melalui phpMyAdmin.
3. Salin environment jika `.env` belum ada:

```powershell
Copy-Item .env.example .env
```

Konfigurasi Laragon default sudah disiapkan:

```env
DATABASE_URL=root@tcp(127.0.0.1:3306)/kontainer_db?parseTime=true&charset=utf8mb4&loc=Local
```

4. Jalankan API:

```powershell
cd services/api
go mod tidy
go run ./cmd/api
```

5. Pada terminal baru, jalankan web:

```powershell
npm install
npm run dev:web
```

6. Buka `http://localhost:3000`.

Akun development memakai password `password`:

- `superadmin@gift.local`
- `admin@gift.local`
- `surveyor@gift.local`
- `supervisor@gift.local`
- `finance@gift.local`
- `management@gift.local`

Dokumentasi query lengkap tersedia di `database/MYSQL_LARAGON_SETUP.md`.

## Docker Compose

Docker memakai service MySQL internal dan tidak memakai MySQL Laragon:

```powershell
docker compose -f infra/docker/docker-compose.yml --env-file .env up --build
```

URL lokal:

- Web: `http://localhost:3000`
- API: `http://localhost:8080`
- Nginx: `http://localhost:8088`
- MinIO: `http://localhost:9001`
