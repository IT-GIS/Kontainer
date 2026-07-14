# REDESIGN UI/UX ADMIN KELAIKAN PETI KEMAS
## Baseline Terpadu — Struktur Menu Sederhana, Data Berbasis Klien, dan Alur Layanan Inspeksi

**Repository:** `IT-GIS/Kontainer`
**Nama aplikasi:** Sistem Kelaikan Peti Kemas
**Penyedia jasa:** PT Global Inspeksi Forensik Teknik (GIFT)
**Fokus dokumen:** UI/UX Admin, struktur menu, alur kerja, form, data berbasis klien, dan kesiapan integrasi tahap berikutnya
**Status dokumen:** Baseline terbaru yang menggantikan struktur Master Data global pada dokumen sebelumnya
**Integrasi backend/database:** Tidak diubah pada tahap UI ini
**Istilah wajib:** Kelaikan

---

# 1. STATUS DAN PRIORITAS DOKUMEN

Dokumen ini menjadi baseline terpadu untuk pengembangan UI Admin.

Apabila terdapat perbedaan dengan dokumen sebelumnya, gunakan urutan prioritas berikut:

1. Dokumen ini menjadi acuan utama untuk:
   - struktur menu Admin;
   - kepemilikan data;
   - Klien & Master Data;
   - pemisahan data klien dan data internal GIFT;
   - alur Permohonan;
   - hubungan Master Data Klien dengan Peti Kemas, Penugasan, Pemeriksaan, dan Review;
   - tahapan implementasi setelah UI-B.

2. Dokumen UI-A digunakan untuk:
   - shell;
   - branding;
   - breadcrumb;
   - active navigation;
   - compatibility route.

3. Dokumen UI-B digunakan untuk:
   - design system;
   - reusable component;
   - responsive pattern;
   - empty, loading, error, dan success state;
   - interaction hardening.

4. Dokumen lama yang masih menempatkan Master Data sebagai data global tidak digunakan apabila bertentangan dengan konsep berbasis klien pada dokumen ini.

---

# 2. KONTEKS BISNIS

Aplikasi ini bukan aplikasi pengelolaan aset peti kemas milik GIFT.

GIFT berperan sebagai penyedia jasa inspeksi kelaikan peti kemas untuk perusahaan atau organisasi lain sebagai klien.

Konsekuensinya:

- perusahaan yang diperiksa adalah klien;
- peti kemas yang diperiksa adalah milik, dikuasai, atau digunakan klien;
- lokasi pemeriksaan adalah lokasi milik atau digunakan klien;
- personel/PIC yang mendampingi proses berasal dari klien;
- Surveyor GIFT adalah personel internal GIFT yang melakukan inspeksi;
- Supervisor/Reviewer GIFT melakukan review dan keputusan sesuai kewenangan;
- pejabat penandatangan melakukan proses sesuai kewenangan;
- data satu klien tidak boleh tercampur dengan klien lain;
- aplikasi harus mendukung pelaksanaan inspeksi sesuai regulasi yang berlaku;
- perbaikan fisik dilakukan oleh klien atau pihak eksternal;
- aplikasi tidak menjadi sistem workshop, bengkel, penagihan, atau inventori perbaikan.

Alur layanan utama:

```text
Klien
→ Permohonan
→ Peti Kemas
→ Kesiapan Penugasan
→ Penugasan Surveyor GIFT
→ Pemeriksaan
→ Review
→ Tindak Lanjut Perbaikan
→ Pemeriksaan Ulang
→ Keputusan
→ Dokumen Kelaikan
→ Laporan
```

---

# 3. TUJUAN REDESIGN

Redesign sisi Admin bertujuan agar aplikasi:

1. mudah dipahami Admin nonteknis;
2. mengikuti alur pelayanan inspeksi;
3. tidak terasa seperti kumpulan menu teknis;
4. membedakan data milik klien dan data internal GIFT;
5. menghindari pengetikan data berulang;
6. membuat Surveyor nantinya cukup memilih data yang telah disiapkan;
7. menampilkan kesiapan proses secara visual;
8. modern, profesional, ringan, dan responsif;
9. siap disambungkan ke API/database pada tahap berikutnya;
10. tetap mempertahankan route lama melalui compatibility mapping;
11. belum membangun workspace Surveyor penuh;
12. belum mengubah backend, database, migration, atau patch SQL.

---

# 4. PRINSIP DESAIN

## 4.1 Prinsip bisnis

1. Pilih klien sekali, gunakan data klien berulang kali.
2. Semua pilihan data turunan dibatasi berdasarkan klien.
3. Surveyor GIFT tidak mengetik ulang data yang sudah disiapkan Admin.
4. Data klien tidak boleh berpindah ke klien lain melalui form turunan.
5. Pemeriksaan Ulang harus terhubung dengan pemeriksaan sebelumnya.
6. Status proses dikendalikan sistem, bukan dropdown bebas.
7. Referensi legacy tidak boleh menjadi sumber workflow aktif.
8. Perbaikan dilakukan pihak eksternal.
9. Dokumen final, QR, dan verifikasi publik belum diaktifkan.
10. Arsip lama hanya read-only.

## 4.2 Karakter visual

- Corporate dan profesional.
- Dominan putih dan biru.
- Latar abu-abu sangat muda.
- Tidak gelap.
- Tidak terlalu ramai.
- Gradient digunakan sangat terbatas.
- Typography jelas.
- Spacing lega.
- Fokus pada keterbacaan.
- Responsif desktop, tablet, dan mobile.

## 4.3 Status visual

| Status UI | Warna |
|---|---|
| Draf | Abu-abu |
| Belum Lengkap | Kuning |
| Siap Ditugaskan | Biru |
| Sedang Berjalan | Biru tua |
| Menunggu Review | Ungu lembut |
| Perlu Perbaikan | Oranye |
| Siap Pemeriksaan Ulang | Cyan |
| Layak | Hijau |
| Tidak Layak | Merah |
| Dibatalkan | Abu gelap |
| Tidak Aktif | Abu muda |

Status tidak boleh hanya dibedakan berdasarkan warna.

Gunakan label teks, icon, dan penjelasan singkat.

---

# 5. IDENTITAS APLIKASI

## 5.1 Branding sidebar

Gunakan:

**Sistem Kelaikan Peti Kemas**
**PT Global Inspeksi Forensik Teknik**

Jangan menampilkan nama perusahaan lain pada workspace GIFT.

## 5.2 Subtitle topbar

> Kelola klien, permohonan, pemeriksaan, review, dan dokumen kelaikan peti kemas.

## 5.3 Logo

- Gunakan logo GIFT dari repository.
- Jangan gepeng.
- Tetap jelas saat sidebar diciutkan.
- Gunakan padding yang cukup.
- Jangan menduplikasi logo pada satu halaman.

---

# 6. DEFINISI ISTILAH

## 6.1 Klien

Perusahaan atau organisasi yang menggunakan jasa inspeksi GIFT.

## 6.2 Pemohon

Pihak yang mengajukan permohonan inspeksi.

Pemohon dapat sama atau berbeda dengan klien sesuai kondisi bisnis.

## 6.3 Pemilik/Pengguna Peti Kemas

Pihak yang memiliki, menguasai, atau menggunakan peti kemas.

Nilainya dapat sama atau berbeda dengan klien.

Sistem boleh mengisi nilai awal dari data klien, tetapi tidak boleh menyatukan ketiganya secara permanen tanpa aturan bisnis yang jelas.

## 6.4 Personel/PIC Klien

Personel dari pihak klien, misalnya:

- PIC utama;
- PIC lokasi;
- penanggung jawab peti kemas;
- personel teknis;
- pendamping pemeriksaan;
- surveyor internal klien bila ada.

## 6.5 Surveyor GIFT

Personel internal GIFT yang ditugaskan melakukan inspeksi.

Surveyor GIFT tidak ditempatkan pada Master Data Klien.

## 6.6 Supervisor/Reviewer

Personel GIFT yang melakukan review hasil pemeriksaan dan keputusan sesuai kewenangan.

## 6.7 Pemeriksaan Ulang

Pemeriksaan lanjutan yang berasal dari pemeriksaan sebelumnya.

Pemeriksaan Ulang:

- bukan permohonan baru yang berdiri sendiri;
- harus mempertahankan hubungan dengan hasil dan temuan sebelumnya;
- statusnya dikendalikan workflow.

---

# 7. KEPEMILIKAN DATA

## 7.1 Data milik klien

- profil klien;
- lokasi klien;
- personel/PIC klien;
- jenis peti kemas yang digunakan klien;
- referensi pemeriksaan milik klien;
- daftar peti kemas individual;
- data teknis peti kemas;
- bukti dan riwayat pemeriksaan;
- bukti tindak lanjut perbaikan;
- mapping referensi legacy yang terkait klien.

## 7.2 Data internal GIFT

- user aplikasi;
- Surveyor GIFT;
- Supervisor/Reviewer;
- pejabat penandatangan;
- profil badan usaha;
- pengaturan penomoran;
- role dan permission;
- audit log;
- konfigurasi internal aplikasi.

## 7.3 Aturan isolasi

```text
Klien A
→ hanya menggunakan lokasi, personel, jenis, dan referensi milik Klien A

Klien B
→ hanya menggunakan lokasi, personel, jenis, dan referensi milik Klien B
```

Dilarang:

- lokasi Klien A muncul pada permohonan Klien B;
- PIC Klien A muncul pada tugas Klien B;
- jenis peti kemas Klien A muncul pada Klien B;
- mapping legacy Klien A muncul pada Klien B;
- form data turunan memindahkan data ke klien lain;
- data digabung seluruhnya lalu difilter hanya secara visual bila berisiko tercampur.

---

# 8. STRUKTUR SIDEBAR ADMIN

Sidebar dibuat sederhana:

```text
ADMIN KELAIKAN

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
```

Prinsip sidebar:

- submenu teknis tidak ditampilkan panjang;
- tab digunakan di dalam halaman;
- active state jelas;
- route detail tetap menyalakan menu induk;
- sidebar dapat diciutkan;
- tooltip tersedia saat sidebar diciutkan;
- mobile menggunakan drawer;
- tombol Keluar berada di footer.

---

# 9. STRUKTUR ROUTE UI

Route berikut adalah usulan UI dan bukan kontrak backend.

```text
/fitness/dashboard

/fitness/clients
/fitness/clients/create
/fitness/clients/:clientId

/fitness/client-master-data
/fitness/client-master-data/:clientId
/fitness/client-master-data/:clientId?tab=summary
/fitness/client-master-data/:clientId?tab=locations
/fitness/client-master-data/:clientId?tab=personnel
/fitness/client-master-data/:clientId?tab=container-types
/fitness/client-master-data/:clientId?tab=inspection-references
/fitness/client-master-data/:clientId?tab=legacy-mapping
/fitness/client-master-data/:clientId?tab=legacy-mapping&section=location
/fitness/client-master-data/:clientId?tab=legacy-mapping&section=component
/fitness/client-master-data/:clientId?tab=legacy-mapping&section=damage
/fitness/client-master-data/:clientId?tab=legacy-mapping&section=material

/fitness/applications
/fitness/applications/create
/fitness/applications/:id

/fitness/containers
/fitness/containers/import
/fitness/containers/:id

/fitness/assignments
/fitness/inspections
/fitness/reviews
/fitness/repair-followups
/fitness/documents
/fitness/reports
/fitness/legacy-archive

/settings/company-profile
/settings/surveyors
/settings/reviewers
/settings/signers
/settings/numbering
/settings/users
/settings/roles
/settings/audit-log
```

Catatan:

- route lama `/fitness/master-data` tetap dipertahankan melalui compatibility;
- route lama diarahkan ke halaman pemilihan klien atau halaman penjelasan migrasi;
- route detail Master Data lama tidak boleh langsung menjadi workflow aktif tanpa konteks klien;
- route pembuatan dan import harus tetap menang dari pattern detail umum.

---

# 10. GLOBAL APP SHELL

## 10.1 Topbar

Tampilkan:

- breadcrumb;
- judul halaman;
- subtitle;
- primary action;
- secondary action bila relevan;
- role pengguna;
- notifikasi;
- profil pengguna.

## 10.2 Breadcrumb

Contoh:

```text
Admin Kelaikan
/ Klien & Master Data
/ Master Data Klien
/ PT Contoh Logistik
/ Lokasi
```

## 10.3 Page header

Setiap halaman memiliki:

- judul;
- deskripsi;
- metadata;
- status badge bila relevan;
- primary action;
- secondary action;
- context klien bila relevan.

## 10.4 Context klien

Pada semua halaman turunan klien, tampilkan context strip:

```text
Klien aktif: PT Contoh Logistik
Kode: CL-001
Status: Aktif
```

Context klien harus berasal dari route/state yang dapat diuji.

Jangan hanya menampilkan nama klien hardcoded.

---

# 11. DASHBOARD ADMIN

Dashboard menjadi pusat tindakan Admin.

## 11.1 Perlu Tindakan Anda

Card:

- klien belum lengkap;
- permohonan belum lengkap;
- data teknis peti kemas belum lengkap;
- pekerjaan belum ditugaskan;
- pemeriksaan menunggu review;
- perbaikan belum selesai;
- pemeriksaan ulang siap dijadwalkan;
- dokumen perlu disiapkan.

Setiap card menampilkan:

- angka;
- deskripsi;
- CTA;
- icon;
- status;
- filter klien bila relevan.

## 11.2 Ringkasan status

- Total Klien Aktif
- Total Permohonan
- Pemeriksaan Berjalan
- Perlu Perbaikan
- Menunggu Pemeriksaan Ulang
- Layak
- Tidak Layak

## 11.3 Aktivitas terbaru

Timeline:

- klien dibuat;
- Master Data Klien diperbarui;
- permohonan dibuat;
- peti kemas ditambahkan;
- Surveyor ditugaskan;
- pemeriksaan dikirim;
- reviewer memberikan keputusan;
- bukti perbaikan diterima;
- dokumen disiapkan.

## 11.4 Quick action

- Tambah Klien
- Kelola Master Data Klien
- Buat Permohonan
- Import Peti Kemas
- Buka Penugasan
- Buka Review

## 11.5 Filter

- Periode
- Klien
- Pemilik/Pengguna Peti Kemas
- Lokasi Klien
- Surveyor GIFT
- Jenis Peti Kemas
- Tahap Proses

---

# 12. KLIEN & MASTER DATA

Menu ini memiliki dua tab utama:

```text
[Daftar Klien]
[Master Data Klien]
```

---

# 13. DAFTAR KLIEN

## 13.1 Tujuan

Menampilkan seluruh perusahaan atau organisasi pengguna jasa GIFT.

## 13.2 Toolbar

- pencarian nama/kode klien;
- filter status;
- filter kota/provinsi;
- reset filter;
- Tambah Klien.

## 13.3 Kolom

- Kode Klien
- Nama Perusahaan/Organisasi
- Alamat Singkat
- PIC Utama
- Email
- Telepon
- Jumlah Lokasi
- Jumlah Peti Kemas
- Status
- Pembaruan Terakhir
- Aksi

## 13.4 Aksi

- Lihat Detail
- Edit
- Kelola Master Data
- Nonaktifkan
- Lihat Permohonan
- Lihat Peti Kemas

## 13.5 Form Klien

Section:

### Identitas

- kode klien;
- nama perusahaan/organisasi;
- nama singkat;
- status.

### Legal dan alamat

- alamat;
- kota/kabupaten;
- provinsi;
- kode pos;
- identitas perusahaan bila tersedia.

### Kontak

- PIC utama;
- jabatan;
- email;
- telepon.

### Catatan

- catatan Admin;
- informasi akses;
- lampiran pendukung placeholder.

Form menggunakan:

- FormSection;
- FormField;
- SearchableSelect;
- StickyActionBar;
- UnsavedChangesGuard;
- ConfirmationDialog;
- ToastFeedback.

---

# 14. MASTER DATA KLIEN

## 14.1 Alur

```text
Master Data Klien
→ Pilih Klien
→ Buka Halaman Klien
→ Pilih Tab Data
→ Tambah/Edit/Nonaktifkan
```

## 14.2 Halaman pemilihan klien

Tampilkan:

- pencarian;
- filter status;
- kartu/tabel;
- jumlah lokasi;
- jumlah personel;
- jumlah jenis peti kemas;
- jumlah referensi;
- status kelengkapan;
- tombol Kelola Master Data.

## 14.3 Halaman klien

Header:

- judul `Master Data Klien`;
- nama perusahaan;
- kode klien;
- status;
- PIC utama;
- pembaruan terakhir.

Tab utama:

```text
[Ringkasan]
[Lokasi]
[Personel/PIC Klien]
[Jenis Peti Kemas]
[Referensi Pemeriksaan]
[Mapping Legacy]
```

Catatan:

- tidak ada tab Surveyor GIFT;
- tidak ada tab Jenis Pemeriksaan bebas;
- tidak ada kelompok aktif CEDEX pada sidebar;
- referensi legacy hanya read-only/mapping;
- referensi aktif menggunakan istilah pemeriksaan yang telah ditetapkan.

---

# 15. TAB RINGKASAN

Tampilkan:

- jumlah lokasi aktif;
- jumlah personel/PIC aktif;
- jumlah jenis peti kemas;
- jumlah referensi pemeriksaan;
- jumlah mapping legacy;
- status kelengkapan;
- pembaruan terakhir;
- aktivitas terbaru.

Card kelengkapan:

```text
Lokasi               4 data aktif
Personel/PIC          6 data aktif
Jenis Peti Kemas      3 data aktif
Referensi Pemeriksaan 18 data aktif
Mapping Legacy        27 data terbaca
```

Aksi:

- Tambah Lokasi
- Tambah Personel
- Tambah Jenis Peti Kemas
- Kelola Referensi
- Lihat Data Belum Lengkap

---

# 16. TAB LOKASI KLIEN

## 16.1 Tujuan

Menyimpan lokasi yang dimiliki atau digunakan klien untuk proses inspeksi.

## 16.2 Jenis lokasi

- depo;
- gudang;
- terminal;
- pelabuhan;
- lokasi pemeriksaan;
- lokasi perbaikan eksternal;
- lainnya.

## 16.3 Kolom

- Kode Lokasi
- Nama Lokasi
- Jenis
- Alamat
- Kota/Kabupaten
- Provinsi
- PIC Lokasi
- Telepon
- Status
- Pembaruan Terakhir
- Aksi

## 16.4 Form tambah/edit

Tampilkan:

```text
Klien: PT Contoh Logistik
```

Klien bersifat read-only.

Field:

- kode lokasi;
- nama lokasi;
- jenis lokasi;
- alamat;
- kota/kabupaten;
- provinsi;
- kode pos;
- PIC;
- telepon;
- email;
- catatan akses;
- status aktif.

Aksi:

- Simpan
- Simpan dan Tambah Baru
- Batal
- Nonaktifkan

Surveyor GIFT nantinya memilih lokasi dari daftar ini.

---

# 17. TAB PERSONEL/PIC KLIEN

## 17.1 Tujuan

Menyimpan personel pihak klien yang terlibat dalam proses pelayanan inspeksi.

## 17.2 Tipe personel

- PIC Utama
- PIC Lokasi
- Penanggung Jawab Peti Kemas
- Personel Teknis
- Pendamping Pemeriksaan
- Surveyor Internal Klien

## 17.3 Kolom

- Nama
- Jabatan
- Tipe Personel
- Lokasi Terkait
- Email
- Telepon
- Status
- Pembaruan Terakhir
- Aksi

## 17.4 Aturan

- Surveyor GIFT tidak boleh masuk tab ini;
- lokasi terkait hanya berasal dari klien aktif;
- personel tidak dapat dipindahkan ke klien lain;
- satu personel dapat terkait ke satu atau beberapa lokasi bila pola UI mendukung.

---

# 18. TAB JENIS PETI KEMAS KLIEN

## 18.1 Tujuan

Menyimpan referensi jenis peti kemas yang digunakan klien.

## 18.2 Kolom

- Kode
- Nama Jenis
- Ukuran
- Deskripsi
- Status
- Pembaruan Terakhir
- Aksi

## 18.3 Aturan

- data ini hanya referensi jenis;
- peti kemas individual tetap berada pada menu Peti Kemas;
- data jenis harus dapat dipilih pada form peti kemas;
- jenis satu klien tidak otomatis muncul pada klien lain.

---

# 19. TAB REFERENSI PEMERIKSAAN

Referensi aktif yang digunakan pada workflow baru:

```text
[Area Pemeriksaan]
[Komponen Struktur Peti Kemas]
[Kriteria Kerusakan/Ketidaksesuaian]
[Tingkat Keparahan]
[Parameter Pengujian]
[Kategori Bukti Foto]
[Rekomendasi Pemeriksaan]
```

## 19.1 Area Pemeriksaan

Kolom:

- kode;
- nama area;
- deskripsi;
- status;
- urutan.

## 19.2 Komponen Struktur Peti Kemas

Kolom:

- kode;
- nama komponen;
- area terkait;
- deskripsi;
- status.

## 19.3 Kriteria Kerusakan/Ketidaksesuaian

Kolom:

- kode;
- nama;
- komponen terkait;
- deskripsi;
- status.

## 19.4 Tingkat Keparahan

Kolom:

- kode;
- label;
- deskripsi;
- dampak visual;
- status.

Jangan mengarang dampak workflow backend.

## 19.5 Parameter Pengujian

Kolom:

- kode;
- nama parameter;
- satuan bila tersedia;
- deskripsi;
- status.

## 19.6 Kategori Bukti Foto

Kolom:

- kode;
- nama kategori;
- deskripsi;
- wajib/tidak wajib sebagai presentation state;
- status.

## 19.7 Rekomendasi Pemeriksaan

Kolom:

- kode;
- nama rekomendasi;
- deskripsi;
- status.

## 19.8 Checklist seed

Checklist seed dikunci sampai baseline teknis/regulasi diverifikasi.

Jangan mengarang:

- item checklist;
- nilai batas;
- tingkat gagal;
- keputusan otomatis;
- referensi regulasi.

---

# 20. MAPPING LEGACY

## 20.1 Posisi

Referensi legacy tidak menjadi Master Data aktif utama.

Tampilkan sebagai:

```text
Mapping Legacy
```

Subtab:

```text
[Location]
[Component]
[Damage]
[Material]
```

Referensi Repair tidak ditampilkan sebagai tab aktif.

## 20.2 Tujuan

- membantu pembacaan data lama;
- memetakan data lama ke referensi aktif;
- mendukung migrasi;
- menjaga riwayat;
- tidak menjadi sumber input utama workflow baru.

## 20.3 Perilaku

- read-only;
- filter berdasarkan klien;
- menampilkan kode lama;
- menampilkan nama lama;
- menampilkan target mapping aktif bila tersedia;
- tidak menyediakan CRUD aktif baru;
- tidak digunakan sebagai menu sidebar;
- tidak mengaktifkan modul workshop;
- tidak mengaktifkan inventori material;
- tidak mengaktifkan biaya atau invoice.

## 20.4 Mapping yang disarankan

```text
Legacy Location
→ Lokasi Klien atau Area Pemeriksaan

Legacy Component
→ Komponen Struktur Peti Kemas

Legacy Damage
→ Kriteria Kerusakan/Ketidaksesuaian

Legacy Material
→ Catatan teknis legacy/read-only
```

Mapping final harus mengikuti data dan struktur yang benar-benar tersedia di repository.

---

# 21. PERMOHONAN

## 21.1 Daftar Permohonan

Toolbar:

- pencarian;
- filter klien;
- filter status;
- filter tanggal;
- filter lokasi;
- filter kategori;
- reset;
- Buat Permohonan.

Kolom:

- Nomor Permohonan
- Tanggal
- Klien
- Pemohon
- Pemilik/Pengguna Peti Kemas
- Lokasi
- Jumlah Peti Kemas
- Kelengkapan
- Tahap Proses
- Pembaruan Terakhir
- Aksi

## 21.2 Form Buat Permohonan

Gunakan stepper:

```text
1. Klien dan Pemohon
2. Informasi Permohonan
3. Lokasi dan PIC
4. Peti Kemas
5. Instruksi Pemeriksaan
6. Lampiran
7. Ringkasan
```

### Tahap 1 — Klien dan Pemohon

- Klien
- Pemohon
- Pemilik/Pengguna Peti Kemas
- Alamat
- PIC
- Telepon
- Email

Setelah klien dipilih, sistem memuat:

- lokasi;
- personel/PIC;
- jenis peti kemas;
- referensi pemeriksaan aktif.

### Tahap 2 — Informasi Permohonan

- Nomor Permohonan — otomatis/read-only
- Tanggal Permohonan
- Kategori Layanan/Persetujuan
- Nomor Surat Permohonan
- Tanggal Surat
- Lampiran Surat

### Tahap 3 — Lokasi dan PIC

- Lokasi Pemeriksaan
- Alamat Lokasi — otomatis
- Kota/Kabupaten
- PIC Lokasi
- Telepon
- Catatan Akses
- Rencana Tanggal Pemeriksaan

Pilihan hanya dari Master Data Klien aktif.

### Tahap 4 — Peti Kemas

- tambah peti kemas manual;
- pilih peti kemas existing;
- import peti kemas;
- lihat kelengkapan data.

### Tahap 5 — Instruksi Pemeriksaan

- Instruksi Khusus
- Catatan Admin
- Referensi Pemeriksaan yang berlaku
- Lampiran Tambahan

Jangan menyediakan status workflow sebagai dropdown bebas.

### Tahap 6 — Lampiran

- surat permohonan;
- daftar peti kemas;
- dokumen kepemilikan/penguasaan bila diperlukan;
- lampiran teknis;
- lampiran lain.

### Tahap 7 — Ringkasan

Tampilkan seluruh data sebelum disimpan.

Tombol:

- Kembali
- Selanjutnya
- Simpan Draf
- Simpan dan Tambah Peti Kemas
- Ajukan
- Batal

---

# 22. DETAIL PERMOHONAN

Header:

- nomor permohonan;
- status;
- klien;
- pemohon;
- pemilik/pengguna peti kemas;
- lokasi;
- tanggal;
- PIC;
- action utama.

Tab:

- Ringkasan
- Peti Kemas
- Penugasan
- Pemeriksaan
- Review
- Dokumen
- Riwayat

## 22.1 Progress tracker

```text
Data Permohonan   ✓
Peti Kemas        ✓
Data Teknis       !
Penugasan         ○
Pemeriksaan       ○
Review            ○
Dokumen           ○
```

## 22.2 Kesiapan penugasan

- klien dipilih;
- pemohon terisi;
- lokasi dipilih;
- PIC tersedia;
- minimal satu peti kemas;
- nomor peti kemas valid;
- data teknis minimum lengkap;
- referensi pemeriksaan tersedia;
- checklist terverifikasi tersedia;
- Surveyor GIFT aktif tersedia.

Tombol Penugasan disabled bila belum siap.

---

# 23. PETI KEMAS

## 23.1 Daftar

Toolbar:

- pencarian nomor;
- filter klien;
- filter permohonan;
- filter jenis;
- filter kelengkapan;
- filter hasil;
- Tambah Peti Kemas;
- Import.

Kolom:

- Nomor Peti Kemas
- Klien
- Nomor Permohonan
- Pemilik/Pengguna
- Jenis
- Pabrik
- Nomor CSC
- Kelengkapan Teknis
- Tahap Proses
- Hasil
- Aksi

## 23.2 Form

Gunakan dedicated full page dengan tab.

### Identitas

- Klien — read-only berdasarkan konteks
- Nomor Peti Kemas
- Owner Code
- Serial Number
- Check Digit
- Status Check Digit
- Jenis Peti Kemas
- Model
- ISO Type Code
- Pabrik Pembuat
- Catatan

### CSC Safety Approval Plate

- Nomor CSC
- Nomor Persetujuan
- Tanggal Pembuatan
- Manufacturer Serial Number
- Foto Plate
- Status Keterbacaan
- Catatan

### Berat dan Kapasitas

- Maximum Gross Weight kg/lbs
- Tare Weight kg/lbs
- Payload Weight kg/lbs
- Cube Capacity m³/ft³

### Data Struktur

- Allowable Stacking Weight kg/lbs
- Racking Test Load kg/lbs
- End Wall Strength
- Side Wall Strength

### Pemeliharaan

- Skema Pemeliharaan
- Next Examination Date
- Interval
- Catatan

### Lampiran

- Foto Nomor Peti Kemas
- Foto CSC Plate
- Dokumen Teknis
- Bukti Pemilik/Penguasaan
- Lampiran Lain

### Ringkasan

Tampilkan:

- kelengkapan setiap tab;
- warning;
- status siap/belum siap ditugaskan;
- hubungan klien dan permohonan.

---

# 24. IMPORT PETI KEMAS

Wizard:

1. Pilih Klien.
2. Pilih Permohonan.
3. Upload File.
4. Mapping Kolom.
5. Preview.
6. Validasi.
7. Ringkasan Import.

Status baris:

- Valid
- Warning
- Error
- Duplikat

Aksi:

- Download Template
- Upload
- Kembali
- Validasi Ulang
- Import Data Valid
- Batalkan

Data import tidak boleh berpindah ke klien lain.

---

# 25. PENUGASAN SURVEYOR

## 25.1 Tab

- Belum Ditugaskan
- Aktif
- Selesai
- Dibatalkan

## 25.2 Form penugasan

### Informasi pekerjaan

- Nomor Permohonan
- Klien
- Pemohon
- Lokasi
- PIC
- Instruksi

### Pilih peti kemas

Tabel checklist dengan status kelengkapan.

### Pilih Surveyor GIFT

Card:

- Nama
- Kode
- Area Tugas
- Pekerjaan Aktif
- Status Ketersediaan

### Jadwal

- Tanggal Rencana
- Jatuh Tempo
- Instruksi
- Catatan Lokasi

### Ringkasan

- nama klien;
- jumlah peti kemas;
- nama Surveyor;
- tanggal;
- lokasi;
- PIC.

Surveyor GIFT menerima data yang sudah disiapkan Admin.

---

# 26. PEMERIKSAAN

Gunakan satu menu dengan tab:

- Semua
- Menunggu
- Berjalan
- Perlu Perbaikan
- Siap Pemeriksaan Ulang
- Layak
- Tidak Layak

Tabel:

- Nomor Pemeriksaan
- Klien
- Peti Kemas
- Permohonan
- Surveyor GIFT
- Progress
- Temuan
- Foto
- Status
- Pembaruan Terakhir
- Aksi

Detail:

- Ringkasan
- Checklist
- Pengujian
- Temuan
- Foto
- Riwayat

Progress:

- Checklist
- Pengujian
- Bukti Foto
- Temuan
- Kelengkapan

Workspace Surveyor belum dibuat pada tahap Admin ini.

---

# 27. REVIEW & KEPUTUSAN

Dedicated workspace.

Header:

- klien;
- peti kemas;
- permohonan;
- Surveyor;
- lokasi;
- tanggal;
- status.

Tab:

- Ringkasan
- Checklist
- Pengujian
- Temuan
- Foto
- Riwayat

Panel keputusan:

- Layak
- Perlu Perbaikan
- Pemeriksaan Ulang
- Tidak Layak
- Minta Revisi Surveyor

Field:

- Keputusan
- Alasan
- Catatan Reviewer
- Status Pembatasan
- Tindakan Berikutnya

Gunakan confirmation dialog.

Admin dapat melihat hasil, tetapi keputusan teknis mengikuti role.

---

# 28. TINDAK LANJUT PERBAIKAN

Tab:

- Menunggu Perbaikan
- Bukti Diterima
- Siap Pemeriksaan Ulang
- Selesai

Tabel:

- Nomor Tindak Lanjut
- Klien
- Peti Kemas
- Temuan
- Pihak Perbaikan
- Tanggal Mulai
- Tanggal Selesai
- Status
- Kesiapan Pemeriksaan Ulang
- Aksi

Form:

- peti kemas;
- temuan yang diperbaiki;
- rekomendasi;
- pihak perbaikan;
- jenis pihak;
- catatan klien;
- bukti;
- tanggal selesai;
- siap pemeriksaan ulang.

Aplikasi tidak mengelola:

- operasi workshop;
- spare part;
- biaya;
- invoice;
- penagihan.

---

# 29. DOKUMEN KELAIKAN

Tab:

- Semua
- Siap Disiapkan
- Draf
- Terbit
- Digantikan
- Dicabut

Tabel:

- Nomor Dokumen
- Jenis
- Klien
- Peti Kemas
- Tanggal
- Penandatangan
- Status
- Aksi

Detail:

- Metadata
- Data Teknis
- Hasil Review
- Penandatangan
- Preview HTML Terstruktur
- Riwayat Versi

Belum mengaktifkan:

- PDF final;
- QR;
- verifikasi publik;
- watermark;
- object storage final.

---

# 30. LAPORAN

Card laporan:

- Rekap Klien
- Rekap Permohonan
- Rekap Peti Kemas
- Rekap Pemeriksaan
- Rekap Hasil Kelaikan
- Rekap Lokasi Klien
- Rekap Surveyor GIFT
- Rekap Periode

Filter:

- Klien
- Periode
- Lokasi
- Surveyor GIFT
- Jenis Peti Kemas
- Tahap Proses
- Hasil
- Status Dokumen

Laporan periodik khusus ditempatkan sebagai fitur tahap lanjut setelah workflow utama stabil.

---

# 31. PENGATURAN INTERNAL GIFT

```text
Pengaturan Internal GIFT
├── Profil Badan Usaha
├── Surveyor GIFT
├── Supervisor/Reviewer
├── Pejabat Penandatangan
├── Pengaturan Penomoran
├── Manajemen User
├── Role & Permission
└── Audit Log
```

## 31.1 Profil Badan Usaha

Dedicated singleton page.

Section:

- Identitas
- Kontak
- Alamat
- Nomor Pajak
- Logo
- Tanda Tangan Default
- Preview Header Dokumen

Tidak ada tombol Tambah jika data sudah ada.

## 31.2 Surveyor GIFT

Menampilkan personel internal GIFT yang dapat ditugaskan.

Jangan dicampur dengan Personel/PIC Klien.

## 31.3 Supervisor/Reviewer

Daftar personel sesuai kewenangan review.

## 31.4 Pejabat Penandatangan

Daftar pejabat sesuai kewenangan.

## 31.5 Pengaturan lainnya

- penomoran;
- user;
- role;
- audit log.

---

# 32. ARSIP LAMA

Arsip bersifat read-only.

Isi:

- pemeriksaan lama;
- transaksi lama;
- referensi lama;
- mapping legacy;
- dokumen lama;
- data yang belum dimigrasikan.

Arsip tidak menjadi sumber utama workflow baru.

---

# 33. HUBUNGAN DENGAN WORKSPACE SURVEYOR

Saat workspace Surveyor dibuat pada tahap terpisah, alurnya:

```text
Buka Tugas
→ Sistem mengetahui Klien
→ Sistem memuat Master Data Klien
→ Pilih Peti Kemas
→ Isi Checklist
→ Pilih Area
→ Pilih Komponen Struktur
→ Pilih Kriteria Kerusakan/Ketidaksesuaian
→ Pilih Tingkat Keparahan
→ Tambah Foto
→ Tambah Catatan
→ Kirim untuk Review
```

Surveyor tidak mengetik ulang:

- nama klien;
- lokasi;
- PIC;
- jenis peti kemas;
- komponen;
- kriteria kerusakan;
- referensi pemeriksaan.

Semua pilihan difilter berdasarkan clientId dari tugas.

---

# 34. KOMPONEN UI WAJIB

- Breadcrumb
- PageHeader
- StatusBadge
- MetricCard
- ActionCard
- PageTabs
- Stepper
- ProgressTracker
- FormSection
- FormField
- SearchableSelect
- Drawer
- FormDialog
- ConfirmationDialog
- StickyActionBar
- EmptyState
- ErrorState
- Skeleton
- ActivityTimeline
- AttachmentUploader placeholder
- AttachmentPreview
- BulkSelectionTable
- FilterBar
- CompletionBadge
- UnsavedChangesGuard
- ToastFeedback
- ResponsiveTableCards

---

# 35. PERILAKU FORM

Setiap form harus memiliki:

- label jelas;
- help text;
- required marker;
- inline validation;
- error summary;
- disabled submit;
- loading state;
- success state;
- confirmation;
- cancel;
- unsaved changes warning;
- responsive layout;
- keyboard navigation;
- focus state;
- aria label;
- empty option yang jelas;
- context klien;
- clientId yang tidak dapat diubah dari form turunan.

---

# 36. RESPONSIVE

## Desktop

- sidebar penuh;
- tabel;
- form dua kolom;
- sticky summary/action;
- tab horizontal.

## Tablet

- sidebar dapat diciutkan;
- drawer form;
- table horizontal scroll;
- filter disederhanakan;
- tab scroll.

## Mobile

- sidebar drawer;
- card list;
- form satu kolom;
- sticky bottom action;
- tab horizontal scroll;
- nama klien tetap terlihat;
- tidak ada overflow;
- tombol tetap mudah digunakan.

---

# 37. ACCESSIBILITY

Pastikan:

- breadcrumb benar;
- active navigation benar;
- tab menggunakan link dan `aria-current`;
- form label terhubung;
- help/error menggunakan `aria-describedby`;
- dialog mendukung Escape;
- focus trap aman;
- focus kembali ke pemicu;
- status tidak hanya warna;
- context klien dapat dibaca screen reader;
- tombol icon memiliki aria-label;
- tabel memiliki header jelas;
- card mobile memiliki label field.

---

# 38. MOCK DATA DAN SERVICE

Selama backend belum dihubungkan:

1. gunakan mock data terstruktur;
2. jangan hardcode data langsung pada component;
3. simpan pada file mock;
4. buat interface/type siap API;
5. gunakan async read-only mock service;
6. sediakan loading, empty, error, dan success;
7. jangan membuat mutation backend;
8. jangan mengubah schema database;
9. sediakan minimal dua klien dengan data berbeda;
10. uji isolasi data.

## 38.1 Tipe frontend yang disarankan

- `FitnessClientSummary`
- `FitnessClientDetail`
- `FitnessClientMasterSummary`
- `FitnessClientLocation`
- `FitnessClientPersonnel`
- `FitnessClientContainerType`
- `FitnessClientInspectionReference`
- `FitnessLegacyMappingRecord`
- `FitnessApplicationSummary`
- `FitnessContainerSummary`

## 38.2 Service yang disarankan

- `getFitnessClients()`
- `getFitnessClientById(clientId)`
- `getFitnessClientMasterSummary(clientId)`
- `getFitnessClientLocations(clientId)`
- `getFitnessClientPersonnel(clientId)`
- `getFitnessClientContainerTypes(clientId)`
- `getFitnessClientInspectionReferences(clientId, section)`
- `getFitnessClientLegacyMappings(clientId, section)`

Seluruh getter data turunan wajib menerima clientId.

---

# 39. STRUKTUR FILE

```text
apps/web/
├── app/fitness/
│   ├── dashboard/
│   ├── clients/
│   ├── client-master-data/
│   ├── applications/
│   ├── containers/
│   ├── assignments/
│   ├── inspections/
│   ├── reviews/
│   ├── repair-followups/
│   ├── documents/
│   ├── reports/
│   └── legacy-archive/
│
├── components/fitness/
│   ├── dashboard/
│   ├── clients/
│   ├── client-master-data/
│   ├── applications/
│   ├── containers/
│   ├── assignments/
│   ├── inspections/
│   ├── reviews/
│   ├── documents/
│   ├── reports/
│   └── shared/
│
├── mocks/
├── types/
├── lib/
└── hooks/
```

Struktur dapat menyesuaikan pola repo saat ini tanpa refactor besar yang tidak perlu.

---

# 40. COMPATIBILITY ROUTE

## 40.1 Master Data lama

Route lama:

```text
/fitness/master-data
```

Diarahkan ke:

```text
/fitness/client-master-data
```

atau menampilkan compatibility notice:

> Pilih klien terlebih dahulu untuk mengelola Master Data Klien.

## 40.2 Route item lama

Route item lama:

- Location;
- Surveyor;
- Container Type;
- Survey Type;
- referensi legacy.

Dipetakan sebagai berikut:

```text
Location
→ Master Data Klien / Lokasi

Surveyor
→ Master Data Klien / Personel/PIC Klien
  atau Pengaturan Internal GIFT / Surveyor GIFT berdasarkan sumber data

Container Type
→ Master Data Klien / Jenis Peti Kemas

Survey Type
→ tidak diaktifkan sebagai master bebas;
  tampilkan compatibility notice dan arahkan ke referensi/instruksi pemeriksaan

Legacy Component
→ Mapping Legacy / Component

Legacy Damage
→ Mapping Legacy / Damage

Legacy Location
→ Mapping Legacy / Location

Legacy Material
→ Mapping Legacy / Material
```

Jangan menghapus data atau route secara destruktif.

---

# 41. ROLE DAN KEWENANGAN

## Admin

- mengelola klien;
- mengelola Master Data Klien;
- membuat permohonan;
- mengelola peti kemas;
- memeriksa kesiapan;
- menyiapkan penugasan;
- memantau proses;
- menyiapkan metadata dokumen.

## Surveyor GIFT

- menerima tugas;
- melihat data klien;
- memilih referensi;
- mengisi hasil;
- mengunggah bukti;
- mengirim untuk review.

Workspace Surveyor belum dibangun pada tahap ini.

## Supervisor/Reviewer

- review;
- meminta revisi;
- memberikan keputusan;
- melihat riwayat.

## Pejabat Penandatangan

- melihat dokumen yang siap;
- menjalankan proses sesuai kewenangan.

## Management

- read-only;
- melihat dashboard dan laporan.

---

# 42. TAHAP IMPLEMENTASI TERBARU

## UI-A — Information Architecture dan Shell

- branding GIFT;
- sidebar;
- route;
- breadcrumb;
- tabs;
- page header;
- placeholder;
- compatibility dasar.

## UI-A.1 — Correction

- collapsed sidebar;
- active route;
- CTA;
- state;
- accessibility;
- validasi.

## UI-B — Design System

- card;
- badge;
- stepper;
- drawer;
- confirmation;
- filter;
- table/card;
- sticky action;
- form pattern.

## UI-B.1 — Interaction Hardening

- SearchableSelect interaktif;
- FilterBar interaktif;
- StickyActionBar;
- bulk selection;
- dialog behavior;
- unsaved changes;
- accessibility.

## UI-B.2 — Klien & Master Data Klien

- sidebar terbaru;
- Daftar Klien;
- pemilihan klien;
- Master Data Klien;
- isolasi data;
- compatibility;
- contract frontend untuk UI-C.

## UI-C — Dashboard dan Permohonan

- Dashboard Admin;
- Daftar Permohonan;
- Buat Permohonan;
- Detail Permohonan;
- pemilihan data berdasarkan clientId;
- readiness checklist.

## UI-D — Peti Kemas

- daftar;
- tambah/edit;
- import;
- validasi teknis;
- relasi dengan klien dan permohonan.

## UI-E — Penugasan dan Monitoring

- kesiapan;
- pilih Surveyor GIFT;
- monitoring;
- detail progres.

## UI-F — Review, Perbaikan, Dokumen, dan Laporan

- review;
- keputusan;
- tindak lanjut perbaikan;
- pemeriksaan ulang;
- metadata dokumen;
- laporan;
- final responsive polish.

---

# 43. BATAS IMPLEMENTASI SAAT INI

Fokus:

- struktur menu;
- Klien;
- Master Data Klien;
- tab dan subtab;
- mock data;
- isolasi data;
- compatibility;
- frontend type;
- mock service.

Belum dikerjakan:

- database;
- migration;
- patch SQL;
- endpoint backend;
- workflow transaksi penuh;
- workspace Surveyor;
- checklist seed teknis;
- PDF final;
- QR;
- verifikasi publik;
- billing;
- penimbangan;
- workshop;
- Type Design aktif.

---

# 44. ACCEPTANCE CRITERIA UI-B.2

UI-B.2 diterima bila:

1. Sidebar Admin sederhana.
2. Menu Klien & Master Data tersedia.
3. Daftar Klien dapat dibuka.
4. Admin harus memilih klien sebelum membuka Master Data.
5. clientId dibawa route/state yang jelas.
6. Context klien selalu terlihat.
7. Tab Ringkasan tersedia.
8. Tab Lokasi tersedia.
9. Tab Personel/PIC Klien tersedia.
10. Tab Jenis Peti Kemas tersedia.
11. Tab Referensi Pemeriksaan tersedia.
12. Mapping Legacy read-only tersedia.
13. Referensi Repair legacy tidak menjadi tab aktif.
14. Surveyor GIFT tidak tercampur dengan personel klien.
15. Jenis Pemeriksaan tidak menjadi master workflow bebas.
16. Data minimal dua klien terisolasi.
17. Form turunan mengunci context klien.
18. Service mock siap dipakai UI-C.
19. Route lama tetap memiliki compatibility.
20. Tidak ada perubahan backend/database.
21. Branding GIFT benar.
22. Istilah Kelaikan konsisten.
23. Typecheck lulus.
24. Build lulus.
25. `git diff --check` bersih.
26. Dokumentasi implementasi lengkap.

---

# 45. VALIDASI WAJIB

Jalankan:

```bash
npm run typecheck --workspace apps/web
npm run build --workspace apps/web
git diff --check
```

Smoke check:

- Dashboard
- Daftar Klien
- Pemilihan Klien
- Master Data Klien A
- Master Data Klien B
- seluruh tab utama
- seluruh subtab Referensi Pemeriksaan
- Mapping Legacy
- Permohonan
- Peti Kemas
- Penugasan
- Pemeriksaan
- Review
- Tindak Lanjut Perbaikan
- Dokumen
- Laporan
- Pengaturan
- Arsip Lama
- compatibility route lama

Periksa:

- tidak ada hydration error;
- active navigation benar;
- tab tetap aktif setelah refresh;
- data Klien A tidak muncul pada Klien B;
- mobile responsive;
- form memiliki state;
- tidak ada tombol palsu tanpa status;
- tidak ada perubahan backend/database;
- branding benar;
- istilah wajib konsisten.

Jika file generated oleh build berubah tanpa kebutuhan implementasi, restore.

---

# 46. OUTPUT CODEX PER TAHAP

Setiap tahap melaporkan:

1. commit awal;
2. tahap yang dikerjakan;
3. file dibuat;
4. file diubah;
5. route baru;
6. perubahan navigation;
7. halaman baru;
8. komponen baru;
9. perubahan form;
10. mock data;
11. service;
12. isolasi data;
13. compatibility;
14. responsive;
15. accessibility;
16. hasil typecheck;
17. hasil build;
18. hasil git diff;
19. hasil smoke check;
20. hal belum dikerjakan;
21. risiko;
22. rekomendasi tahap berikutnya.

Berhenti setelah tahap yang diminta.

Jangan commit dan jangan push kecuali diminta secara eksplisit.

---

# 47. STRUKTUR FINAL

```text
GIFT sebagai penyedia jasa inspeksi
│
├── Dashboard
│
├── Klien & Master Data
│   ├── Daftar Klien
│   └── Master Data Klien
│       ├── Ringkasan
│       ├── Lokasi
│       ├── Personel/PIC Klien
│       ├── Jenis Peti Kemas
│       ├── Referensi Pemeriksaan
│       │   ├── Area Pemeriksaan
│       │   ├── Komponen Struktur Peti Kemas
│       │   ├── Kriteria Kerusakan/Ketidaksesuaian
│       │   ├── Tingkat Keparahan
│       │   ├── Parameter Pengujian
│       │   ├── Kategori Bukti Foto
│       │   └── Rekomendasi Pemeriksaan
│       └── Mapping Legacy
│           ├── Location
│           ├── Component
│           ├── Damage
│           └── Material
│
├── Permohonan
├── Peti Kemas
├── Penugasan Surveyor GIFT
├── Pemeriksaan
├── Review & Keputusan
├── Tindak Lanjut Perbaikan
├── Pemeriksaan Ulang
├── Dokumen Kelaikan
├── Laporan
├── Pengaturan Internal GIFT
└── Arsip Lama
```

Struktur ini memastikan:

- GIFT tetap berperan sebagai penyedia jasa;
- data klien terpisah;
- sidebar tidak terlalu panjang;
- Admin menyiapkan data satu kali;
- Surveyor nantinya tinggal memilih;
- input berulang berkurang;
- referensi aktif dan legacy tidak tercampur;
- proses inspeksi lebih konsisten;
- risiko data antarklien tercampur dapat diminimalkan.
