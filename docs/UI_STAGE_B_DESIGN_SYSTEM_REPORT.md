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
