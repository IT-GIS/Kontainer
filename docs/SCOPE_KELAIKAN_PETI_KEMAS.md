# Scope Aplikasi Kelaikan Peti Kemas

## Ringkasan

Aplikasi ini difokuskan untuk mendukung proses **pemeriksaan, pengujian, dan persetujuan kelaikan peti kemas**. Aplikasi tidak mencakup proses VGM, penimbangan VGM, atau sertifikasi VGM.

## Dasar Lingkup

Permenhub 25/2022 mencakup dua topik besar:

1. Kelaikan Peti Kemas.
2. Berat Kotor Peti Kemas Terverifikasi / VGM.

Dalam aplikasi ini, hanya topik **Kelaikan Peti Kemas** yang digunakan.

## In Scope

### 1. Kelaikan Peti Kemas Baru

Aplikasi harus dapat mencatat dan memproses:

- Peti Kemas Baru Type Design.
- Peti Kemas Baru Individual.
- Pemeriksaan dan pengujian sesuai parameter teknis.
- Data pabrik pembuat.
- Data pemilik peti kemas.
- Data spesifikasi teknis.
- Persetujuan tertulis.
- Data CSC Safety Approval Plate.

### 2. Kelaikan Peti Kemas Lama

Aplikasi harus dapat mencatat dan memproses:

- Peti Kemas Lama yang telah digunakan untuk mengangkut muatan dan belum mendapat persetujuan.
- Peti Kemas Lama yang sudah diproduksi tetapi belum mendapat persetujuan saat produksi.
- Evaluasi data dan informasi peti kemas.
- Pemeriksaan dan pengujian jika data tidak mencukupi.
- Status perbaikan bila ditemukan kerusakan.
- Re-inspection setelah perbaikan.
- Persetujuan kelaikan atau status tidak layak.

### 3. Pemeriksaan dan Pengujian

Aplikasi harus mendukung pencatatan hasil pemeriksaan dan pengujian terhadap kemampuan:

- Lifting / pengangkatan.
- Stacking / penumpukan.
- Concentrated loads / beban terkonsentrasi.
- Transverse racking / kekakuan melintang.
- Longitudinal restraint / pengekangan memanjang.
- Side walls / dinding samping.
- End walls / dinding ujung.
- One door off operation jika relevan.
- NDT / kekedapan las bila diperlukan untuk peti kemas lama.

### 4. Kerusakan dan Perbaikan

Aplikasi hanya mencatat temuan kerusakan dan status tindak lanjut, bukan menentukan metode repair detail milik bengkel/client.

Status yang perlu dicatat:

- Ditemukan kerusakan.
- Perlu perbaikan oleh pemilik/client.
- Dalam perbaikan.
- Siap re-inspection.
- Setelah re-inspection masih rusak.
- Setelah re-inspection memenuhi kelaikan.

### 5. Dokumen Kelaikan

Aplikasi harus mendukung dokumen:

- Surat Persetujuan Kelaikan Peti Kemas Baru Type Design.
- Surat Persetujuan Kelaikan Peti Kemas Baru Individual.
- Surat Persetujuan Peti Kemas Lama yang telah digunakan.
- Surat Persetujuan Peti Kemas yang sudah diproduksi dan belum mendapat persetujuan.
- Surat Pembebasan Peti Kemas yang telah diperbaiki dan memenuhi kelaikan.
- Data CSC Safety Approval Plate.
- QR Validation.

## Out of Scope

Aplikasi tidak mengelola:

- Verified Gross Mass / VGM.
- Metode penentuan VGM.
- Persetujuan peralatan VGM.
- Sertifikat VGM.
- Penimbangan peti kemas.
- Data shipper untuk VGM.
- Tarif VGM.
- Billing repair.
- CEDEX repair code sebagai keputusan perbaikan.
- Operasional bengkel repair.

## Perubahan Konsep dari Aplikasi Lama

| Versi Lama | Versi Kelaikan Peti Kemas |
|---|---|
| Container Survey Management | Sistem Kelaikan Peti Kemas |
| Survey Type banyak jenis | Satu lingkup: Kelaikan Peti Kemas |
| CEDEX Repair | Tidak masuk scope utama |
| Responsibility Code | Diganti menjadi pihak tindak lanjut bila perlu |
| Job Order | Permohonan Kelaikan |
| Report Survey | Dokumen Persetujuan Kelaikan |
| Damage Survey | Temuan Kerusakan Struktur |
| Ready to Invoice | Tidak prioritas pada modul kelaikan |
