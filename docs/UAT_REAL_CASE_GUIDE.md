# Panduan UAT Real Case Survey Sheet

Dataset ini khusus lokal/staging dan selalu memakai label
`UAT-REAL-CASE-2026-08`. Data, akun, gambar, Job, Customer, bucket, dan prefix
yang dibuat adalah fixture sintetis, bukan bukti inspeksi produksi.

## Guardrail

- Target database wajib berakhiran `_uat`; seluruh script menolak nama lain.
- Gunakan database disposable. Jangan arahkan script ke `kontainer_db` produksi.
- Bucket dan object key wajib berada di prefix UAT yang diberikan saat API dan
  worker dijalankan.
- Password fixture dipakai untuk autentikasi, tetapi tidak dicetak pada output.
- Cleanup tidak memakai `TRUNCATE`, `DROP TABLE`, atau `DELETE` tanpa filter.

## Prasyarat

- MySQL 8.4 lokal dan database sumber yang dapat di-clone.
- Go, Node.js/npm, dan executable `mysql`/`mysqldump`.
- API, worker, MinIO, dan Next.js web diarahkan ke database/bucket UAT yang sama.
- Customer sumber master `UAT-CUST-17B` aktif dan memiliki effective master yang
  lengkap.
- MinIO client `mc` tersedia untuk verifikasi lifecycle object.

## Seed dan pemeriksaan SQL

Contoh bootstrap fixture:

```powershell
.\scripts\uat\seed-real-case.ps1 `
  -SourceDatabaseName kontainer_db `
  -DatabaseName kontainer_db_uat `
  -ApiBaseUrl http://127.0.0.1:8080/api/v1 `
  -MinioEndpoint http://127.0.0.1:9000 `
  -MinioBucket gift-survey-uat-real-case `
  -MasterSourceCustomerCode UAT-CUST-17B `
  -Mode BrowserReady

.\scripts\uat\verify-real-case.ps1 `
  -DatabaseName kontainer_db_uat `
  -Mode Finalize
```

`Mode` seed menerima `All`, `BrowserReady`, atau `Finalize`. Seed membuat enam
akun role, Customer UAT, tiga alur workflow, satu target isolasi, dan fixture
multi-container. `-SkipPhotos` hanya menandai pemeriksaan object `SKIPPED`; script
tidak pernah menyisipkan metadata foto palsu.

Jika target belum ada, seed membuatnya lalu menyalin source memakai
`mysqldump --single-transaction`. Marker migration 0013-0018 diperiksa sebelum
fixture domain dibuat. Kegagalan migration parsial menghentikan proses.

Pemeriksaan Finalize berisi 24 gate: duplikasi akun/Job/assignment, enam
container, konsistensi Customer, counter Temuan, active survey, checklist/foto,
scope master, audit upload, revision snapshot dan resolution, location snapshot,
orphan record, isolation fixture, prefix object, mixed status, approve, reject,
audit actions, role boundary, file reference, serta kesehatan deletion queue.

## Menjalankan browser UAT

API, worker, MinIO, dan web harus dijalankan lebih dahulu dengan konfigurasi
UAT. Untuk menguji artefak yang sama dengan Dockerfile web, salin
`.next/standalone`, `.next/static`, dan `public` ke satu direktori lalu jalankan
`node apps/web/server.js` dari direktori tersebut.

Setelah service siap, isi environment sesuai
`apps/web/e2e/README.md`, termasuk:

- `E2E_MULTI_CONTAINER_JOB_ID`;
- `E2E_CONTAINER_A_NO` dan `E2E_CONTAINER_B_NO`;
- `E2E_REVISION_SURVEY_ID`;
- `E2E_REJECTION_SURVEY_ID`;
- `E2E_ISOLATION_SURVEY_ID`;
- pasangan email/password setiap role.

Lalu jalankan serial karena suite memakai fixture mutatif:

```powershell
$env:PLAYWRIGHT_EXTERNAL_SERVER="1"
$env:PLAYWRIGHT_BASE_URL="http://127.0.0.1:3000"
$env:E2E_OPERATIONAL="1"
npm run test:e2e:operational --workspace apps/web -- --workers=1
```

Suite menguji start independen multi-container, upload foto umum, submit,
review claim, need revision Foto/Temuan, deep-link `Buka Target`, resubmit,
approve, reject, isolasi assignment/Customer, read-only Admin/Management, dan
empat viewport. Reseed fixture sebelum mengulang suite mutatif.

## Verifikasi object storage lifecycle

Jalankan script ini pada Survey draft yang disiapkan seed, dengan API, worker,
dan MinIO aktif:

```powershell
.\scripts\uat\verify-storage-lifecycle.ps1 `
  -DatabaseName kontainer_db_uat `
  -ApiBaseUrl http://127.0.0.1:8080/api/v1 `
  -MinioEndpoint http://127.0.0.1:9000 `
  -MinioBucket gift-survey-uat-real-case `
  -ExpectedObjectPrefix "uat/UAT-REAL-CASE-2026-08/"
```

Script melakukan login Surveyor, membuat checklist negatif dan Temuan, upload
foto, membaca original/watermark secara private, soft-delete, memastikan dua
queue pending, restore dan memastikan queue cancelled, soft-delete ulang,
memajukan eligibility hanya di database `_uat`, menunggu worker, memastikan dua
queue processed, memastikan kedua object hilang dari MinIO, lalu memeriksa audit
log.

## Hasil referensi 11 Agustus 2026

- Browser operational E2E: 7 lulus, 9 expected skip, 0 gagal.
- SQL Finalize: 24 dari 24 gate lulus.
- MinIO API dan worker integration: lulus.
- Storage lifecycle HTTP/MySQL/MinIO: lulus sampai object terhapus.
- Rekonsiliasi lifecycle: `missing=0` dan `orphans=0`.
- Next.js production standalone `/login`: HTTP 200 tanpa error kritis.

Rincian database, bucket, prefix, backup, dan batas bukti tersedia di
`docs/FINAL_REPOSITORY_HARDENING_REPORT.md`.

## Cleanup

Selalu tinjau dry run lebih dahulu:

```powershell
.\scripts\uat\cleanup-real-case.ps1 `
  -DatabaseName kontainer_db_uat `
  -DryRun
```

Cleanup memeriksa suffix `_uat` dan manifest. SQL dibatasi pada akun `uat.*`,
email `.test`, dan manifest dataset. Jika domain records atau object masih ada,
hapus melalui API sesuai urutan foreign key dan hanya pada prefix dataset, lalu
ulang cleanup.
