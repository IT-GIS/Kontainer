# Field Dokumen Persetujuan Kelaikan Peti Kemas

## Tujuan

Dokumen approval harus mengikuti informasi penting pada format lampiran Permenhub 25/2022, khususnya:

- Contoh 6: Persetujuan Kelaikan Peti Kemas Baru Type Design.
- Contoh 8: Persetujuan Kelaikan Peti Kemas Baru Individual.
- Contoh 9: Persetujuan Peti Kemas Lama yang telah digunakan.
- Contoh 10: Persetujuan Peti Kemas yang sudah diproduksi dan belum mendapat persetujuan.
- Contoh 23: Surat Pembebasan setelah diperbaiki dan memenuhi kelaikan.

## Field Umum Dokumen

```text
document_no
issued_city
issued_date
letter_classification
attachment
subject
recipient_name
recipient_address
reference_request_letter_no
reference_request_letter_date
regulation_reference
signing_institution
signer_name
signer_position
signer_nip
copy_to
qr_token
```

## Field Pemilik

```text
owner_name
owner_address
owner_pic_name
owner_pic_phone
owner_pic_email
```

## Field Pabrik Pembuat

```text
manufacturer_name
manufacturer_address
manufacturer_country
manufacturer_pic_name
```

## Spesifikasi Teknis Peti Kemas

Field ini wajib tersedia untuk dokumen persetujuan:

```text
container_number
csc_number
manufacture_date
manufacturer_serial_number
type_model
max_gross_weight_kg
max_gross_weight_lbs
tare_weight_kg
tare_weight_lbs
payload_weight_kg
payload_weight_lbs
cube_capacity_m3
cube_capacity_ft3
allowable_stacking_weight_kg
allowable_stacking_weight_lbs
racking_test_load_value_kg
racking_test_load_value_lbs
```

## Field Tambahan CSC Safety Approval Plate

```text
country_reference
approval_reference_no
approval_year
date_manufactured
identification_number
maximum_operating_gross_mass_kg
maximum_operating_gross_mass_lbs
allowable_stacking_load_for_1_8g_kg
allowable_stacking_load_for_1_8g_lbs
transverse_racking_test_force_newtons
end_wall_strength
side_wall_strength
first_maintenance_date
next_examination_date
one_door_off_stacking_load
one_door_off_racking_force
```

## Dokumen: Persetujuan Peti Kemas Baru Individual

Output harus mencakup:

1. Dasar permohonan.
2. Pernyataan bahwa hasil penelitian, pemeriksaan, dan pengujian memenuhi persyaratan.
3. Data pemilik.
4. Data pabrik pembuat.
5. Spesifikasi teknis.
6. Kewajiban menyediakan dan melekatkan Pelat Persetujuan Kelaikan.
7. Kewajiban pemeliharaan.
8. Tanda tangan pejabat berwenang.

## Dokumen: Persetujuan Peti Kemas Lama

Output harus mencakup:

1. Dasar permohonan.
2. Evaluasi data dan informasi peti kemas lama.
3. Data pemilik.
4. Spesifikasi teknis.
5. Kewajiban melekatkan Pelat Persetujuan Kelaikan.
6. Kewajiban pemeliharaan.
7. Tanda tangan pejabat berwenang.

## Dokumen: Surat Pembebasan Setelah Perbaikan

Output harus mencakup:

```text
release_letter_no
release_date
owner_or_master_name
inspection_location
inspector_name
container_owner
csc_number
container_number
iso_code
statement_fit_after_repair
recommendation_remove_prohibition_mark
signer_name
signer_position
```

## Aturan Generate Dokumen

- Dokumen approval tidak boleh memuat data VGM.
- Dokumen harus menyimpan snapshot JSON agar histori tidak berubah jika master data berubah.
- Dokumen PDF harus memiliki QR validation.
- Nomor dokumen mengikuti numbering setting.
- Revisi dokumen harus tersimpan sebagai versi baru.
