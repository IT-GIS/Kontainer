# Database Redesign Container Fitness

## Tujuan

Mengubah database dari model `container survey` umum menjadi model **kelaikan peti kemas** sesuai Permenhub 25/2022.

## Prinsip

1. `survey_type` tidak menjadi pusat aplikasi.
2. Pusat aplikasi adalah `fitness_applications` dan `application_containers`.
3. CEDEX repair tidak menjadi master utama.
4. Status perbaikan dan re-inspection wajib ada.
5. Output dokumen harus mengikuti format persetujuan kelaikan.
6. VGM tidak masuk schema utama.

## Tabel Inti Baru

### 1. container_owners

Pengganti `customers`.

Field utama:

```sql
id
owner_code
owner_name
address
npwp
pic_name
pic_phone
pic_email
status
created_at
updated_at
deleted_at
```

### 2. container_manufacturers

Field utama:

```sql
id
manufacturer_code
manufacturer_name
address
country
pic_name
pic_phone
pic_email
status
created_at
updated_at
deleted_at
```

### 3. inspection_locations

Pengganti atau rename dari `locations`.

```sql
id
location_code
location_name
location_type
address
city
gps_latitude
gps_longitude
pic_name
pic_phone
status
```

### 4. fitness_applications

Pengganti `job_orders`.

```sql
id
application_no
application_date
owner_id
manufacturer_id NULL
location_id
application_category
application_status
request_letter_no
request_letter_date
reference_no
pic_name
pic_phone
pic_email
notes
created_by
updated_by
created_at
updated_at
deleted_at
```

`application_category`:

```text
new_type_design
new_individual
existing_used_without_approval
existing_produced_without_initial_approval
modified_container
reinspection_after_repair
```

### 5. application_containers

Pengganti `job_containers`.

```sql
id
application_id
container_no
csc_no
iso_code
container_model
manufacture_date
manufacturer_serial_no
manufacturer_id
container_category -- new/existing
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
maintenance_scheme -- ACEP/PES/IICL/ISO/none
container_status
remark
created_at
updated_at
deleted_at
```

`container_status`:

```text
draft
assigned
inspection_in_progress
submitted
need_repair
repair_in_progress
ready_for_reinspection
reinspection_in_progress
fit
unfit
suspended
released
approval_issued
certificate_issued
cancelled
```

### 6. inspection_assignments

Pengganti `assignments`.

```sql
id
assignment_no
application_id
surveyor_id
assigned_by
assigned_at
start_date
due_date
instruction
status
cancel_reason
created_at
updated_at
```

### 7. inspection_assignment_containers

Pengganti `assignment_containers`.

```sql
id
assignment_id
application_container_id
assigned_at
unassigned_at
unassigned_reason
```

### 8. container_inspections

Pengganti `surveys`.

```sql
id
inspection_no
application_id
application_container_id
assignment_id
surveyor_id
inspection_date_time
inspection_location_id
inspection_status
final_recommendation
submitted_at
approved_at
rejected_at
created_at
updated_at
```

`inspection_status`:

```text
draft
in_progress
submitted
need_revision
need_repair
repaired_pending_reinspection
reinspection
approved_fit
approved_unfit
suspended
released
cancelled
```

### 9. inspection_checklist_responses

Pengganti `survey_checklist_responses`.

```sql
id
inspection_id
checklist_item_id
result -- pass/fail/na
finding_note
is_critical
created_at
updated_at
```

### 10. structural_findings

Pengganti `survey_damages`.

```sql
id
inspection_id
finding_no
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
status
created_at
updated_at
```

Status finding:

```text
open
repair_required
repair_in_progress
repaired
still_defective
closed
```

### 11. finding_photos

Pengganti `survey_photos`.

```sql
id
inspection_id
finding_id
file_id
caption
photo_type -- before_repair / after_repair / general
uploaded_by
created_at
```

### 12. repair_followups

Baru.

```sql
id
application_container_id
inspection_id
owner_id
repair_status
repair_note
repair_started_at
repair_completed_at
repair_evidence_file_id
ready_for_reinspection_at
created_by
updated_by
created_at
updated_at
```

`repair_status`:

```text
not_started
repair_required
in_progress
completed_by_owner
ready_for_reinspection
still_defective
accepted
```

### 13. reinspection_records

Baru.

```sql
id
previous_inspection_id
new_inspection_id
application_container_id
reinspection_no
reason
result
created_at
```

### 14. fitness_approvals

Pengganti `reports` sebagai approval utama.

```sql
id
approval_no
application_id
application_container_id
inspection_id
approval_type
approval_status
issued_date
valid_until
signed_by
approved_by
qr_token
created_at
updated_at
```

`approval_type`:

```text
new_type_design_approval
new_individual_approval
existing_used_approval
existing_produced_without_initial_approval
release_after_repair
rejection_notice
```

### 15. approval_documents

Pengganti `report_versions` dan `report_snapshots`.

```sql
id
approval_id
document_no
document_type
version
snapshot_json
pdf_file_id
status
generated_at
generated_by
```

### 16. csc_plate_records

Baru.

```sql
id
application_container_id
approval_id
country_reference
approval_reference_no
approval_year
date_manufactured
identification_number
maximum_operating_gross_mass_kg
maximum_operating_gross_mass_lbs
allowable_stacking_load_kg
allowable_stacking_load_lbs
transverse_racking_test_force_newtons
end_wall_strength
side_wall_strength
first_maintenance_date
next_examination_date
one_door_off_stacking_load
one_door_off_racking_force
created_at
updated_at
```

## Tabel Master Baru

### structural_components

Menggantikan `cedex_components` untuk komponen sensitif struktur:

- top rail,
- bottom rail,
- header,
- sill,
- corner posts,
- corner/intermediate fittings,
- understructure,
- locking rods.

### structural_damage_criteria

Berdasarkan Lampiran III Permenhub 25/2022.

```sql
id
component_id
serious_damage_criteria
owner_notification_criteria
empty_sea_restriction
empty_other_transport_restriction
laden_sea_restriction
laden_other_transport_restriction
handling_instruction
status
```

### test_parameters

Berdasarkan Lampiran II Permenhub 25/2022:

- lifting,
- stacking,
- concentrated load,
- transverse racking,
- longitudinal restraint,
- one door off operation,
- NDT jika diperlukan.

## Tabel yang Perlu Dihapus / Deprecated

```text
survey_types
cedex_repairs
responsibility_codes
finance-specific tables jika tidak dipakai
price_lists jika finance ditunda
```

Jika belum bisa dihapus langsung, tandai sebagai deprecated dan sembunyikan dari menu.

## Strategi Migrasi

### Tahap 1

- Tambahkan tabel baru tanpa menghapus tabel lama.
- Buat view/adapter dari job_orders ke fitness_applications sementara.
- Sembunyikan menu lama yang tidak sesuai.

### Tahap 2

- Pindahkan form Admin ke tabel baru.
- Pindahkan alur Surveyor ke inspection model.
- Pindahkan Review ke approval model.

### Tahap 3

- Generate dokumen approval kelaikan yang mengacu pada Permenhub 25/2022.
- Hapus dependency pada survey_type, cedex_repair, responsibility_code.
- Clean up tabel lama.
