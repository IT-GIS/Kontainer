# Audit Pra-Implementasi Restrukturisasi UI/UX Admin

Tanggal audit: 31 Agustus 2026

Branch: `codex/redesign-surveyor-survey-sheet`

Baseline commit: `872a9b97098f8a67f5d4f65959ee91116da43721` (`feat: complete final repository hardening`)

## Batas implementasi

- Restrukturisasi ini berfokus pada information architecture, navigasi, orkestrasi workspace, panduan proses, status manusia, breadcrumb, CTA, dan responsive behavior.
- Backend dan database existing dipakai ulang. Tidak ada DROP, TRUNCATE, mass DELETE, destructive rename, rewrite migration, atau pembuatan business logic paralel.
- Route lama tetap dipertahankan untuk deep-link dan compatibility.
- Finance, Billing, Workshop, Gate-Out, VGM, Public QR, Public Verification, dan Final PDF tidak diaktifkan.
- Istilah presentasi yang dipakai adalah **Kelaikan**.

## Kondisi worktree sebelum implementasi

Worktree sudah tidak bersih sebelum pekerjaan ini dimulai. Perubahan existing yang tidak terkait, termasuk `apps/web/next-env.d.ts`, beberapa laporan/dokumen, backup database, dan `apps/web/components/reports/report-version-history.tsx`, diperlakukan sebagai milik pekerjaan sebelumnya dan tidak boleh dihapus, di-reset, atau dimasukkan ke scope tanpa kebutuhan langsung.

## Current routes

| Area | Route canonical saat ini | Kondisi awal | Target orkestrasi |
| --- | --- | --- | --- |
| Dashboard | `/dashboard` | Aktif | Tetap menjadi menu utama |
| Customer | `/master/customers` | Daftar berbasis readiness backend | Ubah label menjadi Customer & Master dan tambah filter kesiapan |
| Customer detail | `/master/customers/customer/:customerId` | Lima tab: profil, personel, location, riwayat, readiness | Satu setup workspace sembilan tahap |
| Global CEDEX | `/master/iso-cedex` | Lima section global | Tetap hidup; diposisikan dari Pengaturan > Master Global |
| Referensi pemeriksaan | `/master/inspection-references` | Workspace campuran customer/global | Tetap hidup; akses global diposisikan dari Master Global dan mapping customer berada dalam setup Customer |
| Pekerjaan | `/jobs` | Workboard dengan banyak status teknis | Satu workspace dengan tujuh tab proses yang diminta |
| Buat pekerjaan | `/jobs/create` | Form create header Job | Jadikan langkah 1 dari wizard empat tahap; setelah save lanjut ke Job yang sama |
| Detail pekerjaan | `/jobs/:id` | Delapan tab existing | Pertahankan, tambah progress summary, wizard guidance, breadcrumb, dan Next Action |
| Import container | `/jobs/:id/containers/import` | Aksi kontekstual | Tetap hidup pada langkah Peti Kemas |
| Monitoring | `/monitoring/surveys`, `/surveys/monitoring` | Route compatibility/monitoring terpisah | Tetap hidup tetapi tidak menjadi menu sidebar Admin |
| Review | `/review/pending`, `/review/history`, `/review/need-revision`, `/review/approved` | Halaman terpisah | Satu workspace tab/filter di `/review`; route lama tetap hidup |
| Laporan | `/reports`, `/reports/:id`, `/reports/versions` | Laporan/arsip metadata | Satu workspace `Aktif | Arsip`; detail/version route tetap hidup |
| Pengaturan | `/settings/*` dan `/master/surveyors` | Link tersebar di group sidebar | Tambah landing workspace `/settings` dan Master Global `/settings/master-global` |

## Current components

- `apps/web/constants/navigation-admin.ts` masih membuat group terpisah untuk Pekerjaan, Monitoring, Master Data, Review, Dokumen & Laporan, dan Pengaturan.
- `apps/web/components/layout/app-shell.tsx` sudah mendukung sidebar drawer mobile, active route matching, collapse desktop, breadcrumb, dan permission-filtered navigation.
- `apps/web/components/master/customer-readiness.tsx` sudah memakai `/customers/readiness` dan `/customers/:id/readiness`; progress bukan persentase kosmetik.
- `apps/web/components/master/customer-detail-workspace.tsx` baru mengorkestrasi profil, Personel/PIC, Location, riwayat, dan readiness.
- `apps/web/components/master/customer-scoped-master-data.tsx`, `checklist-reference-tab.tsx`, `personnel-location-mapping.tsx`, `iso-cedex-workspace.tsx`, dan `MasterDataPage` dapat dipakai ulang untuk sembilan tahap Customer Setup dan Master Global.
- `apps/web/components/jobs/inspection-work-list.tsx` sudah menggabungkan job, survey, review, dan metadata report, tetapi jumlah/status tab perlu disederhanakan sesuai brief.
- `/jobs/create` sudah customer-first, memakai readiness backend, Location/PIC mapping, Survey Type customer, dan tidak membuat data fiktif.
- `/jobs/:id` sudah mendukung add/import container, check digit validation/override, CSC data, assign/reassign, progress read-only, hasil survey, review, dokumen, dan riwayat.
- Review list masih terbagi pada beberapa page. Komponen workspace tab/filter reusable belum ada.
- `DocumentReportWorkspace` sudah menggabungkan metadata report dan hasil review, tetapi label/tab awal masih `Laporan Pemeriksaan | Arsip Laporan`.
- Komponen UI reusable `Stepper`, `ProgressTracker`, `CompletionBadge`, `ActionCard`, `WorkspaceTabs`, `ResponsiveTableCards`, dan `StatusBadge` sudah tersedia.

## Backend reuse

| Kebutuhan UI | Endpoint/contract existing |
| --- | --- |
| Daftar readiness Customer | `GET /customers/readiness` |
| Readiness Customer detail | `GET /customers/:id/readiness` |
| Profil Customer | CRUD `/master/customers` |
| Location/PIC/mapping | CRUD `/customers/:id/locations`, `/customers/:id/personnel`, GET/PUT mapping Location-PIC |
| Survey Type/Container Type customer | CRUD `/customers/:id/survey-types`, `/customers/:id/container-types` |
| Checklist customer | CRUD `/customers/:id/checklist-templates` dan item template existing |
| Referensi/foto per Survey Type | GET/PUT `/customers/:id/survey-types/:item_id/reference-options` |
| CEDEX customer/global | CRUD customer-scoped dan `/master/cedex/*`; effective-master fallback tetap di backend |
| Job | GET/POST/PUT `/jobs`, GET `/jobs/:id` |
| Container | POST `/jobs/:id/containers`, import preview/confirm, check digit validator |
| Assignment | POST `/jobs/:id/assign`, reassign existing |
| Monitoring/review | `/surveys/monitoring`, `/reviews`, `/reviews/pending`, `/reviews/:id/*` |
| Report metadata/version | `/reports`, `/reports/:id`, `/reports/:id/versions` |

Backend `EvaluateReadinessTx` tetap menjadi hard gate pada create/assignment/start Survey. UI hanya menampilkan dan mengarahkan berdasarkan kontrak nyata; backend tetap authority.

## DB impact

**Tidak ada perubahan database yang direncanakan.** Readiness, customer scope, effective CEDEX, checklist, inspection reference mapping, photo category mapping, jobs, containers, assignments, reviews, reports, dan audit trail sudah memiliki schema/migration existing. Restrukturisasi ini tidak mengubah migration lama maupun baseline dump.

## Permission impact

- Visibility sidebar dan action mengikuti permission existing melalui `visibleNavigation`, `can`, dan `ProtectedRoute`.
- Direct URL tetap dilindungi role frontend dan permission middleware backend.
- Pengelolaan global master hanya ditampilkan kepada user yang memiliki permission modul terkait.
- Keputusan review tetap dibatasi pada Supervisor/Super Admin dengan `reviews.manage.all`; Admin tetap read-only terhadap hasil teknis.
- Tidak ada permission baru atau penghapusan permission.

## Compatibility risks

1. Active sidebar state dapat ganda jika route legacy dan query tab tidak dimasukkan ke satu match canonical.
2. Readiness list dan hard gate berbeda tingkat detail: list readiness bersifat Customer-wide, sedangkan `EvaluateReadinessTx` juga Survey-Type-aware. UI tidak boleh mengklaim hard-gate per Survey Type sebelum Survey Type dipilih.
3. Checklist customer pada schema existing adalah customer-scoped. Global checklist fallback yang eksplisit belum menjadi kontrak backend yang setara dengan effective CEDEX; UI harus menjelaskan sumber existing tanpa mengarang inheritance.
4. `size` Container Type tersedia pada master, tetapi contract option pada detail Job perlu memuatnya sebelum dapat ditampilkan/diturunkan otomatis bersama ISO Type.
5. Kontrak report saat ini metadata-only; Aktif/Arsip tidak boleh menyiratkan PDF final/QR/public verification aktif.
6. Route compatibility harus tetap render/redirect dengan aman: `/master/customers`, `/master/iso-cedex`, `/master/inspection-references`, `/jobs`, `/jobs/create`, `/monitoring/surveys`, `/review/pending`, `/review/history`, dan `/reports`.

## Implementation plan

1. Sederhanakan navigation Admin menjadi enam entry high-level dan perbarui navigation contract test.
2. Jadikan daftar Customer sebagai landing `Customer & Master` dengan search, Status, Kesiapan, progress nyata, missing-item summary, dan CTA kontekstual.
3. Bentuk `CustomerSetupStepper`, readiness card, source explanation, Next Action, dan sembilan tahap setup dari komponen/API existing.
4. Tambah landing Pengaturan dan Master Global yang permission-aware; pertahankan route global CEDEX/reference existing.
5. Sederhanakan tab Pekerjaan dan tambahkan `JobCreationStepper` lintas `/jobs/create` dan `/jobs/:id` tanpa menciptakan Job kedua.
6. Tambah progress summary dan Next Action pada detail Job; tetap read-only untuk hasil teknis.
7. Konsolidasikan Review menjadi tab `Menunggu Review | Perlu Revisi | Disetujui | Ditolak | Riwayat` dengan endpoint existing.
8. Ubah Laporan menjadi tab `Aktif | Arsip` pada satu workspace metadata-only.
9. Tambah status manusia, breadcrumb, responsive rules, dan anti-horizontal-overflow untuk viewport wajib.
10. Jalankan contract tests, lint, typecheck, build, Go test/vet, browser smoke bila runtime tersedia, lalu dokumentasikan hasil dan gap yang benar-benar terbukti.
