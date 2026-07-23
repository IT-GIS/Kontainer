# Laporan Finalisasi Menu Admin ISO CEDEX

Tanggal verifikasi: 23 Juli 2026 (Asia/Jakarta)

## 1. Status ringkas

Scope Admin pada prompt ini memenuhi Definition of Done tanpa temuan `FAIL`. UAT API menghasilkan 77 `PASS`, satu `BLOCKED` untuk ketergantungan MinIO di sisi Surveyor, dan satu `DECISION_REQUIRED` untuk metadata report yang tetap berstatus `queued` ketika approval memakai `generate_report=false`. UAT browser menghasilkan 35 route `PASS`, 15 screenshot baru, nol error console/runtime, dan nol respons jaringan 4xx/5xx.

Tidak ada commit, push, reset, stash, clean, rebase, amend, maupun restore menyeluruh yang dilakukan.

## 2. Baseline Git dan GitHub

| Item | Hasil |
| --- | --- |
| Repository | `IT-GIS/Kontainer` |
| Branch | `main` |
| HEAD awal/akhir | `6b86cb92999879226247295fc2a8e2dd0b43041f` |
| `origin/main` lokal | `6b86cb92999879226247295fc2a8e2dd0b43041f` |
| `origin/main` live (`git ls-remote`) | `6b86cb92999879226247295fc2a8e2dd0b43041f` |
| Commit terbaru | `6b86cb9 fix: make survey damage numbering MySQL compatible` |
| Baseline pembanding prompt | `12320f095ed54f357634f584f3b83cad61c1681f` |
| Staged awal | Tidak ada |
| Staged akhir | Tidak ada |
| Commit/push | Tidak dilakukan |

Perintah audit yang benar-benar dijalankan:

- `git status`
- `git branch --show-current`
- `git log -5 --oneline`
- `git rev-parse HEAD`
- `git rev-parse origin/main`
- `git diff --stat`
- `git diff --name-status`
- `git diff 12320f095ed54f357634f584f3b83cad61c1681f --stat`
- `git diff 12320f095ed54f357634f584f3b83cad61c1681f -- services/api`
- `git diff 12320f095ed54f357634f584f3b83cad61c1681f -- apps/web`
- `git ls-remote origin refs/heads/main`

## 3. Worktree awal dan perlindungan pekerjaan pengguna

Worktree sudah kotor sebelum finalisasi: 23 file tracked tercatat berubah, tidak ada staged change, dan terdapat file untracked dokumentasi, screenshot, source customer-scoped, serta migration `0011`. Perubahan tersebut diperlakukan sebagai pekerjaan pengguna dan tidak dibuang.

Audit akhir mencatat 41 tracked changes dan 24 untracked entries pada output ringkas Git, dengan 0 staged file. Angka akhir mencakup pekerjaan pengguna yang dipertahankan beserta source, test, workflow, dua laporan, dan bukti screenshot finalisasi ini. Worktree sengaja tetap kotor karena prompt melarang commit.

Area dirty yang sudah ada meliputi:

- frontend Admin Kelaikan dan Surveyor;
- navigasi/type Surveyor;
- Docker Compose;
- backend Jobs, Master Data, dan Surveyor;
- `customer_reference_options.go` dan `customer_scope.go`;
- migration customer-scoped `0011`;
- laporan, prompt, dan screenshot terdahulu.

Build sempat mengubah generated file `apps/web/next-env.d.ts`. Baris generated itu dikembalikan secara sempit ke isi baseline; hash file akhir sama dengan hash `HEAD` (`c4b7818fbb2c2c34c24feb1b627ee824507c5600`). Tidak ada file pengguna lain yang dikembalikan.

## 4. Information architecture Admin

`apps/web/constants/navigation-admin.ts` tidak diubah. Enam grup utama tetap:

1. Dashboard
2. Pekerjaan Inspeksi
3. Master Data
4. Review & Keputusan
5. Dokumen & Laporan
6. Pengaturan

Hasil audit browser:

- satu active sidebar item pada seluruh 35 route yang diuji;
- grup kosong tidak tampil setelah permission filtering;
- ISO CEDEX tetap satu menu;
- Referensi Pemeriksaan tetap satu menu;
- Import Peti Kemas dan Assign Surveyor tidak menjadi submenu;
- QR Validation tidak muncul sebagai menu aktif;
- Surveyor GIFT tetap berada di Pengaturan;
- Personel/PIC Customer tetap terpisah dari Surveyor GIFT;
- Surveyor hanya melihat navigasi Surveyor pada sanity check.

## 5. Struktur halaman yang dipertahankan

### ISO CEDEX

Canonical route: `/master/iso-cedex`.

Enam tab tetap tersedia:

- Location Code
- Component Code
- Damage Code
- Action Repair Code
- Material Code
- Responsibility Code

Route kompatibilitas `/master/cedex/*` dan `/master/responsibility-codes` mengarah ke tab yang benar. Back, forward, refresh, query tab, customer picker, dan satu active sidebar item lulus browser UAT.

### Referensi Pemeriksaan

Canonical route: `/master/inspection-references`.

Enam tab tetap tersedia:

- Container Type
- Survey Type
- Checklist
- Test Parameter
- Photo Category
- Finding Severity

### Customer Detail

Canonical route: `/master/customers/customer/:customerId`.

Empat tab tetap tersedia:

- Profil Customer
- Personel/PIC
- Location Pemeriksaan
- Riwayat Pekerjaan

## 6. File finalisasi yang diubah

### Frontend

- `apps/web/app/globals.css`
- `apps/web/app/layout.tsx`
- `apps/web/app/master/inspection-references/page.tsx`
- `apps/web/app/master/iso-cedex/page.tsx`
- `apps/web/app/reports/qr-validation/page.tsx`
- `apps/web/app/settings/users/page.tsx`
- `apps/web/components/jobs/inspection-work-list.tsx`
- `apps/web/components/jobs/job-detail-tabs.tsx`
- `apps/web/components/layout/app-shell.tsx`
- `apps/web/components/master/checklist-reference-tab.tsx`
- `apps/web/components/master/customer-detail-workspace.tsx`
- `apps/web/components/master/customer-first-route.tsx`
- `apps/web/components/master/customer-scoped-master-data.tsx`
- `apps/web/components/master/master-data-page.tsx`
- `apps/web/components/reports/document-report-workspace.tsx`
- `apps/web/components/surveys/survey-list-page.tsx`
- `apps/web/components/surveys/surveyor-survey-list.tsx`
- `apps/web/constants/fitness-master-data-client-first.ts`

### Backend

- `services/api/internal/jobs/repository.go`

File backend lain yang sudah dirty sebelum finalisasi tetap dipertahankan. Perubahan finalisasi pada repository Jobs hanya mengekstrak query/argumen Add Container agar urutan 19 kolom dan 19 argumen dapat diuji tanpa mengubah perilaku bisnis.

## 7. File baru

- `.github/workflows/validate.yml`
- `apps/web/app/favicon.ico/route.ts`
- `services/api/internal/jobs/repository_regression_test.go`
- `services/api/internal/surveyor/helpers_regression_test.go`
- `docs/ADMIN_MENU_FINALIZATION_REPORT.md`
- `docs/ADMIN_MENU_FINAL_UAT_MATRIX.md`
- `docs/screenshots/admin-menu-finalization/api-uat-results.json`
- `docs/screenshots/admin-menu-finalization/browser-uat-results.json`
- 15 PNG di `docs/screenshots/admin-menu-finalization/`

## 8. Pembersihan copy internal

Copy final pada route Admin aktif tidak lagi menampilkan diskusi implementasi seperti source/API existing, ownership, worktree, backend, schema, migration, compatibility route, atau field existing. Browser UAT memeriksa teks yang dirender pada 35 route dan tidak menemukan frasa terlarang.

Contoh copy bisnis yang diterapkan:

- `Master ISO CEDEX — Kelola referensi kode yang digunakan dalam pencatatan hasil pemeriksaan peti kemas.`
- `Data ISO CEDEX ditampilkan sesuai Customer yang dipilih.`
- `Gunakan kode lokasi yang telah disahkan dalam referensi teknis GIFT.`
- `Action Repair Code digunakan sebagai referensi atau rekomendasi tindakan pemeriksaan.`
- copy Customer, pekerjaan, laporan, dan compatibility page dinyatakan dalam konteks bisnis, bukan status implementasi.

Action Repair tetap hanya referensi/rekomendasi teknis; tidak dibentuk sebagai proses bengkel, work order, inventory, atau billing.

## 9. Accessibility

### Label dan ARIA — PASS

- search input dan seluruh filter status/role/keputusan mempunyai accessible name;
- placeholder bukan satu-satunya label;
- icon-only button mempunyai `aria-label`;
- error form terhubung dengan `aria-describedby` dan menggunakan `role="alert"`;
- status mempunyai teks, bukan hanya warna;
- satu H1 per route;
- tidak ada duplicate ID pada route yang diuji;
- audit DOM browser menemukan nol visible control tanpa accessible name pada 35 route dan tujuh viewport.

### Keyboard/focus — PASS

Filter difokuskan melalui keyboard automation. Computed style menghasilkan `outline-style: solid` dan `outline-width: 2px`. CSS fokus eksplisit ditambahkan untuk search/filter wrapper dan input.

### Zoom 200% — PASS

Emulasi page scale 200% pada ISO CEDEX mempertahankan satu H1 dan tidak menghasilkan horizontal body overflow. Screenshot khusus tersedia.

### Contrast — BLOCKED

Audit WCAG contrast penuh dengan alat khusus tidak dijalankan. Karena itu laporan ini tidak menyatakan accessibility WCAG penuh. Label/ARIA, focus, struktur heading, duplicate ID, dan zoom dilaporkan terpisah berdasarkan pemeriksaan yang benar-benar dijalankan.

## 10. Verifikasi backend pada MySQL aktual

UAT API menggunakan source terkini di `127.0.0.1:8081` dan database MySQL Laragon aktual. Hasil terstruktur: 79 pemeriksaan, terdiri dari 77 `PASS`, satu `BLOCKED`, dan satu `DECISION_REQUIRED`.

### Add Container — PASS

- `POST /jobs/:id/containers` menghasilkan HTTP 201;
- record dibaca kembali dari database;
- `check_digit_override_reason` sama dengan input;
- `container_type_id` tidak bergeser;
- `iso_type_code` berasal dari Container Type database, bukan nilai pengalih pada request;
- regression test memverifikasi 19 kolom, 19 placeholder berurutan, dan seluruh urutan argumen.

### Master Options dan Checklist — PASS

- `GET /surveys/:id/master-options` menghasilkan HTTP 200 pada MySQL aktual;
- nama Container Type dikembalikan dari query `container_types.type_name` melalui alias bisnis;
- assignment memakai `assignments.due_date`;
- opsi CEDEX dan reference mapping hanya berasal dari Customer/Survey Type uji;
- `GET /surveys/:id/checklist` menghasilkan HTTP 200 dan snapshot item aktif tersedia;
- regression test menolak penggunaan `ct.name` dan `a.due_at`.

### Damage Counter — PASS

- `POST /surveys/:id/damages` menghasilkan HTTP 201;
- `PUT /survey-damages/:id` menghasilkan HTTP 200;
- `DELETE /survey-damages/:id` menghasilkan HTTP 200;
- implementasi dan regression test memastikan urutan `INSERT IGNORE`, `UPDATE last_number`, lalu `SELECT last_number` tanpa asumsi kolom `id` atau `RETURNING`.

Tidak ada migration atau perubahan schema yang dibuat untuk penutupan bug ini.

## 11. CRUD, isolation, pekerjaan, review, dan laporan

### Customer dan Customer isolation — PASS

- create, read, update, inactive/reactivate, duplicate rejection, dan persistence lulus;
- Personel/PIC dan Location milik Customer A dipakai dalam Job A;
- Job dengan Location/Personel Customer B ditolak HTTP 422;
- kode CEDEX yang sama dapat dibuat pada Customer berbeda;
- list Customer A tidak memuat record CEDEX Customer B;
- data sintetis final ditinggalkan berstatus inactive; empat Customer dari dua percobaan UAT yang berhenti lebih awal juga dinonaktifkan secara terarah.

### ISO CEDEX dan Referensi Pemeriksaan — PASS

- enam resource ISO CEDEX berhasil dibuat dan dibaca;
- duplicate dalam Customer sama ditolak HTTP 409;
- Action Repair diuji inactive lalu reactivate;
- Container Type, Survey Type, Checklist Template, Checklist Item, Test Parameter, Photo Category, dan Finding Severity berhasil dibuat;
- reference options Survey Type dipetakan ke Severity, Test Parameter, dan Photo Category;
- checklist diaktifkan setelah memiliki item aktif;
- satu record disposable diuji DELETE/deactivate.

Tidak ada seed, nilai ambang, metode uji, referensi standar, kode regulasi, atau data CEDEX produksi yang dikarang. Semua record UAT memakai prefix/suffix sintetis yang eksplisit.

### Pekerjaan Inspeksi — PASS

- Create Job HTTP 201;
- dependent Customer references tervalidasi backend;
- Add Container HTTP 201 dan persistence lulus;
- CSV import preview satu baris valid;
- import confirm satu berhasil, nol gagal;
- dua Container ditugaskan hanya ke profil Surveyor GIFT aktif;
- Assignment menyimpan `start_date` dan `due_date` aktual.

### Review & Keputusan — PASS

- Surveyor memulai dua survei dan mengisi general info/checklist;
- submit awal lulus;
- Supervisor menjalankan Need Revision;
- Surveyor resubmit;
- Supervisor Approve;
- survei kedua disubmit lalu Reject;
- Supervisor dapat membaca riwayat review;
- Management mutation ditolak HTTP 403.

Keputusan akhir Kelaikan tidak diubah menjadi otomatis berdasarkan Finding Severity.

### Dokumen & Laporan — PASS / DECISION_REQUIRED

- Supervisor dan Management dapat membuka laporan sesuai permission;
- Management membaca list, detail, dan versi report;
- browser Management pada `/reports` tidak menghasilkan request 4xx/5xx, sehingga permission-aware enrichment tidak memanggil endpoint yang tidak berizin;
- approval dengan `generate_report=false` tetap membuat metadata report `queued`: `DECISION_REQUIRED` sesuai prompt;
- PDF, QR aktif, dan public verification tidak dipicu.

## 12. Route compatibility dan browser UAT

Browser UAT dijalankan pada server development source terkini karena konfigurasi CORS lokal mengizinkan origin tersebut. Build produksi source yang sama diverifikasi terpisah. Kontrol browser bawaan berhenti sebelum sesi dibuat karena metadata sandbox tidak lengkap; fallback Chrome headless terisolasi via Chrome DevTools Protocol digunakan dan menghasilkan bukti baru.

Hasil:

- 35 route diuji;
- 35 `PASS`;
- 0 route 404/blank;
- 0 active sidebar ganda;
- 0 duplicate ID;
- 0 visible control tanpa accessible name;
- 0 browser console/runtime error;
- 0 network response 4xx/5xx;
- back/forward/refresh ISO CEDEX lulus;
- Admin, Supervisor, Management, dan Surveyor login berhasil.

Redirect penting yang terbukti:

- `/master/locations` → `/master/customers?tab=location&compat=locations`
- `/master/container-types` → `/master/inspection-references?tab=container-type`
- `/master/survey-types` → `/master/inspection-references?tab=survey-type`
- `/master/cedex/repairs` → `/master/iso-cedex?tab=action-repair`
- `/jobs/import` dan `/jobs/assign` → view kompatibilitas pada `/jobs`
- `/surveys/monitoring/*` → view status yang tepat pada `/jobs`
- `/reports/versions` → `/reports?view=archive&compat=versions`
- `/settings/roles` → `/settings/users#role-permission`

Daftar lengkap final URL berada di `browser-uat-results.json`.

## 13. Responsive

Viewport yang diuji:

- 1920 × 1080
- 1440 × 900
- 1366 × 768
- 1280 × 720
- 1024 × 768
- 768 × 1024
- 390 × 844

Ketujuh viewport menghasilkan:

- tidak ada horizontal body overflow;
- satu H1;
- tidak ada duplicate ID;
- tidak ada visible control tanpa accessible name;
- mobile drawer dapat dibuka dan ditutup;
- tab tetap dapat digunakan;
- page scale 200% tidak overflow.

## 14. Favicon

`/favicon.ico` kini ditangani oleh route minimal yang mengarahkan ke logo GIFT yang sudah ada.

- request tanpa mengikuti redirect: HTTP 307 ke `/images/gift-logo.png`;
- request dengan redirect: HTTP 200, `image/png`;
- metadata Next.js juga mendeklarasikan icon dan shortcut icon;
- build manifest memuat route `/favicon.ico`.

## 15. Validasi teknis lokal

| Command | Exit | Durasi | Hasil |
| --- | ---: | ---: | --- |
| `cd services/api; go test ./...` | 0 | 12.5 dtk | PASS |
| `cd services/worker; go test ./...` | 0 | 1.0 dtk | PASS |
| `npm run typecheck --workspace apps/web` | 0 | 12.5 dtk | PASS |
| `npm run build --workspace apps/web` | 0 | 43.3 dtk | PASS, 69 static pages/routes |
| `node .tmp/admin-menu-finalization/api-uat.mjs` | 0 | 1.7 dtk | 77 PASS, 1 BLOCKED, 1 DECISION_REQUIRED |
| `node .tmp/admin-menu-finalization/browser-uat.mjs` | 0 | 121.5 dtk | 35 route PASS, 15 screenshot |
| `git diff --check` | 0 | dicatat setelah laporan | PASS |

Build pertama di sandbox selesai kompilasi tetapi gagal membuat child process dengan `spawn EPERM`; command yang sama dijalankan ulang pada execution context yang diizinkan dan lulus penuh. Ini merupakan kendala execution context Windows, bukan kegagalan source.

Diagnostic tambahan `npm run lint --workspace apps/web` dijalankan tetapi bukan closure command yang diwajibkan prompt. Hasilnya exit 1 dengan sembilan error dan satu warning React rule pada gabungan file existing/user-dirty, termasuk area Admin Kelaikan yang berada di luar IA prompt ini. Typecheck dan production build tetap lulus. Hasil lint tidak disamarkan dan tidak digunakan untuk mengklaim lint pass.

## 16. CI GitHub

Workflow baru: `.github/workflows/validate.yml`.

Job:

- `go-unit`: Go API dan Worker tests;
- `mysql-integration`: MySQL 8.4 service, seluruh migration test, lalu Master Data smoke test;
- `web`: `npm ci`, web typecheck, dan production build;
- `whitespace`: `git diff --check`.

Workflow tidak memuat secret, credential produksi, token, file `.env`, atau password produksi. MySQL CI memakai database `kontainer_test` dan empty-password service khusus runner.

Status CI: `BLOCKED` — workflow tersedia tetapi belum pernah berjalan karena scope melarang commit dan push. Tidak ada klaim CI pass.

## 17. Screenshot

Folder: `docs/screenshots/admin-menu-finalization/`.

1. `01-sidebar-admin-desktop.png`
2. `02-sidebar-admin-mobile.png`
3. `03-iso-cedex-location.png`
4. `04-iso-cedex-action-repair.png`
5. `05-referensi-pemeriksaan-checklist.png`
6. `06-customer-personel-pic.png`
7. `07-customer-location.png`
8. `08-pekerjaan-inspeksi.png`
9. `09-create-job.png`
10. `10-detail-job-assignment.png`
11. `11-review-supervisor.png`
12. `12-laporan-management.png`
13. `13-user-hak-akses.png`
14. `14-focus-keyboard-filter.png`
15. `15-zoom-200.png`

## 18. Blockers dan deferred decisions

### BLOCKED — Object storage/MinIO

MinIO tidak diaktifkan. Photo upload Surveyor tidak diklaim lulus. Dependency ini berada di sisi Surveyor dan tidak menghalangi struktur/fungsi menu Admin, tetapi tetap menghalangi alur aplikasi end-to-end yang memerlukan foto.

### BLOCKED — WCAG contrast penuh

Tidak ada tool audit contrast khusus yang dijalankan. Hanya label/ARIA, focus, heading, duplicate ID, dan zoom yang dinyatakan lulus.

### BLOCKED — CI belum berjalan

Workflow tersedia tetapi tidak dijalankan karena tidak ada commit/push.

### DECISION_REQUIRED — auto-queue report

Backend tetap membuat metadata report `queued` pada approval dengan `generate_report=false`. Perilaku tidak diubah tanpa keputusan bisnis.

### Deferred architecture

Keputusan Global CEDEX + Aktivasi Customer tetap ditunda. Scope ini mempertahankan customer-scoped behavior.

## 19. Definition of Done

Seluruh 30 butir Definition of Done pada prompt terpenuhi untuk scope Admin. Tidak ada `FAIL` pada scope Admin. Tiga `BLOCKED` dilaporkan jujur untuk MinIO Surveyor, contrast audit penuh, dan CI yang belum berjalan; satu `DECISION_REQUIRED` dilaporkan untuk auto-queue report. Tidak ada commit atau push.
