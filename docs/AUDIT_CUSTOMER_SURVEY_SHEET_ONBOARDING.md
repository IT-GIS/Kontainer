# Audit Customer Onboarding dan Survey Sheet

Tanggal audit: 2 September 2026
Branch: `codex/redesign-surveyor-survey-sheet`
Baseline: `7eafd6e feat: integrate survey sheet data flow`

## Ringkasan

Fondasi alur Customer -> Job -> Peti Kemas -> Assignment -> Survey -> Review -> Report sudah tersedia dan endpoint existing dapat dipakai kembali. Implementasi tidak memerlukan rebuild database atau business logic paralel. Gap yang perlu ditutup adalah orkestrasi onboarding, istilah konfigurasi evidence, CTA readiness, provenance mismatch, serta kelengkapan data Report.

MGM, TCT, 3rd Scty Sys, dan Cu-Cap tetap dinyatakan sebagai domain gap. Tidak ada source, datatype, atau ownership baru yang ditebak pada implementasi ini.

## Matriks audit

| Area | Current route/component | Current field source | Current endpoint | Target source/menu | Gap | Action | Migration needed? | Risk |
|---|---|---|---|---|---|---|---|---|
| Create Customer | `/master/customers/create`; `MasterDataPage` dalam create mode | Form Customer | `POST /master/customers` | Setup Customer -> Lokasi & PIC | Hasil create tidak mempunyai callback redirect; submit masih berlabel generik | Pasang `onSaved(row, "create")`, validasi `row.id`, lalu `router.replace(...?tab=location-pic)`; ubah CTA menjadi `Simpan & Lanjut` | Tidak | Rendah; endpoint dan payload tidak berubah |
| Profil Customer | `CustomerProfile` | `customers` | `GET/PUT /master/customers/:id` | Profil Customer | Sudah memuat kode, nama, alamat, NPWP, kontak, telepon, email, billing, termin, status | Reuse tanpa backend baru | Tidak | Rendah |
| Lokasi & PIC | `LocationAndPic`, `PersonnelLocationMapping` | Customer Location, Personnel, mapping | `/customers/:id/locations`, `/personnel`, `/location-personnel-mappings` | Lokasi & PIC | Sudah satu area dan readiness memakai mapping aktif | Reuse | Tidak | Rendah |
| Konfigurasi Survey Sheet | `SurveySheetConfiguration` | Customer, Customer scoped masters, Job Container, Job, Surveyor | Endpoint customer scoped existing | Konfigurasi Survey Sheet | Pusat konfigurasi sudah ada; label evidence masih `Photo / Evidence`, sehingga dapat disalahartikan sebagai upload aktual | Ubah istilah Admin menjadi `Kebutuhan Foto / Evidence`; pertahankan foto aktual pada Surveyor | Tidak | Rendah |
| Checklist | `ChecklistReferenceTab`; Surveyor `ChecklistTab` | Template/item Customer dan snapshot response Survey | Endpoint checklist existing | Checklist | Checklist otomatis dibuat saat Survey dimulai; jawaban `no` dapat ditautkan ke Finding | Reuse | Tidak | Rendah |
| Referensi pemeriksaan | `SurveyTypeReferenceConfiguration` | Mapping Customer + master aktif | `/customers/:id/survey-types/:surveyTypeId/reference-options` | Referensi Pemeriksaan | Sudah dibaca Admin, Surveyor, dan Reviewer tanpa input ulang | Reuse | Tidak | Rendah |
| Requirement evidence | `SurveyTypeReferenceConfiguration` | Mapping kategori Customer per Survey Type | Endpoint reference-options existing | Kebutuhan Foto / Evidence | Data benar, istilah UI Admin belum membedakan requirement dan upload aktual | Rename label dan explanatory copy pada area Admin | Tidak | Rendah |
| Evidence aktual | Surveyor tab Foto dan Finding editor | `survey_photos`; `damage_id NULL` untuk umum atau Finding ID | `POST /surveys/:id/photos`, `POST /survey-damages/:id/photos` | Surveyor -> Reviewer -> Report | Flow sudah satu sumber; Admin tidak mempunyai upload inspeksi | Reuse | Tidak | Sedang; storage round-trip tetap bergantung MinIO/runtime |
| Master CEDEX | `/master/iso-cedex`; `IsoCedexWorkspace` | Global dan Customer override efektif | Master CEDEX CRUD dan `/surveys/:id/master-options` | Master CEDEX / Konfigurasi CEDEX Customer | CRUD, active/inactive, search/filter/pagination, permission, fallback, dan proposal sudah tersedia | Reuse | Tidak | Rendah |
| Job / SPK | `/jobs/create` | Admin | `POST /jobs` | Buat Pekerjaan | Field target dan hard gate backend sudah ada; pesan frontend belum memberi CTA `Lengkapi Customer` | Tampilkan daftar missing checks dan link langsung ke tab readiness Customer | Tidak | Rendah |
| Peti Kemas | `/jobs/:id` tab Peti Kemas | Job Container | `POST /jobs/:id/containers` | Job -> Peti Kemas | Field container, ISO, cargo, weight, CSC, truck, driver, remark, check digit tersedia per unit | Reuse | Tidak | Rendah |
| Start Survey / snapshot | Surveyor assigned container | Customer, Job, Job Container saat start | `POST /surveys/start` | Header Survey Sheet | `survey_general_infos` sudah menyimpan snapshot customer, location, survey type, Job/SPK, container type/size, manufacture, weight, cargo, CSC | Reuse migration additive `0019` yang sudah ada | Tidak | Rendah |
| Condition & Cleanliness | Surveyor Identitas Peti Kemas | Surveyor | `PUT /surveys/:id/general-info` | Hasil verifikasi Surveyor | UI sudah canonical, tetapi backend masih menerima nilai condition legacy dan mismatch awal/verifikasi tidak mewajibkan catatan | Batasi condition ke DMG/AVL/AR; jika Cargo atau CSC berbeda dari snapshot awal, wajibkan `general_remark`; masukkan nilai verifikasi dan catatan pada audit after-state | Tidak | Sedang; validasi lebih ketat hanya pada mutasi Surveyor |
| Finding description | Finding editor dan repository | Effective CEDEX + dimensi + kuantitas | Damage create/update existing | Finding | `finding_description` sudah dibentuk server-side dan remark terpisah | Reuse | Tidak | Rendah |
| Reviewer | `/review/:id` | Snapshot Survey, checklist, damages, photos | `/reviews/:id` dan action review | Review & Keputusan | Header, checklist, Survey Sheet, Finding, evidence, recommendation, target revision, approve/reject sudah read-only/reuse | Tambahkan indikator mismatch agar provenance eksplisit | Tidak | Rendah |
| Report | `/reports/:id`; backend berada di package `reviews` | Snapshot Survey + transaksi Survey | `GET /reports/:id` | Laporan | Header, Finding, dan Photo sudah reuse; Checklist dan detail keputusan Reviewer belum dikembalikan/ditampilkan | Tambahkan query read-only checklist dan approval history pada response Report, type frontend, dan dua panel read-only | Tidak | Rendah |
| Status end-to-end | Job status helper, Surveyor, Review, Report | Status transaksi | Endpoint workflow existing | Semua menu | Transition assign/start/submit/revision/resubmit/approve/reject dan human label sudah tersedia | Reuse dan validasi regression | Tidak | Sedang; perlu UAT multi-role untuk bukti runtime penuh |
| Permission | Route middleware + UI `can(...)` | Permission existing | Route existing | Admin/Surveyor/Reviewer | Surveyor mutation role dan Reviewer decision role sudah dibatasi; Surveyor tidak mendapat CRUD Global CEDEX | Reuse | Tidak | Rendah |
| Customer isolation | Effective master/query ownership | `customer_id` + Survey Type | Endpoint existing | Customer-specific config | Query CEDEX override/fallback, reference mapping, dan Job ownership sudah customer-scoped | Reuse dan pertahankan test | Tidak | Rendah |
| Multi-container isolation | Survey terkait `job_container_id` | Job Container + Survey snapshot | Endpoint existing | Per unit | Survey dimulai per assigned container dan snapshot memakai container ID terkait | Reuse dan pertahankan test | Tidak | Rendah |

## Route dan endpoint yang dipakai kembali

- `POST /master/customers`
- `GET/PUT /master/customers/:id`
- `GET /customers/:id/readiness`
- Customer Location, Personnel, Location-PIC mapping, Survey Type, Container Type, reference-options, dan effective master endpoints existing
- `POST /jobs`, `POST /jobs/:id/containers`, dan `POST /jobs/:id/assign`
- `POST /surveys/start`, Survey preview/general/checklist/damage/photo/submit endpoints existing
- Review detail/start/need-revision/approve/reject endpoints existing
- `GET /reports/:id` dan `GET /reports/:id/versions`

## Keputusan migration

Tidak ada migration baru. Snapshot header dan field `cleanliness` sudah disediakan secara additive oleh `services/api/migrations/0019_survey_sheet_data_flow.up.sql`. Perbaikan Report hanya menambah data hasil query dari tabel existing; provenance mismatch memakai `general_remark` dan audit log existing.

## Batas verifikasi

Browser UAT terautentikasi memerlukan stack API, database, object storage, akun multi-role, dan master aktif. Jika fixture atau service tersebut tidak tersedia, hasilnya harus dicatat sebagai evidence gap dan tidak boleh diklaim PASS hanya dari pemeriksaan source.
