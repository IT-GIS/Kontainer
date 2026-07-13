# Admin Stage 1.1 Corrective Hardening Report

Laporan corrective Tahap 1.1 untuk generic Master Data Admin Kelaikan. Scope berhenti di hardening Master Data; tidak ada workflow transaksi, patch SQL, migration, tabel baru, commit, atau push.

## Masalah Yang Diperbaiki

- Optional field kosong sebelumnya dikirim `null` secara global tanpa melihat DDL.
- Field non-null dengan database default seperti `display_order`, `version_no`, `severity_default`, dan beberapa boolean dapat tertimpa `null`.
- Audit log sebelumnya terjadi setelah mutation sehingga kegagalan audit dapat membuat API error walau data sudah berubah.
- Relation fetch bergantung pada seluruh `formData`, sehingga mengetik field biasa memicu fetch relation ulang.
- Search list memanggil API pada setiap keystroke.
- Dropdown user Surveyor memuat maksimal 100 user dan tidak searchable server-side.
- Row inactive masih dapat menampilkan aksi Nonaktifkan berulang.

## Strategi Empty Field

Create:

- Required kosong ditolak.
- Nullable kosong dikirim sebagai `null`.
- Non-null dengan database default di-omit agar default DB bekerja.
- Non-null tanpa default wajib diisi.

Update:

- Field tidak dikirim berarti tidak diubah.
- Nullable kosong menjadi `null`.
- Non-null dengan database default dikembalikan ke `DefaultValue` terkonfigurasi.
- Required kosong tetap ditolak.

## Resource Metadata

Backend `Field` sekarang memakai metadata `Nullable`, `UseDatabaseDefault`, dan `DefaultValue`. Frontend `MasterField` memakai `nullable`, `omitWhenEmpty`, `defaultValue`, `clearValue`, dan `required`.

Default yang dijaga:

- `display_order`: `0`.
- `version_no`: `1`.
- `severity_default`: `minor`.
- `final_fitness_result_mapping`: `pending`.
- Boolean default seperti `is_mvp_active`, `requires_next_examination_date`, `is_structural_critical`, `is_required`, `requires_supervisor_review`, dan `is_active`.

Matrix lengkap ada di `docs/ADMIN_STAGE_1_FIELD_NULLABILITY_MATRIX.md`.

## Transaction Audit

Create, update, dan deactivate Master Data sekarang berjalan melalui transaction boundary repository:

- create: duplicate check, insert resource, insert audit, commit.
- update: ambil old value, duplicate check, update resource, insert audit, commit.
- deactivate: ambil old value, skip bila sudah inactive, update status/is_active, insert audit, commit.

Jika mutation atau audit gagal, transaction rollback. Response API tetap memakai bentuk lama.

## Relation Fetch

Relation fetch tidak lagi bergantung pada seluruh object form. Fetch hanya dipicu saat dialog aktif dan relation search atau selected relation berubah. Request lama dicegah menimpa response baru memakai sequence ID.

Current relation pada edit tetap ditampilkan. Jika detail tidak dapat diambil, UI menampilkan label aman `Data referensi saat ini`, bukan UUID mentah.

## List Search Debounce

Search tabel dipisah menjadi `searchInput` dan `debouncedSearch` dengan debounce 350 ms. Page direset menjadi 1 setelah debounce selesai. Response lama tidak menimpa response baru.

## Surveyor Searchable User

Field `user_id` Surveyor sekarang memakai searchable relation ke `/users` dengan query:

- `role=surveyor`
- `status=active`
- `without_surveyor_profile=true`
- `search`
- pagination

Saat edit, user saat ini tetap tampil sebagai opsi current profile walau tidak lolos filter without profile.

## Inactive Action

- Row inactive tidak menampilkan tombol Nonaktifkan.
- Jika user punya permission update, row inactive menampilkan tombol Aktifkan.
- Backend skip deactivate bila record sudah inactive sehingga audit deactivate tidak berulang.
- Company profile tetap memakai `is_active` boolean.
- Checklist template tetap mendukung `draft`, `active`, dan `inactive`.

## Test Yang Dibuat

Backend test ditambah untuk:

- create default field diomit saat kosong;
- update default field kosong memakai configured default;
- nullable field kosong saat update menjadi `nil`;
- audit gagal membuat create rollback;
- mutation gagal tidak membuat audit;
- mutation dan audit sukses commit bersama;
- retry setelah audit failure tidak membuat record ganda;
- inactive row tidak membuat audit deactivate berulang.

Frontend tidak memiliki test runner terpasang di workspace. Validasi frontend dilakukan lewat typecheck dan build.

## Risiko Tersisa

- Runtime CRUD dengan database utama belum dijalankan agar tidak melakukan mutation data kerja.
- Current user detail Surveyor tidak memiliki endpoint detail `/users/:id`, sehingga label edit memakai data row Surveyor saat ini.
- Business rule Tahap 2 seperti singleton company profile dan template aktif wajib punya item belum diaktifkan.