# Form Requirements Kelaikan Peti Kemas

## 1. Form Permohonan Kelaikan

Field:

```text
application_date
application_category
owner_id
manufacturer_id
location_id
request_letter_no
request_letter_date
reference_no
pic_name
pic_phone
pic_email
notes
```

Validasi:

- `application_date` wajib.
- `application_category` wajib.
- `owner_id` wajib.
- `location_id` wajib.
- `manufacturer_id` wajib untuk peti kemas baru.
- `pic_email` valid jika diisi.

## 2. Form Data Peti Kemas

Field:

```text
container_number
csc_number
iso_code
manufacture_date
manufacturer_serial_number
type_model
container_category
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
one_door_off_approved
next_examination_date
maintenance_scheme
remark
```

Validasi:

- `container_number` wajib.
- `container_category` wajib: `new` atau `existing`.
- Berat dan kapasitas numeric.
- `manufacture_date` tidak boleh tanggal masa depan.
- `csc_number` wajib jika sudah ada CSC plate.

## 3. Form Assignment Surveyor

Field:

```text
surveyor_id
container_ids
start_date
due_date
instruction
```

Validasi:

- Surveyor wajib.
- Minimal 1 peti kemas.
- Due date tidak boleh sebelum start date.
- Container tidak boleh sedang aktif di assignment lain.

## 4. Form Pemeriksaan

Tab:

```text
General Info
Checklist Kelaikan
Pengujian Beban
Temuan Struktur
Foto Evidence
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

Result:

```text
pass
fail
na
```

### Pengujian Beban

Parameter:

```text
lifting
stacking
concentrated_load
transverse_racking
longitudinal_restraint
one_door_off_operation
ndt_if_required
```

Field tiap test:

```text
test_result -- pass/fail/na
test_value
test_unit
equipment_used
method_reference
notes
```

### Temuan Struktur

Field:

```text
component_id
criteria_id
location_area
finding_description
measurement_value
measurement_unit
severity
requires_repair
usage_restriction
recommended_followup
photo_required
```

Komponen utama:

- Top rail.
- Bottom rail.
- Header.
- Sill.
- Corner posts.
- Corner and intermediate fittings.
- Understructure.
- Locking rods.

## 5. Form Perbaikan oleh Pemilik/Client

Field:

```text
repair_status
repair_note
repair_started_at
repair_completed_at
repair_evidence_file
ready_for_reinspection_at
```

Catatan:

- Repair bukan dilakukan oleh aplikasi.
- Aplikasi hanya mencatat status dan bukti tindak lanjut dari pemilik/client.

## 6. Form Review

Keputusan:

```text
approve_fit
need_repair
approve_unfit
suspend_use
release_after_repair
request_revision
```

Field:

```text
review_note
final_result
approval_note
signer_id
generate_document
```

Validasi:

- Jika `need_repair`, wajib isi catatan perbaikan.
- Jika `approve_unfit`, wajib isi alasan.
- Jika `release_after_repair`, wajib ada re-inspection yang memenuhi.
- Jika generate document, data teknis wajib lengkap.
