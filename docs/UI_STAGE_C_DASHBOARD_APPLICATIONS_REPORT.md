# UI Stage C Dashboard dan Permohonan Report

Tanggal: 14 Juli 2026

## 1. Baseline dan Scope

- Commit awal: `5b7c642ef56da18412d41cb637e9418554205fea`.
- Tahap: UI-C — Dashboard Admin dan Permohonan.
- Acuan utama: dokumen redesign terpadu, laporan UI-B.2/UI-B.2.1, dan laporan design system UI-B/UI-B.1.
- Implementasi dibatasi pada frontend Admin Kelaikan, mock data, async read-only service, dan dokumentasi.
- Tidak ada perubahan backend, database, migration, SQL, schema, seed, atau API mutation.
- Tidak ada commit dan tidak ada push.

## 2. File

File dibuat:

- `apps/web/app/fitness/dashboard/page.tsx`
- `apps/web/app/fitness/applications/page.tsx`
- `apps/web/app/fitness/applications/create/page.tsx`
- `apps/web/app/fitness/applications/[applicationId]/page.tsx`
- `apps/web/components/fitness/dashboard/dashboard-workspace.tsx`
- `apps/web/components/fitness/applications/applications-list.tsx`
- `apps/web/components/fitness/applications/application-create-workspace.tsx`
- `apps/web/components/fitness/applications/application-detail-workspace.tsx`
- `apps/web/mocks/fitness-dashboard-applications.ts`
- `apps/web/lib/fitness-dashboard-applications-mock-service.ts`
- `docs/UI_STAGE_C_DASHBOARD_APPLICATIONS_REPORT.md`

File diubah:

- `apps/web/types/fitness-admin.ts`
- `apps/web/components/ui/page-header.tsx`
- `apps/web/app/globals.css`

`PageHeader` diperluas secara backward-compatible agar action dapat menggunakan `href` atau `onClick`. Pemakaian UI-A sampai UI-B.2.1 tetap kompatibel.

## 3. Route UI-C

- `/fitness/dashboard`
- `/fitness/applications`
- `/fitness/applications/create`
- `/fitness/applications/:applicationId`
- Query detail: `tab=summary|containers|assignment|inspection|review|documents|history`
- Query filter daftar yang dipertahankan pada initial state: pencarian, `clientId`, status, tanggal, lokasi, dan tahap.

Tab tidak valid kembali ke Ringkasan. ID Permohonan tidak dikenal menampilkan `ErrorState` dan CTA kembali ke daftar.

## 4. Dashboard Admin

Dashboard berorientasi pada pekerjaan yang perlu ditindaklanjuti dan menyediakan:

- delapan card Perlu Tindakan Anda;
- tujuh metric Ringkasan Status;
- Aktivitas Terbaru;
- enam Quick Action;
- filter Periode dan Klien.

Card tindakan mencakup Klien belum lengkap, Permohonan belum lengkap, peti kemas belum lengkap, belum ditugaskan, menunggu review, perbaikan belum selesai, siap pemeriksaan ulang, dan dokumen perlu disiapkan.

Saat filter Klien atau Periode berubah, component memanggil ulang async mock service. Dashboard tidak menanam record operasional langsung pada component.

## 5. Daftar Permohonan

Daftar menampilkan:

- nomor dan tanggal Permohonan;
- Klien;
- Pemohon;
- Pemilik/Pengguna Peti Kemas;
- lokasi;
- jumlah peti kemas;
- kelengkapan;
- tahap proses;
- pembaruan terakhir;
- aksi detail.

Filter langsung aktif saat nilai berubah: pencarian, Klien, status, rentang tanggal, lokasi, dan tahap proses. Desktop memakai tabel dan mobile memakai card melalui `ResponsiveTableCards`.

Klien, Pemohon, dan Pemilik/Pengguna Peti Kemas dipertahankan sebagai tiga konsep berbeda pada type, mock, daftar, form, detail, dan ringkasan.

## 6. Form Buat Permohonan

Stepper terdiri dari tujuh langkah:

1. Klien dan Pemohon
2. Informasi Permohonan
3. Lokasi dan PIC
4. Peti Kemas
5. Instruksi Pemeriksaan
6. Lampiran
7. Ringkasan

Perilaku client-scoped:

- Klien harus dipilih terlebih dahulu.
- Pergantian Klien langsung mengosongkan lokasi, PIC, peti kemas, dan referensi lama.
- Opsi lama dihapus dari UI sebelum request mock Klien baru selesai.
- Lokasi, Personel/PIC, jenis peti kemas, dan tujuh section Referensi dimuat dengan getter async yang menerima `clientId`.
- Hanya data aktif klien terpilih yang diberikan ke field.
- Jenis peti kemas pada setiap baris berasal dari clientId aktif.
- Tidak tersedia dropdown bebas untuk status workflow.

Peti kemas pada UI-C hanya memuat identitas minimum: nomor dan jenis. Form teknis lengkap tidak dibuat karena merupakan scope UI-D.

Action:

- Batalkan;
- Simpan Draf;
- Ajukan;
- Kembali dan Selanjutnya untuk navigasi langkah.

Simpan Draf dan Ajukan memakai confirmation dan toast lokal. Batalkan serta navigasi internal dilindungi `UnsavedChangesGuard`. Tidak ada persistence setelah reload atau mutation backend.

## 7. Detail Permohonan

Detail menampilkan:

- header nomor, status, Klien, pembaruan, dan lokasi;
- context strip clientId;
- Progress Tracker tujuh tahap;
- tab Ringkasan, Peti Kemas, Penugasan, Pemeriksaan, Review, Dokumen, dan Riwayat;
- ringkasan konsep Pemohon dan Pemilik/Pengguna;
- tabel/card peti kemas;
- aktivitas riwayat.

Tab Pemeriksaan, Review, dan Dokumen hanya menampilkan `EmptyState` batas tahap. Tidak ada UI Pemeriksaan/Review penuh, PDF final, QR, atau verifikasi publik.

## 8. Readiness

Checklist berisi sepuluh kondisi sesuai dokumen:

- Klien dipilih;
- Pemohon tersedia;
- Lokasi dipilih;
- PIC tersedia;
- minimal satu peti kemas;
- nomor peti kemas valid;
- data teknis minimum lengkap;
- referensi pemeriksaan tersedia;
- checklist terverifikasi tersedia;
- Surveyor GIFT aktif tersedia.

Permohonan Nusantara mempunyai 10/10 kondisi dan CTA Buka Penugasan aktif. Draf Samudra mempunyai 4/10 kondisi dan tombol Penugasan disabled.

UI-C hanya memeriksa ketersediaan Surveyor GIFT dan checklist terverifikasi melalui boolean mock. UI Surveyor dan checklist seed tidak dibuat.

## 9. Mock, Types, dan Service

Type yang ditambahkan/diperluas:

- `FitnessApplicationSummary`
- `FitnessApplicationDetail`
- `FitnessApplicationDraft`
- `FitnessApplicationReadiness`
- `FitnessApplicationReadinessItem`
- `FitnessApplicationContainerDraft`
- `FitnessApplicationAttachment`
- `FitnessDashboardMetric`
- `FitnessDashboardAction`
- `FitnessDashboardActivity`
- `FitnessDashboardQuickAction`
- `FitnessDashboardSnapshot`

Mock menyediakan tiga Permohonan dan dua detail utama dengan Klien, lokasi, PIC, jenis peti kemas, referensi, progress, readiness, lampiran, dan riwayat berbeda.

Async read-only service menyediakan:

- `getFitnessDashboardSnapshot`
- `getFitnessApplications`
- `getFitnessApplicationById`
- `getFitnessApplicationReadiness`
- `getFitnessApplicationDraft`

Form create menggunakan getter UI-B.2: `getFitnessClientById`, `getFitnessClientLocations`, `getFitnessClientPersonnel`, `getFitnessClientContainerTypes`, dan `getFitnessClientInspectionReferences`.

Semua service mendukung state loading, empty, error, dan success melalui `FitnessMockState<T>`.

## 10. Isolasi clientId

Bukti isolasi route/detail:

- detail Nusantara memuat Depo Nusantara Priok dan tidak memuat Terminal Samudra Perak;
- detail Samudra memuat Terminal Samudra Perak dan tidak memuat Depo Nusantara Priok;
- masing-masing detail membawa context clientId yang berbeda.

Bukti jalur form:

- setiap getter turunan menerima clientId terpilih;
- state dependent di-reset saat Klien berubah;
- hasil lokasi/PIC/jenis/referensi difilter aktif sebelum dipasang;
- field tidak menyediakan kontrol untuk memindahkan record Master Data ke Klien lain.

## 11. Responsive dan Accessibility

Responsive:

- desktop: action grid empat kolom, metric grid, tabel, stepper, form/grid dua kolom, dan sticky action;
- tablet: action grid dua kolom, detail menjadi satu kolom, container row dua kolom, tab scroll dari UI-B;
- mobile: card list, action/quick action satu kolom, form dan summary satu kolom, step navigation bertumpuk, sticky action, serta tidak ada grid yang memaksa overflow.

Accessibility:

- Stepper memakai `aria-current=step`;
- tab memakai link dan `aria-current`;
- seluruh input memakai FormField/label/id;
- SearchableSelect memakai combobox ARIA dan label luar tanpa label ganda;
- error/validation memakai role alert;
- readiness memakai icon dan teks, bukan warna saja;
- context Klien memakai role status dan accessible label;
- tombol icon mempunyai aria-label;
- tabel/card mempunyai header dan label;
- UnsavedChangesGuard, ConfirmationDialog, dan action keyboard memakai komponen UI-B.1.

## 12. Hasil Validasi

- `npm run typecheck --workspace apps/web`: LULUS.
- `npm run build --workspace apps/web`: LULUS pada rerun final di luar sandbox. Percobaan final pertama berhenti setelah compile karena worker TypeScript terkena `spawn EPERM`; rerun dengan kode yang sama selesai penuh.
- Build menghasilkan 63 halaman dan mengenali empat route UI-C khusus.
- `git diff --check`: LULUS.
- Hash `apps/web/next-env.d.ts` sebelum dan setelah restore: `7AD303E40D4FD44F156129E397511953A71481C5CFD86B1862649AAAF240CC`.
- Scope guard: 0 file backend/database/migration/SQL/schema/seed berubah.
- Scan istilah/modul terlarang pada implementasi UI-C: 0 temuan.

## 13. Smoke Test

HTTP route smoke pada server lokal:

- 88 route diuji;
- 88 route HTTP 200;
- 0 gagal.

Matriks mencakup Dashboard, daftar/create/filter Permohonan, dua detail Permohonan, seluruh tujuh tab detail, invalid tab, unknown ID, seluruh route Klien/Master Data dua Klien, seluruh section Referensi dan Mapping Legacy, seluruh placeholder sidebar, Pengaturan, serta compatibility route lama UI-A sampai UI-B.2.1.

Pemeriksaan detail/readiness: 9/9 lulus, meliputi isolasi lokasi dua Klien, sepuluh item readiness pada dua Permohonan, CTA Penugasan aktif/disabled, dan tujuh tahap progress.

Pemeriksaan source-level form: getter client-scoped, reset dependent state, larangan dropdown workflow bebas, UnsavedChangesGuard, tiga action utama, active navigation prefix, dan breakpoint responsive tersedia.

Browser in-app interaktif dicoba, tetapi koneksi browser ditolak karena metadata sandbox lingkungan tidak tersedia. Karena itu klik seluruh langkah, perubahan filter visual, screenshot desktop/tablet/mobile, focus restore, dan console hydration tidak dapat dibuktikan melalui browser automation pada sesi ini. Pemeriksaan tersebut tidak diklaim sebagai browser pass; bukti yang tersedia adalah build/typecheck, HTTP matrix, payload detail, dan jalur event/source-level.

## 14. Hal yang Belum Dikerjakan

- UI-D Peti Kemas tidak dimulai.
- UI-E Penugasan dan UI Surveyor tidak dibuat.
- Pemeriksaan dan Review penuh tidak dibuat.
- Backend, database, migration, SQL, schema, seed, dan API mutation tidak diubah.
- Checklist seed tidak dibuat.
- Persistence setelah reload tidak tersedia.
- Workshop, billing, finance, VGM, PDF final, QR, dan verifikasi publik tidak diaktifkan.
- Browser interactive smoke penuh masih menunggu runtime browser internal yang dapat tersambung.
- Tidak ada commit dan tidak ada push.

Implementasi berhenti setelah UI-C.
