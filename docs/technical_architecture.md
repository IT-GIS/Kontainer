# technical_architecture.md â€” Container Survey Management System

**Dokumen:** Technical Architecture  
**Produk:** Container Survey Management System  
**Perusahaan/Unit:** GIFT / PT Global Inspeksi Sertifikasi Group  
**Versi:** 1.0  
**Status:** Draft teknis untuk perencanaan development  

---

## 1. Tujuan Dokumen

Dokumen ini menjelaskan rancangan teknis sistem Container Survey Management System, termasuk stack teknologi, arsitektur service, deployment, database, storage, security, queue, observability, dan kesiapan future mobile app.

Dokumen ini melengkapi:

1. `prd.md`
2. `database_schema.md`
3. `api_contract.md`
4. `ui_flow.md`
5. `state_machine.md`
6. `permission_matrix_detail.md`

---

## 2. Prinsip Arsitektur

Sistem harus mengikuti prinsip berikut:

1. **Satu backend API pusat**  
   Web Application dan future Mobile Application memakai backend API yang sama.

2. **Satu database utama**  
   Semua transaksi job, survey, report, invoice, dan payment memakai satu sumber data.

3. **Web MVP dulu**  
   Semua role dibuat di Web Application untuk validasi alur sebelum Surveyor dibuat mobile.

4. **Mobile-ready API**  
   Endpoint surveyor harus reusable oleh mobile app.

5. **File tidak disimpan di database**  
   Foto, PDF, invoice, bukti bayar, dan signature disimpan di object storage.

6. **Queue untuk proses berat**  
   Generate PDF, image compression, watermark, dan notifikasi tidak boleh membebani request utama.

7. **Stateless backend**  
   Backend API harus dapat diskalakan horizontal di masa depan.

8. **Security by default**  
   Semua endpoint private wajib auth, permission, dan audit log pada aksi penting.

9. **Auditability**  
   Semua perubahan penting harus tercatat.

10. **No PHP stack**  
   Arsitektur ini tidak menggunakan PHP. Backend direkomendasikan memakai Go.

---

## 3. Stack Teknologi Final Rekomendasi

| Layer | Teknologi | Catatan |
|---|---|---|
| Web Application | Next.js + TypeScript | Untuk Admin, Surveyor Web MVP, Supervisor, Finance, Management |
| Mobile Application Future | Flutter | Untuk Surveyor lapangan pada fase lanjutan |
| Backend API | Go + Gin | REST API utama |
| Database | MySQL | Relasional, transaksi, indexing kuat |
| Cache | Redis | Cache master data, session/token helper, rate limit |
| Queue | Redis-backed worker / Asynq | Background job PDF, image, notification |
| Object Storage | MinIO / S3-compatible | Foto, PDF, invoice, payment proof |
| Reverse Proxy | Nginx | HTTPS, routing, static, upload limit |
| Deployment | Docker + Docker Compose | Untuk development, staging, production awal |
| OS Server | Ubuntu Server LTS | Production server |
| API Documentation | OpenAPI/Swagger | Kontrak API |
| Monitoring | Prometheus + Grafana optional | Future/production mature |
| Logging | Structured JSON logs | Untuk backend dan worker |

Catatan:

1. Go framework dapat menggunakan Gin atau Fiber. Dokumen ini memakai **Go + Gin** sebagai standar rekomendasi.
2. Worker Go dapat memakai Asynq jika menggunakan Redis sebagai backend queue.
3. Untuk MVP awal, satu server cukup. Arsitektur tetap disiapkan agar bisa dipisah service di masa depan.

---

## 4. High-Level Architecture

```text
[User Browser]
Admin / Surveyor Web / Supervisor / Finance / Management
        |
        | HTTPS
        v
[Nginx Reverse Proxy]
        |
        |-------------------------|
        v                         v
[Next.js Web App]          [Go Backend API]
                                  |
                                  |--------------------|-------------------|
                                  v                    v                   v
                            [MySQL]           [Redis]            [MinIO/S3]
                            Main DB                Cache/Queue        Files/PDF
                                  |
                                  v
                            [Backup System]

[Future Flutter Mobile App]
Surveyor Lapangan
        |
        | HTTPS REST API
        v
[Go Backend API yang sama]
```

---

## 5. Service Breakdown

### 5.1 Web App Service

**Teknologi:** Next.js + TypeScript  
**Nama service:** `gift-survey-web`

Fungsi:

1. Login UI.
2. Dashboard role-based.
3. Master data pages.
4. Job order pages.
5. Surveyor Web Module.
6. Review/approval pages.
7. Report archive pages.
8. Finance pages.
9. Management recap pages.
10. File preview/download UI.

Karakteristik:

1. Tidak menyimpan business logic utama.
2. Semua data dari backend API.
3. Form validation frontend hanya untuk UX; backend tetap validasi final.
4. Role-based menu menggunakan data permission dari `/api/me`.

---

### 5.2 Backend API Service

**Teknologi:** Go + Gin  
**Nama service:** `gift-survey-api`

Fungsi:

1. Authentication.
2. Authorization.
3. Master data.
4. CEDEX master.
5. Numbering service.
6. Job order.
7. Container.
8. Assignment.
9. Survey.
10. Damage.
11. Photo metadata.
12. Review/approval.
13. Report generation trigger.
14. Finance invoice/payment.
15. Audit log.
16. Notification.
17. File authorization.
18. API for future mobile.

Karakteristik:

1. Stateless.
2. REST API.
3. JSON request/response.
4. Multipart upload for files.
5. JWT access token + refresh token.
6. Database transaction untuk aksi penting.
7. Semua permission dicek di backend.

---

### 5.3 Worker Service

**Teknologi:** Go Worker + Redis Queue  
**Nama service:** `gift-survey-worker`

Fungsi background job:

1. Generate PDF report.
2. Generate invoice PDF.
3. Generate EIR PDF.
4. Compress image.
5. Apply watermark image.
6. Create thumbnail image.
7. Send in-app notification.
8. Send email notification optional.
9. Cleanup temporary files.
10. Scheduled overdue invoice check.

Alasan worker diperlukan:

1. Request user tidak menunggu proses berat.
2. Upload/generate PDF lebih stabil.
3. Retry job dapat dilakukan otomatis.
4. Error job dapat dicatat dan diulang.

---

### 5.4 MySQL Service

**Nama service:** `gift-survey-db`

Fungsi:

1. Menyimpan data user, role, permission.
2. Menyimpan master data.
3. Menyimpan job, survey, damage, report metadata.
4. Menyimpan invoice, payment.
5. Menyimpan audit log.
6. Menyimpan notification.
7. Menyimpan file metadata.

Aturan:

1. File binary tidak disimpan di database.
2. Gunakan UUID primary key.
3. Gunakan migration untuk perubahan schema.
4. Gunakan index pada kolom query utama.

---

### 5.5 Redis Service

**Nama service:** `gift-survey-redis`

Fungsi:

1. Cache master data.
2. Queue background job.
3. Rate limit helper.
4. Temporary lock untuk numbering.
5. Session/token blacklist optional.
6. Notification queue.

Aturan:

1. Redis bukan sumber data utama.
2. Data penting tetap disimpan di MySQL.
3. Jika Redis restart, sistem tetap dapat berjalan dengan degradasi terbatas.

---

### 5.6 Object Storage Service

**Teknologi:** MinIO atau S3-compatible storage  
**Nama service:** `gift-survey-storage`

Fungsi menyimpan:

1. Foto general survey.
2. Foto damage.
3. Foto CSC plate.
4. Foto seal.
5. Report PDF.
6. EIR PDF.
7. Invoice PDF.
8. Payment proof.
9. Signature.
10. Company logo.

Aturan:

1. File final tidak boleh ditimpa.
2. Report revision menghasilkan file baru.
3. Akses file private lewat signed URL atau API proxy.
4. Database hanya menyimpan metadata dan path.

---

## 6. Environment

### 6.1 Development

Dipakai developer lokal.

Komponen:

```text
- Next.js web app
- Go API
- MySQL via Docker
- Redis via Docker
- MinIO via Docker
- Worker via Docker/local
```

Contoh domain lokal:

```text
http://localhost:3000    -> Web App
http://localhost:8080    -> API
http://localhost:9000    -> MinIO Console/API
```

---

### 6.2 Staging

Dipakai testing internal sebelum production.

Karakteristik:

1. Data dummy atau copy data production yang sudah dianonimkan.
2. Domain terpisah.
3. Deploy otomatis/manual dari branch staging.
4. Digunakan untuk UAT.

Contoh domain:

```text
https://staging-survey.gift.co.id
https://staging-api-survey.gift.co.id
```

---

### 6.3 Production

Dipakai user asli.

Karakteristik:

1. HTTPS wajib.
2. Backup aktif.
3. Logging aktif.
4. Monitoring aktif minimal uptime/resource.
5. Akses database terbatas.
6. Environment variable aman.

Contoh domain:

```text
https://survey.gift.co.id
https://api-survey.gift.co.id
```

---

## 7. Deployment Topology MVP

Untuk MVP awal, cukup satu VPS/server.

```text
[Ubuntu Server]
  â”œâ”€â”€ Nginx
  â”œâ”€â”€ Docker Network
  â”‚   â”œâ”€â”€ web-nextjs
  â”‚   â”œâ”€â”€ api-go
  â”‚   â”œâ”€â”€ worker-go
  â”‚   â”œâ”€â”€ mysql
  â”‚   â”œâ”€â”€ redis
  â”‚   â””â”€â”€ minio
  â””â”€â”€ Backup Script
```

Minimum server awal:

| Resource | Rekomendasi MVP |
|---|---|
| CPU | 4 Core |
| RAM | 8 GB |
| Storage | 200â€“300 GB SSD |
| OS | Ubuntu Server LTS |
| Bandwidth | Disesuaikan jumlah upload foto |

Jika foto banyak, storage harus lebih besar atau pakai object storage eksternal.

---

## 8. Deployment Topology Future Scaling

Jika traffic bertambah:

```text
[Nginx / Load Balancer]
        |
        |------------------|
        v                  v
[API Instance 1]     [API Instance 2]
        |                  |
        |------------------|
        v
[Managed MySQL / Primary DB]
        |
        v
[Redis Cluster / Managed Redis]
        |
        v
[S3 / Object Storage]
```

Pemisahan service future:

1. Web App server sendiri.
2. API server sendiri.
3. Worker server sendiri.
4. Database managed/dedicated.
5. Storage dedicated/S3.
6. Monitoring server.

---

## 9. Network and Domain Routing

### 9.1 Nginx Routing

| Domain/Path | Target Service |
|---|---|
| `survey.gift.co.id` | Next.js web app |
| `api-survey.gift.co.id` | Go API |
| `storage-console.gift.co.id` | MinIO console, restricted |
| `/api/*` optional | Go API if same domain deployment |

Rekomendasi:

```text
Web App: https://survey.gift.co.id
API:     https://api-survey.gift.co.id
```

Alasan domain API dipisah:

1. Mobile app future lebih mudah diarahkan.
2. CORS lebih jelas.
3. Scaling web dan API bisa dipisahkan.
4. Logging lebih mudah.

---

## 10. Authentication Architecture

### 10.1 Auth Flow Web

```text
User login di Web
â†“
Web kirim email/password ke API
â†“
API validasi credential
â†“
API mengembalikan access_token + refresh_token + user profile
â†“
Web menyimpan token secara aman
â†“
Setiap request API memakai Authorization Bearer token
```

### 10.2 Auth Flow Future Mobile

```text
Surveyor login di Flutter
â†“
Mobile kirim credential ke API
â†“
API mengembalikan token
â†“
Mobile menyimpan token di secure storage
â†“
Mobile sync job dan master data
```

### 10.3 Token Strategy

| Token | Durasi Rekomendasi | Fungsi |
|---|---|---|
| Access Token | 15â€“60 menit | Akses API |
| Refresh Token | 7â€“30 hari | Membuat access token baru |

Aturan:

1. Refresh token dapat dicabut saat logout.
2. Password reset mencabut refresh token lama.
3. User deaktivasi mencabut semua token.
4. Token memuat user_id dan role/permission summary secukupnya.
5. Permission final tetap dicek dari database/cache backend.

---

## 11. Authorization Architecture

Authorization dilakukan di backend melalui:

1. Role check.
2. Permission check.
3. Ownership/scope check.
4. Status guard.
5. Field-level guard pada aksi tertentu.

Contoh request:

```text
PUT /api/survey-damages/{id}
```

Backend harus cek:

1. User authenticated.
2. Role surveyor.
3. Damage milik survey yang assigned ke surveyor.
4. Survey status Draft atau Need Revision.
5. Payload valid.
6. Audit log dibuat.

---

## 12. Data Architecture

### 12.1 Main Data Domains

1. Identity & Access
2. Company & Numbering
3. Master Data
4. CEDEX Master
5. Job Order
6. Assignment
7. Survey
8. Damage & Photo Evidence
9. Review & Approval
10. Report & EIR
11. Finance
12. Audit & Notification
13. File Object
14. Future Mobile Sync

### 12.2 Database Conventions

1. MySQL.
2. Primary key UUID.
3. Snake_case table and column names.
4. `created_at`, `updated_at`, `deleted_at` standard columns.
5. Soft delete for business data.
6. Audit log immutable.
7. Foreign key untuk relasi utama.
8. Index untuk query utama.

### 12.3 Critical Indexes

```text
users.email
job_orders.job_order_no
job_orders.customer_id
job_orders.status
job_containers.container_no
job_containers.job_order_id
assignments.surveyor_id
surveys.survey_no
surveys.status
surveys.surveyor_id
survey_damages.survey_id
survey_photos.survey_id
reports.report_no
invoices.invoice_no
invoices.customer_id
invoices.status
audit_logs.entity_type, entity_id
audit_logs.created_at
```

---

## 13. Numbering Architecture

Nomor dokumen harus dibuat oleh backend melalui numbering service.

Jenis nomor:

1. Job Order No.
2. Assignment No.
3. Survey No.
4. Damage No.
5. Report No.
6. EIR No.
7. Invoice No.
8. Payment Receipt No.

Aturan:

1. Nomor dibuat atomic.
2. Nomor tidak boleh duplicate.
3. Nomor tidak boleh dipakai ulang setelah void/cancel.
4. Gunakan DB transaction dan lock pada sequence.
5. Running number dipisah berdasarkan doc_type dan year.

Contoh flow:

```text
Create Job Order
â†“
Begin transaction
â†“
Lock numbering row for JO-2026
â†“
Increment running number
â†“
Generate GIFT-JO-2026-000001
â†“
Insert job_order
â†“
Commit
```

---

## 14. File Upload Architecture

### 14.1 Upload Flow Web MVP

```text
User pilih file/foto di Web
â†“
Web upload multipart ke API
â†“
API validasi auth, permission, file type, file size
â†“
API simpan file ke MinIO/S3
â†“
API simpan metadata ke database
â†“
API return file object metadata
```

### 14.2 Future Mobile Upload Flow

```text
Mobile capture foto
â†“
Mobile compress foto
â†“
Mobile simpan lokal sementara
â†“
Mobile upload ke API saat online
â†“
API simpan ke object storage
â†“
API simpan metadata
â†“
Mobile tandai file synced
```

### 14.3 File Validation

| File Type | Allowed MIME | Max Size MVP |
|---|---|---:|
| Image | image/jpeg, image/png, image/webp | 10 MB sebelum compress |
| PDF | application/pdf | 20 MB |
| Excel Import | xlsx/csv | 10 MB |
| Signature | image/png, image/jpeg | 5 MB |

Aturan:

1. Upload file harus dicek MIME dan extension.
2. Nama file sistem tidak boleh memakai nama file user langsung.
3. Gunakan UUID/random filename.
4. Simpan original filename hanya sebagai metadata.
5. Private file tidak boleh public tanpa signed URL.

---

## 15. Image Processing Architecture

Untuk MVP web, image processing bisa sederhana. Untuk mobile future, proses lebih lengkap.

### 15.1 MVP Web

1. Upload foto.
2. Simpan original ke object storage.
3. Generate thumbnail via worker optional.
4. Watermark dapat ditunda atau diproses worker.

### 15.2 Future Mobile

1. Compress foto di mobile sebelum upload.
2. Tambahkan watermark di mobile atau worker.
3. Simpan original/compressed sesuai kebijakan.
4. Upload background.
5. Retry jika gagal.

### 15.3 Watermark Content

```text
Container No
Survey No
Damage No
Location
Surveyor Name
Date Time
GPS Coordinate, jika tersedia
```

---

## 16. PDF Generation Architecture

PDF dibuat di backend/worker, bukan di frontend/mobile.

### 16.1 Report PDF Flow

```text
Supervisor approve survey
â†“
API membuat Report No
â†“
API enqueue job generate_report_pdf
â†“
Worker mengambil data survey lengkap
â†“
Worker render HTML template
â†“
Worker convert ke PDF
â†“
Worker upload PDF ke storage
â†“
Worker update report status = generated
â†“
Notification ke Admin/Finance
```

### 16.2 PDF Generator Options

Pilihan:

1. Go HTML-to-PDF library.
2. Headless Chromium service.
3. Dedicated PDF microservice future.

Rekomendasi MVP:

> Gunakan HTML template + headless Chromium jika layout PDF harus rapi dan mirip dokumen resmi.

### 16.3 PDF Types

1. Container Inspection Report.
2. Damage Report.
3. Photo Attachment Report.
4. EIR.
5. Invoice PDF.
6. Payment Receipt PDF optional.

---

## 17. Queue Architecture

### 17.1 Queue Topics

| Queue | Job |
|---|---|
| report | Generate report PDF, regenerate revision |
| invoice | Generate invoice PDF |
| image | Compress, thumbnail, watermark |
| notification | In-app/email notification |
| finance | Overdue check |
| cleanup | Temporary file cleanup |

### 17.2 Retry Policy

| Job Type | Retry | Catatan |
|---|---:|---|
| Generate PDF | 3â€“5 kali | Jika gagal, status failed dan bisa retry manual |
| Image processing | 3 kali | File tetap original |
| Notification | 3 kali | Tidak menghambat transaksi utama |
| Overdue check | Scheduled | Bisa dijalankan ulang |

### 17.3 Job Status

```text
queued
processing
completed
failed
retrying
cancelled
```

---

## 18. API Architecture

### 18.1 API Style

1. REST API.
2. JSON response.
3. Multipart upload untuk file.
4. Versioning dengan prefix `/api/v1` optional.
5. OpenAPI documentation.

Rekomendasi endpoint base:

```text
https://api-survey.gift.co.id/api/v1
```

### 18.2 Standard Response

Success:

```json
{
  "success": true,
  "message": "Request successful",
  "data": {},
  "meta": {}
}
```

Error:

```json
{
  "success": false,
  "message": "Validation failed",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": []
  }
}
```

### 18.3 HTTP Status

| Status | Arti |
|---|---|
| 200 | Success |
| 201 | Created |
| 400 | Bad request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not found |
| 409 | Invalid state/conflict |
| 422 | Validation error |
| 500 | Server error |

---

## 19. Frontend Web Architecture

### 19.1 Next.js App Structure

Rekomendasi struktur:

```text
web/
  app/
    (auth)/
      login/
    (dashboard)/
      dashboard/
      master/
      jobs/
      surveyor/
      review/
      reports/
      finance/
      management/
      settings/
  components/
    ui/
    forms/
    tables/
    survey-sheet/
    layout/
  lib/
    api-client.ts
    auth.ts
    permissions.ts
    validators.ts
  hooks/
  types/
  constants/
```

### 19.2 Web Data Fetching

1. Gunakan API client terpusat.
2. Token disisipkan otomatis.
3. Handle 401 dengan refresh token/logout.
4. Server-side atau client-side fetch disesuaikan.
5. Table pakai server-side pagination.

### 19.3 UI Component Standards

Komponen reusable:

1. AppLayout.
2. Sidebar.
3. PageHeader.
4. DataTable.
5. StatusBadge.
6. ConfirmDialog.
7. FormField.
8. FileUploader.
9. PhotoGallery.
10. SurveySheetGrid.
11. DamageModal.
12. Timeline.
13. AuditTrailPanel.

---

## 20. Backend Go Architecture

### 20.1 Recommended Project Structure

```text
api/
  cmd/
    api/
      main.go
    worker/
      main.go
  internal/
    config/
    database/
    middleware/
    auth/
    permissions/
    users/
    masterdata/
    cedex/
    numbering/
    jobs/
    assignments/
    surveys/
    damages/
    photos/
    reviews/
    reports/
    finance/
    files/
    notifications/
    audit/
    queue/
    storage/
    pdf/
    validator/
  migrations/
  docs/
  tests/
```

### 20.2 Layering

Gunakan pola:

```text
Handler / Controller
â†“
Service / Use Case
â†“
Repository
â†“
Database / Storage / Queue
```

Aturan:

1. Handler hanya parsing request/response.
2. Service memuat business logic.
3. Repository hanya akses data.
4. Permission/status guard di service/middleware.
5. Audit log dipanggil dari service setelah transaksi berhasil.

---

## 21. Database Migration Strategy

Gunakan migration tool seperti:

1. golang-migrate.
2. Atlas.
3. Goose.

Migration order:

1. Extensions UUID.
2. Enum types.
3. Users/roles/permissions.
4. Company/numbering.
5. Master data.
6. CEDEX.
7. Checklist template.
8. Job order/container.
9. Assignment.
10. Survey/checklist.
11. Damage/photo.
12. Approval/report/EIR.
13. Finance.
14. Notification/audit.
15. Mobile sync future.

Aturan:

1. Migration harus versioned.
2. Tidak edit migration lama setelah shared.
3. Gunakan rollback untuk development.
4. Production migration harus backup dulu.

---

## 22. Environment Variables

### 22.1 Web App ENV

```text
NEXT_PUBLIC_APP_NAME=Container Survey Management System
NEXT_PUBLIC_API_BASE_URL=https://api-survey.gift.co.id/api/v1
NEXT_PUBLIC_FILE_PREVIEW_MODE=signed_url
```

### 22.2 API ENV

```text
APP_ENV=production
APP_NAME=gift-survey-api
APP_PORT=8080
APP_BASE_URL=https://api-survey.gift.co.id
WEB_BASE_URL=https://survey.gift.co.id

DATABASE_URL=user:password@tcp(mysql:3306)/kontainer_db?parseTime=true&charset=utf8mb4
REDIS_ADDR=redis:6379
REDIS_PASSWORD=

JWT_ACCESS_SECRET=change_me
JWT_REFRESH_SECRET=change_me
JWT_ACCESS_TTL_MINUTES=60
JWT_REFRESH_TTL_DAYS=14

S3_ENDPOINT=http://minio:9000
S3_ACCESS_KEY=change_me
S3_SECRET_KEY=change_me
S3_BUCKET=gift-survey
S3_REGION=us-east-1
S3_USE_SSL=false

MAX_UPLOAD_MB=10
PDF_WORKER_ENABLED=true
```

### 22.3 Worker ENV

```text
APP_ENV=production
DATABASE_URL=...
REDIS_ADDR=...
S3_ENDPOINT=...
PDF_RENDER_TIMEOUT_SECONDS=120
IMAGE_PROCESSING_ENABLED=true
```

Aturan:

1. Secret tidak boleh disimpan di repository.
2. Gunakan `.env.example` tanpa secret asli.
3. Production secret disimpan di server/secret manager.

---

## 23. Docker Architecture

### 23.1 Services

```yaml
services:
  web:
    image: gift-survey-web
  api:
    image: gift-survey-api
  worker:
    image: gift-survey-worker
  mysql:
    image: mysql
  redis:
    image: redis
  minio:
    image: minio/minio
  nginx:
    image: nginx
```

### 23.2 Docker Networks

```text
public-network: nginx, web, api
private-network: api, worker, mysql, redis, minio
```

Aturan:

1. MySQL, Redis, MinIO tidak expose public kecuali diperlukan terbatas.
2. Nginx satu-satunya public entry point.
3. Gunakan volume untuk database dan storage.

---

## 24. CI/CD Recommendation

### 24.1 Branch Strategy

```text
main        -> production
staging     -> staging
feature/*   -> development fitur
hotfix/*    -> perbaikan mendesak
```

### 24.2 Pipeline Minimal

Untuk setiap push/merge:

1. Lint.
2. Type check.
3. Unit test.
4. Build Docker image.
5. Run migration check.
6. Deploy staging.
7. Manual approval production.

### 24.3 Deployment Steps

```text
Pull latest image
â†“
Backup database
â†“
Run migration
â†“
Restart API/Worker/Web
â†“
Health check
â†“
Smoke test login and dashboard
```

---

## 25. Backup and Restore Architecture

### 25.1 Backup Targets

1. MySQL database.
2. MinIO/S3 files.
3. Environment/config backup.
4. Nginx config.

### 25.2 Backup Schedule

| Data | Frequency | Retention |
|---|---:|---:|
| MySQL full backup | Daily | 14â€“30 days |
| MySQL WAL/archive future | Hourly/continuous | Future mature |
| Object storage | Daily sync | 14â€“30 days |
| Config backup | After change | Latest + history |

### 25.3 Restore Test

Minimal setiap bulan:

1. Restore database ke staging.
2. Restore sample file report/foto.
3. Test login.
4. Test open report.
5. Test invoice list.

Aturan penting:

> Backup yang tidak pernah dites restore belum bisa dianggap aman.

---

## 26. Security Architecture

### 26.1 Transport Security

1. HTTPS wajib di production.
2. Redirect HTTP ke HTTPS.
3. Secure cookie jika memakai cookie.
4. CORS dibatasi ke domain web/mobile yang sah.

### 26.2 Application Security

1. Password hash dengan bcrypt/argon2.
2. JWT secret kuat.
3. Input validation server-side.
4. SQL query parameterized.
5. Upload validation.
6. Rate limit login.
7. Role/permission enforcement.
8. Audit log.
9. File authorization.
10. Error response tidak membocorkan stack trace.

### 26.3 File Security

1. File private by default.
2. Signed URL dengan expiry singkat.
3. Jangan expose bucket public kecuali folder public tertentu seperti logo jika diperlukan.
4. Validasi file type dan size.
5. Scan malware optional future.

### 26.4 Admin Security

1. Super Admin terbatas.
2. Role permission tidak bisa diubah user biasa.
3. Audit log immutable.
4. Reset password tercatat.
5. Deaktivasi user mencabut token.

---

## 27. Performance Architecture

### 27.1 Web Performance

1. Server-side pagination.
2. Server-side filtering.
3. Lazy loading photo gallery.
4. Thumbnail untuk foto.
5. Jangan render foto original di list.
6. Cache master dropdown.
7. Debounce search input.

### 27.2 API Performance

1. Index query utama.
2. Pagination wajib pada list.
3. Hindari N+1 query.
4. Response hanya field yang diperlukan.
5. Gunakan cache untuk master data.
6. Generate PDF async.
7. Image processing async.

### 27.3 Database Performance

1. Index kolom status/date/foreign key.
2. Use EXPLAIN untuk query lambat.
3. Archiving audit log lama future.
4. Connection pool.
5. Batasi transaksi panjang.

### 27.4 File Performance

1. Thumbnail.
2. Image compression.
3. Signed URL direct download.
4. Upload progress.
5. Multipart direct-to-storage future.

---

## 28. Observability and Logging

### 28.1 Logs

Backend log harus structured JSON.

Field log:

```text
timestamp
level
request_id
user_id
role
method
path
status_code
latency_ms
error
```

### 28.2 Request ID

1. Setiap request punya request_id.
2. Request_id dikembalikan di header response.
3. Worker job juga mencatat job_id.

### 28.3 Metrics Future

Metrics yang disarankan:

1. API request count.
2. API latency.
3. Error rate.
4. Queue length.
5. Job failure count.
6. Database connection count.
7. Storage usage.
8. Upload volume.
9. PDF generation duration.

### 28.4 Alert Future

Alert untuk:

1. API down.
2. Database down.
3. Disk almost full.
4. Queue job failed banyak.
5. Backup failed.
6. SSL certificate expiring.

---

## 29. Error Handling Architecture

### 29.1 Error Categories

| Code | HTTP | Arti |
|---|---:|---|
| UNAUTHORIZED | 401 | Belum login/token invalid |
| FORBIDDEN | 403 | Tidak punya permission |
| NOT_FOUND | 404 | Data tidak ditemukan |
| VALIDATION_ERROR | 422 | Input tidak valid |
| INVALID_STATE | 409 | Status tidak memungkinkan aksi |
| DUPLICATE_DATA | 409 | Data duplicate |
| FILE_UPLOAD_FAILED | 500/422 | Upload gagal |
| PDF_GENERATION_FAILED | 500 | Generate PDF gagal |
| INTERNAL_ERROR | 500 | Error server |

### 29.2 Error Response

```json
{
  "success": false,
  "message": "Survey cannot be submitted because D-001 has no photo.",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": [
      {
        "field": "damages[0].photos",
        "message": "Damage photo is required"
      }
    ]
  }
}
```

---

## 30. State Machine Enforcement Architecture

State machine harus ditegakkan di service layer backend.

Contoh:

```text
survey.submit()
checks:
- status in Draft/Need Revision
- assigned user matches surveyor
- required general info complete
- checklist complete
- damage valid
- photo evidence complete
then:
- status = Submitted
- create audit log
- create notification for supervisor
```

Invalid transition harus menghasilkan:

```text
HTTP 409 INVALID_STATE
```

---

## 31. Audit Architecture

Audit log dibuat untuk aksi penting.

### 31.1 Audit Flow

```text
User action
â†“
Backend validates permission
â†“
Backend executes transaction
â†“
Backend writes audit log
â†“
Response success
```

### 31.2 Audit Storage

Audit log di MySQL.

Aturan:

1. Audit log tidak diedit.
2. Audit log tidak dihapus lewat UI.
3. Audit log menyimpan old_value dan new_value untuk perubahan penting.
4. Simpan IP dan user agent.
5. Simpan request_id.

---

## 32. Notification Architecture

### 32.1 MVP In-App Notification

Notifikasi disimpan di database.

Flow:

```text
Event terjadi
â†“
API/Worker create notification
â†“
User melihat badge notification di web
â†“
User mark as read
```

### 32.2 Future Push Notification

Untuk mobile:

1. Simpan device token.
2. Kirim push notification untuk job assigned, need revision, approved.
3. Fallback in-app notification.

---

## 33. Future Mobile Architecture

### 33.1 Flutter App Components

```text
mobile/
  lib/
    app/
    auth/
    jobs/
    surveys/
    checklist/
    survey_sheet/
    damages/
    photos/
    sync/
    local_db/
    api_client/
```

### 33.2 Local Storage

Gunakan SQLite untuk:

1. Assigned job.
2. Container list.
3. Master CEDEX.
4. Checklist template.
5. Draft survey.
6. Damage draft.
7. Photo upload queue.

### 33.3 Mobile Sync Flow

```text
Login
â†“
Download assigned jobs
â†“
Download master data
â†“
Surveyor bekerja lokal
â†“
Data draft disimpan SQLite
â†“
Jika online, sync data ke API
â†“
Foto upload background
â†“
Submit survey setelah validasi
```

### 33.4 Mobile Conflict Rule

MVP mobile future:

1. Survey submitted tidak dapat diedit.
2. Jika server status berubah, mobile mengikuti server.
3. Jika konflik local draft vs server locked, mobile menampilkan warning.
4. Surveyor tidak boleh override server approved data.

---

## 34. Reporting Architecture

### 34.1 Report Templates

Template disimpan sebagai:

1. HTML template di backend/worker.
2. Company profile dari database.
3. Data report dari survey approved.
4. Photo evidence dari storage.

### 34.2 Report Data Snapshot

Rekomendasi:

Saat report generated, simpan snapshot data penting ke `report_versions`.

Tujuan:

1. Report tetap konsisten walaupun master data berubah.
2. Rev. 0 tetap historis.
3. Revisi menghasilkan snapshot baru.

---

## 35. Finance Architecture

### 35.1 Ready to Invoice Flow

```text
Survey Approved
â†“
Report Generated
â†“
Report status Ready to Invoice
â†“
Finance create invoice
â†“
Invoice Draft
â†“
Issue invoice
â†“
Payment
â†“
Paid/Closed
```

### 35.2 Finance Integrity

1. Finance tidak menulis ke tabel survey/damage.
2. Invoice item mengacu ke report/job.
3. Payment mengacu ke invoice.
4. Paid invoice tidak dapat dihapus.
5. Cancel invoice wajib reason.

---

## 36. Data Retention

Rekomendasi awal:

| Data | Retention |
|---|---|
| Job/survey/report | Permanent selama diperlukan bisnis |
| Foto evidence | Permanent/minimal sesuai kebijakan perusahaan |
| Invoice/payment | Permanent sesuai kebutuhan finance/legal |
| Audit log | Minimal 2â€“5 tahun, disesuaikan |
| Notification | Bisa archive setelah 1 tahun |
| Temporary files | Cleanup otomatis 7â€“30 hari |

---

## 37. Development Roadmap Teknis

### Phase 1 â€” Foundation

1. Repository setup.
2. Docker compose development.
3. MySQL migration.
4. Go API skeleton.
5. Next.js skeleton.
6. Auth basic.
7. RBAC basic.

### Phase 2 â€” Master & Core

1. User/role/permission.
2. Company profile.
3. Numbering.
4. Master customer/location/surveyor.
5. Master container type/survey type.
6. Master CEDEX.

### Phase 3 â€” Job & Assignment

1. Job order.
2. Job container.
3. Import Excel.
4. Assignment surveyor.
5. Job timeline.

### Phase 4 â€” Surveyor Web

1. Job saya.
2. Start survey.
3. General info.
4. Checklist.
5. Survey sheet.
6. Damage.
7. Photo evidence.
8. Submit.

### Phase 5 â€” Review & Report

1. Pending review.
2. Need revision.
3. Approve.
4. Report generation.
5. Report archive.
6. QR validation.

### Phase 6 â€” Finance

1. Price list.
2. Ready to invoice.
3. Invoice.
4. Payment.
5. Outstanding.

### Phase 7 â€” Hardening

1. Permission test.
2. State machine test.
3. File upload test.
4. Backup test.
5. Performance test.
6. Staging UAT.
7. Production deployment.

### Phase 8 â€” Future Mobile

1. Flutter app foundation.
2. Local SQLite.
3. Job sync.
4. Offline draft.
5. Camera/GPS.
6. Background upload.
7. Submit sync.

---

## 38. Testing Architecture

### 38.1 Backend Tests

1. Unit test service.
2. Repository test.
3. Permission test.
4. State machine test.
5. API integration test.
6. File upload test.
7. PDF generation test.

### 38.2 Web Tests

1. Login flow.
2. Role menu visibility.
3. Job create flow.
4. Surveyor web flow.
5. Review flow.
6. Finance flow.
7. Error state.

### 38.3 End-to-End Tests

Critical E2E:

1. Job without damage.
2. Job with minor damage.
3. Damage without photo blocked.
4. Need revision flow.
5. Approve and generate report.
6. Invoice and payment.

---

## 39. Operational Runbook MVP

### 39.1 Common Commands

```text
Start services
Run migration
Seed data
Create super admin
Backup database
Restore database
Restart API
Restart worker
Check logs
```

### 39.2 Common Incidents

| Incident | Action |
|---|---|
| API down | Check container logs, restart API |
| DB down | Check MySQL container/volume, restore if needed |
| Upload failed | Check MinIO, disk space, credentials |
| PDF failed | Check worker logs, retry job |
| Login failed for all users | Check JWT config, database, API logs |
| Disk full | Cleanup temp files, increase storage, review backups |

---

## 40. Risks and Technical Mitigation

| Risiko Teknis | Dampak | Mitigasi |
|---|---|---|
| Upload foto besar | Lambat/storage cepat penuh | Compress, thumbnail, object storage |
| PDF generation berat | API lambat | Worker queue |
| Permission bocor | Data salah akses | Backend RBAC + tests |
| Status workflow kacau | Data korup | State machine service |
| Numbering duplicate | Dokumen kacau | DB transaction + lock |
| Database lambat | UX buruk | Index, pagination, query optimization |
| File hilang | Bukti survey hilang | Backup object storage |
| Mobile dibuat terlalu cepat | Banyak rewrite | Web MVP validasi alur dulu |
| Server tunggal down | Semua layanan down | Backup, monitoring, future scaling |

---

## 41. Checklist Kesiapan Implementasi

| Area | Status |
|---|---|
| Stack ditentukan | Required |
| Service architecture ditentukan | Required |
| Environment ditentukan | Required |
| Auth architecture ditentukan | Required |
| RBAC architecture ditentukan | Required |
| Database architecture ditentukan | Required |
| Storage architecture ditentukan | Required |
| Queue architecture ditentukan | Required |
| PDF architecture ditentukan | Required |
| Deployment topology ditentukan | Required |
| Backup strategy ditentukan | Required |
| Security rules ditentukan | Required |
| Performance strategy ditentukan | Required |
| Observability strategy ditentukan | Required |
| Future mobile readiness ditentukan | Required |

---

## 42. Catatan Akhir

Arsitektur yang disarankan adalah:

```text
Web App = Next.js + TypeScript
Backend API = Go + Gin
Database = MySQL
Storage = MinIO/S3
Queue/Cache = Redis
Worker = Go worker
Future Mobile = Flutter + SQLite
Deployment = Docker + Nginx + Ubuntu
```

Keputusan paling penting:

1. Semua role dibuat di Web MVP untuk validasi alur.
2. Surveyor Web bukan target akhir lapangan.
3. Backend API dan database harus dibuat mobile-ready sejak awal.
4. File foto/PDF harus disimpan di object storage.
5. Proses berat harus masuk worker queue.
6. Permission dan state machine wajib ditegakkan di backend.

Dengan struktur ini, sistem dapat dikembangkan bertahap: Web MVP dulu, lalu mobile app surveyor setelah alur bisnis, database, API, dan report sudah stabil.


