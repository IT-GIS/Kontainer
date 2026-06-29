# PRD.md â€” Container Survey Management System

**Nama Produk:** Container Survey Management System  
**Perusahaan/Unit:** GIFT / PT Global Inspeksi Sertifikasi Group  
**Dokumen:** Product Requirements Document (PRD)  
**Versi:** 1.0  
**Tanggal:** 23 Juni 2026  
**Status:** Draft lengkap untuk perencanaan development  

---

## 1. Ringkasan Produk

Container Survey Management System adalah aplikasi untuk membantu perusahaan survey kontainer dalam mengelola pekerjaan survey dari awal sampai akhir, mulai dari pembuatan job order, penugasan surveyor, pengisian survey sheet, pencatatan damage, upload foto bukti, review supervisor, generate laporan PDF, hingga proses invoice oleh finance.

Pada tahap awal, seluruh role akan dibuat dalam **Web Application**, termasuk menu Surveyor. Menu Surveyor di web digunakan sebagai **validasi alur, MVP awal, demo internal, dan pengujian proses bisnis**, bukan sebagai target akhir utama untuk penggunaan lapangan jangka panjang.

Pada tahap lanjutan, role Surveyor akan dikembangkan menjadi **Mobile Application** agar lebih optimal untuk pekerjaan lapangan, terutama untuk kamera, GPS, offline draft, sync data, upload foto background, dan performa mobile yang ringan.

---

## 2. Tujuan Produk

Tujuan utama aplikasi:

1. Mempermudah Admin/Operasional dalam membuat job order survey kontainer.
2. Mempermudah penugasan surveyor berdasarkan job dan daftar kontainer.
3. Mempermudah Surveyor mengisi data survey secara terstruktur.
4. Mempermudah pencatatan kerusakan kontainer melalui survey sheet interaktif.
5. Memastikan setiap damage memiliki data teknis, CEDEX code, ukuran, foto, dan catatan.
6. Memastikan hasil survey direview oleh Supervisor sebelum menjadi laporan final.
7. Menghasilkan laporan PDF secara otomatis dan konsisten.
8. Mempermudah Finance membuat invoice dari job yang sudah disetujui.
9. Menyimpan arsip survey, foto, laporan, invoice, dan audit log secara rapi.
10. Menyiapkan fondasi API dan data agar nantinya mobile app surveyor bisa dibuat tanpa mengubah alur utama.

---

## 3. Prinsip Desain Produk

Aplikasi harus mengikuti prinsip berikut:

1. **Satu sistem pusat**: Web app dan mobile app nantinya memakai backend API dan database yang sama.
2. **Web dulu, mobile kemudian**: Semua alur divalidasi di web sebelum dikembangkan ke mobile.
3. **Surveyor web bukan final lapangan**: Menu Surveyor di web adalah prototype/MVP alur.
4. **Data teknis dan administrasi dipisah**: Nomor job/report/invoice tidak dicampur dengan CEDEX code.
5. **Dropdown lebih diutamakan daripada input bebas**: Agar data survey konsisten.
6. **Foto harus terhubung ke damage**: Foto tidak boleh hanya menjadi lampiran bebas tanpa relasi damage.
7. **Approval wajib sebelum report final**: Data survey tidak boleh langsung menjadi laporan final tanpa review.
8. **Finance tidak boleh mengubah data teknis survey**: Finance hanya menggunakan data yang sudah approved.
9. **Audit trail wajib**: Semua perubahan penting harus tercatat.
10. **Mobile-ready architecture**: Walaupun MVP di web, API dan database harus siap dipakai mobile.

---

## 4. Scope Produk

### 4.1 Scope MVP Web Application

MVP web mencakup:

1. Login dan role-based access.
2. Super Admin setting.
3. Master data.
4. Master CEDEX.
5. Numbering setting.
6. Job order.
7. Input/import container.
8. Assignment surveyor.
9. Surveyor web module.
10. General survey form.
11. Checklist survey.
12. Survey sheet interaktif.
13. Damage input.
14. Upload photo evidence.
15. Submit survey.
16. Review dan approval supervisor.
17. Revisi survey.
18. Generate report PDF.
19. Report archive.
20. Finance ready-to-invoice.
21. Invoice.
22. Payment.
23. Dashboard dasar.
24. Audit log.

### 4.2 Scope Future Mobile Application

Mobile app surveyor akan mencakup:

1. Login surveyor.
2. Job saya.
3. Detail job.
4. Pilih container.
5. General info.
6. Checklist.
7. Survey sheet interaktif.
8. Damage input.
9. Kamera langsung.
10. GPS location.
11. Watermark foto.
12. Offline draft.
13. Local storage.
14. Background upload.
15. Sync data.
16. Riwayat survey.
17. Revisi survey.

### 4.3 Di luar Scope MVP

Fitur berikut tidak wajib di MVP:

1. OCR nomor kontainer.
2. AI damage detection.
3. Customer portal.
4. WhatsApp gateway.
5. Integrasi accounting.
6. Integrasi e-signature pihak ketiga.
7. Native mobile iOS penuh.
8. Advanced analytics detail.
9. Repair estimate dengan costing lengkap.
10. API integrasi dengan sistem customer/depot eksternal.

---

## 5. Platform dan Arsitektur

### 5.1 Platform

Sistem terdiri dari:

1. **Web Application**  
   Digunakan oleh Super Admin, Admin, Surveyor tahap awal, Supervisor, Finance, dan Management.

2. **Mobile Application**  
   Direncanakan untuk Surveyor pada tahap lanjutan sebagai aplikasi lapangan.

3. **Backend API**  
   Menjadi pusat proses bisnis dan endpoint untuk web serta mobile.

4. **Database**  
   Menyimpan data master, transaksi, survey, approval, finance, dan audit log.

5. **Object Storage**  
   Menyimpan foto survey, foto damage, dokumen PDF, invoice PDF, dan bukti pembayaran.

6. **Queue/Cache**  
   Digunakan untuk proses berat seperti generate PDF, compress/watermark foto, notifikasi, dan cache data master.

### 5.2 Stack Teknologi Rekomendasi

Karena tidak menggunakan PHP, stack yang direkomendasikan adalah:

| Komponen | Teknologi |
|---|---|
| Web Application | Next.js + TypeScript |
| Mobile Application tahap lanjutan | Flutter |
| Backend API | Go + Gin atau Go + Fiber |
| Database | MySQL |
| Local DB Mobile | SQLite |
| Object Storage | MinIO / S3-compatible storage |
| Cache & Queue | Redis |
| Deployment | Docker + Nginx + Ubuntu Server |
| API Style | REST API |
| Auth | JWT access token + refresh token |
| PDF Generation | Server-side PDF generator |
| File Upload | Multipart upload ke backend lalu storage |

### 5.3 Arsitektur Tingkat Tinggi

```text
[Web Application - Next.js]
Admin / Surveyor Web / Supervisor / Finance / Management
        |
        | HTTPS REST API
        v
[Backend API - Go]
        |
        |---------------------|----------------------|
        v                     v                      v
[MySQL]              [Redis]               [MinIO/S3]
Database                  Cache/Queue           Foto & PDF

[Mobile App - Flutter, Future Phase]
Surveyor Lapangan
        |
        | HTTPS REST API
        v
[Backend API yang sama]
```

---

## 6. Role Pengguna

### 6.1 Super Admin

Super Admin adalah role tertinggi yang mengatur sistem.

Fungsi:

1. Mengelola user.
2. Mengatur role dan permission.
3. Mengatur profil perusahaan.
4. Mengatur format penomoran dokumen.
5. Mengatur master data global.
6. Mengatur template report.
7. Melihat audit log.
8. Mengatur system setting.

### 6.2 Admin / Operasional

Admin menjalankan proses operasional survey.

Fungsi:

1. Mengelola customer.
2. Mengelola lokasi.
3. Mengelola surveyor.
4. Mengelola master container type.
5. Mengelola master survey type.
6. Mengelola master CEDEX.
7. Membuat job order.
8. Input/import daftar container.
9. Assign surveyor.
10. Monitoring status survey.
11. Melihat report archive.
12. Export data.

### 6.3 Surveyor

Surveyor melakukan input hasil survey. Pada MVP, role ini tersedia di web untuk validasi alur. Pada tahap lanjutan, role ini akan dipindahkan/dikembangkan ke mobile app.

Fungsi:

1. Melihat job yang ditugaskan.
2. Memilih container.
3. Mengisi general info.
4. Mengisi checklist.
5. Menggunakan survey sheet interaktif.
6. Input damage.
7. Upload foto evidence.
8. Preview survey.
9. Submit survey.
10. Memperbaiki survey jika ada revisi.
11. Melihat riwayat survey.

### 6.4 Supervisor / Approver

Supervisor melakukan review kualitas data survey.

Fungsi:

1. Melihat pending review.
2. Membuka detail survey.
3. Mengecek checklist.
4. Mengecek survey sheet.
5. Mengecek damage list.
6. Mengecek CEDEX code.
7. Mengecek foto.
8. Approve survey.
9. Mengembalikan survey untuk revisi.
10. Generate/finalisasi report.

### 6.5 Finance

Finance mengelola invoice dan pembayaran.

Fungsi:

1. Melihat job/report yang siap invoice.
2. Mengelola price list.
3. Membuat invoice.
4. Mencatat pembayaran.
5. Melihat outstanding.
6. Export laporan finance.
7. Melihat invoice status.

Finance tidak boleh mengubah data teknis survey.

### 6.6 Management

Management melihat dashboard dan rekap.

Fungsi:

1. Melihat jumlah job.
2. Melihat jumlah container disurvey.
3. Melihat performa surveyor.
4. Melihat customer aktif.
5. Melihat damage terbanyak.
6. Melihat revenue dan outstanding.
7. Export laporan management.

---

## 7. Menu Aplikasi Web

### 7.1 Sidebar Global

Menu lengkap web app:

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

### 7.2 Menu Berdasarkan Role

#### Super Admin

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

#### Admin / Operasional

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

#### Surveyor Web

```text
Dashboard Surveyor
Job Saya
Detail Job
Pilih Container
General Info
Checklist Survey
Survey Sheet Interaktif
Damage Input
Photo Evidence
Preview Survey
Submit Survey
Draft Survey
Need Revision
Riwayat Survey
```

#### Supervisor

```text
Dashboard Review
Pending Review
Detail Survey
Need Revision
Approved Survey
Report Preview
Final Report
```

#### Finance

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

#### Management

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

## 8. Alur Menyeluruh Web Application

### 8.1 Alur Utama End-to-End

```text
Super Admin setup sistem
â†“
Admin input master data
â†“
Admin buat job order
â†“
Admin input/import container
â†“
Admin assign surveyor
â†“
Surveyor web buka job saya
â†“
Surveyor pilih container
â†“
Surveyor isi general info
â†“
Surveyor isi checklist
â†“
Surveyor klik survey sheet
â†“
Surveyor input damage
â†“
Surveyor upload foto
â†“
Surveyor preview survey
â†“
Surveyor submit
â†“
Supervisor review
â†“
Jika salah: Need Revision
â†“
Surveyor revisi
â†“
Submit ulang
â†“
Supervisor approve
â†“
Sistem generate report PDF
â†“
Finance create invoice
â†“
Finance input payment
â†“
Job closed
```

### 8.2 Alur Super Admin

```text
Login
â†“
Buat role dan permission
â†“
Buat user admin/surveyor/supervisor/finance/management
â†“
Atur profil perusahaan
â†“
Atur numbering setting
â†“
Atur template report
â†“
Sistem siap dipakai
```

### 8.3 Alur Admin

```text
Login
â†“
Input master data
â†“
Buat job order
â†“
Input daftar container
â†“
Assign surveyor
â†“
Monitoring survey
â†“
Lihat status submitted/approved/report generated
```

### 8.4 Alur Surveyor Web

```text
Login
â†“
Job Saya
â†“
Pilih job
â†“
Pilih container
â†“
Sistem membuat survey no
â†“
Isi general info
â†“
Isi checklist
â†“
Klik survey sheet
â†“
Input damage
â†“
Upload foto
â†“
Preview
â†“
Submit
```

### 8.5 Alur Supervisor

```text
Login
â†“
Pending Review
â†“
Buka detail survey
â†“
Cek general info, checklist, damage, foto
â†“
Approve atau Need Revision
â†“
Jika approve, report bisa digenerate
```

### 8.6 Alur Finance

```text
Login
â†“
Ready to Invoice
â†“
Pilih report/job approved
â†“
Create invoice
â†“
Input item dan harga
â†“
Issue invoice
â†“
Catat payment
â†“
Status invoice paid
```

---

## 9. Modul Authentication dan Authorization

### 9.1 Login

Field:

| Field | Wajib | Keterangan |
|---|---:|---|
| Email/Username | Ya | Identitas user |
| Password | Ya | Password user |
| Remember Me | Tidak | Menyimpan session |

### 9.2 Logout

User dapat logout dari aplikasi. Token/session dihapus.

### 9.3 Forgot Password

Fitur reset password dapat disiapkan dengan email atau reset manual oleh Super Admin.

### 9.4 Role-Based Access Control

Setiap user hanya dapat mengakses menu sesuai role.

### 9.5 Session dan Token

1. Web app menggunakan token/session aman.
2. Backend API mendukung JWT access token dan refresh token.
3. Token memiliki expiry time.
4. Refresh token dapat dicabut saat logout.

---

## 10. Modul Dashboard

### 10.1 Dashboard Admin

Menampilkan:

| Indikator | Keterangan |
|---|---|
| Total Job Hari Ini | Job dibuat hari ini |
| Draft Job | Job belum assigned |
| Assigned Job | Job sudah assigned |
| In Progress | Survey sedang dikerjakan |
| Submitted | Survey menunggu review |
| Need Revision | Survey perlu perbaikan |
| Approved | Survey disetujui |
| Report Generated | Report sudah dibuat |
| Ready to Invoice | Siap ditagih |
| Surveyor Aktif | Surveyor yang punya tugas |

### 10.2 Dashboard Surveyor

Menampilkan:

| Indikator | Keterangan |
|---|---|
| Job Saya | Total job milik surveyor |
| Belum Mulai | Container belum dikerjakan |
| Draft | Survey belum submit |
| Need Revision | Survey dikembalikan |
| Submitted | Survey sudah dikirim |
| Approved | Survey disetujui |

### 10.3 Dashboard Supervisor

Menampilkan:

| Indikator | Keterangan |
|---|---|
| Pending Review | Survey menunggu review |
| Need Revision | Survey dikembalikan |
| Approved Today | Survey approved hari ini |
| Critical Damage | Damage critical yang perlu perhatian |

### 10.4 Dashboard Finance

Menampilkan:

| Indikator | Keterangan |
|---|---|
| Ready to Invoice | Report siap invoice |
| Invoice Bulan Ini | Jumlah invoice |
| Paid | Invoice lunas |
| Unpaid | Invoice belum lunas |
| Overdue | Invoice lewat jatuh tempo |
| Outstanding Amount | Total piutang |

### 10.5 Dashboard Management

Menampilkan:

| Indikator | Keterangan |
|---|---|
| Total Job Periode | Job berdasarkan periode |
| Total Container | Jumlah container disurvey |
| Top Customer | Customer terbanyak |
| Top Surveyor | Surveyor paling produktif |
| Top Damage | Damage terbanyak |
| Revenue | Pendapatan |
| Outstanding | Piutang |

---

## 11. Modul Master Data

### 11.1 Master Customer

Field:

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| customer_code | string | Ya | Otomatis/manual |
| customer_name | string | Ya | Nama customer |
| address | text | Tidak | Alamat customer |
| npwp | string | Tidak | NPWP |
| pic_name | string | Tidak | Nama PIC |
| pic_phone | string | Tidak | Nomor PIC |
| pic_email | string | Tidak | Email PIC |
| billing_address | text | Tidak | Alamat tagihan |
| payment_term_days | integer | Tidak | Termin pembayaran |
| status | enum | Ya | active/inactive |

### 11.2 Master Location

Field:

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| location_code | string | Ya | Kode lokasi |
| location_name | string | Ya | Nama lokasi |
| location_type | enum | Ya | depot/yard/port/warehouse/factory/other |
| address | text | Tidak | Alamat |
| city | string | Tidak | Kota |
| gps_latitude | decimal | Tidak | Latitude |
| gps_longitude | decimal | Tidak | Longitude |
| pic_name | string | Tidak | PIC lokasi |
| pic_phone | string | Tidak | Kontak PIC |
| status | enum | Ya | active/inactive |

### 11.3 Master Surveyor

Field:

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| surveyor_code | string | Ya | Kode surveyor |
| user_id | uuid/integer | Ya | Relasi user login |
| name | string | Ya | Nama surveyor |
| phone | string | Tidak | Nomor HP |
| area | string | Tidak | Area kerja |
| signature_file | file path | Tidak | Tanda tangan |
| status | enum | Ya | active/inactive |

### 11.4 Master Container Type

Field:

| Field | Tipe | Wajib | Contoh |
|---|---|---:|---|
| code | string | Ya | 20GP |
| iso_code | string | Tidak | 22G1 |
| size | string | Ya | 20 Feet |
| type | string | Ya | General Purpose |
| description | text | Tidak | Dry container |
| status | enum | Ya | active/inactive |

Contoh data:

| Code | ISO Code | Size | Type |
|---|---|---|---|
| 20GP | 22G1 | 20 Feet | General Purpose |
| 40GP | 42G1 | 40 Feet | General Purpose |
| 40HC | 45G1 | 40 Feet | High Cube |
| 20RF | 22R1 | 20 Feet | Reefer |
| 40RF | 45R1 | 40 Feet | Reefer |

### 11.5 Master Survey Type

Contoh data:

| Code | Survey Type | Keterangan |
|---|---|---|
| GI | Gate In Survey | Saat container masuk yard/depot |
| GO | Gate Out Survey | Saat container keluar yard/depot |
| DS | Damage Survey | Survey khusus kerusakan |
| CW | Cargo Worthy Survey | Penilaian layak muat |
| CL | Cleanliness Survey | Survey kebersihan |
| ONH | On Hire Survey | Awal sewa/pakai |
| OFH | Off Hire Survey | Akhir sewa/pakai |
| STUF | Stuffing Survey | Saat muat barang |
| STRP | Stripping Survey | Saat bongkar barang |
| PTI | Pre-Trip Inspection | Khusus reefer, future phase |

---

## 12. Modul Master CEDEX

CEDEX tidak dibuat sebagai satu nomor tunggal. CEDEX disimpan sebagai kombinasi kode pada setiap baris damage.

### 12.1 Struktur CEDEX

Master CEDEX terdiri dari:

1. CEDEX Location Code.
2. CEDEX Component Code.
3. CEDEX Damage Code.
4. CEDEX Repair Code.
5. CEDEX Material Code.
6. Responsibility Code.

### 12.2 CEDEX Location Code

Field:

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| code | string | Ya | L1, L2, D1, T1, dst |
| face | enum | Ya | left/right/front/door/roof/floor/understructure |
| grid_code | string | Ya | Kode grid UI |
| cedex_mapping_code | string | Tidak | Mapping CEDEX teknis |
| container_size | enum | Tidak | all/20/40/45 |
| description | text | Tidak | Deskripsi lokasi |
| status | enum | Ya | active/inactive |

Contoh:

| Code | Face | Description |
|---|---|---|
| L1 | Left Side | Left side section 1 |
| L2 | Left Side | Left side section 2 |
| R1 | Right Side | Right side section 1 |
| D1 | Door End | Door area section 1 |
| F1 | Front End | Front section 1 |
| T1 | Roof | Roof section 1 |
| FL1 | Floor | Floor section 1 |
| U1 | Understructure | Understructure section 1 |

### 12.3 CEDEX Component Code

Field:

| Field | Tipe | Wajib |
|---|---|---:|
| code | string | Ya |
| component_name | string | Ya |
| description | text | Tidak |
| status | enum | Ya |

Contoh component:

| Code | Component |
|---|---|
| SP | Side Panel |
| RP | Roof Panel |
| FP | Front Panel |
| DP | Door Panel |
| DG | Door Gasket |
| LB | Locking Bar |
| CK | Cam Keeper |
| FB | Floor Board |
| CM | Cross Member |
| CP | Corner Post |
| CC | Corner Casting |
| BSR | Bottom Side Rail |
| TSR | Top Side Rail |
| FKP | Forklift Pocket |
| VN | Ventilator |
| CSC | CSC Plate |

### 12.4 CEDEX Damage Code

Contoh damage:

| Code | Damage |
|---|---|
| DT | Dent |
| HL | Hole |
| CR | Crack |
| BN | Bent |
| BR | Broken |
| MS | Missing |
| RS | Rust |
| CO | Corrosion |
| TO | Torn |
| LS | Loose |
| DY | Dirty |
| WT | Wet |
| OD | Odor |
| OS | Oil Stain |
| BM | Burn Mark |
| DL | Delamination |
| LK | Leakage |
| IR | Improper Repair |

### 12.5 CEDEX Repair Code

Contoh repair:

| Code | Repair |
|---|---|
| NR | No Repair |
| ST | Straighten |
| WD | Weld |
| PT | Patch |
| RP | Replace |
| RF | Refit |
| CL | Clean |
| DR | Drying |
| GR | Grinding |
| PN | Painting |
| SL | Sealant |
| TG | Tighten |
| RM | Remove |
| RI | Reinstall |

### 12.6 CEDEX Material Code

Contoh material:

| Code | Material |
|---|---|
| STL | Steel |
| ALU | Aluminium |
| PLY | Plywood |
| RUB | Rubber |
| PLA | Plastic |
| SST | Stainless Steel |
| PNT | Paint/Coating |

### 12.7 Responsibility Code

Contoh responsibility:

| Code | Responsibility |
|---|---|
| O | Owner |
| U | User / Lessee |
| S | Shipper |
| C | Consignee |
| CAR | Carrier |
| D | Depot |
| T | Trucking |
| X | Unknown |
| N | Not Applicable |

---

## 13. Modul Numbering Setting

### 13.1 Jenis Nomor

| Jenis Nomor | Contoh | Keterangan |
|---|---|---|
| Job Order No | GIFT-JO-2026-000001 | Nomor pekerjaan |
| Assignment No | GIFT-ASG-2026-000001 | Nomor penugasan |
| Survey No | GIFT-SVY-2026-000001 | Nomor survey per container |
| Report No | GIFT-RPT-2026-000001 | Nomor laporan final |
| EIR No | GIFT-EIR-2026-000001 | Nomor EIR |
| Damage No | D-001 | Nomor damage per survey |
| Invoice No | GIFT-INV-2026-000001 | Nomor invoice |
| Payment Receipt No | GIFT-RCP-2026-000001 | Nomor receipt pembayaran |

### 13.2 Format Nomor

Format default:

```text
[PREFIX]-[DOC_TYPE]-[YEAR]-[RUNNING_NUMBER]
```

Contoh:

```text
GIFT-JO-2026-000001
GIFT-ASG-2026-000001
GIFT-SVY-2026-000001
GIFT-RPT-2026-000001
GIFT-EIR-2026-000001
GIFT-INV-2026-000001
```

### 13.3 Aturan Penomoran

1. Job Order No dibuat saat job disimpan pertama kali.
2. Assignment No dibuat saat surveyor ditugaskan.
3. Survey No dibuat saat surveyor membuka/memulai survey container.
4. Damage No dibuat otomatis per survey, mulai dari D-001.
5. Report No dibuat setelah survey approved.
6. Invoice No dibuat saat finance issue invoice.
7. Nomor yang batal tidak boleh dipakai ulang.
8. Nomor final tidak boleh berubah.

---

## 14. Modul Job Order

### 14.1 Job Order Header

Field:

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| job_order_no | string | Ya | Otomatis |
| job_date | date | Ya | Tanggal job |
| customer_id | relation | Ya | Customer |
| survey_type_id | relation | Ya | Jenis survey |
| location_id | relation | Ya | Lokasi survey |
| pic_customer_name | string | Tidak | PIC customer |
| pic_customer_phone | string | Tidak | Kontak PIC |
| pic_customer_email | string | Tidak | Email PIC |
| reference_no | string | Tidak | Nomor referensi customer |
| booking_no | string | Tidak | Booking number |
| do_no | string | Tidak | Delivery order number |
| bl_no | string | Tidak | Bill of lading number |
| vessel | string | Tidak | Nama kapal |
| voyage | string | Tidak | Voyage |
| trucking_company | string | Tidak | Perusahaan trucking |
| priority | enum | Ya | normal/urgent |
| deadline | datetime | Tidak | Deadline pekerjaan |
| instruction | text | Tidak | Instruksi khusus |
| status | enum | Ya | Status job |

### 14.2 Job Container

Field:

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| job_order_id | relation | Ya | Relasi job |
| container_no | string | Ya | Nomor container |
| check_digit_status | enum | Tidak | valid/invalid/not_checked |
| container_type_id | relation | Tidak | Type container |
| iso_type_code | string | Tidak | ISO type code |
| seal_no | string | Tidak | Nomor seal |
| cargo_status | enum | Ya | empty/laden/unknown |
| gross_weight | decimal | Tidak | Berat kotor |
| tare_weight | decimal | Tidak | Berat kosong |
| payload | decimal | Tidak | Payload |
| manufacture_date | date | Tidak | Tanggal produksi |
| csc_plate_status | enum | Tidak | available/missing/unreadable |
| truck_no | string | Tidak | Nomor kendaraan |
| driver_name | string | Tidak | Nama driver |
| remark | text | Tidak | Catatan |
| status | enum | Ya | Status container |

### 14.3 Cara Input Container

MVP mendukung:

1. Input manual satu per satu.
2. Import Excel.

Future phase:

1. OCR nomor container dari foto.
2. Scan barcode/QR jika tersedia.

### 14.4 Validasi Job

1. Job tidak dapat di-assign jika belum ada container.
2. Container no dalam satu job tidak boleh duplikat.
3. Container no harus dikapitalisasi otomatis.
4. Jika check digit invalid, sistem menampilkan warning.
5. Admin boleh override check digit invalid dengan alasan.
6. Job yang sudah cancelled tidak bisa diubah kecuali oleh Super Admin.

---

## 15. Modul Assignment Surveyor

### 15.1 Tujuan

Assignment digunakan untuk menugaskan surveyor ke job atau container tertentu.

### 15.2 Field Assignment

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| assignment_no | string | Ya | Otomatis |
| job_order_id | relation | Ya | Relasi job |
| surveyor_id | relation | Ya | Surveyor |
| assigned_by | relation | Ya | Admin yang assign |
| assigned_at | datetime | Ya | Waktu assign |
| start_date | datetime | Tidak | Jadwal mulai |
| due_date | datetime | Tidak | Deadline |
| instruction | text | Tidak | Instruksi khusus |
| status | enum | Ya | assigned/accepted/in_progress/completed/cancelled |

### 15.3 Model Assignment

Sistem harus mendukung:

1. Satu job satu surveyor.
2. Satu job banyak surveyor.
3. Satu surveyor memegang sebagian container dalam satu job.
4. Reassignment container dari satu surveyor ke surveyor lain dengan audit log.

---

## 16. Modul Surveyor Web

### 16.1 Catatan Penting

Surveyor Web Module adalah modul untuk validasi alur/MVP. Modul ini meniru proses yang nantinya akan dijalankan di mobile app. Semua data dan workflow harus dirancang agar bisa digunakan ulang oleh mobile app.

### 16.2 Menu Surveyor Web

```text
Dashboard Surveyor
Job Saya
Detail Job
Pilih Container
General Info
Checklist Survey
Survey Sheet Interaktif
Damage List
Photo Evidence
Preview Survey
Submit Survey
Draft Survey
Need Revision
Riwayat Survey
```

### 16.3 Job Saya

Surveyor hanya melihat job/container yang ditugaskan kepada dirinya.

Tampilan list:

| Field | Keterangan |
|---|---|
| Job Order No | Nomor job |
| Customer | Nama customer |
| Location | Lokasi |
| Survey Type | Jenis survey |
| Total Container | Jumlah container assigned |
| Progress | Persentase selesai |
| Status | Status assignment |

### 16.4 Detail Job Surveyor

Menampilkan:

1. Job Order No.
2. Customer.
3. Location.
4. Survey Type.
5. Instruction.
6. Deadline.
7. Daftar container.

Daftar container:

| Field | Keterangan |
|---|---|
| Container No | Nomor container |
| Type | Tipe container |
| Seal No | Nomor seal |
| Cargo Status | Empty/Laden |
| Status | Not Started/Draft/Submitted/etc |

### 16.5 Memulai Survey Container

Saat surveyor membuka container:

1. Sistem membuat Survey No jika belum ada.
2. Status container berubah menjadi In Progress.
3. Status survey menjadi Draft.
4. Data dari job di-autofill.

---

## 17. Modul General Survey Form

### 17.1 Field General Info

| Field | Tipe | Wajib | Sumber |
|---|---|---:|---|
| survey_no | string | Ya | Otomatis |
| job_order_no | string | Ya | Dari job |
| container_no | string | Ya | Dari job |
| container_type | string | Tidak | Dari job/manual |
| survey_type | string | Ya | Dari job |
| customer | string | Ya | Dari job |
| location | string | Ya | Dari job |
| survey_date_time | datetime | Ya | Otomatis/manual |
| surveyor_name | string | Ya | Dari login |
| cargo_status | enum | Ya | Dari job/manual |
| seal_no | string | Conditional | Wajib jika laden |
| truck_no | string | Tidak | Input |
| driver_name | string | Tidak | Input |
| chassis_no | string | Tidak | Input |
| csc_plate_status | enum | Tidak | available/missing/unreadable |
| door_status | enum | Tidak | open/closed/locked/cannot_open |
| general_condition | enum | Ya | sound/damage/dirty/wet/odor/not_cargo_worthy |
| weather | string | Tidak | Opsional |
| gps_latitude | decimal | Tidak | Future mobile |
| gps_longitude | decimal | Tidak | Future mobile |
| general_remark | text | Tidak | Catatan |

### 17.2 Aturan General Info

1. Survey No hanya dibuat satu kali per container dalam job.
2. Container no tidak boleh kosong.
3. Surveyor name otomatis dari user login.
4. Seal no wajib jika cargo_status = laden, kecuali admin/supervisor mengubah aturan.
5. General condition dapat berubah otomatis berdasarkan damage/checklist.

---

## 18. Modul Checklist Survey

### 18.1 Checklist Umum

Checklist umum tersedia untuk semua survey type:

| Checklist | Input |
|---|---|
| Container number readable | Yes/No/N/A |
| ISO code readable | Yes/No/N/A |
| CSC plate available | Yes/No/N/A |
| Exterior condition OK | OK/Not OK/N/A |
| Interior clean | OK/Not OK/N/A |
| Door can open/close | OK/Not OK/N/A |
| Floor condition OK | OK/Not OK/N/A |
| Roof condition OK | OK/Not OK/N/A |
| Side panel condition OK | OK/Not OK/N/A |
| Front panel condition OK | OK/Not OK/N/A |
| Understructure condition OK | OK/Not OK/N/A |
| Seal condition OK | OK/Not OK/N/A |
| Light test pass | Pass/Fail/Not Checked/N/A |
| Odor detected | Yes/No/N/A |
| Wet condition | Yes/No/N/A |
| Cleanliness | Clean/Dirty/N/A |

### 18.2 Checklist Cargo Worthy

Tambahan untuk cargo worthy:

| Checklist | Input |
|---|---|
| Watertight | Yes/No/N/A |
| No light leakage | Yes/No/Not Checked |
| Door closes properly | Yes/No |
| Floor safe for cargo | Yes/No |
| No sharp edge | Yes/No |
| No contamination | Yes/No |
| No odor | Yes/No |
| Structurally safe | Yes/No |
| Cargo worthy result | Pass/Fail/Pending Review |

### 18.3 Checklist Gate In/Gate Out

Tambahan:

| Checklist | Input |
|---|---|
| Truck no recorded | Yes/No/N/A |
| Driver name recorded | Yes/No/N/A |
| Seal no recorded | Yes/No/N/A |
| Handover party recorded | Yes/No/N/A |
| EIR required | Yes/No |

### 18.4 Aturan Checklist

1. Checklist wajib diisi sebelum submit.
2. Checklist dapat berbeda berdasarkan survey type.
3. Jika checklist critical gagal, survey result direkomendasikan menjadi Not Cargo Worthy atau Pending Review.
4. Supervisor dapat melihat semua checklist.

---

## 19. Modul Survey Sheet Interaktif

### 19.1 Tujuan

Survey sheet interaktif digunakan agar surveyor dapat mencatat damage berdasarkan posisi visual kontainer. Surveyor mengklik area pada gambar/grid container, lalu sistem membuka form damage.

### 19.2 Sisi Kontainer

Survey sheet harus memiliki sisi:

1. Left Side.
2. Right Side.
3. Front End.
4. Door End.
5. Roof.
6. Floor / Interior.
7. Understructure.

### 19.3 Contoh Grid Left Side

```text
LEFT SIDE

+------+------+------+------+
| L1   | L2   | L3   | L4   |
+------+------+------+------+
| L5   | L6   | L7   | L8   |
+------+------+------+------+
```

### 19.4 Contoh Grid Right Side

```text
RIGHT SIDE

+------+------+------+------+
| R1   | R2   | R3   | R4   |
+------+------+------+------+
| R5   | R6   | R7   | R8   |
+------+------+------+------+
```

### 19.5 Contoh Grid Door End

```text
DOOR END

+------+------+
| D1   | D2   |
+------+------+
| D3   | D4   |
+------+------+
```

### 19.6 Contoh Grid Front End

```text
FRONT END

+------+------+
| F1   | F2   |
+------+------+
| F3   | F4   |
+------+------+
```

### 19.7 Contoh Grid Roof

```text
ROOF

+------+------+------+------+
| T1   | T2   | T3   | T4   |
+------+------+------+------+
```

### 19.8 Contoh Grid Floor

```text
FLOOR / INTERIOR

+------+------+------+------+
| FL1  | FL2  | FL3  | FL4  |
+------+------+------+------+
```

### 19.9 Contoh Grid Understructure

```text
UNDERSTRUCTURE

+------+------+------+------+
| U1   | U2   | U3   | U4   |
+------+------+------+------+
```

### 19.10 Aturan Klik Survey Sheet

Saat area diklik:

1. Sistem membaca face.
2. Sistem membaca grid location.
3. Sistem membuat damage no otomatis.
4. Sistem membuka modal damage.
5. Location otomatis terisi.
6. CEDEX location mapping otomatis jika tersedia.

Contoh:

```text
Klik L3
â†“
Damage No: D-001
Face: Left Side
Location: L3
CEDEX Location: sesuai mapping master
```

### 19.11 Marker Damage

Setelah damage disimpan:

1. Marker D-001 muncul pada grid.
2. Warna marker mengikuti severity.
3. Klik marker membuka detail damage.
4. Damage masuk ke Damage List.

Rekomendasi warna:

| Warna | Arti |
|---|---|
| Hijau | OK/Sound |
| Kuning | Minor |
| Merah | Major/Critical |
| Abu-abu | Dirty/Cleaning |
| Biru | Note/Photo only |

---

## 20. Modul Damage Input

### 20.1 Field Damage

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| damage_no | string | Ya | D-001, otomatis per survey |
| survey_id | relation | Ya | Relasi survey |
| face | enum | Ya | left/right/front/door/roof/floor/understructure |
| internal_location | string | Ya | L3, D2, T1, dst |
| cedex_location_code | string | Tidak | Dari mapping |
| component_code | relation | Ya | CEDEX component |
| damage_code | relation | Ya | CEDEX damage |
| repair_code | relation | Tidak | CEDEX repair |
| material_code | relation | Tidak | CEDEX material |
| responsibility_code | relation | Tidak | Responsibility |
| severity | enum | Ya | minor/major/critical |
| quantity | integer | Tidak | Jumlah |
| length | decimal | Tidak | Panjang |
| width | decimal | Tidak | Lebar |
| depth | decimal | Tidak | Kedalaman |
| unit | enum | Tidak | mm/cm/m |
| is_repair_required | boolean | Tidak | Perlu repair |
| is_cargo_worthy_impact | boolean | Tidak | Berpengaruh layak muat |
| remark | text | Tidak | Catatan |

### 20.2 Aturan Damage

1. Damage wajib memiliki location.
2. Damage wajib memiliki component.
3. Damage wajib memiliki damage type.
4. Damage no otomatis berurutan dalam satu survey.
5. Damage major/critical wajib memiliki ukuran dan foto.
6. Damage minor tetap disarankan memiliki foto.
7. Jika ada damage tanpa foto, submit tidak diperbolehkan.
8. Jika damage severity = critical, survey result direkomendasikan Not Cargo Worthy/Pending Review.
9. Damage hanya dapat diedit selama survey status Draft atau Need Revision.
10. Penghapusan damage harus masuk audit log.

---

## 21. Modul Photo Evidence

### 21.1 Jenis Foto

Foto dibagi menjadi:

1. General photo.
2. Damage photo.
3. Document/reference photo.

### 21.2 Foto Umum

Jenis foto umum:

| Jenis Foto | Keterangan |
|---|---|
| Container Number | Foto nomor container |
| CSC Plate | Foto CSC plate |
| Exterior | Foto tampak luar |
| Interior | Foto bagian dalam |
| Door | Foto pintu |
| Floor | Foto lantai |
| Roof | Foto atap |
| Seal | Foto seal |
| Additional | Foto tambahan |

### 21.3 Foto Damage

Foto damage wajib terhubung ke damage_id.

Contoh:

```text
D-001 Photo 1
D-001 Photo 2
D-002 Photo 1
```

### 21.4 Field Foto

| Field | Tipe | Wajib | Keterangan |
|---|---|---:|---|
| survey_id | relation | Ya | Relasi survey |
| damage_id | relation | Conditional | Wajib jika damage photo |
| photo_type | enum | Ya | general/damage/document |
| file_path | string | Ya | Path storage |
| original_file_name | string | Tidak | Nama asli |
| file_size | integer | Tidak | Ukuran file |
| mime_type | string | Tidak | Tipe file |
| caption | text | Tidak | Caption |
| taken_at | datetime | Tidak | Waktu foto |
| uploaded_by | relation | Ya | User uploader |

### 21.5 Watermark Foto

Watermark disiapkan terutama untuk mobile phase, tetapi format data harus disiapkan sejak web MVP.

Isi watermark:

```text
Container No
Survey No
Damage No
Location
Surveyor Name
Date Time
GPS Coordinate, jika tersedia
```

### 21.6 Aturan Foto

1. Damage wajib minimal 1 foto sebelum submit.
2. Foto harus disimpan di object storage, bukan database blob.
3. Database hanya menyimpan metadata dan file path.
4. Foto harus dapat muncul di report PDF.
5. Foto yang dihapus masuk audit log.

---

## 22. Modul Preview dan Submit Survey

### 22.1 Preview Survey

Preview menampilkan:

1. Job information.
2. Container information.
3. General survey info.
4. Checklist summary.
5. Survey sheet marker.
6. Damage list.
7. Photo evidence.
8. Final result sementara.
9. Warning data belum lengkap.

### 22.2 Validasi Sebelum Submit

Survey tidak dapat submit jika:

1. General info wajib belum lengkap.
2. Checklist wajib belum lengkap.
3. Ada damage tanpa component.
4. Ada damage tanpa damage type.
5. Ada damage tanpa foto.
6. Seal no kosong untuk laden container, kecuali ada override.
7. Damage major/critical tidak memiliki ukuran.
8. Survey result belum ditentukan.

### 22.3 Submit Survey

Saat submit:

1. Status survey berubah dari Draft ke Submitted.
2. Status container berubah menjadi Submitted.
3. Supervisor dapat melihat di Pending Review.
4. Surveyor tidak dapat edit kecuali status menjadi Need Revision.
5. Audit log dicatat.

---

## 23. Modul Review dan Approval

### 23.1 Pending Review

Supervisor melihat survey status Submitted.

List menampilkan:

| Field | Keterangan |
|---|---|
| Survey No | Nomor survey |
| Job Order No | Nomor job |
| Container No | Nomor container |
| Customer | Customer |
| Surveyor | Nama surveyor |
| Survey Type | Jenis survey |
| Submitted At | Waktu submit |
| Status | Submitted |

### 23.2 Detail Review

Supervisor dapat melihat:

1. General info.
2. Checklist.
3. Survey sheet marker.
4. Damage list.
5. Foto evidence.
6. Catatan surveyor.
7. Rekomendasi system result.

### 23.3 Need Revision

Jika data belum benar:

1. Supervisor memilih Need Revision.
2. Supervisor wajib mengisi revision note.
3. Status survey berubah menjadi Need Revision.
4. Surveyor dapat mengedit kembali.
5. Semua catatan revisi disimpan.

Contoh revision note:

```text
Foto D-001 kurang jelas, mohon upload ulang.
Ukuran damage D-002 belum lengkap.
Checklist Light Test belum diisi.
```

### 23.4 Approve Survey

Jika data benar:

1. Supervisor klik Approve.
2. Status survey berubah menjadi Approved.
3. Survey terkunci.
4. Sistem membuat Report No.
5. Report dapat digenerate.
6. Audit log dicatat.

### 23.5 Reject Survey

Reject digunakan jika survey tidak dapat diterima sama sekali.

Aturan:

1. Reject harus memiliki alasan.
2. Survey rejected tidak masuk invoice.
3. Rejected survey hanya dapat dibuka ulang oleh Super Admin atau Supervisor sesuai permission.

---

## 24. Modul Report

### 24.1 Jenis Report/Dokumen

Aplikasi harus dapat menghasilkan:

| No | Dokumen | Kapan Dibuat | Oleh |
|---|---|---|---|
| 1 | Job Order / Surat Tugas | Setelah job dibuat/assigned | Admin |
| 2 | Assignment Sheet | Setelah assign surveyor | Admin |
| 3 | Survey Sheet | Setelah survey submitted/approved | Sistem |
| 4 | Damage Report | Jika ada damage | Sistem |
| 5 | Container Inspection Report | Setelah approved | Sistem/Supervisor |
| 6 | EIR | Untuk Gate In/Gate Out jika diperlukan | Sistem |
| 7 | Photo Attachment Report | Setelah approved | Sistem |
| 8 | Invoice | Setelah ready to invoice | Finance |
| 9 | Payment Receipt | Setelah pembayaran | Finance |

### 24.2 Container Inspection Report

Isi laporan utama:

1. Company header.
2. Logo perusahaan.
3. Report No.
4. Job Order No.
5. Survey No.
6. Customer.
7. Location.
8. Survey Date.
9. Surveyor.
10. Approver.
11. Container No.
12. Container type/size.
13. ISO code.
14. Seal no.
15. Cargo status.
16. Survey type.
17. Final result.
18. Checklist summary.
19. Survey sheet dengan marker damage.
20. Damage list.
21. Photo evidence.
22. Conclusion.
23. Signature surveyor.
24. Signature approver.
25. QR code validasi.

### 24.3 Damage Report

Isi:

1. Container No.
2. Survey No.
3. Damage no.
4. Location.
5. Component code/name.
6. Damage code/name.
7. Repair code/name.
8. Material.
9. Responsibility.
10. Severity.
11. Size.
12. Foto.
13. Remark.

### 24.4 EIR

Digunakan untuk Gate In/Gate Out jika diperlukan.

Isi:

1. EIR No.
2. Date/time.
3. Container No.
4. Type/size.
5. Truck no.
6. Driver name.
7. Seal no.
8. From party.
9. To party.
10. Location.
11. Condition at handover.
12. Damage mark.
13. Signature pihak terkait.

### 24.5 Report Versioning

Aturan:

1. Report pertama adalah Rev. 0.
2. Koreksi setelah final menjadi Rev. 1, Rev. 2, dst.
3. Versi lama diberi status superseded.
4. Semua versi PDF tetap disimpan.
5. Revisi report harus memiliki alasan.

### 24.6 QR Code Validasi

QR code membuka halaman validasi publik/terbatas.

Data yang ditampilkan:

1. Report No.
2. Container No.
3. Customer.
4. Survey date.
5. Status valid.
6. Surveyor.
7. Approver.
8. Download PDF jika diizinkan.

---

## 25. Modul Finance

### 25.1 Ready to Invoice

Finance melihat survey/report yang sudah approved/generated dan belum invoice.

List:

| Field | Keterangan |
|---|---|
| Report No | Nomor report |
| Job Order No | Nomor job |
| Customer | Customer |
| Survey Type | Jenis survey |
| Total Container | Jumlah container |
| Status | Ready to Invoice |

### 25.2 Price List

Field:

| Field | Tipe | Wajib |
|---|---|---:|
| customer_id | relation | Tidak |
| survey_type_id | relation | Ya |
| container_type_id | relation | Tidak |
| unit_price | decimal | Ya |
| currency | enum | Ya |
| tax_type | enum | Tidak |
| effective_date | date | Ya |
| status | enum | Ya |

### 25.3 Invoice

Field invoice header:

| Field | Tipe | Wajib |
|---|---|---:|
| invoice_no | string | Ya |
| invoice_date | date | Ya |
| customer_id | relation | Ya |
| billing_address | text | Tidak |
| payment_term_days | integer | Tidak |
| due_date | date | Tidak |
| subtotal | decimal | Ya |
| tax_amount | decimal | Tidak |
| discount_amount | decimal | Tidak |
| grand_total | decimal | Ya |
| status | enum | Ya |

Field invoice item:

| Field | Tipe | Wajib |
|---|---|---:|
| invoice_id | relation | Ya |
| job_order_id | relation | Tidak |
| report_id | relation | Tidak |
| description | string | Ya |
| quantity | decimal | Ya |
| unit_price | decimal | Ya |
| total | decimal | Ya |

### 25.4 Payment

Field:

| Field | Tipe | Wajib |
|---|---|---:|
| payment_no | string | Tidak |
| invoice_id | relation | Ya |
| payment_date | date | Ya |
| amount | decimal | Ya |
| payment_method | enum | Tidak |
| bank_account | string | Tidak |
| proof_file | file path | Tidak |
| note | text | Tidak |
| created_by | relation | Ya |

### 25.5 Status Invoice

Status invoice:

1. Draft.
2. Issued.
3. Unpaid.
4. Partial Paid.
5. Paid.
6. Overdue.
7. Cancelled.

### 25.6 Aturan Finance

1. Invoice hanya bisa dibuat dari report approved/generated.
2. Satu report tidak boleh ditagih dua kali kecuali dibuat invoice tambahan dengan alasan.
3. Invoice paid tidak boleh dihapus.
4. Payment harus mencatat nominal, tanggal, dan user.
5. Finance tidak bisa mengubah survey, damage, checklist, atau approval.
6. Cancel invoice wajib alasan.

---

## 26. Status Workflow

### 26.1 Status Job Order

| Status | Arti |
|---|---|
| Draft | Job baru dibuat, belum assigned |
| Assigned | Job sudah ditugaskan |
| In Progress | Survey sedang berjalan |
| All Survey Submitted | Semua survey sudah submit |
| All Survey Approved | Semua survey sudah approved |
| Report Generated | Report sudah dibuat |
| Ready to Invoice | Siap ditagih |
| Invoiced | Sudah dibuat invoice |
| Paid | Invoice sudah lunas |
| Closed | Pekerjaan selesai total |
| Cancelled | Job dibatalkan |

### 26.2 Status Job Container

| Status | Arti |
|---|---|
| Not Started | Belum mulai |
| Assigned | Sudah assigned ke surveyor |
| In Progress | Sedang dikerjakan |
| Draft | Survey tersimpan draft |
| Submitted | Survey disubmit |
| Need Revision | Perlu revisi |
| Approved | Disetujui |
| Reported | Masuk report |
| Invoiced | Sudah ditagih |
| Closed | Selesai |
| Cancelled | Dibatalkan |

### 26.3 Status Survey

| Status | Arti |
|---|---|
| Draft | Survey belum submit |
| Submitted | Survey dikirim ke supervisor |
| Need Revision | Survey perlu diperbaiki |
| Approved | Survey disetujui |
| Rejected | Survey ditolak |
| Report Generated | Report final dibuat |

### 26.4 Status Assignment

| Status | Arti |
|---|---|
| Assigned | Ditugaskan |
| Accepted | Diterima surveyor |
| In Progress | Sedang dikerjakan |
| Completed | Selesai |
| Cancelled | Dibatalkan |

---

## 27. Survey Result dan Logika Otomatis

### 27.1 Pilihan Survey Result

| Result | Arti |
|---|---|
| Sound | Tidak ada damage signifikan |
| Damage | Ada damage |
| Dirty | Kotor/perlu cleaning |
| Wet | Basah/perlu drying |
| Odor | Ada bau |
| Need Repair | Perlu repair |
| Cargo Worthy | Layak muat |
| Not Cargo Worthy | Tidak layak muat |
| Pending Review | Perlu review supervisor |

### 27.2 Logika Rekomendasi Sistem

| Kondisi | Rekomendasi Result |
|---|---|
| Tidak ada damage dan checklist OK | Sound/Cargo Worthy |
| Ada dirty | Dirty/Need Cleaning |
| Ada wet | Wet/Need Drying |
| Ada hole pada roof/side | Need Repair/Pending Review |
| Door cannot close | Not Cargo Worthy |
| Light test fail | Not Cargo Worthy |
| Damage critical | Not Cargo Worthy/Pending Review |
| Damage minor saja | Damage |

Catatan: hasil otomatis adalah rekomendasi. Final result tetap diputuskan oleh Supervisor saat approval.

---

## 28. Hak Akses

| Fitur | Super Admin | Admin | Surveyor | Supervisor | Finance | Management |
|---|---:|---:|---:|---:|---:|---:|
| User Management | Ya | Tidak | Tidak | Tidak | Tidak | Tidak |
| Role Permission | Ya | Tidak | Tidak | Tidak | Tidak | Tidak |
| Company Setting | Ya | Tidak | Tidak | Tidak | Tidak | Lihat |
| Numbering Setting | Ya | Tidak | Tidak | Tidak | Tidak | Lihat |
| Master Customer | Ya | Ya | Tidak | Lihat | Lihat | Lihat |
| Master Location | Ya | Ya | Tidak | Lihat | Tidak | Lihat |
| Master Surveyor | Ya | Ya | Tidak | Lihat | Tidak | Lihat |
| Master CEDEX | Ya | Ya | Lihat dropdown | Lihat | Tidak | Lihat |
| Job Order | Ya | Ya | Lihat job sendiri | Lihat | Tidak | Lihat |
| Assign Surveyor | Ya | Ya | Tidak | Opsional | Tidak | Tidak |
| Isi Survey | Tidak | Tidak | Ya | Tidak | Tidak | Tidak |
| Upload Foto | Tidak | Tidak | Ya | Tidak | Tidak | Tidak |
| Submit Survey | Tidak | Tidak | Ya | Tidak | Tidak | Tidak |
| Review Survey | Lihat | Lihat | Tidak | Ya | Tidak | Lihat |
| Approve Survey | Tidak | Tidak | Tidak | Ya | Tidak | Tidak |
| Generate Report | Ya | Ya | Tidak | Ya | Tidak | Lihat |
| Invoice | Ya | Tidak | Tidak | Tidak | Ya | Lihat |
| Payment | Ya | Tidak | Tidak | Tidak | Ya | Lihat |
| Audit Log | Ya | Tidak | Tidak | Lihat terbatas | Tidak | Lihat |

---

## 29. Data Model / Entity List

Entity utama:

```text
User
Role
Permission
CompanyProfile
NumberingSetting
Customer
Location
SurveyorProfile
ContainerType
SurveyType
CedexLocation
CedexComponent
CedexDamage
CedexRepair
CedexMaterial
ResponsibilityCode
JobOrder
JobContainer
Assignment
Survey
SurveyChecklist
SurveyDamage
SurveyPhoto
SurveyApproval
Report
ReportVersion
PriceList
Invoice
InvoiceItem
Payment
AuditLog
Notification
FileObject
```

### 29.1 Relasi Data Utama

```text
Customer
  â†“
JobOrder
  â†“
JobContainer
  â†“
Survey
  â†“
SurveyDamage
  â†“
SurveyPhoto

JobOrder
  â†“
Assignment
  â†“
SurveyorProfile

Survey
  â†“
SurveyApproval
  â†“
Report
  â†“
Invoice
  â†“
Payment
```

### 29.2 Aturan Relasi

1. Satu customer bisa memiliki banyak job order.
2. Satu job order bisa memiliki banyak container.
3. Satu job order bisa memiliki banyak assignment.
4. Satu assignment menghubungkan surveyor dengan job/container.
5. Satu job container memiliki satu survey utama per survey type.
6. Satu survey bisa memiliki banyak checklist item.
7. Satu survey bisa memiliki banyak damage.
8. Satu damage bisa memiliki banyak foto.
9. Satu survey approved dapat menghasilkan satu atau lebih report version.
10. Satu invoice dapat menagih satu atau lebih report/job.
11. Satu invoice bisa memiliki banyak payment jika partial paid.

---

## 30. API Requirements

Backend API harus disiapkan untuk web dan future mobile.

### 30.1 Auth API

```text
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh
GET    /api/me
POST   /api/auth/forgot-password
POST   /api/auth/reset-password
```

### 30.2 Master Data API

```text
GET    /api/master/customers
POST   /api/master/customers
GET    /api/master/customers/{id}
PUT    /api/master/customers/{id}
DELETE /api/master/customers/{id}

GET    /api/master/locations
POST   /api/master/locations
PUT    /api/master/locations/{id}
DELETE /api/master/locations/{id}

GET    /api/master/surveyors
POST   /api/master/surveyors
PUT    /api/master/surveyors/{id}

GET    /api/master/container-types
GET    /api/master/survey-types
```

### 30.3 CEDEX API

```text
GET    /api/master/cedex/locations
POST   /api/master/cedex/locations
PUT    /api/master/cedex/locations/{id}

GET    /api/master/cedex/components
POST   /api/master/cedex/components
PUT    /api/master/cedex/components/{id}

GET    /api/master/cedex/damages
POST   /api/master/cedex/damages
PUT    /api/master/cedex/damages/{id}

GET    /api/master/cedex/repairs
POST   /api/master/cedex/repairs
PUT    /api/master/cedex/repairs/{id}

GET    /api/master/cedex/materials
GET    /api/master/responsibility-codes
```

### 30.4 Job API

```text
GET    /api/jobs
POST   /api/jobs
GET    /api/jobs/{id}
PUT    /api/jobs/{id}
DELETE /api/jobs/{id}
POST   /api/jobs/{id}/cancel

GET    /api/jobs/{id}/containers
POST   /api/jobs/{id}/containers
POST   /api/jobs/{id}/containers/import
PUT    /api/job-containers/{id}
DELETE /api/job-containers/{id}

POST   /api/jobs/{id}/assign
GET    /api/jobs/{id}/timeline
```

### 30.5 Surveyor API

```text
GET    /api/surveyor/jobs
GET    /api/surveyor/jobs/{id}
GET    /api/surveyor/jobs/{id}/containers
GET    /api/surveyor/containers/{container_id}

POST   /api/surveys/start
GET    /api/surveys/{id}
PUT    /api/surveys/{id}/general-info
PUT    /api/surveys/{id}/checklist
POST   /api/surveys/{id}/submit
```

### 30.6 Damage API

```text
GET    /api/surveys/{id}/damages
POST   /api/surveys/{id}/damages
GET    /api/survey-damages/{id}
PUT    /api/survey-damages/{id}
DELETE /api/survey-damages/{id}
```

### 30.7 Photo API

```text
GET    /api/surveys/{id}/photos
POST   /api/surveys/{id}/photos
POST   /api/survey-damages/{id}/photos
DELETE /api/survey-photos/{id}
```

### 30.8 Review API

```text
GET    /api/reviews/pending
GET    /api/reviews/{survey_id}
POST   /api/reviews/{survey_id}/approve
POST   /api/reviews/{survey_id}/need-revision
POST   /api/reviews/{survey_id}/reject
```

### 30.9 Report API

```text
GET    /api/reports
GET    /api/reports/{id}
POST   /api/reports/generate/{survey_id}
GET    /api/reports/{id}/download
GET    /api/reports/{id}/versions
GET    /api/reports/validate/{qr_token}
```

### 30.10 Finance API

```text
GET    /api/finance/ready-to-invoice
GET    /api/finance/price-list
POST   /api/finance/price-list
PUT    /api/finance/price-list/{id}

GET    /api/finance/invoices
POST   /api/finance/invoices
GET    /api/finance/invoices/{id}
PUT    /api/finance/invoices/{id}
POST   /api/finance/invoices/{id}/issue
POST   /api/finance/invoices/{id}/cancel

POST   /api/finance/payments
GET    /api/finance/outstanding
```

---

## 31. File Storage Requirements

### 31.1 Jenis File

File yang disimpan:

1. Foto container.
2. Foto damage.
3. Foto CSC plate.
4. Foto seal.
5. Report PDF.
6. Invoice PDF.
7. Payment proof.
8. Signature file.
9. Company logo.

### 31.2 Struktur Storage

Contoh struktur:

```text
/storage
  /surveys
    /2026
      /06
        /GIFT-SVY-2026-000001
          /general
          /damages
            /D-001-photo-1.jpg
            /D-001-photo-2.jpg
  /reports
    /2026
      /GIFT-RPT-2026-000001-rev0.pdf
  /invoices
    /2026
      /GIFT-INV-2026-000001.pdf
  /payments
    /2026
      /GIFT-RCP-2026-000001.jpg
```

### 31.3 Aturan Storage

1. Database tidak menyimpan file binary/blob.
2. Database menyimpan metadata dan path file.
3. File report final tidak boleh ditimpa.
4. Jika ada revisi report, buat file versi baru.
5. File harus bisa dibackup.
6. File sensitif harus membutuhkan permission untuk dibuka.

---

## 32. Audit Log

### 32.1 Aktivitas yang Dicatat

Audit log wajib mencatat:

1. Login.
2. Logout.
3. Create/update/delete master data.
4. Create job.
5. Update job.
6. Cancel job.
7. Import container.
8. Assign surveyor.
9. Reassign surveyor.
10. Start survey.
11. Update general info.
12. Update checklist.
13. Add/edit/delete damage.
14. Upload/delete photo.
15. Submit survey.
16. Need revision.
17. Approve survey.
18. Reject survey.
19. Generate report.
20. Create invoice.
21. Issue invoice.
22. Cancel invoice.
23. Add payment.
24. Update permission.

### 32.2 Field Audit Log

| Field | Keterangan |
|---|---|
| user_id | User yang melakukan aksi |
| action | Nama aksi |
| entity_type | Tipe data |
| entity_id | ID data |
| old_value | Data sebelum |
| new_value | Data sesudah |
| ip_address | IP user |
| user_agent | Browser/device |
| created_at | Waktu aksi |

---

## 33. Notification Requirements

### 33.1 Event Notifikasi

| Event | Penerima |
|---|---|
| Job assigned | Surveyor |
| Survey submitted | Supervisor |
| Survey need revision | Surveyor |
| Survey approved | Admin, Finance |
| Report generated | Admin, Finance |
| Invoice created | Admin/Finance |
| Payment overdue | Finance |
| Job urgent | Surveyor/Admin |

### 33.2 Kanal Notifikasi

MVP:

1. In-app notification.
2. Email optional.

Future:

1. WhatsApp gateway.
2. Push notification mobile.

---

## 34. Non-Functional Requirements

### 34.1 Performance

1. Halaman dashboard web harus memuat data awal dengan cepat.
2. List data menggunakan pagination.
3. Filter data dilakukan server-side.
4. Foto tidak boleh langsung dimuat full size di list.
5. Report PDF dibuat background job.
6. Upload file harus memiliki progress indicator.
7. Master CEDEX dapat di-cache.

### 34.2 Scalability

1. Backend API harus stateless.
2. File disimpan di object storage.
3. Queue digunakan untuk proses berat.
4. Database harus memiliki index pada kolom penting.

Kolom yang perlu index:

```text
job_order_no
survey_no
report_no
invoice_no
container_no
customer_id
surveyor_id
status
created_at
survey_date
```

### 34.3 Security

1. Password harus di-hash.
2. Role-based access wajib.
3. API harus menggunakan HTTPS.
4. File private harus membutuhkan authorization.
5. Input harus divalidasi server-side.
6. Upload file dibatasi tipe dan ukuran.
7. Audit log tidak boleh diedit user biasa.
8. Token/session memiliki expiry.

### 34.4 Reliability

1. Data survey tidak boleh hilang.
2. Submit survey harus atomic.
3. File upload gagal harus dapat diulang.
4. Report final tidak boleh tertimpa.
5. Backup database wajib.
6. Backup file storage wajib.

### 34.5 Maintainability

1. Kode dipisah berdasarkan modul.
2. API didokumentasikan.
3. Struktur database memakai migration.
4. Error handling konsisten.
5. Log error backend harus tersedia.

### 34.6 Mobile-Readiness

Walaupun MVP di web, sistem harus siap mobile:

1. API tidak boleh bergantung pada session web saja.
2. Endpoint surveyor harus mobile-friendly.
3. Data master dapat di-download untuk local cache.
4. Upload foto harus mendukung mobile.
5. Struktur survey/damage harus reusable.

---

## 35. Future Mobile App Requirements

### 35.1 Tujuan Mobile

Mobile app dibuat agar surveyor lapangan dapat bekerja lebih cepat, ringan, dan stabil.

### 35.2 Fitur Mobile

1. Login surveyor.
2. Job saya.
3. Download assigned job.
4. Local master data.
5. General info.
6. Checklist.
7. Survey sheet interaktif.
8. Damage input.
9. Camera capture.
10. GPS capture.
11. Watermark foto.
12. Compress foto.
13. Offline draft.
14. Background upload.
15. Sync status.
16. Retry upload.
17. Need revision.
18. Submit survey.

### 35.3 Mobile Offline Strategy

Data yang disimpan lokal:

1. Job assigned.
2. Container list.
3. Master CEDEX.
4. Checklist template.
5. Draft general info.
6. Draft checklist.
7. Draft damage.
8. Foto local queue.

### 35.4 Sync Strategy

1. Data disimpan lokal dulu.
2. Sync dilakukan saat online.
3. Foto upload background.
4. Konflik data ditandai.
5. Survey submitted tidak bisa diedit kecuali Need Revision.

---

## 36. Acceptance Criteria MVP

### 36.1 Authentication

- User dapat login sesuai role.
- User hanya melihat menu sesuai permission.
- User dapat logout.

### 36.2 Master Data

- Admin dapat membuat customer.
- Admin dapat membuat location.
- Admin dapat membuat surveyor.
- Admin dapat membuat survey type.
- Admin dapat membuat CEDEX component, damage, repair, location, material, responsibility.

### 36.3 Job Order

- Admin dapat membuat job order.
- Admin dapat input container manual.
- Admin dapat import container dari Excel.
- Sistem mencegah duplikasi container dalam job.
- Admin dapat assign surveyor.

### 36.4 Surveyor Web

- Surveyor hanya melihat job miliknya.
- Surveyor dapat membuka container.
- Sistem membuat survey no otomatis.
- Surveyor dapat mengisi general info.
- Surveyor dapat mengisi checklist.
- Surveyor dapat klik survey sheet.
- Surveyor dapat input damage dari area klik.
- Surveyor dapat upload foto damage.
- Surveyor dapat preview survey.
- Surveyor dapat submit jika data lengkap.
- Surveyor tidak dapat edit setelah submit kecuali Need Revision.

### 36.5 Review

- Supervisor dapat melihat submitted survey.
- Supervisor dapat membuka detail survey.
- Supervisor dapat approve survey.
- Supervisor dapat mengembalikan survey sebagai Need Revision dengan catatan.
- Surveyor dapat memperbaiki survey yang Need Revision.

### 36.6 Report

- Report no dibuat setelah approve.
- Sistem dapat generate PDF report.
- PDF menampilkan data job, container, checklist, survey sheet, damage list, foto, dan signature.
- Report final tersimpan di archive.

### 36.7 Finance

- Finance dapat melihat report siap invoice.
- Finance dapat membuat invoice.
- Finance dapat mencatat payment.
- Status invoice berubah sesuai pembayaran.

### 36.8 Audit Log

- Aktivitas penting tercatat.
- Audit log menampilkan user, aksi, waktu, dan data yang berubah.

---

## 37. Testing Scenario

### 37.1 Scenario 1 â€” Job Tanpa Damage

1. Admin membuat job.
2. Admin input 1 container.
3. Admin assign surveyor.
4. Surveyor isi general info.
5. Surveyor checklist semua OK.
6. Surveyor submit.
7. Supervisor approve.
8. Sistem generate report Sound/Cargo Worthy.
9. Finance buat invoice.

Expected result: job selesai tanpa damage report detail.

### 37.2 Scenario 2 â€” Job Dengan Damage Minor

1. Surveyor klik L3.
2. Input Side Panel - Dent - Straighten.
3. Upload foto.
4. Submit.
5. Supervisor approve.
6. Report menampilkan D-001 di survey sheet dan damage list.

Expected result: damage tampil lengkap dengan foto.

### 37.3 Scenario 3 â€” Damage Tanpa Foto

1. Surveyor input damage.
2. Surveyor tidak upload foto.
3. Surveyor klik submit.

Expected result: sistem menolak submit dan menampilkan warning.

### 37.4 Scenario 4 â€” Need Revision

1. Surveyor submit.
2. Supervisor menemukan foto blur.
3. Supervisor set Need Revision.
4. Surveyor upload ulang foto.
5. Surveyor submit ulang.
6. Supervisor approve.

Expected result: revisi tercatat di audit log.

### 37.5 Scenario 5 â€” Finance Invoice

1. Survey approved.
2. Report generated.
3. Finance membuka Ready to Invoice.
4. Finance create invoice.
5. Finance input payment.

Expected result: invoice status Paid dan job bisa Closed.

---

## 38. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Alur survey belum jelas | Banyak revisi aplikasi | Buat web module surveyor dulu |
| CEDEX terlalu teknis | Surveyor bingung | Surveyor pilih nama, sistem simpan kode |
| Foto tidak terhubung damage | Bukti lemah | Foto wajib punya damage_id |
| Report keluar tanpa review | Risiko salah laporan | Approval wajib |
| Finance edit data survey | Integritas data rusak | Permission dibatasi |
| Upload foto berat | Aplikasi lambat | Compress dan object storage |
| Mobile dibuat terlalu awal | Banyak bongkar ulang | Validasi alur di web dulu |
| Nomor dokumen kacau | Arsip sulit | Numbering setting otomatis |
| Data hilang | Operasional terganggu | Autosave, backup, audit |

---

## 39. Roadmap Development

### Phase 1 â€” PRD dan Desain

1. Finalisasi PRD.
2. Flow diagram.
3. Database schema.
4. API design.
5. Wireframe UI.

### Phase 2 â€” Backend dan Web Core

1. Auth.
2. Role permission.
3. Master data.
4. Master CEDEX.
5. Numbering.
6. Job order.
7. Assignment.

### Phase 3 â€” Surveyor Web Module

1. Job saya.
2. Detail container.
3. General info.
4. Checklist.
5. Survey sheet interaktif.
6. Damage input.
7. Photo evidence.
8. Submit.

### Phase 4 â€” Review dan Report

1. Pending review.
2. Need revision.
3. Approve.
4. Generate report.
5. Report archive.
6. QR validation.

### Phase 5 â€” Finance

1. Price list.
2. Ready to invoice.
3. Invoice.
4. Payment.
5. Outstanding.

### Phase 6 â€” Testing dan Deployment

1. Functional testing.
2. Role permission testing.
3. File upload testing.
4. Report PDF testing.
5. End-to-end testing.
6. Staging deployment.
7. Production deployment.

### Phase 7 â€” Mobile Surveyor

1. Flutter app.
2. Login.
3. Job saya.
4. Offline draft.
5. Camera/GPS.
6. Sync data.
7. Background upload.

---

## 40. Checklist Kelengkapan PRD

Checklist ini digunakan untuk memastikan kebutuhan utama tidak terlewat.

| Area | Status |
|---|---|
| Tujuan produk | Sudah dicakup |
| Scope MVP | Sudah dicakup |
| Future mobile scope | Sudah dicakup |
| Role user | Sudah dicakup |
| Menu web lengkap | Sudah dicakup |
| Alur end-to-end | Sudah dicakup |
| Super Admin flow | Sudah dicakup |
| Admin flow | Sudah dicakup |
| Surveyor web flow | Sudah dicakup |
| Supervisor review flow | Sudah dicakup |
| Finance flow | Sudah dicakup |
| Master data | Sudah dicakup |
| CEDEX master | Sudah dicakup |
| Numbering perusahaan | Sudah dicakup |
| Job order | Sudah dicakup |
| Assignment | Sudah dicakup |
| General survey form | Sudah dicakup |
| Checklist survey | Sudah dicakup |
| Survey sheet interaktif | Sudah dicakup |
| Damage input | Sudah dicakup |
| Photo evidence | Sudah dicakup |
| Submit validation | Sudah dicakup |
| Review dan approval | Sudah dicakup |
| Report PDF | Sudah dicakup |
| EIR | Sudah dicakup |
| Finance invoice | Sudah dicakup |
| Payment | Sudah dicakup |
| Status workflow | Sudah dicakup |
| Hak akses | Sudah dicakup |
| Data model | Sudah dicakup |
| API requirements | Sudah dicakup |
| Storage requirements | Sudah dicakup |
| Audit log | Sudah dicakup |
| Notification | Sudah dicakup |
| Non-functional requirements | Sudah dicakup |
| Acceptance criteria | Sudah dicakup |
| Testing scenario | Sudah dicakup |
| Risiko dan mitigasi | Sudah dicakup |
| Roadmap development | Sudah dicakup |

---

## 41. Catatan Akhir

PRD ini menetapkan bahwa sistem tahap awal dibuat sebagai Web Application lengkap untuk semua role, termasuk Surveyor Web Module. Namun, modul Surveyor di web digunakan untuk validasi alur dan MVP internal. Target operasional lapangan jangka panjang tetap Mobile Application berbasis Flutter, dengan backend API, database, dan storage yang sama.

Keputusan arsitektur utama:

```text
Web App = proses kantor, kontrol, validasi alur, dan MVP semua role
Surveyor Web = validasi alur sebelum mobile
Mobile App = target utama surveyor lapangan pada tahap lanjutan
Backend API = pusat proses bisnis
Database = satu sumber data utama
Storage = foto, PDF, invoice, bukti pembayaran
```

Dengan struktur ini, aplikasi dapat dibangun bertahap tanpa kehilangan arah, dan perubahan dari Surveyor Web ke Mobile Surveyor dapat dilakukan lebih aman karena alur, database, dan API sudah tervalidasi lebih dulu.

