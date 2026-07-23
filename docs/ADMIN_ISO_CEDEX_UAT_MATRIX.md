# UAT Matrix Admin ISO CEDEX

Tanggal: 23 Juli 2026 (Asia/Jakarta)
Commit yang diaudit: `af1ec4c3ded3b3ff8b81d3214478e90011b8587e`
Baseline commit: `9ea105f2b43fdf89aa24c9a2257d73e2585c2531`

## Definisi status

| Status | Arti |
|---|---|
| `PASS` | Expected result terbukti melalui endpoint/command dan, bila relevan, bukti layar |
| `FAIL` | Perilaku terbukti tidak memenuhi expected result |
| `BLOCKED` | Tidak dapat dibuktikan karena dependency/tooling tidak tersedia |
| `NOT_APPLICABLE` | Sengaja tidak dijalankan karena berada di luar batas aman UAT |

## Runtime dan data UAT

- Database: Laragon MySQL `kontainer_db`.
- API UAT fresh: `http://127.0.0.1:8081/api/v1`.
- Web: `http://localhost:3000`.
- Browser fallback: Microsoft Edge headless dengan profil sementara dan Chrome DevTools Protocol.
- Suite CRUD utama: `UAT-ISO-CEDEX-20260723115019`.
- Suite Approve/Reject: `UAT-ISO-CEDEX-20260723112314`.
- Suite import: `UAT-ISO-CEDEX-20260723114335-IMPORT`.
- Suite Damage: `UAT-ISO-CEDEX-20260723115158-DAMAGE`.
- Seluruh record master Customer A/B pada suite utama diinaktifkan setelah UAT.
- Job, assignment, survey, dan report yang tidak memiliki delete flow dibiarkan dengan ID terdokumentasi.

Hasil agregat:

- suite CRUD utama: 76/76 `PASS`;
- suite survey/review lanjutan: 18/18 `PASS`;
- canonical tabs: 12/12 `PASS`;
- compatibility routes: 18/18 `PASS`;
- screenshot baru: 20 PNG;
- satu `FAIL` aksesibilitas untuk filter tanpa accessible name;
- dua blocker tooling/dependency utama: audit contrast penuh dan upload foto karena MinIO tidak aktif.

## Matriks

| ID | Area / scenario | Status | Actual result | Endpoint/status atau command | Screenshot | Issue |
|---|---|---|---|---|---|---|
| GIT-01 | HEAD terhadap target | PASS | HEAD sama dengan commit target | `git rev-parse HEAD` -> `af1ec4c3...` | N/A | - |
| GIT-02 | Baseline parent | PASS | Parent target sama dengan baseline | `git rev-parse af1ec4c3^` -> `9ea105f2...` | N/A | - |
| GIT-03 | Remote main | PASS | Remote main masih menunjuk target | `git ls-remote origin refs/heads/main` -> `af1ec4c3...` | N/A | - |
| GIT-04 | Scope commit | PASS | 64 file; 3.014 insertions; 774 deletions | `git diff --name-status/--stat 9ea105f2 af1ec4c3` | N/A | - |
| GIT-05 | Backend/DB dalam target | PASS | Tidak ada file backend, migration, schema, seed, permission | Path audit 64 file | N/A | - |
| GIT-06 | Drift lokal Surveyor | PASS | `navigation-surveyor.ts` tidak berubah pada commit; perubahan lokal dipertahankan | Hash baseline=target; `git status --short` | [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | Drift pasca-commit, bukan bug target |
| NAV-01 | Sidebar Admin canonical | PASS | Sidebar merender dan active item tunggal | Edge CDP `/dashboard`; `activeNavCount=1` | [01](screenshots/admin-iso-cedex-audit/01-admin-dashboard-1366.png) | - |
| NAV-02 | Enam tab ISO CEDEX | PASS | 6/6 URL, label tab, active tab, active sidebar benar | `canonical-tab-retest.json`; 6/6 | [02](screenshots/admin-iso-cedex-audit/02-iso-location-1920.png), [03](screenshots/admin-iso-cedex-audit/03-iso-component-1366.png), [04](screenshots/admin-iso-cedex-audit/04-iso-action-repair-1024.png) | - |
| NAV-03 | Enam Referensi Pemeriksaan | PASS | 6/6 URL, label tab, active tab, active sidebar benar | `canonical-tab-retest.json`; 6/6 | [05](screenshots/admin-iso-cedex-audit/05-reference-container-type-1366.png), [06](screenshots/admin-iso-cedex-audit/06-reference-checklist-1024.png) | - |
| NAV-04 | Seluruh compatibility route | PASS | 18/18 redirect ke canonical URL tepat | `browser-uat-results.json`; 18/18 | [15](screenshots/admin-iso-cedex-audit/15-survey-monitoring-admin-1366.png) | - |
| NAV-05 | Active state compatibility | PASS | Redirect menghasilkan satu sidebar item aktif | Edge DOM `activeNavCount=1` | [15](screenshots/admin-iso-cedex-audit/15-survey-monitoring-admin-1366.png) | - |
| NAV-06 | Browser back | PASS | Kembali ke `/master/iso-cedex?tab=component` | CDP `history.back()` | [03](screenshots/admin-iso-cedex-audit/03-iso-component-1366.png) | - |
| NAV-07 | Browser forward | PASS | Maju ke `/master/inspection-references?tab=survey-type` | CDP `history.forward()` | [05](screenshots/admin-iso-cedex-audit/05-reference-container-type-1366.png) | - |
| NAV-08 | Refresh | PASS | URL/query tab tetap setelah hard reload | CDP `Page.reload(ignoreCache=true)` | [05](screenshots/admin-iso-cedex-audit/05-reference-container-type-1366.png) | - |
| NAV-09 | Supervisor menu | PASS | Hanya `Review & Keputusan` dan `Dokumen & Laporan` | Login Supervisor; DOM navigation | [16](screenshots/admin-iso-cedex-audit/16-review-pending-supervisor-1024.png), [17](screenshots/admin-iso-cedex-audit/17-review-history-supervisor-1366.png) | - |
| NAV-10 | Management menu | PASS | Dashboard, Dokumen & Laporan, Rekap Customer | Login Management; DOM navigation | [18](screenshots/admin-iso-cedex-audit/18-reports-management-1366.png) | - |
| NAV-11 | Surveyor menu | PASS | Dashboard Surveyor, Pekerjaan Saya, Perlu Revisi, Riwayat Pemeriksaan | Login Surveyor; DOM navigation | [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | Menampilkan drift lokal pasca-commit |
| CUST-01 | Create Customer A/B | PASS | HTTP 201/201; dua ID unik | `POST /master/customers`; prefix `...115019` | [07](screenshots/admin-iso-cedex-audit/07-customer-profile-1366.png) | - |
| CUST-02 | Customer Profile | PASS | Detail Customer merender profil dan status | `GET /master/customers/:id` HTTP 200 | [07](screenshots/admin-iso-cedex-audit/07-customer-profile-1366.png) | - |
| CUST-03 | Customer Personel/PIC | PASS | CRUD A/B, duplicate 409, isolation, inactive persistence 200 | `/customers/:id/personnel` 201/409/200 | [08](screenshots/admin-iso-cedex-audit/08-customer-personnel-1024.png) | - |
| CUST-04 | Customer Location | PASS | CRUD A/B, duplicate 409, isolation, inactive persistence 200 | `/customers/:id/locations` 201/409/200 | [09](screenshots/admin-iso-cedex-audit/09-customer-location-768.png) | - |
| CUST-05 | Customer History | PASS | Hanya job dengan `customer_id` yang sama ditampilkan | `GET /jobs?customer_id=:id` HTTP 200 + client filter | [10](screenshots/admin-iso-cedex-audit/10-customer-history-1366.png) | - |
| CRUD-01 | Container Type | PASS | Create A/B 201, duplicate A 409, isolation, inactive 200 | `/customers/:id/container-types` | [05](screenshots/admin-iso-cedex-audit/05-reference-container-type-1366.png) | - |
| CRUD-02 | Survey Type | PASS | Create A/B 201, duplicate A 409, isolation, inactive 200 | `/customers/:id/survey-types` | [05](screenshots/admin-iso-cedex-audit/05-reference-container-type-1366.png) | - |
| CRUD-03 | CEDEX Location | PASS | Create A/B 201, duplicate A 409, isolation, inactive 200 | `/customers/:id/cedex/locations` | [02](screenshots/admin-iso-cedex-audit/02-iso-location-1920.png) | - |
| CRUD-04 | CEDEX Component | PASS | Create A/B 201, duplicate A 409, isolation, inactive 200 | `/customers/:id/cedex/components` | [03](screenshots/admin-iso-cedex-audit/03-iso-component-1366.png) | - |
| CRUD-05 | CEDEX Damage | PASS | Create A/B 201, duplicate A 409, isolation, inactive 200 | `/customers/:id/cedex/damages` | [03](screenshots/admin-iso-cedex-audit/03-iso-component-1366.png) | - |
| CRUD-06 | Action Repair | PASS | Create A/B 201, duplicate A 409, isolation, inactive 200 | `/customers/:id/cedex/repairs` | [04](screenshots/admin-iso-cedex-audit/04-iso-action-repair-1024.png) | - |
| CRUD-07 | CEDEX Material | PASS | Create A/B 201, duplicate A 409, isolation, inactive 200 | `/customers/:id/cedex/materials` | [04](screenshots/admin-iso-cedex-audit/04-iso-action-repair-1024.png) | - |
| CRUD-08 | Responsibility Code | PASS | Create A/B 201, duplicate A 409, isolation, inactive 200 | `/customers/:id/responsibility-codes` | [04](screenshots/admin-iso-cedex-audit/04-iso-action-repair-1024.png) | - |
| CRUD-09 | Checklist Template | PASS | Draft template 201, item 201, inactive persistence 200 | `/customers/:id/checklist-templates`; `/fitness/master-data/checklist-templates/:id/items` | [06](screenshots/admin-iso-cedex-audit/06-reference-checklist-1024.png) | Active template wajib punya item; payload UAT dikoreksi ke `draft` |
| CRUD-10 | Test Parameter | PASS | Create 201, edit/inactive 200, duplicate 409 | `/fitness/master-data/test-parameters` | [06](screenshots/admin-iso-cedex-audit/06-reference-checklist-1024.png) | - |
| CRUD-11 | Photo Category | PASS | Create 201, edit/inactive 200, duplicate 409 | `/fitness/master-data/photo-categories`; `applies_to=inspection` | [06](screenshots/admin-iso-cedex-audit/06-reference-checklist-1024.png) | `general` bukan enum valid; payload UAT diperbaiki |
| CRUD-12 | Finding Severity | PASS | Create 201, edit/inactive 200, duplicate 409 | `/fitness/master-data/finding-severities` | [06](screenshots/admin-iso-cedex-audit/06-reference-checklist-1024.png) | - |
| SEC-01 | Customer A/B list isolation | PASS | Setiap list A hanya berisi record A dan sebaliknya | 10 pasangan `GET /customers/:id/...` HTTP 200 | N/A — bukti API | - |
| SEC-02 | Duplicate pada Customer sama | PASS | Seluruh resource customer-scoped menolak duplicate dengan HTTP 409 | 10 `POST /customers/:id/...` | N/A — bukti API | - |
| SEC-03 | Kode sama pada Customer berbeda | PASS | Customer B menerima kode yang sama dengan HTTP 201 | 10 `POST /customers/:B/...` | N/A — bukti API | - |
| SEC-04 | URL/body customer tampering | PASS | `customer_id=B` pada route A disimpan sebagai A | `POST /customers/:A/cedex/components` HTTP 201 | N/A — bukti API | Route parameter authoritative |
| SEC-05 | Cross-customer edit | PASS | Record B melalui route A ditolak | `PUT /customers/:A/cedex/components/:BRecord` HTTP 404 | N/A — bukti API | - |
| SEC-06 | Cross-customer Job reference | PASS | Location B pada Job A ditolak | `POST /jobs` HTTP 422 | N/A — bukti API | - |
| SEC-07 | Management mutation master data | PASS | Backend menolak create | `POST /customers/:id/cedex/components` HTTP 403 | [18](screenshots/admin-iso-cedex-audit/18-reports-management-1366.png) | - |
| SEC-08 | Management mutation review | PASS | Backend menolak Need Revision | `POST /reviews/:id/need-revision` HTTP 403 | [18](screenshots/admin-iso-cedex-audit/18-reports-management-1366.png) | - |
| SEC-09 | Surveyor GIFT vs Personel/PIC | PASS | Resource dan ID tidak overlap; personnel tidak dapat di-assign | `GET /master/surveyors` 200; invalid assign 422 | [08](screenshots/admin-iso-cedex-audit/08-customer-personnel-1024.png), [14](screenshots/admin-iso-cedex-audit/14-job-detail-assignment-1024.png) | - |
| JOB-01 | Create Job | PASS | Job dibuat dengan customer-owned reference | `POST /jobs` HTTP 201 | [12](screenshots/admin-iso-cedex-audit/12-job-create-1366.png) | - |
| JOB-02 | Job list | PASS | Data job tampil dengan filter/action | `GET /jobs` HTTP 200 | [11](screenshots/admin-iso-cedex-audit/11-jobs-list-1920.png) | - |
| JOB-03 | Detail Job | PASS | Ringkasan Job dan supporting tabs merender | `GET /jobs/:id` HTTP 200 | [13](screenshots/admin-iso-cedex-audit/13-job-detail-summary-1366.png) | - |
| JOB-04 | Add Container | PASS | Setelah fix, valid container tersimpan | `POST /jobs/:id/containers` HTTP 201; ID `ef3108a3...` | [13](screenshots/admin-iso-cedex-audit/13-job-detail-summary-1366.png) | BUG-01 fixed: argumen SQL bergeser |
| JOB-05 | Import template | PASS | CSV template tersedia | `GET /job-containers/import/template?format=csv` HTTP 200; 290 byte | [11](screenshots/admin-iso-cedex-audit/11-jobs-list-1920.png) | - |
| JOB-06 | Import preview | PASS | Satu baris valid, nol gagal | `POST /jobs/e843.../containers/import/preview` HTTP 200 | [11](screenshots/admin-iso-cedex-audit/11-jobs-list-1920.png) | - |
| JOB-07 | Import confirm dan persistence | PASS | Imported=1, failed=0, record ditemukan | `POST .../confirm` 200; `GET .../containers` 200; ID `82b50221...` | [11](screenshots/admin-iso-cedex-audit/11-jobs-list-1920.png) | - |
| JOB-08 | Import duplicate | PASS | Preview kedua mendeteksi `container duplicate` | `POST .../preview` HTTP 200; valid=0, failed=1, duplicate=1 | N/A — bukti API | - |
| JOB-09 | Assignment Surveyor GIFT | PASS | Assignment tersimpan; container assigned | `POST /jobs/:id/assign` HTTP 200 | [14](screenshots/admin-iso-cedex-audit/14-job-detail-assignment-1024.png) | API contract aktual mengembalikan 200 |
| SUR-01 | Start Survey | PASS | Survey draft dan snapshot checklist dibuat | `POST /surveys/start` HTTP 201 | [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | - |
| SUR-02 | Survey master-options | PASS | Customer-scoped ISO/reference options tersedia | `GET /surveys/:id/master-options` HTTP 200 | [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | BUG-02 fixed: `ct.type_name`, `a.due_date` |
| SUR-03 | Survey checklist snapshot | PASS | Satu item snapshot tersedia | `GET /surveys/:id/checklist` HTTP 200 | [06](screenshots/admin-iso-cedex-audit/06-reference-checklist-1024.png) | BUG-02 fixed |
| SUR-04 | General Info persistence | PASS | Update tersimpan | `PUT /surveys/:id/general-info` HTTP 200 | [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | - |
| SUR-05 | Checklist response persistence | PASS | completed=1, total=1 | `PUT /surveys/:id/checklist` HTTP 200 | [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | - |
| SUR-06 | Preview submit | PASS | `can_submit=true` | `GET /surveys/:id/preview` HTTP 200 | [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | Satu warning non-blocking tetap tercatat |
| SUR-07 | Submit Survey | PASS | Status menjadi `submitted` | `POST /surveys/:id/submit` HTTP 200 | [16](screenshots/admin-iso-cedex-audit/16-review-pending-supervisor-1024.png) | - |
| SUR-08 | Damage create | PASS | Damage `D-001` dibuat setelah counter fix | `POST /surveys/829e.../damages` HTTP 201; ID `7d952d90...` | N/A — bukti API | BUG-04 fixed: counter tanpa kolom `id` |
| SUR-09 | Damage update | PASS | Remark update tersimpan | `PUT /survey-damages/7d952d90...` HTTP 200 | N/A — bukti API | - |
| SUR-10 | Damage delete | PASS | Synthetic damage di-soft-delete | `DELETE /survey-damages/7d952d90...` HTTP 200 | N/A — bukti API | - |
| SUR-11 | Photo upload | BLOCKED | HTTP 500 setelah 5,3 detik; MinIO health tidak dapat dihubungi | `POST /survey-damages/:id/photos`; `http://127.0.0.1:9000/minio/health/live` connection refused | N/A — dependency tidak aktif | Bukan bukti bug aplikasi; object storage unavailable |
| REV-01 | Need Revision | PASS | Survey menjadi `need_revision` | `POST /reviews/293e.../need-revision` HTTP 200 | [17](screenshots/admin-iso-cedex-audit/17-review-history-supervisor-1366.png) | - |
| REV-02 | Resubmit setelah revision | PASS | Survey kembali `submitted` | General/checklist/preview/submit seluruhnya HTTP 200 | [16](screenshots/admin-iso-cedex-audit/16-review-pending-supervisor-1024.png) | - |
| REV-03 | Approve | PASS | Survey `approved`; report `GIFT-RPT-2026-000001` queued | `POST /reviews/293e.../approve` HTTP 200, `generate_report=false` | [17](screenshots/admin-iso-cedex-audit/17-review-history-supervisor-1366.png) | Backend tetap auto-queue metadata report |
| REV-04 | Reject kasus terpisah | PASS | Survey `724d3aea...` menjadi `rejected` | `POST /reviews/724d.../reject` HTTP 200 | [17](screenshots/admin-iso-cedex-audit/17-review-history-supervisor-1366.png) | - |
| RPT-01 | Report archive API | PASS | Report UAT ditemukan | `GET /reports` HTTP 200; total=1 | [18](screenshots/admin-iso-cedex-audit/18-reports-management-1366.png) | - |
| RPT-02 | Management read-only report | PASS | `/reports` merender link report tanpa alert/console error | API `/reports?page=1&per_page=100` HTTP 200; tidak memanggil monitoring | [18](screenshots/admin-iso-cedex-audit/18-reports-management-1366.png) | BUG-03 fixed: permission-aware enrichment |
| RPT-03 | PDF final | NOT_APPLICABLE | Endpoint download/generate tidak dipanggil | Tidak dijalankan sesuai batas UAT | N/A | Sengaja tidak memicu PDF final |
| RPT-04 | Public QR | NOT_APPLICABLE | Endpoint validasi QR publik tidak dipanggil | Tidak dijalankan sesuai batas UAT | N/A | Fitur UI juga ditandai belum aktif |
| USR-01 | User & Hak Akses route | PASS | Halaman merender dan active sidebar tunggal | Edge `/settings/users#role-permission` | [19](screenshots/admin-iso-cedex-audit/19-users-access-admin-768.png) | - |
| BRW-01 | Browser interaktif bawaan | BLOCKED | Bootstrap gagal karena metadata sandbox `sandboxPolicy` tidak tersedia | Browser skill/node REPL bootstrap | N/A | Fallback Edge digunakan |
| BRW-02 | Edge fallback | PASS | Login 4 role, navigasi, DOM inspection, screenshot berhasil | Edge headless + CDP port sementara 9222 | Seluruh 20 screenshot | - |
| BRW-03 | Bukti layar baru | PASS | Tepat 20 PNG valid dan berdimensi sesuai | `System.Drawing.Image::FromFile` pada 20 file | [Folder bukti](screenshots/admin-iso-cedex-audit/) | - |
| BRW-04 | Lima viewport | PASS | 390x844, 768x1024, 1024x768, 1366x768, 1920x1080 tercakup | `browser-uat-results.json` | [02](screenshots/admin-iso-cedex-audit/02-iso-location-1920.png), [09](screenshots/admin-iso-cedex-audit/09-customer-location-768.png), [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | - |
| BRW-05 | Horizontal overflow | PASS | Tidak ada overflow pada seluruh screenshot dan zoom test | DOM `scrollWidth <= clientWidth` | [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | - |
| BRW-06 | Zoom 200% | PASS | H1=1, active nav=1, overflow=false | CDP `Emulation.setPageScaleFactor(2)` | [02](screenshots/admin-iso-cedex-audit/02-iso-location-1920.png) | - |
| BRW-07 | Keyboard/focus | PASS | Tab berpindah ke button dengan outline solid 2px | CDP `Input.dispatchKeyEvent(Tab)` | [02](screenshots/admin-iso-cedex-audit/02-iso-location-1920.png) | - |
| BRW-08 | Heading dan duplicate ID | PASS | Semua 20 layar memiliki satu H1 dan nol duplicate ID | DOM inspection per screenshot | Seluruh 20 screenshot | - |
| BRW-09 | Label/ARIA form controls | FAIL | Kontrol tanpa accessible name: 1 pada Customer Personnel, 1 Location, 2 User, 1 Review History, 1 Surveyor Job | DOM label audit | [08](screenshots/admin-iso-cedex-audit/08-customer-personnel-1024.png), [09](screenshots/admin-iso-cedex-audit/09-customer-location-768.png), [17](screenshots/admin-iso-cedex-audit/17-review-history-supervisor-1366.png), [19](screenshots/admin-iso-cedex-audit/19-users-access-admin-768.png), [20](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png) | Follow-up: beri `aria-label`/label eksplisit pada filter |
| BRW-10 | Contrast WCAG menyeluruh | BLOCKED | Render tersedia, tetapi contrast scanner/manual image inspection tidak dapat bootstrap | Image inspection/node REPL gagal `sandboxPolicy` | Seluruh 20 screenshot tersedia untuk review manual | Tidak mengklaim lulus contrast |
| BRW-11 | Console/hydration/runtime | PASS | Setelah report fix tidak ada error aplikasi; hanya 404 `favicon.ico` pada run utama | `browser-uat-results.json`, `management-report-retest.json` | [18](screenshots/admin-iso-cedex-audit/18-reports-management-1366.png) | Favicon 404 non-fungsional |
| VAL-01 | Go test API | PASS | Semua package lulus setelah fix terakhir | `cd services/api; go test ./...` | N/A | - |
| VAL-02 | Go test Worker | PASS | Semua package lulus | `cd services/worker; go test ./...` | N/A | - |
| VAL-03 | Web typecheck | PASS | TypeScript tanpa error | `npm run typecheck --workspace apps/web` | N/A | - |
| VAL-04 | Web production build | PASS | Next 16.2.9; 68/68 static pages; build sukses | `npm run build --workspace apps/web` | N/A | - |
| VAL-05 | `next-env.d.ts` hygiene | PASS | Hash awal dipulihkan identik setelah build | SHA-256 awal/akhir `7AD303E4...` | N/A | Dipulihkan via patch satu baris, tanpa checkout |
| VAL-06 | Whitespace check | PASS | Exit code 0 | `git diff --check` | N/A | Hanya warning CRLF, tanpa whitespace error |
| VAL-07 | CI GitHub | BLOCKED | 0 status dan 0 check-run | GitHub API commit status/check-runs | N/A | **Belum ada verifikasi CI GitHub** |

## Record UAT yang ditinggalkan

| Prefix / nomor | ID | Status akhir |
|---|---|---|
| `UAT-ISO-CEDEX-20260723115019` Customer A | `42aee823-b9d1-4788-9fd6-cdce2cb732f8` | inactive |
| `UAT-ISO-CEDEX-20260723115019` Customer B | `5d275989-b5f8-4f56-abb7-1e6cf8630449` | inactive |
| Job suite CRUD | `4f3589d9-1d31-4063-bf92-06e06a966fc0` | assigned; prefix pada reference/instruction |
| Job suite Reject | `1b39e6d9-c766-41ae-bdfb-24b53e76eaa9` | in progress/rejected survey |
| Survey Approve | `293e4859-83eb-4e36-9ab5-48fbe2f33bbf` | approved |
| Survey Reject | `724d3aea-49fb-41de-82ce-05d35a394925` | rejected |
| Report UAT | `GIFT-RPT-2026-000001` | queued metadata; PDF tidak dipanggil |
| Job import | `e8438630-bfbf-4861-be6f-73611a3f479c` | assigned |
| Imported container | `82b50221-7114-4dce-8544-c0508885094b` | assigned |
| Survey Damage/Photo | `829ea486-456b-44e3-883d-5cc97b7c6dc9` | draft; photo blocked |
| Damage sintetis | `7d952d90-6b58-439d-b117-3df03f38f226` | soft-deleted |

Sebelum suite final berprefix penuh, runner eksplorasi membuat data berprefix ringkas `A0723110926`. Seluruh Customer dan master record dari runner tersebut telah diinaktifkan. Job/survey yang tidak memiliki delete flow tetap terdokumentasi pada log audit API. Suite final 76/76 menggunakan prefix penuh yang diwajibkan.

## Katalog 20 screenshot baru

1. [Admin dashboard 1366](screenshots/admin-iso-cedex-audit/01-admin-dashboard-1366.png)
2. [ISO Location 1920](screenshots/admin-iso-cedex-audit/02-iso-location-1920.png)
3. [ISO Component 1366](screenshots/admin-iso-cedex-audit/03-iso-component-1366.png)
4. [ISO Action Repair 1024](screenshots/admin-iso-cedex-audit/04-iso-action-repair-1024.png)
5. [Reference Container Type 1366](screenshots/admin-iso-cedex-audit/05-reference-container-type-1366.png)
6. [Reference Checklist 1024](screenshots/admin-iso-cedex-audit/06-reference-checklist-1024.png)
7. [Customer Profile 1366](screenshots/admin-iso-cedex-audit/07-customer-profile-1366.png)
8. [Customer Personnel 1024](screenshots/admin-iso-cedex-audit/08-customer-personnel-1024.png)
9. [Customer Location 768](screenshots/admin-iso-cedex-audit/09-customer-location-768.png)
10. [Customer History 1366](screenshots/admin-iso-cedex-audit/10-customer-history-1366.png)
11. [Jobs List 1920](screenshots/admin-iso-cedex-audit/11-jobs-list-1920.png)
12. [Job Create 1366](screenshots/admin-iso-cedex-audit/12-job-create-1366.png)
13. [Job Detail Summary 1366](screenshots/admin-iso-cedex-audit/13-job-detail-summary-1366.png)
14. [Job Detail Assignment 1024](screenshots/admin-iso-cedex-audit/14-job-detail-assignment-1024.png)
15. [Survey Monitoring compatibility 1366](screenshots/admin-iso-cedex-audit/15-survey-monitoring-admin-1366.png)
16. [Review Pending Supervisor 1024](screenshots/admin-iso-cedex-audit/16-review-pending-supervisor-1024.png)
17. [Review History Supervisor 1366](screenshots/admin-iso-cedex-audit/17-review-history-supervisor-1366.png)
18. [Reports Management 1366](screenshots/admin-iso-cedex-audit/18-reports-management-1366.png)
19. [User & Hak Akses 768](screenshots/admin-iso-cedex-audit/19-users-access-admin-768.png)
20. [Surveyor menu mobile 390](screenshots/admin-iso-cedex-audit/20-surveyor-menu-mobile-390.png)

Machine-readable evidence:

- `docs/screenshots/admin-iso-cedex-audit/browser-uat-results.json`
- `docs/screenshots/admin-iso-cedex-audit/management-report-retest.json`
- `docs/screenshots/admin-iso-cedex-audit/canonical-tab-retest.json`
