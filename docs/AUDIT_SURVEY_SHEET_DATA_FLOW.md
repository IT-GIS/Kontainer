# Audit Survey Sheet Data Flow

Tanggal audit: 2 September 2026
Repository: `IT-GIS/Kontainer`
Branch/HEAD saat audit: `codex/redesign-surveyor-survey-sheet` / `29c755d`

## Ruang lingkup dan batas

- Dokumen ini merekam kondisi sebelum implementasi integrasi Survey Sheet CEDEX end-to-end.
- Tidak ditemukan `AGENTS.md` di repository.
- Worktree sudah memiliki perubahan dan file tidak terlacak milik pengguna; implementasi tidak boleh mereset, membersihkan, atau ikut mengubah file yang tidak terkait.
- Route legacy, permission, endpoint existing, dan sumber data resmi dipertahankan.
- Database tidak boleh diubah secara destruktif. Perubahan schema yang diperlukan harus additive.
- `MGM`, `TCT`, `3rd Scty Sys`, dan `Cu-Cap` tetap berstatus `DOMAIN GAP`; tidak boleh dipetakan ke field lain tanpa definisi bisnis yang disahkan.
- `gross_weight` tetap ditampilkan sebagai Gross Weight dan tidak dilabeli MGM.

## Ringkasan sumber data saat ini

| Kelompok | Sumber resmi saat ini | Endpoint utama | UI utama | Temuan audit |
|---|---|---|---|---|
| Customer | `customers` | `GET/PUT /master/customers/:id` | Customer & Master, Setup Customer | Sudah menjadi satu sumber editable. |
| Location | `locations` scoped Customer | `/customers/:id/locations` | Lokasi & PIC; Job create | Sudah scoped Customer dan active. |
| PIC | `customer_personnel` + `customer_personnel_locations` | `/customers/:id/personnel`, `/customers/:id/locations/:locationId/personnel` | Lokasi & PIC; Job create | Job memvalidasi PIC benar-benar terpetakan ke Location yang dipilih, tetapi readiness umum belum menghitung mapping aktif. |
| Survey Type | `survey_types` scoped Customer | `/customers/:id/survey-types` | Setup Customer; Job create | Sudah dipilih saat Job dan read-only pada Survey. |
| Container Type | `container_types` scoped Customer | `/customers/:id/container-types` | Setup Customer; Job Container | Sudah dipilih per unit; code/size/ISO diteruskan sebagian ke Surveyor. |
| Data peti kemas | `job_containers` | `/jobs/:id/containers` | Job Detail | Sudah menyimpan container number, cargo, gross, tare, payload, manufacture, serta detail CSC; kontrak Survey belum membawa seluruh field. |
| Hasil lapangan | `survey_general_infos` | `PUT /surveys/:id/general-info` | Identitas Peti Kemas | `general_condition` tersedia; `cleanliness` belum tersedia. Cargo/CSC saat ini dapat diedit sebagai verifikasi, tetapi UI belum membedakan data awal dan hasil verifikasi dengan jelas. |
| Master CEDEX | `cedex_locations`, `cedex_components`, `cedex_damages`, `cedex_repairs`, `cedex_materials` | `/surveys/:id/master-options`, route master existing | `IsoCedexWorkspace`, Temuan Surveyor | Effective master sudah menggunakan override Customer aktif dengan Global fallback dan isolasi Customer. Entry point utama Customer & Master belum jelas. |
| Checklist | snapshot `survey_checklist_responses` dari template | `/surveys/:id/checklist` | Checklist Surveyor/Reviewer | Instance dibuat saat Survey start. Response Tidak Baik dapat ditautkan ke Temuan melalui `checklist_response_id`. |
| Referensi | mapping Customer + Survey Type | `/customers/:id/survey-types/:surveyTypeId/reference-options` | Setup Customer, Decision Rule, Reviewer | Existing dan direuse; tidak perlu endpoint baru. |
| Foto | `survey_photos` + `file_objects` | `/surveys/:id/photos`, `/survey-damages/:id/photos` | Surveyor, Reviewer | General photo menggunakan `damage_id NULL`; finding photo menggunakan Survey + Finding yang sama. |
| Reviewer | Survey, general info, checklist, finding, photo | `/reviews/:id` | Review & Keputusan | Read-only terhadap source administratif, tetapi header detail belum membawa semua field Job Container. |
| Report | `reports` yang mereferensikan Survey/Job/Customer | `/reports`, `/reports/:id` | Laporan | Tidak ada form input ulang. Detail metadata belum mengekspos header Survey Sheet lengkap. |

## Audit field current-to-target

| Current field | Current table | Current endpoint | Current UI | Target source | Target destination | Gap | Action | Migration required? | Risk |
|---|---|---|---|---|---|---|---|---|---|
| Customer / Client | `customers.customer_name` melalui Job | `/surveys/:id/preview`, `/reviews/:id`, `/reports/:id` | Surveyor/Reviewer/Report | Customer | Semua header read-only | Sudah tersedia, label/provenance belum konsisten | Pertahankan kontrak dan tampilkan sebagai field terkunci bersumber Customer | Tidak | Rendah |
| Container Nbrs | `job_containers.container_no` | endpoint Survey/Review/Report existing | Semua menu | Job Container | Semua header read-only | Sudah tersedia | Pertahankan satu sumber dan tampilkan badge Peti Kemas | Tidak | Rendah |
| Type of Survey | `job_orders.survey_type_id` / `surveys.survey_type_id` | endpoint existing | Semua menu | Customer config, dipilih di Job | Survey/Review/Report read-only | Sudah tersedia, konfigurasi Customer belum diringkas di satu layar | Tambah pusat Konfigurasi Survey Sheet | Tidak | Rendah |
| Size | `container_types.size` | `/surveys/:id/preview` | Surveyor | Container Type per Job Container | Survey/Review/Report | Surveyor tersedia; Review/Report belum lengkap | Perluas kontrak read-only Review/Report | Tidak | Rendah |
| Date Manufacture | `job_containers.manufacture_date` | Job Container; sebagian Survey detail | Job, Surveyor | Job Container | Survey/Review/Report | Review/Report belum lengkap | Perluas kontrak tanpa copy editable | Tidak | Rendah |
| Status MTY/FULL | `job_containers.cargo_status`; snapshot awal pada `survey_general_infos.cargo_status` | Job Container; General Info | Job, Surveyor | Job Container + verifikasi Surveyor | Survey/Review/Report | UI belum membedakan data awal vs verifikasi | Tampilkan nilai awal terkunci dan hasil verifikasi terpisah | Tidak | Sedang |
| Type | `job_containers.container_type_id` → `container_types` | Survey preview | Surveyor | Job Container | Survey/Review/Report | Review/Report belum lengkap | Perluas kontrak | Tidak | Rendah |
| CSC Plate Status | `job_containers.csc_plate_status`; verifikasi `survey_general_infos.csc_plate_status` | Job Container; General Info | Job, Surveyor | Job Container + verifikasi Surveyor | Survey/Review/Report | Provenance belum jelas | Tampilkan data awal dan verifikasi terpisah | Tidak | Sedang |
| CSC Plate Number | `job_containers.csc_plate_number` | Job Container | Job | Job Container | Survey/Review/Report | Belum dibawa `SurveyDetail`; Surveyor menampilkan placeholder salah | Perluas query/type/UI | Tidak | Rendah |
| CSC Approval Reference | `job_containers.csc_approval_reference` | Job Container | Job | Job Container | Survey/Review/Report | Belum dibawa `SurveyDetail` | Perluas query/type/UI | Tidak | Rendah |
| CSC Manufacture Date | `job_containers.csc_manufacture_date` | Job Container | Job | Job Container | Survey/Review/Report | Belum dibawa `SurveyDetail` | Perluas query/type/UI | Tidak | Rendah |
| CSC Next Examination | `job_containers.csc_next_examination_date` | Job Container | Job | Job Container | Survey/Review/Report | Belum dibawa `SurveyDetail` | Perluas query/type/UI | Tidak | Rendah |
| CSC Program / ACEP candidate | `job_containers.csc_program_type` | Job Container | Job | Job Container | Survey/Review/Report | Belum dibawa; ACEP belum boleh disimpulkan hanya dari label | Tampilkan sebagai `CSC Program Type`; beri catatan ACEP menunggu konfirmasi | Tidak | Rendah |
| Condition DMG/AVL/AR | `survey_general_infos.general_condition` | `PUT /surveys/:id/general-info` | Surveyor | Hasil Survey | Survey/Review/Report | Opsi UI existing `sound/damage/dirty` tidak sesuai acuan | Gunakan field existing dengan nilai canonical `DMG/AVL/AR`; tetap Surveyor-only | Tidak | Sedang, kompatibilitas nilai legacy |
| MGM | Belum terdefinisi | Tidak ada kontrak sah | Tidak boleh ditampilkan final | DOMAIN GAP | TBD | Definisi, type, owner, dan scope belum disahkan | Jangan implementasikan atau menganggap `gross_weight` sebagai MGM | Tidak | Tinggi bila ditebak |
| Gross Weight | `job_containers.gross_weight` | Job Container | Job | Job Container | Header data awal bila diperlukan | Tidak dibawa `SurveyDetail` | Perluas kontrak dengan label Gross Weight, bukan MGM | Tidak | Rendah |
| Cleanliness DTY/CTM | Belum ada field dedicated | Tidak ada | Belum ada | Hasil Survey | Survey/Review/Report | Gap schema/API/UI/test | Tambah kolom additive `survey_general_infos.cleanliness` dan validasi `DTY/CTM` | Ya, additive | Sedang |
| Payload | `job_containers.payload` | Job Container | Job | Job Container | Survey/Review/Report read-only | Tidak dibawa `SurveyDetail` | Perluas kontrak | Tidak | Rendah |
| TCT | Belum terdefinisi | Tidak ada | Tidak boleh ditampilkan final | DOMAIN GAP | TBD | Definisi belum disahkan | Jangan implementasikan | Tidak | Tinggi bila ditebak |
| Survey Location | `job_orders.location_id` → `locations` | endpoint existing | Semua menu | Job | Survey/Review/Report read-only | Sudah tersedia | Tambah provenance badge dan pertahankan snapshot/reference | Tidak | Rendah |
| Tare | `job_containers.tare_weight` | Job Container | Job | Job Container | Survey/Review/Report read-only | Tidak dibawa `SurveyDetail` | Perluas kontrak | Tidak | Rendah |
| 3rd Scty Sys | Belum terdefinisi | Tidak ada | Tidak boleh ditampilkan final | DOMAIN GAP | TBD | Definisi belum disahkan | Jangan implementasikan | Tidak | Tinggi bila ditebak |
| Date of Survey | `surveys.started_at`; `survey_general_infos.survey_date_time` | Survey preview | Surveyor | Sistem saat Survey start | Survey/Review/Report | Ringkasan UI masih memakai SPK/due date pada konteks Survey Sheet | Gunakan `started_at` sebagai tanggal utama; perubahan `survey_date_time` tetap audit | Tidak | Sedang |
| Cu-Cap | Belum terdefinisi | Tidak ada | Tidak boleh ditampilkan final | DOMAIN GAP | TBD | Definisi belum disahkan | Jangan implementasikan | Tidak | Tinggi bila ditebak |

## Field audit matrix wajib

| Field | Current Source | Target Source | Surveyor Auto | Surveyor Editable | Reviewer | Report | Status |
|---|---|---|---|---|---|---|---|
| Customer | `customers` melalui Job | Customer | Ya | Tidak | Read-only | Display | Sesuai; perjelas source |
| Container Number | `job_containers.container_no` | Job Container | Ya | Tidak | Read-only | Display | Sesuai |
| Survey Type | `survey_types` dipilih pada Job | Customer config → Job | Ya | Tidak | Read-only | Display | Sesuai |
| Size | `container_types.size` | Job Container → Container Type | Ya | Tidak | Perlu dilengkapi | Perlu dilengkapi | Partial |
| Manufacture | `job_containers.manufacture_date` | Job Container | Ya | Verifikasi terkontrol saja | Perlu dilengkapi | Perlu dilengkapi | Partial |
| Cargo Status | Job Container + General Info | Job Container + verifikasi Surveyor | Ya | Hanya hasil verifikasi | Read-only | Display | Partial, provenance perlu diperjelas |
| Type | `container_types` dari Job Container | Job Container | Ya | Tidak | Perlu dilengkapi | Perlu dilengkapi | Partial |
| CSC | Status awal + status verifikasi | Job Container + verifikasi Surveyor | Ya | Hanya hasil verifikasi | Perlu dilengkapi | Perlu dilengkapi | Partial |
| Condition | `survey_general_infos.general_condition` | Hasil Survey | Tidak | Ya, DMG/AVL/AR | Read-only | Display | Nilai UI perlu dikoreksi |
| MGM | Tidak ada definisi | DOMAIN GAP | Tidak | TBD | TBD | TBD | DOMAIN GAP |
| ACEP | `csc_program_type` kandidat | Menunggu definisi; tampilkan nama canonical | Ya sebagai CSC Program | Verifikasi bila rule sah | Read-only | Display | DOMAIN GAP label, data canonical tersedia |
| Cleanliness | Belum ada | `survey_general_infos.cleanliness` | Tidak | Ya, DTY/CTM | Read-only | Display | Gap additive |
| Payload | `job_containers.payload` | Job Container | Ya | Tidak | Read-only | Display | Kontrak Survey perlu dilengkapi |
| TCT | Tidak ada definisi | DOMAIN GAP | Tidak | TBD | TBD | TBD | DOMAIN GAP |
| Location | `job_orders.location_id` | Job | Ya | Tidak | Read-only | Display | Sesuai |
| Tare | `job_containers.tare_weight` | Job Container | Ya | Tidak | Read-only | Display | Kontrak Survey perlu dilengkapi |
| 3rd Scty Sys | Tidak ada definisi | DOMAIN GAP | Tidak | TBD | TBD | TBD | DOMAIN GAP |
| Date Survey | `surveys.started_at` + audited `survey_date_time` | Sistem / Survey start | Ya | Tidak secara diam-diam | Read-only | Display | UI perlu memakai sumber benar |
| Cu-Cap | Tidak ada definisi | DOMAIN GAP | Tidak | TBD | TBD | TBD | DOMAIN GAP |

## Audit readiness

### Readiness daftar Customer

`ListCustomerReadiness` saat ini menghitung Location dan Personel/PIC secara terpisah. Belum ada check `location_pic_mapping` yang membuktikan adanya mapping antara Location aktif dan PIC aktif.

### Hard gate operasional

`EvaluateReadinessTx` dipakai oleh pembuatan Job, Assignment, dan Start Survey. Gate ini juga menghitung Location/PIC secara terpisah. Pembuatan Job sudah memiliki validasi tambahan yang tepat: PIC harus aktif, milik Customer, dan terpetakan ke Location yang dipilih. Namun Assignment dan Start Survey tetap membutuhkan check mapping dalam readiness agar konfigurasi yang kehilangan mapping tidak lolos.

Action: tambahkan hitungan mapping dengan join ke Location dan PIC aktif pada kedua kontrak readiness, tanpa menambah tabel atau endpoint.

## Audit CEDEX dan permission

- `IsoCedexWorkspace` dan route `/master/iso-cedex` tersedia dan tidak boleh dihapus.
- Route legacy `/master/cedex/*` masih mengarah ke workspace CEDEX yang sama.
- `GET /surveys/:id/master-options` sudah memberikan CEDEX efektif per Customer.
- Validasi Temuan menolak CEDEX yang inactive atau berasal dari Customer lain.
- Surveyor hanya memilih CEDEX melalui endpoint Survey; pengajuan kode tersedia dan tidak langsung mengubah master.
- Mutasi Global/Customer CEDEX tetap mengikuti permission resource existing.
- Gap UX: navigasi Customer & Master belum menandai route CEDEX/Referensi sebagai bagian dari pusat konfigurasi dan landing belum memiliki tiga entry point eksplisit.

## Rencana perubahan hasil audit

1. Buat landing Customer & Master dengan entry point Customer, Master CEDEX, dan Master Pemeriksaan; route existing direuse.
2. Ubah setup Customer menjadi delapan tahap domain, tambahkan `Konfigurasi Survey Sheet`, dan ubah label CEDEX Customer agar tidak rancu dengan kamus global.
3. Buat ringkasan konfigurasi Survey Sheet yang membaca endpoint existing serta menerangkan source/owner tiap field tanpa menyimpan field peti kemas ke Customer.
4. Perluas query `SurveyDetail`, Reviewer, dan Report dengan field read-only dari Job Container yang sudah ada.
5. Tambah `cleanliness` secara additive ke DB, API, UI, Review, Report, dan test.
6. Gunakan `general_condition` existing untuk Condition DMG/AVL/AR serta pertahankan kompatibilitas nilai legacy pada display.
7. Perjelas data awal Admin versus hasil verifikasi Surveyor untuk Cargo dan CSC.
8. Gunakan `surveys.started_at` sebagai Date of Survey utama.
9. Tambah check mapping Location–PIC pada readiness daftar dan hard gate.
10. Perluas contract test Survey Sheet dan test backend untuk nilai Condition/Cleanliness/readiness.
