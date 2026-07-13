# Form Admin Kelaikan Peti Kemas

Dokumen ini mengunci detail form Admin untuk tahap menu, master data aktif, dan placeholder workflow. Database foundation sudah disiapkan untuk master, permohonan, data peti kemas, import, numbering, dan permission kelaikan; CRUD Master Data Stage 1 dan Stage 2 sudah aktif, sedangkan submit aktif, upload aktif, inspection flow penuh, approval final, PDF final, QR final, dan workflow non-master masih belum aktif.

## Prinsip Form

- Admin menyiapkan data yang akan dipakai Surveyor di lapangan.
- Surveyor diarahkan memilih data master, bukan mengetik bebas.
- Type Design hanya future/inactive di dokumentasi, tidak aktif pada UI MVP.
- VGM, penimbangan, sertifikat VGM, billing repair, dan finance utama bukan scope.

## Dashboard Kelaikan

Field tampilan: Total Permohonan, Permohonan Draft, Pemeriksaan Berjalan, Menunggu Review, Perlu Perbaikan, Siap Re-Inspection, Peti Kemas Layak, Peti Kemas Tidak Layak, Dokumen Kelaikan Terbit, Surat Pembebasan Terbit, Aktivitas Terbaru.

Validasi: filter periode harus valid; filter pemilik, lokasi, surveyor, status, dan kategori bersifat opsional.

Dipakai oleh: Admin, Supervisor, Management.

Hubungan ke Surveyor: status dashboard berasal dari hasil pemeriksaan dan rekomendasi yang dikirim Surveyor.

## Permohonan Kelaikan

### 1. Daftar Permohonan

Route: `/fitness/applications`

Field tampilan: Nomor Permohonan, Tanggal Permohonan, Pemilik Peti Kemas, Pabrik Pembuat, Lokasi Pemeriksaan, Kategori Persetujuan Kelaikan, Nomor Surat Permohonan Client, Tanggal Surat Permohonan Client, PIC, Instruksi / Catatan, Status draft/submitted.

Validasi: pemilik, lokasi, kategori, dan tanggal permohonan wajib; email PIC harus valid jika diisi; pabrik pembuat disarankan wajib untuk peti kemas baru.

Dipakai oleh: Data Peti Kemas, Assign Surveyor, Pemeriksaan Lapangan, Dokumen Kelaikan.

Hubungan ke Surveyor: Surveyor menerima konteks permohonan, pemilik, lokasi, kategori persetujuan, dan instruksi pemeriksaan dari data ini.

### 2. Buat Permohonan Kelaikan

Route: `/fitness/applications/create`

Field: Nomor Permohonan auto numbering, Tanggal Permohonan, Pemilik Peti Kemas, Pabrik Pembuat optional, Lokasi Pemeriksaan, Kategori Persetujuan Kelaikan, Nomor Surat Permohonan Client, Tanggal Surat Permohonan Client, Nama PIC, Telepon PIC, Email PIC, Instruksi / Catatan, Status draft/submitted.

Validasi: pemilik wajib diisi; lokasi wajib dipilih; kategori persetujuan wajib dipilih; tanggal permohonan wajib; email PIC harus valid jika diisi; pabrik pembuat disarankan wajib untuk peti kemas baru.

Dipakai oleh: Data Peti Kemas, Assign Surveyor, Pemeriksaan Lapangan, Dokumen Kelaikan.

Hubungan ke Surveyor: Surveyor menerima konteks permohonan, pemilik, lokasi, kategori persetujuan, dan instruksi pemeriksaan dari data ini.

### 3. Import Data Peti Kemas

Route: `/fitness/containers/import`

Field: Pilih Permohonan, Upload file Excel/CSV, Mapping kolom, Preview data, Validasi hasil import, Status import.

Kolom import minimal: container_no, container_type, iso_type_code, csc_no, manufacture_date, manufacturer_serial_no, type_model, max_gross_weight_kg, tare_weight_kg, payload_weight_kg.

Validasi: file wajib Excel/CSV; nomor peti kemas wajib; format nomor peti kemas harus divalidasi; data duplicate harus ditandai; data invalid tidak boleh langsung masuk; import hanya placeholder, belum ada proses upload aktif.

Dipakai oleh: Data Peti Kemas, Assign Surveyor, Pemeriksaan Lapangan, Dokumen Kelaikan.

Hubungan ke Surveyor: Data hasil import akan menjadi daftar peti kemas yang ditugaskan kepada Surveyor.
## Master Data Kelaikan

### 1. Pemilik Peti Kemas

Route: `/fitness/master-data/owners`

Tabel existing: `customers`

Field: Kode Pemilik, Nama Pemilik Peti Kemas, Alamat, NPWP, Nama PIC, Nomor Telepon PIC, Email PIC, Alamat Billing optional, Catatan, Status active/inactive.

Validasi: kode pemilik unik; nama wajib; email valid jika diisi; status wajib.

Dipakai oleh: Permohonan Kelaikan, Data Peti Kemas, Dokumen Kelaikan, Laporan.

Hubungan ke Surveyor: Surveyor melihat pemilik untuk memastikan konteks pekerjaan dan identitas peti kemas.

### 2. Pabrik Pembuat Peti Kemas

Route: `/fitness/master-data/manufacturers`

Tabel foundation: `container_manufacturers`

Field: Kode Pabrik, Nama Pabrik Pembuat, Alamat Pabrik, Negara, Nama PIC, Telepon PIC, Email PIC, Website optional, Catatan, Status active/inactive.

Validasi: kode pabrik unik; nama wajib; negara wajib; email valid jika diisi.

Dipakai oleh: Permohonan Kelaikan, Data Teknis Peti Kemas, Surat Persetujuan Kelaikan.

Hubungan ke Surveyor: menjadi referensi saat Surveyor memeriksa plate dan data teknis.

### 3. Lokasi Pemeriksaan

Route: `/fitness/master-data/locations`

Tabel existing: `locations`

Field: Kode Lokasi, Nama Lokasi, Jenis Lokasi, Alamat, Kota, Latitude optional, Longitude optional, Nama PIC Lokasi, Telepon PIC Lokasi, Status active/inactive.

Validasi: kode lokasi unik; nama wajib; jenis lokasi wajib.

Dipakai oleh: Permohonan Kelaikan, Assignment Surveyor, Pemeriksaan Lapangan, Laporan.

Hubungan ke Surveyor: menjadi tujuan pekerjaan, bukti GPS, dan konteks pemeriksaan lapangan.

### 4. Surveyor / Pemeriksa

Route: `/fitness/master-data/surveyors`

Tabel existing: `surveyor_profiles`

Field: User akun, Kode Surveyor, Nama Lengkap, Nomor Telepon, Area Tugas, Tanda Tangan optional, Status active/inactive.

Validasi: user wajib; kode surveyor unik; nama wajib; inactive tidak boleh di-assign.

Dipakai oleh: Assign Surveyor, Pemeriksaan Lapangan, Dokumen Hasil Pemeriksaan, Laporan.

Hubungan ke Surveyor: akun ini menerima assignment dan mengirim hasil pemeriksaan.

### 5. Jenis / Model Peti Kemas

Route: `/fitness/master-data/container-types`

Tabel existing: `container_types`

Field: Kode Jenis, ISO Code, Ukuran, Nama Tipe, Deskripsi, Status active/inactive, Catatan scope optional.

Validasi: kode jenis unik; ukuran wajib; nama tipe wajib; jenis di luar scope internal tidak aktif default.

Dipakai oleh: Data Peti Kemas, Template Checklist, Pemeriksaan Lapangan, Dokumen Kelaikan.

Hubungan ke Surveyor: menentukan checklist dan parameter pemeriksaan yang tampil.

### 6. Kategori Persetujuan Kelaikan

Route: `/fitness/master-data/approval-categories`

Tabel foundation: `fitness_approval_categories`

Field: Kode Kategori, Nama Kategori, Deskripsi, Berlaku Untuk, Aktif di MVP, Status active/inactive, Display Order.

Validasi: kode kategori unik; kategori aktif MVP hanya peti kemas baru individual dan peti kemas lama sesuai scope; kategori future/inactive tidak tampil aktif di UI MVP.

Dipakai oleh: Permohonan Kelaikan, Template Checklist, Dokumen Kelaikan, Laporan.

Hubungan ke Surveyor: menentukan checklist dan parameter sesuai jenis proses kelaikan.

### 7. Skema Pemeliharaan Peti Kemas

Route: `/fitness/master-data/maintenance-schemes`

Tabel foundation: `maintenance_schemes`

Field: Kode Skema, Nama Skema, Deskripsi, Membutuhkan Next Examination Date yes/no, Interval Pemeriksaan optional, Status active/inactive.

Validasi: kode skema unik; nama wajib; interval numeric jika diisi.

Dipakai oleh: Data Teknis Peti Kemas, CSC Safety Approval Plate, Dokumen Kelaikan, Laporan.

Hubungan ke Surveyor: dipakai untuk memeriksa NED dan skema pada plate/data teknis.

### 8. Area Pemeriksaan Peti Kemas

Route: `/fitness/master-data/inspection-areas`

Tabel foundation: `inspection_areas`

Field: Kode Area, Nama Area, Deskripsi, Urutan Tampil, Status active/inactive.

Validasi: kode area unik; nama wajib; urutan numeric jika diisi.

Dipakai oleh: Komponen Struktur, Form Temuan Surveyor, Foto Evidence.

Hubungan ke Surveyor: Surveyor memilih area seperti roof, floor, door end, understructure, corner area, dan CSC plate area.

### 9. Komponen Struktur Peti Kemas

Route: `/fitness/master-data/structural-components`

Tabel foundation: `structural_components`

Field: Kode Komponen, Nama Komponen, Area Pemeriksaan optional, Komponen Struktural Kritis yes/no, Deskripsi, Urutan Tampil, Status active/inactive.

Validasi: kode komponen unik; nama wajib.

Dipakai oleh: Form Temuan Surveyor, Kriteria Kerusakan, Keputusan Kelaikan.

Hubungan ke Surveyor: Surveyor memilih komponen seperti corner post, cross member, floor, roof, side wall, door panel, dan CSC plate.

### 10. Kriteria Kerusakan / Ketidaksesuaian

Route: `/fitness/master-data/damage-criteria`

Tabel foundation: `structural_damage_criteria`

Field: Kode Kriteria, Nama Kriteria, Komponen Terkait optional, Deskripsi, Tingkat Temuan Default, Default Memengaruhi Kelaikan yes/no, Default Perlu Perbaikan yes/no, Catatan Pemeriksaan, Status active/inactive.

Validasi: kode kriteria unik; nama wajib; severity default harus aktif jika dipilih.

Dipakai oleh: Form Temuan Surveyor, Review Kelaikan, Repair Follow-up, Laporan Kerusakan.

Hubungan ke Surveyor: Surveyor memilih kriteria seperti dent, crack, hole, corrosion, CSC plate missing, unreadable plate, deformation, atau watertightness failure.

### 11. Tingkat Temuan / Severity

Route: `/fitness/master-data/finding-severities`

Tabel foundation: `finding_severities`

Field: Kode Severity, Nama Severity, Deskripsi, Level Angka, Default Memengaruhi Kelaikan yes/no, Default Perlu Review Supervisor yes/no, Warna Badge optional, Status active/inactive.

Validasi: kode severity unik; level angka numeric; data awal minor, major, critical.

Dipakai oleh: Kriteria Kerusakan, Form Temuan Surveyor, Review Kelaikan.

Hubungan ke Surveyor: memberi konteks risiko dan prioritas tindak lanjut untuk reviewer.

### 12. Parameter Pengujian Kelaikan

Route: `/fitness/master-data/test-parameters`

Tabel foundation: `inspection_test_parameters`

Field: Kode Parameter, Nama Parameter, Deskripsi, Satuan, Referensi Standar, Berlaku untuk Peti Kemas Baru, Berlaku untuk Peti Kemas Lama, Wajib Hasil Angka, Wajib Lampiran/Foto, Urutan Tampil, Status active/inactive.

Validasi: kode parameter unik; nama wajib; satuan wajib jika hasil angka diwajibkan.

Dipakai oleh: Form Pengujian Surveyor, Review Hasil Pengujian, Dokumen Kelaikan.

Hubungan ke Surveyor: Surveyor mengisi hasil uji yang diwajibkan oleh kategori dan checklist.

### 13. Template Checklist Kelaikan

Route: `/fitness/master-data/checklist-templates`

Tabel foundation: `fitness_checklist_templates`, `fitness_checklist_template_items`

Field header: Kode Template, Nama Template, Kategori Persetujuan, Jenis / Model Peti Kemas optional, Deskripsi, Versi, Status draft/active/inactive, Created by, Approved by optional.

Field item: Kode Item, Label Pertanyaan, Deskripsi, Area Pemeriksaan optional, Komponen Struktur optional, Parameter Pengujian optional, Response Type, Expected Value optional, Wajib Diisi yes/no, Critical Item yes/no, Jika Gagal Perlu Perbaikan yes/no, Jika Gagal Tidak Layak yes/no, Urutan Tampil, Status active/inactive.

Validasi target akhir: template active minimal satu item; response type wajib; critical item wajib punya aturan dampak.

Status implementasi finishing Admin Master Data: CRUD header `fitness_checklist_templates` aktif, dan item checklist pada `fitness_checklist_template_items` aktif sebagai route nested sederhana. Item ini disiapkan agar nanti form Surveyor dapat dibangun dari master data, tetapi flow Surveyor belum aktif.

Dipakai oleh: Form Surveyor, Review Hasil Pemeriksaan, Audit Trail, Dokumen Kelaikan.

Hubungan ke Surveyor: menjadi daftar pemeriksaan yang diisi Surveyor secara konsisten.

### 14. Kategori Foto Evidence

Route: `/fitness/master-data/photo-categories`

Tabel foundation: `evidence_photo_categories`

Field: Kode Kategori Foto, Nama Kategori Foto, Deskripsi, Wajib Default yes/no, Berlaku Untuk, Urutan Tampil, Status active/inactive.

Validasi: kode kategori unik; nama wajib; berlaku untuk minimal satu konteks.

Dipakai oleh: Upload Foto Surveyor, Temuan Kerusakan, Re-Inspection, Dokumen Evidence.

Hubungan ke Surveyor: mengarahkan foto seperti general container, container number, CSC plate, damage finding, test result, repair evidence, dan reinspection evidence.

### 15. Rekomendasi Hasil Pemeriksaan

Route: `/fitness/master-data/inspection-recommendations`

Tabel foundation: `inspection_recommendations`

Field: Kode Rekomendasi, Nama Rekomendasi, Deskripsi, Final Fitness Result Mapping, Workflow Status Mapping, Restriction Status Mapping, Perlu Review Supervisor yes/no, Status active/inactive.

Validasi: kode rekomendasi unik; mapping status wajib; rekomendasi aktif saja yang tampil di form Surveyor.

Dipakai oleh: Form Surveyor, Review Kelaikan, Status Monitoring.

Hubungan ke Surveyor: Surveyor memilih rekomendasi seperti layak, perlu perbaikan, tidak layak, perlu re-inspection, atau dilarang digunakan sementara.

### 16. Pejabat Penandatangan

Route: `/fitness/master-data/authorized-signers`

Tabel foundation: `authorized_signers`

Field: Nama Pejabat, Jabatan, NIP / ID Pegawai optional, Email, Nomor Telepon, File Tanda Tangan optional, Berlaku Mulai, Berlaku Sampai, Status active/inactive.

Validasi: nama dan jabatan wajib; email valid jika diisi; berlaku sampai tidak boleh sebelum berlaku mulai.

Dipakai oleh: Surat Persetujuan Kelaikan, Surat Pembebasan Setelah Perbaikan, Dokumen Final.

Hubungan ke Surveyor: hasil pemeriksaan lengkap menjadi dasar dokumen yang ditandatangani.

### 17. Profil Badan Usaha

Route: `/fitness/master-data/company-profile`

Tabel existing: `company_profiles`

Field: Nama Badan Usaha, Brand, Alamat, Telepon, Email, Website, Nomor Pajak, Logo, Tanda Tangan Default optional, Status Aktif.

Validasi: nama badan usaha wajib; email valid jika diisi; hanya satu profil aktif sebagai default.

Dipakai oleh: Header Dokumen, Surat Persetujuan, Validasi Dokumen, Report.

Hubungan ke Surveyor: dokumen hasil pemeriksaan memakai profil ini, tetapi Surveyor tidak mengubahnya.
## Admin Master Data CRUD Stage 1

Tahap ini mengaktifkan CRUD nyata untuk 6 master data prioritas Sistem Kelaikan Peti Kemas:

1. Pemilik Peti Kemas (`/fitness/master-data/owners`) memakai tabel `customers`.
2. Pabrik Pembuat Peti Kemas (`/fitness/master-data/manufacturers`) memakai tabel `container_manufacturers`.
3. Lokasi Pemeriksaan (`/fitness/master-data/locations`) memakai tabel `locations`.
4. Surveyor / Pemeriksa (`/fitness/master-data/surveyors`) memakai tabel `surveyor_profiles`.
5. Jenis / Model Peti Kemas (`/fitness/master-data/container-types`) memakai tabel `container_types`.
6. Kategori Persetujuan Kelaikan (`/fitness/master-data/approval-categories`) memakai tabel `fitness_approval_categories`.

Setiap halaman aktif menyediakan list, pencarian, filter status, tambah, detail, edit, validasi dasar, dan aksi nonaktifkan sesuai endpoint REST `/api/v1/fitness/master-data/*`.

Menu yang masih placeholder:

- Item Template Checklist Kelaikan belum menjadi CRUD nested aktif dan belum dipakai flow Surveyor.
- Assign Surveyor menunggu tahap Assignment Surveyor.
- Pemeriksaan & Pengujian menunggu tahap Surveyor Inspection Flow.
- Review & Keputusan menunggu tahap Review & Approval.
- Dokumen Kelaikan menunggu tahap Document & QR.

Batasan tahap ini:

- Tidak mengaktifkan workflow transaksi permohonan, assignment, pemeriksaan lapangan, review final, PDF, QR, import aktif, upload aktif, finance, repair, atau re-inspection.
- Tidak mengubah `database/kontainer_db.sql`, tabel legacy, atau patch `0015_container_fitness_foundation.sql`.
- Permission yang dipakai mengikuti foundation yang sudah ada: `*.view.all` untuk baca dan `*.manage.all` atau permission CRUD existing yang setara untuk perubahan data.
- Patch `0016_container_fitness_master_stage1_permissions.sql` menyelaraskan permission granular `create.all`, `update.all`, dan `delete.all` untuk `container_manufacturers` dan `fitness_approval_categories` agar CRUD Stage 1 berjalan dengan pola permission frontend dan backend saat ini.

## Admin Master Data CRUD Stage 2

Tahap ini mengaktifkan CRUD nyata untuk 11 master data pendukung Surveyor lapangan:

1. Skema Pemeliharaan Peti Kemas (`/fitness/master-data/maintenance-schemes`) memakai tabel `maintenance_schemes`.
2. Area Pemeriksaan Peti Kemas (`/fitness/master-data/inspection-areas`) memakai tabel `inspection_areas`.
3. Komponen Struktur Peti Kemas (`/fitness/master-data/structural-components`) memakai tabel `structural_components`.
4. Kriteria Kerusakan / Ketidaksesuaian (`/fitness/master-data/damage-criteria`) memakai tabel `structural_damage_criteria`.
5. Tingkat Temuan / Severity (`/fitness/master-data/finding-severities`) memakai tabel `finding_severities`.
6. Parameter Pengujian Kelaikan (`/fitness/master-data/test-parameters`) memakai tabel `inspection_test_parameters`.
7. Template Checklist Kelaikan (`/fitness/master-data/checklist-templates`) memakai tabel `fitness_checklist_templates` untuk header dan route `/fitness/master-data/checklist-templates/[id]/items` untuk item `fitness_checklist_template_items`.
8. Kategori Foto Evidence (`/fitness/master-data/photo-categories`) memakai tabel `evidence_photo_categories`.
9. Rekomendasi Hasil Pemeriksaan (`/fitness/master-data/inspection-recommendations`) memakai tabel `inspection_recommendations`.
10. Pejabat Penandatangan (`/fitness/master-data/authorized-signers`) memakai tabel `authorized_signers`.
11. Profil Badan Usaha (`/fitness/master-data/company-profile`) memakai tabel `company_profiles`.

Setiap halaman Stage 2 aktif menyediakan list, pencarian, filter status, tambah, detail, edit, dan aksi nonaktifkan melalui endpoint REST `/api/v1/fitness/master-data/*`.

Batasan Stage 2:

- Item checklist pada `fitness_checklist_template_items` sudah menjadi CRUD nested sederhana melalui `/fitness/master-data/checklist-templates/[id]/items`, namun belum dipakai oleh flow Surveyor.
- Tidak mengaktifkan Assignment Surveyor, Pemeriksaan Lapangan, Review/Approval final, Dokumen PDF/QR final, Import Excel proses nyata, Finance, atau workflow transaksi lain.
- Tidak mengubah tabel legacy, tidak drop/rename tabel, dan tidak mengubah patch `0015` maupun `0016`.
- Patch `0017_container_fitness_master_stage2_permissions.sql` menyelaraskan permission granular `view.all`, `create.all`, `update.all`, dan `delete.all` untuk 11 master Stage 2 dan mapping `super_admin`/`admin`.
## Finishing Admin Master Data Kelaikan

Tahap finishing ini menambahkan dropdown untuk field relasi master data agar Admin tidak perlu menginput UUID manual pada Komponen Struktur, Kriteria Kerusakan, dan Template Checklist Kelaikan.

Template checklist item sudah tersedia sebagai CRUD sederhana di `/fitness/master-data/checklist-templates/[id]/items` dengan relasi ke area pemeriksaan, komponen struktur, dan parameter pengujian. Data ini disiapkan agar nanti form Surveyor dapat dibangun dari master data.

Tahap finishing ini belum mengaktifkan Assignment Surveyor, Pemeriksaan Lapangan, Review, Dokumen, PDF, QR, Import aktif, Finance, atau workflow transaksi Permohonan Kelaikan.
## Tahap 1 - Hardening Generic Master Data

Tahap 1 memperkuat generic CRUD Master Data Kelaikan tanpa menambah tabel, patch, migration, dashboard, permohonan, import, assignment, inspection, review, dokumen, laporan, atau UI Surveyor.

Perubahan teknis utama:

- Field generik sekarang mendukung `text`, `textarea`, `number`, `decimal`, `email`, `tel`, `url`, `date`, `datetime-local`, `select`, `searchable-select`, `checkbox`, dan `hidden`.
- Field panjang seperti `address`, `billing_address`, `description`, `note`, dan `inspection_note` dipetakan ke `textarea`.
- Field telepon, email, URL, tanggal, decimal, dan numeric memiliki metadata input dan validasi backend yang lebih sesuai.
- Optional field yang dikosongkan saat edit dikirim sebagai `null`, bukan dibuang dari payload.
- Required field tidak boleh kosong pada create maupun update.
- Aksi Nonaktifkan pada namespace `/fitness/master-data/*` hanya mengubah status/is_active dan tidak mengisi `deleted_at`.
- Filter status mengikuti resource: master umum memakai Aktif/Tidak Aktif, checklist template memakai Draf/Aktif/Tidak Aktif, company profile memakai status aktif berbasis `is_active`.
- Relation dropdown memakai pencarian server-side, mempertahankan nilai lama saat edit, dan menampilkan pesan bila data referensi tidak ditemukan.
- Mutation master data sekarang tidak lagi mengabaikan error audit log.

Catatan: hardening ini belum mengaktifkan workflow transaksi Kelaikan dan belum membuktikan CRUD runtime terhadap database kerja utama.
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