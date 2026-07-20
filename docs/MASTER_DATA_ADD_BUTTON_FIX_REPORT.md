# Master Data Add Button Fix Report

Tanggal: 17 Juli 2026

## 1. Baseline Commit

- Baseline: 97033cb1500de354b81238ada8db16bb428eaf47.
- Branch: main.
- Baseline sudah membuat route aktual /master/... menjadi customer-first.
- Scope pekerjaan ini hanya frontend Master Data, mock frontend, styling terarah, dan dokumentasi.
- Tidak ada commit dan tidak ada push.

## 2. Kategori Terdampak

Perbaikan kontrak tombol tambah berlaku untuk:

1. Location
2. Surveyor Customer
3. Container Type
4. Survey Type
5. CEDEX Location
6. CEDEX Component
7. CEDEX Damage
8. CEDEX Repair
9. CEDEX Material
10. Responsibility Code

Customer tetap menjadi pengecualian dan dapat mempunyai tombol Tambah Customer pada halaman Customer.

## 3. Gejala

Gejala yang dilaporkan adalah tombol tambah kategori tidak terlihat setelah Admin memilih Customer. Halaman index kategori wajib tetap berupa daftar Customer dan tidak boleh menampilkan tombol tambah kategori.

Audit source dan chunk development baseline menemukan bahwa action tambah sebenarnya sudah terdapat pada workspace detail. Karena itu tidak dibuat tombol kedua. Perbaikan difokuskan pada kontrak visibilitas yang konsisten, permission, label final, empty-state CTA, accessibility, dan cache runtime.

## 4. Akar Masalah

Temuan yang dapat dipastikan dari source:

- action tersebar pada empat editor internal dan belum mempunyai kontrak akses tunggal;
- visibilitas hanya mempertimbangkan status Customer, belum role Admin dan permission manage kategori;
- label Surveyor masih Tambah Surveyor, bukan Tambah Surveyor Customer;
- PageHeader action belum menerima aria-label yang menyebut kategori dan Customer;
- EmptyState tidak mendukung action onClick, sehingga data kosong tidak memiliki CTA yang membuka drawer existing;
- kondisi data kosong dan filter tanpa hasil masih digabung;
- belum ada fixture Customer tidak aktif untuk membuktikan cabang read-only;
- tombol global memiliki tinggi dasar 38 px, sedangkan acceptance mobile meminta minimal 44 px.

Source dan chunk server lokal sudah memuat action sebelum perbaikan. Penyebab visual spesifik dari laporan awal tidak diklaim telah direproduksi karena browser internal tidak dapat diinisialisasi pada sesi ini. Cache .next lama sudah dibersihkan dan build final dibuat dari cache bersih.

## 5. Route Aktual

| Kategori | Route index | Route detail |
|---|---|---|
| Location | /master/locations | /master/locations/customer/:customerId |
| Surveyor | /master/surveyors | /master/surveyors/customer/:customerId |
| Container Type | /master/container-types | /master/container-types/customer/:customerId |
| Survey Type | /master/survey-types | /master/survey-types/customer/:customerId |
| CEDEX Location | /master/cedex/locations | /master/cedex/locations/customer/:customerId |
| CEDEX Component | /master/cedex/components | /master/cedex/components/customer/:customerId |
| CEDEX Damage | /master/cedex/damages | /master/cedex/damages/customer/:customerId |
| CEDEX Repair | /master/cedex/repairs | /master/cedex/repairs/customer/:customerId |
| CEDEX Material | /master/cedex/materials | /master/cedex/materials/customer/:customerId |
| Responsibility Code | /master/responsibility-codes | /master/responsibility-codes/customer/:customerId |

Halaman index tetap memakai MasterDataCustomerPicker tanpa action tambah kategori. Workspace detail tetap memakai FitnessClientMasterCategoryWorkspace setelah customerId dari route tervalidasi.

## 6. Permission

Mutation frontend hanya tersedia bila seluruh kondisi berikut benar:

- role user adalah admin atau super_admin;
- user memiliki permission [module].manage.all atau wildcard yang diterima helper permission existing;
- Customer berstatus Aktif.

Mapping permission:

| Kategori | Module |
|---|---|
| Location | locations |
| Surveyor Customer | surveyors |
| Container Type | container_types |
| Survey Type | survey_types |
| CEDEX Location | cedex_locations |
| CEDEX Component | cedex_components |
| CEDEX Damage | cedex_damages |
| CEDEX Repair | cedex_repairs |
| CEDEX Material | cedex_materials |
| Responsibility Code | responsibility_codes |

Supervisor, Management, dan user tanpa manage permission tetap berada pada mode baca saja. Backend role dan permission tidak diubah.

## 7. Customer Aktif dan Tidak Aktif

- Customer aktif + Admin + manage permission: tombol tambah, edit, dan nonaktifkan tersedia.
- Customer aktif tanpa hak manage: action mutasi disembunyikan dan alert mode baca saja ditampilkan.
- Customer tidak aktif: action mutasi disembunyikan dan pesan berikut ditampilkan: Customer tidak aktif. Data dapat dilihat, tetapi penambahan dan perubahan dinonaktifkan.

Fixture frontend client-arsip / CL-003 / PT Arsip Kontainer Indonesia ditambahkan dengan status Tidak Aktif dan tanpa record turunan. Fixture ini hanya untuk pembuktian read-only dan tidak mengubah database.

## 8. Label Tombol

- Tambah Location
- Tambah Surveyor Customer
- Tambah Container Type
- Tambah Survey Type
- Tambah CEDEX Location
- Tambah CEDEX Component
- Tambah CEDEX Damage
- Tambah CEDEX Repair
- Tambah CEDEX Material
- Tambah Responsibility Code

Seluruh action memakai ikon Plus dan aria-label dengan pola [label] untuk [nama Customer].

## 9. Posisi Tombol

- Desktop: action berada di kanan atas PageHeader section kategori.
- Tablet: action dapat wrap tanpa keluar dari panel.
- Mobile: action menjadi full width dan rata tengah.
- Action detail dan CTA mempunyai tinggi minimal 44 px.
- Picker Customer tidak menerima action tambah kategori.

## 10. Empty-State CTA

Data kosong sekarang dibedakan dari hasil filter kosong:

- rows kosong: tampilkan Belum ada [kategori] untuk Customer ini dan CTA tambah;
- rows tersedia tetapi filter tidak cocok: tampilkan pesan ubah pencarian atau reset filter tanpa CTA duplikat.

Action header dan EmptyState menggunakan createAction yang sama dan mengarah ke satu openCreateDrawer() per editor. Tidak ada form kedua.

## 11. Form yang Dibuka

Semua tombol menggunakan MasterDataDrawer existing:

- Location memakai form Location existing;
- Surveyor Customer memakai form Surveyor Customer dan Location milik Customer aktif;
- Container Type memakai form Container Type existing;
- Survey Type dan seluruh referensi CEDEX/Responsibility memakai editor reference reusable;
- Customer serta Customer ID ditampilkan read-only dan berasal dari route;
- tidak ada dropdown untuk memindahkan Customer.

Validasi code, name atau Grid Code, email, status, dan Display Order nonnegatif dipertahankan. ISO Code tidak ditambahkan karena model Container Type frontend saat ini tidak mempunyai field tersebut.

## 12. Save Behavior

- Save tetap memakai state lokal frontend existing.
- Record baru selalu menggunakan client.id dari route.
- Drawer ditutup setelah save.
- Editing dan draft direset.
- Dirty state dibersihkan.
- Toast sukses ditampilkan.
- Customer, kategori, filter route, dan halaman tidak berpindah.
- Submit lock berbasis ref mencegah handler save yang sama berjalan ganda.
- Refresh mengembalikan data ke mock awal; tidak ada klaim persistensi backend.

## 13. Responsive

CSS scoped Master Data memastikan:

- tombol header dan CTA minimal 44 px;
- action wrap pada ruang sempit;
- action header dan CTA full width pada breakpoint mobile 640 px;
- workspace dan panel tetap min-width 0;
- Drawer existing tetap memakai lebar responsif dan body scroll.

## 14. Accessibility

- PageHeader action mendukung ariaLabel.
- EmptyState action mendukung link atau button, ikon, ariaLabel, dan varian visual.
- Ikon Plus selalu disertai teks kategori.
- Status selalu mempunyai teks melalui StatusBadge.
- Drawer existing mempertahankan role dialog, aria-modal, focus trap, Escape, scroll lock, dan focus restore.
- UnsavedChangesGuard serta confirmation dialog existing tetap digunakan.
- Customer read-only ditampilkan sebagai Customer dan Customer ID dari route.

## 15. Hasil Browser Test

Browser internal sudah dicoba setelah:

1. dev server lama dihentikan;
2. apps/web/.next dibersihkan;
3. build produksi lulus dari cache bersih;
4. dev server baru berhasil aktif pada port 3000.

Koneksi browser internal gagal pada tahap inisialisasi karena metadata sandbox browser tidak tersedia. Akibatnya login Admin, klik visual 10 kategori, save melalui DOM, role Supervisor/Management, focus runtime, console browser, dan breakpoint desktop/tablet/mobile tidak dinyatakan lulus.

Dev server UAT sudah dihentikan kembali. Port 3000 tidak ditinggalkan dalam keadaan listening.

## 16. Screenshot

Tidak ada screenshot dibuat karena tidak ada browser terverifikasi. Screenshot fallback tanpa session Admin yang nyata tidak dibuat agar bukti tidak menyesatkan.

Screenshot yang masih memerlukan UAT manual:

1. detail Location dengan tombol tambah;
2. drawer Tambah Location;
3. detail CEDEX Location dengan tombol tambah;
4. drawer Tambah CEDEX Location;
5. tampilan mobile salah satu kategori.

## 17. File Dibuat

- docs/MASTER_DATA_ADD_BUTTON_FIX_REPORT.md

## 18. File Diubah

- apps/web/constants/fitness-master-data-client-first.ts
- apps/web/components/fitness/client-master-data/client-master-workspace.tsx
- apps/web/components/ui/page-header.tsx
- apps/web/components/ui/empty-state.tsx
- apps/web/mocks/fitness-client-master-data.ts
- apps/web/app/globals.css

apps/web/app/globals.css sudah mempunyai perubahan lokal lain sebelum tugas ini. Perubahan tersebut dipertahankan; pekerjaan ini hanya menambah rule scoped Master Data.

## 19. Keterbatasan

- Save masih state lokal dan hilang setelah refresh.
- Browser automation dan screenshot belum tersedia pada runtime sesi ini.
- Permission mutation diverifikasi dari source dan kontrak permission existing, bukan melalui pergantian akun di browser.
- Tidak ada backend mutation yang diaktifkan.

## 20. Hal yang Belum Selesai

UAT visual manual masih diperlukan untuk menerima aspek berikut:

- tombol terlihat secara visual pada seluruh 10 detail Customer aktif;
- drawer dapat diklik dan diisi menggunakan session Admin nyata;
- akun Supervisor/Management terlihat read-only;
- focus restore, Escape, dirty confirmation, dan keyboard flow pada browser;
- desktop, tablet, mobile, dan lima screenshot yang diminta.

## Hasil Validasi Teknis

- npm run typecheck --workspace apps/web: LULUS.
- npm run build --workspace apps/web: LULUS; Next.js menghasilkan 65 halaman.
- HTTP route matrix index/detail-active/detail-empty/detail-inactive: 40/40 LULUS.
- Isolasi Customer A pada 10 kategori: 10/10 LULUS.
- Isolasi Customer B pada 10 kategori: 10/10 LULUS.
- Kontrak label dan permission kategori: 10/10 LULUS.
- Kontrak tambahan picker/action/CTA/aria/inactive: 7/7 LULUS.
- git diff --check: LULUS; warning line ending Windows tidak menghasilkan error.
- Backend/database scope leaks: 0.
- Forbidden terminology hits pada file implementasi: 0.
- apps/web/next-env.d.ts dipulihkan ke hash awal 7AD303E40D4FDDF44F156129E397511953A71481C5CFD86B1862649AAAF240CC.

Tidak ada perubahan backend, API, database, migration, SQL, workflow Surveyor GIFT, PDF/QR, verifikasi publik, workshop, billing, Finance, atau VGM.
