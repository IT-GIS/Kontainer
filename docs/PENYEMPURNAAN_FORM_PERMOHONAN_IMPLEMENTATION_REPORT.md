# Laporan Implementasi Penyempurnaan Form Permohonan dan Alur Admin

Tanggal verifikasi: 4 September 2026

Status implementasi: selesai pada source, migrasi lokal, dan UAT API

Dokumen ini mencatat implementasi terhadap spesifikasi
`PENYEMPURNAAN_FORM_PERMOHONAN_DAN_ALUR_ADMIN_KELAIKAN_PETI_KEMAS.md`.

## Cakupan yang diselesaikan

### Customer

- Form Customer memakai satu sumber data Customer dan tidak menyimpan data per unit peti kemas.
- `Customer Code`, `Customer Name`, `Bentuk Entitas`, dan `Alamat Utama` wajib diisi.
- Bentuk entitas menyediakan `Badan Usaha` dan `Perorangan`.
- Negara dan catatan administratif tersedia sebagai data opsional.
- PIC lama dipertahankan sebagai kontak legacy opsional; PIC operasional tetap dikelola pada tahap `Lokasi & PIC`.
- Setelah membuat Customer, Admin diarahkan ke tahap `Lokasi & PIC`.
- Customer Readiness mewajibkan Location, Personel/PIC, mapping Location-PIC, Survey Type, Container Type, checklist, referensi, kebutuhan foto, dan CEDEX efektif.
- Responsibility Code legacy tidak lagi menjadi pemeriksaan wajib pada workflow baru.

### Permohonan / Job

- Satu Job tetap menjadi satu permohonan aktif; rute permohonan fitness lama diarahkan ke alur Job.
- Job menyimpan kategori persetujuan MVP, pemilik aktual, hubungan pemohon-pemilik, manufacturer opsional, rencana pemeriksaan, dan catatan khusus.
- Pemilik dipilih dari Customer aktif sehingga pemohon dapat menjadi pemilik atau mewakili Customer lain yang sudah terdaftar.
- Location, Survey Type, dan PIC divalidasi sebagai data aktif milik Customer pemohon.
- Nomor/tanggal/keterangan SPK tetap tersimpan bersama metadata lampiran.
- Field logistik tetap opsional dan tidak menjadi blocker readiness.

### Lampiran Surat Permohonan / SPK

- Endpoint unggah, ganti, dan unduh lampiran tersedia pada Job.
- Format yang diterima berdasarkan deteksi MIME backend: PDF, JPEG, dan PNG.
- Batas ukuran diterapkan pada request dan stream file.
- Nama file dinormalisasi, object disimpan private, checksum SHA-256 dicatat, serta event dan audit log dibuat.
- Akses unggah dan unduh mengikuti permission Job yang sudah ada.
- Jika unggah setelah pembuatan Job gagal, UI mengarahkan Admin ke Job yang sudah terbentuk untuk mencoba ulang tanpa membuat Job duplikat.

### Data Peti Kemas dan Inspection Readiness

- Draft unit dapat dibuat hanya dengan Container Number yang valid.
- Check digit harus valid atau memakai alasan override yang dicatat bersama pelaku dan waktu override.
- Data draft dapat dilengkapi kemudian melalui `PUT /api/v1/job-containers/:id` dan aksi `Lengkapi` pada detail Job.
- Container Type dan Size menjadi blocker keras sebelum assignment.
- Size dan ISO Type diambil konsisten dari Container Type Customer.
- Data CSC awal, berat/kapasitas, manufacturer, dan skema pemeliharaan tersedia tanpa dijadikan blocker berlebihan.
- Foundation `container_technical_specs`, master manufacturer, approval category, dan maintenance scheme dipakai ulang; tidak dibuat master duplikat.
- Readiness tersedia per unit melalui `GET /api/v1/jobs/:id/inspection-readiness` dengan status `BLOCKED`, `READY_WITH_WARNINGS`, atau `READY`.
- `CSC Plate Status = Not Checked` tetap diperlakukan sebagai warning, sesuai skenario data yang akan diverifikasi Surveyor di lapangan.
- Backend assignment mengevaluasi Customer Readiness dan Inspection Readiness dalam transaksi yang sama.

### Surveyor, Reviewer, dan Report

- Saat Survey dimulai, data Customer, Job, Container, owner, kategori, manufacturer, data teknis, dan CSC awal disalin sebagai snapshot.
- Nilai CSC awal Admin dan nilai CSC terverifikasi Surveyor disimpan pada kolom terpisah.
- Perbedaan penting mewajibkan General Remark dan tidak menimpa nilai awal.
- Query tanggal snapshot memakai nilai `YYYY-MM-DD` langsung dari database agar tidak bergeser karena konversi zona waktu.
- Reviewer dan Report menampilkan data awal serta data terverifikasi secara berdampingan.
- Survey Sheet, checklist, finding berbasis CEDEX, general evidence, finding evidence, revision, approval, rejection, dan audit history existing tetap dipertahankan.
- Label `Owner Code` pada nomor ISO tidak lagi dipresentasikan sebagai pemilik/operator legal.

## Perubahan database

Migrasi utama:

- `services/api/migrations/0020_application_job_readiness.up.sql`
- `services/api/migrations/0020_application_job_readiness.down.sql`
- `database/patches/0026_application_job_readiness.sql`

Patch kompatibilitas `0026` diterapkan setelah prerequisite `database/patches/0025_survey_sheet_data_flow.sql` pada database Laragon lokal. Sebelum perubahan dibuat backup:

`database/backups/kontainer_db_before_0026_20260904_105714.sql`

Hasil pemeriksaan skema lokal:

| Pemeriksaan | Hasil |
| --- | ---: |
| Kolom Customer baru | 3/3 |
| Kolom Job baru | 6/6 |
| Relasi baru pada technical specs | 2/2 |
| Kolom snapshot/verified Survey baru | 14/14 |
| Kategori persetujuan MVP aktif | 3 |
| Skema pemeliharaan aktif | 6 |
| Manufacturer aktif | 0 |

Manufacturer tetap opsional. Ketika master belum berisi data aktif, UI tidak mengarang pilihan dan menampilkan kondisi belum tersedia.

## Bukti UAT API lokal

UAT menggunakan Customer fixture yang telah lengkap dan menambahkan mapping Location-PIC fixture yang sebelumnya belum ada.

1. Customer Readiness menghasilkan 16/16 pemeriksaan siap tanpa Responsibility Code.
2. Job dengan pemohon sebagai pemilik berhasil dibuat.
3. Draft unit hanya dengan `MSKU1234565` berhasil dibuat dan check digit dinyatakan valid.
4. Inspection Readiness menghasilkan blocker `CONTAINER_TYPE` dan `CONTAINER_SIZE`.
5. Assignment pada kondisi tersebut ditolak dengan HTTP 422.
6. Setelah Container Type dan data teknis dilengkapi, status menjadi `READY_WITH_WARNINGS` tanpa blocker.
7. Assignment ke Surveyor berhasil.
8. Job dengan pemohon dan pemilik berbeda menyimpan nama owner serta hubungan `owner_representative` secara terpisah.
9. Survey dapat dimulai dan snapshot tanggal tersimpan tanpa pergeseran tanggal.
10. CSC awal `not_checked` tetap tersimpan, sementara CSC hasil verifikasi `available` dan nomor aktual tersimpan pada field verified.
11. Nilai tanggal CSC awal dan verified yang sama tidak memicu mismatch palsu.
12. Seluruh Job, assignment, dan Survey UAT baru ditutup setelah verifikasi agar tidak menjadi pekerjaan aktif; record dan audit trail tetap dipertahankan.

UAT unggah object secara langsung berstatus `SKIPPED_OBJECT_STORAGE_UNAVAILABLE`: Docker daemon/MinIO lokal tidak aktif. Wiring endpoint, validasi MIME/ukuran, safe filename, checksum, private metadata, dan audit sudah diverifikasi oleh test backend. Kriteria spesifikasi menyatakan lampiran aktif ketika object storage siap.

## Hasil validasi source

- `go test ./...`: lulus.
- `go vet ./...`: lulus.
- `npm run typecheck`: lulus.
- `npm run lint`: lulus tanpa error.
- `npm run build`: lulus; 76/76 route berhasil dibangun.
- Migrasi/patch lokal: diterapkan dan diverifikasi terhadap `information_schema`.
