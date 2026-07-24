# Laporan Penyesuaian Menu Admin dan Database 15

Tanggal audit dan implementasi: 24 Juli 2026
Status keseluruhan: **PARTIAL** - perbaikan MySQL dan seluruh validasi CI-equivalent lokal lulus. Publikasi ke `origin/main` kemudian diotorisasi melalui instruksi terpisah; status workflow GitHub commit perbaikan harus diverifikasi di remote dan tidak diasumsikan hijau.

## 1. Ruang lingkup dan batas pekerjaan

Pekerjaan dilakukan pada workspace Admin Sistem Kelaikan Peti Kemas dengan alur canonical:

`Customer → Job/SPK → Peti Kemas → Penugasan Surveyor GIFT → Pemeriksaan → Review → Laporan/Arsip`

Batas yang dipertahankan:

- Finance, workshop, Gate-Out, billing, tarif repair, inventory, dan spare part tidak diaktifkan pada menu Admin Kelaikan.
- Action Repair tetap merupakan referensi/rekomendasi teknis, bukan proses bengkel.
- Final PDF, QR, public verification, dan antrean report otomatis tidak diaktifkan.
- Data legacy dan tabel lama tidak dihapus.
- Tidak dibuat seed CEDEX, checklist, metode uji, atau nilai ambang berdasarkan asumsi.
- Personel/PIC Customer tetap terpisah dari Surveyor GIFT.
- Validasi awal dilakukan tanpa commit/push; publikasi ke `origin/main` baru dilakukan setelah pengguna memberi instruksi terpisah.

## 2. Baseline Git dan worktree

| Pemeriksaan | Hasil |
|---|---|
| Repository | `IT-GIS/Kontainer` |
| Branch | `main` |
| HEAD awal | `fa5a9da550f596d01a6b1aa7d8805181875331e3` |
| `origin/main` awal | `fa5a9da550f596d01a6b1aa7d8805181875331e3` |
| Commit | `feat: align admin workflow with DB15` |
| Paritas awal | HEAD lokal sama dengan `origin/main` |
| Status awal | Dirty; perubahan existing diperlakukan sebagai pekerjaan pengguna |
| Status sebelum publikasi | Dirty; perubahan existing pengguna dipisahkan dari scope commit perbaikan |

Perubahan existing yang terdeteksi sebelum tugas dan tidak ditimpa sebagai bagian pekerjaan ini:

- `.gitignore`
- `apps/web/app/fitness/master-data/[category]/[clientId]/page.tsx`
- `apps/web/app/fitness/master-data/[category]/page.tsx`
- `apps/web/constants/navigation-surveyor.ts`
- `infra/docker/docker-compose.yml`
- `apps/web/components/reports/report-version-history.tsx`
- dokumen dan screenshot customer-first/master-data yang sudah untracked sebelum tugas

File `apps/web/next-env.d.ts` sempat berubah otomatis saat build dan telah dikembalikan ke baseline, sehingga tidak menjadi perubahan tugas.

## 3. Audit langsung `kontainer_db (15).sql`

Sumber: `C:\Users\Thinkpad X390\Downloads\kontainer_db (15).sql`
Ukuran: 592.005 byte
Metadata dump: 23 Juli 2026 sekitar 08:00
Metode: import ke database MySQL sementara, query struktur/data, uji migration up/down/up, lalu database sementara dibersihkan.

### 3.1 Ringkasan aktual

| Area | Hasil audit |
|---|---:|
| Tabel | 67 |
| Customer | 12: 2 aktif, 10 tidak aktif |
| Surveyor GIFT aktif | 1 |
| Company Profile | 1; address/phone/email/logo belum lengkap |
| Authorized Signer | 0 |
| Mapping `customer_personnel_locations` | 0 |
| Checklist Template | 4: 3 aktif, 1 tidak aktif |
| Checklist Item aktif | 4 |
| `file_objects` | 0 |
| `survey_photos` | 0 |
| Job | 7 |
| Job Container | 8 |
| Assignment | 6 |
| Assignment Container | 8 |
| Survey | 7 |
| Checklist Response | 7 |
| Survey Approval | 6 |
| Report | 2 |
| Audit Log | 391 |

Perbedaan terhadap snapshot awal prompt: empat template memang ada, tetapi tidak seluruhnya aktif; hasil aktual adalah tiga aktif dan satu tidak aktif. Empat item checklist yang ditemukan berstatus aktif.

Customer aktif pada dump bernama/kode sintetis UAT, termasuk `UAT-CUST-17` dan `UAT-CUST-17B`. Seluruh 12 Customer terindikasi data sintetis/UAT. Data tersebut tidak dihapus atau dinonaktifkan.

### 3.2 Tabel relevan

- Identitas dan akses: `users`, `roles`, `user_roles`, `permissions`, `role_permissions`, `surveyor_profiles`.
- Customer: `customers`, `customer_personnel`, `locations`, `customer_personnel_locations`.
- Referensi customer-scoped: `container_types`, `survey_types`, `fitness_checklist_templates`, `fitness_checklist_template_items`, tabel mapping severity/test parameter/photo category.
- CEDEX: `cedex_locations`, `cedex_components`, `cedex_damages`, `cedex_repairs`, `cedex_materials`, `responsibility_codes`.
- Operasional: `jobs`, `job_containers`, `assignments`, `assignment_containers`, `surveys`, `survey_findings`, `survey_checklist_responses`, `survey_approvals`.
- Dokumen dan audit: `reports`, `file_objects`, `survey_photos`, `numbering_settings`, `numbering_sequences`, `audit_logs`, `company_profiles`.

### 3.3 Legacy dan area di luar scope aktif

Jumlah data master dengan `customer_id IS NULL`:

| Tabel | Baris legacy |
|---|---:|
| `locations` | 0 |
| `container_types` | 10 |
| `survey_types` | 10 |
| `cedex_locations` | 10 |
| `cedex_components` | 16 |
| `cedex_damages` | 18 |
| `cedex_repairs` | 14 |
| `cedex_materials` | 5 |
| `responsibility_codes` | 5 |

Baris tersebut dipertahankan, dikecualikan dari endpoint operasional, dan diperlakukan sebagai legacy/read-only. Tabel Finance tetap dipertahankan tetapi transaksi Finance pada dump kosong dan tidak diaktifkan di workspace Admin Kelaikan.

## 4. Struktur menu canonical

Konflik pemilihan `adminWorkspace` dan `containerFitnessAdminWorkspace` diselesaikan pada source selection. Scope `container_fitness` sekarang menggunakan satu `adminWorkspace` canonical; perubahan tidak hanya dilakukan pada `.env`.

| Grup | Item canonical |
|---|---|
| Dashboard | Dashboard |
| Pekerjaan Inspeksi | Semua Pekerjaan; Buat Job/SPK |
| Master Data | Customer; Referensi Pemeriksaan; ISO CEDEX |
| Review & Keputusan | Menunggu Review; Riwayat Keputusan |
| Dokumen & Laporan | Laporan Pemeriksaan; Arsip Laporan |
| Pengaturan | Surveyor GIFT; Company Profile; Penomoran; User & Hak Akses; Audit Log |

Menu Finance, Ready to Invoice, workshop, billing, repair aktif, import terpisah, assignment terpisah, monitoring survey terpisah, final PDF, QR aktif, dan public verification tidak ditampilkan di sidebar Admin.

Pemeriksaan sumber menu ditambahkan melalui `apps/web/scripts/check-admin-navigation.mjs` dan script `test:navigation`.

## 5. Route canonical dan compatibility

### 5.1 Route canonical

- `/dashboard`
- `/jobs` dan `/jobs/create`
- `/master/customers`, `/master/customers/create`, `/master/customers/customer/:customerId`
- `/master/inspection-references`
- `/master/iso-cedex`
- `/review/pending`, `/review/history`
- `/reports`, `/reports/archive`
- `/master/surveyors`, `/settings/company-profile`, `/settings/numbering`, `/settings/users`, `/settings/audit-log`

Route Surveyor GIFT yang benar-benar tersedia tetap `/master/surveyors`. Rekomendasi `/settings/surveyors` belum diimplementasikan karena page/redirect tersebut belum ada dan perubahan route akan memperluas scope perbaikan CI. Assignment tetap memakai `surveyor_profiles`, terpisah dari `customer_personnel`.

### 5.2 Route compatibility

| Route lama | Tujuan canonical |
|---|---|
| `/fitness/dashboard` | `/dashboard` |
| `/fitness/applications` | `/jobs` |
| `/fitness/applications/create` | `/jobs/create` |
| `/fitness/applications/:id` | `/jobs` |
| `/fitness/clients` dan `/fitness/client-master-data` | `/master/customers` |
| detail/client create lama | tab/route Customer canonical yang sesuai |
| `/fitness/containers` | `/jobs` |
| `/fitness/assignments` | `/jobs?view=assigned` |
| `/fitness/inspections` | `/jobs?view=in-progress` |
| `/fitness/reviews` | `/review/pending` |
| `/fitness/approvals` | `/review/history` |
| `/fitness/documents`, `/fitness/reports` | `/reports` |
| `/fitness/legacy-archive` | `/reports?view=archive` |

Route compatibility tidak tampil sebagai menu utama dan tidak menghasilkan active item ganda.

## 6. Perubahan fungsional

### 6.1 Dashboard dan daftar pekerjaan

- Dashboard Admin menampilkan metrik pekerjaan operasional, Customer dengan master data belum lengkap, serta aktivitas job/audit terbaru.
- Metrik pendapatan, invoice, outstanding, dan saldo tidak ditampilkan.
- `/jobs` memakai tab: Semua, Draf/Baru, Belum Ditugaskan, Ditugaskan, Dalam Pemeriksaan, Sudah Dikirim, Perlu Revisi, Disetujui, Ditolak, dan Selesai/Arsip.

### 6.2 Customer, kesiapan, dan mapping PIC–Location

- Detail Customer memiliki tab Profil Customer, Personel/PIC, Location Pemeriksaan, Riwayat Pekerjaan, dan Kelengkapan Master Data.
- Readiness dihitung read-only dari 16 komponen data existing; tidak dibuat tabel readiness baru.
- API mapping dua arah Personel/PIC–Location ditambahkan.
- Mutation menolak Customer tidak aktif, PIC lintas Customer, Location lintas Customer, dan Location tidak aktif.
- Form Job memfilter/memprioritaskan PIC berdasarkan Location yang dipilih.
- Master dengan `customer_id IS NULL` tidak menjadi opsi workflow aktif.

Endpoint baru:

- `GET /master-data/customers/readiness`
- `GET /master-data/customers/:id/readiness`
- `GET|PUT /master-data/customers/:id/personnel/:item_id/locations`
- `GET /master-data/customers/:id/locations/:item_id/personnel`

### 6.3 Job/SPK dan assignment

- Metadata `spk_no`, `spk_date`, `spk_file_id`, dan `spk_notes` ditambahkan melalui migration.
- Create Job memvalidasi Customer aktif dan referensi PIC, Location, Survey Type, dan Container Type dalam scope Customer.
- Upload lampiran SPK ditandai belum aktif; UI tidak membuat fake upload.
- Assignment dan reassignment hanya menerima `surveyor_profiles` aktif yang terhubung ke role Surveyor.

### 6.4 Review dan data teknis Surveyor

- Keputusan Need Revision/Approve/Reject dibatasi pada active role `supervisor` atau `super_admin`.
- Permission Admin yang salah konfigurasi tidak cukup untuk melakukan keputusan teknis.
- Surveyor mutation mensyaratkan active role `surveyor`; wildcard super_admin tidak dapat menulis hasil teknis atas nama Surveyor.
- Approval tidak membuat report otomatis dan tidak memasukkan antrean dokumen. Status pembentukan report tetap `not_started`.
- Endpoint final PDF, generate report, dan public QR mengembalikan `409 FEATURE_NOT_ACTIVE`.

### 6.5 Pengaturan

- Company Profile menggunakan satu form fisik dan satu record; pembuatan record kedua ditolak.
- Penomoran membaca setting/sequence existing dan menampilkan preview tanpa menambah sequence.
- Audit Log memiliki endpoint paginated/search dan UI read-only.
- Surveyor GIFT tetap berasal dari `surveyor_profiles`, bukan `customer_personnel`.

## 7. Permission dan keamanan

| Peran | Perilaku aktif |
|---|---|
| Admin | Menyiapkan Job, data Customer, assignment, monitoring; tidak mengisi data teknis dan tidak mengambil keputusan review |
| Surveyor | Workspace Surveyor dan mutation pemeriksaan miliknya; tidak memperoleh menu Admin/Review |
| Supervisor | Review dan keputusan teknis sesuai permission |
| Management | Read-only; mutation ditolak oleh permission/backend |
| Finance | Role/tabel dipertahankan, tetapi bukan bagian menu Admin Kelaikan aktif |
| Super Admin | Administrasi umum; mutation data teknis Surveyor tetap memerlukan active role Surveyor |

Seluruh pembatasan customer-scoped dan role gate diterapkan di backend, bukan hanya melalui filtering frontend.

## 8. Migration database

Migration terakhir yang ada sebelum pekerjaan adalah `0011`; nomor aktual berikutnya adalah `0012`.

File baru:

- `services/api/migrations/0012_admin_db15_alignment.up.sql`
- `services/api/migrations/0012_admin_db15_alignment.down.sql`

Perubahan:

- empat field metadata SPK dan FK/index `spk_file_id → file_objects.id`;
- FK `survey_checklist_responses.survey_id → surveys.id` dengan `ON DELETE CASCADE`, mengikuti kepemilikan response sebagai child Survey;
- FK `survey_checklist_responses.template_item_id → fitness_checklist_template_items.id` tanpa cascade delete, agar referensi template tidak hilang otomatis;
- index pendukung untuk kedua FK checklist.

Audit orphan sebelum FK: 0 orphan `survey_id` dan 0 orphan `template_item_id`.

Clean MySQL 8.4.10 mereproduksi `ERROR 3780` pada migration `0010_container_fitness_foundation.up.sql` baris 139, constraint `fk_fitness_checklist_templates_container_type`. Parent `container_types.id` bertipe `CHAR(36)` dengan `utf8mb4_0900_ai_ci`, sedangkan child `fitness_checklist_templates.container_type_id` bertipe `CHAR(36)` tetapi mewarisi `utf8mb4_unicode_ci` dari deklarasi tabel `0010`. Canonical dump dan parent foundation aktual memakai `utf8mb4_0900_ai_ci`, sehingga tepat 19 deklarasi tabel pada migration `0010` dan patch `0015` diselaraskan kembali ke `utf8mb4_0900_ai_ci`. Seluruh FK string terverifikasi memiliki tipe, charset, dan collation yang sama; constraint tidak dihapus.

Hasil database upgrade copy DB15:

- up: 4 kolom SPK dan 3 FK target tersedia;
- down: 4 kolom SPK dan 3 FK target terhapus sesuai rollback;
- up ulang: schema kembali lengkap, 7 checklist response tetap ada, tanpa orphan.

## 9. Validasi yang benar-benar dijalankan

| Perintah/area | Status | Catatan |
|---|---|---|
| MySQL integration `TestMasterDataSmokeWithTestDatabase` | PASS | MySQL 8.4.10, exit 0, test PASS |
| `go test ./...` pada `services/api` | PASS | Seluruh package lulus, exit 0 |
| `go test ./...` pada `services/worker` | PASS | Seluruh package lulus, exit 0 |
| `npm run typecheck --workspace apps/web` | PASS | Tidak ada type error |
| `npm run test:navigation --workspace apps/web` | PASS | Enam grup canonical, label terlarang, dan source workspace canonical tervalidasi |
| `npm run lint --workspace apps/web` | PASS | Exit 0 tanpa error |
| `npm run build --workspace apps/web` | PASS | Next.js production build lulus, exit 0 |
| Clean migration MySQL 8.4.10 | PASS | `0001`-`0012` seluruhnya exit 0; 67 tabel |
| Migration `0012` up/down/up | PASS | Down menghapus 4 kolom dan 3 FK; up ulang mengembalikannya; orphan 0 |
| `git diff --check` | PASS | Pemeriksaan whitespace akhir dijalankan setelah dokumentasi |

Status commit baseline `fa5a9da`: Web typecheck/build PASS dan Go API/Worker PASS pada GitHub Actions, sedangkan `Validate / MySQL integration test` FAIL karena `ERROR 3780`. Perbaikan lokal sudah lulus seluruh validasi di atas dan dipublikasikan setelah instruksi terpisah; status workflow commit perbaikan diverifikasi di remote dan tidak dinyatakan hijau sebelum selesai. Deployment production tidak dijalankan.

## 10. UAT dan screenshot

API UAT dijalankan terhadap copy DB15 dengan data sintetis. Assertion customer isolation, readiness, Job/SPK, assignment, siklus Submit–Need Revision–Resubmit–Approve, skenario Reject, role gate, audit, dan fitur dokumen nonaktif lulus. Satu kesalahan field pada test harness awal dikoreksi dari `customer_id` menjadi field canonical `id`; aplikasi tidak diubah untuk kesalahan harness tersebut. Login enam role lulus, dan isolasi menu Admin/Supervisor/Surveyor/Management/Finance lulus melalui assertion DOM Edge CDP. Detail seluruh skenario ada di `ADMIN_MENU_DB15_UAT_MATRIX.md`.

In-app browser tidak dapat bootstrap karena runtime mengembalikan `codex/sandbox-state-meta: missing field sandboxPolicy`. Sebagai fallback, Microsoft Edge headless melalui Chrome DevTools Protocol dipakai terhadap build production lokal. Tujuh skenario DOM/navigation lulus dan screenshot berukuran valid tersimpan. Tool inspeksi gambar lokal juga tertahan wrapper sandbox, sehingga laporan ini tidak mengklaim pemeriksaan pixel-by-pixel manual.

Screenshot:

- [Dashboard Admin desktop](screenshots/admin-menu-db15-alignment/01-dashboard-desktop.png)
- [Customer readiness desktop](screenshots/admin-menu-db15-alignment/02-customers-readiness-desktop.png)
- [Tab status pekerjaan desktop](screenshots/admin-menu-db15-alignment/03-jobs-status-tabs-desktop.png)
- [Company Profile desktop](screenshots/admin-menu-db15-alignment/04-company-profile-desktop.png)
- [Audit Log desktop](screenshots/admin-menu-db15-alignment/05-audit-log-desktop.png)
- [Penomoran mobile 390 px](screenshots/admin-menu-db15-alignment/06-numbering-mobile.png)
- [Redirect compatibility assignment mobile](screenshots/admin-menu-db15-alignment/07-compat-assignment-redirect-mobile.png)

## 11. File perubahan tugas

### Web

- `apps/web/constants/navigation.ts`
- `apps/web/scripts/check-admin-navigation.mjs`
- `apps/web/package.json`
- halaman Dashboard, Jobs, Customer canonical, Settings, Review, dan route compatibility di bawah `apps/web/app/`
- komponen Jobs, Customer readiness, mapping PIC–Location, settings, dashboard legacy redirect, report status, dan utility select di bawah `apps/web/components/`
- `apps/web/lib/inspection-work.ts`
- `apps/web/types/inspection-work.ts`
- `apps/web/types/jobs.ts`

### API dan database

- `services/api/internal/dashboard/dashboard.go`
- `services/api/internal/http/router.go`
- `services/api/internal/jobs/models.go`
- `services/api/internal/jobs/repository.go`
- `services/api/internal/masterdata/handler.go`
- `services/api/internal/masterdata/repository.go`
- `services/api/internal/masterdata/customer_location_mapping.go`
- `services/api/internal/masterdata/customer_readiness.go`
- `services/api/internal/modules/admin_settings.go`
- `services/api/internal/modules/routes.go`
- file handler/model/repository/service/test di `services/api/internal/reviews/`
- `services/api/internal/surveyor/service.go`
- `services/api/internal/surveyor/helpers_regression_test.go`
- migration `0010` (normalisasi collation) dan migration baru `0012`
- `database/patches/0015_container_fitness_foundation.sql` (sinkronisasi collation canonical patch)

### Dokumentasi

- `docs/ADMIN_MENU_DB15_ALIGNMENT_REPORT.md`
- `docs/ADMIN_MENU_DB15_UAT_MATRIX.md`
- `docs/screenshots/admin-menu-db15-alignment/`

Follow-up perbaikan CI 24 Juli 2026 hanya mengubah migration `0010`, canonical patch `0015`, dua dokumen ini, dan bukti non-sensitif di `docs/evidence/mysql-migration-fix/`. Perubahan worktree pengguna di luar daftar tersebut dipertahankan.

## 12. Blocker dan keputusan tertunda

| Area | Status | Keterangan |
|---|---|---|
| Struktur menu dan route Admin | PASS | Satu IA canonical untuk scope `container_fitness` |
| Customer isolation dan mapping PIC–Location | PASS | Backend dan UAT negatif lulus |
| Metadata SPK | PASS | Schema, API, dan UI tersedia |
| Upload lampiran SPK | BLOCKED | Object storage/file flow belum siap; tidak dibuat fake upload |
| Foto pemeriksaan live | NOT_TESTED | `file_objects` dan `survey_photos` kosong; object storage belum dibuktikan operasional |
| Daftar CEDEX produksi | DECISION_REQUIRED | Daftar resmi GIS/Pak Agus belum diberikan; tidak dibuat seed asumsi |
| Format/validasi Location Code | DECISION_REQUIRED | Aturan resmi panjang/format belum dikonfirmasi |
| Final PDF, QR, public verification | BLOCKED | Sengaja nonaktif dan mengembalikan `FEATURE_NOT_ACTIVE` |
| Report queue otomatis | DECISION_REQUIRED | Keputusan bisnis pemicu/antrean belum ditetapkan |
| Data produksi | BLOCKED | Dump didominasi data UAT dan Company Profile belum lengkap |
| Route Surveyor GIFT `/settings/surveyors` | DECISION_REQUIRED | Route aktual `/master/surveyors` tetap dipakai; redirect/canonical rename dikerjakan terpisah |
| CI commit perbaikan dan deployment production | NOT_TESTED | Baseline gagal pada MySQL; workflow commit perbaikan diverifikasi setelah push. Deployment tidak diuji |
| Inspeksi visual in-app | PARTIAL | Edge CDP lulus; runtime in-app dan viewer gambar tertahan sandbox |

Hasil ini tidak dinyatakan production-ready. Pengaktifan upload, foto, dokumen akhir, atau data referensi produksi memerlukan sumber data dan keputusan bisnis terpisah.

## 13. Pernyataan publish

**Publikasi ke `origin/main` dilakukan setelah pengguna memberi instruksi push terpisah. Scope commit dibatasi pada perbaikan MySQL, dokumentasi, dan bukti pengujian.**
