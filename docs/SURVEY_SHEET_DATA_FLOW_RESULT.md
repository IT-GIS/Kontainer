# Hasil Implementasi Survey Sheet Data Flow

Tanggal hasil: 2 September 2026
Repository: `IT-GIS/Kontainer`
Branch/HEAD: `codex/redesign-surveyor-survey-sheet` / `29c755d`

## Ringkasan hasil

Integrasi data Survey Sheet sudah disambungkan dari Customer, Job/SPK, Peti Kemas, Master Pemeriksaan, dan Master CEDEX ke Surveyor, Reviewer, lalu Report. Setiap field administratif tetap mempunyai satu sumber editable. Survey menyimpan snapshot transaksi saat Start Survey; Reviewer dan Report membaca snapshot yang sama.

Master CEDEX tetap menjadi kamus teknis. Effective master tetap memprioritaskan override Customer aktif per kode dan memakai Global fallback bila override tidak tersedia. Implementasi tidak menyalin seluruh master Global ke Customer dan tidak membuat endpoint duplikat.

Field `MGM`, `TCT`, `3rd Scty Sys`, dan `Cu-Cap` tidak ditebak. Keempatnya tetap berstatus `DOMAIN GAP`.

## Files changed

### Frontend dan navigasi

- `apps/web/constants/navigation-admin.ts`
  - Menempatkan route Master CEDEX dan Master Pemeriksaan di workspace `Customer & Master` tanpa menghapus route lama.
- `apps/web/components/master/customer-readiness.tsx`
  - Menambahkan landing tiga entry point: Customer, Master CEDEX, dan Master Pemeriksaan.
  - Menampilkan jumlah mapping Location-PIC dan sumber CEDEX efektif.
- `apps/web/components/master/customer-setup-stepper.tsx`
  - Menjadi delapan tahap: Profil, Lokasi & PIC, Konfigurasi Survey Sheet, Checklist, Referensi Pemeriksaan, Foto / Evidence, Konfigurasi CEDEX Customer, dan Kesiapan.
- `apps/web/app/master/customers/customer/[customerId]/page.tsx`
  - Menambahkan routing step/subsection Konfigurasi Survey Sheet dan compatibility mapping untuk query lama.
- `apps/web/components/master/customer-detail-workspace.tsx`
  - Menghubungkan step baru, sumber CEDEX efektif, jumlah master aktif, dan next action readiness.
- `apps/web/components/master/survey-sheet-configuration.tsx` (baru)
  - Pusat konfigurasi yang membaca endpoint Customer existing dan menjelaskan sumber/ownership tanpa membuat salinan editable.
- `apps/web/components/ui/survey-sheet-field-source-badge.tsx` (baru)
  - Badge `Customer`, `Job`, `Peti Kemas`, `Sistem`, `Surveyor`, dan `Master CEDEX`.
- `apps/web/app/master/iso-cedex/page.tsx`
  - Memperjelas Master CEDEX sebagai bagian dari `Customer & Master`; `IsoCedexWorkspace` dan compatibility route tetap dipertahankan.
- `apps/web/app/master/inspection-references/page.tsx`
  - Memperjelas halaman sebagai Master Pemeriksaan untuk Survey Type, Container Type, Checklist, referensi/rule, dan Foto / Evidence.
- `apps/web/app/jobs/[id]/page.tsx`
  - Mempertahankan label canonical `CSC Program Type` dan menghapus placeholder yang dapat disalahartikan sebagai keputusan bahwa ACEP selalu sama dengan program CSC.
- `apps/web/app/surveyor/surveys/[id]/page.tsx`
  - Header Survey Sheet lengkap dengan provenance, field terkunci, data awal Admin, dan hasil verifikasi Surveyor.
  - `Date of Survey` menggunakan `surveys.started_at`, bukan Job/SPK/due date.
  - Cargo menampilkan mapping `empty -> MTY` dan `laden -> FULL` tanpa mengubah canonical backend.
  - Condition hanya menawarkan `DMG/AVL/AR`; Cleanliness memakai field dedicated `DTY/CTM`.
  - General Remark tetap terpisah dan tidak dipakai untuk Cleanliness.
- `apps/web/app/review/[id]/page.tsx`
  - Reviewer melihat header/provenance, data awal vs verifikasi, diagram Survey Sheet read-only, checklist, Finding, foto, dan riwayat keputusan/revisi.
- `apps/web/app/reports/[id]/page.tsx`
  - Report membaca header snapshot, hasil verifikasi, Finding, foto, dan keputusan existing tanpa form input ulang.
- `apps/web/app/globals.css`
  - Styling landing, konfigurasi, source badge, dan header yang responsif.
- `apps/web/types/surveyor.ts`, `apps/web/types/reviews.ts`
  - Memperluas kontrak header snapshot dan hasil verifikasi.
- `apps/web/scripts/check-interactive-survey-sheet.mjs`
  - Menambah contract check untuk konfigurasi, source badge, snapshot, Reviewer, Report, readiness, dan domain gap.

### Backend

- `services/api/internal/masterdata/customer_readiness.go`
  - Response readiness menambahkan `location_pic_mapping_count`, `cedex_override_count`, `cedex_source`, dan check `location_pic_mapping`.
- `services/api/internal/masterdata/readiness_gate.go`
  - Hard gate internal menambahkan missing code actionable `LOCATION_PIC_MAPPING` dengan join Location dan PIC aktif.
- `services/api/internal/masterdata/customer_readiness_test.go` (baru)
  - Menguji mapping Location-PIC dan sumber effective CEDEX.
- `services/api/internal/surveyor/helpers.go`
  - `SurveyDetail` membawa seluruh header dari snapshot dengan fallback source existing.
  - Submit gate memvalidasi header wajib, Condition canonical, dan Cleanliness canonical.
- `services/api/internal/surveyor/models.go`
  - Menambahkan `cleanliness` pada input General Info.
- `services/api/internal/surveyor/repository.go`
  - Start Survey membuat snapshot Customer, Job/SPK, Location, Survey Type, Container Type/Size, manufacture, weight, cargo awal, dan data CSC.
  - General Info menyimpan Condition/Cleanliness hasil Surveyor secara terpisah serta tetap melalui audit existing.
- `services/api/internal/surveyor/survey_list_test.go`, `helpers_regression_test.go`
  - Menguji kode canonical dan kontrak query snapshot.
- `services/api/internal/reviews/helpers.go`, `repository.go`
  - Reviewer dan Report membaca snapshot header yang sama.
  - Reviewer menerima marker Survey Sheet; Report menerima Finding dan metadata foto existing.

### Database

- `services/api/migrations/0019_survey_sheet_data_flow.up.sql` (baru)
- `services/api/migrations/0019_survey_sheet_data_flow.down.sql` (baru, hanya untuk rollback terkontrol)
- `database/patches/0025_survey_sheet_data_flow.sql` (baru)
- `database/kontainer_db.sql`

Upgrade migration hanya menambah kolom pada `survey_general_infos` dan melakukan backfill dari source current untuk Survey lama:

- snapshot Customer, Location, Survey Type, Job/SPK, Container Type, dan Size;
- `manufacture_date`, `gross_weight`, `tare_weight`, `payload`;
- `cargo_status_initial`;
- `csc_plate_status_initial`, CSC number/reference/dates/program;
- `cleanliness`.

Migration tidak dijalankan pada database lokal/live selama implementasi ini. Tidak ada `DROP`, `TRUNCATE`, mass delete, reset, atau perubahan data destruktif yang dieksekusi.

## Endpoints reused

- Customer/readiness: `/customers/readiness`, `/customers/:id/readiness`.
- Customer configuration: `/customers/:id/survey-types`, `/customers/:id/container-types`, `/customers/:id/locations`, endpoint checklist/reference/photo mapping existing.
- Master CEDEX: route master existing dan `/surveys/:id/master-options`.
- Job/Container/Assignment: endpoint existing di `/jobs`.
- Survey: `/surveys/:id/preview`, `/surveys/:id/general-info`, checklist, damage, dan photo endpoints existing.
- Review: `/reviews/:id` dan action Start/Need Revision/Approve/Reject existing.
- Report: `/reports/:id` dan `/reports/:id/versions` existing.

Tidak ada endpoint baru. Kontrak response/input existing diperluas secara additive:

- readiness memuat mapping Location-PIC dan provenance CEDEX;
- preview Survey memuat header snapshot lengkap;
- General Info menerima `cleanliness`;
- Review memuat header dan location snapshot Finding;
- Report memuat header, Finding, dan metadata foto.

## Final field mapping

| Field | Source final | Surveyor | Reviewer | Report | Hasil |
|---|---|---|---|---|---|
| Customer | Customer snapshot | Auto/read-only | Read-only | Display | PASS |
| Container Number | Job Container snapshot | Auto/read-only | Read-only | Display | PASS |
| Survey Type | Customer config dipilih di Job | Auto/read-only | Read-only | Display | PASS |
| Size / Type | Container Type per unit | Auto/read-only | Read-only | Display | PASS |
| Manufacture | Job Container per unit | Auto/read-only | Read-only | Display | PASS |
| Cargo Status | Job Container initial + Surveyor verification | Auto + verify | Bandingkan read-only | Display keduanya | PASS |
| CSC | Job Container initial + Surveyor status verification | Auto + verify | Bandingkan read-only | Display keduanya | PASS |
| Condition | `survey_general_infos.general_condition` | `DMG/AVL/AR` | Read-only | Display | PASS |
| Cleanliness | `survey_general_infos.cleanliness` | `DTY/CTM` | Read-only | Display | PASS |
| Payload / Tare | Job Container snapshot per unit | Auto/read-only | Read-only | Display | PASS |
| Survey Location | Job snapshot | Auto/read-only | Read-only | Display | PASS |
| Date of Survey | `surveys.started_at` | Auto/read-only | Read-only | Display | PASS |
| CEDEX Finding | Effective Master + Finding snapshot | Pilih dari master | Read-only | Display | PASS |
| MGM | Belum disahkan | Tidak ditebak | Tidak ditebak | Tidak ditebak | DOMAIN GAP |
| TCT | Belum disahkan | Tidak ditebak | Tidak ditebak | Tidak ditebak | DOMAIN GAP |
| 3rd Scty Sys | Belum disahkan | Tidak ditebak | Tidak ditebak | Tidak ditebak | DOMAIN GAP |
| Cu-Cap | Belum disahkan | Tidak ditebak | Tidak ditebak | Tidak ditebak | DOMAIN GAP |
| ACEP label | Belum disahkan; data canonical tetap `CSC Program Type` | Read-only/verifikasi status CSC | Read-only | Display canonical | DOMAIN GAP label |

## Readiness changes

Readiness Customer sekarang memerlukan:

- Customer profile aktif dan lengkap;
- Location aktif;
- PIC aktif;
- relasi Location-PIC yang keduanya masih aktif;
- Survey Type dan Container Type aktif;
- Checklist template/item;
- referensi dan photo mapping;
- effective CEDEX dan responsibility.

Job creation tetap memvalidasi PIC spesifik benar-benar terpetakan ke Location yang dipilih. Hard gate readiness yang dipakai Job, Assignment, dan Start Survey sekarang juga menolak Customer yang sama sekali tidak mempunyai mapping aktif.

## Tests

| Perintah | Hasil |
|---|---|
| `npm run lint` (`apps/web`) | PASS |
| `npm run test:navigation` (`apps/web`) | PASS |
| `npm run test:iso-cedex` (`apps/web`) | PASS |
| `npm run test:survey-sheet` (`apps/web`) | PASS |
| `npm run typecheck` (`apps/web`) | PASS |
| `npm run build` (`apps/web`) | PASS, 76 route dibangun |
| `go test ./...` (`services/api`) | PASS |
| `go vet ./...` (`services/api`) | PASS |
| `git diff --check` | PASS; hanya warning line-ending Windows |
| `npm run test:e2e:smoke` dengan Microsoft Edge | PASS pada rerun: 6/6 viewport, 360/390/412/768/1366/1920 |

Percobaan Playwright pertama menghasilkan 2 desktop PASS dan 4 timeout pada `page.goto` selama cold start server Next.js. Tidak ada assertion layout yang gagal. Setelah cache/server build hangat, rerun lulus 6/6 dalam 33,3 detik.

## E2E result

- Responsive login smoke: `PASS` pada enam viewport.
- Authenticated/mutative operational UAT: `SKIPPED_FIXTURE_MISSING`.
- Environment `E2E_OPERATIONAL=1`, ID fixture Job/Survey/Container, URL server UAT, dan credential empat role tidak tersedia pada sesi ini.
- Karena suite operasional mengubah status workflow dan upload file, suite tidak diaktifkan terhadap database yang tidak secara eksplisit disiapkan sebagai database `_uat`.
- Dengan demikian implementasi tidak mengklaim keberhasilan Admin onboarding, assignment, authenticated Surveyor prefill, Need Revision/Resubmit/Approve, atau Customer isolation secara live. Jalankan `scripts/uat/seed-real-case.ps1`, isi environment pada `apps/web/e2e/README.md`, lalu jalankan `npm run test:e2e:operational` pada environment UAT.

## Known domain gaps and deployment notes

- `MGM`, `TCT`, `3rd Scty Sys`, `Cu-Cap`: definisi/type/source/owner belum disahkan.
- `ACEP`: belum dijadikan label final; UI menggunakan `CSC Program Type`.
- Field CSC verification saat ini memisahkan status awal dan status hasil Surveyor. Kontrak mismatch detail/catatan khusus belum ditambah karena belum ada rule resmi yang mewajibkannya.
- Tare, Payload, Manufacture, CSC Number, dan CSC Program bersifat informasi opsional bila source tidak tersedia. UI menampilkan `Belum tersedia` dan meminta koreksi Admin; submit gate tidak membuatnya mandatory tanpa rule resmi.
- Migration `0019`/patch `0025` harus diterapkan lebih dahulu pada environment target sebelum API versi ini dijalankan.
- Tidak ada commit atau push yang dilakukan.
- Perubahan pengguna yang sudah ada, termasuk `apps/web/next-env.d.ts`, `apps/web/components/reports/report-version-history.tsx`, backup database, dan dokumen lain, tidak disentuh atau dimasukkan sebagai bagian implementasi ini.
