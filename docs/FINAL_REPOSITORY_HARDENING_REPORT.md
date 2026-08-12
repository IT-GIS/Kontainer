# Laporan Final Penyempurnaan Repository Kontainer

Tanggal validasi: 11 Agustus 2026 (Asia/Jakarta).

Status: seluruh perubahan kode, database, storage, CI definition, browser E2E,
backup, baseline, dan staging lokal yang diminta brief sudah diimplementasikan
serta divalidasi. Satu tindakan eksternal belum dilakukan: branch protection
`main` pada GitHub. Pemeriksaan read-only mengembalikan `404 Branch not
protected`; pengaktifannya akan mengubah kebijakan push seluruh tim dan harus
dilakukan dengan otorisasi GitHub yang valid.

## Hasil implementasi P0

- Readiness gate dan resolver Survey Sheet memakai satu aturan effective master:
  Customer override aktif diprioritaskan, global aktif menjadi fallback, override
  nonaktif tidak memblokir fallback, dan master yang benar-benar hilang tetap
  memblokir Job. Cakupannya adalah Location, Component, Damage, Action/Repair,
  Material, Responsibility Code, dan Decision Rule.
- Query progress/list Surveyor hanya menggabungkan Survey aktif
  (`is_active=1` dan `deleted_at IS NULL`), sehingga Survey lama tidak lagi
  menggandakan atau mengubah progres Job.
- Agregasi status Job menangani multi-container dan status campuran untuk draft,
  assigned, submitted, under review, need revision, resubmitted, approved, dan
  rejected. Reject, revision, resubmit, approval, serta kesiapan report memiliki
  test status tersendiri.
- Worker memproses `object_deletion_queue` dengan batch lock, pemeriksaan
  referensi foto aktif, validasi bucket/prefix, retry eksponensial, dan terminal
  status `processed`, `failed`, atau `cancelled`.
- Soft-delete foto membuat queue dengan retensi tujuh hari. Restore mengaktifkan
  kembali metadata dan membatalkan queue selama object belum diproses.
- Migration additive `0018` menambahkan metadata retry/lock queue dan merapikan
  batas permission role tanpa menghapus data bisnis.

## Hasil implementasi P1

- GitHub Actions mendefinisikan Go test/vet, MySQL migration dan integration,
  migration `0018` down/up, lint, tiga frontend contract test, typecheck, build,
  MinIO API/worker integration, responsive browser smoke, operational E2E
  opsional, serta whitespace/secret scan.
- Browser E2E operasional menguji multi-container, foto umum, submit, review
  claim, need revision untuk Foto dan Temuan, deep-link target, resubmit,
  approve, reject, customer/assignment isolation, dan batas role.
- Viewport yang diuji adalah 360x800, 390x844, 768x1024, dan 1366x768. Semua
  lulus tanpa horizontal overflow.
- Status dan label utama Surveyor memakai mapping Bahasa Indonesia terpusat.
  Menu `Selesai` hanya memuat status terminal; `Riwayat Survey` menyediakan
  filter tanggal, Customer, peti kemas, dan hasil.
- Management dan Admin bersifat read-only pada alur keputusan teknis. Hanya
  Supervisor atau Super Admin yang dapat melakukan review mutation.
- Error API yang tidak tertangani sekarang dicatat secara aman memakai request
  ID, method, path, dan error internal tanpa merekam body atau kredensial.

## Temuan saat UAT yang sudah diperbaiki

1. Upload foto sempat menghasilkan HTTP 500 karena query konteks foto membaca
   `surveys.customer_id`, kolom yang tidak ada. Query diperbaiki untuk memakai
   `job_orders.customer_id`.
2. Halaman Survey dapat berhenti pada teks memuat saat API gagal. Sekarang error
   forbidden/not-found tampil eksplisit dalam elemen `role=alert`.
3. Submit login sebelum React selesai hydration dapat berubah menjadi native
   GET `/login?`. Tombol submit sekarang baru aktif setelah hydration.
4. Suite mutatif dapat saling berebut fixture bila paralel. Workflow operasional
   dijalankan serial (`--workers=1`) dan setiap skenario memiliki timeout yang
   proporsional.

## Database, baseline, dan backup

- Migration canonical terbaru:
  `services/api/migrations/0018_final_repository_hardening.up.sql`.
- Down migration:
  `services/api/migrations/0018_final_repository_hardening.down.sql`.
- Patch deployment instalasi lama:
  `database/patches/0024_final_repository_hardening.sql`.
- Baseline bersih terbaru: `database/kontainer_db.sql` (71 tabel, 127 foreign
  key). Restore baseline ke database kosong telah lulus.
- Backup UAT final:
  `database/backups/kontainer_final_operational_20260811d_uat_20260811.sql`.
  Restore backup lulus dengan 74 tabel, satu revision approved, dan satu Survey
  rejected.
- Database workflow UAT final:
  `kontainer_final_operational_20260811d_uat`.
- Database storage lifecycle:
  `kontainer_final_operational_20260811c_uat`.
- Database migration bersih:
  `kontainer_final_ci2_20260811_uat`.

Catatan operasional: database harus memakai collation yang konsisten dengan
tabel migration. MySQL 8.4 default yang dipakai CI dan validasi lulus. Database
yang dibuat manual dengan `utf8mb4_unicode_ci` tidak boleh dicampur dengan tabel
ber-collation `utf8mb4_0900_ai_ci` karena foreign key akan ditolak oleh MySQL.

## Bukti validasi yang benar-benar dijalankan

| Area | Bukti | Hasil |
| --- | --- | --- |
| API | `go test ./...` dan `go vet ./...` | Lulus |
| Worker | `go test ./...` dan `go vet ./...` | Lulus |
| MySQL | Migration 0001-0018 dari database kosong | Lulus |
| Migration safety | `0018` down/up dan restore baseline | Lulus |
| Effective master | MySQL integration test | Lulus |
| Queue | MySQL deletion-queue integration test | Lulus |
| MinIO API | Upload/read/delete round-trip | Lulus |
| MinIO worker | Object deletion dan MySQL queue round-trip | Lulus |
| Frontend | Lint, Navigation, ISO CEDEX, Survey Sheet, typecheck | Lulus |
| Production frontend | Next.js production build, 74 routes | Lulus |
| Browser operasional | Edge/Playwright terhadap API, MySQL, worker, MinIO, dan standalone web nyata | 7 lulus, 9 expected skip, 0 gagal |
| SQL UAT | 24 pemeriksaan final atas workflow, audit, isolasi, file, dan queue | 24 lulus |
| Repository hygiene | `git diff --check` dan common-secret scan | Lulus |
| Staging lokal | Standalone production `/login` pada `127.0.0.1:3000` | HTTP 200, tanpa error kritis |

Sembilan skip Playwright adalah by design: tiga skenario mutatif hanya berjalan
sekali pada project desktop dan dilewati pada tiga project viewport lainnya.
Seluruh pemeriksaan nonmutatif tetap berjalan pada empat viewport.

## Bukti UAT real case sintetis

- Dataset berlabel `UAT-REAL-CASE-2026-08`; tidak memakai data inspeksi produksi.
- Multi-container mempertahankan Job `in_progress` ketika Container A masih
  draft dan Container B masih assigned.
- Alur revision menyimpan snapshot request/response, dua item revision (Foto dan
  Temuan), deep-link target, resubmit, dan hasil approved.
- Skenario reject menghasilkan Survey `rejected` dan Job
  `completed_with_rejection`.
- Cross-assignment/customer access menghasilkan respons aman 404 agar keberadaan
  Survey tidak bocor.
- Foto umum dan foto Temuan berhasil diunggah dan dibaca secara private untuk
  varian original serta watermark.
- Soft-delete membuat dua queue, restore membatalkan dua queue, soft-delete
  ulang diproses Worker, lalu kedua object hilang dari MinIO.
- Rekonsiliasi bucket lifecycle menghasilkan `objects=4`, `active_db_keys=4`,
  `missing=0`, dan `orphans=0`.
- Audit login, start/open/submit/resubmit Survey, upload foto, start review,
  need revision, approve, dan reject tersedia.

Bucket/prefix workflow final adalah `gift-survey-uat-real-case-d` dan
`uat/UAT-REAL-CASE-2026-08/run-d`. Bucket/prefix lifecycle adalah
`gift-survey-uat-real-case-c` dan `uat/UAT-REAL-CASE-2026-08/run-c`.

## Feature flags dan deployment

- Public verification, final PDF, public QR, dan seluruh pasangan flag
  `NEXT_PUBLIC_*` tetap `false` di `.env.example`.
- Stack production-style lokal berhasil dijalankan memakai MySQL 8.4, MinIO,
  API, worker, dan artefak Next.js standalone.
- Base commit sebelum final hardening adalah
  `58c5e50aae1c277accbff303b2e3c38c5a9a9d48`. Commit publikasi final adalah
  commit yang memuat laporan ini; gunakan riwayat Git sebagai sumber SHA agar
  laporan tidak menyimpan self-referential hash yang berubah saat di-commit.
- Hasil remote GitHub Actions pada commit publikasi perlu diperiksa sebagai
  bukti tambahan; seluruh hasil pada tabel di atas adalah bukti eksekusi lokal.
- Branch `main` remote terverifikasi belum protected. Pengaktifan required
  checks/branch protection serta commit/push adalah tindakan remote yang belum
  dilakukan pada laporan ini.

## Definition of Done

Readiness, status campuran, storage lifecycle, retry, object reconciliation,
Go/worker/MySQL/MinIO/frontend/browser CI, multi-container, approve, revision,
reject, role access, customer isolation, foto, audit log, mobile, migration,
baseline, backup, feature flags, staging, dan pemeriksaan error kritis seluruhnya
lulus pada lingkungan UAT lokal nyata dengan fixture sintetis.

Setelah commit ini dipublish, kontrol remote yang tersisa adalah memastikan
GitHub Actions pada commit tersebut lulus dan mengaktifkan branch protection
`main` dengan required checks yang disepakati tim.
