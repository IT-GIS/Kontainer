# UI Flow — Container Survey Management System

**Nama Produk:** Container Survey Management System  
**Perusahaan/Unit:** GIFT / PT Global Inspeksi Sertifikasi Group  
**Dokumen:** UI Flow / User Interface Flow Document  
**Versi:** 1.0  
**Tanggal:** 24 Juni 2026  
**Status:** Draft detail untuk desain UI/UX dan development web MVP  

---

## 1. Tujuan Dokumen

Dokumen `ui_flow.md` menjelaskan alur tampilan aplikasi dari sisi pengguna. Dokumen ini menjadi turunan dari:

1. `prd.md`
2. `database_schema.md`
3. `api_contract.md`

Dokumen ini berfungsi untuk membantu UI/UX designer, frontend developer, backend developer, QA tester, dan stakeholder memahami:

1. Struktur halaman aplikasi.
2. Pembagian menu berdasarkan role.
3. Alur klik dari satu halaman ke halaman lain.
4. Data yang tampil pada setiap halaman.
5. Tombol/aksi yang tersedia.
6. Validasi UI sebelum data dikirim ke API.
7. State halaman seperti loading, empty, error, success, disabled, dan locked.
8. Perbedaan antara Web Application MVP dan Mobile Application phase lanjutan.

---

## 2. Prinsip UI/UX Utama

Aplikasi harus mengikuti prinsip berikut:

1. **Web-first untuk MVP**  
   Semua role dibuat di Web Application terlebih dahulu, termasuk Surveyor Web Module, untuk validasi alur.

2. **Mobile-ready design**  
   Walaupun surveyor MVP ada di web, layout dan flow surveyor harus mudah dipindahkan ke mobile.

3. **Role-based navigation**  
   User hanya melihat menu sesuai role dan permission.

4. **Action-driven UI**  
   Setiap halaman harus memiliki aksi utama yang jelas, misalnya `Create Job`, `Assign Surveyor`, `Submit Survey`, `Approve`, atau `Create Invoice`.

5. **Status visible**  
   Status job, survey, report, invoice, dan payment harus selalu terlihat.

6. **Minim input bebas**  
   Gunakan dropdown, radio, checkbox, date picker, dan autocomplete sebanyak mungkin.

7. **Damage dan foto harus terhubung**  
   Di UI, user harus selalu tahu foto mana milik damage mana.

8. **Approval-first**  
   Report final tidak boleh muncul sebagai final sebelum supervisor approve.

9. **Finance tidak melihat form teknis sebagai editable**  
   Finance hanya melihat data teknis dalam mode read-only.

10. **Clear warning sebelum submit**  
   Surveyor harus melihat warning data belum lengkap sebelum submit.

---

## 3. Platform UI

### 3.1 Web Application MVP

Digunakan oleh:

1. Super Admin
2. Admin / Operasional
3. Surveyor Web
4. Supervisor / Approver
5. Finance
6. Management

Tujuan:

1. Menjalankan proses bisnis end-to-end.
2. Memvalidasi alur survey sebelum mobile dibuat.
3. Menjadi dashboard kantor.
4. Menjadi pusat pengelolaan master data, job, approval, report, dan finance.

### 3.2 Mobile Application Future Phase

Digunakan oleh:

1. Surveyor lapangan

Tujuan:

1. Mengisi survey lebih cepat di lapangan.
2. Menggunakan kamera langsung.
3. Mengambil GPS.
4. Menyimpan draft offline.
5. Upload foto background.
6. Sync data ke backend yang sama.

Catatan penting:

> Surveyor Web Module adalah validasi alur/MVP internal. Target operasional lapangan jangka panjang tetap Mobile Application.

---

## 4. Global Layout Web Application

### 4.1 Struktur Layout Desktop

```text
+--------------------------------------------------------------------------------+
| Topbar: Logo | Search | Notification | User Profile | Logout                  |
+----------------------+---------------------------------------------------------+
| Sidebar              | Main Content                                            |
| - Dashboard          |                                                         |
| - Master Data        | Page Header                                             |
| - Job Order          | Breadcrumb                                              |
| - Surveyor Module    | Content Card / Table / Form                             |
| - Review             |                                                         |
| - Report             |                                                         |
| - Finance            |                                                         |
| - Management         |                                                         |
| - Setting            |                                                         |
+----------------------+---------------------------------------------------------+
```

### 4.2 Struktur Layout Mobile Web Responsive

Untuk web responsive, sidebar berubah menjadi drawer.

```text
+----------------------------------+
| Topbar: Menu Icon | Logo | User  |
+----------------------------------+
| Page Title                       |
| Breadcrumb                       |
| Content                          |
| Bottom/Sticky Action if needed   |
+----------------------------------+
```

### 4.3 Komponen Global

| Komponen | Fungsi |
|---|---|
| Topbar | Menampilkan logo, notifikasi, user profile, logout |
| Sidebar | Navigasi utama sesuai role |
| Breadcrumb | Menunjukkan posisi halaman |
| Page Header | Judul halaman dan aksi utama |
| Status Badge | Menampilkan status job/survey/report/invoice |
| Data Table | List data dengan pagination/filter/search |
| Form Card | Input data terstruktur |
| Modal/Dialog | Aksi cepat seperti tambah damage, confirm submit, approve |
| Toast Notification | Feedback sukses/gagal |
| Empty State | Tampilan jika data kosong |
| Loading State | Skeleton/spinner saat data dimuat |
| Error State | Tampilan jika API gagal |
| Confirmation Dialog | Konfirmasi aksi penting |

---

## 5. Global Navigation dan Role-Based Menu

### 5.1 Sidebar Global Lengkap

```text
Dashboard

Master Data
- Customer
- Location
- Surveyor
- Container Type
- Survey Type
- CEDEX Location
- CEDEX Component
- CEDEX Damage
- CEDEX Repair
- CEDEX Material
- Responsibility Code
- Price List

Job Order
- Create Job
- Job List
- Import Container
- Assign Surveyor
- Job Timeline

Surveyor Module
- Job Saya
- Draft Survey
- Submitted Survey
- Need Revision
- Riwayat Survey

Review
- Pending Review
- Need Revision
- Approved Survey

Report
- Report Archive
- Generate Report
- Download Report
- Report Version

Finance
- Ready to Invoice
- Invoice List
- Create Invoice
- Payment
- Outstanding
- Rekap Customer

Management
- Job Recap
- Surveyor Recap
- Customer Recap
- Damage Recap
- Revenue Recap

Setting
- User Management
- Role & Permission
- Company Profile
- Numbering Setting
- Report Template
- Audit Log
- System Setting
```

### 5.2 Menu Super Admin

```text
Dashboard
User Management
Role & Permission
Company Profile
Numbering Setting
Master Data
Report Template
Audit Log
System Setting
```

### 5.3 Menu Admin / Operasional

```text
Dashboard Operasional
Master Customer
Master Location
Master Surveyor
Master Container Type
Master Survey Type
Master CEDEX
Job Order
Input Container
Assign Surveyor
Monitoring Survey
Report Archive
Export Data
```

### 5.4 Menu Surveyor Web

```text
Dashboard Surveyor
Job Saya
Draft Survey
Submitted Survey
Need Revision
Riwayat Survey
```

Di dalam detail survey:

```text
General Info
Checklist Survey
Survey Sheet Interaktif
Damage List
Photo Evidence
Preview Survey
Submit Survey
```

### 5.5 Menu Supervisor

```text
Dashboard Review
Pending Review
Need Revision
Approved Survey
Report Preview
Final Report
```

### 5.6 Menu Finance

```text
Dashboard Finance
Ready to Invoice
Price List
Create Invoice
Invoice List
Payment
Outstanding
Rekap Customer
Export Finance
```

### 5.7 Menu Management

```text
Dashboard Management
Rekap Job
Rekap Surveyor
Rekap Customer
Rekap Damage
Rekap Revenue
Export Report
```

---

## 6. Global UI State

Setiap halaman list, detail, dan form harus memiliki state berikut.

### 6.1 Loading State

Dipakai saat data masih dimuat.

Contoh:

```text
[ Skeleton table row ]
[ Skeleton table row ]
[ Skeleton table row ]
```

### 6.2 Empty State

Dipakai saat data kosong.

Contoh:

```text
Belum ada Job Order.
Klik tombol "Create Job" untuk membuat pekerjaan baru.
```

### 6.3 Error State

Dipakai saat API gagal.

Contoh:

```text
Data gagal dimuat.
[ Coba Lagi ]
```

### 6.4 Success State

Dipakai setelah aksi berhasil.

Contoh toast:

```text
Job Order berhasil dibuat.
```

### 6.5 Validation State

Dipakai saat form belum valid.

Contoh:

```text
Container No wajib diisi.
Damage D-001 belum memiliki foto.
Seal No wajib untuk container Laden.
```

### 6.6 Locked State

Dipakai saat data sudah submitted/approved/final.

Contoh:

```text
Survey sudah Approved. Data terkunci dan tidak dapat diedit.
```

---

## 7. Authentication Flow

### 7.1 Login Page

Route:

```text
/login
```

Layout:

```text
+--------------------------------------+
| Logo Perusahaan                      |
| Container Survey Management System   |
|--------------------------------------|
| Email / Username                     |
| Password                             |
| [ ] Remember Me                      |
| [ Login ]                            |
| Forgot Password?                     |
+--------------------------------------+
```

Field:

| Field | Komponen | Validasi |
|---|---|---|
| Email/Username | Input text | Wajib |
| Password | Password input | Wajib |
| Remember Me | Checkbox | Opsional |

Aksi:

| Tombol | Fungsi |
|---|---|
| Login | Submit ke API login |
| Forgot Password | Buka halaman reset password |

Flow:

```text
User buka /login
↓
Input credential
↓
Klik Login
↓
Jika gagal: tampilkan error
↓
Jika sukses: arahkan sesuai role
```

Redirect setelah login:

| Role | Redirect |
|---|---|
| Super Admin | /dashboard/super-admin |
| Admin | /dashboard/admin |
| Surveyor | /surveyor/jobs |
| Supervisor | /review/pending |
| Finance | /finance/dashboard |
| Management | /management/dashboard |

### 7.2 Forgot Password Page

Route:

```text
/forgot-password
```

Flow:

```text
Input email
↓
Klik Send Reset Link
↓
Sistem kirim email/reset manual sesuai konfigurasi
```

### 7.3 Logout Flow

```text
Klik User Profile
↓
Klik Logout
↓
Konfirmasi
↓
Token/session dihapus
↓
Redirect ke /login
```

---

## 8. Dashboard UI Flow

## 8.1 Dashboard Admin / Operasional

Route:

```text
/dashboard/admin
```

Konten:

```text
+--------------------------------------------------------------------------------+
| Dashboard Operasional                                                          |
| [Create Job Order] [Import Container]                                          |
+--------------------------------------------------------------------------------+
| Card: Total Job Today | Draft | Assigned | In Progress | Pending Review        |
| Card: Need Revision   | Approved | Ready Invoice | Surveyor Active           |
+--------------------------------------------------------------------------------+
| Chart: Job by Status                                                           |
| Table: Latest Job Orders                                                       |
+--------------------------------------------------------------------------------+
```

Komponen:

| Komponen | Data |
|---|---|
| Summary Cards | Jumlah job berdasarkan status |
| Latest Job Table | Job terbaru |
| Status Chart | Jumlah job per status |
| Quick Action | Create Job, Import Container |

Aksi:

| Aksi | Target |
|---|---|
| Create Job Order | /jobs/create |
| View Job | /jobs/{id} |
| Monitoring Survey | /monitoring/surveys |

---

## 8.2 Dashboard Surveyor

Route:

```text
/dashboard/surveyor
```

Konten:

```text
+-------------------------------------------------------+
| Dashboard Surveyor                                    |
+-------------------------------------------------------+
| Card: Job Saya | Belum Mulai | Draft | Need Revision  |
| Card: Submitted | Approved                            |
+-------------------------------------------------------+
| Section: Job Hari Ini                                 |
| - GIFT-JO-2026-000001                                 |
| - GIFT-JO-2026-000002                                 |
+-------------------------------------------------------+
```

Aksi:

| Aksi | Target |
|---|---|
| Lihat Job | /surveyor/jobs/{id} |
| Lanjutkan Draft | /surveyor/surveys/{id} |
| Perbaiki Revisi | /surveyor/surveys/{id} |

---

## 8.3 Dashboard Supervisor

Route:

```text
/dashboard/supervisor
```

Konten:

```text
+------------------------------------------------------+
| Dashboard Review                                     |
+------------------------------------------------------+
| Pending Review | Need Revision | Approved Today      |
| Critical Damage                                      |
+------------------------------------------------------+
| Table: Submitted Survey                              |
+------------------------------------------------------+
```

Aksi:

| Aksi | Target |
|---|---|
| Review Survey | /review/{survey_id} |
| View Approved | /review/approved |

---

## 8.4 Dashboard Finance

Route:

```text
/finance/dashboard
```

Konten:

```text
+------------------------------------------------------+
| Dashboard Finance                                    |
+------------------------------------------------------+
| Ready Invoice | Invoice Bulan Ini | Paid | Unpaid    |
| Overdue | Outstanding Amount                         |
+------------------------------------------------------+
| Table: Ready to Invoice                              |
| Table: Overdue Invoice                               |
+------------------------------------------------------+
```

Aksi:

| Aksi | Target |
|---|---|
| Create Invoice | /finance/invoices/create |
| View Outstanding | /finance/outstanding |

---

## 8.5 Dashboard Management

Route:

```text
/management/dashboard
```

Konten:

```text
+------------------------------------------------------+
| Dashboard Management                                 |
+------------------------------------------------------+
| Total Job | Total Container | Revenue | Outstanding  |
+------------------------------------------------------+
| Chart: Job Trend                                     |
| Chart: Revenue Trend                                 |
| Chart: Top Damage                                    |
| Chart: Top Customer                                  |
+------------------------------------------------------+
```

---

## 9. Master Data UI Flow

Master data memiliki pola UI yang sama.

### 9.1 Generic Master Data List Page

Contoh route:

```text
/master/customers
/master/locations
/master/surveyors
/master/container-types
/master/survey-types
/master/cedex/components
/master/cedex/damages
/master/cedex/repairs
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Page Title: Master Customer                                   [Add Customer]    |
+--------------------------------------------------------------------------------+
| Search... | Filter Status | Export                                           |
+--------------------------------------------------------------------------------+
| Table                                                                          |
| Code | Name | Status | Created At | Action                                      |
| ...                                                                            |
+--------------------------------------------------------------------------------+
| Pagination                                                                     |
+--------------------------------------------------------------------------------+
```

Aksi table:

| Aksi | Fungsi |
|---|---|
| View | Membuka detail |
| Edit | Membuka form edit |
| Delete/Deactivate | Nonaktifkan data |

State:

| State | Tampilan |
|---|---|
| Empty | Belum ada data master |
| Loading | Skeleton table |
| Error | Coba lagi |

### 9.2 Generic Master Data Create/Edit Page

Layout:

```text
+------------------------------------------------------+
| Add Customer                                         |
| Breadcrumb: Master Data > Customer > Add             |
+------------------------------------------------------+
| Form Card                                            |
| Customer Code                                        |
| Customer Name                                        |
| Address                                              |
| PIC Name                                             |
| Phone                                                |
| Email                                                |
| Status                                               |
+------------------------------------------------------+
| [Cancel] [Save]                                      |
+------------------------------------------------------+
```

Flow:

```text
Klik Add
↓
Isi form
↓
Klik Save
↓
Validasi UI
↓
Submit API
↓
Jika sukses: redirect ke list/detail
↓
Jika gagal: tampilkan error
```

---

## 10. Company Profile UI Flow

Route:

```text
/settings/company-profile
```

Layout:

```text
+------------------------------------------------------+
| Company Profile                                      |
+------------------------------------------------------+
| Company Name                                         |
| Legal Name                                           |
| Address                                              |
| Phone                                                |
| Email                                                |
| Website                                              |
| Tax Number                                           |
| Logo Upload                                          |
| Report Header Setting                                |
+------------------------------------------------------+
| [Save Changes]                                       |
+------------------------------------------------------+
```

Validasi:

1. Company name wajib.
2. Logo harus image.
3. Email harus valid.

---

## 11. Numbering Setting UI Flow

Route:

```text
/settings/numbering
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Numbering Setting                                                              |
+--------------------------------------------------------------------------------+
| Document Type | Prefix | Format | Current Year | Current Number | Action       |
| Job Order     | GIFT-JO | {PREFIX}-{YEAR}-{NUMBER} | 2026 | 000001 | Edit     |
| Survey        | GIFT-SVY| ...                            | ...  | ...    | Edit     |
+--------------------------------------------------------------------------------+
```

Edit modal:

```text
+------------------------------------------------------+
| Edit Numbering: Job Order                            |
+------------------------------------------------------+
| Prefix                                               |
| Format Pattern                                       |
| Reset Rule: yearly/monthly/never                     |
| Current Number                                       |
| Padding Length                                       |
+------------------------------------------------------+
| Preview: GIFT-JO-2026-000001                         |
| [Cancel] [Save]                                      |
+------------------------------------------------------+
```

Validasi:

1. Prefix wajib.
2. Format wajib punya running number.
3. Current number tidak boleh lebih kecil dari nomor yang sudah pernah dipakai.

---

## 12. Job Order UI Flow

## 12.1 Job List Page

Route:

```text
/jobs
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Job Order                                                   [Create Job]        |
+--------------------------------------------------------------------------------+
| Search Job/Customer/Container | Status Filter | Date Range | Export            |
+--------------------------------------------------------------------------------+
| Job No | Customer | Survey Type | Location | Total Container | Status | Action  |
| ...                                                                            |
+--------------------------------------------------------------------------------+
| Pagination                                                                     |
+--------------------------------------------------------------------------------+
```

Status badge:

| Status | Badge |
|---|---|
| Draft | Gray |
| Assigned | Blue |
| In Progress | Yellow |
| Submitted | Purple |
| Approved | Green |
| Ready to Invoice | Teal |
| Invoiced | Indigo |
| Paid | Green |
| Cancelled | Red |

Aksi:

| Aksi | Target |
|---|---|
| Create Job | /jobs/create |
| View Detail | /jobs/{id} |
| Edit | /jobs/{id}/edit |
| Cancel | Confirmation modal |

---

## 12.2 Create Job Page

Route:

```text
/jobs/create
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Create Job Order                                                               |
+--------------------------------------------------------------------------------+
| Section: Basic Information                                                     |
| Job Date | Customer | Survey Type | Location | Priority | Deadline            |
+--------------------------------------------------------------------------------+
| Section: Customer Reference                                                    |
| PIC Name | PIC Phone | PIC Email | Reference No | Booking No | DO No | BL No   |
+--------------------------------------------------------------------------------+
| Section: Shipment/Transport Optional                                           |
| Vessel | Voyage | Trucking Company                                             |
+--------------------------------------------------------------------------------+
| Section: Instruction                                                           |
| Instruction textarea                                                           |
+--------------------------------------------------------------------------------+
| [Cancel] [Save Draft] [Save & Add Container]                                   |
+--------------------------------------------------------------------------------+
```

Flow:

```text
Admin buka Create Job
↓
Isi basic information
↓
Klik Save Draft atau Save & Add Container
↓
Sistem membuat Job Order No
↓
Redirect ke Job Detail > Container tab
```

Validasi:

1. Customer wajib.
2. Survey Type wajib.
3. Location wajib.
4. Job Date wajib.
5. Priority default normal.

---

## 12.3 Job Detail Page

Route:

```text
/jobs/{id}
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Job Detail: GIFT-JO-2026-000001                         [Edit] [Cancel Job]    |
| Customer: PT ABC Logistics | Status: Draft                                      |
+--------------------------------------------------------------------------------+
| Tabs: Overview | Containers | Assignment | Survey Progress | Reports | Timeline |
+--------------------------------------------------------------------------------+
```

### Tab Overview

Menampilkan:

1. Job Order No.
2. Job Date.
3. Customer.
4. Survey Type.
5. Location.
6. PIC.
7. Reference.
8. Booking/DO/BL.
9. Vessel/Voyage.
10. Priority.
11. Deadline.
12. Instruction.
13. Status.

Aksi:

| Aksi | Fungsi |
|---|---|
| Edit Job | Edit header job |
| Cancel Job | Membatalkan job |
| Print Job Order | Generate surat tugas/job order |

### Tab Containers

```text
+--------------------------------------------------------------------------------+
| Containers                                                   [Add] [Import]     |
+--------------------------------------------------------------------------------+
| Container No | Type | Seal No | Cargo | Truck No | Surveyor | Status | Action   |
+--------------------------------------------------------------------------------+
```

Aksi:

| Aksi | Fungsi |
|---|---|
| Add Container | Manual input |
| Import Container | Upload Excel |
| Edit Container | Edit data container |
| Delete Container | Hanya jika belum assigned/submitted |

### Tab Assignment

Menampilkan assignment surveyor.

```text
Assignment No | Surveyor | Total Container | Status | Assigned At | Action
```

Aksi:

| Aksi | Fungsi |
|---|---|
| Assign Surveyor | Buka assignment page/modal |
| Reassign | Ganti surveyor untuk container tertentu |

### Tab Survey Progress

```text
Container No | Surveyor | Survey No | Survey Status | Damage Count | Photo Count | Action
```

Aksi:

| Aksi | Fungsi |
|---|---|
| View Survey | Buka detail survey readonly |

### Tab Reports

```text
Report No | Container No | Survey No | Version | Status | Action
```

### Tab Timeline

Menampilkan aktivitas job.

```text
Created job
Added container
Assigned surveyor
Survey submitted
Survey approved
Report generated
Invoice issued
```

---

## 12.4 Add Container Modal/Page

Route/modal:

```text
/jobs/{id}/containers/add
```

Layout:

```text
+------------------------------------------------------+
| Add Container                                        |
+------------------------------------------------------+
| Container No                                         |
| Container Type                                       |
| ISO Type Code                                        |
| Seal No                                              |
| Cargo Status                                         |
| Truck No                                             |
| Driver Name                                          |
| CSC Plate Status                                     |
| Remark                                               |
+------------------------------------------------------+
| [Cancel] [Save]                                      |
+------------------------------------------------------+
```

Validasi:

1. Container No wajib.
2. Container No auto uppercase.
3. Container No tidak boleh duplikat dalam job.
4. Cargo Status wajib.
5. Check digit warning tampil jika invalid.

---

## 12.5 Import Container Page

Route:

```text
/jobs/{id}/containers/import
```

Layout:

```text
+------------------------------------------------------+
| Import Container                                     |
+------------------------------------------------------+
| Step 1: Download Template                            |
| [Download Excel Template]                            |
+------------------------------------------------------+
| Step 2: Upload File                                  |
| [Choose File]                                        |
+------------------------------------------------------+
| Step 3: Preview Data                                 |
| Table preview with validation status                 |
+------------------------------------------------------+
| [Cancel] [Import Valid Rows]                         |
+------------------------------------------------------+
```

Preview columns:

```text
Row | Container No | Type | Seal No | Cargo Status | Status Validation | Error
```

Rules:

1. Invalid rows tampil merah.
2. Duplicate rows ditandai.
3. User bisa import hanya row valid.

---

## 13. Assignment UI Flow

## 13.1 Assign Surveyor Page/Modal

Route:

```text
/jobs/{id}/assign
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Assign Surveyor: GIFT-JO-2026-000001                                           |
+--------------------------------------------------------------------------------+
| Select Surveyor                                                                |
| Start Date | Due Date                                                          |
| Instruction                                                                    |
+--------------------------------------------------------------------------------+
| Container Selection                                                            |
| [ ] Select All                                                                 |
| [ ] MSKU1234567 - 20GP                                                         |
| [ ] TLLU7654321 - 40HC                                                         |
+--------------------------------------------------------------------------------+
| [Cancel] [Assign]                                                              |
+--------------------------------------------------------------------------------+
```

Flow:

```text
Admin pilih surveyor
↓
Pilih container
↓
Klik Assign
↓
Sistem membuat Assignment No
↓
Status container menjadi Assigned
↓
Surveyor dapat melihat di Job Saya
```

Validasi:

1. Surveyor wajib.
2. Minimal satu container dipilih.
3. Container yang sudah approved/closed tidak bisa diassign ulang.
4. Reassignment wajib alasan.

---

## 14. Surveyor Web UI Flow

Surveyor Web Module adalah bagian paling penting untuk validasi alur sebelum mobile.

## 14.1 Surveyor Job List

Route:

```text
/surveyor/jobs
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Job Saya                                                                       |
+--------------------------------------------------------------------------------+
| Search | Status Filter | Date Range                                            |
+--------------------------------------------------------------------------------+
| Job No | Customer | Location | Survey Type | Total Container | Progress | Status |
| ...                                                                            |
+--------------------------------------------------------------------------------+
```

Aksi:

| Aksi | Target |
|---|---|
| View Job | /surveyor/jobs/{id} |

Empty state:

```text
Belum ada job yang ditugaskan kepada Anda.
```

---

## 14.2 Surveyor Job Detail

Route:

```text
/surveyor/jobs/{id}
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Job Detail: GIFT-JO-2026-000001                                                |
| Customer | Location | Survey Type | Deadline | Instruction                    |
+--------------------------------------------------------------------------------+
| Container List                                                                  |
| Container No | Type | Seal | Cargo | Survey Status | Action                         |
| MSKU1234567 | 20GP | ABC  | Empty | Not Started   | [Start Survey]                 |
| TLLU7654321 | 40HC | XYZ  | Laden | Draft         | [Continue]                     |
+--------------------------------------------------------------------------------+
```

Aksi berdasarkan status:

| Status | Tombol |
|---|---|
| Not Started | Start Survey |
| Draft | Continue |
| Need Revision | Revise |
| Submitted | View Submitted |
| Approved | View Approved |

---

## 14.3 Start Survey Flow

```text
Surveyor klik Start Survey
↓
Sistem membuat Survey No
↓
Redirect ke /surveyor/surveys/{survey_id}/general
↓
Status container menjadi In Progress
↓
Status survey menjadi Draft
```

---

## 14.4 Survey Detail Layout

Route base:

```text
/surveyor/surveys/{survey_id}
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Survey: GIFT-SVY-2026-000001                                                   |
| Container: MSKU1234567 | Status: Draft | Customer: PT ABC                      |
+--------------------------------------------------------------------------------+
| Stepper/Tabs:                                                                    |
| 1. General Info                                                                  |
| 2. Checklist                                                                     |
| 3. Survey Sheet                                                                  |
| 4. Damage List                                                                   |
| 5. Photos                                                                        |
| 6. Preview                                                                       |
| 7. Submit                                                                        |
+--------------------------------------------------------------------------------+
| Content Area                                                                     |
+--------------------------------------------------------------------------------+
| Sticky Actions: [Save Draft] [Previous] [Next]                                   |
+--------------------------------------------------------------------------------+
```

Recommended behavior:

1. Tabs boleh dibuka bebas selama status Draft/Need Revision.
2. Submit tab menampilkan validasi semua step.
3. Setelah Submitted, semua field readonly.
4. Setelah Need Revision, field editable kembali dengan catatan supervisor.

---

## 14.5 General Info Tab

Route:

```text
/surveyor/surveys/{survey_id}/general
```

Layout:

```text
+--------------------------------------------------------------------------------+
| General Info                                                                    |
+--------------------------------------------------------------------------------+
| Survey No: GIFT-SVY-2026-000001       Job No: GIFT-JO-2026-000001              |
| Container No: MSKU1234567              Surveyor: Budi                           |
+--------------------------------------------------------------------------------+
| Cargo Status       | Seal No                                                    |
| Truck No           | Driver Name                                                |
| Chassis No         | CSC Plate Status                                            |
| Door Status        | General Condition                                           |
| Weather            | Survey Date Time                                            |
| General Remark                                                                  |
+--------------------------------------------------------------------------------+
| [Save Draft] [Next: Checklist]                                                   |
+--------------------------------------------------------------------------------+
```

Field behavior:

| Field | Behavior |
|---|---|
| Survey No | Readonly |
| Job No | Readonly |
| Container No | Readonly, unless permission allows correction |
| Customer | Readonly |
| Location | Readonly |
| Surveyor | Readonly |
| Cargo Status | Editable |
| Seal No | Conditional required if cargo laden |
| General Condition | Editable/recommended by system |

Validation:

1. Cargo Status wajib.
2. General Condition wajib.
3. Seal No wajib jika cargo_status = laden.

---

## 14.6 Checklist Tab

Route:

```text
/surveyor/surveys/{survey_id}/checklist
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Checklist Survey                                                                |
+--------------------------------------------------------------------------------+
| Section: General Checklist                                                      |
| Container number readable     [Yes] [No] [N/A]                                  |
| ISO code readable             [Yes] [No] [N/A]                                  |
| CSC plate available           [Yes] [No] [N/A]                                  |
| Exterior condition OK         [OK] [Not OK] [N/A]                               |
| Interior clean                [OK] [Not OK] [N/A]                               |
| Door can open/close           [OK] [Not OK] [N/A]                               |
| Floor condition OK            [OK] [Not OK] [N/A]                               |
| Roof condition OK             [OK] [Not OK] [N/A]                               |
| Light test pass               [Pass] [Fail] [Not Checked] [N/A]                 |
+--------------------------------------------------------------------------------+
| Section: Survey Type Specific Checklist                                         |
| Cargo Worthy / Gate In / Gate Out items appear based on survey type             |
+--------------------------------------------------------------------------------+
| [Save Draft] [Previous] [Next: Survey Sheet]                                    |
+--------------------------------------------------------------------------------+
```

Behavior:

1. Checklist template mengikuti survey type.
2. Item critical yang gagal menampilkan warning.
3. Jika checklist gagal mempengaruhi cargo worthy, tampilkan recommendation.

Warning example:

```text
Light test failed. System recommends result: Not Cargo Worthy / Pending Review.
```

---

## 14.7 Survey Sheet Tab

Route:

```text
/surveyor/surveys/{survey_id}/sheet
```

Layout desktop:

```text
+--------------------------------------------------------------------------------+
| Survey Sheet Interaktif                                                         |
+--------------------------------------------------------------------------------+
| Face Selector: [Left] [Right] [Front] [Door] [Roof] [Floor] [Understructure]    |
+--------------------------------------------------------------------------------+
| Main Sheet Area                                  | Damage Summary              |
|                                                  | D-001 L3 Dent Minor         |
| +------+------+------+------+                    | D-002 D2 Torn Major         |
| | L1   | L2   | L3*  | L4   |                    |                              |
| +------+------+------+------+                    |                              |
| | L5   | L6   | L7   | L8   |                    |                              |
| +------+------+------+------+                    |                              |
+--------------------------------------------------------------------------------+
| Legend: Yellow Minor | Red Major/Critical | Blue Note                         |
+--------------------------------------------------------------------------------+
```

Layout responsive:

```text
+----------------------------------+
| Face Selector horizontal scroll  |
+----------------------------------+
| Sheet/Grid                       |
+----------------------------------+
| Damage Summary                   |
+----------------------------------+
| [Add Damage Manually]            |
+----------------------------------+
```

Aksi:

| Aksi | Fungsi |
|---|---|
| Klik grid kosong | Buka modal tambah damage |
| Klik marker damage | Buka detail/edit damage |
| Add Damage Manually | Tambah damage tanpa klik grid, tetap wajib location |
| Change Face | Mengganti sisi kontainer |

---

## 14.8 Add/Edit Damage Modal

Trigger:

1. Klik grid survey sheet.
2. Klik tombol Add Damage.
3. Klik marker existing damage.

Layout:

```text
+------------------------------------------------------+
| Tambah Damage                                        |
+------------------------------------------------------+
| Location: Left Side - L3                             |
| Damage No: D-001                                     |
+------------------------------------------------------+
| Component            [Dropdown]                      |
| Damage Type          [Dropdown]                      |
| Repair Type          [Dropdown]                      |
| Material             [Dropdown]                      |
| Responsibility       [Dropdown]                      |
| Severity             [Minor/Major/Critical]          |
| Quantity             [Number]                        |
| Length               [Number] [Unit]                 |
| Width                [Number] [Unit]                 |
| Depth                [Number] [Unit]                 |
| Repair Required      [Yes/No]                        |
| Cargo Worthy Impact  [Yes/No]                        |
| Remark               [Textarea]                      |
+------------------------------------------------------+
| Photo Section                                         |
| [Upload Photo] [Take Photo - future mobile]          |
+------------------------------------------------------+
| [Cancel] [Save Damage]                               |
+------------------------------------------------------+
```

Validation:

1. Location wajib.
2. Component wajib.
3. Damage Type wajib.
4. Severity wajib.
5. Jika severity major/critical, ukuran wajib.
6. Foto wajib sebelum submit, tidak harus saat save damage.

After save:

```text
Damage saved
↓
Marker appears on survey sheet
↓
Damage appears in Damage Summary and Damage List
```

---

## 14.9 Damage List Tab

Route:

```text
/surveyor/surveys/{survey_id}/damages
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Damage List                                                   [Add Damage]      |
+--------------------------------------------------------------------------------+
| Damage No | Location | Component | Damage | Repair | Size | Severity | Photo   |
| D-001     | L3       | Side Panel| Dent   | Straighten | 30x20 | Minor | 2    |
+--------------------------------------------------------------------------------+
```

Aksi:

| Aksi | Fungsi |
|---|---|
| View | Lihat detail damage |
| Edit | Edit selama draft/revision |
| Delete | Hapus selama draft/revision |
| Add Photo | Upload foto untuk damage |

Empty state:

```text
Belum ada damage. Jika container sound, Anda dapat lanjut ke Preview.
```

---

## 14.10 Photos Tab

Route:

```text
/surveyor/surveys/{survey_id}/photos
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Photo Evidence                                                                  |
+--------------------------------------------------------------------------------+
| General Photos                                                   [Upload]       |
| [Container Number] [CSC Plate] [Exterior] [Interior] [Seal]                     |
+--------------------------------------------------------------------------------+
| Damage Photos                                                                   |
| D-001 - Left Side L3 - Dent                                      [Upload]       |
| [photo thumbnail] [photo thumbnail]                                             |
| D-002 - Door D2 - Torn                                          [Upload]        |
| [No photo warning]                                                              |
+--------------------------------------------------------------------------------+
```

Photo card:

```text
+---------------------+
| Thumbnail           |
| Caption             |
| Uploaded by         |
| Uploaded at         |
| [View] [Delete]     |
+---------------------+
```

Validation indicator:

| Kondisi | Tampilan |
|---|---|
| Damage sudah punya foto | Badge green: Photo OK |
| Damage belum punya foto | Badge red: Photo Required |

---

## 14.11 Preview Survey Tab

Route:

```text
/surveyor/surveys/{survey_id}/preview
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Preview Survey                                                                  |
+--------------------------------------------------------------------------------+
| Section: Job & Container Info                                                   |
| Section: General Info                                                           |
| Section: Checklist Summary                                                      |
| Section: Survey Sheet Marker                                                    |
| Section: Damage List                                                            |
| Section: Photo Evidence                                                         |
| Section: System Recommendation                                                  |
| Section: Validation Warning                                                     |
+--------------------------------------------------------------------------------+
| [Back] [Submit Survey]                                                          |
+--------------------------------------------------------------------------------+
```

Warning panel:

```text
Data belum lengkap:
- Damage D-002 belum memiliki foto.
- Checklist Light Test belum diisi.
- Seal No wajib untuk Laden container.
```

Submit button behavior:

| Kondisi | Submit Button |
|---|---|
| Data lengkap | Enabled |
| Data belum lengkap | Disabled atau enabled dengan modal blocking |
| Status submitted/approved | Hidden/disabled |

---

## 14.12 Submit Survey Confirmation

Trigger:

```text
Klik Submit Survey
```

Modal:

```text
+------------------------------------------------------+
| Submit Survey?                                       |
+------------------------------------------------------+
| Setelah submit, data tidak dapat diedit kecuali      |
| Supervisor mengembalikan survey sebagai Need Revision.|
+------------------------------------------------------+
| Summary:                                             |
| Container No: MSKU1234567                            |
| Damage Count: 2                                      |
| Photo Count: 5                                       |
+------------------------------------------------------+
| [Cancel] [Submit]                                    |
+------------------------------------------------------+
```

After submit:

```text
Status Draft → Submitted
↓
Redirect ke Submitted Survey detail readonly
↓
Toast: Survey berhasil disubmit
```

---

## 14.13 Need Revision Flow for Surveyor

Route:

```text
/surveyor/need-revision
/surveyor/surveys/{survey_id}
```

Revision banner:

```text
+--------------------------------------------------------------------------------+
| Need Revision                                                                   |
| Catatan Supervisor: Foto D-001 kurang jelas. Checklist Light Test belum diisi.  |
+--------------------------------------------------------------------------------+
```

Behavior:

1. Surveyor dapat edit data yang perlu diperbaiki.
2. Revision note selalu tampil di atas detail survey.
3. Submit ulang mengikuti flow submit yang sama.
4. Riwayat revisi tampil di tab timeline/revision history.

---

## 15. Supervisor Review UI Flow

## 15.1 Pending Review List

Route:

```text
/review/pending
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Pending Review                                                                  |
+--------------------------------------------------------------------------------+
| Search | Survey Type | Customer | Date Range | Damage Severity                 |
+--------------------------------------------------------------------------------+
| Survey No | Container No | Customer | Surveyor | Submitted At | Status | Action |
+--------------------------------------------------------------------------------+
```

Aksi:

| Aksi | Target |
|---|---|
| Review | /review/{survey_id} |

---

## 15.2 Review Detail Page

Route:

```text
/review/{survey_id}
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Review Survey: GIFT-SVY-2026-000001                                             |
| Container: MSKU1234567 | Status: Submitted                                      |
+--------------------------------------------------------------------------------+
| Tabs: Summary | General Info | Checklist | Survey Sheet | Damage | Photos | Log |
+--------------------------------------------------------------------------------+
| Sticky Actions: [Need Revision] [Reject] [Approve]                              |
+--------------------------------------------------------------------------------+
```

### Tab Summary

Menampilkan:

1. Job info.
2. Container info.
3. Surveyor info.
4. Final result recommendation.
5. Damage count.
6. Photo count.
7. Critical warning.

### Tab General Info

Readonly detail general info.

### Tab Checklist

Readonly checklist dengan highlight item failed/critical.

### Tab Survey Sheet

Survey sheet readonly dengan marker damage.

### Tab Damage

Table damage readonly.

### Tab Photos

Gallery foto per damage.

### Tab Log

Menampilkan submit/revision/approval history.

---

## 15.3 Need Revision Modal

Trigger:

```text
Klik Need Revision
```

Modal:

```text
+------------------------------------------------------+
| Need Revision                                        |
+------------------------------------------------------+
| Revision Note                                        |
| [Textarea wajib]                                     |
+------------------------------------------------------+
| Checklist optional:                                  |
| [ ] General info salah                               |
| [ ] Checklist belum lengkap                          |
| [ ] Damage detail salah                              |
| [ ] Foto kurang jelas                                |
| [ ] CEDEX code perlu koreksi                         |
+------------------------------------------------------+
| [Cancel] [Send Revision]                             |
+------------------------------------------------------+
```

After action:

```text
Status Submitted → Need Revision
↓
Surveyor dapat edit kembali
↓
Notification dikirim ke Surveyor
```

---

## 15.4 Approve Modal

Trigger:

```text
Klik Approve
```

Modal:

```text
+------------------------------------------------------+
| Approve Survey                                       |
+------------------------------------------------------+
| Final Result                                         |
| [Dropdown: Sound/Damage/Cargo Worthy/Not Cargo Worthy]|
| Approval Note                                        |
| [Textarea optional]                                  |
+------------------------------------------------------+
| Setelah approve, survey akan terkunci dan Report No  |
| akan dibuat.                                         |
+------------------------------------------------------+
| [Cancel] [Approve]                                   |
+------------------------------------------------------+
```

After approve:

```text
Status Submitted → Approved
↓
Report No dibuat
↓
Survey locked
↓
Redirect ke report preview/generate
```

---

## 15.5 Reject Modal

Trigger:

```text
Klik Reject
```

Modal:

```text
+------------------------------------------------------+
| Reject Survey                                        |
+------------------------------------------------------+
| Alasan Reject                                        |
| [Textarea wajib]                                     |
+------------------------------------------------------+
| Survey rejected tidak akan masuk proses invoice.      |
+------------------------------------------------------+
| [Cancel] [Reject]                                    |
+------------------------------------------------------+
```

---

## 16. Report UI Flow

## 16.1 Report Archive List

Route:

```text
/reports
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Report Archive                                                                  |
+--------------------------------------------------------------------------------+
| Search Report/Container/Customer | Date Range | Status | Export                |
+--------------------------------------------------------------------------------+
| Report No | Survey No | Container No | Customer | Version | Status | Action    |
+--------------------------------------------------------------------------------+
```

Aksi:

| Aksi | Fungsi |
|---|---|
| View | Buka detail report |
| Download PDF | Download file PDF |
| View Versions | Lihat version history |
| Validate QR | Buka halaman validasi |

---

## 16.2 Report Detail Page

Route:

```text
/reports/{id}
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Report Detail: GIFT-RPT-2026-000001                                             |
| Status: Final | Version: Rev. 0                                                  |
+--------------------------------------------------------------------------------+
| Tabs: Preview | Metadata | Versions | Related Invoice                           |
+--------------------------------------------------------------------------------+
| [Download PDF] [Generate New Revision] [Print]                                  |
+--------------------------------------------------------------------------------+
```

Preview area:

```text
Embedded PDF viewer or report HTML preview
```

---

## 16.3 Generate Report Flow

Trigger:

1. Supervisor approve survey.
2. Admin/Supervisor klik Generate Report.

Flow:

```text
Survey Approved
↓
Klik Generate Report
↓
Backend queue generate PDF
↓
Status: Generating
↓
Jika selesai: Report Generated
↓
PDF available for download
```

UI state:

| Status | Tampilan |
|---|---|
| Generating | Spinner/progress |
| Generated | Download button active |
| Failed | Retry generate |

---

## 16.4 QR Validation Page

Public/limited route:

```text
/reports/validate/{qr_token}
```

Layout:

```text
+------------------------------------------------------+
| Report Validation                                    |
+------------------------------------------------------+
| Status: VALID                                        |
| Report No                                            |
| Container No                                         |
| Customer                                             |
| Survey Date                                          |
| Surveyor                                             |
| Approver                                             |
+------------------------------------------------------+
| [Download PDF] if allowed                            |
+------------------------------------------------------+
```

---

## 17. Finance UI Flow

## 17.1 Ready to Invoice List

Route:

```text
/finance/ready-to-invoice
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Ready to Invoice                                                                |
+--------------------------------------------------------------------------------+
| Search | Customer | Survey Type | Date Range                                    |
+--------------------------------------------------------------------------------+
| Select | Report No | Job No | Customer | Total Container | Survey Type | Action   |
+--------------------------------------------------------------------------------+
| [Create Invoice from Selected]                                                  |
+--------------------------------------------------------------------------------+
```

Aksi:

| Aksi | Fungsi |
|---|---|
| Create Invoice | Membuat invoice dari report/job selected |
| View Report | Buka report readonly |

---

## 17.2 Price List Page

Route:

```text
/finance/price-list
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Price List                                                   [Add Price]        |
+--------------------------------------------------------------------------------+
| Customer | Survey Type | Container Type | Unit Price | Currency | Status | Action |
+--------------------------------------------------------------------------------+
```

Add/Edit modal:

```text
Customer optional
Survey Type
Container Type optional
Unit Price
Currency
Tax Type
Effective Date
Status
```

---

## 17.3 Create Invoice Page

Route:

```text
/finance/invoices/create
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Create Invoice                                                                  |
+--------------------------------------------------------------------------------+
| Section: Customer & Billing                                                     |
| Customer | Billing Address | Invoice Date | Payment Term | Due Date              |
+--------------------------------------------------------------------------------+
| Section: Source Reports/Jobs                                                    |
| Report No | Job No | Survey Type | Container Count                              |
+--------------------------------------------------------------------------------+
| Section: Invoice Items                                                          |
| Description | Qty | Unit Price | Tax | Discount | Total                           |
+--------------------------------------------------------------------------------+
| Summary: Subtotal | Tax | Discount | Grand Total                                |
+--------------------------------------------------------------------------------+
| [Cancel] [Save Draft] [Issue Invoice]                                           |
+--------------------------------------------------------------------------------+
```

Behavior:

1. Customer auto-filled from selected report/job.
2. Item bisa auto-filled dari price list.
3. Finance bisa menyesuaikan description/unit price sesuai permission.
4. Grand total dihitung otomatis.

Validation:

1. Customer wajib.
2. Minimal satu invoice item.
3. Qty wajib > 0.
4. Unit price wajib >= 0.

---

## 17.4 Invoice List Page

Route:

```text
/finance/invoices
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Invoice List                                                [Create Invoice]    |
+--------------------------------------------------------------------------------+
| Search | Customer | Status | Date Range | Export                                |
+--------------------------------------------------------------------------------+
| Invoice No | Customer | Date | Due Date | Total | Paid | Status | Action       |
+--------------------------------------------------------------------------------+
```

Aksi:

| Aksi | Fungsi |
|---|---|
| View | Detail invoice |
| Download PDF | Download invoice PDF |
| Add Payment | Catat pembayaran |
| Cancel | Batalkan invoice |

---

## 17.5 Invoice Detail Page

Route:

```text
/finance/invoices/{id}
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Invoice Detail: GIFT-INV-2026-000001                                            |
| Status: Unpaid                                                                  |
+--------------------------------------------------------------------------------+
| Customer & Billing Info                                                         |
| Invoice Items                                                                   |
| Payment History                                                                 |
| Related Reports                                                                 |
+--------------------------------------------------------------------------------+
| [Download PDF] [Add Payment] [Cancel Invoice]                                   |
+--------------------------------------------------------------------------------+
```

---

## 17.6 Add Payment Modal

Trigger:

```text
Klik Add Payment
```

Modal:

```text
+------------------------------------------------------+
| Add Payment                                          |
+------------------------------------------------------+
| Payment Date                                         |
| Amount                                               |
| Payment Method                                       |
| Bank Account                                         |
| Proof File                                           |
| Note                                                 |
+------------------------------------------------------+
| [Cancel] [Save Payment]                              |
+------------------------------------------------------+
```

After payment:

```text
Payment saved
↓
Invoice status recalculated:
- Partial Paid
- Paid
- Unpaid
```

---

## 17.7 Outstanding Page

Route:

```text
/finance/outstanding
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Outstanding Invoice                                                             |
+--------------------------------------------------------------------------------+
| Customer | Invoice No | Due Date | Aging | Total | Paid | Remaining | Status    |
+--------------------------------------------------------------------------------+
```

Aging badge:

| Aging | Badge |
|---|---|
| 0-7 days | Yellow |
| 8-30 days | Orange |
| >30 days | Red |

---

## 18. Management UI Flow

## 18.1 Job Recap

Route:

```text
/management/job-recap
```

Konten:

1. Filter periode.
2. Total job.
3. Total container.
4. Job per status.
5. Job per customer.
6. Export.

## 18.2 Surveyor Recap

Route:

```text
/management/surveyor-recap
```

Konten:

1. Surveyor name.
2. Total job assigned.
3. Total container completed.
4. Average completion time.
5. Need revision count.

## 18.3 Damage Recap

Route:

```text
/management/damage-recap
```

Konten:

1. Damage by type.
2. Damage by component.
3. Damage by severity.
4. Damage by location.
5. Damage by customer.

## 18.4 Revenue Recap

Route:

```text
/management/revenue-recap
```

Konten:

1. Revenue by month.
2. Outstanding by customer.
3. Paid/unpaid invoice.
4. Export finance summary.

---

## 19. Audit Log UI Flow

Route:

```text
/settings/audit-log
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Audit Log                                                                       |
+--------------------------------------------------------------------------------+
| User | Action | Entity | Date Range | Search                                    |
+--------------------------------------------------------------------------------+
| Time | User | Action | Entity Type | Entity ID | IP | Action                    |
+--------------------------------------------------------------------------------+
```

Detail modal:

```text
+------------------------------------------------------+
| Audit Detail                                         |
+------------------------------------------------------+
| User                                                 |
| Action                                               |
| Entity Type                                          |
| Entity ID                                            |
| Old Value                                            |
| New Value                                            |
| IP Address                                           |
| User Agent                                           |
| Created At                                           |
+------------------------------------------------------+
```

---

## 20. Notification UI Flow

### 20.1 Notification Dropdown

Topbar notification icon:

```text
Bell Icon with badge count
```

Dropdown:

```text
+------------------------------------------------------+
| Notifications                                        |
+------------------------------------------------------+
| Job assigned: GIFT-JO-2026-000001                    |
| Survey submitted: GIFT-SVY-2026-000001               |
| Survey need revision                                 |
+------------------------------------------------------+
| [View All]                                           |
+------------------------------------------------------+
```

### 20.2 Notification List Page

Route:

```text
/notifications
```

Layout:

```text
+--------------------------------------------------------------------------------+
| Notifications                                                                   |
+--------------------------------------------------------------------------------+
| Filter: All/Unread/Read                                                         |
+--------------------------------------------------------------------------------+
| Title | Message | Created At | Status | Action                                  |
+--------------------------------------------------------------------------------+
```

---

## 21. File Upload UI Standard

### 21.1 Upload Component

```text
+------------------------------------------------------+
| Drag and drop file here                              |
| or                                                   |
| [Choose File]                                        |
+------------------------------------------------------+
| Allowed: jpg, jpeg, png, pdf                         |
| Max size: configurable                               |
+------------------------------------------------------+
```

### 21.2 Upload State

| State | UI |
|---|---|
| Idle | Choose File |
| Uploading | Progress bar |
| Success | Thumbnail/file name |
| Failed | Retry button |
| Invalid | Error message |

---

## 22. Data Table Standard

Semua tabel list harus memiliki:

1. Search.
2. Filter.
3. Sort.
4. Pagination.
5. Row action.
6. Bulk action jika diperlukan.
7. Empty state.
8. Export jika relevan.

### 22.1 Generic Table Layout

```text
+--------------------------------------------------------------------------------+
| Search... | Filter | Date Range | Export                                       |
+--------------------------------------------------------------------------------+
| Checkbox | Column 1 | Column 2 | Column 3 | Status | Action                    |
+--------------------------------------------------------------------------------+
| Pagination                                                                     |
+--------------------------------------------------------------------------------+
```

---

## 23. Form Standard

### 23.1 Required Field Marker

Field wajib diberi tanda:

```text
Customer Name *
```

### 23.2 Error Message

Error field tampil tepat di bawah field.

```text
Container No wajib diisi.
```

### 23.3 Save Button State

| Kondisi | Button |
|---|---|
| Form clean | Disabled optional |
| Form dirty | Enabled |
| Submitting | Loading |
| Success | Redirect/toast |
| Error | Tampilkan error |

---

## 24. Status Transition UI

### 24.1 Survey Status Transition

```text
Draft
↓ Submit
Submitted
↓ Need Revision
Need Revision
↓ Submit ulang
Submitted
↓ Approve
Approved
↓ Generate Report
Report Generated
```

UI rules:

| Status | Editable by Surveyor | Action Supervisor |
|---|---:|---|
| Draft | Ya | Tidak |
| Submitted | Tidak | Approve/Need Revision/Reject |
| Need Revision | Ya | Tidak sampai submit ulang |
| Approved | Tidak | Generate Report |
| Report Generated | Tidak | View only |

### 24.2 Job Status Transition

```text
Draft
↓ Add Container
Draft
↓ Assign Surveyor
Assigned
↓ Surveyor starts
In Progress
↓ All submitted
All Survey Submitted
↓ All approved
All Survey Approved
↓ Report generated
Report Generated
↓ Finance ready
Ready to Invoice
↓ Invoice issued
Invoiced
↓ Paid
Paid
↓ Close
Closed
```

---

## 25. Route List Summary

### 25.1 Auth

```text
/login
/forgot-password
/reset-password
```

### 25.2 Dashboard

```text
/dashboard/admin
/dashboard/surveyor
/dashboard/supervisor
/finance/dashboard
/management/dashboard
```

### 25.3 Master Data

```text
/master/customers
/master/customers/create
/master/customers/{id}
/master/locations
/master/surveyors
/master/container-types
/master/survey-types
/master/cedex/locations
/master/cedex/components
/master/cedex/damages
/master/cedex/repairs
/master/cedex/materials
/master/responsibility-codes
```

### 25.4 Job

```text
/jobs
/jobs/create
/jobs/{id}
/jobs/{id}/edit
/jobs/{id}/containers/add
/jobs/{id}/containers/import
/jobs/{id}/assign
/jobs/{id}/timeline
```

### 25.5 Surveyor Web

```text
/surveyor/jobs
/surveyor/jobs/{id}
/surveyor/surveys/{survey_id}/general
/surveyor/surveys/{survey_id}/checklist
/surveyor/surveys/{survey_id}/sheet
/surveyor/surveys/{survey_id}/damages
/surveyor/surveys/{survey_id}/photos
/surveyor/surveys/{survey_id}/preview
/surveyor/drafts
/surveyor/submitted
/surveyor/need-revision
/surveyor/history
```

### 25.6 Review

```text
/review/pending
/review/{survey_id}
/review/need-revision
/review/approved
```

### 25.7 Report

```text
/reports
/reports/{id}
/reports/{id}/versions
/reports/validate/{qr_token}
```

### 25.8 Finance

```text
/finance/ready-to-invoice
/finance/price-list
/finance/invoices
/finance/invoices/create
/finance/invoices/{id}
/finance/payments
/finance/outstanding
/finance/recap-customer
```

### 25.9 Management

```text
/management/job-recap
/management/surveyor-recap
/management/customer-recap
/management/damage-recap
/management/revenue-recap
```

### 25.10 Setting

```text
/settings/users
/settings/roles
/settings/company-profile
/settings/numbering
/settings/report-template
/settings/audit-log
/settings/system
```

---

## 26. Mobile App Future UI Flow Summary

Mobile app dibuat setelah web surveyor flow stabil.

### 26.1 Mobile Main Navigation

```text
Login
Dashboard
Job Saya
Draft
Need Revision
History
Profile
Sync Status
```

### 26.2 Mobile Survey Flow

```text
Login
↓
Download assigned job
↓
Job Saya
↓
Pilih Job
↓
Pilih Container
↓
General Info
↓
Checklist
↓
Survey Sheet
↓
Input Damage
↓
Camera Photo
↓
Preview
↓
Submit / Save Offline
↓
Sync to API
```

### 26.3 Mobile-Specific UI Requirements

1. Bottom navigation lebih cocok daripada sidebar.
2. Stepper survey harus ringkas.
3. Tombol utama sticky di bawah.
4. Foto langsung dari kamera.
5. Status sync selalu terlihat.
6. Draft offline harus jelas.
7. Upload queue harus terlihat.

---

## 27. QA Checklist UI Flow

| Area | Checklist |
|---|---|
| Login | User redirect sesuai role |
| Sidebar | Menu tampil sesuai permission |
| Dashboard | Data ringkasan tampil benar |
| Master Data | CRUD berjalan dan validasi tampil |
| Job Order | Create job menghasilkan job no |
| Container | Add/import container validasi duplicate |
| Assignment | Surveyor hanya melihat assigned job |
| Survey General | Field wajib tervalidasi |
| Checklist | Template sesuai survey type |
| Survey Sheet | Klik grid membuka damage modal |
| Damage | Damage muncul di marker dan damage list |
| Photo | Foto damage terhubung ke damage |
| Preview | Warning tampil jika data belum lengkap |
| Submit | Submit ditolak jika belum valid |
| Review | Supervisor bisa approve/need revision/reject |
| Revision | Surveyor bisa edit saat Need Revision |
| Report | Report generated setelah approve |
| Finance | Invoice hanya dari approved/generated report |
| Payment | Payment mengubah status invoice |
| Audit Log | Aktivitas penting tercatat |
| Responsive | Halaman utama tetap usable di tablet/mobile web |

---

## 28. Catatan Implementasi Frontend

### 28.1 Komponen yang Sebaiknya Dibuat Reusable

1. StatusBadge
2. DataTable
3. FilterBar
4. PageHeader
5. Breadcrumb
6. FormCard
7. ConfirmDialog
8. UploadBox
9. PhotoGallery
10. SurveySheetGrid
11. DamageModal
12. ChecklistItem
13. RevisionBanner
14. Timeline
15. MoneyInput
16. DateRangePicker

### 28.2 Survey Sheet Grid Component

Komponen `SurveySheetGrid` harus menerima props:

```text
face
locations[]
damages[]
readonly
onLocationClick
onMarkerClick
```

Output:

1. Grid sesuai face.
2. Marker damage.
3. Severity color.
4. Click handler.

### 28.3 Damage Modal Component

Komponen `DamageModal` harus bisa dipakai untuk:

1. Add damage.
2. Edit damage.
3. View readonly damage.

Props utama:

```text
mode: create/edit/view
surveyId
location
initialData
masterComponent
masterDamage
masterRepair
masterMaterial
masterResponsibility
onSave
onClose
```

---

## 29. Catatan Desain Visual

Rekomendasi gaya UI:

1. Bersih dan profesional.
2. Warna status konsisten.
3. Tabel mudah dibaca.
4. Form tidak terlalu padat.
5. Gunakan tab/stepper untuk proses panjang.
6. Gunakan card untuk detail data.
7. Gunakan sticky action untuk halaman survey.
8. Foto damage harus tampil cukup besar saat review.
9. Warning dan error harus terlihat jelas.
10. Jangan menyembunyikan status penting.

---

## 30. Kesimpulan UI Flow

Alur UI web MVP dibangun untuk menjalankan seluruh proses bisnis dari awal sampai akhir:

```text
Login
↓
Setup sistem
↓
Master data
↓
Job order
↓
Assignment
↓
Surveyor web mengisi survey
↓
Damage dan foto
↓
Submit
↓
Supervisor review
↓
Approve / Need Revision
↓
Generate report
↓
Finance invoice
↓
Payment
↓
Closed
```

Dokumen ini menetapkan bahwa Surveyor Web Module harus dibuat cukup lengkap untuk memvalidasi alur, tetapi desainnya harus tetap mobile-ready agar nanti dapat dikembangkan menjadi Flutter Mobile Application tanpa mengubah backend API, database, dan workflow utama.
