# Laporan Integritas Workflow Survey Kontainer

Tanggal: 30 Juli 2026

Referensi: `Rencana_Perbaikan_Aplikasi_Survey_Kontainer.md`

## Tujuan

Perubahan ini menutup gap pada skenario terdekat yang ditetapkan dokumen:

```text
40 feet
-> Right Side
-> Bottom
-> Section 1-4
-> Temuan dan marker tersimpan
-> Foto tersimpan
-> Submitted
-> Under Review
-> Need Revision
-> Resubmitted
-> Under Review
-> Approved
```

Scope tidak diperluas ke modul baru.

## Hasil Audit

Kemampuan berikut sudah tersedia sebelum perubahan ini dan dipertahankan:

- Survey Sheet berbasis SVG dengan mouse, keyboard, dan touch target.
- Mapping terstruktur untuk ukuran, face, vertical position, section, dan transverse span.
- Marker dibentuk kembali dari damage yang tersimpan.
- Upload foto private, watermark, metadata, serta pemeriksaan role/assignment.
- Permission Surveyor, Reviewer, dan Admin pada route utama.
- Audit event untuk pembukaan survey, pemilihan lokasi, perubahan temuan, foto, submit, dan keputusan.

Gap yang ditemukan:

- Location manual masih dapat melewati master aktif.
- Global ISO CEDEX reference tetap dapat dipakai walaupun Customer mempunyai override dengan kode sama.
- Item checklist `Tidak Baik` tidak membawa relasi persisted ke temuan.
- Submit belum memvalidasi relasi checklist dan kategori foto wajib.
- `Need Revision` kembali disubmit sebagai `submitted`, sehingga siklus revisi tidak dapat dibedakan.
- Belum ada state `under_review`, waktu mulai review, atau histori snapshot sebelum/sesudah.
- Reviewer dapat mengambil keputusan tanpa menjalankan transisi mulai review.

## Implementasi

### Location Code dan Customer Scope

- Form dan API mewajibkan Location Code aktif.
- Fallback lokasi manual dihapus dari UI dan backend.
- Area tanpa mapping tetap memakai alur pengajuan kode.
- Reference global hanya efektif jika Customer tidak mempunyai override aktif dengan kode yang sama.
- Validasi tersebut diterapkan pada daftar lokasi, pilihan interaktif, dan referensi CEDEX temuan.

### Checklist ke Temuan

- `survey_damages.checklist_response_id` menyimpan relasi ke snapshot checklist.
- Relasi hanya diterima jika item berasal dari survey yang sama dan bernilai `no`.
- Tombol `Buat Temuan CEDEX` membawa item checklist sampai form temuan.
- Daftar temuan menampilkan item checklist terkait.
- Submit ditolak jika item `Tidak Baik` belum mempunyai temuan.

### Foto Evidence

- Validasi tidak mewajibkan foto secara blanket untuk setiap temuan.
- Kategori yang `is_required_default=1` pada mapping Customer + Survey Type wajib tersedia.
- Kategori wajib dengan `applies_to=finding` divalidasi per temuan.
- Foto kategori lain tetap dapat ditambahkan sebagai evidence tanpa menjadi kewajiban baru.

### State Machine Review

Transisi inti menjadi:

```text
draft
-> submitted
-> under_review
-> need_revision
-> resubmitted
-> under_review
-> approved
```

- Reviewer harus memilih `Mulai Review` sebelum dapat memberi keputusan.
- Surveyor tetap read-only pada `submitted`, `under_review`, dan `resubmitted`.
- Resubmit mempunyai status dan timestamp tersendiri.
- Queue Submitted mencakup `submitted`, `under_review`, dan `resubmitted` tanpa menyembunyikan pekerjaan aktif.

### Revisi dan Versioning

- Tabel `survey_revisions` menyimpan revision number, reason, actor, timestamp, note, status, snapshot before, dan snapshot after.
- `Need Revision` membuat Revision 1 dan seterusnya.
- Resubmit mengisi actor, timestamp, dan snapshot sesudah revisi.
- Reviewer dapat membuka histori dan membandingkan snapshot sebelum/sesudah.
- Approval/rejection memperbarui status revision aktif.

### Database

Perubahan schema tersedia dalam:

- `services/api/migrations/0016_survey_workflow_integrity.up.sql`
- `services/api/migrations/0016_survey_workflow_integrity.down.sql`
- `database/patches/0022_survey_workflow_integrity.sql`

Migration belum dijalankan ke database nyata pada sesi ini.

## Validasi

Lolos:

- `go test ./...` dari `services/api`
- `go test ./...` dari `services/worker`
- `npm run test:survey-sheet --workspace apps/web`
- `npm run test:iso-cedex --workspace apps/web`
- `npm run test:navigation --workspace apps/web`
- `npm run typecheck --workspace apps/web`
- `npm run lint --workspace apps/web`
- `npm run build --workspace apps/web`
- `git diff --check`

Coverage baru membuktikan:

- state monitoring menerima `under_review` dan `resubmitted`;
- keputusan hanya boleh dari `under_review`;
- queue Submitted tetap memuat state review aktif;
- lokasi manual tidak dapat melewati master;
- checklist `Tidak Baik` memerlukan temuan tertaut;
- kategori foto wajib mengikuti konfigurasi dan scope temuan.

## Batas Bukti

Belum diklaim:

- migration berhasil pada database staging/production;
- upload ke object storage nyata;
- UAT multi-role dengan session Surveyor dan Reviewer nyata;
- UAT multi-customer pada data staging;
- pemeriksaan visual mobile pada browser/perangkat nyata.

Langkah UAT berikutnya harus menjalankan satu skenario dokumen pada database dan object storage terhubung, kemudian memeriksa audit log serta isolasi Customer.
