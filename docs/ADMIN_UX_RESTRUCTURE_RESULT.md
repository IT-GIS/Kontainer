# Hasil Restrukturisasi UI/UX Admin Kontainer

Tanggal implementasi: 31 Agustus 2026

Referensi penerimaan: `SPESIFIKASI_PERUBAHAN_UI_UX_ADMIN_KONTAINER.md`

Branch kerja: `codex/redesign-surveyor-survey-sheet`

Baseline: `872a9b97098f8a67f5d4f65959ee91116da43721`

## Ringkasan hasil

Restrukturisasi selesai pada lapisan frontend/orchestration dengan mempertahankan API, schema, permission, dan route legacy. Sidebar Admin sekarang mempunyai enam menu tingkat atas. Customer setup, pembuatan pekerjaan, review, laporan, dan pengaturan diubah menjadi workspace beralur tanpa membuat business logic paralel atau data kesiapan fiktif.

Tidak ada perubahan database, migration, endpoint backend, permission key, atau destructive operation. Publikasi Git dilakukan setelah ada instruksi terpisah dari pengguna.

## Checklist penerimaan

| Kebutuhan | Hasil implementasi | Status |
| --- | --- | --- |
| Enam menu Admin | Dashboard; Customer & Master; Pekerjaan Inspeksi; Review & Keputusan; Laporan; Pengaturan | Selesai |
| Monitoring keluar dari sidebar | Route `/monitoring/surveys` dan `/surveys/monitoring` tetap hidup dan tetap cocok sebagai konteks Pekerjaan | Selesai |
| Customer sebagai pusat setup | Landing readiness, pencarian, filter Status/Kesiapan, progress nyata, kekurangan, dan CTA kontekstual | Selesai |
| Setup Customer sembilan tahap | Profile; Lokasi & PIC; Survey Type; Container Type; Checklist; CEDEX; Referensi; Photo Evidence; Readiness | Selesai |
| Global vs Customer CEDEX | Customer override dijelaskan sebagai prioritas; global sebagai fallback dari kontrak effective master backend | Selesai |
| Wizard pembuatan pekerjaan | Buat Pekerjaan; Peti Kemas; Penugasan; Konfirmasi, menggunakan Job ID yang sama | Selesai |
| Penugasan dari tahap Peti Kemas | Peti kemas terpilih dapat langsung ditugaskan tanpa wajib berpindah tab | Selesai |
| Ringkasan progress | Total, Belum Dimulai, Sedang Dikerjakan, dan Menunggu Review memakai data pekerjaan/survey existing | Selesai |
| Review terpadu | Menunggu Review; Perlu Revisi; Disetujui; Ditolak; Riwayat pada `/review` | Selesai |
| Laporan terpadu | Tab Aktif dan Arsip; tetap jujur sebagai metadata report tanpa PDF/QR/public verification | Selesai |
| Pengaturan | Landing permission-aware dan workspace Master Global | Selesai |
| Status manusia | Status teknis utama dipetakan ke label operasional Indonesia dan fallback di-humanize | Selesai |
| Breadcrumb dan Next Action | Ditambahkan pada workspace utama serta tahap setup/pembuatan pekerjaan | Selesai |
| Responsive viewport wajib | 360x800, 390x844, 412x915, 768x1024, 1366x768, 1920x1080 terdaftar dan lulus smoke tanpa overflow pada login | Selesai sesuai bukti yang tersedia |
| Route legacy | Route Customer, master, Monitoring, Review lama, Pekerjaan, dan Laporan tetap merespons | Selesai |

## Files changed

File yang diubah/dibuat khusus untuk restrukturisasi ini:

- Navigasi dan status: `apps/web/constants/navigation-admin.ts`, `apps/web/scripts/check-admin-navigation.mjs`, `apps/web/lib/inspection-work.ts`, dan `apps/web/lib/status-labels.ts`.
- Customer & Master: `apps/web/app/master/customers/create/page.tsx`, `apps/web/app/master/customers/customer/[customerId]/page.tsx`, `apps/web/app/master/iso-cedex/page.tsx`, `apps/web/app/master/inspection-references/page.tsx`, `apps/web/components/master/customer-readiness.tsx`, `customer-detail-workspace.tsx`, `customer-first-route.tsx`, `customer-scoped-master-data.tsx`, `customer-setup-stepper.tsx`, `global-master-workspace.tsx`, dan `master-source-selector.tsx`.
- Pekerjaan: `apps/web/app/jobs/create/page.tsx`, `apps/web/app/jobs/[id]/page.tsx`, `apps/web/components/jobs/inspection-work-list.tsx`, `job-detail-tabs.tsx`, `job-creation-stepper.tsx`, serta `apps/web/types/job-detail-workspace.ts`.
- Review: seluruh page di `apps/web/app/review` yang disebut pada route compatibility dan `apps/web/components/reviews/review-workspace.tsx`.
- Laporan: `apps/web/app/reports/page.tsx` dan `apps/web/components/reports/document-report-workspace.tsx`.
- Pengaturan: `apps/web/app/settings/page.tsx`, `apps/web/app/settings/master-global/page.tsx`, dan `apps/web/components/settings/settings-workspace.tsx`.
- Reusable/responsive/testing: `apps/web/components/workflow/next-action-card.tsx`, `apps/web/app/globals.css`, `apps/web/playwright.config.ts`, dan `apps/web/e2e/README.md`.
- Dokumentasi: `docs/AUDIT_ADMIN_UX_RESTRUCTURE.md` dan `docs/ADMIN_UX_RESTRUCTURE_RESULT.md`.

`apps/web/next-env.d.ts`, `apps/web/components/reports/report-version-history.tsx`, backup database, serta dokumen lain pada status Git bukan bagian perubahan restrukturisasi ini; semuanya sudah ada pada worktree awal dan dipertahankan.

## Routes

### Reused/canonical

- `/dashboard`
- `/master/customers`, `/master/customers/create`, `/master/customers/customer/:customerId`
- `/master/iso-cedex`, `/master/inspection-references`
- `/jobs`, `/jobs/create`, `/jobs/:id`, `/jobs/:id/containers/import`
- `/review`, `/review/:id`
- `/reports`, `/reports/:id`, `/reports/versions`

### Added

- `/settings`
- `/settings/master-global`

### Legacy retained

- `/monitoring/surveys` dan `/surveys/monitoring`
- `/review/pending`, `/review/history`, `/review/need-revision`, dan `/review/approved`
- Route master lama tetap dapat dibuka walaupun navigasinya sekarang diarahkan melalui Customer & Master atau Pengaturan.

## Perubahan utama

### Navigasi dan information architecture

- `apps/web/constants/navigation-admin.ts` diubah menjadi enam link tingkat atas tanpa group submenu terpisah.
- Visibility tetap memakai role dan permission existing; active matching mencakup route canonical dan legacy.
- Contract test navigasi sekarang menolak entry lama/nested yang akan mengembalikan kepadatan sidebar.

### Customer & Master

- `apps/web/components/master/customer-readiness.tsx` menjadi landing Customer & Master dengan filter kesiapan berbasis `/customers/readiness`.
- `apps/web/components/master/customer-detail-workspace.tsx` menjadi satu setup workspace sembilan tahap.
- Komponen baru:
  - `customer-setup-stepper.tsx` untuk urutan, complete state, dan incomplete state dari readiness backend;
  - `master-source-selector.tsx` untuk menjelaskan sumber Customer override dan global fallback;
  - perluasan `customer-scoped-master-data.tsx` untuk memisahkan referensi severity/test dari Photo Evidence tanpa membuat mapping baru.
- Profil Customer tetap diedit lewat contract existing. Lokasi, PIC, mapping, Survey Type, Container Type, Checklist, CEDEX, dan reference options memakai API existing.
- Saat ready, Next Action menuju `/jobs/create?customerId=...`; saat belum ready, menuju tahap pertama yang belum lengkap.

### Pekerjaan Inspeksi

- Daftar Pekerjaan disederhanakan menjadi Semua, Draf, Belum Ditugaskan, Sedang Dikerjakan, Menunggu Review, Perlu Revisi, dan Selesai.
- `job-creation-stepper.tsx` mengikat alur create dan detail Job.
- Form create dapat menerima Customer dari query, lalu mengarahkan ke Job yang baru dibuat pada tahap Peti Kemas—tidak membuat Job kedua.
- Detail Job menambahkan confirmation summary, progress summary, contextual Next Action, tampilan size/ISO Type, dan aksi penugasan langsung untuk peti kemas terpilih.
- Hasil teknis Surveyor tetap read-only bagi Admin sesuai permission/backend authority.

### Review & Keputusan

- `apps/web/components/reviews/review-workspace.tsx` menggabungkan lima status dalam satu workspace.
- `/review` menjadi route canonical.
- `/review/pending`, `/review/history`, `/review/need-revision`, dan `/review/approved` tetap hidup sebagai redirect compatibility.
- Detail Review kembali ke workspace canonical setelah keputusan.

### Laporan

- `document-report-workspace.tsx` sekarang hanya mengekspos tab Aktif dan Arsip.
- Klasifikasi memakai status metadata report existing.
- UI menyatakan PDF final, QR, dan public verification belum aktif; fitur tersebut tidak disimulasikan.

### Pengaturan dan Master Global

- Route baru `/settings` menyatukan kartu Surveyor GIFT, Master Global, User & Hak Akses, Penomoran, Company Profile, dan Audit Log secara permission-aware.
- Route baru `/settings/master-global` mengorkestrasi CEDEX, Checklist, Container Type, Survey Type, Photo Category, dan Referensi Pemeriksaan dari komponen/route existing.
- Checklist global tidak diklaim memiliki inheritance karena backend belum menyediakan contract fallback yang setara dengan effective CEDEX. UI mengarahkan konfigurasi checklist ke scope Customer yang nyata.

### Responsive dan reusable UI

- Style baru pada `apps/web/app/globals.css` membuat stepper, source flow, cards, actions, dan confirmation grid berubah dari multi-column ke dua kolom dan satu kolom tanpa overflow horizontal.
- `next-action-card.tsx` menyediakan pola CTA reusable untuk setup dan pekerjaan.
- Konfigurasi Playwright ditambah viewport 412x915 dan 1920x1080 sehingga enam ukuran spesifikasi diuji.

## API dan backend yang dipakai ulang

| Area | Contract existing |
| --- | --- |
| Customer readiness | `GET /customers/readiness`, `GET /customers/:id/readiness` |
| Profil Customer | CRUD `/master/customers` |
| Lokasi/PIC/mapping | CRUD `/customers/:id/locations`, `/customers/:id/personnel`, GET/PUT mapping Location-PIC |
| Master per Customer | CRUD Survey Type, Container Type, Checklist Template, CEDEX, dan reference options di bawah `/customers/:id/...` |
| Global CEDEX | `/master/cedex/*` dan effective-master backend |
| Pekerjaan | GET/POST/PUT `/jobs`, GET `/jobs/:id` |
| Peti Kemas dan assignment | `/jobs/:id/containers`, import preview/confirm, validator check digit, `/jobs/:id/assign`, reassign existing |
| Monitoring dan Review | `/surveys/monitoring`, `/reviews`, `/reviews/pending`, `/reviews/:id/*` |
| Laporan | `/reports`, `/reports/:id`, `/reports/:id/versions` |

Backend `EvaluateReadinessTx` tetap menjadi hard gate untuk create/assignment/start Survey. Frontend hanya menyajikan readiness dan arahan dari data nyata.

## Dampak database dan permission

- Database impact: **tidak ada**.
- Migration/schema/baseline dump: **tidak diubah**.
- Permission baru/dihapus: **tidak ada**.
- Sidebar, workspace card, dan CTA difilter memakai permission existing.
- Direct URL tetap dilindungi `ProtectedRoute` dan backend middleware tetap menjadi authority.
- Keputusan teknis Review tetap pada role/permission existing.

## Verifikasi

| Pemeriksaan | Hasil |
| --- | --- |
| `npm run test:navigation --workspace apps/web` | PASS |
| `npm run test:iso-cedex --workspace apps/web` | PASS |
| `npm run test:survey-sheet --workspace apps/web` | PASS |
| `npm run typecheck --workspace apps/web` | PASS |
| `npm run lint --workspace apps/web` | PASS |
| `npm run build --workspace apps/web` | PASS; 76 route berhasil dibangun |
| `go test ./...` | PASS |
| `go vet ./...` | PASS |
| `npm run test:e2e:smoke --workspace apps/web` | PASS; 6/6 project Playwright melalui Microsoft Edge |
| Route HTTP smoke | PASS; 15/15 route canonical/legacy merespons HTTP 200 |
| `git diff --check` | PASS; hanya warning normalisasi LF/CRLF Windows |

In-app browser tidak dapat diinisialisasi karena metadata sandbox kehilangan `sandboxPolicy`. Sesuai fallback browser skill, verifikasi responsive dijalankan melalui Playwright repository setelah runner diizinkan membuat worker/Edge process. Bukti ini hanya mencakup usability dan overflow halaman login pada enam viewport; tidak dipakai untuk mengklaim UAT workflow terautentikasi.

## Responsive screens tested

Halaman `/login` diuji dengan Microsoft Edge melalui Playwright pada 360x800, 390x844, 412x915, 768x1024, 1366x768, dan 1920x1080. Pada keenam project, judul, field Email, field Password, tombol Masuk, dan pemeriksaan `scrollWidth <= clientWidth` lulus. Layar Admin terautentikasi belum diuji secara browser karena akun UAT tidak tersedia; responsive rules untuk sidebar drawer, Customer stepper, Job stepper, action, card, dan grid sudah tercakup oleh lint, typecheck, serta production build, tetapi tetap memerlukan UAT visual ketika fixture tersedia.

## Route compatibility yang diverifikasi

`/master/customers`, `/master/iso-cedex`, `/master/inspection-references`, `/jobs`, `/jobs/create`, `/monitoring/surveys`, `/surveys/monitoring`, `/review`, `/review/pending`, `/review/history`, `/review/need-revision`, `/review/approved`, `/reports`, `/settings`, dan `/settings/master-global` merespons HTTP 200 pada runtime lokal.

## Gap dan batas klaim

1. Kredensial dan fixture `E2E_*` tidak tersedia. UAT browser terautentikasi untuk setup Customer, create Job, assignment, review decision, dan report lifecycle belum dapat diklaim.
2. Checklist global fallback belum memiliki contract backend. Implementasi tidak mengarang inheritance; Checklist tetap customer-scoped.
3. Readiness backend belum mengekspos check terpisah yang menyatakan mapping Lokasi-PIC sebagai item progress. UI menyediakan mapping tetapi tidak membuat persentase/check palsu.
4. Kontrak report masih metadata-only. PDF final, QR, public verification, Finance, Billing, Workshop, Gate-Out, dan VGM tetap nonaktif.
5. Istilah/fitur domain yang tidak mempunyai active master atau contract—termasuk Cleanliness, Cu-Cap, TCT, dan 3rd Scty Sys—tidak dibuat sebagai data hardcoded.
6. Keputusan bahwa workflow benar secara operasional tetap membutuhkan fixture UAT dan akun per role; build atau smoke anonymous bukan pengganti bukti tersebut.

## Worktree dan publikasi

Perubahan lain yang sudah ada sebelum implementasi—termasuk `apps/web/next-env.d.ts`, `apps/web/components/reports/report-version-history.tsx`, backup database, dan dokumen lama—dipertahankan. Tidak dilakukan reset atau clean. Commit dan push ke `main` hanya mencakup 39 file restrukturisasi setelah ada instruksi publikasi terpisah dari pengguna.
