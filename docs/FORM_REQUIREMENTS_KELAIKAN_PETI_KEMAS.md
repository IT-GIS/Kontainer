# Form Requirements Kelaikan Peti Kemas

Dokumen ini menyatukan kebutuhan form Admin dan kebutuhan Surveyor lapangan. Tahap implementasi saat ini hanya placeholder dan dokumentasi; belum ada submit aktif atau API mutation.

## 1. Form Admin: Master Data Kelaikan

Master data Admin harus mengurangi input bebas Surveyor. Data yang wajib tersedia untuk dipilih Surveyor:

- Area Pemeriksaan Peti Kemas
- Komponen Struktur Peti Kemas
- Kriteria Kerusakan / Ketidaksesuaian
- Tingkat Temuan / Severity
- Parameter Pengujian Kelaikan
- Template Checklist Kelaikan
- Kategori Foto Evidence
- Rekomendasi Hasil Pemeriksaan

Detail field tiap master ada di `docs/ADMIN_FORMS_KELAIKAN_PETI_KEMAS.md`.

## 2. Form Permohonan Kelaikan

Field:

```text
application_no
application_date
owner_id
manufacturer_id
inspection_location_id
approval_category_id
client_request_letter_no
client_request_letter_date
pic_name
pic_phone
pic_email
instruction_notes
status
```

Validasi:

- Tanggal permohonan wajib.
- Pemilik wajib.
- Lokasi pemeriksaan wajib.
- Kategori persetujuan wajib.
- Pabrik pembuat disarankan wajib untuk peti kemas baru.
- Email PIC harus valid jika diisi.

Dipakai Surveyor untuk memahami pemilik, lokasi, kategori proses, dan instruksi pemeriksaan.

## 3. Form Data Peti Kemas

Field:

```text
container_no
owner_code
serial_number
check_digit
check_digit_status
check_digit_override_reason
container_type_id
iso_type_code
csc_no
manufacture_date
manufacturer_serial_no
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
end_wall_strength
side_wall_strength
next_examination_date
maintenance_scheme_id
notes
status
```

Validasi:

- Nomor peti kemas wajib.
- Check digit harus dicek atau diberi alasan override.
- Nomor CSC wajib sebelum dokumen persetujuan diterbitkan.
- Field teknis wajib lengkap sebelum dokumen diterbitkan.
- Berat dan kapasitas numeric.

Dipakai Surveyor sebagai pembanding saat memeriksa identitas, CSC plate, dan data teknis peti kemas.

## 4. Form Import Data Peti Kemas

Field:

```text
application_id
file
column_mapping
preview_rows
validation_result
import_status
```

Kolom minimal import:

```text
container_no
container_type
iso_type_code
csc_no
manufacture_date
manufacturer_serial_no
type_model
max_gross_weight_kg
tare_weight_kg
payload_weight_kg
```

Validasi:

- File wajib Excel/CSV.
- Mapping kolom wajib dikonfirmasi.
- Nomor peti kemas wajib unik dalam satu permohonan.
- Status import: processed, partial_failed, failed.

## 5. Form Assignment Surveyor

Field:

```text
application_id
container_ids
surveyor_id
start_date
due_date
inspection_instruction
location_notes
assignment_status
```

Validasi:

- Surveyor wajib aktif.
- Minimal satu peti kemas dipilih.
- Due date tidak boleh sebelum start date.

Dipakai Surveyor untuk melihat pekerjaan yang ditugaskan, lokasi, daftar peti kemas, dan instruksi pemeriksaan.

## 6. Form Surveyor: Pemeriksaan Lapangan

Tab yang akan dibutuhkan pada tahap berikutnya:

```text
General Info
Checklist Kelaikan
Pengujian Kelaikan
Temuan Struktur
Foto Evidence
Rekomendasi Hasil
Preview
Submit
```

### General Info

```text
inspection_date_time
inspection_location_id
weather
gps_latitude
gps_longitude
general_condition
general_remark
```

### Checklist Kelaikan

Sumber item: `fitness_checklist_templates` dan `fitness_checklist_template_items`.

Response type:

```text
ok_not_ok
yes_no
text
number
date
photo_required
not_applicable
```

### Pengujian Kelaikan

Sumber parameter: `inspection_test_parameters`.

Field hasil:

```text
test_parameter_id
result_value
result_unit
result_status
notes
attachment_required
photo_category_id
```

### Temuan Struktur

Sumber pilihan: area pemeriksaan, komponen struktur, kriteria kerusakan, dan severity.

Field:

```text
inspection_area_id
structural_component_id
damage_criteria_id
severity_id
affects_fitness
requires_repair
finding_notes
recommendation_id
```

### Foto Evidence

Sumber kategori: `evidence_photo_categories`.

Field:

```text
photo_category_id
related_finding_id
caption
file
captured_at
gps_latitude
gps_longitude
```

### Rekomendasi Hasil

Sumber pilihan: `inspection_recommendations`.

Data awal rekomendasi:

- fit: Layak
- need_repair: Perlu Perbaikan
- unfit: Tidak Layak
- need_reinspection: Perlu Re-Inspection
- suspend_use: Dilarang Digunakan Sementara

## 7. Form Review & Keputusan Kelaikan

Field:

```text
inspection_id
checklist_summary
test_summary
finding_summary
photo_summary
surveyor_recommendation
reviewer_decision
reviewer_notes
final_fitness_result
restriction_status
```

Pilihan keputusan reviewer:

```text
approve_fit
need_repair
approve_unfit
suspend_use
request_revision
```

Validasi:

- Reviewer wajib melihat checklist, pengujian, temuan, dan foto.
- Keputusan final belum diaktifkan sebagai mutation pada tahap placeholder.

## 8. Form Dokumen Kelaikan

Field metadata:

```text
document_no
document_type
application_no
container_no
owner_id
manufacturer_id
location_id
issue_date
issue_city
authorized_signer_id
document_status
```

Status dokumen:

```text
draft
issued
superseded
revoked
```

Catatan: PDF final, QR final, snapshot dokumen, dan watermark belum dikerjakan pada tahap ini.
