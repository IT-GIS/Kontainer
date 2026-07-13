# Deploy Admin Kelaikan

Dokumen ini menyiapkan deploy mode Admin untuk Sistem Kelaikan Peti Kemas. Mode ini mengaktifkan menu dan master data Admin Kelaikan, tetapi belum mengaktifkan Surveyor flow, Review final, PDF/QR, Finance kelaikan, import Excel aktif, repair/re-inspection, atau upload MinIO aktif.

## Requirement

- MySQL 8.x
- Go sesuai versi module `services/api` dan `services/worker`
- Node.js dan npm sesuai workspace web
- Database kosong dengan character set `utf8mb4` dan collation `utf8mb4_0900_ai_ci`

## Environment

Copy `.env.example` ke `.env`, lalu ubah nilai production berikut:

- `DATABASE_URL`
- `JWT_ACCESS_SECRET`
- `JWT_REFRESH_SECRET`
- `NEXT_PUBLIC_API_BASE_URL`
- `NEXT_PUBLIC_APP_SCOPE=container_fitness`

Default aplikasi untuk deploy ini:

```env
APP_NAME=container-fitness
NEXT_PUBLIC_APP_NAME=Sistem Kelaikan Peti Kemas
NEXT_PUBLIC_APP_SCOPE=container_fitness
```

## Setup Database Baru

1. Buat database `kontainer_db` di MySQL 8.x.
2. Pastikan character set `utf8mb4` dan collation `utf8mb4_0900_ai_ci`.
3. Import dump canonical:

```powershell
& 'C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe' --user=root --host=127.0.0.1 --port=3306 kontainer_db < database\kontainer_db.sql
```

Dump canonical sudah memuat patch Kelaikan sampai deploy readiness, termasuk tabel foundation, master seed, permission Admin, dan `numbering_sequences` periode `2026`. Data runtime lokal seperti `refresh_tokens` dan `audit_logs` tidak ikut disimpan sebagai data deploy.

## Database Existing

Jika database sudah pernah dibuat dari dump lama, jalankan patch berurutan sampai:

```text
database/patches/0015_container_fitness_foundation.sql
database/patches/0016_container_fitness_master_stage1_permissions.sql
database/patches/0017_container_fitness_master_stage2_permissions.sql
database/patches/0018_container_fitness_deploy_readiness.sql
```

Patch `0018` hanya menyiapkan sequence dokumen Kelaikan dan tidak menghapus data runtime.

## Menjalankan API

```powershell
cd services/api
go run ./cmd/api
```

Pastikan `DATABASE_URL`, `JWT_ACCESS_SECRET`, dan `JWT_REFRESH_SECRET` sudah diset untuk environment target.

## Build Web

```powershell
npm run typecheck --workspace apps/web
npm run build --workspace apps/web
```

Pastikan `NEXT_PUBLIC_API_BASE_URL` mengarah ke API production dan `NEXT_PUBLIC_APP_SCOPE=container_fitness`.

## Catatan Scope

- Admin menu Kelaikan dan master data sudah aktif.
- Template checklist item disiapkan sebagai master data untuk tahap form Surveyor berikutnya.
- Surveyor flow belum aktif.
- Dokumen PDF/QR belum aktif.
- Finance kelaikan belum aktif.
- Legacy table tetap ada untuk arsip dan compatibility.