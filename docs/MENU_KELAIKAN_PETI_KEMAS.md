# Menu Admin Kelaikan Peti Kemas

## Tujuan Menu

Menu Admin harus mencerminkan alur kelaikan peti kemas, bukan alur general container survey.

## Menu Admin Final

```text
Dashboard

Master Data
- Pemilik Peti Kemas
- Pabrik Pembuat Peti Kemas
- Lokasi Pemeriksaan
- Surveyor / Pemeriksa
- Jenis / Model Peti Kemas
- Komponen Struktur Peti Kemas
- Kriteria Kerusakan Struktur
- Parameter Pengujian Kelaikan
- Template Checklist Kelaikan
- Pejabat Penandatangan
- Profil Badan Usaha

Permohonan Kelaikan
- Daftar Permohonan
- Buat Permohonan
- Input Data Peti Kemas
- Import Data Peti Kemas
- Assign Surveyor

Pemeriksaan & Pengujian
- Monitoring Pemeriksaan
- Pemeriksaan Berjalan
- Perlu Perbaikan
- Siap Re-Inspection
- Layak
- Tidak Layak

Review & Persetujuan
- Pending Review
- Review History
- Persetujuan Kelaikan
- Pembebasan Setelah Perbaikan

Dokumen Kelaikan
- Surat Persetujuan Kelaikan
- CSC Safety Approval Plate Data
- Surat Pembebasan
- QR Validation

Laporan
- Laporan Kegiatan 6 Bulanan
- Peti Kemas Layak
- Peti Kemas Tidak Layak
- Peti Kemas Perlu Perbaikan
- Persetujuan Dicabut / Dilarang Digunakan
- Rekap Pemilik Peti Kemas
- Rekap Pabrik Pembuat

Setting
- Company Profile
- Numbering Setting
- User Management
- Role & Permission
- Audit Log
```

## Menu yang Harus Dihapus dari Versi Lama

```text
- Survey Type
- CEDEX Repair
- Responsibility Code
- Ready to Invoice
- Price List
- Invoice List
- Payment
- Outstanding
- VGM module jika ada
```

## Menu yang Harus Diubah Label

| Menu Lama | Menu Baru |
|---|---|
| Customer | Pemilik Peti Kemas |
| Job Order | Permohonan Kelaikan |
| Job List | Daftar Permohonan |
| Create Job | Buat Permohonan |
| Add Container | Input Data Peti Kemas |
| Assign Surveyor | Assign Surveyor / Pemeriksa |
| Monitoring Survey | Monitoring Pemeriksaan |
| Review | Review & Persetujuan |
| Report | Dokumen Kelaikan |
| Report Archive | Surat Persetujuan Kelaikan |
| QR Validation | Validasi Dokumen Kelaikan |

## Catatan Role

### Admin

Admin boleh:

- membuat permohonan,
- mengelola master data,
- input/import data peti kemas,
- assign surveyor,
- monitoring status,
- melihat dokumen.

Admin tidak otomatis menjadi approver final kecuali kebijakan internal mengizinkan.

### Surveyor / Pemeriksa

Surveyor melakukan:

- pemeriksaan,
- pengujian,
- input checklist,
- input temuan,
- upload foto,
- submit hasil pemeriksaan.

### Supervisor / Reviewer

Supervisor melakukan:

- review hasil pemeriksaan,
- meminta perbaikan,
- menyetujui kelaikan,
- menyatakan tidak layak,
- menyetujui pembebasan setelah re-inspection.

### Management

Management hanya read-only:

- dashboard,
- laporan,
- dokumen.

## Prioritas Implementasi Menu

Tahap 1:

- Ganti label menu utama.
- Hapus menu di luar scope.
- Tambah menu Perlu Perbaikan dan Siap Re-Inspection.
- Tambah menu Dokumen Kelaikan.

Tahap 2:

- Implement persetujuan kelaikan.
- Implement surat pembebasan.
- Implement laporan kegiatan 6 bulanan.

Tahap 3:

- QR Validation final.
- Dashboard statistik kelaikan.
