# api_contract.md — Container Survey Management System

**Produk:** Container Survey Management System  
**Unit/Perusahaan:** GIFT / PT Global Inspeksi Sertifikasi Group  
**Versi Dokumen:** 1.0  
**Tanggal:** 24 Juni 2026  
**Status:** Draft kontrak API untuk development backend, web app, dan future mobile app  
**Basis Dokumen:** `prd.md` v1.0 dan `database_schema.md` v1.0  

---

## 1. Tujuan Dokumen

Dokumen ini mendefinisikan kontrak API untuk aplikasi **Container Survey Management System**. API ini digunakan oleh:

1. **Web Application** untuk Super Admin, Admin/Operasional, Surveyor Web Module, Supervisor, Finance, dan Management.
2. **Future Mobile Application** untuk Surveyor lapangan.
3. **Backend service internal** untuk proses seperti generate report, upload file, notification, dan audit log.

Kontrak API ini bertujuan agar frontend web, mobile app, dan backend dapat dikembangkan secara konsisten tanpa saling menebak format data, status, validasi, dan response error.

---

## 2. Prinsip API

API harus mengikuti prinsip berikut:

1. API menggunakan **REST API**.
2. Semua response menggunakan format JSON kecuali endpoint download file.
3. Semua endpoint private wajib menggunakan authentication.
4. Authorization berbasis role dan permission.
5. ID resource menggunakan UUID.
6. Semua list endpoint mendukung pagination.
7. Filter dan search dilakukan server-side.
8. Semua perubahan penting harus mencatat audit log.
9. File binary tidak dikirim sebagai base64 kecuali ada kebutuhan khusus; gunakan multipart upload.
10. API harus siap digunakan oleh mobile app di masa depan, bukan hanya web app.
11. Endpoint Surveyor harus mobile-friendly, ringan, dan mendukung sync/offline phase.
12. Operasi submit, approve, issue invoice, dan payment harus aman dari double submit.

---

## 3. Base URL dan Environment

### 3.1 Environment

| Environment | Base URL Contoh | Keterangan |
|---|---|---|
| Development | `http://localhost:8080/api/v1` | Lokal developer |
| Staging | `https://staging-api.gift-survey.co.id/api/v1` | Testing internal |
| Production | `https://api.gift-survey.co.id/api/v1` | Live production |

### 3.2 API Versioning

Versi API ditempatkan pada path:

```text
/api/v1
```

Jika terjadi breaking change besar, versi baru dibuat:

```text
/api/v2
```

---

## 4. Authentication dan Header

### 4.1 Authentication Type

API menggunakan:

```text
JWT Access Token + Refresh Token
```

Access token dikirim melalui header:

```http
Authorization: Bearer <access_token>
```

### 4.2 Standard Request Header

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <access_token>
X-Request-Id: optional-client-generated-request-id
X-Idempotency-Key: optional-for-submit-like-actions
```

Untuk upload file:

```http
Content-Type: multipart/form-data
```

### 4.3 Standard Response Header

```http
Content-Type: application/json
X-Request-Id: server-or-client-request-id
```

---

## 5. Format Response Standar

### 5.1 Success Response — Object

```json
{
  "success": true,
  "message": "Data berhasil diambil.",
  "data": {
    "id": "2c4d4f5e-7e78-4c2a-9d5d-b7f3a4c2a111"
  },
  "meta": null
}
```

### 5.2 Success Response — List Pagination

```json
{
  "success": true,
  "message": "Data berhasil diambil.",
  "data": [
    {
      "id": "2c4d4f5e-7e78-4c2a-9d5d-b7f3a4c2a111"
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5,
    "has_next": true,
    "has_prev": false
  }
}
```

### 5.3 Error Response

```json
{
  "success": false,
  "message": "Validasi gagal.",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "container_no",
        "message": "Container no wajib diisi."
      }
    ]
  },
  "meta": null
}
```

### 5.4 Standard HTTP Status Code

| Status | Penggunaan |
|---:|---|
| 200 | Success GET/PUT/PATCH |
| 201 | Created |
| 202 | Accepted untuk background process |
| 204 | Success tanpa body, misalnya delete |
| 400 | Bad request |
| 401 | Unauthorized / token tidak valid |
| 403 | Forbidden / tidak punya permission |
| 404 | Resource tidak ditemukan |
| 409 | Conflict, misalnya duplicate atau status tidak valid |
| 422 | Validation error |
| 429 | Rate limit |
| 500 | Internal server error |

### 5.5 Standard Error Code

| Code | Arti |
|---|---|
| `UNAUTHORIZED` | Token tidak ada/tidak valid |
| `FORBIDDEN` | User tidak memiliki akses |
| `NOT_FOUND` | Data tidak ditemukan |
| `VALIDATION_ERROR` | Input tidak valid |
| `DUPLICATE_RESOURCE` | Data duplikat |
| `INVALID_STATUS_TRANSITION` | Perubahan status tidak diperbolehkan |
| `FILE_TOO_LARGE` | File melebihi batas |
| `UNSUPPORTED_FILE_TYPE` | Tipe file tidak didukung |
| `CHECK_DIGIT_INVALID` | Nomor container invalid |
| `SURVEY_SUBMIT_BLOCKED` | Survey belum memenuhi syarat submit |
| `REPORT_GENERATION_FAILED` | Generate report gagal |
| `INVOICE_ALREADY_EXISTS` | Report/job sudah ditagih |
| `PAYMENT_EXCEEDS_INVOICE_TOTAL` | Payment melebihi tagihan |
| `INTERNAL_ERROR` | Error internal |

---

## 6. Pagination, Search, Filter, dan Sorting

### 6.1 Query Pagination

Semua endpoint list menggunakan query:

```text
?page=1&per_page=20
```

Default:

```text
page = 1
per_page = 20
max_per_page = 100
```

### 6.2 Search

```text
?search=keyword
```

### 6.3 Sorting

```text
?sort_by=created_at&sort_order=desc
```

`sort_order`:

```text
asc, desc
```

### 6.4 Filter Tanggal

```text
?date_from=2026-06-01&date_to=2026-06-30
```

### 6.5 Filter Status

```text
?status=submitted
```

---

## 7. Common Data Type dan Format

| Data | Format |
|---|---|
| UUID | string UUID v4 |
| Date | `YYYY-MM-DD` |
| Datetime | ISO 8601, contoh `2026-06-24T10:30:00+07:00` |
| Currency amount | decimal number, contoh `150000.00` |
| Boolean | true/false |
| File path | string path object storage |
| Coordinates | decimal latitude/longitude |

---

## 8. Common Object

### 8.1 User Summary

```json
{
  "id": "uuid",
  "name": "Budi Surveyor",
  "email": "budi@example.com",
  "status": "active"
}
```

### 8.2 Customer Summary

```json
{
  "id": "uuid",
  "customer_code": "CUST-001",
  "customer_name": "PT ABC Logistics"
}
```

### 8.3 Job Summary

```json
{
  "id": "uuid",
  "job_order_no": "GIFT-JO-2026-000001",
  "customer_name": "PT ABC Logistics",
  "survey_type_name": "Gate In Survey",
  "location_name": "Tanjung Priok Yard",
  "status": "assigned"
}
```

### 8.4 Container Summary

```json
{
  "id": "uuid",
  "container_no": "MSKU1234567",
  "container_type_code": "20GP",
  "seal_no": "ABC123",
  "cargo_status": "empty",
  "status": "assigned"
}
```

---

## 9. Auth API

### 9.1 Login

```http
POST /api/v1/auth/login
```

Request:

```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

Response `200`:

```json
{
  "success": true,
  "message": "Login berhasil.",
  "data": {
    "access_token": "jwt_access_token",
    "refresh_token": "jwt_refresh_token",
    "token_type": "Bearer",
    "expires_in": 3600,
    "user": {
      "id": "uuid",
      "name": "Admin Operasional",
      "email": "admin@example.com",
      "roles": ["admin"],
      "permissions": ["jobs.read", "jobs.create"]
    }
  },
  "meta": null
}
```

### 9.2 Logout

```http
POST /api/v1/auth/logout
```

Response `200`:

```json
{
  "success": true,
  "message": "Logout berhasil.",
  "data": null,
  "meta": null
}
```

### 9.3 Refresh Token

```http
POST /api/v1/auth/refresh
```

Request:

```json
{
  "refresh_token": "jwt_refresh_token"
}
```

Response `200`:

```json
{
  "success": true,
  "message": "Token berhasil diperbarui.",
  "data": {
    "access_token": "new_access_token",
    "refresh_token": "new_refresh_token",
    "token_type": "Bearer",
    "expires_in": 3600
  },
  "meta": null
}
```

### 9.4 Get Current User

```http
GET /api/v1/me
```

Response `200`:

```json
{
  "success": true,
  "message": "User berhasil diambil.",
  "data": {
    "id": "uuid",
    "name": "Admin Operasional",
    "email": "admin@example.com",
    "roles": ["admin"],
    "permissions": ["jobs.read", "jobs.create", "jobs.assign"],
    "profile": {
      "surveyor_profile_id": null
    }
  },
  "meta": null
}
```

### 9.5 Forgot Password

```http
POST /api/v1/auth/forgot-password
```

Request:

```json
{
  "email": "user@example.com"
}
```

### 9.6 Reset Password

```http
POST /api/v1/auth/reset-password
```

Request:

```json
{
  "token": "reset_token",
  "password": "new_password",
  "password_confirmation": "new_password"
}
```

---

## 10. User, Role, Permission API

### 10.1 List Users

```http
GET /api/v1/users?page=1&per_page=20&search=budi&status=active
```

Permission:

```text
users.read
```

Response item:

```json
{
  "id": "uuid",
  "name": "Budi Surveyor",
  "email": "budi@example.com",
  "status": "active",
  "roles": ["surveyor"],
  "created_at": "2026-06-24T10:00:00+07:00"
}
```

### 10.2 Create User

```http
POST /api/v1/users
```

Request:

```json
{
  "name": "Budi Surveyor",
  "email": "budi@example.com",
  "password": "password123",
  "status": "active",
  "role_ids": ["uuid-role-surveyor"]
}
```

### 10.3 Update User

```http
PUT /api/v1/users/{id}
```

Request:

```json
{
  "name": "Budi Surveyor",
  "email": "budi@example.com",
  "status": "active",
  "role_ids": ["uuid-role-surveyor"]
}
```

### 10.4 Reset User Password by Admin

```http
POST /api/v1/users/{id}/reset-password
```

Request:

```json
{
  "new_password": "new_password123"
}
```

### 10.5 Roles

```http
GET    /api/v1/roles
POST   /api/v1/roles
GET    /api/v1/roles/{id}
PUT    /api/v1/roles/{id}
DELETE /api/v1/roles/{id}
```

Create role request:

```json
{
  "name": "supervisor",
  "display_name": "Supervisor / Approver",
  "permission_ids": ["uuid-permission-1", "uuid-permission-2"]
}
```

### 10.6 Permissions

```http
GET /api/v1/permissions
```

Response item:

```json
{
  "id": "uuid",
  "name": "surveys.approve",
  "module": "review",
  "description": "Approve hasil survey"
}
```

---

## 11. Company Profile dan Setting API

### 11.1 Get Company Profile

```http
GET /api/v1/settings/company-profile
```

### 11.2 Update Company Profile

```http
PUT /api/v1/settings/company-profile
```

Request:

```json
{
  "company_name": "GIFT",
  "legal_name": "PT Global Inspeksi Sertifikasi Group",
  "address": "Alamat perusahaan",
  "phone": "021-xxxx",
  "email": "info@example.com",
  "website": "https://example.com",
  "tax_no": "NPWP",
  "bank_name": "Bank ABC",
  "bank_account_no": "1234567890",
  "bank_account_name": "PT Global Inspeksi Sertifikasi"
}
```

### 11.3 Upload Company Logo

```http
POST /api/v1/settings/company-profile/logo
```

Request multipart:

| Field | Type | Wajib |
|---|---|---:|
| file | file | Ya |

---

## 12. Numbering Setting API

### 12.1 List Numbering Settings

```http
GET /api/v1/settings/numbering
```

Response item:

```json
{
  "id": "uuid",
  "document_type": "job_order",
  "prefix": "GIFT",
  "code": "JO",
  "year": 2026,
  "current_number": 15,
  "padding": 6,
  "format": "{PREFIX}-{CODE}-{YEAR}-{NUMBER}",
  "is_active": true
}
```

### 12.2 Update Numbering Setting

```http
PUT /api/v1/settings/numbering/{id}
```

Request:

```json
{
  "prefix": "GIFT",
  "code": "JO",
  "padding": 6,
  "format": "{PREFIX}-{CODE}-{YEAR}-{NUMBER}",
  "is_active": true
}
```

### 12.3 Preview Next Number

```http
GET /api/v1/settings/numbering/{document_type}/preview
```

Response:

```json
{
  "success": true,
  "message": "Preview nomor berhasil dibuat.",
  "data": {
    "document_type": "job_order",
    "next_number": "GIFT-JO-2026-000016"
  },
  "meta": null
}
```

---

## 13. Master Data API

### 13.1 Customers

```http
GET    /api/v1/master/customers
POST   /api/v1/master/customers
GET    /api/v1/master/customers/{id}
PUT    /api/v1/master/customers/{id}
DELETE /api/v1/master/customers/{id}
```

Create customer request:

```json
{
  "customer_code": "CUST-001",
  "customer_name": "PT ABC Logistics",
  "address": "Jakarta",
  "npwp": "00.000.000.0-000.000",
  "pic_name": "Andi",
  "pic_phone": "08123456789",
  "pic_email": "andi@example.com",
  "billing_address": "Jakarta",
  "payment_term_days": 30,
  "status": "active"
}
```

### 13.2 Locations

```http
GET    /api/v1/master/locations
POST   /api/v1/master/locations
GET    /api/v1/master/locations/{id}
PUT    /api/v1/master/locations/{id}
DELETE /api/v1/master/locations/{id}
```

Create location request:

```json
{
  "location_code": "LOC-001",
  "location_name": "Tanjung Priok Yard",
  "location_type": "yard",
  "address": "Tanjung Priok",
  "city": "Jakarta",
  "gps_latitude": -6.123456,
  "gps_longitude": 106.123456,
  "pic_name": "PIC Yard",
  "pic_phone": "08123456789",
  "status": "active"
}
```

### 13.3 Surveyors

```http
GET    /api/v1/master/surveyors
POST   /api/v1/master/surveyors
GET    /api/v1/master/surveyors/{id}
PUT    /api/v1/master/surveyors/{id}
DELETE /api/v1/master/surveyors/{id}
```

Create surveyor request:

```json
{
  "surveyor_code": "SVR-001",
  "user_id": "uuid-user",
  "name": "Budi Surveyor",
  "phone": "08123456789",
  "area": "Jakarta",
  "status": "active"
}
```

### 13.4 Container Types

```http
GET    /api/v1/master/container-types
POST   /api/v1/master/container-types
GET    /api/v1/master/container-types/{id}
PUT    /api/v1/master/container-types/{id}
DELETE /api/v1/master/container-types/{id}
```

Create request:

```json
{
  "code": "20GP",
  "iso_code": "22G1",
  "size": "20 Feet",
  "type": "General Purpose",
  "description": "Dry container 20 feet",
  "status": "active"
}
```

### 13.5 Survey Types

```http
GET    /api/v1/master/survey-types
POST   /api/v1/master/survey-types
GET    /api/v1/master/survey-types/{id}
PUT    /api/v1/master/survey-types/{id}
DELETE /api/v1/master/survey-types/{id}
```

Create request:

```json
{
  "code": "GI",
  "name": "Gate In Survey",
  "description": "Survey saat container masuk yard/depot",
  "requires_eir": true,
  "requires_light_test": false,
  "status": "active"
}
```

---

## 14. Master CEDEX API

### 14.1 CEDEX Locations

```http
GET    /api/v1/master/cedex/locations?face=left&container_size=all
POST   /api/v1/master/cedex/locations
GET    /api/v1/master/cedex/locations/{id}
PUT    /api/v1/master/cedex/locations/{id}
DELETE /api/v1/master/cedex/locations/{id}
```

Create request:

```json
{
  "code": "L3",
  "face": "left",
  "grid_code": "L3",
  "cedex_mapping_code": "optional-technical-code",
  "container_size": "all",
  "description": "Left side section 3",
  "status": "active"
}
```

### 14.2 CEDEX Components

```http
GET    /api/v1/master/cedex/components
POST   /api/v1/master/cedex/components
GET    /api/v1/master/cedex/components/{id}
PUT    /api/v1/master/cedex/components/{id}
DELETE /api/v1/master/cedex/components/{id}
```

Create request:

```json
{
  "code": "SP",
  "component_name": "Side Panel",
  "description": "Panel samping container",
  "status": "active"
}
```

### 14.3 CEDEX Damages

```http
GET    /api/v1/master/cedex/damages
POST   /api/v1/master/cedex/damages
GET    /api/v1/master/cedex/damages/{id}
PUT    /api/v1/master/cedex/damages/{id}
DELETE /api/v1/master/cedex/damages/{id}
```

Create request:

```json
{
  "code": "DT",
  "damage_name": "Dent",
  "description": "Penyok",
  "status": "active"
}
```

### 14.4 CEDEX Repairs

```http
GET    /api/v1/master/cedex/repairs
POST   /api/v1/master/cedex/repairs
GET    /api/v1/master/cedex/repairs/{id}
PUT    /api/v1/master/cedex/repairs/{id}
DELETE /api/v1/master/cedex/repairs/{id}
```

Create request:

```json
{
  "code": "ST",
  "repair_name": "Straighten",
  "description": "Diluruskan",
  "status": "active"
}
```

### 14.5 CEDEX Materials

```http
GET    /api/v1/master/cedex/materials
POST   /api/v1/master/cedex/materials
PUT    /api/v1/master/cedex/materials/{id}
DELETE /api/v1/master/cedex/materials/{id}
```

### 14.6 Responsibility Codes

```http
GET    /api/v1/master/responsibility-codes
POST   /api/v1/master/responsibility-codes
PUT    /api/v1/master/responsibility-codes/{id}
DELETE /api/v1/master/responsibility-codes/{id}
```

---

## 15. Checklist Template API

Checklist template dipakai agar checklist dapat berbeda berdasarkan survey type.

### 15.1 List Checklist Templates

```http
GET /api/v1/master/checklist-templates?survey_type_id=uuid
```

Response item:

```json
{
  "id": "uuid",
  "survey_type_id": "uuid",
  "section": "General",
  "item_key": "container_number_readable",
  "label": "Container number readable",
  "input_type": "yes_no_na",
  "is_required": true,
  "sort_order": 1,
  "status": "active"
}
```

### 15.2 Create Checklist Template

```http
POST /api/v1/master/checklist-templates
```

Request:

```json
{
  "survey_type_id": "uuid-survey-type",
  "section": "General",
  "item_key": "container_number_readable",
  "label": "Container number readable",
  "input_type": "yes_no_na",
  "is_required": true,
  "sort_order": 1,
  "status": "active"
}
```

---

## 16. Job Order API

### 16.1 List Jobs

```http
GET /api/v1/jobs?page=1&per_page=20&status=assigned&customer_id=uuid&date_from=2026-06-01&date_to=2026-06-30&search=GIFT-JO
```

Permission:

```text
jobs.read
```

Response item:

```json
{
  "id": "uuid",
  "job_order_no": "GIFT-JO-2026-000001",
  "job_date": "2026-06-24",
  "customer": {
    "id": "uuid",
    "customer_name": "PT ABC Logistics"
  },
  "survey_type": {
    "id": "uuid",
    "name": "Gate In Survey"
  },
  "location": {
    "id": "uuid",
    "location_name": "Tanjung Priok Yard"
  },
  "priority": "normal",
  "status": "assigned",
  "total_containers": 10,
  "created_at": "2026-06-24T10:00:00+07:00"
}
```

### 16.2 Create Job

```http
POST /api/v1/jobs
```

Permission:

```text
jobs.create
```

Request:

```json
{
  "job_date": "2026-06-24",
  "customer_id": "uuid-customer",
  "survey_type_id": "uuid-survey-type",
  "location_id": "uuid-location",
  "pic_customer_name": "Andi",
  "pic_customer_phone": "08123456789",
  "pic_customer_email": "andi@example.com",
  "reference_no": "REF-001",
  "booking_no": "BOOK-001",
  "do_no": "DO-001",
  "bl_no": "BL-001",
  "vessel": "VESSEL NAME",
  "voyage": "VOY-001",
  "trucking_company": "PT Trucking",
  "priority": "normal",
  "deadline": "2026-06-25T17:00:00+07:00",
  "instruction": "Survey dilakukan saat gate in."
}
```

Response `201`:

```json
{
  "success": true,
  "message": "Job order berhasil dibuat.",
  "data": {
    "id": "uuid",
    "job_order_no": "GIFT-JO-2026-000001",
    "status": "draft"
  },
  "meta": null
}
```

### 16.3 Get Job Detail

```http
GET /api/v1/jobs/{id}
```

Response includes:

1. Header job.
2. Customer.
3. Location.
4. Survey type.
5. Containers summary.
6. Assignment summary.
7. Status timeline.

### 16.4 Update Job

```http
PUT /api/v1/jobs/{id}
```

Aturan:

1. Job dapat diedit selama status `draft` atau `assigned` dengan batasan.
2. Job `cancelled`, `closed`, atau `paid` tidak boleh diedit oleh Admin biasa.

### 16.5 Cancel Job

```http
POST /api/v1/jobs/{id}/cancel
```

Request:

```json
{
  "reason": "Job dibatalkan oleh customer."
}
```

### 16.6 Job Timeline

```http
GET /api/v1/jobs/{id}/timeline
```

Response item:

```json
{
  "id": "uuid",
  "event": "job_created",
  "description": "Job order dibuat.",
  "actor": "Admin Operasional",
  "created_at": "2026-06-24T10:00:00+07:00"
}
```

---

## 17. Job Container API

### 17.1 List Containers in Job

```http
GET /api/v1/jobs/{job_id}/containers?page=1&per_page=50&status=assigned
```

Response item:

```json
{
  "id": "uuid",
  "container_no": "MSKU1234567",
  "check_digit_status": "valid",
  "container_type": {
    "id": "uuid",
    "code": "20GP"
  },
  "iso_type_code": "22G1",
  "seal_no": "ABC123",
  "cargo_status": "empty",
  "truck_no": "B1234ABC",
  "driver_name": "Driver Name",
  "status": "assigned"
}
```

### 17.2 Add Container to Job

```http
POST /api/v1/jobs/{job_id}/containers
```

Request:

```json
{
  "container_no": "MSKU1234567",
  "container_type_id": "uuid-container-type",
  "iso_type_code": "22G1",
  "seal_no": "ABC123",
  "cargo_status": "empty",
  "truck_no": "B1234ABC",
  "driver_name": "Driver Name",
  "csc_plate_status": "not_checked",
  "remark": "Container masuk yard."
}
```

Response `201`:

```json
{
  "success": true,
  "message": "Container berhasil ditambahkan.",
  "data": {
    "id": "uuid",
    "container_no": "MSKU1234567",
    "check_digit_status": "valid",
    "status": "not_started"
  },
  "meta": null
}
```

### 17.3 Import Containers

```http
POST /api/v1/jobs/{job_id}/containers/import
```

Request multipart:

| Field | Type | Wajib |
|---|---|---:|
| file | `.xlsx` | Ya |

Expected Excel columns:

```text
container_no, container_type_code, iso_type_code, seal_no, cargo_status, truck_no, driver_name, remark
```

Response `200`:

```json
{
  "success": true,
  "message": "Import selesai.",
  "data": {
    "total_rows": 10,
    "imported": 9,
    "failed": 1,
    "errors": [
      {
        "row": 5,
        "field": "container_no",
        "message": "Container no duplikat dalam job."
      }
    ]
  },
  "meta": null
}
```

### 17.4 Update Job Container

```http
PUT /api/v1/job-containers/{id}
```

### 17.5 Delete Job Container

```http
DELETE /api/v1/job-containers/{id}
```

Aturan:

1. Container tidak dapat dihapus jika survey sudah `submitted` atau lebih lanjut.
2. Jika perlu, gunakan `cancel` dengan alasan.

### 17.6 Validate Container Number

```http
POST /api/v1/job-containers/validate-container-no
```

Request:

```json
{
  "container_no": "MSKU1234567"
}
```

Response:

```json
{
  "success": true,
  "message": "Validasi selesai.",
  "data": {
    "container_no": "MSKU1234567",
    "is_format_valid": true,
    "is_check_digit_valid": true,
    "owner_code": "MSK",
    "equipment_identifier": "U",
    "serial_number": "123456",
    "check_digit": "7"
  },
  "meta": null
}
```

---

## 18. Assignment API

### 18.1 Assign Surveyor

```http
POST /api/v1/jobs/{job_id}/assign
```

Request for all containers:

```json
{
  "surveyor_id": "uuid-surveyor",
  "container_ids": ["uuid-container-1", "uuid-container-2"],
  "start_date": "2026-06-24T09:00:00+07:00",
  "due_date": "2026-06-24T17:00:00+07:00",
  "instruction": "Prioritaskan container laden."
}
```

Response:

```json
{
  "success": true,
  "message": "Surveyor berhasil ditugaskan.",
  "data": {
    "assignment_no": "GIFT-ASG-2026-000001",
    "status": "assigned",
    "assigned_containers": 2
  },
  "meta": null
}
```

### 18.2 List Assignments

```http
GET /api/v1/jobs/{job_id}/assignments
```

### 18.3 Reassign Container

```http
POST /api/v1/job-containers/{container_id}/reassign
```

Request:

```json
{
  "from_surveyor_id": "uuid-surveyor-a",
  "to_surveyor_id": "uuid-surveyor-b",
  "reason": "Surveyor A berhalangan."
}
```

Aturan:

1. Reassign harus mencatat audit log.
2. Container yang sudah approved tidak bisa di-reassign.

### 18.4 Accept Assignment

```http
POST /api/v1/assignments/{id}/accept
```

Digunakan opsional untuk Surveyor Web/Mobile jika perusahaan ingin ada proses accept job.

---

## 19. Surveyor API

Endpoint ini digunakan oleh Surveyor Web Module dan future Mobile App.

### 19.1 Dashboard Surveyor

```http
GET /api/v1/surveyor/dashboard
```

Response:

```json
{
  "success": true,
  "message": "Dashboard surveyor berhasil diambil.",
  "data": {
    "total_jobs": 5,
    "not_started": 2,
    "draft": 1,
    "submitted": 1,
    "need_revision": 1,
    "approved": 0
  },
  "meta": null
}
```

### 19.2 Job Saya

```http
GET /api/v1/surveyor/jobs?page=1&per_page=20&status=assigned&date=2026-06-24
```

Response item:

```json
{
  "id": "uuid-job",
  "job_order_no": "GIFT-JO-2026-000001",
  "customer_name": "PT ABC Logistics",
  "location_name": "Tanjung Priok Yard",
  "survey_type_name": "Gate In Survey",
  "total_containers": 10,
  "completed_containers": 2,
  "status": "assigned",
  "deadline": "2026-06-24T17:00:00+07:00"
}
```

### 19.3 Detail Job Saya

```http
GET /api/v1/surveyor/jobs/{job_id}
```

Response includes assigned containers only.

### 19.4 Container Saya dalam Job

```http
GET /api/v1/surveyor/jobs/{job_id}/containers
```

Response item:

```json
{
  "id": "uuid-job-container",
  "container_no": "MSKU1234567",
  "container_type_code": "20GP",
  "seal_no": "ABC123",
  "cargo_status": "empty",
  "survey_id": "uuid-survey-or-null",
  "survey_no": "GIFT-SVY-2026-000001",
  "status": "draft"
}
```

---

## 20. Survey API

### 20.1 Start Survey

```http
POST /api/v1/surveys/start
```

Request:

```json
{
  "job_container_id": "uuid-job-container"
}
```

Response `201`:

```json
{
  "success": true,
  "message": "Survey berhasil dimulai.",
  "data": {
    "id": "uuid-survey",
    "survey_no": "GIFT-SVY-2026-000001",
    "status": "draft",
    "job_order_no": "GIFT-JO-2026-000001",
    "container_no": "MSKU1234567"
  },
  "meta": null
}
```

Aturan:

1. Jika survey sudah ada untuk job_container tersebut, API mengembalikan survey yang sudah ada.
2. Survey No hanya dibuat satu kali.
3. Hanya surveyor yang ditugaskan yang dapat start survey.

### 20.2 Get Survey Detail

```http
GET /api/v1/surveys/{id}
```

Response includes:

1. General info.
2. Checklist.
3. Survey sheet markers.
4. Damage list.
5. Photos.
6. Revision notes.
7. Report summary jika ada.

### 20.3 Update General Info

```http
PUT /api/v1/surveys/{id}/general-info
```

Request:

```json
{
  "survey_date_time": "2026-06-24T10:30:00+07:00",
  "cargo_status": "empty",
  "seal_no": "ABC123",
  "truck_no": "B1234ABC",
  "driver_name": "Driver Name",
  "chassis_no": "CHS-001",
  "csc_plate_status": "available",
  "door_status": "closed",
  "general_condition": "damage",
  "weather": "Sunny",
  "gps_latitude": -6.123456,
  "gps_longitude": 106.123456,
  "general_remark": "Container masuk yard."
}
```

Aturan:

1. Hanya bisa update status `draft` atau `need_revision`.
2. Jika `cargo_status = laden`, `seal_no` wajib kecuali override rule.

### 20.4 Get Survey Checklist

```http
GET /api/v1/surveys/{id}/checklist
```

### 20.5 Update Survey Checklist

```http
PUT /api/v1/surveys/{id}/checklist
```

Request:

```json
{
  "items": [
    {
      "item_key": "container_number_readable",
      "value": "yes",
      "note": null
    },
    {
      "item_key": "light_test_pass",
      "value": "pass",
      "note": "Tidak ditemukan cahaya masuk."
    }
  ]
}
```

Response:

```json
{
  "success": true,
  "message": "Checklist berhasil disimpan.",
  "data": {
    "survey_id": "uuid-survey",
    "total_items": 15,
    "completed_items": 15
  },
  "meta": null
}
```

### 20.6 Get Survey Sheet Data

```http
GET /api/v1/surveys/{id}/sheet
```

Response:

```json
{
  "success": true,
  "message": "Survey sheet berhasil diambil.",
  "data": {
    "faces": [
      {
        "face": "left",
        "label": "Left Side",
        "locations": [
          {
            "code": "L1",
            "label": "L1",
            "has_damage": false,
            "damage_markers": []
          },
          {
            "code": "L3",
            "label": "L3",
            "has_damage": true,
            "damage_markers": [
              {
                "damage_id": "uuid-damage",
                "damage_no": "D-001",
                "severity": "minor"
              }
            ]
          }
        ]
      }
    ]
  },
  "meta": null
}
```

### 20.7 Preview Survey

```http
GET /api/v1/surveys/{id}/preview
```

Response includes validation warnings.

```json
{
  "success": true,
  "message": "Preview survey berhasil diambil.",
  "data": {
    "survey_no": "GIFT-SVY-2026-000001",
    "container_no": "MSKU1234567",
    "survey_result_recommendation": "damage",
    "can_submit": false,
    "warnings": [
      {
        "code": "DAMAGE_PHOTO_REQUIRED",
        "message": "Damage D-001 belum memiliki foto."
      }
    ]
  },
  "meta": null
}
```

### 20.8 Submit Survey

```http
POST /api/v1/surveys/{id}/submit
```

Headers:

```http
X-Idempotency-Key: unique-key-submit-survey
```

Request:

```json
{
  "final_remark": "Survey selesai dan siap direview."
}
```

Response:

```json
{
  "success": true,
  "message": "Survey berhasil disubmit.",
  "data": {
    "id": "uuid-survey",
    "survey_no": "GIFT-SVY-2026-000001",
    "status": "submitted",
    "submitted_at": "2026-06-24T11:00:00+07:00"
  },
  "meta": null
}
```

Validasi submit:

1. General info wajib lengkap.
2. Checklist wajib lengkap.
3. Damage wajib memiliki component dan damage type.
4. Damage wajib memiliki foto minimal 1.
5. Damage major/critical wajib memiliki ukuran.
6. Seal no wajib untuk laden container kecuali override.
7. Survey result harus tersedia.

---

## 21. Damage API

### 21.1 List Damage by Survey

```http
GET /api/v1/surveys/{survey_id}/damages
```

Response item:

```json
{
  "id": "uuid-damage",
  "damage_no": "D-001",
  "face": "left",
  "internal_location": "L3",
  "cedex_location_code": "L3",
  "component": {
    "code": "SP",
    "name": "Side Panel"
  },
  "damage": {
    "code": "DT",
    "name": "Dent"
  },
  "repair": {
    "code": "ST",
    "name": "Straighten"
  },
  "severity": "minor",
  "length": 30,
  "width": 20,
  "depth": 2,
  "unit": "cm",
  "photo_count": 1,
  "remark": "Penyok ringan pada panel kiri."
}
```

### 21.2 Create Damage

```http
POST /api/v1/surveys/{survey_id}/damages
```

Request:

```json
{
  "face": "left",
  "internal_location": "L3",
  "cedex_location_code": "L3",
  "component_code_id": "uuid-component",
  "damage_code_id": "uuid-damage-code",
  "repair_code_id": "uuid-repair",
  "material_code_id": "uuid-material",
  "responsibility_code_id": "uuid-responsibility",
  "severity": "minor",
  "quantity": 1,
  "length": 30,
  "width": 20,
  "depth": 2,
  "unit": "cm",
  "is_repair_required": true,
  "is_cargo_worthy_impact": false,
  "remark": "Penyok ringan pada panel kiri."
}
```

Response `201`:

```json
{
  "success": true,
  "message": "Damage berhasil ditambahkan.",
  "data": {
    "id": "uuid-damage",
    "damage_no": "D-001",
    "face": "left",
    "internal_location": "L3",
    "severity": "minor"
  },
  "meta": null
}
```

### 21.3 Get Damage Detail

```http
GET /api/v1/survey-damages/{id}
```

### 21.4 Update Damage

```http
PUT /api/v1/survey-damages/{id}
```

Aturan:

1. Hanya dapat update jika survey status `draft` atau `need_revision`.
2. Update damage setelah submit tidak diperbolehkan kecuali status dikembalikan menjadi `need_revision`.

### 21.5 Delete Damage

```http
DELETE /api/v1/survey-damages/{id}
```

Aturan:

1. Delete damage hanya soft delete.
2. Hapus damage wajib masuk audit log.
3. File foto yang terkait tidak langsung dihapus fisik sebelum retention policy dipenuhi.

---

## 22. Photo Evidence API

### 22.1 List Survey Photos

```http
GET /api/v1/surveys/{survey_id}/photos
```

Response item:

```json
{
  "id": "uuid-photo",
  "photo_type": "damage",
  "damage_id": "uuid-damage",
  "damage_no": "D-001",
  "file_url": "signed-or-proxy-url",
  "thumbnail_url": "signed-or-proxy-thumbnail-url",
  "caption": "Foto penyok L3",
  "taken_at": "2026-06-24T10:45:00+07:00",
  "uploaded_by": "Budi Surveyor"
}
```

### 22.2 Upload General Photo

```http
POST /api/v1/surveys/{survey_id}/photos
```

Request multipart:

| Field | Type | Wajib | Keterangan |
|---|---|---:|---|
| file | file | Ya | JPG/PNG/WebP |
| photo_type | string | Ya | general/document |
| category | string | Tidak | container_number/csc_plate/exterior/interior/door/floor/roof/seal/additional |
| caption | text | Tidak | Caption |
| taken_at | datetime | Tidak | Waktu foto |

Response:

```json
{
  "success": true,
  "message": "Foto berhasil diupload.",
  "data": {
    "id": "uuid-photo",
    "file_path": "/surveys/2026/06/GIFT-SVY-2026-000001/general/photo.jpg",
    "thumbnail_path": "/surveys/2026/06/GIFT-SVY-2026-000001/general/thumb-photo.jpg"
  },
  "meta": null
}
```

### 22.3 Upload Damage Photo

```http
POST /api/v1/survey-damages/{damage_id}/photos
```

Request multipart:

| Field | Type | Wajib |
|---|---|---:|
| file | file | Ya |
| caption | text | Tidak |
| taken_at | datetime | Tidak |
| gps_latitude | decimal | Tidak |
| gps_longitude | decimal | Tidak |

### 22.4 Delete Photo

```http
DELETE /api/v1/survey-photos/{id}
```

Aturan:

1. Foto hanya bisa dihapus jika survey masih draft/need_revision.
2. Delete photo mencatat audit log.
3. Jika foto adalah satu-satunya foto damage, sistem menandai survey tidak bisa submit.

### 22.5 File Validation

Default batas file:

| Jenis | Batas |
|---|---:|
| Photo | 10 MB per file |
| PDF upload optional | 20 MB per file |
| Payment proof | 10 MB per file |

Allowed mime:

```text
image/jpeg, image/png, image/webp, application/pdf
```

---

## 23. Review dan Approval API

### 23.1 Pending Review

```http
GET /api/v1/reviews/pending?page=1&per_page=20&customer_id=uuid&survey_type_id=uuid
```

Response item:

```json
{
  "survey_id": "uuid-survey",
  "survey_no": "GIFT-SVY-2026-000001",
  "job_order_no": "GIFT-JO-2026-000001",
  "container_no": "MSKU1234567",
  "customer_name": "PT ABC Logistics",
  "surveyor_name": "Budi Surveyor",
  "survey_type_name": "Gate In Survey",
  "submitted_at": "2026-06-24T11:00:00+07:00",
  "status": "submitted"
}
```

### 23.2 Detail Review

```http
GET /api/v1/reviews/{survey_id}
```

Response includes full survey detail for review.

### 23.3 Need Revision

```http
POST /api/v1/reviews/{survey_id}/need-revision
```

Request:

```json
{
  "revision_note": "Foto D-001 kurang jelas, mohon upload ulang. Checklist Light Test belum diisi."
}
```

Response:

```json
{
  "success": true,
  "message": "Survey dikembalikan untuk revisi.",
  "data": {
    "survey_id": "uuid-survey",
    "status": "need_revision"
  },
  "meta": null
}
```

### 23.4 Approve Survey

```http
POST /api/v1/reviews/{survey_id}/approve
```

Headers:

```http
X-Idempotency-Key: unique-key-approve-survey
```

Request:

```json
{
  "final_result": "damage",
  "approval_note": "Data survey sudah sesuai.",
  "generate_report": true
}
```

Response:

```json
{
  "success": true,
  "message": "Survey berhasil disetujui.",
  "data": {
    "survey_id": "uuid-survey",
    "status": "approved",
    "report_no": "GIFT-RPT-2026-000001",
    "report_generation_status": "queued"
  },
  "meta": null
}
```

Aturan:

1. Hanya survey status `submitted` yang bisa di-approve.
2. Approval membuat survey terkunci.
3. Report No dibuat setelah approve.
4. Jika `generate_report = true`, backend membuat job queue untuk PDF.

### 23.5 Reject Survey

```http
POST /api/v1/reviews/{survey_id}/reject
```

Request:

```json
{
  "rejection_reason": "Survey tidak dapat diterima karena data container tidak sesuai."
}
```

---

## 24. Report API

### 24.1 List Reports

```http
GET /api/v1/reports?page=1&per_page=20&customer_id=uuid&status=generated&search=GIFT-RPT
```

Response item:

```json
{
  "id": "uuid-report",
  "report_no": "GIFT-RPT-2026-000001",
  "revision_no": 0,
  "job_order_no": "GIFT-JO-2026-000001",
  "survey_no": "GIFT-SVY-2026-000001",
  "container_no": "MSKU1234567",
  "customer_name": "PT ABC Logistics",
  "status": "generated",
  "file_url": "signed-or-proxy-url",
  "created_at": "2026-06-24T11:30:00+07:00"
}
```

### 24.2 Generate Report

```http
POST /api/v1/reports/generate/{survey_id}
```

Request:

```json
{
  "report_type": "container_inspection_report"
}
```

Response `202`:

```json
{
  "success": true,
  "message": "Generate report masuk antrean.",
  "data": {
    "survey_id": "uuid-survey",
    "report_no": "GIFT-RPT-2026-000001",
    "status": "queued"
  },
  "meta": null
}
```

### 24.3 Get Report Detail

```http
GET /api/v1/reports/{id}
```

### 24.4 Download Report

```http
GET /api/v1/reports/{id}/download
```

Response:

```text
application/pdf
```

### 24.5 Report Versions

```http
GET /api/v1/reports/{id}/versions
```

### 24.6 Create Report Revision

```http
POST /api/v1/reports/{id}/revisions
```

Request:

```json
{
  "reason": "Perbaikan caption foto D-001.",
  "regenerate": true
}
```

### 24.7 Validate Report by QR Token

```http
GET /api/v1/public/reports/validate/{qr_token}
```

Response:

```json
{
  "success": true,
  "message": "Report valid.",
  "data": {
    "report_no": "GIFT-RPT-2026-000001",
    "revision_no": 0,
    "container_no": "MSKU1234567",
    "customer_name": "PT ABC Logistics",
    "survey_date": "2026-06-24",
    "status": "valid",
    "surveyor_name": "Budi Surveyor",
    "approver_name": "Supervisor Name"
  },
  "meta": null
}
```

---

## 25. EIR API

EIR digunakan jika survey type membutuhkan Equipment Interchange Receipt, terutama Gate In/Gate Out.

### 25.1 Generate EIR

```http
POST /api/v1/eirs/generate/{survey_id}
```

Request:

```json
{
  "from_party": "Trucking",
  "to_party": "Depot",
  "handover_note": "Gate in container."
}
```

Response:

```json
{
  "success": true,
  "message": "EIR berhasil dibuat.",
  "data": {
    "id": "uuid-eir",
    "eir_no": "GIFT-EIR-2026-000001",
    "status": "generated"
  },
  "meta": null
}
```

### 25.2 Download EIR

```http
GET /api/v1/eirs/{id}/download
```

---

## 26. Finance API

### 26.1 Dashboard Finance

```http
GET /api/v1/finance/dashboard?date_from=2026-06-01&date_to=2026-06-30
```

Response:

```json
{
  "success": true,
  "message": "Dashboard finance berhasil diambil.",
  "data": {
    "ready_to_invoice": 10,
    "invoice_count": 25,
    "paid_count": 15,
    "unpaid_count": 8,
    "overdue_count": 2,
    "outstanding_amount": 15000000
  },
  "meta": null
}
```

### 26.2 Ready to Invoice

```http
GET /api/v1/finance/ready-to-invoice?page=1&per_page=20&customer_id=uuid
```

Response item:

```json
{
  "report_id": "uuid-report",
  "report_no": "GIFT-RPT-2026-000001",
  "job_order_no": "GIFT-JO-2026-000001",
  "customer_id": "uuid-customer",
  "customer_name": "PT ABC Logistics",
  "survey_type_name": "Gate In Survey",
  "container_count": 1,
  "status": "ready_to_invoice"
}
```

### 26.3 Price List

```http
GET    /api/v1/finance/price-list
POST   /api/v1/finance/price-list
GET    /api/v1/finance/price-list/{id}
PUT    /api/v1/finance/price-list/{id}
DELETE /api/v1/finance/price-list/{id}
```

Create request:

```json
{
  "customer_id": null,
  "survey_type_id": "uuid-survey-type",
  "container_type_id": "uuid-container-type",
  "unit_price": 50000,
  "currency": "IDR",
  "tax_type": "ppn",
  "effective_date": "2026-06-01",
  "status": "active"
}
```

### 26.4 Create Invoice

```http
POST /api/v1/finance/invoices
```

Headers:

```http
X-Idempotency-Key: unique-key-create-invoice
```

Request:

```json
{
  "customer_id": "uuid-customer",
  "invoice_date": "2026-06-24",
  "payment_term_days": 30,
  "billing_address": "Jakarta",
  "items": [
    {
      "job_order_id": "uuid-job",
      "report_id": "uuid-report",
      "description": "Gate In Survey 20GP - MSKU1234567",
      "quantity": 1,
      "unit_price": 50000,
      "taxable": true
    }
  ],
  "discount_amount": 0,
  "note": "Invoice survey container."
}
```

Response `201`:

```json
{
  "success": true,
  "message": "Invoice berhasil dibuat.",
  "data": {
    "id": "uuid-invoice",
    "invoice_no": "GIFT-INV-2026-000001",
    "status": "draft",
    "grand_total": 55500
  },
  "meta": null
}
```

### 26.5 List Invoices

```http
GET /api/v1/finance/invoices?page=1&status=unpaid&customer_id=uuid
```

### 26.6 Get Invoice Detail

```http
GET /api/v1/finance/invoices/{id}
```

### 26.7 Update Invoice Draft

```http
PUT /api/v1/finance/invoices/{id}
```

Aturan:

1. Hanya invoice status `draft` yang dapat diubah.

### 26.8 Issue Invoice

```http
POST /api/v1/finance/invoices/{id}/issue
```

Response:

```json
{
  "success": true,
  "message": "Invoice berhasil diterbitkan.",
  "data": {
    "invoice_no": "GIFT-INV-2026-000001",
    "status": "issued",
    "due_date": "2026-07-24"
  },
  "meta": null
}
```

### 26.9 Cancel Invoice

```http
POST /api/v1/finance/invoices/{id}/cancel
```

Request:

```json
{
  "reason": "Invoice salah customer."
}
```

### 26.10 Download Invoice PDF

```http
GET /api/v1/finance/invoices/{id}/download
```

Response:

```text
application/pdf
```

---

## 27. Payment API

### 27.1 Create Payment

```http
POST /api/v1/finance/payments
```

Request:

```json
{
  "invoice_id": "uuid-invoice",
  "payment_date": "2026-06-25",
  "amount": 55500,
  "payment_method": "bank_transfer",
  "bank_account": "Bank ABC - 1234567890",
  "note": "Pembayaran lunas."
}
```

Response:

```json
{
  "success": true,
  "message": "Payment berhasil dicatat.",
  "data": {
    "id": "uuid-payment",
    "payment_no": "GIFT-RCP-2026-000001",
    "invoice_status": "paid"
  },
  "meta": null
}
```

### 27.2 Upload Payment Proof

```http
POST /api/v1/finance/payments/{id}/proof
```

Request multipart:

| Field | Type | Wajib |
|---|---|---:|
| file | image/pdf | Ya |

### 27.3 List Payments

```http
GET /api/v1/finance/payments?page=1&invoice_id=uuid
```

### 27.4 Outstanding

```http
GET /api/v1/finance/outstanding?customer_id=uuid&date_to=2026-06-30
```

---

## 28. Dashboard dan Management API

### 28.1 Admin Dashboard

```http
GET /api/v1/dashboard/admin?date=2026-06-24
```

### 28.2 Supervisor Dashboard

```http
GET /api/v1/dashboard/supervisor?date=2026-06-24
```

### 28.3 Management Dashboard

```http
GET /api/v1/dashboard/management?date_from=2026-06-01&date_to=2026-06-30
```

Response:

```json
{
  "success": true,
  "message": "Dashboard management berhasil diambil.",
  "data": {
    "total_jobs": 100,
    "total_containers": 350,
    "total_reports": 320,
    "total_revenue": 50000000,
    "total_outstanding": 10000000,
    "top_customers": [
      {
        "customer_name": "PT ABC Logistics",
        "job_count": 25
      }
    ],
    "top_damages": [
      {
        "damage_name": "Dent",
        "count": 50
      }
    ]
  },
  "meta": null
}
```

### 28.4 Recap Endpoints

```http
GET /api/v1/management/recap/jobs
GET /api/v1/management/recap/surveyors
GET /api/v1/management/recap/customers
GET /api/v1/management/recap/damages
GET /api/v1/management/recap/revenue
```

---

## 29. Audit Log API

### 29.1 List Audit Logs

```http
GET /api/v1/audit-logs?page=1&per_page=20&entity_type=survey&entity_id=uuid&user_id=uuid
```

Response item:

```json
{
  "id": "uuid",
  "user": {
    "id": "uuid",
    "name": "Admin Operasional"
  },
  "action": "survey.submitted",
  "entity_type": "survey",
  "entity_id": "uuid-survey",
  "old_value": {
    "status": "draft"
  },
  "new_value": {
    "status": "submitted"
  },
  "ip_address": "127.0.0.1",
  "user_agent": "Mozilla/5.0",
  "created_at": "2026-06-24T11:00:00+07:00"
}
```

### 29.2 Get Audit Log Detail

```http
GET /api/v1/audit-logs/{id}
```

Aturan:

1. Audit log tidak boleh diedit.
2. Audit log tidak boleh dihapus melalui API biasa.

---

## 30. Notification API

### 30.1 List Notifications

```http
GET /api/v1/notifications?page=1&status=unread
```

Response item:

```json
{
  "id": "uuid",
  "type": "survey_need_revision",
  "title": "Survey perlu revisi",
  "message": "Survey GIFT-SVY-2026-000001 dikembalikan untuk revisi.",
  "is_read": false,
  "link_url": "/surveyor/surveys/uuid",
  "created_at": "2026-06-24T11:15:00+07:00"
}
```

### 30.2 Mark Notification as Read

```http
POST /api/v1/notifications/{id}/read
```

### 30.3 Mark All as Read

```http
POST /api/v1/notifications/read-all
```

---

## 31. File Object API

File object API digunakan untuk metadata file, signed URL, dan download terkontrol.

### 31.1 Get File Detail

```http
GET /api/v1/files/{id}
```

### 31.2 Get Signed URL / Temporary URL

```http
GET /api/v1/files/{id}/url
```

Response:

```json
{
  "success": true,
  "message": "URL file berhasil dibuat.",
  "data": {
    "url": "temporary-signed-url",
    "expires_in": 300
  },
  "meta": null
}
```

### 31.3 Download File via Backend Proxy

```http
GET /api/v1/files/{id}/download
```

---

## 32. Mobile Sync API — Future Phase

Endpoint ini disiapkan untuk future Flutter mobile app.

### 32.1 Mobile Bootstrap

```http
GET /api/v1/mobile/bootstrap
```

Response berisi data master ringan untuk local cache:

```json
{
  "success": true,
  "message": "Bootstrap data berhasil diambil.",
  "data": {
    "server_time": "2026-06-24T10:00:00+07:00",
    "master_version": "2026-06-24-001",
    "cedex_components": [],
    "cedex_damages": [],
    "cedex_repairs": [],
    "cedex_locations": [],
    "survey_types": [],
    "container_types": [],
    "checklist_templates": []
  },
  "meta": null
}
```

### 32.2 Mobile Assigned Jobs Sync

```http
GET /api/v1/mobile/sync/jobs?updated_since=2026-06-24T00:00:00+07:00
```

### 32.3 Mobile Push Draft Changes

```http
POST /api/v1/mobile/sync/push
```

Request:

```json
{
  "device_id": "device-uuid",
  "changes": [
    {
      "client_id": "local-uuid-1",
      "entity_type": "survey_damage",
      "operation": "create",
      "payload": {
        "survey_id": "uuid-survey",
        "face": "left",
        "internal_location": "L3",
        "component_code_id": "uuid-component",
        "damage_code_id": "uuid-damage",
        "severity": "minor"
      },
      "client_updated_at": "2026-06-24T10:30:00+07:00"
    }
  ]
}
```

Response:

```json
{
  "success": true,
  "message": "Sync selesai.",
  "data": {
    "accepted": [
      {
        "client_id": "local-uuid-1",
        "server_id": "uuid-damage"
      }
    ],
    "rejected": [],
    "conflicts": []
  },
  "meta": null
}
```

### 32.4 Mobile Upload Queue Status

```http
GET /api/v1/mobile/sync/upload-queue
```

---

## 33. Export API

### 33.1 Export Jobs

```http
GET /api/v1/exports/jobs.xlsx?date_from=2026-06-01&date_to=2026-06-30
```

### 33.2 Export Survey Data

```http
GET /api/v1/exports/surveys.xlsx?date_from=2026-06-01&date_to=2026-06-30
```

### 33.3 Export Finance Recap

```http
GET /api/v1/exports/finance.xlsx?date_from=2026-06-01&date_to=2026-06-30
```

### 33.4 Export Damage Recap

```http
GET /api/v1/exports/damages.xlsx?date_from=2026-06-01&date_to=2026-06-30
```

---

## 34. Business Validation Rules API

### 34.1 Job Rules

1. Job tidak dapat di-assign jika tidak memiliki container.
2. Container no tidak boleh duplikat dalam satu job.
3. Job cancelled tidak dapat diproses lanjut.
4. Job closed tidak dapat diubah.

### 34.2 Survey Rules

1. Surveyor hanya dapat mengakses job/container miliknya.
2. Survey hanya dapat diedit saat status `draft` atau `need_revision`.
3. Survey `submitted` terkunci untuk surveyor.
4. Survey `approved` terkunci untuk semua role kecuali proses report revision.
5. Submit membutuhkan general info, checklist, damage, dan foto valid.

### 34.3 Damage Rules

1. Damage wajib memiliki location, component, dan damage type.
2. Damage major/critical wajib memiliki ukuran.
3. Damage wajib memiliki minimal 1 foto sebelum submit.
4. Damage no berurutan per survey.

### 34.4 Review Rules

1. Hanya survey `submitted` yang dapat di-approve.
2. Need revision wajib memiliki catatan.
3. Reject wajib memiliki alasan.
4. Approval membuat survey terkunci.

### 34.5 Report Rules

1. Report hanya dibuat dari survey `approved`.
2. Report final tidak boleh ditimpa.
3. Revisi report membuat version baru.

### 34.6 Finance Rules

1. Invoice hanya dibuat dari report approved/generated.
2. Satu report tidak boleh masuk dua invoice aktif.
3. Invoice paid tidak bisa dihapus.
4. Payment tidak boleh melebihi sisa tagihan.
5. Cancel invoice wajib alasan.

---

## 35. Status Transition Contract

### 35.1 Survey Status Transition

| From | Action | To |
|---|---|---|
| draft | submit | submitted |
| submitted | need_revision | need_revision |
| need_revision | submit | submitted |
| submitted | approve | approved |
| submitted | reject | rejected |
| approved | generate_report | report_generated |

Invalid transition response:

```json
{
  "success": false,
  "message": "Perubahan status tidak valid.",
  "error": {
    "code": "INVALID_STATUS_TRANSITION",
    "details": [
      {
        "field": "status",
        "message": "Survey dengan status approved tidak dapat dikembalikan ke draft."
      }
    ]
  },
  "meta": null
}
```

### 35.2 Invoice Status Transition

| From | Action | To |
|---|---|---|
| draft | issue | issued/unpaid |
| issued/unpaid | payment partial | partial_paid |
| issued/unpaid | payment full | paid |
| partial_paid | payment remaining | paid |
| draft | cancel | cancelled |
| issued/unpaid | cancel | cancelled |

---

## 36. Idempotency Rules

Endpoint berikut harus mendukung `X-Idempotency-Key`:

1. `POST /api/v1/surveys/{id}/submit`
2. `POST /api/v1/reviews/{survey_id}/approve`
3. `POST /api/v1/reports/generate/{survey_id}`
4. `POST /api/v1/finance/invoices`
5. `POST /api/v1/finance/invoices/{id}/issue`
6. `POST /api/v1/finance/payments`

Tujuan:

1. Mencegah double submit.
2. Mencegah report/invoice/payment duplikat.
3. Mendukung retry dari mobile app saat koneksi tidak stabil.

---

## 37. Security Contract

### 37.1 Authorization

Setiap endpoint harus memeriksa:

1. User authenticated.
2. Role/permission sesuai.
3. Ownership data jika role Surveyor.
4. Data state valid.

### 37.2 File Security

1. File private tidak boleh dibuka tanpa permission.
2. Signed URL memiliki expiry pendek.
3. File upload harus divalidasi mime dan size.
4. Nama file original tidak boleh langsung dijadikan path final tanpa sanitasi.

### 37.3 Input Validation

1. Semua input divalidasi server-side.
2. Semua string harus dibatasi panjangnya.
3. HTML/script tidak boleh disimpan tanpa sanitasi.
4. Numeric amount harus decimal positif.

---

## 38. Performance Contract

1. Semua list endpoint wajib pagination.
2. Endpoint list tidak boleh mengirim file binary.
3. Foto di list menggunakan thumbnail URL.
4. Report generation dilakukan background job.
5. Dashboard menggunakan agregasi query yang dioptimalkan.
6. Master data yang jarang berubah dapat di-cache.
7. Endpoint mobile bootstrap harus ringan dan bisa menggunakan versioning master data.

---

## 39. Sample End-to-End API Flow

### 39.1 Admin Membuat Job

```text
POST /api/v1/jobs
POST /api/v1/jobs/{job_id}/containers
POST /api/v1/jobs/{job_id}/assign
```

### 39.2 Surveyor Mengisi Survey

```text
GET  /api/v1/surveyor/jobs
GET  /api/v1/surveyor/jobs/{job_id}/containers
POST /api/v1/surveys/start
PUT  /api/v1/surveys/{survey_id}/general-info
PUT  /api/v1/surveys/{survey_id}/checklist
POST /api/v1/surveys/{survey_id}/damages
POST /api/v1/survey-damages/{damage_id}/photos
GET  /api/v1/surveys/{survey_id}/preview
POST /api/v1/surveys/{survey_id}/submit
```

### 39.3 Supervisor Review

```text
GET  /api/v1/reviews/pending
GET  /api/v1/reviews/{survey_id}
POST /api/v1/reviews/{survey_id}/approve
```

### 39.4 Report dan Finance

```text
POST /api/v1/reports/generate/{survey_id}
GET  /api/v1/reports/{id}/download
GET  /api/v1/finance/ready-to-invoice
POST /api/v1/finance/invoices
POST /api/v1/finance/invoices/{id}/issue
POST /api/v1/finance/payments
```

---

## 40. Acceptance Criteria API

### 40.1 General API

- Semua response mengikuti envelope standar.
- Semua error mengikuti error format standar.
- Semua endpoint private menolak request tanpa token.
- Semua endpoint memeriksa permission.
- Semua list endpoint mendukung pagination.

### 40.2 Job API

- Admin dapat membuat job.
- Admin dapat menambahkan container.
- Sistem menolak container duplikat dalam job.
- Admin dapat assign surveyor.
- Surveyor hanya melihat container yang ditugaskan.

### 40.3 Survey API

- Survey No dibuat otomatis saat start survey.
- Surveyor dapat simpan general info.
- Surveyor dapat simpan checklist.
- Surveyor dapat input damage dari survey sheet.
- Surveyor dapat upload foto.
- Submit ditolak jika data belum lengkap.
- Survey terkunci setelah submitted.

### 40.4 Review API

- Supervisor dapat melihat pending review.
- Supervisor dapat approve survey.
- Supervisor dapat mengembalikan survey ke Need Revision dengan catatan.
- Approval menghasilkan Report No.

### 40.5 Report API

- Report hanya dapat dibuat dari survey approved.
- Generate report mengembalikan status queued/processing/generated.
- Report final dapat di-download sebagai PDF.
- Report revision membuat versi baru.

### 40.6 Finance API

- Finance hanya melihat report ready to invoice.
- Invoice tidak bisa dibuat ganda untuk report yang sama.
- Payment mengubah status invoice.
- Payment tidak boleh melebihi sisa tagihan.

---

## 41. Hal yang Perlu Dikonfirmasi Sebelum Implementasi Final

1. Apakah invoice dapat menagih beberapa report sekaligus atau hanya satu report per invoice?
2. Apakah satu job dapat memiliki report gabungan untuk banyak container, selain report per container?
3. Apakah EIR wajib untuk semua Gate In/Gate Out atau optional per job?
4. Apakah Supervisor boleh mengedit damage langsung atau hanya memberi revisi ke Surveyor?
5. Apakah Admin boleh approve jika Supervisor tidak tersedia?
6. Apakah price list berlaku global, per customer, atau per kontrak?
7. Apakah payment membutuhkan approval Finance Manager?
8. Apakah QR validation page publik atau harus login?
9. Apakah mobile offline sync akan dibuat pada phase awal mobile atau phase lanjutan?
10. Apakah report PDF menggunakan bahasa Indonesia, English, atau bilingual?

---

## 42. Catatan Akhir

API contract ini menetapkan backend sebagai pusat proses bisnis untuk Web Application dan Future Mobile Application. Walaupun MVP awal menjalankan Surveyor Module di web, endpoint surveyor harus dirancang mobile-ready agar pada fase Flutter Mobile App tidak perlu mengubah struktur API utama.

Keputusan utama:

```text
Web App menggunakan API yang sama dengan Future Mobile App.
Surveyor Web Module adalah validasi alur.
Surveyor Mobile App menggunakan endpoint Surveyor API yang sama.
Backend API menjadi satu sumber kebenaran data.
Database dan storage tetap terpusat.
```

Dokumen ini harus digunakan bersama:

1. `prd.md`
2. `database_schema.md`
3. `ui_flow.md` atau wireframe yang akan dibuat berikutnya
4. `report_template.md` untuk desain PDF final
