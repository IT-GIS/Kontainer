# Master Data Client-First Navigation Report

Tanggal: 14 Juli 2026

## 1. Baseline dan Tujuan

- Commit awal: `fae66929f2ce4142501c7672e0959097a5e99a3e`.
- Scope hanya frontend Admin Kelaikan, mock data, async read-only service, compatibility route, styling, dan dokumentasi.
- Customer menjadi sumber tunggal perusahaan/organisasi untuk seluruh kategori Master Data.
- Tidak ada perubahan backend, API, database, migration, SQL, schema, seed, atau modul operasional.
- Tidak ada commit dan tidak ada push.
- `docs/PROMPT_CODEX_MASTER_DATA_CLIENT_FIRST.md` adalah file lokal pengguna yang sudah ada sebelum implementasi dan tidak diubah.

## 2. Struktur Sidebar

Sebelum perubahan, `Klien & Master Data` merupakan satu link menuju `/fitness/clients`.

Setelah perubahan, link tersebut menjadi group collapsible dengan urutan:

1. Customer
2. Location
3. Surveyor
4. Container Type
5. Survey Type
6. CEDEX Location
7. CEDEX Component
8. CEDEX Damage
9. CEDEX Repair
10. CEDEX Material
11. Responsibility Code

Group otomatis terbuka ketika child aktif. Saat sidebar collapsed, klik group memperluas sidebar sekaligus membuka submenu. Child aktif memakai `aria-current="page"`. Label operasional diperjelas menjadi `Penugasan Surveyor GIFT` dan `Monitoring Pemeriksaan` tanpa mengubah route atau isi modulnya.

## 3. Reusable Customer Picker

`MasterDataCustomerPicker` dipakai oleh seluruh kategori selain Customer. Komponen menerima konfigurasi kategori dan data Customer yang sudah dilengkapi summary count dari service.

Fitur picker:

- pencarian nama/kode Customer;
- filter status;
- filter kota/provinsi;
- jumlah record kategori per Customer;
- PIC utama, status, dan pembaruan;
- table desktop dan card mobile melalui `ResponsiveTableCards`;
- tombol aksesibel `Kelola [Kategori] [Customer]`;
- empty state ketika filter atau service tidak menghasilkan Customer.

Tidak ada data perusahaan yang diduplikasi pada kategori.

## 4. Route Client-First

Route index kategori memakai `/fitness/master-data/:category` dan selalu menampilkan Customer terlebih dahulu. Route detail memakai `/fitness/master-data/:category/:clientId` dan memuat data hanya untuk Customer dari route.

Kategori canonical:

- `customers`
- `locations`
- `surveyors`
- `container-types`
- `survey-types`
- `cedex-locations`
- `cedex-components`
- `cedex-damages`
- `cedex-repairs`
- `cedex-materials`
- `responsibility-codes`

Customer juga menyediakan `/fitness/master-data/customers/create`. Unknown category dan unknown `clientId` memakai `ErrorState`. Query mock `mockState=loading|empty|error` tersedia untuk validasi state async tanpa API baru.

## 5. Reuse Workspace Detail

Workspace UI-B.2 existing dipertahankan dan diadaptasi dengan `FitnessClientMasterCategoryWorkspace`.

- Location memakai kembali table, filter, Drawer, dan form Location existing.
- Container Type memakai kembali editor existing.
- Surveyor Customer memakai pola Personel existing tetapi memiliki type dan mock terpisah agar Personel/PIC UI-C tidak berubah.
- Survey Type, seluruh CEDEX, dan Responsibility Code memakai satu editor referensi generik yang aman.
- Semua detail memakai `PageHeader`, context strip, `FilterBar`, `ResponsiveTableCards`, `Drawer`, `FormSection`, `FormField`, `UnsavedChangesGuard`, `ConfirmationDialog`, `ToastFeedback`, `EmptyState`, `ErrorState`, dan `Skeleton` existing.

Customer selalu ditampilkan read-only di Drawer. Tidak ada dropdown atau kontrol untuk memindahkan record ke Customer lain.

## 6. Kontrak Kategori dan Batas Bisnis

Frontend menambahkan union `FitnessMasterDataCategory`, slug kategori, `FitnessClientSurveyor`, `FitnessClientMasterDataReference`, record union, dan category summary.

- Surveyor pada Master Data adalah Surveyor Customer, bukan Surveyor GIFT.
- Survey Type hanya referensi jenis layanan/pemeriksaan, bukan status workflow.
- CEDEX Repair hanya referensi teknis dan tidak memuat workshop, biaya, spare part, atau operasional bengkel.
- CEDEX Material hanya referensi teknis dan tidak memuat inventori, stok, harga, atau pembelian.
- Responsibility Code hanya referensi frontend tanpa aturan keputusan, biaya, penagihan, atau tanggung jawab hukum tambahan.

## 7. Mock Data dan Async Service

Customer existing `client-nusantara` dan `client-samudra` tetap menjadi sumber perusahaan. Keduanya mempunyai record yang berbeda untuk seluruh kategori. Jumlah record juga dibuat berbeda agar picker menampilkan count aktual.

Getter baru:

- `getFitnessCustomers`
- `getFitnessCustomerById`
- `getFitnessClientSurveyors`
- `getFitnessClientSurveyTypes`
- `getFitnessClientCedexLocations`
- `getFitnessClientCedexComponents`
- `getFitnessClientCedexDamages`
- `getFitnessClientCedexRepairs`
- `getFitnessClientCedexMaterials`
- `getFitnessClientResponsibilityCodes`
- `getFitnessMasterDataCategoryRecords`
- `getMasterDataCategorySummary`

Getter existing untuk Location, Personel/PIC, Container Type, referensi pemeriksaan, dan UI-C tetap kompatibel. Semua getter turunan menerima `clientId` dan memfilter array mock sebelum mengembalikan state loading, empty, error, atau success.

## 8. Isolasi clientId

- `clientId` detail berasal dari route dinamis.
- Service memfilter setiap array dengan `item.clientId === clientId`.
- Record lokal Location, Surveyor Customer, Container Type, dan referensi teknis selalu menulis `clientId: client.id` dari route.
- Opsi Location pada form Surveyor difilter ulang terhadap Customer aktif.
- Refresh mempertahankan kategori dan Customer karena keduanya berada pada URL.

Bukti payload:

- Nusantara menampilkan `Depo Nusantara Priok` dan tidak menampilkan `Terminal Samudra Perak`.
- Samudra menampilkan `Terminal Samudra Perak` dan tidak menampilkan `Depo Nusantara Priok`.
- CEDEX Damage Nusantara menampilkan `Bent` tanpa `Dented`.
- CEDEX Damage Samudra menampilkan `Dented` tanpa `Bent`.
- Responsibility Code Samudra menampilkan `Customer Reference S` tanpa record Nusantara.

## 9. Compatibility

Redirect canonical:

- `/fitness/clients` ke Customer;
- `/fitness/clients/create` ke create Customer;
- `/fitness/clients/:clientId` ke detail Customer;
- `/fitness/client-master-data` ke Customer;
- tab `summary`, `locations`, `personnel`, dan `container-types` ke detail canonical yang sesuai;
- `/fitness/master-data` ke Customer.

Tab lama tanpa padanan semantik langsung menampilkan compatibility notice dan tidak dipetakan secara spekulatif. Slug global lama seperti owners, manufacturers, inspection references lama, dan checklist tetap memakai notice existing.

## 10. Responsive dan Accessibility

- Desktop memakai sidebar group, Customer table, detail table, Drawer, dan context strip horizontal.
- Tablet memakai sidebar drawer/collapsible, table scroll, dan context strip wrap.
- Mobile memakai card list, action minimal 44 px, form satu kolom, Drawer responsive, context strip bertumpuk, dan proteksi overflow.
- Group sidebar memakai `aria-expanded`; child aktif memakai `aria-current`.
- Tombol Kelola menyebut kategori dan nama Customer.
- Context Customer memakai `role="status"`.
- Form memakai label existing; Drawer mendukung Escape, focus trap, scroll lock, dan focus restore melalui behavior UI-B.1.
- Status selalu mempunyai teks.

## 11. File

File dibuat:

- `apps/web/constants/fitness-master-data-client-first.ts`
- `apps/web/components/fitness/client-master-data/master-data-customer-picker.tsx`
- `apps/web/app/fitness/master-data/page.tsx`
- `apps/web/app/fitness/master-data/[category]/page.tsx`
- `apps/web/app/fitness/master-data/[category]/[clientId]/page.tsx`
- `apps/web/app/fitness/master-data/customers/create/page.tsx`
- `docs/MASTER_DATA_CLIENT_FIRST_NAVIGATION_REPORT.md`

File utama yang diubah:

- navigation Admin dan `AppShell`;
- type, mock, dan async service frontend Master Data;
- workspace/detail Customer UI-B.2;
- route compatibility `/fitness/clients` dan `/fitness/client-master-data`;
- catch-all compatibility Admin Kelaikan;
- responsive CSS.

## 12. Hasil Validasi Aktual

- `npm run typecheck --workspace apps/web`: LULUS pada rerun final setelah koreksi syntax patch awal.
- `npm run build --workspace apps/web`: LULUS.
- Next.js menghasilkan 65 halaman dan mengenali route dynamic category, detail `clientId`, root redirect, dan Customer create.
- `git diff --check`: LULUS sebelum penulisan laporan dan dijalankan kembali pada closure final.
- Hash `apps/web/next-env.d.ts` sebelum build: `7AD303E40D4FDDF44F156129E397511953A71481C5CFD86B1862649AAAF240CC`.
- Build mengubah file tersebut; setelah dipulihkan hash kembali ke nilai awal yang sama.
- Scan implementasi untuk istilah terlarang: 0 temuan.

## 13. Smoke Test Aktual

HTTP route matrix:

- 52 route diuji;
- 52 route HTTP 200 setelah dua route yang timeout saat kompilasi awal berhasil pada rerun;
- mencakup 11 index, detail dua Customer pada 11 kategori, Customer create, unknown `clientId`, empty/error state, dan compatibility route.

Pemeriksaan source/HTTP tambahan:

- 19/19 pemeriksaan redirect marker, compatibility notice, 11 submenu, prefix active-match, `aria-current`, collapsed group, filter picker, accessible action, Customer read-only, write path `clientId`, dan breakpoint responsive lulus.
- Isolasi payload Location, CEDEX Damage, dan Responsibility Code dua Customer lulus.

Browser in-app interaktif dicoba setelah server lokal aktif, tetapi koneksi browser internal tidak dapat diinisialisasi pada runtime sesi ini. Karena itu klik visual, screenshot breakpoint, refresh visual, Escape/focus restore, dan pemeriksaan overflow nyata tidak diklaim lulus. Bukti fallback yang tersedia adalah build, HTTP matrix, payload isolation, redirect marker, dan pemeriksaan source-level jalur interaksi/responsive.

## 14. Hal yang Tidak Dikerjakan

- Backend, database, migration, SQL, schema, seed, dan API mutation tidak diubah.
- UI Surveyor GIFT baru tidak dibuat.
- Peti Kemas, Penugasan, Pemeriksaan, Review, Dokumen, dan Laporan tidak dilanjutkan.
- Workshop, inventori, billing, finance, VGM, PDF final, QR, dan verifikasi publik tidak dibuat.
- Persistence lintas reload tidak dibuat.
- Test framework atau dependency baru tidak ditambahkan.
- Tidak ada commit dan tidak ada push.

## 15. FINAL CORRECTION AND HARDENING

Baseline final correction adalah `8dba26aca6d60b74179cadab5d1d90e95317da8c`. File lokal `docs/PROMPT_CODEX_MASTER_DATA_CLIENT_FIRST.md` tetap dipertahankan tanpa perubahan.

Koreksi final yang diterapkan:

- seluruh isi canonical Master Data memakai terminologi Customer; `Klien & Master Data` hanya dipertahankan sebagai nama group navigasi;
- daftar dan form Customer hanya mempunyai satu cabang canonical, tanpa `clientFirst=false`, `FitnessClientPicker`, atau `FitnessClientMasterWorkspace`;
- detail Customer tetap memuat form profil dan sekarang mempunyai overview 10 kategori, metrik total/aktif/tidak aktif/pembaruan/kelengkapan, tombol Edit Customer, shortcut Kelola, serta kembali ke daftar;
- `FitnessMasterDataCategorySummary` memuat `activeCount`, `inactiveCount`, dan `completeness`; `getFitnessCustomerMasterDataOverview(clientId)` memakai kelengkapan presence-based;
- picker menampilkan total dan record aktif/tidak aktif, PIC, wilayah, status, pembaruan, filter langsung, dan nama aksesibel yang menyebut kategori serta Customer;
- editor referensi memakai union discriminated untuk Survey Type, CEDEX Location, kategori CEDEX bernama, dan Responsibility Code sehingga field legacy tidak dipaksakan ke model generik;
- setiap Drawer memakai Customer dan `clientId` read-only dari route; pilihan Location Surveyor dibatasi ke Location aktif milik Customer tersebut;
- form Customer dan Location/Surveyor memvalidasi field wajib dan format email; feedback konfirmasi, toast, dirty guard, Escape, focus trap, dan focus restore memakai komponen interaksi existing;
- overview responsive memakai tiga kolom desktop, dua kolom tablet, dan satu kolom mobile; form Drawer satu kolom, action minimal 44 px, context strip wrap, card mobile berlabel, dan konten diberi proteksi overflow;
- route canonical dan seluruh adapter compatibility tetap tersedia. Active child tetap tunggal berdasarkan scoring match existing, group membuka otomatis, dan atribut `aria-expanded` serta `aria-current` dipertahankan.

Pembersihan hanya mencakup UI lama yang tidak mempunyai consumer: workspace/tab summary privat, picker privat, mapping legacy privat, dan cabang label lama. Tipe/getter Personel serta referensi pemeriksaan yang masih dipakai UI-C tidak dihapus.

### Batas role

- Admin mengelola Master Data.
- Supervisor dan Reviewer mengambil keputusan teknis pada tahap workflow berikutnya, bukan pada Master Data.
- Management tetap read-only.
- Admin boleh melihat Review untuk monitoring, tetapi tidak memperoleh aksi keputusan teknis dari perubahan frontend ini.

### Validasi final

Hasil final correction dicatat berdasarkan perintah yang benar-benar dijalankan pada sesi ini:

- `npm run typecheck --workspace apps/web`: LULUS.
- `npm run build --workspace apps/web`: LULUS; Next.js menghasilkan 65 halaman.
- `git diff --check`: LULUS; peringatan line-ending Windows tidak menghasilkan error.
- Hash `apps/web/next-env.d.ts` kembali ke `7AD303E40D4FDDF44F156129E397511953A71481C5CFD86B1862649AAAF240CC` setelah churn build dipulihkan.
- HTTP smoke: 66/66 route lulus, mencakup seluruh index canonical, detail dua Customer untuk 11 kategori, create, unknown category/`clientId`, state loading/empty/error, dan adapter compatibility.
- Isolasi payload HTML: 7/7 pemeriksaan lulus untuk Location, Surveyor/Location aktif, CEDEX Damage, dan Responsibility Code pada Nusantara/Samudra.
- Browser in-app sudah benar-benar dicoba, tetapi koneksi gagal pada tahap inisialisasi runtime sesi. Karena itu filter/click, sidebar, dialog, focus, refresh visual, dan breakpoint browser tidak dinyatakan lulus.
- Scan 17 file implementasi/dokumentasi yang diubah: nol temuan untuk empat variasi istilah terlarang pada brief.
- Scan repository menemukan istilah tersebut hanya pada dokumen brief lama `docs/FINALISASI_FULL_MENU_ADMIN_KELAIKAN_BERTAHAP.md` dan file prompt lokal pengguna yang tidak diubah; temuan ini berada di luar scope.
- Audit scope: nol file backend, API, database, migration, SQL, atau modul operasional berubah.

Tidak ada backend, API, database, migration, SQL, atau modul operasional yang diubah oleh final correction.
