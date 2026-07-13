# Admin Stage 1 Hardening Report

Laporan Tahap 1 untuk hardening generic Master Data Admin Kelaikan.

## File Yang Diubah

- `apps/web/components/master/master-data-page.tsx`
- `apps/web/constants/master-data.ts`
- `apps/web/app/globals.css`
- `services/api/internal/masterdata/models.go`
- `services/api/internal/masterdata/service.go`
- `services/api/internal/masterdata/handler.go`
- `services/api/internal/masterdata/service_test.go`
- `docs/ADMIN_FINAL_AUDIT.md`
- `docs/ADMIN_FORMS_KELAIKAN_PETI_KEMAS.md`
- `docs/ADMIN_STAGE_1_HARDENING_REPORT.md`

## Tipe Field

Generic field config sekarang mendukung:

- `text`
- `textarea`
- `number`
- `decimal`
- `email`
- `tel`
- `url`
- `date`
- `datetime-local`
- `select`
- `searchable-select`
- `checkbox`
- `hidden`

Field panjang dipetakan ke `textarea`; telepon memakai `tel`; website memakai `url`; tanggal signer memakai `date`; latitude/longitude memakai `decimal` dengan min/max dan step.

## Perubahan Payload

- Payload frontend tidak lagi membuang field kosong secara global.
- Optional field kosong dikirim sebagai `null` agar edit dapat benar-benar mengosongkan nilai nullable.
- Required field kosong tetap dikirim sebagai string kosong dan ditolak frontend/backend.
- String input ditrim sebelum dikirim, kecuali field dikonfigurasi `trim: false`.

## Perubahan Validation

Backend generic master data sekarang memeriksa:

- required field pada create;
- required field pada update jika field dikirim kosong;
- unknown field;
- email;
- URL;
- telepon dengan panjang masuk akal;
- tanggal `YYYY-MM-DD`;
- numeric min/max;
- UUID untuk foreign key;
- allowed enum;
- allowed status;
- duplicate code sebagai conflict;
- foreign key invalid sebagai error ramah.

## Perubahan Nonaktifkan

Namespace `/fitness/master-data/*` memakai konfigurasi resource khusus agar aksi Nonaktifkan hanya mengubah `status` atau `is_active`, tanpa mengisi `deleted_at`.

Route legacy `/master/*` tetap memakai konfigurasi resource lamanya sehingga perilaku legacy tidak ikut diubah.

## Perubahan Status Filter

- Master umum: `active`, `inactive` dengan label Aktif/Tidak Aktif.
- Checklist template: `draft`, `active`, `inactive` dengan label Draf/Aktif/Tidak Aktif.
- Company profile: filter UI tetap Aktif/Tidak Aktif dan backend memetakan ke boolean `is_active`.

## Perubahan Relation Dropdown

- Relation field memakai searchable select dengan server-side search.
- Relation preload dibatasi per pencarian, bukan mengambil 100 record lalu diam.
- Nilai lama saat edit tetap ditampilkan; jika detail referensi gagal ditemukan, UI menampilkan label `Data referensi tidak ditemukan` alih-alih UUID mentah saja.
- Error relation ditampilkan di field terkait.
- Debounce 250 ms dipakai untuk mencegah race request saat user mengetik.

## Perubahan Audit Log

Mutation master data tetap mencatat actor, action, entity/table, entity_id, old value, new value, request ID, IP, user agent, dan timestamp melalui `audit_logs`.

Perubahan Tahap 1: error audit tidak lagi diabaikan. Jika audit insert gagal, mutation API mengembalikan error. Operasi belum dibungkus transaction bersama audit karena perubahan transaction boundary untuk generic repository dinilai terlalu besar untuk Tahap 1.

## Test Yang Ditambahkan

Test backend masterdata ditambah untuk:

- required field update kosong;
- optional field kosong menjadi `nil`;
- unknown field ditolak;
- URL invalid ditolak;
- numeric min/max;
- UUID foreign key;
- resource Admin Kelaikan tidak soft delete;
- filter Tidak Aktif menemukan status inactive;
- payload reaktivasi status active valid;
- deteksi foreign key DB error.

Test yang belum dibuat sebagai automated integration test:

- permission create/update/delete end-to-end;
- audit log insert dengan database nyata;
- relation inactive pada browser runtime;
- double-submit pada browser runtime.

## Hasil Test

- `go test ./...` di `services/api`: PASSED dengan `GOCACHE` workspace.
- `go test ./...` di `services/worker`: PASSED dengan `GOCACHE` workspace.
- `npm run typecheck --workspace apps/web`: PASSED.
- `npm run build --workspace apps/web`: PASSED.
- `apps/web/next-env.d.ts` berubah saat build dan dikembalikan ke isi baseline; `git diff` konten file tersebut kosong.

## Risiko Tersisa

- CRUD runtime belum diuji terhadap database kerja utama untuk mencegah mutation pada database utama.
- Audit log belum atomic dalam transaction yang sama dengan mutation master data.
- Relation inactive akan tampil dengan label detail jika endpoint detail berhasil; bila tidak, fallback masih berupa pesan dengan UUID.
- Searchable select belum memakai komponen combobox penuh; masih berupa input search plus select agar tetap sesuai scope generic minimal.
- Beberapa validasi bisnis spesifik Tahap 2 belum diaktifkan, misalnya singleton company profile, template active wajib punya item, dan aturan critical severity.

## Hal Yang Belum Dikerjakan

- Dashboard Kelaikan.
- Permohonan Kelaikan.
- Data Peti Kemas.
- Import Data Peti Kemas.
- Assignment.
- Inspection.
- Review.
- Dokumen.
- Laporan.
- UI Surveyor.
- Tabel baru.
- Patch SQL baru.
- Migration baru.
- Perubahan workflow transaksi.
## Tahap 1.1 - Corrective Hardening

Corrective Tahap 1.1 menutup blocker hardening generic Master Data Admin Kelaikan:

- empty field semantics kini membedakan required, nullable, non-null default, dan omitted field;
- default database seperti `display_order=0`, `version_no=1`, `severity_default=minor`, dan `final_fitness_result_mapping=pending` dijaga;
- mutation master data dan audit log dibungkus dalam satu transaction;
- relation fetch tidak lagi dipicu oleh perubahan field non-relation;
- list search memakai debounce 350 ms;
- user Surveyor memakai searchable relation `/users`;
- aksi Nonaktifkan disembunyikan untuk row inactive dan backend mencegah audit deactivate berulang.

Laporan detail: `docs/ADMIN_STAGE_1_1_CORRECTIVE_REPORT.md`.
Matrix field: `docs/ADMIN_STAGE_1_FIELD_NULLABILITY_MATRIX.md`.