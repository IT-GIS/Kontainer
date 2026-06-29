# permission_matrix_detail.md — Container Survey Management System

**Dokumen:** Permission Matrix Detail  
**Produk:** Container Survey Management System  
**Perusahaan/Unit:** GIFT / PT Global Inspeksi Sertifikasi Group  
**Versi:** 1.0  
**Status:** Draft detail untuk development  

---

## 1. Tujuan Dokumen

Dokumen ini menjelaskan aturan hak akses aplikasi secara detail agar developer dapat menerapkan Role-Based Access Control (RBAC) dengan konsisten pada Web Application MVP dan future Mobile Application.

Dokumen ini melengkapi:

1. `prd.md`
2. `database_schema.md`
3. `api_contract.md`
4. `ui_flow.md`
5. `state_machine.md`

Fokus dokumen ini adalah:

1. Hak akses per role.
2. Hak akses per menu.
3. Hak akses per aksi CRUD.
4. Hak akses berdasarkan kepemilikan data.
5. Hak akses berdasarkan status workflow.
6. Field-level permission.
7. Permission untuk API endpoint.
8. Aturan keamanan agar data teknis survey tidak rusak.

---

## 2. Prinsip Permission

Aplikasi harus mengikuti prinsip berikut:

1. **Least privilege**  
   Setiap role hanya mendapat akses minimum yang diperlukan.

2. **Role-based access**  
   Akses utama ditentukan oleh role user.

3. **Ownership-based access**  
   Surveyor hanya dapat mengakses job/container/survey yang ditugaskan kepadanya.

4. **Status-based access**  
   Data hanya dapat diedit pada status tertentu.

5. **Finance isolation**  
   Finance tidak boleh mengubah data teknis survey.

6. **Approval lock**  
   Survey yang sudah approved atau report generated harus terkunci.

7. **Audit all critical actions**  
   Semua aksi penting harus masuk audit log.

8. **Backend enforcement**  
   Permission tidak boleh hanya dicek di frontend. Backend API wajib melakukan validasi permission.

---

## 3. Role Pengguna

Role yang digunakan:

| Role | Kode | Fungsi Utama |
|---|---|---|
| Super Admin | super_admin | Pengatur sistem tertinggi |
| Admin / Operasional | admin | Mengelola master data, job, assignment, monitoring |
| Surveyor | surveyor | Mengisi survey, damage, foto, submit |
| Supervisor / Approver | supervisor | Review, revisi, approve, finalisasi report |
| Finance | finance | Invoice, payment, outstanding |
| Management | management | Melihat dashboard dan rekap |

Future role opsional:

| Role | Kode | Fungsi |
|---|---|---|
| Customer Portal User | customer_user | Melihat report/invoice milik customer |
| External Auditor | external_auditor | Melihat data read-only tertentu |

---

## 4. Permission Action Code

Gunakan action code standar agar mudah diterapkan di backend.

| Kode | Arti |
|---|---|
| view | Melihat list/detail |
| create | Membuat data baru |
| update | Mengubah data |
| delete | Menghapus data |
| cancel | Membatalkan data |
| approve | Menyetujui data |
| reject | Menolak data |
| revise | Mengembalikan untuk revisi |
| submit | Mengirim data untuk review |
| upload | Upload file/foto |
| download | Download file/PDF |
| export | Export Excel/PDF |
| import | Import Excel |
| assign | Menugaskan surveyor |
| reassign | Mengubah penugasan |
| issue | Menerbitkan invoice |
| pay | Mencatat pembayaran |
| void | Membatalkan nomor/dokumen |
| lock | Mengunci data |
| unlock | Membuka kunci data |
| manage | Akses penuh administratif |

---

## 5. Data Scope

Selain role, sistem harus mengenali scope akses.

| Scope | Arti |
|---|---|
| all | Dapat melihat semua data |
| own | Hanya data milik user sendiri |
| assigned | Hanya data yang ditugaskan kepada user |
| department | Data sesuai unit/department |
| read_only | Hanya baca |
| none | Tidak ada akses |

Rekomendasi scope per role:

| Role | Scope Utama |
|---|---|
| Super Admin | all |
| Admin | all untuk operasional |
| Surveyor | assigned / own |
| Supervisor | all untuk review survey |
| Finance | all untuk finance, read-only untuk report |
| Management | read-only all |

---

## 6. Matrix Menu Utama

| Menu / Modul | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| Dashboard | view | view | view | view | view | view |
| User Management | manage | none | none | none | none | none |
| Role & Permission | manage | none | none | none | none | none |
| Company Profile | manage | view | none | view | view | view |
| Numbering Setting | manage | view | none | view | none | view |
| Report Template | manage | update terbatas | none | view | none | view |
| Master Customer | manage | manage | none | view | view | view |
| Master Location | manage | manage | none | view | none | view |
| Master Surveyor | manage | manage | own profile | view | none | view |
| Master Container Type | manage | manage | view dropdown | view | none | view |
| Master Survey Type | manage | manage | view dropdown | view | none | view |
| Master CEDEX | manage | manage | view dropdown | view | none | view |
| Price List | manage | view/update opsional | none | none | manage | view |
| Job Order | manage | manage | view assigned | view | read-only ready invoice | view |
| Job Container | manage | manage | view assigned | view | read-only | view |
| Assignment | manage | assign/reassign | view assigned | view/opsional assign | none | view |
| Surveyor Web Module | none | view monitoring | manage assigned survey | view | none | view |
| Review | view | view | none | manage | none | view |
| Report | manage | generate/download | view limited | generate/download | download approved | view/download |
| Finance | view | none | none | none | manage | view |
| Audit Log | view all | view terbatas | none | view review-related | none | view terbatas |
| Notification | view/manage | view | view own | view | view | view |
| Export Data | export all | export operational | export own history | export review list | export finance | export management |

Catatan penting:

1. `manage` berarti create, view, update, delete, dan aksi khusus sesuai modul.
2. `view dropdown` berarti hanya dapat membaca data master untuk pilihan form, bukan mengubah.
3. Finance hanya dapat membaca report approved/generated sebagai dasar invoice.
4. Management bersifat read-only.

---

## 7. Matrix CRUD Detail per Modul

### 7.1 User Management

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View user list | Ya | Tidak | Tidak | Tidak | Tidak | Tidak |
| Create user | Ya | Tidak | Tidak | Tidak | Tidak | Tidak |
| Update user | Ya | Tidak | Tidak | Tidak | Tidak | Tidak |
| Deactivate user | Ya | Tidak | Tidak | Tidak | Tidak | Tidak |
| Reset password | Ya | Tidak | Tidak | Tidak | Tidak | Tidak |
| Assign role | Ya | Tidak | Tidak | Tidak | Tidak | Tidak |
| Delete hard | Tidak direkomendasikan | Tidak | Tidak | Tidak | Tidak | Tidak |

Aturan:

1. User tidak boleh dihapus hard jika sudah memiliki transaksi.
2. Gunakan `is_active = false` untuk deaktivasi.
3. Reset password wajib masuk audit log.

---

### 7.2 Role & Permission

| Aksi | Super Admin | Lainnya |
|---|---:|---:|
| View role | Ya | Tidak |
| Create role | Ya | Tidak |
| Update role | Ya | Tidak |
| Assign permission | Ya | Tidak |
| Delete role | Ya, jika tidak dipakai | Tidak |

Aturan:

1. Role bawaan sistem tidak boleh dihapus.
2. Perubahan permission harus masuk audit log.
3. User yang sedang aktif dapat terkena perubahan permission pada request berikutnya.

---

### 7.3 Company Profile

| Aksi | Super Admin | Admin | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|
| View | Ya | Ya | Ya | Ya | Ya |
| Update logo | Ya | Tidak | Tidak | Tidak | Tidak |
| Update address/contact | Ya | Tidak/opsional | Tidak | Tidak | Tidak |
| Update bank info | Ya | Tidak | Tidak | Ya opsional | Lihat |

Aturan:

1. Bank info hanya boleh diedit Super Admin atau Finance jika diberi permission khusus.
2. Logo digunakan di report dan invoice.

---

### 7.4 Numbering Setting

| Aksi | Super Admin | Admin | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|
| View | Ya | Ya | Ya | Tidak | Ya |
| Create/update format | Ya | Tidak | Tidak | Tidak | Tidak |
| Reset running number | Ya | Tidak | Tidak | Tidak | Tidak |
| Void number | Ya | Tidak | Tidak | Tidak | Tidak |

Aturan:

1. Nomor final tidak boleh berubah.
2. Nomor yang batal tidak boleh dipakai ulang.
3. Reset running number hanya boleh dilakukan sebelum production atau dengan alasan resmi.

---

## 8. Master Data Permission

### 8.1 Customer

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View list | Ya | Ya | Tidak | Ya | Ya | Ya |
| View detail | Ya | Ya | Tidak | Ya | Ya | Ya |
| Create | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update | Ya | Ya | Tidak | Tidak | Update billing opsional | Tidak |
| Deactivate | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Delete | Tidak direkomendasikan | Tidak | Tidak | Tidak | Tidak | Tidak |
| Export | Ya | Ya | Tidak | Tidak | Ya finance fields | Ya |

Field-level:

| Field | Editable by Admin | Editable by Finance |
|---|---:|---:|
| customer_name | Ya | Tidak |
| address | Ya | Tidak |
| pic_name/phone/email | Ya | Tidak |
| billing_address | Ya | Ya opsional |
| payment_term_days | Ya | Ya opsional |
| npwp | Ya | Ya opsional |
| status | Ya | Tidak |

---

### 8.2 Location

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View | Ya | Ya | Dropdown assigned | Ya | Tidak | Ya |
| Create | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Deactivate | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Delete | Tidak direkomendasikan | Tidak | Tidak | Tidak | Tidak | Tidak |

---

### 8.3 Surveyor Profile

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View list | Ya | Ya | Tidak | Ya | Tidak | Ya |
| View own profile | Ya | Ya | Ya | Ya | Ya | Ya |
| Create surveyor profile | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update surveyor profile | Ya | Ya | Own limited | Tidak | Tidak | Tidak |
| Upload signature | Ya | Ya | Own | Tidak | Tidak | Tidak |
| Deactivate | Ya | Ya | Tidak | Tidak | Tidak | Tidak |

Surveyor field-level own edit:

| Field | Own Editable |
|---|---:|
| phone | Ya |
| signature_file | Ya |
| password | Ya melalui profile/security |
| name | Tidak, minta admin |
| role | Tidak |
| status | Tidak |

---

### 8.4 Container Type & Survey Type

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View | Ya | Ya | Dropdown | Ya | Lihat untuk price list | Ya |
| Create | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Deactivate | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Delete | Tidak direkomendasikan | Tidak | Tidak | Tidak | Tidak | Tidak |

---

## 9. Master CEDEX Permission

### 9.1 CEDEX Location / Component / Damage / Repair / Material / Responsibility

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View list | Ya | Ya | Dropdown only | Ya | Tidak | Ya |
| View detail | Ya | Ya | Tidak | Ya | Tidak | Ya |
| Create | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Deactivate | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Delete | Tidak direkomendasikan | Tidak | Tidak | Tidak | Tidak | Tidak |
| Import master CEDEX | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Export | Ya | Ya | Tidak | Ya | Tidak | Ya |

Aturan:

1. CEDEX yang sudah dipakai di damage tidak boleh dihapus.
2. Gunakan status inactive jika tidak ingin digunakan lagi.
3. Surveyor hanya melihat label/nama untuk dropdown, bukan halaman master penuh.
4. Supervisor boleh melihat kode teknis untuk review.

---

## 10. Job Order Permission

### 10.1 Job Order Header

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View list all | Ya | Ya | Tidak | Ya | Ready invoice only | Ya |
| View assigned | Ya | Ya | Ya | Ya | Tidak | Ya |
| View detail | Ya | Ya | Assigned only | Ya | Approved/report only | Ya |
| Create | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update draft | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update assigned | Ya | Ya terbatas | Tidak | Tidak | Tidak | Tidak |
| Cancel | Ya | Ya jika belum approved | Tidak | Tidak | Tidak | Tidak |
| Delete | Tidak direkomendasikan | Tidak | Tidak | Tidak | Tidak | Tidak |
| Export | Ya | Ya | Tidak | Ya | Finance fields | Ya |

Status guard:

| Status Job | Admin Edit? | Admin Cancel? |
|---|---:|---:|
| Draft | Ya | Ya |
| Assigned | Ya terbatas | Ya dengan alasan |
| In Progress | Terbatas | Ya dengan approval |
| All Survey Submitted | Tidak untuk data utama | Tidak kecuali Super Admin |
| All Survey Approved | Tidak | Tidak |
| Report Generated | Tidak | Tidak |
| Invoiced/Paid/Closed | Tidak | Tidak |

Field-level update:

| Field | Draft | Assigned | In Progress | Approved+ |
|---|---:|---:|---:|---:|
| customer_id | Ya | Tidak/khusus | Tidak | Tidak |
| survey_type_id | Ya | Tidak/khusus | Tidak | Tidak |
| location_id | Ya | Ya terbatas | Tidak | Tidak |
| priority | Ya | Ya | Ya | Tidak |
| deadline | Ya | Ya | Ya | Tidak |
| instruction | Ya | Ya | Ya | Tidak |
| reference_no/booking/do/bl | Ya | Ya | Ya terbatas | Tidak |

---

### 10.2 Job Container

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View | Ya | Ya | Assigned only | Ya | Reported only | Ya |
| Create manual | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Import Excel | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update before survey | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Update during survey | Ya | Ya terbatas | Tidak | Tidak | Tidak | Tidak |
| Delete before assignment | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Cancel container | Ya | Ya | Tidak | Tidak | Tidak | Tidak |

Aturan:

1. Container yang sudah memiliki survey tidak boleh dihapus.
2. Jika container salah, gunakan cancel/void dengan alasan.
3. Container no tidak boleh diedit setelah survey dimulai kecuali Super Admin dengan audit log dan alasan.

---

## 11. Assignment Permission

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View assignment | Ya | Ya | Assigned own | Ya | Tidak | Ya |
| Create assignment | Ya | Ya | Tidak | Opsional | Tidak | Tidak |
| Reassign | Ya | Ya | Tidak | Opsional | Tidak | Tidak |
| Cancel assignment | Ya | Ya | Tidak | Opsional | Tidak | Tidak |
| Accept assignment | Tidak | Tidak | Ya opsional | Tidak | Tidak | Tidak |
| Mark in progress | Tidak | Tidak | Ya otomatis | Tidak | Tidak | Tidak |
| Complete assignment | Ya | Sistem/Admin | Sistem | Sistem | Tidak | Lihat |

Status guard:

| Status Assignment | Admin Reassign? | Surveyor Edit Survey? |
|---|---:|---:|
| Assigned | Ya | Belum sampai start |
| Accepted | Ya dengan alasan | Ya |
| In Progress | Ya terbatas | Ya |
| Completed | Tidak | Tidak |
| Cancelled | Tidak | Tidak |

---

## 12. Survey Permission

### 12.1 Survey General Info

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View | Ya | Ya | Own assigned | Ya | Approved only | Ya |
| Start survey | Tidak | Tidak | Ya assigned only | Tidak | Tidak | Tidak |
| Update Draft | Tidak | Tidak | Ya own | Tidak | Tidak | Tidak |
| Update Need Revision | Tidak | Tidak | Ya own | Tidak | Tidak | Tidak |
| Update Submitted | Tidak | Tidak | Tidak | Tidak | Tidak | Tidak |
| Update Approved | Tidak | Tidak | Tidak | Tidak | Tidak | Tidak |
| Submit | Tidak | Tidak | Ya own | Tidak | Tidak | Tidak |
| Cancel survey | Ya | Tidak | Tidak | Supervisor/Super Admin | Tidak | Tidak |

Aturan:

1. Surveyor hanya dapat start survey untuk container assigned.
2. Surveyor tidak dapat mengedit surveyor_name atau survey_no.
3. Surveyor tidak dapat mengubah customer/location/survey_type yang berasal dari job.
4. Survey yang approved/report generated terkunci.

Field-level:

| Field | Surveyor Editable? | Supervisor Editable? |
|---|---:|---:|
| survey_no | Tidak | Tidak |
| job_order_no | Tidak | Tidak |
| container_no | Tidak | Tidak |
| survey_type | Tidak | Tidak |
| customer | Tidak | Tidak |
| location | Tidak | Tidak |
| survey_date_time | Ya saat draft | Tidak |
| cargo_status | Ya terbatas | Tidak |
| seal_no | Ya | Tidak |
| truck_no | Ya | Tidak |
| driver_name | Ya | Tidak |
| csc_plate_status | Ya | Tidak |
| door_status | Ya | Tidak |
| general_condition | Ya/sistem rekomendasi | Final result saat approve |
| general_remark | Ya | Catatan review terpisah |

---

### 12.2 Survey Checklist

| Aksi | Surveyor | Supervisor | Admin | Management |
|---|---:|---:|---:|---:|
| View | Own assigned | Ya | Ya | Ya |
| Fill/update Draft | Ya | Tidak | Tidak | Tidak |
| Fill/update Need Revision | Ya | Tidak | Tidak | Tidak |
| Update Submitted | Tidak | Tidak | Tidak | Tidak |
| Review | Tidak | Ya | Lihat | Lihat |

Aturan:

1. Checklist wajib lengkap sebelum submit.
2. Supervisor tidak mengubah checklist langsung; jika salah, gunakan Need Revision.
3. Perubahan checklist masuk audit log.

---

## 13. Survey Sheet & Damage Permission

### 13.1 Interactive Survey Sheet

| Aksi | Surveyor | Supervisor | Admin | Finance | Management |
|---|---:|---:|---:|---:|---:|
| View sheet | Ya own | Ya | Ya | Approved only | Ya |
| Click area/add damage | Draft/Need Revision only | Tidak | Tidak | Tidak | Tidak |
| View marker | Ya | Ya | Ya | Approved only | Ya |
| Edit marker/damage | Draft/Need Revision only | Tidak | Tidak | Tidak | Tidak |

### 13.2 Damage

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View damage | Ya | Ya | Own assigned | Ya | Approved only | Ya |
| Create damage | Tidak | Tidak | Ya draft/revision | Tidak | Tidak | Tidak |
| Update damage | Tidak | Tidak | Ya draft/revision | Tidak | Tidak | Tidak |
| Delete damage | Tidak | Tidak | Ya draft/revision | Tidak | Tidak | Tidak |
| Review damage | Ya | Lihat | Tidak | Ya | Tidak | Lihat |
| Override damage after approve | Super Admin only | Tidak | Tidak | Tidak | Tidak | Tidak |

Aturan:

1. Damage No otomatis, tidak diedit manual.
2. Damage wajib punya location, component, damage type.
3. Damage major/critical wajib ukuran dan foto.
4. Delete damage setelah submit tidak diperbolehkan.
5. Jika supervisor menemukan kesalahan damage, gunakan Need Revision.

Field-level damage:

| Field | Surveyor Draft/Revision | Submitted | Approved |
|---|---:|---:|---:|
| internal_location | Ya dari klik | Tidak | Tidak |
| component_code | Ya | Tidak | Tidak |
| damage_code | Ya | Tidak | Tidak |
| repair_code | Ya | Tidak | Tidak |
| material_code | Ya | Tidak | Tidak |
| responsibility_code | Ya | Tidak | Tidak |
| severity | Ya | Tidak | Tidak |
| length/width/depth | Ya | Tidak | Tidak |
| remark | Ya | Tidak | Tidak |

---

## 14. Photo Evidence Permission

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View photo | Ya | Ya | Own assigned | Ya | Approved/report only | Ya |
| Upload general photo | Tidak | Tidak | Draft/Revision only | Tidak | Tidak | Tidak |
| Upload damage photo | Tidak | Tidak | Draft/Revision only | Tidak | Tidak | Tidak |
| Delete own photo | Tidak | Tidak | Draft/Revision only | Tidak | Tidak | Tidak |
| Delete after submit | Super Admin only | Tidak | Tidak | Tidak | Tidak | Tidak |
| Download photo | Ya | Ya | Own | Ya | Approved only | Ya |

Aturan:

1. Foto damage harus punya `damage_id`.
2. Foto report final tidak boleh hilang meskipun foto asal diubah pada revisi.
3. File sensitive harus dicek authorization saat dibuka.

---

## 15. Submit, Review, Approval Permission

### 15.1 Submit Survey

| Aksi | Surveyor | Supervisor | Admin |
|---|---:|---:|---:|
| Submit Draft | Ya own | Tidak | Tidak |
| Submit Need Revision | Ya own | Tidak | Tidak |
| Submit incomplete | Tidak | Tidak | Tidak |

Backend guard sebelum submit:

1. Survey status harus Draft atau Need Revision.
2. User harus surveyor assigned.
3. General info wajib lengkap.
4. Checklist wajib lengkap.
5. Damage wajib valid.
6. Damage wajib punya foto.
7. Seal no wajib jika laden kecuali override valid.

---

### 15.2 Review / Approval

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View pending review | Ya | Ya view | Tidak | Ya | Tidak | Ya view |
| Need Revision | Tidak/opsional | Tidak | Tidak | Ya | Tidak | Tidak |
| Approve | Tidak/opsional | Tidak | Tidak | Ya | Tidak | Tidak |
| Reject | Tidak/opsional | Tidak | Tidak | Ya | Tidak | Tidak |
| Reopen approved | Super Admin only | Tidak | Tidak | Tidak | Tidak | Tidak |

Aturan:

1. Supervisor tidak boleh mengedit isi survey langsung.
2. Supervisor menggunakan Need Revision untuk meminta perbaikan.
3. Approve membuat survey terkunci.
4. Report No dibuat setelah approval.
5. Approval harus mencatat user, waktu, dan note.

---

## 16. Report Permission

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View report list | Ya | Ya | Own limited | Ya | Approved only | Ya |
| Generate report | Ya | Ya | Tidak | Ya | Tidak | Tidak |
| Regenerate draft preview | Ya | Ya | Tidak | Ya | Tidak | Tidak |
| Download PDF | Ya | Ya | Own approved optional | Ya | Approved only | Ya |
| Create revision | Ya | Tidak | Tidak | Supervisor/Ya | Tidak | Tidak |
| Supersede version | Ya | Tidak | Tidak | Ya | Tidak | Tidak |
| Delete report | Tidak direkomendasikan | Tidak | Tidak | Tidak | Tidak | Tidak |
| Validate QR | Public/limited | Public/limited | Public/limited | Public/limited | Public/limited | Public/limited |

Aturan:

1. Report final hanya dari survey approved.
2. Report final tidak boleh ditimpa.
3. Revisi report menghasilkan versi baru.
4. Finance hanya melihat report yang approved/generated.

---

## 17. EIR Permission

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View EIR | Ya | Ya | Own approved optional | Ya | Approved only | Ya |
| Generate EIR | Ya | Ya | Tidak | Ya | Tidak | Tidak |
| Update draft EIR | Ya | Ya | Tidak | Ya | Tidak | Tidak |
| Finalize EIR | Ya | Tidak | Tidak | Ya | Tidak | Tidak |
| Download | Ya | Ya | Own optional | Ya | Approved only | Ya |

Aturan:

1. EIR hanya untuk survey type yang membutuhkan Gate In/Gate Out/handover.
2. Final EIR terkunci.

---

## 18. Finance Permission

### 18.1 Price List

| Aksi | Super Admin | Admin | Finance | Management |
|---|---:|---:|---:|---:|
| View | Ya | Ya | Ya | Ya |
| Create | Ya | Tidak/opsional | Ya | Tidak |
| Update | Ya | Tidak/opsional | Ya | Tidak |
| Deactivate | Ya | Tidak | Ya | Tidak |
| Delete | Tidak direkomendasikan | Tidak | Tidak | Tidak |

### 18.2 Invoice

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View invoice | Ya | Tidak | Tidak | Tidak | Ya | Ya |
| View ready-to-invoice | Ya | Tidak | Tidak | Tidak | Ya | Ya |
| Create draft invoice | Ya | Tidak | Tidak | Tidak | Ya | Tidak |
| Update draft invoice | Ya | Tidak | Tidak | Tidak | Ya | Tidak |
| Issue invoice | Ya | Tidak | Tidak | Tidak | Ya | Tidak |
| Cancel invoice | Ya | Tidak | Tidak | Tidak | Ya dengan alasan | Tidak |
| Delete invoice | Tidak | Tidak | Tidak | Tidak | Tidak | Tidak |
| Download invoice PDF | Ya | Tidak | Tidak | Tidak | Ya | Ya |
| Export invoice | Ya | Tidak | Tidak | Tidak | Ya | Ya |

Status guard invoice:

| Status Invoice | Finance Edit? | Finance Cancel? | Payment Allowed? |
|---|---:|---:|---:|
| Draft | Ya | Ya | Tidak |
| Issued | Terbatas | Ya dengan alasan | Ya |
| Unpaid | Terbatas | Ya dengan alasan | Ya |
| Partial Paid | Tidak untuk item | Tidak kecuali Super Admin | Ya |
| Paid | Tidak | Tidak | Tidak kecuali adjustment future |
| Overdue | Terbatas | Ya dengan alasan | Ya |
| Cancelled | Tidak | Tidak | Tidak |

### 18.3 Payment

| Aksi | Super Admin | Finance | Management |
|---|---:|---:|---:|
| View payment | Ya | Ya | Ya |
| Create payment | Ya | Ya | Tidak |
| Update payment | Ya terbatas | Ya sebelum reconciliation | Tidak |
| Cancel/void payment | Ya | Ya dengan alasan | Tidak |
| Delete payment | Tidak | Tidak | Tidak |
| Upload proof | Ya | Ya | Tidak |

Aturan:

1. Payment tidak boleh melebihi outstanding kecuali ada mekanisme overpayment future.
2. Payment paid/cancelled wajib audit log.
3. Bukti bayar disimpan sebagai file object.

---

## 19. Management Permission

Management read-only untuk data bisnis.

| Modul | Akses Management |
|---|---|
| Dashboard | View |
| Job Recap | View/export |
| Surveyor Recap | View/export |
| Customer Recap | View/export |
| Damage Recap | View/export |
| Revenue Recap | View/export |
| Report Archive | View/download sesuai kebijakan |
| Finance Outstanding | View/export |
| Audit Log | View terbatas |

Management tidak boleh:

1. Mengubah job.
2. Mengubah survey.
3. Approve survey.
4. Membuat invoice.
5. Mengubah master data.
6. Mengubah permission.

---

## 20. Audit Log Permission

| Aksi | Super Admin | Admin | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|
| View all audit | Ya | Tidak | Tidak | Tidak | Tidak |
| View operational audit | Ya | Ya terbatas | Tidak | Tidak | Ya terbatas |
| View review audit | Ya | Ya view | Ya | Tidak | Ya terbatas |
| View finance audit | Ya | Tidak | Tidak | Ya own module | Ya terbatas |
| Export audit | Ya | Tidak/opsional | Tidak | Tidak | Tidak/opsional |
| Delete audit | Tidak | Tidak | Tidak | Tidak | Tidak |

Aturan:

1. Audit log immutable.
2. Tidak ada role yang boleh delete audit log melalui UI.
3. Data audit lama hanya boleh di-archive oleh proses sistem/admin database sesuai kebijakan retention.

---

## 21. Notification Permission

| Aksi | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| View own notification | Ya | Ya | Ya | Ya | Ya | Ya |
| Mark as read | Ya own | Ya own | Ya own | Ya own | Ya own | Ya own |
| Create system notification | Sistem/Super Admin | Sistem | Sistem | Sistem | Sistem | Sistem |
| Delete notification | Own optional | Own optional | Own optional | Own optional | Own optional | Own optional |

Notification target:

| Event | Target |
|---|---|
| Job assigned | Surveyor |
| Survey submitted | Supervisor |
| Need revision | Surveyor |
| Survey approved | Admin, Finance |
| Report generated | Admin, Finance |
| Invoice issued | Finance/Admin |
| Payment overdue | Finance |

---

## 22. Export / Import Permission

| Fitur | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| Import container Excel | Ya | Ya | Tidak | Tidak | Tidak | Tidak |
| Export job list | Ya | Ya | Tidak | Ya | Tidak | Ya |
| Export survey list | Ya | Ya | Own history optional | Ya | Tidak | Ya |
| Export damage recap | Ya | Ya | Tidak | Ya | Tidak | Ya |
| Export invoice | Ya | Tidak | Tidak | Tidak | Ya | Ya |
| Export payment | Ya | Tidak | Tidak | Tidak | Ya | Ya |
| Export audit log | Ya | Tidak/opsional | Tidak | Tidak | Tidak | Tidak |

Aturan:

1. Export harus tetap mengikuti filter permission.
2. Surveyor tidak boleh export data seluruh job.
3. Finance export tidak boleh memuat detail teknis damage kecuali report approved summary.

---

## 23. API Endpoint Permission Mapping

### 23.1 Auth

| Endpoint | Role |
|---|---|
| POST /api/auth/login | Public |
| POST /api/auth/logout | Authenticated |
| POST /api/auth/refresh | Authenticated/refresh token |
| GET /api/me | Authenticated |

### 23.2 User & Role

| Endpoint | Permission |
|---|---|
| GET /api/users | super_admin |
| POST /api/users | super_admin |
| PUT /api/users/{id} | super_admin |
| POST /api/users/{id}/deactivate | super_admin |
| GET /api/roles | super_admin |
| POST /api/roles | super_admin |
| PUT /api/roles/{id} | super_admin |
| PUT /api/roles/{id}/permissions | super_admin |

### 23.3 Job

| Endpoint | Permission |
|---|---|
| GET /api/jobs | super_admin/admin/supervisor/management, finance limited |
| POST /api/jobs | super_admin/admin |
| GET /api/jobs/{id} | based on role and scope |
| PUT /api/jobs/{id} | super_admin/admin and status guard |
| POST /api/jobs/{id}/cancel | super_admin/admin and status guard |
| POST /api/jobs/{id}/containers/import | super_admin/admin |
| POST /api/jobs/{id}/assign | super_admin/admin |

### 23.4 Surveyor

| Endpoint | Permission |
|---|---|
| GET /api/surveyor/jobs | surveyor own assigned |
| GET /api/surveyor/jobs/{id} | surveyor assigned only |
| POST /api/surveys/start | surveyor assigned only |
| PUT /api/surveys/{id}/general-info | surveyor owner + draft/revision |
| PUT /api/surveys/{id}/checklist | surveyor owner + draft/revision |
| POST /api/surveys/{id}/submit | surveyor owner + validation |

### 23.5 Damage & Photos

| Endpoint | Permission |
|---|---|
| POST /api/surveys/{id}/damages | surveyor owner + draft/revision |
| PUT /api/survey-damages/{id} | surveyor owner + draft/revision |
| DELETE /api/survey-damages/{id} | surveyor owner + draft/revision |
| POST /api/survey-damages/{id}/photos | surveyor owner + draft/revision |
| DELETE /api/survey-photos/{id} | surveyor owner + draft/revision or super_admin |

### 23.6 Review

| Endpoint | Permission |
|---|---|
| GET /api/reviews/pending | supervisor/admin view/management view |
| POST /api/reviews/{survey_id}/approve | supervisor |
| POST /api/reviews/{survey_id}/need-revision | supervisor |
| POST /api/reviews/{survey_id}/reject | supervisor |

### 23.7 Report

| Endpoint | Permission |
|---|---|
| GET /api/reports | super_admin/admin/supervisor/finance/management based scope |
| POST /api/reports/generate/{survey_id} | super_admin/admin/supervisor |
| GET /api/reports/{id}/download | based on role and report status |
| GET /api/reports/validate/{qr_token} | public/limited token |

### 23.8 Finance

| Endpoint | Permission |
|---|---|
| GET /api/finance/ready-to-invoice | finance/super_admin/management view |
| POST /api/finance/invoices | finance/super_admin |
| PUT /api/finance/invoices/{id} | finance/super_admin + status guard |
| POST /api/finance/invoices/{id}/issue | finance/super_admin |
| POST /api/finance/invoices/{id}/cancel | finance/super_admin + reason |
| POST /api/finance/payments | finance/super_admin |

---

## 24. Status-Based Permission Summary

### 24.1 Survey Editing

| Survey Status | Surveyor Edit | Surveyor Submit | Supervisor Review | Finance Access |
|---|---:|---:|---:|---:|
| Draft | Ya | Ya jika valid | Tidak | Tidak |
| Submitted | Tidak | Tidak | Ya | Tidak |
| Need Revision | Ya | Ya jika valid | Tidak sampai submit ulang | Tidak |
| Approved | Tidak | Tidak | Ya read-only | Ya after report generated/ready invoice |
| Rejected | Tidak | Tidak | Ya read-only | Tidak |
| Report Generated | Tidak | Tidak | Read-only | Ya |

### 24.2 Report Access

| Report Status | Admin | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|
| Draft Preview | Ya | Ya | Tidak | Tidak/opsional |
| Generated | Ya | Ya | Ya | Ya |
| Superseded | Ya | Ya | Ya read-only | Ya |
| Cancelled | Ya | Ya | Tidak unless needed | Ya read-only |

### 24.3 Invoice Access

| Invoice Status | Finance Edit | Finance Issue | Finance Payment | Management |
|---|---:|---:|---:|---:|
| Draft | Ya | Ya | Tidak | View optional |
| Issued | Terbatas | Tidak | Ya | View |
| Unpaid | Terbatas | Tidak | Ya | View |
| Partial Paid | Tidak item | Tidak | Ya | View |
| Paid | Tidak | Tidak | Tidak | View |
| Cancelled | Tidak | Tidak | Tidak | View |

---

## 25. UI Button Visibility Rules

Frontend boleh menyembunyikan tombol berdasarkan permission, tetapi backend tetap harus validasi.

### 25.1 Job Detail Buttons

| Tombol | Muncul Jika |
|---|---|
| Edit Job | role admin/super_admin dan status Draft/Assigned/In Progress terbatas |
| Add Container | role admin/super_admin dan status Draft/Assigned |
| Import Container | role admin/super_admin dan status Draft/Assigned |
| Assign Surveyor | role admin/super_admin dan job punya container serta belum closed/cancelled |
| Cancel Job | role admin/super_admin dan status belum approved/report/invoiced |
| View Timeline | role admin/supervisor/management/super_admin |

### 25.2 Surveyor Survey Buttons

| Tombol | Muncul Jika |
|---|---|
| Start Survey | surveyor assigned dan container Not Started/Assigned |
| Save Draft | survey status Draft/Need Revision |
| Add Damage | survey status Draft/Need Revision |
| Upload Photo | survey status Draft/Need Revision |
| Submit Survey | survey status Draft/Need Revision dan validasi lengkap |
| Edit Survey | survey status Draft/Need Revision |
| View Revision Note | survey status Need Revision |

### 25.3 Supervisor Review Buttons

| Tombol | Muncul Jika |
|---|---|
| Need Revision | role supervisor dan survey status Submitted |
| Approve | role supervisor dan survey status Submitted |
| Reject | role supervisor dan survey status Submitted |
| Generate Report | role supervisor/admin dan survey status Approved |

### 25.4 Finance Buttons

| Tombol | Muncul Jika |
|---|---|
| Create Invoice | role finance dan report Ready to Invoice |
| Edit Invoice | invoice Draft/Issued terbatas |
| Issue Invoice | invoice Draft |
| Cancel Invoice | invoice Draft/Issued/Unpaid dan belum paid |
| Add Payment | invoice Issued/Unpaid/Partial Paid/Overdue |
| Download Invoice | invoice Issued/Paid/Unpaid/Partial Paid/Overdue |

---

## 26. Field Masking / Sensitive Data

| Data | Visible to |
|---|---|
| Password hash | Nobody via API |
| Refresh token | Backend only |
| Audit old/new value | Super Admin, limited auditor |
| Bank account company | Super Admin, Finance, Management view |
| Customer billing data | Super Admin, Admin, Finance, Management view |
| Payment proof | Super Admin, Finance, Management view |
| Photo evidence | Role with report/survey access |
| Internal system settings | Super Admin only |

Aturan:

1. API tidak boleh mengembalikan password hash.
2. Token tidak boleh tersimpan di response selain saat auth.
3. File private harus memakai signed URL atau endpoint proxy dengan authorization.

---

## 27. Multi-Role User Handling

Jika satu user memiliki lebih dari satu role:

1. Sistem dapat memilih active role saat login.
2. Permission adalah gabungan role aktif, bukan seluruh role sekaligus, kecuali diputuskan berbeda.
3. UI menampilkan menu berdasarkan active role.
4. Audit log mencatat active_role saat aksi dilakukan.

Rekomendasi MVP:

> Satu user menggunakan satu role aktif untuk menghindari kebingungan.

---

## 28. Permission Seed Recommendation

Permission sebaiknya disimpan sebagai string terstruktur:

```text
module.action.scope
```

Contoh:

```text
users.manage.all
customers.view.all
customers.create.all
jobs.view.all
jobs.create.all
jobs.assign.all
surveys.view.assigned
surveys.update.assigned
surveys.submit.assigned
reviews.approve.all
finance.invoice.create.all
finance.payment.create.all
audit.view.all
```

Contoh role permission:

```text
super_admin = *.*.all
admin = customers.manage.all, jobs.manage.all, assignments.manage.all, reports.view.all
surveyor = surveys.view.assigned, surveys.update.assigned, surveys.submit.assigned, photos.upload.assigned
supervisor = reviews.manage.all, reports.generate.all, surveys.view.all
finance = finance.manage.all, reports.view.approved
management = dashboard.view.all, reports.view.all, finance.view.all
```

---

## 29. Backend Middleware Requirement

Backend harus memiliki middleware berikut:

1. Authentication middleware.
2. Role middleware.
3. Permission middleware.
4. Ownership/scope middleware.
5. Status guard middleware/service.
6. Audit log middleware/service.
7. File authorization middleware.

Contoh validasi request:

```text
Request: PUT /api/survey-damages/{id}

Backend checks:
1. User authenticated?
2. User role = surveyor?
3. Damage belongs to survey owned/assigned to surveyor?
4. Survey status in Draft or Need Revision?
5. Payload valid?
6. Audit log saved?
```

---

## 30. Invalid Permission Scenarios

Backend harus menolak skenario berikut:

1. Surveyor membuka job milik surveyor lain.
2. Surveyor mengedit survey setelah Submitted.
3. Surveyor upload foto ke damage milik survey lain.
4. Finance mengubah damage/checklist/general survey.
5. Admin menghapus container yang sudah memiliki survey.
6. Supervisor approve survey yang belum Submitted.
7. Report dibuat dari survey yang belum Approved.
8. Invoice dibuat dari report yang belum Generated/Ready to Invoice.
9. Payment dibuat untuk invoice Cancelled/Paid.
10. User non Super Admin mengubah permission.
11. User membuka file private tanpa hak akses.

---

## 31. Testing Matrix Permission

### 31.1 Surveyor Access Test

| Test | Expected |
|---|---|
| Surveyor A membuka job Surveyor A | Allowed |
| Surveyor A membuka job Surveyor B | 403 Forbidden |
| Surveyor edit Draft survey | Allowed |
| Surveyor edit Submitted survey | 403/409 |
| Surveyor submit incomplete survey | 422 Validation Error |

### 31.2 Supervisor Access Test

| Test | Expected |
|---|---|
| Supervisor lihat Pending Review | Allowed |
| Supervisor approve Submitted | Allowed |
| Supervisor approve Draft | 409 Invalid State |
| Supervisor edit damage langsung | 403 Forbidden |

### 31.3 Finance Access Test

| Test | Expected |
|---|---|
| Finance lihat Ready to Invoice | Allowed |
| Finance create invoice from approved report | Allowed |
| Finance create invoice from draft survey | 409 Invalid State |
| Finance edit survey damage | 403 Forbidden |
| Finance add payment to cancelled invoice | 409 Invalid State |

### 31.4 Admin Access Test

| Test | Expected |
|---|---|
| Admin create job | Allowed |
| Admin assign surveyor | Allowed |
| Admin delete approved survey | 403 Forbidden |
| Admin edit report final | 403/409 |

### 31.5 Super Admin Access Test

| Test | Expected |
|---|---|
| Super Admin manage users | Allowed |
| Super Admin change permission | Allowed |
| Super Admin delete audit log | Not available |

---

## 32. Checklist Implementasi Permission

| Area | Status |
|---|---|
| Role list defined | Required |
| Permission action code defined | Required |
| Menu permission defined | Required |
| CRUD permission defined | Required |
| Ownership scope defined | Required |
| Status guard defined | Required |
| Field-level permission defined | Required |
| API permission mapping defined | Required |
| UI button visibility rules defined | Required |
| Audit log rules defined | Required |
| File access permission defined | Required |
| Finance isolation defined | Required |
| Supervisor cannot directly edit survey | Required |
| Surveyor assigned-only access defined | Required |
| Management read-only defined | Required |

---

## 33. Catatan Akhir

Dokumen ini menetapkan bahwa permission aplikasi tidak hanya berbasis role, tetapi juga berbasis scope, ownership, dan status workflow.

Ringkasan paling penting:

```text
Super Admin = kontrol sistem penuh, kecuali audit log tetap immutable
Admin = operasional job dan master data
Surveyor = hanya job assigned, input survey saat Draft/Need Revision
Supervisor = review, Need Revision, Approve, Report final
Finance = invoice dan payment, tidak boleh edit data teknis survey
Management = read-only dashboard dan rekap
```

Backend API wajib menjadi sumber kebenaran permission. Frontend hanya membantu menyembunyikan tombol dan menu, tetapi semua keputusan akses final harus tetap dilakukan di backend.
