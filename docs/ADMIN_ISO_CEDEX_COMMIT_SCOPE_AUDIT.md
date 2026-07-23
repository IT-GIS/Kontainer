# Audit Scope Commit Admin ISO CEDEX

Tanggal audit: 23 Juli 2026 (Asia/Jakarta)
Commit target: `af1ec4c3ded3b3ff8b81d3214478e90011b8587e`
Baseline: `9ea105f2b43fdf89aa24c9a2257d73e2585c2531`
Branch: `main`

## Kesimpulan

Commit target berisi 64 file dengan 3.014 penambahan dan 774 penghapusan. Seluruh file commit berada pada frontend web dan dokumentasi/bukti layar; tidak ada perubahan API, migration, schema, seed, atau permission backend di dalam commit.

Scope commit konsisten dengan restrukturisasi Admin ISO CEDEX: canonical navigation, compatibility routes, customer-first master data, pekerjaan inspeksi, review, laporan, User & Hak Akses, serta dokumentasi. Risiko terbesar bukan perubahan schema, melainkan ketergantungan frontend pada endpoint, permission, dan data customer-scoped yang harus sudah tersedia pada runtime.

Audit runtime dilakukan terhadap worktree lokal yang telah memiliki perubahan pasca-commit. Karena itu:

- atribusi commit memakai diff murni `9ea105f2..af1ec4c3`;
- UAT runtime memakai checkout lokal saat audit;
- perubahan lokal yang sudah ada dipertahankan;
- `navigation-surveyor.ts` dicatat sebagai drift pasca-commit dan bukan perubahan commit target;
- tidak ada commit, push, reset, stash, clean, rebase, atau checkout file.

## Baseline dan isolasi perubahan

| Pemeriksaan | Hasil |
|---|---|
| `HEAD` | `af1ec4c3ded3b3ff8b81d3214478e90011b8587e` |
| `main` | `af1ec4c3ded3b3ff8b81d3214478e90011b8587e` |
| `origin/main` lokal | `af1ec4c3ded3b3ff8b81d3214478e90011b8587e` |
| `git ls-remote origin refs/heads/main` | `af1ec4c3ded3b3ff8b81d3214478e90011b8587e` |
| Parent commit | `9ea105f2b43fdf89aa24c9a2257d73e2585c2531` |
| File commit | 64 |
| Backend/database di commit | 0 |
| Perubahan `navigation-surveyor.ts` di commit | 0 |
| Overlap file commit dengan perubahan lokal pada awal audit | 0 |
| CI GitHub | 0 commit status dan 0 check-run |

Status GitHub API untuk commit mengembalikan `state=pending` dengan `total_count=0`; ini berarti **Belum ada verifikasi CI GitHub**, bukan kegagalan CI. Hasil tersebut dipisahkan dari validasi lokal.

## Klasifikasi scope A-E

| Scope | Arti | Batas audit |
|---|---|---|
| A | Canonical information architecture dan navigation Admin | Struktur menu, halaman canonical, tab, CSS layout, active state |
| B | Compatibility route | Redirect lama ke canonical route, query/hash, satu sidebar aktif |
| C | Resource CRUD dan customer ownership | Customer-first selector/detail, master data, checklist, dependency resource |
| D | Workflow pendukung | Job, import, assignment, survey monitoring, review, laporan, settings |
| E | Dokumentasi dan bukti historis commit | Dokumen mapping dan delapan screenshot lama; bukan bukti UAT baru |

Kode rekomendasi:

- `KEEP`: sesuai brief.
- `KEEP+REGRESSION`: sesuai brief tetapi berisiko dan wajib dipertahankan dalam regression test.
- `REDIRECT`: compatibility-only; sumber UI tetap canonical.
- `DOC-ONLY`: tidak memengaruhi runtime.
- `HISTORICAL`: hanya bukti keadaan commit, tidak boleh dianggap UAT baru.

## Audit seluruh 64 file commit

| # | File | Kategori | Scope | Risiko | Route / dependency | Permission | Rekomendasi |
|---:|---|---|:---:|---|---|---|---|
| 1 | `apps/web/app/fitness/master-data/checklist-templates/[clientId]/[templateId]/items/page.tsx` | Checklist CRUD | C | Tinggi | `/fitness/master-data/checklist-templates/:client/:template/items`; customer/template/item API | `fitness_checklist_templates.*` | KEEP+REGRESSION |
| 2 | `apps/web/app/fitness/master-data/checklist-templates/[clientId]/page.tsx` | Checklist CRUD | C | Tinggi | `/fitness/master-data/checklist-templates/:client`; customer-scoped template API | `fitness_checklist_templates.*` | KEEP+REGRESSION |
| 3 | `apps/web/app/fitness/master-data/checklist-templates/page.tsx` | Checklist customer picker | C | Sedang | `/fitness/master-data/checklist-templates`; customer list | `customers.view.all`, `fitness_checklist_templates.view.all` | KEEP |
| 4 | `apps/web/app/globals.css` | Layout/responsive | A | Tinggi | Seluruh Admin workspace dan lima viewport | N/A | KEEP+REGRESSION |
| 5 | `apps/web/app/jobs/[id]/page.tsx` | Detail Job | D | Tinggi | `/jobs/:id`; jobs, containers, assignments, surveys, reviews, reports | `jobs.view.all`, `job_containers.*`, `assignments.*`, `reviews.view.all`, `reports.view.all` | KEEP+REGRESSION |
| 6 | `apps/web/app/jobs/assign/page.tsx` | Compatibility assignment | B | Rendah | `/jobs/assign` -> `/jobs?view=unassigned&compat=assign` | `assignments.assign.all` | REDIRECT |
| 7 | `apps/web/app/jobs/create/page.tsx` | Create Job | D | Tinggi | `/jobs/create`; customer-owned survey type, location, Personel/PIC | `jobs.create.all` dan view reference | KEEP+REGRESSION |
| 8 | `apps/web/app/jobs/import/page.tsx` | Compatibility import | B | Rendah | `/jobs/import` -> `/jobs?view=unassigned&compat=import` | `job_containers.import.all` | REDIRECT |
| 9 | `apps/web/app/jobs/page.tsx` | Pekerjaan Inspeksi | D | Tinggi | `/jobs`; work list/filter/action | `jobs.view.all`, action permissions | KEEP+REGRESSION |
| 10 | `apps/web/app/master/[...route]/page.tsx` | Dynamic legacy master | B | Tinggi | Legacy customer/category path -> canonical customer/ISO/reference | Sesuai resource target | REDIRECT |
| 11 | `apps/web/app/master/cedex/components/page.tsx` | CEDEX compatibility | B | Rendah | -> `/master/iso-cedex?tab=component` | `cedex_components.view.all` | REDIRECT |
| 12 | `apps/web/app/master/cedex/damages/page.tsx` | CEDEX compatibility | B | Rendah | -> `/master/iso-cedex?tab=damage` | `cedex_damages.view.all` | REDIRECT |
| 13 | `apps/web/app/master/cedex/locations/page.tsx` | CEDEX compatibility | B | Rendah | -> `/master/iso-cedex?tab=location` | `cedex_locations.view.all` | REDIRECT |
| 14 | `apps/web/app/master/cedex/materials/page.tsx` | CEDEX compatibility | B | Rendah | -> `/master/iso-cedex?tab=material` | `cedex_materials.view.all` | REDIRECT |
| 15 | `apps/web/app/master/cedex/repairs/page.tsx` | CEDEX compatibility | B | Rendah | -> `/master/iso-cedex?tab=action-repair` | `cedex_repairs.view.all` | REDIRECT |
| 16 | `apps/web/app/master/container-types/page.tsx` | Reference compatibility | B | Rendah | -> `/master/inspection-references?tab=container-type` | `container_types.view.all` | REDIRECT |
| 17 | `apps/web/app/master/customers/customer/[customerId]/page.tsx` | Customer Detail | C | Tinggi | `/master/customers/customer/:id`; profile/personnel/location/history | `customers.view.all`, `locations.*`, customer personnel permission | KEEP+REGRESSION |
| 18 | `apps/web/app/master/inspection-references/page.tsx` | Canonical references | A | Tinggi | Enam tab reference; customer/global resources | Permission per resource | KEEP+REGRESSION |
| 19 | `apps/web/app/master/iso-cedex/page.tsx` | Canonical ISO CEDEX | A | Tinggi | Enam tab ISO CEDEX; customer selector/detail | `cedex_*.*`, `responsibility_codes.*` | KEEP+REGRESSION |
| 20 | `apps/web/app/master/locations/page.tsx` | Location compatibility | B | Sedang | -> `/master/customers?tab=location&compat=locations` | `locations.view.all` | REDIRECT |
| 21 | `apps/web/app/master/responsibility-codes/page.tsx` | CEDEX compatibility | B | Rendah | -> `/master/iso-cedex?tab=responsibility` | `responsibility_codes.view.all` | REDIRECT |
| 22 | `apps/web/app/master/survey-types/page.tsx` | Reference compatibility | B | Rendah | -> `/master/inspection-references?tab=survey-type` | `survey_types.view.all` | REDIRECT |
| 23 | `apps/web/app/master/surveyors/page.tsx` | Surveyor GIFT | A | Sedang | `/master/surveyors`; terpisah dari Personel/PIC Customer | `surveyors.*` | KEEP+REGRESSION |
| 24 | `apps/web/app/reports/[id]/page.tsx` | Detail laporan | D | Tinggi | `/reports/:id`; metadata/version | `reports.view.all`, `reports.version.all` | KEEP+REGRESSION |
| 25 | `apps/web/app/reports/page.tsx` | Canonical laporan | D | Tinggi | `/reports`; workspace laporan/read-only Management | `reports.view.all` | KEEP+REGRESSION |
| 26 | `apps/web/app/reports/qr-validation/page.tsx` | QR placeholder | D | Sedang | `/reports/qr-validation`; fitur ditandai belum aktif | `reports.view.all` | KEEP; jangan aktifkan QR |
| 27 | `apps/web/app/reports/versions/page.tsx` | Report compatibility | B | Rendah | -> `/reports?view=archive&compat=versions` | `reports.version.all` | REDIRECT |
| 28 | `apps/web/app/review/[id]/page.tsx` | Detail review | D | Tinggi | `/review/:surveyId`; checklist/damage/photo/decision | `reviews.view.all`, `reviews.manage.all` | KEEP+REGRESSION |
| 29 | `apps/web/app/review/history/page.tsx` | Riwayat keputusan | D | Sedang | `/review/history`; approved/rejected/need revision | `reviews.view.all` | KEEP+REGRESSION |
| 30 | `apps/web/app/review/pending/page.tsx` | Pending review | D | Tinggi | `/review/pending`; submitted surveys | `reviews.view.all`, aksi `reviews.manage.all` | KEEP+REGRESSION |
| 31 | `apps/web/app/settings/roles/page.tsx` | Settings compatibility | B | Rendah | -> `/settings/users#role-permission` | `roles.view.all` | REDIRECT |
| 32 | `apps/web/app/settings/users/page.tsx` | User & Hak Akses | D | Tinggi | `/settings/users`; user list + role/permission reference | `users.view.all`, `roles.view.all`; mutation sesuai permission | KEEP+REGRESSION |
| 33 | `apps/web/app/surveys/monitoring/approved/page.tsx` | Monitoring compatibility | B | Rendah | -> `/jobs?view=approved&compat=monitoring` | `surveys.view.all` | REDIRECT |
| 34 | `apps/web/app/surveys/monitoring/in-progress/page.tsx` | Monitoring compatibility | B | Rendah | -> `/jobs?view=in-progress&compat=monitoring` | `surveys.view.all` | REDIRECT |
| 35 | `apps/web/app/surveys/monitoring/need-revision/page.tsx` | Monitoring compatibility | B | Rendah | -> `/jobs?view=need-revision&compat=monitoring` | `surveys.view.all` | REDIRECT |
| 36 | `apps/web/app/surveys/monitoring/page.tsx` | Monitoring compatibility | B | Rendah | -> `/jobs?view=in-progress&compat=monitoring` | `surveys.view.all` | REDIRECT |
| 37 | `apps/web/app/surveys/monitoring/submitted/page.tsx` | Monitoring compatibility | B | Rendah | -> `/jobs?view=pending-review&compat=monitoring` | `surveys.view.all` | REDIRECT |
| 38 | `apps/web/components/jobs/inspection-work-list.tsx` | Work list | D | Tinggi | `/jobs`; gabungan jobs/surveys/reviews/actions | Permission aksi per role | KEEP+REGRESSION |
| 39 | `apps/web/components/jobs/job-detail-tabs.tsx` | Detail Job tabs | D | Tinggi | Ringkasan, peti kemas, assignment, progress, survey, review, dokumen, history | `job_containers.*`, `assignments.*`, `reviews.*`, `reports.*` | KEEP+REGRESSION |
| 40 | `apps/web/components/master/checklist-reference-tab.tsx` | Checklist reference | C | Tinggi | Reference checklist customer picker/detail | `fitness_checklist_templates.*` | KEEP+REGRESSION |
| 41 | `apps/web/components/master/customer-detail-workspace.tsx` | Customer Detail tabs | C | Tinggi | Profile, Personel/PIC, Location, history | `customers.view.all`, `locations.*`, personnel permission | KEEP+REGRESSION |
| 42 | `apps/web/components/master/customer-first-route.tsx` | Customer-first routing | C | Tinggi | Selector customer sebelum resource detail | `customers.view.all` + target resource | KEEP+REGRESSION |
| 43 | `apps/web/components/master/customer-scoped-master-data.tsx` | Customer-scoped CRUD | C | Kritis | Membentuk endpoint `/customers/:id/...` dan canonical href | Permission per resource; backend ownership wajib | KEEP+REGRESSION |
| 44 | `apps/web/components/master/master-data-page.tsx` | Generic CRUD | C | Kritis | List/create/edit/inactive/duplicate/relation options | `resource.permissionModule.*` | KEEP+REGRESSION |
| 45 | `apps/web/components/reports/document-report-workspace.tsx` | Laporan/rekap | D | Tinggi | Reports + optional survey/review enrichment | `reports.view.all`; `/surveys/monitoring` hanya bila `surveys.view.all` | KEEP+REGRESSION |
| 46 | `apps/web/components/ui/data-table.tsx` | Shared data table | A | Tinggi | Semua tabel Admin | N/A | KEEP+REGRESSION |
| 47 | `apps/web/components/ui/workspace-tabs.tsx` | Shared tabs | A | Sedang | Canonical ISO/reference/customer/report tabs | N/A; ARIA tab state | KEEP |
| 48 | `apps/web/constants/fitness-master-data-client-first.ts` | Master routing config | C | Tinggi | Category/customer href mapping | Permission mengikuti resource | KEEP+REGRESSION |
| 49 | `apps/web/constants/master-data.ts` | CRUD resource schema | C | Kritis | Endpoint, field, relation, labels | Permission module per resource | KEEP+REGRESSION |
| 50 | `apps/web/constants/navigation-admin.ts` | Admin navigation | A | Kritis | Enam grup canonical, compatibility active matcher | Role/permission visibility | KEEP+REGRESSION |
| 51 | `apps/web/lib/inspection-work.ts` | Workflow aggregation | D | Tinggi | Load/filter/merge jobs, surveys, reviews | Endpoint permissions harus konsisten | KEEP+REGRESSION |
| 52 | `apps/web/types/inspection-work.ts` | Workflow types | D | Sedang | Inspection work view model | N/A | KEEP |
| 53 | `apps/web/types/job-detail-workspace.ts` | Job detail types | D | Sedang | Supporting data job detail | N/A | KEEP |
| 54 | `apps/web/types/jobs.ts` | Job types | D | Sedang | Job/container/assignment payload-response | N/A | KEEP |
| 55 | `docs/ADMIN_INFORMATION_ARCHITECTURE_PAK_AGUS_ALIGNMENT.md` | Dokumentasi IA | E | Rendah | Tidak ada runtime | N/A | DOC-ONLY |
| 56 | `docs/OLD_TO_NEW_ADMIN_MENU_MAPPING.md` | Dokumentasi mapping | E | Rendah | Tidak ada runtime | N/A | DOC-ONLY |
| 57 | `docs/screenshots/admin-iso-pak-agus/01-sidebar-admin-baru.png` | Bukti commit lama | E | Rendah | Sidebar Admin saat commit | N/A | HISTORICAL |
| 58 | `docs/screenshots/admin-iso-pak-agus/02-iso-cedex-location.png` | Bukti commit lama | E | Rendah | ISO CEDEX Location saat commit | N/A | HISTORICAL |
| 59 | `docs/screenshots/admin-iso-pak-agus/03-iso-cedex-component.png` | Bukti commit lama | E | Rendah | ISO CEDEX Component saat commit | N/A | HISTORICAL |
| 60 | `docs/screenshots/admin-iso-pak-agus/04-referensi-pemeriksaan.png` | Bukti commit lama | E | Rendah | Referensi Pemeriksaan saat commit | N/A | HISTORICAL |
| 61 | `docs/screenshots/admin-iso-pak-agus/05-customer-personnel.png` | Bukti commit lama | E | Rendah | Customer Personel/PIC saat commit | N/A | HISTORICAL |
| 62 | `docs/screenshots/admin-iso-pak-agus/06-customer-location.png` | Bukti commit lama | E | Rendah | Customer Location saat commit | N/A | HISTORICAL |
| 63 | `docs/screenshots/admin-iso-pak-agus/07-pekerjaan-inspeksi.png` | Bukti commit lama | E | Rendah | Pekerjaan Inspeksi saat commit | N/A | HISTORICAL |
| 64 | `docs/screenshots/admin-iso-pak-agus/08-mobile-iso-cedex.png` | Bukti commit lama | E | Rendah | Mobile ISO CEDEX saat commit | N/A | HISTORICAL |

## Audit navigation dan route

Hasil audit statis dan browser:

- enam grup canonical Admin tersedia: dashboard, master data, pekerjaan inspeksi, review & keputusan, dokumen & laporan, dan pengaturan;
- enam tab ISO CEDEX tersedia dengan label `Location Code`, `Component Code`, `Damage Code`, `Action Repair Code`, `Material Code`, dan `Responsibility Code`;
- enam tab Referensi Pemeriksaan tersedia dengan label `Container Type`, `Survey Type`, `Checklist`, `Test Parameter`, `Photo Category`, dan `Finding Severity`;
- 12/12 tab canonical memiliki satu workspace tab aktif dan satu sidebar item aktif;
- 18/18 route compatibility mengarah ke URL canonical yang diharapkan;
- browser back, forward, dan refresh mempertahankan URL/query tab;
- Customer Detail berisi Profil Customer, Personel/PIC, Location Pemeriksaan, dan Riwayat Pekerjaan;
- Surveyor GIFT tetap resource terpisah dari Personel/PIC Customer;
- menu Surveyor pada commit target tidak berubah. Perubahan lokal `apps/web/constants/navigation-surveyor.ts` adalah drift pasca-commit dan dipertahankan.

## Dependency dan ownership

Commit target tidak membawa backend untuk endpoint customer-scoped. Frontend mengandalkan:

- `/customers/:customerId/locations`;
- `/customers/:customerId/personnel`;
- `/customers/:customerId/container-types`;
- `/customers/:customerId/survey-types`;
- `/customers/:customerId/cedex/locations`;
- `/customers/:customerId/cedex/components`;
- `/customers/:customerId/cedex/damages`;
- `/customers/:customerId/cedex/repairs`;
- `/customers/:customerId/cedex/materials`;
- `/customers/:customerId/responsibility-codes`;
- `/customers/:customerId/checklist-templates`.

Runtime UAT memakai implementasi backend lokal pasca-commit yang sudah ada pada worktree. Pengujian membuktikan route customer authoritative, isolasi Customer A/B, cross-customer edit ditolak, dan referensi Job wajib berasal dari Customer yang sama. Hal ini membuktikan runtime lokal, tetapi tidak boleh diatribusikan sebagai kode yang diperkenalkan oleh commit `af1ec4c3`.

## Bug yang terbukti dan perbaikan minimal

| Bug | Atribusi | Perbaikan | Retest |
|---|---|---|---|
| Add Container menghasilkan HTTP 500 karena argumen `check_digit_override_reason` hilang sehingga seluruh parameter SQL bergeser | Perubahan backend lokal pasca-commit | Tambah `input.CheckDigitOverrideReason` pada urutan argumen INSERT di `services/api/internal/jobs/repository.go` | HTTP 201, check digit valid, persistence dan assignment lulus |
| Survey `master-options` dan `checklist` menghasilkan HTTP 500 karena query memakai `ct.name` dan `a.due_at`, sedangkan schema memakai `ct.type_name` dan `a.due_date` | Perubahan backend lokal pasca-commit | Koreksi dua nama kolom di `services/api/internal/surveyor/helpers.go` | Kedua endpoint HTTP 200; general info, checklist, submit, Need Revision, Approve, Reject lulus |
| Create Damage menghasilkan HTTP 500 karena `UPDATE ... RETURNING` pada `survey_damage_counters` diasumsikan memiliki kolom `id`, padahal primary key-nya `survey_id` | Perubahan backend lokal pasca-commit | Ganti menjadi `UPDATE` lalu `SELECT last_number` dalam transaksi yang sama | Damage create 201, update 200, dan soft-delete 200 |
| Management membuka Laporan tetapi frontend selalu memanggil `/surveys/monitoring`, yang membutuhkan `surveys.view.all` dan menghasilkan 403 | Commit target | Hanya lakukan enrichment survey bila user memiliki `surveys.view.all`; laporan tetap memuat `/reports` untuk Management | `/reports` HTTP 200, tanpa alert/console error, report link tampil, tidak ada request monitoring |

Tidak ada perubahan public API, schema database, seed, atau permission yang dibuat dalam audit ini.

## Risiko terbuka

1. Beberapa filter `<select>` belum memiliki accessible name eksplisit. Edge mendeteksi kontrol tanpa label pada Customer Personel/PIC, Customer Location, User & Hak Akses, Riwayat Keputusan, dan Job Saya. Status UAT aksesibilitas untuk bagian tersebut `FAIL`.
2. Pemeriksaan kontras menyeluruh tidak dapat dilakukan karena browser interaktif bawaan dan image inspection tool gagal bootstrap akibat sandbox. Edge headless membuktikan render, focus outline, heading, active state, dan overflow, tetapi bukan audit WCAG contrast penuh. Status `BLOCKED`.
3. Approve otomatis membuat metadata laporan berstatus `queued` walaupun payload `generate_report=false`. Endpoint download PDF dan public QR tidak dipanggil. Perilaku auto-queue perlu keputusan produk jika `generate_report=false` seharusnya benar-benar meniadakan report row.
4. Upload foto survey `BLOCKED`: endpoint mencapai penyimpanan objek lalu gagal HTTP 500 karena MinIO `127.0.0.1:9000` tidak aktif; health endpoint juga connection refused. Tidak ada perubahan kode untuk blocker environment ini.
5. Delapan screenshot `docs/screenshots/admin-iso-pak-agus/` hanya bukti historis commit. Bukti UAT baru berada di `docs/screenshots/admin-iso-cedex-audit/`.

## Rekomendasi

1. Pertahankan struktur canonical dan compatibility redirect yang sudah lulus.
2. Tambahkan regression test frontend untuk permission-aware data enrichment pada role Management.
3. Tambahkan integration test repository untuk Add Container yang memastikan seluruh 19 argumen SQL tetap sejajar.
4. Tambahkan integration test survey base query terhadap schema MySQL aktual.
5. Tambahkan accessible name pada filter yang teridentifikasi, lalu jalankan axe/WCAG contrast scan pada environment browser yang mendukung.
6. Tambahkan GitHub Actions untuk Go test, web typecheck/build, dan `git diff --check`; saat audit ini belum ada verifikasi CI GitHub.
