# Hasil Implementasi Customer Onboarding dan Survey Sheet

Tanggal hasil: 3 September 2026
Branch: `codex/redesign-surveyor-survey-sheet`
Baseline: `7eafd6e feat: integrate survey sheet data flow`

## Ringkasan hasil

Alur Customer -> Job/SPK -> Peti Kemas -> Assignment -> Survey -> Review -> Report telah disambungkan tanpa endpoint paralel dan tanpa rebuild database. Customer baru sekarang langsung masuk Setup Customer, istilah evidence pada sisi Admin dibedakan dari foto aktual Surveyor, Job yang belum memenuhi readiness menyediakan CTA perbaikan, provenance awal-versus-verifikasi mempunyai aturan mismatch, dan Report membaca checklist serta histori keputusan Reviewer dari transaksi yang sama.

## Files changed

### Customer onboarding dan konfigurasi Admin

- `apps/web/app/master/customers/create/page.tsx`
- `apps/web/app/master/customers/customer/[customerId]/page.tsx`
- `apps/web/app/master/inspection-references/page.tsx`
- `apps/web/components/master/customer-detail-workspace.tsx`
- `apps/web/components/master/customer-readiness.tsx`
- `apps/web/components/master/customer-scoped-master-data.tsx`
- `apps/web/components/master/customer-setup-stepper.tsx`
- `apps/web/components/master/customer-setup-tabs.ts`
- `apps/web/components/master/master-data-page.tsx`
- `apps/web/components/master/survey-sheet-configuration.tsx`

### Job, Surveyor, Reviewer, dan Report

- `apps/web/app/jobs/create/page.tsx`
- `apps/web/app/jobs/[id]/page.tsx`
- `apps/web/app/surveyor/surveys/[id]/page.tsx`
- `apps/web/app/review/[id]/page.tsx`
- `apps/web/app/reports/[id]/page.tsx`
- `apps/web/types/reviews.ts`
- `services/api/internal/jobs/repository.go`
- `services/api/internal/surveyor/helpers.go`
- `services/api/internal/surveyor/helpers_regression_test.go`
- `services/api/internal/surveyor/repository.go`
- `services/api/internal/reviews/repository.go`

### Test dan UAT fixture

- `apps/web/e2e/customer-survey-sheet-final.spec.ts`
- `apps/web/e2e/operational-workflow.spec.ts`
- `apps/web/scripts/check-interactive-survey-sheet.mjs`
- `services/api/cmd/uat-real-case/domain.go`
- `services/api/cmd/uat-real-case/main.go`
- `scripts/uat/seed-real-case.ps1`
- `infra/docker/docker-compose.yml`
- `docs/AUDIT_CUSTOMER_SURVEY_SHEET_ONBOARDING.md`
- `docs/CUSTOMER_SURVEY_SHEET_ONBOARDING_RESULT.md`

`apps/web/next-env.d.ts`, `apps/web/components/reports/report-version-history.tsx`, backup database, dan dokumen lain yang sudah dirty/untracked sebelum pekerjaan ini tidak termasuk perubahan implementasi ini dan tidak dihapus.

## Routes changed

- `/master/customers/create`: menjadi entry point onboarding dengan CTA `Simpan & Lanjut`.
- `/master/customers/customer/[customerId]`: memakai sumber definisi tab yang aman untuk Server Component dan Client Component.
- `/master/inspection-references` dan Setup Customer: istilah Admin menjadi `Kebutuhan Foto / Evidence`.
- `/jobs/create`: hard gate readiness menampilkan missing checks dan CTA `Lengkapi Customer`.
- `/jobs/[id]`: langkah Assignment menampilkan CTA readiness dan menerima container baru berstatus `unassigned` melalui kontrak backend yang konsisten.
- `/surveyor/surveys/[id]`: provenance Data Awal dan Hasil Verifikasi menampilkan mismatch serta mewajibkan Catatan Verifikasi.
- `/review/[id]`: Reviewer melihat mismatch dan catatan Surveyor secara read-only.
- `/reports/[id]`: Report menampilkan checklist, mismatch, Temuan, evidence, dan histori keputusan Reviewer.

Tidak ada route baru yang diperlukan.

## Routes dan endpoint reused

- `POST /master/customers`, `GET/PUT /master/customers/:id`
- Customer Location, Personnel, Location-PIC mapping, Survey Type, Container Type, reference-options, effective CEDEX, dan readiness endpoints existing
- `POST /jobs`, `POST /jobs/:id/containers`, `POST /jobs/:id/assign`
- `POST /surveys/start`, general info, checklist response, damage/finding, photo/evidence, submit, dan resubmit endpoints existing
- Review detail, Need Revision, Approve, dan Reject endpoints existing
- `GET /reports/:id` dan `GET /reports/:id/versions`

Tidak ada business logic paralel. Perubahan backend hanya memperketat atau melengkapi kontrak endpoint existing:

- general info Survey menerima Condition canonical `DMG`/`AVL`/`AR`, Cleanliness `DTY`/`CTM`, dan menolak mismatch Cargo/CSC tanpa catatan;
- audit after-state general info sekarang menyimpan nilai awal, hasil verifikasi, Condition, Cleanliness, tanggal, dan catatan;
- Assignment menerima status awal container existing `unassigned`, selain status transisi yang sudah didukung;
- detail Report menambahkan query read-only checklist dan `survey_approvals`.

## DB migration

Tidak ada migration baru. Migration additive existing `0019_survey_sheet_data_flow.up.sql` sudah menyediakan snapshot header dan `cleanliness`; migration tersebut sekarang juga dipasang pada bootstrap Docker/UAT agar runtime konsisten dengan source. UAT menggunakan database terisolasi `kontainer_customer_sheet_uat`; tidak ada reset, clean, atau operasi database destruktif.

## Customer onboarding result

- Setelah `POST /master/customers` berhasil dan `row.id` tersedia, aplikasi menjalankan `router.replace(/master/customers/customer/{id}?tab=location-pic)`.
- User tidak kembali ke daftar Customer.
- Setup Customer tetap memuat Profil, Lokasi & PIC, Konfigurasi Survey Sheet, Checklist, Referensi, Kebutuhan Foto/Evidence, CEDEX, dan Kesiapan.
- Readiness Location & PIC tetap bersumber dari Location aktif, PIC aktif, dan mapping aktif melalui kontrak backend existing.

## Survey prefill result

- Start Survey tetap membentuk snapshot administratif dari Customer, Job, Location, Survey Type, dan Job Container melalui alur existing.
- Surveyor membaca Customer, container number/type/size, manufacture date, gross/tare/payload, Cargo initial, CSC initial/detail, Job/SPK, serta lokasi tanpa input ulang.
- Condition dan Cleanliness tetap dimiliki Surveyor.
- Cargo Status dan CSC dibedakan menjadi Data Awal Admin dan Hasil Verifikasi Surveyor. Jika dua nilai known berbeda, Catatan Verifikasi wajib dan nilai lengkap masuk audit after-state.

## Evidence result

- Area Admin memakai istilah `Kebutuhan Foto / Evidence` dan hanya mengatur kategori/requirement.
- Foto aktual tetap di-upload Surveyor ke `survey_photos`: general photo memakai `damage_id = NULL`, sedangkan finding photo terkait ke Finding.
- Reviewer dan Report membaca object reference yang sama; tidak ada upload ulang.

## CEDEX result

- CRUD, active/inactive, pencarian, filter, pagination, permission, dan audit Master CEDEX existing dipertahankan.
- Finding tetap memilih effective master dari Customer override aktif, kemudian Global fallback aktif.
- `finding_description` tetap dibentuk backend dari CEDEX, dimension, dan quantity; remark tetap terpisah.
- Surveyor tidak diberi akses CRUD Global CEDEX dan tetap memakai alur proposal jika kode belum tersedia.

## Reviewer result

- Reviewer tetap hanya menjalankan Need Revision, Approve, atau Reject.
- Header, checklist, Survey Sheet, Finding, evidence, recommendation, dan provenance dibaca dari Survey yang sama.
- Target revisi tetap menunjuk entitas/item spesifik dan hasil UAT membuktikan siklus Need Revision -> perbaikan Surveyor -> Resubmit -> Approve.

## Report result

- Header memakai snapshot Survey.
- Checklist memakai `survey_checklist_responses`.
- Temuan memakai `survey_damages` dan evidence memakai `survey_photos`.
- Keputusan Reviewer memakai histori `survey_approvals`, termasuk siklus revisi dan keputusan akhir.
- Tidak ada form administratif, upload evidence, atau keputusan Reviewer baru pada Report.

## Tests

### Pemeriksaan source dan build

| Perintah | Hasil |
|---|---|
| `npm run lint --workspace apps/web` | PASS, exit 0 |
| `npm run test:navigation --workspace apps/web` | PASS |
| `npm run test:iso-cedex --workspace apps/web` | PASS |
| `npm run test:survey-sheet --workspace apps/web` | PASS |
| `npm run typecheck --workspace apps/web` | PASS |
| `npm run build --workspace apps/web` | PASS, 76/76 halaman statis dihasilkan |
| `go test ./...` | PASS |
| `go vet ./...` | PASS |
| `git diff --check` | PASS; hanya warning konversi LF/CRLF dari konfigurasi Git Windows |

### Browser UAT dan integritas transaksi

Browser UAT dijalankan dengan Playwright memakai Microsoft Edge pada stack lokal terisolasi. Kontrol browser dalam aplikasi sempat tidak dapat di-bootstrap karena error metadata sandbox, sehingga verifikasi dilanjutkan dengan runner Playwright repository yang menghasilkan assertion dan trace standar.

- Suite final `customer-survey-sheet-final.spec.ts`: **3/3 PASS**.
  - create Customer dan redirect langsung ke Lokasi & PIC;
  - konfigurasi Customer Ready, pembuatan Job, tambah Peti Kemas, dan Assignment;
  - Report membaca checklist, Temuan, Foto/Evidence, serta keputusan Reviewer.
- UAT operasional existing mengeksekusi multi-role Surveyor/Reviewer untuk Start Container A, memastikan Container B tidak ikut mulai, prefill, Condition/Cleanliness, checklist, Finding CEDEX, evidence, Submit, Need Revision, revisi bertarget, Resubmit, Approve, Reject, role boundary, dan responsive desktop. Tiga skenario selesai PASS; satu assertion URL lama gagal setelah aksi Approve berhasil karena aplikasi memakai `/review?view=history`. Assertion route sudah menerima kedua bentuk route yang valid.
- Verifikasi database/storage mode `Finalize`: **24/24 PASS**, termasuk revision history dan snapshot, multi-container state, approve/reject state, workflow audit, role boundary, active file references, customer isolation structure, dan deletion queue health. Endpoint MinIO juga reachable.

Data sintetis UAT dan database terisolasi dipertahankan untuk evidence karena spesifikasi melarang operasi destructive DB. API dan web server sementara yang dijalankan untuk UAT sudah dihentikan setelah pengujian.

## Known gaps

- `MGM`, `TCT`, `3rd Scty Sys`, dan `Cu-Cap` tetap `Domain gap`; source, datatype, dan owner belum dikonfirmasi sehingga tidak diimplementasikan atau ditebak.
- PDF final, QR publik, dan verifikasi publik tetap mengikuti feature flag existing dan tidak termasuk scope perbaikan ini.
- UAT operasional penuh tidak di-reset dan dijalankan ulang setelah koreksi assertion URL, karena reset/destructive DB dilarang. Aksi workflow sudah terjadi dan hasil akhirnya dibuktikan oleh 24/24 pemeriksaan transaksi.
- Tidak ada commit atau push yang dilakukan sesuai instruksi spesifikasi.
