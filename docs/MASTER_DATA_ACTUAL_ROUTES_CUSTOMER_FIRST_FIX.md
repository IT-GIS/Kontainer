# Master Data Actual Routes Customer-First Fix

Tanggal: 16 Juli 2026

## 1. Baseline dan Batas Perubahan

- Commit awal: `2db52ede10e8bc301631d10ebf05600d0c0412e1`.
- URL masalah yang dikonfirmasi: `http://localhost:3000/master/cedex/locations`.
- Scope hanya frontend route aktual `/master/...`, adaptor service/mock customer-scoped existing, navigasi, responsive UI, accessibility, dan dokumentasi.
- Tidak ada perubahan backend, API, database, migration, SQL, seed, Job Order, Monitoring Survey, Review, Report, Setting, Finance, PDF/QR, atau workflow operasional.
- Perubahan lokal `/fitness/master-data/...` yang sudah ada sebelum pekerjaan ini dipertahankan.
- Tidak ada commit dan tidak ada push.

## 2. Audit Route Aktual

| Menu | Route index aktual | Component index | Component tabel/detail | Sumber data | Route detail |
|---|---|---|---|---|---|
| Customer | `/master/customers` | `ActualMasterDataIndexRoute` + `FitnessClientsList` | `FitnessClientForm` + overview | `getFitnessCustomers` | `/master/customers/customer/:customerId` |
| Location | `/master/locations` | `ActualMasterDataIndexRoute` + `MasterDataCustomerPicker` | `LocationTab` | `getFitnessMasterDataCategoryRecords` | `/master/locations/customer/:customerId` |
| Surveyor | `/master/surveyors` | picker reusable | `CustomerSurveyorTab` | service customer-scoped existing | `/master/surveyors/customer/:customerId` |
| Container Type | `/master/container-types` | picker reusable | `ContainerTypeTab` | service customer-scoped existing | `/master/container-types/customer/:customerId` |
| Survey Type | `/master/survey-types` | picker reusable | `MasterDataReferenceTab` | service customer-scoped existing | `/master/survey-types/customer/:customerId` |
| CEDEX Location | `/master/cedex/locations` | picker reusable | `MasterDataReferenceTab` dengan kolom CEDEX | service customer-scoped existing | `/master/cedex/locations/customer/:customerId` |
| CEDEX Component | `/master/cedex/components` | picker reusable | `MasterDataReferenceTab` | service customer-scoped existing | `/master/cedex/components/customer/:customerId` |
| CEDEX Damage | `/master/cedex/damages` | picker reusable | `MasterDataReferenceTab` | service customer-scoped existing | `/master/cedex/damages/customer/:customerId` |
| CEDEX Repair | `/master/cedex/repairs` | picker reusable | `MasterDataReferenceTab` | service customer-scoped existing | `/master/cedex/repairs/customer/:customerId` |
| CEDEX Material | `/master/cedex/materials` | picker reusable | `MasterDataReferenceTab` | service customer-scoped existing | `/master/cedex/materials/customer/:customerId` |
| Responsibility Code | `/master/responsibility-codes` | picker reusable | `MasterDataReferenceTab` | service customer-scoped existing | `/master/responsibility-codes/customer/:customerId` |

Customer create tersedia pada `/master/customers/create`. Detail dan create ditangani wrapper dinamis `/master/[...route]`, sedangkan seluruh URL index tetap page aktual masing-masing.

## 3. Akar Masalah

Sebelum perubahan, sebelas page index `apps/web/app/master/**/page.tsx` langsung merender `MasterDataPage`. Komponen tersebut memanggil endpoint global `/api/v1/master/...` dan langsung menampilkan tabel CRUD, sehingga tidak pernah ada tahap memilih Customer.

Implementasi customer-first sudah tersedia pada route `/fitness/master-data/...`, tetapi sidebar aktual dan page `/master/...` tidak menggunakannya. Active navigation legacy juga memakai exact match, sehingga URL detail baru tidak akan mengaktifkan child menu tanpa prefix match.

## 4. Struktur Sebelum dan Sesudah

Sebelum:

```text
klik submenu /master/...
-> MasterDataPage
-> tabel global
```

Sesudah:

```text
klik submenu /master/...
-> Customer Picker
-> pilih Customer
-> /master/.../customer/:customerId
-> workspace kategori untuk Customer tersebut
```

Tidak ada auto-select Customer, last-customer persistence, redirect ke Customer pertama, atau fallback ke tabel global.

## 5. Customer Picker

- Mengambil perusahaan hanya dari `getFitnessCustomers()`, sumber yang sama dengan menu Customer.
- Menyediakan filter nama/kode, status, kota/provinsi, reset, tabel desktop, card mobile, dan pagination lokal 10 baris.
- Menampilkan kode, perusahaan, PIC, wilayah, total kategori, aktif, tidak aktif, status Customer, pembaruan, dan aksi `Kelola [Kategori]`.
- Setiap action mempunyai label yang menyebut kategori dan Customer.
- Index tidak memuat record detail kategori; verifikasi source/HTTP memastikan kode record Customer A/B tidak terdapat pada payload index.

## 6. Detail dan Reuse Tabel Existing

- Workspace category-specific existing direuse melalui `FitnessClientMasterCategoryWorkspace`.
- Pencarian, filter status, tambah, lihat, edit, nonaktifkan, drawer, konfirmasi, unsaved-changes guard, toast, dan pagination dipertahankan.
- Header dan context strip menampilkan nama, kode, status, PIC, jumlah data, pembaruan, serta Customer ID.
- Customer dan Customer ID selalu read-only pada form kategori.
- CEDEX Location memakai kolom `CODE | FACE | GRID | CONTAINER SIZE | ORDER | STATUS | AKSI`.
- Tombol `Kembali ke Daftar Customer` kembali ke index kategori yang sama.
- Customer tidak aktif tetap dapat dilihat, tetapi seluruh aksi mutasi kategori dan form profil dinonaktifkan.

## 7. Isolasi Customer ID

- Customer ID hanya berasal dari URL detail.
- Semua getter turunan menerima Customer ID dan memfilter record sebelum data diberikan ke workspace.
- Record lokal baru selalu ditulis dengan ID Customer aktif.
- Edit tidak menyediakan dropdown Customer.
- Unknown Customer menampilkan error dan tidak pernah menggunakan data global sebagai fallback.
- Perpindahan kategori melalui sidebar selalu menuju index tanpa Customer ID, sehingga context kategori sebelumnya dilepas.

## 8. Navigation dan Compatibility

- Semua child Master Data aktual memakai prefix match; index dan detail menyalakan submenu yang sama.
- Scoring navigation existing tetap memastikan hanya satu child memakai `aria-current="page"`.
- Group Master Data otomatis terbuka ketika child aktif dan sidebar mobile tetap ditutup oleh handler link existing.
- Route API global `/api/v1/master/...` tidak diubah agar Job Order, Survey, Finance, dan consumer legacy tetap kompatibel.
- `MasterDataPage` tidak dihapus, tetapi tidak lagi dipanggil oleh sebelas page index browser aktual.
- Metadata frontend CEDEX Repair dikoreksi dari alias `cedex-perbaikans` ke `cedex-repairs`.

## 9. Responsive dan Accessibility

- Table desktop mempunyai `scope="col"` dan accessible label.
- Card mobile mempunyai label record, action minimum 44 px, dan status selalu memiliki teks.
- Table tetap berada dalam container scroll pada tablet, sedangkan context strip wrap dan bertumpuk pada mobile.
- Aksi lihat, edit, nonaktifkan, close detail, dan pagination memiliki `aria-label`.
- Drawer existing mempertahankan Escape, focus trap, focus restore, dan scroll lock.
- Unsaved-changes guard tetap mencegat perpindahan link ketika form dirty.

## 10. File Utama

Dibuat:

- `apps/web/components/master/customer-first-route.tsx`;
- `apps/web/app/master/[...route]/page.tsx`;
- `docs/MASTER_DATA_ACTUAL_ROUTES_CUSTOMER_FIRST_FIX.md`.

Diubah:

- sebelas page index `apps/web/app/master/...`;
- config route-family, picker, Customer list/form/overview, dan category workspace existing;
- responsive table/card, navigation Admin, metadata Master Data, dan responsive CSS.

## 11. Hasil Validasi Aktual

- `npm run typecheck --workspace apps/web`: LULUS.
- `npm run build --workspace apps/web`: LULUS; Next.js menghasilkan 65 halaman dan mengenali seluruh index `/master/...` serta wrapper detail `/master/[...route]`.
- Percobaan build sandbox pertama berhenti pada `spawn EPERM`; rerun final di luar sandbox lulus.
- HTTP route matrix: 38/38 lulus dengan HTTP 200, mencakup 11 index, detail dua Customer, create, unknown Customer, loading, empty, dan error state.
- Kontrak picker/detail/isolasi: 31/31 lulus untuk 10 kategori turunan dan unknown Customer.
- Kesesuaian summary picker dengan record awal: 20/20 lulus untuk dua Customer pada 10 kategori turunan.
- `apps/web/next-env.d.ts` dipulihkan ke hash awal `7AD303E40D4FDDF44F156129E397511953A71481C5CFD86B1862649AAAF240CC` setelah build.

## 12. Browser/UAT dan Screenshot

Browser in-app sudah dicoba, tetapi koneksi browser internal tidak dapat diinisialisasi pada runtime sesi ini. Karena itu klik visual, Back/refresh visual, breakpoint desktop/tablet/mobile, focus runtime, overflow nyata, dan sidebar interaktif tidak diklaim lulus.

Empat screenshot yang diminta tidak dibuat karena tidak ada browser terverifikasi. Membuat screenshot fallback tanpa session Admin yang nyata akan menghasilkan bukti menyesatkan. UAT manual dan screenshot berikut masih diperlukan:

1. index CEDEX Location berupa Customer Picker;
2. detail CEDEX Location setelah Customer dipilih;
3. index Container Type berupa Customer Picker;
4. detail Container Type setelah Customer dipilih.

## 13. Keterbatasan yang Disengaja

- CRUD pada workspace customer-first tetap state lokal frontend dan kembali ke mock awal setelah reload.
- Persistensi lintas reload memerlukan relasi Customer pada backend/database, yang secara eksplisit berada di luar scope.
- Tidak ada backend/database spekulatif, commit, atau push.
