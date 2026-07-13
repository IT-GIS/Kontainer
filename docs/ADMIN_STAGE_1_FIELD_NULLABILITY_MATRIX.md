# Admin Stage 1 Field Nullability Matrix

Matrix ini disusun untuk corrective hardening Tahap 1.1 berdasarkan `database/kontainer_db.sql`, `database/patches/0015_container_fitness_foundation.sql`, dan schema existing yang dipakai generic Master Data Admin Kelaikan. Tidak ada perubahan schema pada tahap ini.

| Resource | Field | DB Type | DB Nullable | DB Default | Frontend Required | Frontend Nullable | Create Empty Behavior | Update Empty Behavior | Catatan |
|---|---|---|---|---|---|---|---|---|---|
| owners | customer_code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| owners | customer_name | varchar | NO | none | YES | NO | reject | reject | nama pemilik |
| owners | address | text | YES | NULL | NO | YES | null | null | textarea |
| owners | npwp | varchar | YES | NULL | NO | YES | null | null | optional |
| owners | pic_name | varchar | YES | NULL | NO | YES | null | null | optional |
| owners | pic_phone | varchar | YES | NULL | NO | YES | null | null | tel |
| owners | pic_email | varchar | YES | NULL | NO | YES | null | null | email |
| owners | billing_address | text | YES | NULL | NO | YES | null | null | textarea |
| owners | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| manufacturers | manufacturer_code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| manufacturers | manufacturer_name | varchar | NO | none | YES | NO | reject | reject | nama pabrik |
| manufacturers | address | text | YES | NULL | NO | YES | null | null | textarea |
| manufacturers | country | varchar | YES | NULL | NO | YES | null | null | optional |
| manufacturers | pic_name | varchar | YES | NULL | NO | YES | null | null | optional |
| manufacturers | pic_phone | varchar | YES | NULL | NO | YES | null | null | tel |
| manufacturers | pic_email | varchar | YES | NULL | NO | YES | null | null | email |
| manufacturers | website | varchar | YES | NULL | NO | YES | null | null | url |
| manufacturers | note | text | YES | NULL | NO | YES | null | null | textarea |
| manufacturers | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| locations | location_code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| locations | location_name | varchar | NO | none | YES | NO | reject | reject | nama lokasi |
| locations | location_type | varchar | NO | none | YES | NO | reject | reject | enum lokasi |
| locations | address | text | YES | NULL | NO | YES | null | null | textarea |
| locations | city | varchar | YES | NULL | NO | YES | null | null | optional |
| locations | gps_latitude | decimal | YES | NULL | NO | YES | null | null | min -90 max 90 |
| locations | gps_longitude | decimal | YES | NULL | NO | YES | null | null | min -180 max 180 |
| locations | pic_name | varchar | YES | NULL | NO | YES | null | null | optional |
| locations | pic_phone | varchar | YES | NULL | NO | YES | null | null | tel |
| locations | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| surveyors | user_id | char(36) | NO | none | YES | NO | reject | reject | searchable `/users` relation |
| surveyors | surveyor_code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| surveyors | name | varchar | NO | none | YES | NO | reject | reject | maps to `full_name` |
| surveyors | phone | varchar | YES | NULL | NO | YES | null | null | tel |
| surveyors | area | varchar | YES | NULL | NO | YES | null | null | optional |
| surveyors | signature_file_id | char(36) | YES | NULL | NO | YES | null | null | upload belum aktif |
| surveyors | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| container_types | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| container_types | iso_code | varchar | YES | NULL | NO | YES | null | null | optional |
| container_types | size | varchar | NO | none | YES | NO | reject | reject | ukuran wajib |
| container_types | type | varchar | NO | none | YES | NO | reject | reject | maps to `type_name` |
| container_types | description | text | YES | NULL | NO | YES | null | null | textarea |
| container_types | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| approval_categories | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| approval_categories | name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| approval_categories | description | text | YES | NULL | NO | YES | null | null | textarea |
| approval_categories | container_lifecycle | varchar | NO | none | YES | NO | reject | reject | `new` atau `existing` |
| approval_categories | is_mvp_active | tinyint | NO | 1 | NO | NO | omit/default true | default true | non-null default |
| approval_categories | display_order | int | NO | 0 | NO | NO | omit/default 0 | default 0 | non-null default |
| approval_categories | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| maintenance_schemes | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| maintenance_schemes | name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| maintenance_schemes | description | text | YES | NULL | NO | YES | null | null | textarea |
| maintenance_schemes | requires_next_examination_date | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| maintenance_schemes | default_interval_months | int | YES | NULL | NO | YES | null | null | nullable numeric |
| maintenance_schemes | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| inspection_areas | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| inspection_areas | area_name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| inspection_areas | description | text | YES | NULL | NO | YES | null | null | textarea |
| inspection_areas | display_order | int | NO | 0 | NO | NO | omit/default 0 | default 0 | non-null default |
| inspection_areas | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| structural_components | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| structural_components | component_name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| structural_components | inspection_area_id | char(36) | YES | NULL | NO | YES | null | null | relation nullable |
| structural_components | is_structural_critical | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| structural_components | description | text | YES | NULL | NO | YES | null | null | textarea |
| structural_components | display_order | int | NO | 0 | NO | NO | omit/default 0 | default 0 | non-null default |
| structural_components | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| damage_criteria | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| damage_criteria | criteria_name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| damage_criteria | component_id | char(36) | YES | NULL | NO | YES | null | null | relation nullable |
| damage_criteria | description | text | YES | NULL | NO | YES | null | null | textarea |
| damage_criteria | severity_default | varchar | NO | minor | NO | NO | omit/default minor | default minor | enum severity |
| damage_criteria | affects_fitness_default | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| damage_criteria | repair_required_default | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| damage_criteria | inspection_note | text | YES | NULL | NO | YES | null | null | textarea |
| damage_criteria | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| finding_severities | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| finding_severities | name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| finding_severities | description | text | YES | NULL | NO | YES | null | null | textarea |
| finding_severities | level_no | int | NO | none | YES | NO | reject | reject | minimum 1 |
| finding_severities | affects_fitness_default | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| finding_severities | requires_supervisor_review | tinyint | NO | 0/false | NO | NO | omit/default false | default false | non-null default; aturan critical wajib review masuk Tahap 2 |
| finding_severities | badge_tone | varchar | YES | NULL | NO | YES | null | null | enum optional |
| finding_severities | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| test_parameters | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| test_parameters | parameter_name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| test_parameters | description | text | YES | NULL | NO | YES | null | null | textarea |
| test_parameters | unit | varchar | YES | NULL | NO | YES | null | null | optional |
| test_parameters | standard_reference | varchar | YES | NULL | NO | YES | null | null | optional |
| test_parameters | applies_to_new_container | tinyint | NO | 1 | NO | NO | omit/default true | default true | non-null default |
| test_parameters | applies_to_existing_container | tinyint | NO | 1 | NO | NO | omit/default true | default true | non-null default |
| test_parameters | requires_numeric_result | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| test_parameters | requires_attachment | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| test_parameters | display_order | int | NO | 0 | NO | NO | omit/default 0 | default 0 | non-null default |
| test_parameters | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| checklist_templates | template_code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| checklist_templates | template_name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| checklist_templates | approval_category_id | char(36) | YES | NULL | NO | YES | null | null | relation nullable |
| checklist_templates | container_type_id | char(36) | YES | NULL | NO | YES | null | null | relation nullable |
| checklist_templates | description | text | YES | NULL | NO | YES | null | null | textarea |
| checklist_templates | version_no | int | NO | 1 | NO | NO | omit/default 1 | default 1 | non-null default |
| checklist_templates | status | varchar | NO | draft | NO | NO | omit/default draft | active if emptied | draft/active/inactive |
| checklist_items | template_id | char(36) | NO | none | YES | NO | reject | reject | fixed parent |
| checklist_items | item_code | varchar | NO | none | YES | NO | reject | reject | unik per template |
| checklist_items | item_label | varchar | NO | none | YES | NO | reject | reject | label wajib |
| checklist_items | description | text | YES | NULL | NO | YES | null | null | textarea |
| checklist_items | inspection_area_id | char(36) | YES | NULL | NO | YES | null | null | relation nullable |
| checklist_items | structural_component_id | char(36) | YES | NULL | NO | YES | null | null | relation nullable |
| checklist_items | test_parameter_id | char(36) | YES | NULL | NO | YES | null | null | relation nullable |
| checklist_items | response_type | varchar | NO | ok_not_ok | NO | NO | omit/default ok_not_ok | default ok_not_ok | enum response |
| checklist_items | expected_value | varchar | YES | NULL | NO | YES | null | null | optional |
| checklist_items | is_required | tinyint | NO | 1 | NO | NO | omit/default true | default true | non-null default |
| checklist_items | is_critical | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| checklist_items | fail_requires_repair | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| checklist_items | fail_marks_unfit | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| checklist_items | display_order | int | NO | 0 | NO | NO | omit/default 0 | default 0 | non-null default |
| checklist_items | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| photo_categories | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| photo_categories | name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| photo_categories | description | text | YES | NULL | NO | YES | null | null | textarea |
| photo_categories | is_required_default | tinyint | NO | 0 | NO | NO | omit/default false | default false | non-null default |
| photo_categories | applies_to | varchar | YES | NULL | NO | YES | null | null | enum optional |
| photo_categories | display_order | int | NO | 0 | NO | NO | omit/default 0 | default 0 | non-null default |
| photo_categories | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| recommendations | code | varchar | NO | none | YES | NO | reject | reject | kode unik |
| recommendations | name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| recommendations | description | text | YES | NULL | NO | YES | null | null | textarea |
| recommendations | final_fitness_result_mapping | varchar | NO | pending | NO | NO | omit/default pending | default pending | enum final result |
| recommendations | workflow_status_mapping | varchar | YES | NULL | NO | YES | null | null | optional |
| recommendations | restriction_status_mapping | varchar | YES | NULL | NO | YES | null | null | optional |
| recommendations | requires_supervisor_review | tinyint | NO | 1 | NO | NO | omit/default true | default true | non-null default |
| recommendations | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| authorized_signers | signer_name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| authorized_signers | position_title | varchar | NO | none | YES | NO | reject | reject | jabatan wajib |
| authorized_signers | employee_no | varchar | YES | NULL | NO | YES | null | null | optional |
| authorized_signers | email | varchar | YES | NULL | NO | YES | null | null | email |
| authorized_signers | phone | varchar | YES | NULL | NO | YES | null | null | tel |
| authorized_signers | signature_file_id | char(36) | YES | NULL | NO | YES | null | null | upload belum aktif |
| authorized_signers | valid_from | date | YES | NULL | NO | YES | null | null | date input |
| authorized_signers | valid_until | date | YES | NULL | NO | YES | null | null | date input |
| authorized_signers | status | varchar | NO | active | NO | NO | omit/default active | active if emptied | status resource |
| company_profile | company_name | varchar | NO | none | YES | NO | reject | reject | nama wajib |
| company_profile | brand_name | varchar | YES | NULL | NO | YES | null | null | optional |
| company_profile | address | text | YES | NULL | NO | YES | null | null | textarea |
| company_profile | phone | varchar | YES | NULL | NO | YES | null | null | tel |
| company_profile | email | varchar | YES | NULL | NO | YES | null | null | email |
| company_profile | website | varchar | YES | NULL | NO | YES | null | null | url |
| company_profile | tax_no | varchar | YES | NULL | NO | YES | null | null | optional |
| company_profile | logo_file_id | char(36) | YES | NULL | NO | YES | null | null | upload belum aktif |
| company_profile | default_signature_file_id | char(36) | YES | NULL | NO | YES | null | null | upload belum aktif |
| company_profile | is_active | tinyint | NO | 1 | NO | NO | omit/default true | default true | boolean status |
## Addendum Tahap 1.2

Koreksi Tahap 1.2:

- Frontend nullable ditambahkan untuk field optional DDL `NULL`, termasuk `npwp`, `pic_name`, `pic_email`, `country`, `city`, `area`, `signature_file_id`, `iso_code`, seluruh FK nullable master, `employee_no`, `email`, `brand_name`, `tax_no`, `logo_file_id`, dan `default_signature_file_id`.
- Empty update untuk field nullable tetap dikirim sebagai `null` lewat `serializePayload`, sehingga backend menyimpan `NULL`.
- Relation FK nullable tetap memakai create empty `null` dan update empty `null`.
- Relation display backend mengembalikan label DB: `inspection_area_label`, `component_label`, `test_parameter_label`, `approval_category_label`, dan `container_type_label`.
- `finding_severities.requires_supervisor_review` mengikuti DDL patch 0015 dan canonical dump: default `0/false`.
