# Admin Menu Final UAT Matrix

Tanggal UAT: 23 Juli 2026

Evidence utama:

- `screenshots/admin-menu-finalization/api-uat-results.json`
- `screenshots/admin-menu-finalization/browser-uat-results.json`
- `screenshots/admin-menu-finalization/01-sidebar-admin-desktop.png` sampai `15-zoom-200.png`

| No | Area | Route | Role | Scenario | Expected | Actual | Status | Evidence | Issue |
| ---: | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Git baseline | Git/local/remote | N/A | Bandingkan HEAD, origin/main lokal, remote live | SHA sama | Seluruhnya `6b86cb92999879226247295fc2a8e2dd0b43041f` | PASS | Laporan §2 | - |
| 2 | IA Admin | Sidebar | Admin | Enam grup utama dan permission filtering | Struktur tetap, tidak kosong | Enam grup tetap; menu kosong tidak tampil | PASS | `01-sidebar-admin-desktop.png` | - |
| 3 | Active state | 35 route | Admin | Active sidebar | Maksimal satu item | Satu item pada seluruh route | PASS | `browser-uat-results.json` | - |
| 4 | ISO CEDEX | `/master/iso-cedex` | Admin | Enam tab | Seluruh tab tersedia | Location, Component, Damage, Action Repair, Material, Responsibility | PASS | `03-iso-cedex-location.png`, `04-iso-cedex-action-repair.png` | - |
| 5 | ISO navigation | `/master/iso-cedex?tab=action-repair` | Admin | Back/forward/refresh | Query tab bertahan | Location ↔ Action Repair dan refresh benar | PASS | `browser-uat-results.json` | - |
| 6 | ISO compatibility | `/master/cedex/*` | Admin | Route lama | Redirect ke tab benar | Enam mapping benar | PASS | `browser-uat-results.json` | - |
| 7 | Inspection references | `/master/inspection-references` | Admin | Enam tab | Struktur tetap | Enam tab tersedia | PASS | `05-referensi-pemeriksaan-checklist.png` | - |
| 8 | Customer Detail | `/master/customers/customer/:id` | Admin | Empat tab | Profil, Personel/PIC, Location, Riwayat | Empat tab tersedia | PASS | `06-customer-personel-pic.png`, `07-customer-location.png` | - |
| 9 | UI copy | 35 route Admin | Admin | Frasa teknis/internal tidak tampil | Tidak ada diskusi implementasi | Tidak ada match pada DOM ter-render | PASS | `browser-uat-results.json` | - |
| 10 | Accessible names | 35 route | Admin | Visible form controls | Seluruhnya bernama | 0 control tanpa accessible name | PASS | `browser-uat-results.json` | - |
| 11 | Heading/ID | 35 route | Admin | H1 dan duplicate ID | Satu H1, ID unik | Seluruh route lulus | PASS | `browser-uat-results.json` | - |
| 12 | Keyboard focus | `/review/history` | Admin | Fokus filter | Indikator terlihat | Outline solid 2 px | PASS | `14-focus-keyboard-filter.png` | - |
| 13 | Zoom | `/master/iso-cedex` | Admin | Page scale 200% | Tetap usable, tidak overflow | Tidak ada body overflow | PASS | `15-zoom-200.png` | - |
| 14 | WCAG contrast | Route Admin | Admin | Audit contrast penuh | Tool khusus dijalankan | Tidak dijalankan | BLOCKED | Laporan §9 | Audit terpisah diperlukan |
| 15 | Customer CRUD | `/master/customers` | Admin | Create/read/update/inactive/duplicate | Persistence dan validasi | Seluruh skenario lulus; duplicate 409 | PASS | `api-uat-results.json` | - |
| 16 | Personel/PIC | `/customers/:id/personnel` | Admin | Create/inactive/reactivate | Customer-scoped | Seluruh skenario lulus | PASS | `api-uat-results.json` | - |
| 17 | Location | `/customers/:id/locations` | Admin | Create dan isolation | Customer-scoped | Persistence lulus | PASS | `api-uat-results.json` | - |
| 18 | Customer isolation | `/jobs` | Admin | Pakai Location/PIC Customer lain | Ditolak | HTTP 422 | PASS | `api-uat-results.json` | - |
| 19 | ISO CRUD | `/customers/:id/cedex/*` | Admin | Enam resource, duplicate, inactive | Persistence dan isolation | Create lulus; duplicate 409; isolation lulus | PASS | `api-uat-results.json` | - |
| 20 | Inspection CRUD | `/customers/:id/*`, `/fitness/master-data/*` | Admin | Container Type, Survey Type, Checklist, Test, Photo, Severity | Persistence dan relation | Seluruh resource/relation lulus | PASS | `api-uat-results.json` | - |
| 21 | Checklist | `/customers/:id/checklist-templates` | Admin | Template + item + activate | Item aktif sebelum template aktif | Lulus | PASS | `api-uat-results.json` | - |
| 22 | Create Job | `POST /jobs` | Admin | Customer → PIC → Location → Survey Type | HTTP 201 | HTTP 201 | PASS | `api-uat-results.json` | - |
| 23 | Add Container | `POST /jobs/:id/containers` | Admin | Insert 19 field | HTTP 201 dan field sejajar | 201; override, type ID, ISO code benar | PASS | `api-uat-results.json` | - |
| 24 | Import preview | `POST /jobs/:id/containers/import/preview` | Admin | CSV satu baris | Satu valid | 1 valid, 0 gagal | PASS | `api-uat-results.json` | - |
| 25 | Import confirm | `POST /jobs/:id/containers/import/confirm` | Admin | Persist preview | Satu imported | 1 imported, 0 gagal | PASS | `api-uat-results.json` | - |
| 26 | Assignment | `POST /jobs/:id/assign` | Admin | Assign dua Container | Hanya Surveyor GIFT aktif | Dua Container assigned | PASS | `api-uat-results.json` | - |
| 27 | Master options | `GET /surveys/:id/master-options` | Surveyor | Query MySQL aktual | HTTP 200, scoped refs | 200 dan isi benar | PASS | `api-uat-results.json` | - |
| 28 | Checklist runtime | `GET /surveys/:id/checklist` | Surveyor | Snapshot template aktif | HTTP 200 dan item ada | 200, item tersedia | PASS | `api-uat-results.json` | - |
| 29 | Damage create | `POST /surveys/:id/damages` | Surveyor | Counter MySQL | HTTP 201 | HTTP 201 | PASS | `api-uat-results.json` | - |
| 30 | Damage update | `PUT /survey-damages/:id` | Surveyor | Update damage | HTTP 200 | HTTP 200 | PASS | `api-uat-results.json` | - |
| 31 | Damage delete | `DELETE /survey-damages/:id` | Surveyor | Soft delete damage | HTTP 200 | HTTP 200 | PASS | `api-uat-results.json` | - |
| 32 | Need Revision | `POST /reviews/:id/need-revision` | Supervisor | Kembalikan survey | HTTP 200 | HTTP 200 | PASS | `api-uat-results.json` | - |
| 33 | Resubmit | `POST /surveys/:id/submit` | Surveyor | Submit setelah revisi | HTTP 200 | HTTP 200 | PASS | `api-uat-results.json` | - |
| 34 | Approve | `POST /reviews/:id/approve` | Supervisor | Approve tanpa PDF/QR | HTTP 200 | HTTP 200 | PASS | `api-uat-results.json` | - |
| 35 | Reject | `POST /reviews/:id/reject` | Supervisor | Reject survey kedua | HTTP 200 | HTTP 200 | PASS | `api-uat-results.json` | - |
| 36 | Management read | `/reports`, `/reports/:id`, versions | Management | Read-only report | HTTP 200 | Seluruh GET 200 | PASS | `api-uat-results.json`, `12-laporan-management.png` | - |
| 37 | Management mutation | `POST /reviews/:id/approve` | Management | Mutation ditolak | HTTP 403 | HTTP 403 | PASS | `api-uat-results.json` | - |
| 38 | Permission enrichment | `/reports` | Management | Tidak ada hidden unauthorized call | Tidak ada 4xx/5xx | 0 network failure | PASS | `browser-uat-results.json` | - |
| 39 | Auto-queue report | Approve `generate_report=false` | Supervisor | Metadata report | Catat tanpa perubahan bisnis | Tetap `queued` | DECISION_REQUIRED | `api-uat-results.json` | Perlu keputusan bisnis |
| 40 | Object storage | Photo upload | Surveyor | Upload foto | MinIO tersedia | MinIO tidak diaktifkan | BLOCKED | Laporan §18 | Environment dependency |
| 41 | Surveyor sanity | `/surveyor/jobs` | Surveyor | Menu dan pekerjaan assigned | Tidak rusak | Login, route, start survey lulus | PASS | `browser-uat-results.json`, `api-uat-results.json` | - |
| 42 | Responsive desktop | ISO CEDEX | Admin | 1920, 1440, 1366, 1280, 1024 | Tidak overflow | Seluruhnya lulus | PASS | `browser-uat-results.json` | - |
| 43 | Responsive tablet/mobile | ISO CEDEX/sidebar | Admin | 768×1024, 390×844 | Drawer/tab usable | Tidak overflow | PASS | `02-sidebar-admin-mobile.png`, `browser-uat-results.json` | - |
| 44 | Favicon redirect | `/favicon.ico` | Public | Asset tersedia | Tidak 404 | 307 → image/png 200 | PASS | Laporan §14 | - |
| 45 | Runtime browser | 35 route | Semua role | Console/runtime/network | Nol error | 0 console/runtime, 0 4xx/5xx | PASS | `browser-uat-results.json` | - |
| 46 | Go API | `services/api` | N/A | `go test ./...` | Exit 0 | Exit 0, 12.5 dtk | PASS | Laporan §15 | - |
| 47 | Go Worker | `services/worker` | N/A | `go test ./...` | Exit 0 | Exit 0, 1.0 dtk | PASS | Laporan §15 | - |
| 48 | Web typecheck | root | N/A | workspace typecheck | Exit 0 | Exit 0, 12.5 dtk | PASS | Laporan §15 | - |
| 49 | Web build | root | N/A | production build | Exit 0 | Exit 0, 69 pages/routes | PASS | Laporan §15 | - |
| 50 | Whitespace | root | N/A | `git diff --check` | Exit 0 | Exit 0 | PASS | Laporan §15 | - |
| 51 | CI definition | `.github/workflows/validate.yml` | GitHub | Workflow minimal tersedia | Job unit/integration/web/whitespace | Workflow tersedia | PASS | Laporan §16 | - |
| 52 | CI execution | GitHub Actions | N/A | Workflow berjalan | Check-run tersedia | Belum berjalan karena tidak commit/push | BLOCKED | Laporan §16 | Scope melarang publish |
| 53 | Screenshot set | `docs/screenshots/admin-menu-finalization` | Semua role | 15 bukti baru | Seluruh file ada | 15 PNG valid | PASS | Folder screenshot | - |
| 54 | Publish guard | Git | N/A | Tidak commit/push | Worktree tetap lokal | Tidak ada commit/push | PASS | Laporan §1 | - |
