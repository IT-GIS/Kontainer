# Workflow Kelaikan Peti Kemas

## Alur Utama

```text
Admin membuat Permohonan Kelaikan
â†“
Admin input data Pemilik / Pabrik / Lokasi
â†“
Admin input atau import data Peti Kemas
â†“
Admin assign Surveyor
â†“
Surveyor melakukan Pemeriksaan dan Pengujian
â†“
Surveyor input checklist, hasil uji, temuan, foto
â†“
Surveyor submit hasil pemeriksaan
â†“
Supervisor review
â†“
Keputusan:
  - Layak
  - Perlu Perbaikan
  - Tidak Layak
â†“
Jika perlu perbaikan:
  - Pemilik/client melakukan perbaikan
  - Admin tandai Ready for Re-Inspection
  - Surveyor cek ulang
â†“
Jika layak:
  - Persetujuan Kelaikan diterbitkan
  - Data CSC Safety Approval Plate dicatat
  - QR dokumen dibuat
```

## Alur Peti Kemas Baru

### A. Peti Kemas Baru Type Design

1. Pemohon mengajukan permohonan.
2. Admin mencatat data pabrik pembuat dan jenis desain.
3. Surveyor melakukan pengawasan/pemeriksaan/pengujian.
4. Hasil dilengkapi gambar dan spesifikasi desain.
5. Supervisor melakukan review.
6. Jika memenuhi, surat persetujuan type design diterbitkan.
7. Pelat persetujuan kelaikan dilekatkan.

### B. Peti Kemas Baru Individual

1. Pemohon mengajukan permohonan.
2. Admin mencatat data pemilik, pabrik, dan spesifikasi teknis container.
3. Surveyor melakukan pemeriksaan dan pengujian.
4. Supervisor review.
5. Jika memenuhi, surat persetujuan kelaikan peti kemas baru individual diterbitkan.
6. Pelat persetujuan kelaikan dilekatkan.

## Alur Peti Kemas Lama

### A. Lama sudah digunakan dan belum mendapat persetujuan

1. Pemilik mengajukan permohonan beserta data dan informasi peti kemas.
2. Admin input data teknis.
3. Surveyor mengevaluasi data dan/atau melakukan pemeriksaan/pengujian.
4. Jika data dan hasil pemeriksaan memenuhi, persetujuan diterbitkan.
5. Jika tidak memenuhi, status menjadi perlu perbaikan atau tidak layak.

### B. Lama sudah diproduksi tetapi belum mendapat persetujuan saat produksi

1. Pemilik mengajukan permohonan.
2. Admin input data teknis.
3. Surveyor melakukan evaluasi data dan pemeriksaan/pengujian bila diperlukan.
4. Supervisor review.
5. Jika memenuhi, surat persetujuan diterbitkan.

## Alur Perbaikan dan Re-Inspection

```text
Temuan kerusakan
â†“
Status: Perlu Perbaikan
â†“
Pemilik/client melakukan perbaikan
â†“
Admin upload/isi bukti perbaikan jika ada
â†“
Status: Siap Re-Inspection
â†“
Surveyor melakukan pemeriksaan ulang
â†“
Hasil:
  - Masih Rusak
  - Layak Setelah Perbaikan
  - Tidak Layak
â†“
Jika layak setelah perbaikan:
  - Surat Pembebasan / Release Letter diterbitkan
```

## Status Alur

Lihat `STATUS_LIFECYCLE_KELAIKAN_PETI_KEMAS.md` untuk detail status.

## Aturan Penting

1. VGM tidak boleh muncul di form atau workflow.
2. CEDEX repair tidak boleh menjadi dasar keputusan.
3. Tindakan repair dicatat sebagai tindak lanjut oleh pemilik/client.
4. Hasil akhir harus berupa status kelaikan, bukan status survey umum.
5. Dokumen akhir harus sesuai kategori permohonan.
