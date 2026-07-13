# UI Stage A - Information Architecture Report

## 1. Kondisi UI Awal

- Branch awal: `main`.
- Commit awal: `5b43b2a` (`Finalize generic master data correction`).
- Worktree awal memiliki dokumen acuan untracked: `docs/REDESIGN_UI_UX_ADMIN_KELAIKAN_KONTAINER.md`.
- Admin Kelaikan memakai catch-all route `apps/web/app/fitness/[[...slug]]/page.tsx`.
- Master Data aktif tetap memakai `MasterDataPage`; route non-master masih placeholder.

## 2. Struktur Sidebar Lama

- Master Data tampil sebagai satu grup panjang berisi seluruh submenu.
- Monitoring Pemeriksaan, Review, Dokumen, dan Laporan memiliki banyak submenu yang menuju route sama.
- Beberapa label masih memakai istilah campuran seperti assignment, recheck bahasa Inggris, severity, evidence, dan status teknis.
- Branding sidebar masih menampilkan nama perusahaan yang tidak sesuai workspace GIFT.

## 3. Struktur Sidebar Baru

1. Dashboard
2. Permohonan
3. Peti Kemas
4. Penugasan
5. Monitoring Pemeriksaan
6. Review & Keputusan
7. Tindak Lanjut Perbaikan
8. Dokumen Kelaikan
9. Laporan
10. Master Data
11. Pengaturan
12. Arsip Lama

## 4. Route Mapping

- `/fitness/dashboard`
- `/fitness/applications`
- `/fitness/applications/create`
- `/fitness/applications?status=incomplete`
- `/fitness/containers`
- `/fitness/containers/import`
- `/fitness/containers?filter=technical-incomplete`
- `/fitness/assignments?status=unassigned`
- `/fitness/assignments?status=active`
- `/fitness/assignments?status=history`
- `/fitness/inspections`
- `/fitness/reviews`
- `/fitness/repair-followups`
- `/fitness/documents`
- `/fitness/reports`
- `/fitness/master-data`
- `/fitness/legacy-archive`

## 5. Compatibility Route

- Route lama tidak dihapus.
- Route yang sebelumnya menuju halaman sama tetap aman karena catch-all fitness route memakai metadata placeholder.
- Query state dipakai untuk membedakan submenu yang satu pathname.
- Master Data CRUD lama tetap memakai mapping resource aktif.

## 6. Branding

- Sidebar memakai `Sistem Kelaikan Peti Kemas`.
- Nama perusahaan memakai `PT Global Inspeksi Forensik Teknik`.
- Topbar memakai subtitle: `Kelola permohonan, pemeriksaan, review, dan dokumen kelaikan peti kemas.`
- Logo GIFT tetap memakai asset existing `/images/gift-logo.png` dengan `object-fit: contain`.

## 7. Komponen Baru

- `apps/web/components/ui/breadcrumb.tsx`
- `apps/web/components/ui/page-tabs.tsx`
- `apps/web/components/fitness/fitness-ui-a.tsx`

Komponen fitness UI-A mencakup placeholder pengguna, ringkasan dashboard, section header, Master Data group, dan Master Data card.

## 8. Mock Data

- `apps/web/types/fitness-admin.ts`
- `apps/web/mocks/fitness-admin.ts`
- `apps/web/lib/fitness-admin-mock-service.ts`

Mock data berisi ringkasan navigasi, tab status, grup Master Data, jumlah aktif/tidak aktif placeholder, dan metadata placeholder. Service bersifat read-only dan tidak memanggil backend.

## 9. Responsive

- Desktop memakai sidebar penuh dan grid card.
- Sidebar collapsed menyembunyikan label dengan logo tetap proporsional.
- Tablet menurunkan grid menjadi dua kolom.
- Mobile memakai drawer sidebar, breadcrumb dipendekkan, tabs horizontal scroll, dan card satu kolom.

## 10. Halaman Yang Masih Placeholder

- Dashboard
- Permohonan
- Peti Kemas
- Penugasan
- Monitoring Pemeriksaan
- Review & Keputusan
- Tindak Lanjut Perbaikan
- Dokumen Kelaikan
- Laporan
- Arsip Lama

Master Data index aktif sebagai halaman navigasi. Sub-route Master Data CRUD existing tetap aktif.

## 11. Hal Yang Belum Dikerjakan

- Form permohonan lengkap.
- Form peti kemas lengkap.
- Dashboard data nyata.
- Integrasi API baru.
- Workflow backend.
- Dokumen final dan validasi publik.
- UI Surveyor baru.

## 12. Rekomendasi UI-B

- Lanjutkan ke hardening komponen design system.
- Samakan empty, loading, error, dan success state lintas halaman.
- Siapkan pattern filter bar dan responsive table/card view.
- Tambahkan state visual yang lebih kaya untuk form tahap berikutnya.
