# UI Stage B.2 Client Master Data Report

Tanggal: 14 Juli 2026

## 1. Baseline dan Scope

- Commit awal: 7edf3501109a18c9bcf9ea759245358c5e81cccc.
- Tahap: UI-B.2 — Klien & Master Data Klien.
- Perubahan UI-B/UI-B.1 yang sudah ada dan belum di-commit dipertahankan.
- Implementasi hanya menyentuh frontend Admin Kelaikan dan dokumentasi.
- Tidak ada perubahan pada backend, database, migration, SQL patch, schema, atau modul Surveyor.
- Tidak ada commit dan tidak ada push.

## 2. File UI-B.2

File dibuat:

- apps/web/app/fitness/clients/page.tsx
- apps/web/app/fitness/clients/create/page.tsx
- apps/web/app/fitness/clients/[clientId]/page.tsx
- apps/web/app/fitness/client-master-data/page.tsx
- apps/web/app/fitness/client-master-data/[clientId]/page.tsx
- apps/web/components/fitness/client-master-data/client-pages.tsx
- apps/web/components/fitness/client-master-data/client-master-workspace.tsx
- apps/web/mocks/fitness-client-master-data.ts
- apps/web/lib/fitness-client-master-data-mock-service.ts
- docs/UI_STAGE_B2_CLIENT_MASTER_DATA_REPORT.md

File diubah untuk UI-B.2:

- apps/web/app/fitness/[[...slug]]/page.tsx
- apps/web/app/globals.css
- apps/web/app/login/page.tsx
- apps/web/constants/navigation-admin-fitness.ts
- apps/web/mocks/fitness-admin.ts
- apps/web/types/fitness-admin.ts

File UI-B/UI-B.1 lain yang sudah berubah sebelum UI-B.2 tidak dibatalkan atau ditimpa.

## 3. Struktur Sidebar

Sidebar Admin Kelaikan sekarang terdiri dari 12 menu tanpa submenu teknis panjang:

1. Dashboard
2. Klien & Master Data
3. Permohonan
4. Peti Kemas
5. Penugasan Surveyor
6. Pemeriksaan
7. Review & Keputusan
8. Tindak Lanjut Perbaikan
9. Dokumen Kelaikan
10. Laporan
11. Pengaturan Internal GIFT
12. Arsip Lama

Klien & Master Data tetap aktif untuk route clients, client-master-data, dan compatibility master-data. Route detail, create, import, dan query status tetap menyalakan menu induk masing-masing.

Branding shell dan login menggunakan Sistem Kelaikan Peti Kemas serta PT Global Inspeksi Forensik Teknik.

## 4. Route UI-B.2

Route baru:

- /fitness/clients
- /fitness/clients/create
- /fitness/clients/:clientId
- /fitness/client-master-data
- /fitness/client-master-data/:clientId
- Query tab: summary, locations, personnel, container-types, inspection-references, legacy-mapping
- Query section Referensi: inspection-areas, structural-components, damage-criteria, finding-severities, test-parameters, photo-categories, inspection-recommendations
- Query section Legacy: location, component, damage, material

Tab atau section yang tidak valid menggunakan default Ringkasan, Area Pemeriksaan, atau Location. clientId yang tidak tersedia menampilkan ErrorState dan CTA kembali ke pemilihan klien.

## 5. Halaman Klien

Daftar Klien menyediakan:

- tab Daftar Klien dan Master Data Klien;
- pencarian nama/kode;
- filter status dan kota/provinsi;
- desktop table dan mobile card;
- status, PIC, kontak, jumlah lokasi, jumlah peti kemas, dan pembaruan;
- aksi detail, edit, Kelola Master Data, dan nonaktifkan;
- confirmation dan toast untuk perubahan state lokal.

Form tambah/detail Klien menggunakan FormSection, FormField, SearchableSelect, StickyActionBar, UnsavedChangesGuard, ConfirmationDialog, dan ToastFeedback.

Form hanya mengubah state lokal frontend. Tidak ada request mutation atau perubahan database.

## 6. Master Data Klien

Halaman pemilihan klien menampilkan jumlah lokasi, personel, jenis peti kemas, referensi, kelengkapan, dan CTA Kelola Master Data. Compatibility route dapat meneruskan target tab dan section.

Halaman detail selalu menampilkan context strip yang berasal dari clientId route:

- nama klien aktif;
- kode klien;
- status;
- PIC utama;
- pembaruan terakhir.

Tab yang tersedia:

- Ringkasan
- Lokasi
- Personel/PIC Klien
- Jenis Peti Kemas
- Referensi Pemeriksaan
- Mapping Legacy

Ringkasan menampilkan metric kelengkapan, quick actions, dan aktivitas mock. Lokasi, Personel/PIC, Jenis Peti Kemas, dan Referensi Pemeriksaan memiliki daftar responsif, filter, serta form tambah/edit/nonaktifkan berbasis state lokal.

Personel/PIC hanya memuat personel pihak klien. Surveyor GIFT tidak menjadi tab, tipe personel, atau pilihan form.

Mapping Legacy bersifat read-only, difilter berdasarkan clientId, dan hanya mempunyai subtab Location, Component, Damage, dan Material. Tidak ada Repair, workshop, material inventory, billing, invoice, atau mutation.

## 7. Mock Data, Types, dan Service

Mock menyediakan dua klien berbeda:

- client-nusantara / CL-001
- client-samudra / CL-002

Masing-masing memiliki ID dan kode sendiri untuk lokasi, personel, jenis peti kemas, tujuh kelompok referensi, serta empat kelompok mapping legacy.

Frontend contract mencakup:

- FitnessClientSummary
- FitnessClientDetail
- FitnessClientMasterSummary
- FitnessClientLocation
- FitnessClientPersonnel
- FitnessClientContainerType
- FitnessClientInspectionReference
- FitnessLegacyMappingRecord
- FitnessApplicationSummary
- FitnessContainerSummary
- union section Referensi dan Mapping Legacy

Async read-only service menyediakan:

- getFitnessClients
- getFitnessClientById
- getFitnessClientMasterSummary
- getFitnessClientLocations
- getFitnessClientPersonnel
- getFitnessClientContainerTypes
- getFitnessClientInspectionReferences
- getFitnessClientLegacyMappings

Semua getter turunan menerima clientId dan melakukan filter di service sebelum data diberikan ke komponen. Getter Referensi dan Mapping juga menerima section.

## 8. Isolasi Data Klien

Isolasi diuji menggunakan payload route server:

- halaman Lokasi client-nusantara memuat Depo Nusantara Priok;
- halaman tersebut tidak memuat Terminal Samudra Perak;
- halaman Lokasi client-samudra memuat Terminal Samudra Perak;
- halaman tersebut tidak memuat Depo Nusantara Priok.

Form turunan hanya menampilkan clientId sebagai nilai read-only. Tidak ada field untuk memindahkan data ke klien lain.

## 9. Compatibility

/fitness/master-data dan seluruh detail Master Data lama tetap dapat dibuka.

Pemetaan utama:

- index lama menuju pemilihan klien;
- owners menuju Daftar Klien;
- locations dan container-types menuju pemilihan klien dengan target tab;
- surveyors menampilkan pemisahan Personel/PIC Klien dan Surveyor GIFT;
- referensi lama menuju pemilihan klien dengan target section;
- manufacturer, approval, maintenance, dan checklist menampilkan notice tidak aktif;
- signer dan company profile diarahkan ke konteks Pengaturan Internal GIFT.

Checklist template item lama juga ditangani sebagai compatibility notice. CRUD global lama tidak menjadi workflow aktif tanpa konteks klien.

## 10. Responsive dan Accessibility

Responsive behavior:

- desktop menampilkan tabel dan form multi-kolom;
- tablet mempertahankan tabel scroll, drawer form, sidebar collapse, dan context klien;
- mobile memakai card list, sidebar drawer, tab horizontal, action responsif, dan context strip bertumpuk;
- nama dan kode klien tetap terlihat pada context strip.

Accessibility:

- tab memakai link dan aria-current melalui PageTabs;
- context klien mempunyai role status dan accessible label;
- tabel mempunyai header dan card mobile mempunyai label field;
- form menggunakan label, id, required marker, dan state error;
- drawer/dialog memakai behavior Escape, focus trap, scroll lock, dan focus restore dari UI-B.1;
- tombol icon mempunyai aria-label;
- status selalu mempunyai teks, bukan warna saja.

## 11. Hasil Validasi

- npm run typecheck --workspace apps/web: LULUS.
- npm run build --workspace apps/web: LULUS.
- Next.js build menghasilkan 60 halaman dan mengenali seluruh route UI-B.2.
- git diff --check: LULUS.
- Hash next-env.d.ts sebelum build: 083E23C4C5E7761DB151134EA1EF7896120C86C5888CDC8A861F534F7E86D6FD.
- Build mengubah next-env.d.ts menjadi 4E4DA12AA061AAC172FB1BCB48E9B6E4B293080D2F494327925FDBA8F39632AC.
- File dipulihkan ke hash awal 083E23C4C5E7761DB151134EA1EF7896120C86C5888CDC8A861F534F7E86D6FD.
- Guard scope: 0 file backend/database/migration/SQL berubah.
- Guard istilah/modul terlarang pada file UI-B.2: 0 temuan.
- Jumlah menu sidebar: 12.
- Getter client-scoped: 8.

## 12. Smoke Test

HTTP smoke test pada server lokal aktif:

- total route diuji: 72;
- route HTTP 200: 72;
- gagal: 0.

Matriks mencakup:

- Dashboard;
- Daftar, create, dan detail dua Klien;
- pemilihan klien;
- Ringkasan, Lokasi, Personel/PIC, dan Jenis Peti Kemas untuk dua klien;
- seluruh tujuh subtab Referensi untuk dua klien;
- seluruh empat subtab Mapping Legacy untuk dua klien;
- Permohonan dan create;
- Peti Kemas dan import;
- Penugasan, Pemeriksaan, Review, Tindak Lanjut, Dokumen, Laporan;
- Pengaturan;
- Arsip Lama;
- index dan seluruh detail compatibility Master Data lama.

Browser in-app interaktif tidak dapat dijalankan karena runtime menolak koneksi akibat metadata sandboxPolicy yang tidak tersedia. Karena itu klik dialog, focus restore, screenshot breakpoint, console hydration, dan visual active-navigation tidak dapat dibuktikan melalui browser automation pada sesi ini. Build, route HTTP, isolasi payload, active-match configuration, komponen accessibility, dan media-query responsive telah diverifikasi sebagai pengganti non-visual.

## 13. Hal yang Belum Dikerjakan

Sengaja tidak dikerjakan pada UI-B.2:

- UI-C Dashboard dan Permohonan;
- form Permohonan penuh;
- workspace atau UI Surveyor baru;
- mutation backend dan persistence mock lintas reload;
- database, migration, SQL patch, dan schema;
- checklist seed atau data keputusan teknis;
- workflow Peti Kemas, Penugasan, Pemeriksaan, atau Review;
- workshop, billing, invoice, PDF final, QR, dan verifikasi publik;
- test runner frontend baru;
- commit dan push.

Risiko tersisa hanya verifikasi visual/interaksi browser yang terblokir oleh runtime. Tahap berikutnya tetap UI-C dan belum dimulai.
