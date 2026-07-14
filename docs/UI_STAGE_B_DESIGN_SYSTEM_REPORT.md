# UI Stage B Design System Report

Tanggal: 13 Juli 2026

## 1. Scope

Tahap UI-B melanjutkan fondasi Admin Kelaikan dari UI-A dengan fokus pada design system dan komponen reusable.

Perubahan tetap dibatasi ke frontend dan dokumentasi. Tidak ada perubahan backend, database, migration, SQL patch, Surveyor UI, commit, atau push pada tahap ini.

## 2. Baseline

Baseline yang dipakai:

- `docs/REDESIGN_UI_UX_ADMIN_KELAIKAN_KONTAINER.md`, khususnya daftar komponen wajib, perilaku form, responsive, mock data, dan tahap implementasi UI-B.
- `docs/UI_STAGE_A_INFORMATION_ARCHITECTURE_REPORT.md`, khususnya rekomendasi UI-B untuk hardening komponen, state lintas halaman, filter bar, responsive table/card, dan state visual form.

## 3. Komponen Ditambahkan

Komponen reusable baru di `apps/web/components/ui/`:

- `ActionCard`
- `ActivityTimeline`
- `AttachmentPreview`
- `AttachmentUploaderPlaceholder`
- `BulkSelectionTable`
- `CompletionBadge`
- `ConfirmationDialog`
- `Drawer`
- `EmptyState`
- `ErrorState`
- `FilterBar`
- `FormField`
- `FormSection`
- `MetricCard`
- `ProgressTracker`
- `ResponsiveTableCards`
- `SearchableSelect`
- `Skeleton`
- `Stepper`
- `StickyActionBar`
- `ToastFeedback`
- `UnsavedChangesGuard`

Komponen yang diperkuat:

- `StatusBadge`: menerima konten React dan tone `info`.
- `PageHeader`: mendukung eyebrow, metadata, primary action, dan secondary action.
- `FormDialog`: label aksi dasar disesuaikan ke bahasa Indonesia.

## 4. Wiring Admin Kelaikan

Halaman placeholder Admin Kelaikan sekarang memakai komponen UI-B untuk:

- metric card;
- filter bar;
- stepper;
- progress tracker;
- responsive table/card;
- completion badge;
- activity timeline;
- attachment upload placeholder;
- attachment preview;
- sticky action bar;
- empty, error, dan loading state reusable.

Dashboard summary memakai `ActionCard`, sedangkan master data index tetap mempertahankan grouped cards UI-A yang sudah aktif.

## 5. Mock Data

Mock UI-B ditambahkan ke:

- `apps/web/types/fitness-admin.ts`
- `apps/web/mocks/fitness-admin.ts`
- `apps/web/lib/fitness-admin-mock-service.ts`

Service baru bersifat async read-only dan tidak memanggil endpoint backend.

## 6. Responsive Behavior

Pattern responsive UI-B:

- desktop memakai grid metric dan table;
- tablet menyederhanakan grid filter dan flow;
- mobile menyembunyikan table dan menampilkan card list;
- action bar menjadi sticky bottom pada mobile;
- form section turun dari dua kolom ke satu kolom.

## 7. Compatibility

Tidak ada perubahan route backend atau schema. Public interface UI-A tetap kompatibel.

Komponen baru bersifat opt-in. Komponen lama seperti `PageTabs`, `Breadcrumb`, `DataTable`, dan grouped master data index tetap berjalan.

## 8. Batas Tahap

Yang belum dikerjakan pada UI-B:

- form bisnis penuh;
- dashboard data nyata;
- integrasi API;
- workflow backend;
- dokumen final;
- validasi publik;
- implementasi halaman Surveyor.

## 9. Rekomendasi UI-C

UI-C dapat mulai memakai komponen UI-B untuk Dashboard dan Permohonan:

- metric card dashboard;
- filter bar daftar permohonan;
- stepper buat permohonan;
- responsive table/card daftar permohonan;
- progress tracker detail permohonan;
- sticky action bar untuk draf dan lanjut tahap.
## 10. Koreksi UI-B.1

Baseline koreksi: `7edf3501109a18c9bcf9ea759245358c5e81cccc`.

UI-B.1 mengubah komponen UI-B dari preview visual menjadi komponen interaktif yang siap dipakai pada Dashboard dan Permohonan di UI-C, tanpa memulai halaman bisnis UI-C.

Komponen yang dibuat interaktif:

- `SearchableSelect`: controlled value, controlled atau local search, local filtering, clear action, disabled, required, loading, error, empty state, option disabled, combobox/listbox/option ARIA, keyboard ArrowUp/ArrowDown/Enter/Escape, dan click outside close.
- `FilterBar`: field `search`, `select`, `date`, `date-range`, dan `text`; controlled `onChange`; `onSubmit`; `onReset`; `resetHref` compatibility; loading/disabled; active filter count; collapse mobile.
- `StickyActionBar`: action mendukung `href`, `onClick`, `type`, `form`, disabled, loading, loading label, icon, dan aria label; internal href memakai Next `Link`.
- `BulkSelectionTable`: controlled `selectedIds`, checkbox nyata, toggle row, toggle all, indeterminate select-all, predicate selectable, disabled row, label aksesibel, dan card mobile tetap dapat memilih data.
- `UnsavedChangesGuard`: tetap menangani refresh/tab close/external navigation dan menambah hook `useUnsavedChangesGuard` dengan `requestNavigation`, `confirmationOpen`, `confirmLeave`, dan `cancelLeave`.
- `Drawer`, `ConfirmationDialog`, dan `FormDialog`: Escape close, focus awal, focus trap sederhana, restore focus, body scroll lock, `aria-labelledby`, `aria-describedby`, configurable backdrop close, dan close dicegah saat loading/submitting.
- `Stepper`: `aria-current="step"`, nomor tahap, status complete/current/upcoming/error, optional step click, dan compact/mobile horizontal.
- `ProgressTracker`: status complete/current/incomplete/warning/error, label status aksesibel, dan backward compatibility untuk status lama.
- `FormField`: struktur `div` + `label`, `id`, `htmlFor`, help/error ID, required marker, optional label, dan compatibility error summary.
- `ToastFeedback`: dismiss optional, duration optional, role `status` untuk success/info, role `alert` untuk warning/danger, dan close button.

Perubahan API tetap menjaga penggunaan lama sebisa mungkin. Komponen yang sekarang membutuhkan handler controlled hanya dipakai pada harness internal, sehingga halaman production tidak terdampak.

Accessibility:

- Combobox memakai `role="combobox"`, `aria-expanded`, `aria-controls`, `aria-activedescendant`, dan error description.
- Dialog memakai focus trap, Escape handling, scroll lock, focus restore, `aria-modal`, `aria-labelledby`, dan `aria-describedby`.
- Bulk selection memakai checkbox native dengan label aksesibel dan indeterminate state.
- Stepper memakai `aria-current="step"` pada tahap aktif.
- Toast memakai role yang sesuai dengan tingkat pesan.

Compatibility:

- Placeholder Admin Kelaikan tidak lagi menampilkan showcase komponen generik.
- `DashboardSummary` tetap memakai `ActionCard` production-ready.
- Master Data grouped index tetap berjalan.
- Mock UI-B tetap read-only dan tidak memanggil endpoint backend.

Cara penggunaan di UI-C:

- Daftar Permohonan dapat memakai `FilterBar`, `ResponsiveTableCards`, dan `BulkSelectionTable` untuk list dan aksi massal.
- Buat Permohonan dapat memakai `Stepper`, `FormField`, `SearchableSelect`, `StickyActionBar`, dan `UnsavedChangesGuard`.
- Detail Permohonan dapat memakai `ProgressTracker`, `Drawer`, `ConfirmationDialog`, `ToastFeedback`, dan state `EmptyState`/`ErrorState`/`Skeleton`.
- Navigasi internal yang berpotensi membuang perubahan dapat memanggil `requestNavigation(() => router.push(path))` dari `useUnsavedChangesGuard`.

Harness internal:

- `apps/web/components/fitness/ui-b-interaction-preview.tsx` dibuat sebagai component harness internal.
- Harness tidak dipasang ke route production dan tidak tampil permanen di placeholder bisnis.
- Harness mencakup SearchableSelect, FilterBar, Drawer, ConfirmationDialog, StickyActionBar, Stepper, BulkSelectionTable, UnsavedChangesGuard, ToastFeedback, dan state empty/loading/error/success.

File yang diubah pada UI-B.1:

- `apps/web/app/globals.css`
- `apps/web/components/fitness/fitness-placeholder-page.tsx`
- `apps/web/components/fitness/fitness-ui-a.tsx`
- `apps/web/components/ui/bulk-selection-table.tsx`
- `apps/web/components/ui/confirmation-dialog.tsx`
- `apps/web/components/ui/drawer.tsx`
- `apps/web/components/ui/filter-bar.tsx`
- `apps/web/components/ui/form-dialog.tsx`
- `apps/web/components/ui/form-field.tsx`
- `apps/web/components/ui/progress-tracker.tsx`
- `apps/web/components/ui/responsive-table-cards.tsx`
- `apps/web/components/ui/searchable-select.tsx`
- `apps/web/components/ui/stepper.tsx`
- `apps/web/components/ui/sticky-action-bar.tsx`
- `apps/web/components/ui/toast-feedback.tsx`
- `apps/web/components/ui/unsaved-changes-guard.tsx`

File yang dibuat pada UI-B.1:

- `apps/web/hooks/use-dialog-behavior.ts`
- `apps/web/components/fitness/ui-b-interaction-preview.tsx`

## 11. Hasil Validasi

Hasil aktual UI-B.1:

- `npm run typecheck --workspace apps/web`: lulus.
- `npm run build --workspace apps/web`: lulus.
- `apps/web/next-env.d.ts`: berubah akibat build dan sudah direstore.
- Test otomatis: tidak dijalankan karena workspace web belum memiliki test runner; dependency besar tidak ditambahkan.
- Interaction smoke test: typecheck harness internal lulus; route production tidak menampilkan harness.
- Responsive smoke test: route production utama tetap HTTP 200 pada server lokal aktif; responsive behavior diperiksa lewat CSS pattern mobile untuk filter collapse, card list, sticky bottom action, dan stepper horizontal.
- Backend/database guard: tidak ada perubahan pada `services/api` atau `database`.
- Surveyor UI guard: tidak ada perubahan pada route atau komponen Surveyor.
- UI-A route smoke check HTTP 200:
  - `/fitness/dashboard`
  - `/fitness/applications`
  - `/fitness/applications/create`
  - `/fitness/applications?status=incomplete`
  - `/fitness/containers`
  - `/fitness/containers?filter=technical-incomplete`
  - `/fitness/assignments?status=active`
  - `/fitness/master-data`

Validasi final yang dijalankan setelah update dokumen:

- `git diff --check`: lulus.
- Scan istilah terlarang dari brief pada file berubah: bersih.
- Legacy master menu guard: tidak ada menu aktif baru yang ditambahkan.

Hal yang belum selesai dan sengaja tidak dikerjakan pada UI-B.1:

- UI-C Dashboard dan Permohonan belum dimulai.
- Form bisnis Permohonan penuh belum dibuat.
- Test runner frontend belum ditambahkan.
- Backend, API, database, migration, SQL patch, dan UI Surveyor tidak diubah.
- Tidak ada commit dan tidak ada push pada tahap ini.
