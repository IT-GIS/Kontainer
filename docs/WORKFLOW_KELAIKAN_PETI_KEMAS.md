# Workflow Kelaikan Peti Kemas

## Prinsip Workflow

Sistem Kelaikan Peti Kemas berfokus pada kelaikan peti kemas. VGM, penimbangan, sertifikat VGM, billing repair, finance utama, dan operasional bengkel repair bukan scope workflow ini.

## Alur Admin ke Surveyor

```text
Admin menyiapkan Master Data Kelaikan
  -> Admin membuat Permohonan Kelaikan
  -> Admin input/import Data Peti Kemas
  -> Admin assign Surveyor / Pemeriksa
  -> Surveyor melakukan pemeriksaan lapangan
  -> Surveyor memilih checklist, area, komponen, kriteria, severity, parameter uji, foto, dan rekomendasi dari master data
  -> Surveyor submit hasil pemeriksaan
  -> Supervisor / Reviewer melakukan review
  -> Keputusan: Layak, Perlu Perbaikan, Tidak Layak, Revisi, atau Dilarang Digunakan Sementara
  -> Dokumen Kelaikan disiapkan jika memenuhi syarat
```

## Peran Master Data untuk Surveyor

Admin wajib menyiapkan master berikut agar input Surveyor konsisten:

- Area Pemeriksaan Peti Kemas
- Komponen Struktur Peti Kemas
- Kriteria Kerusakan / Ketidaksesuaian
- Tingkat Temuan / Severity
- Parameter Pengujian Kelaikan
- Template Checklist Kelaikan
- Kategori Foto Evidence
- Rekomendasi Hasil Pemeriksaan

## Alur Permohonan Kelaikan

1. Admin memilih Pemilik Peti Kemas.
2. Admin memilih Pabrik Pembuat jika relevan.
3. Admin memilih Lokasi Pemeriksaan.
4. Admin memilih Kategori Persetujuan Kelaikan aktif MVP.
5. Admin mengisi surat permohonan client, PIC, dan instruksi.
6. Admin menyimpan draft atau submitted pada tahap lanjutan.

## Alur Data Peti Kemas

1. Admin input atau import daftar peti kemas.
2. Admin melengkapi identitas container, check digit, ISO type code, CSC number, dan data teknis.
3. Admin memilih jenis/model peti kemas dan skema pemeliharaan.
4. Data teknis menjadi pembanding bagi Surveyor saat memeriksa lapangan.

## Alur Pemeriksaan Lapangan

1. Surveyor membuka assignment.
2. Surveyor melihat pemilik, lokasi, kategori persetujuan, dan instruksi.
3. Surveyor mengisi general info.
4. Surveyor mengisi checklist dari template aktif.
5. Surveyor mengisi hasil pengujian dari parameter yang berlaku.
6. Surveyor mencatat temuan dengan memilih area, komponen, kriteria, dan severity.
7. Surveyor upload foto sesuai kategori evidence.
8. Surveyor memilih rekomendasi hasil pemeriksaan.
9. Surveyor submit untuk review.

## Alur Perbaikan dan Re-Inspection

```text
Temuan kerusakan atau ketidaksesuaian
  -> Reviewer memberi keputusan Perlu Perbaikan / Dilarang Digunakan Sementara
  -> Pemilik/client melakukan perbaikan di luar sistem
  -> Admin menandai siap re-inspection pada tahap workflow berikutnya
  -> Surveyor melakukan re-inspection
  -> Reviewer menyatakan layak, masih perlu perbaikan, atau tidak layak
  -> Jika layak setelah perbaikan, surat pembebasan dapat disiapkan
```

## Alur Dokumen

1. Dokumen memakai data permohonan, data peti kemas, hasil pemeriksaan, hasil review, pejabat penandatangan, dan profil badan usaha.
2. Tahap ini hanya placeholder metadata dokumen.
3. PDF final, QR final, snapshot dokumen, MinIO, dan watermark belum dikerjakan.

## Route Placeholder Tahap Ini

- `/fitness/dashboard`
- `/fitness/master-data`
- `/fitness/applications`
- `/fitness/containers`
- `/fitness/assignments`
- `/fitness/inspections`
- `/fitness/reviews`
- `/fitness/documents`
- `/fitness/reports`
- `/fitness/legacy-archive`

## Aturan Penting

1. Gunakan istilah Kelaikan secara konsisten.
2. Permenhub 25/2022 hanya ditulis sebagai acuan regulasi dalam Markdown.
3. Jangan gunakan singkatan regulasi sebagai identifier.
4. CEDEX repair tidak menjadi dasar keputusan utama.
5. Repair dicatat sebagai tindak lanjut pemilik/client, bukan operasional bengkel internal.
6. Data legacy tidak dihapus dan tidak menjadi workflow aktif.
