# Matriks UAT Penyesuaian Menu Admin dan Database 15

Tanggal: 24 Juli 2026
Lingkungan: bukti UAT sebelumnya dipertahankan; follow-up ini memakai clean container MySQL 8.4.10 pada port 3307 dan build production lokal. Tidak ada data produksi yang diubah.
Data: bukti UAT sebelumnya memakai data sintetis; follow-up clean migration tidak memasukkan data bisnis dan tidak menyentuh database produksi.

Arti status:

- **PASS**: skenario dijalankan dan hasil aktual sesuai ekspektasi.
- **PARTIAL**: sebagian bukti tersedia, tetapi ada komponen yang belum dapat diverifikasi.
- **BLOCKED**: tidak dapat dijalankan karena dependensi/keputusan belum tersedia.
- **DECISION_REQUIRED**: membutuhkan keputusan atau sumber resmi.
- **NOT_TESTED**: belum dijalankan.

## 1. Navigasi dan isolasi role

UAT DOM dijalankan melalui Microsoft Edge headless/CDP pada lebar desktop. Login API juga diuji untuk seluruh enam role existing.

| No. | Skenario | Ekspektasi | Hasil aktual | Status |
|---:|---|---|---|---|
| 1 | Login Super Admin | Token aktif diterbitkan | Login berhasil | PASS |
| 2 | Login Admin | Token aktif diterbitkan | Login berhasil | PASS |
| 3 | Login Supervisor | Token aktif diterbitkan | Login berhasil | PASS |
| 4 | Login Surveyor | Token aktif diterbitkan | Login berhasil | PASS |
| 5 | Login Management | Token aktif diterbitkan | Login berhasil | PASS |
| 6 | Login Finance | Token aktif diterbitkan | Login berhasil | PASS |
| 7 | Sidebar Admin pada scope `container_fitness` | Enam grup canonical tersedia | Label wajib lengkap; tidak ada item terlarang | PASS |
| 8 | Sidebar Supervisor | Review & Keputusan dan Dokumen & Laporan tersedia; menu persiapan Admin tidak ada | Sesuai | PASS |
| 9 | Sidebar Surveyor | Dashboard Surveyor, Pekerjaan Saya, Perlu Revisi tersedia; menu Admin/Review tidak ada | Sesuai | PASS |
| 10 | Sidebar Management | Dashboard, Dokumen & Laporan, Rekap Customer; tidak ada mutation workspace Admin | Sesuai | PASS |
| 11 | Sidebar Finance | Workspace Finance tetap terpisah; tidak bercampur dengan Admin Kelaikan | Sesuai | PASS |
| 12 | Horizontal overflow role pages | Tidak ada overflow pada viewport uji | `scrollWidth <= clientWidth` untuk lima role | PASS |
| 13 | Label Admin terlarang | Ready to Invoice, Workshop, Billing, QR Validation, Public Verification tidak ada | Tidak ditemukan pada sidebar Admin | PASS |
| 14 | Satu ISO CEDEX dan Referensi Pemeriksaan | Masing-masing satu item menu | Source check dan DOM Admin sesuai | PASS |
| 15 | Compatibility assignment | `/fitness/assignments` menuju `/jobs?view=assigned` | Redirect dan query sesuai | PASS |

Catatan: runtime in-app browser bawaan tidak dapat bootstrap karena `codex/sandbox-state-meta: missing field sandboxPolicy`. Edge CDP digunakan sebagai fallback terkontrol. Pengujian role di atas adalah assertion DOM dan overflow; screenshot terpisah tersedia untuk tujuh layar utama Admin.

## 2. Customer readiness dan isolasi Customer

| No. | Skenario | Ekspektasi | Hasil aktual | Status |
|---:|---|---|---|---|
| 1 | Daftar readiness 12 Customer | Seluruh Customer mendapatkan hasil readiness | 12 hasil dikembalikan | PASS |
| 2 | Customer lengkap UAT | Seluruh 16 komponen siap | `16/16`, field canonical `id` terbaca | PASS |
| 3 | Customer dengan data kurang | Komponen yang tidak ada berstatus belum siap | Hasil mengikuti count aktual per Customer | PASS |
| 4 | Customer tidak aktif melakukan mutation master | Ditolak backend | HTTP 422 | PASS |
| 5 | Company Profile record kedua | Ditolak karena satu form fisik/record aktif | HTTP 422 | PASS |
| 6 | Mapping PIC ke Location Customer yang sama | Berhasil | HTTP 200; GET mengembalikan satu PIC | PASS |
| 7 | Mapping Location Customer lain/tidak aktif | Ditolak backend | HTTP 422 | PASS |
| 8 | Job memakai PIC Customer lain | Ditolak backend | HTTP 422 | PASS |
| 9 | Job memakai Location Customer lain | Ditolak backend | HTTP 422 | PASS |
| 10 | Job memakai Survey Type Customer lain | Ditolak backend | HTTP 422 `VALIDATION_ERROR` | PASS |
| 11 | Peti Kemas memakai Container Type Customer lain | Ditolak backend | HTTP 422 `VALIDATION_ERROR` | PASS |
| 12 | Job memakai Customer tidak aktif | Ditolak backend | HTTP 422 | PASS |
| 13 | CEDEX kode sama pada Customer A dan B | Keduanya boleh dibuat | HTTP 201 untuk A dan B | PASS |
| 14 | CEDEX duplikat dalam Customer yang sama | Ditolak | HTTP 409 | PASS |
| 15 | Master options Surveyor untuk Customer A | Tidak memuat CEDEX Customer lain | Endpoint mengembalikan masing-masing satu item milik Customer A walau database memiliki 4–7 item aktif Customer lain per kategori | PASS |
| 16 | Legacy `customer_id IS NULL` | Tidak muncul pada workflow aktif | Endpoint operasional hanya mengembalikan data customer-scoped aktif | PASS |

Readiness dihitung untuk:

1. Profil;
2. Personel/PIC aktif;
3. Location aktif;
4. Survey Type aktif;
5. Container Type aktif;
6. Checklist Template aktif;
7. Checklist Item aktif;
8. mapping Severity;
9. mapping Test Parameter;
10. mapping Photo Category;
11. CEDEX Location;
12. CEDEX Component;
13. CEDEX Damage;
14. CEDEX Action Repair;
15. CEDEX Material;
16. Responsibility Code.

## 3. Job, SPK, assignment, dan Surveyor

| No. | Skenario | Ekspektasi | Hasil aktual | Status |
|---:|---|---|---|---|
| 1 | Create Job dengan metadata SPK | Tersimpan | HTTP 201 | PASS |
| 2 | Baca ulang Job | Nomor/tanggal/catatan SPK tersedia | Nilai sama dengan payload UAT | PASS |
| 3 | Add Peti Kemas customer-scoped | Container Type milik Customer diterima | HTTP 201 | PASS |
| 4 | Assign Surveyor GIFT aktif | Berhasil | HTTP 200 | PASS |
| 5 | Reassign ke Surveyor GIFT tidak aktif | Ditolak | HTTP 422 | PASS |
| 6 | Surveyor mulai survey yang ditugaskan | Survey draft dan snapshot checklist dibuat | HTTP 201 | PASS |
| 7 | Super Admin menulis data teknis Surveyor | Ditolak karena active role bukan Surveyor | HTTP 403 | PASS |
| 8 | Admin menulis general info teknis melalui request manual | Ditolak | HTTP 403 | PASS |
| 9 | Upload lampiran SPK | Tidak membuat fake upload | UI menyatakan fitur belum aktif | BLOCKED |
| 10 | Upload foto ke object storage live | Tidak boleh diklaim tanpa storage | Tidak dijalankan; dump memiliki 0 file dan 0 foto | NOT_TESTED |

## 4. Siklus pemeriksaan dan review

Satu survey UAT baru dan satu survey draft UAT existing digunakan pada salinan database.

| No. | Langkah | Ekspektasi | Hasil aktual | Status |
|---:|---|---|---|---|
| 1 | Start Survey | Status draft | Survey `GIFT-SVY-2026-000008` dibuat dalam status draft | PASS |
| 2 | Isi General Info | Hanya Surveyor aktif yang dapat menulis | Tersimpan | PASS |
| 3 | Isi Checklist snapshot | Item wajib lengkap | `completed_items=1` | PASS |
| 4 | Submit pertama | Status submitted | `submitted` | PASS |
| 5 | Supervisor Need Revision | Status need_revision dan revision note | `need_revision` | PASS |
| 6 | Surveyor memperbaiki data | Status editable kembali dan catatan berubah | Tersimpan | PASS |
| 7 | Resubmit | Status submitted | `submitted` | PASS |
| 8 | Supervisor Approve | Status approved | `approved` | PASS |
| 9 | Jumlah report setelah approve | Tidak bertambah otomatis | Tetap `2 → 2` | PASS |
| 10 | Skenario submit kedua | Siap direview | `submitted` | PASS |
| 11 | Supervisor Reject | Status rejected dengan alasan | `rejected` | PASS |
| 12 | Admin melakukan Approve dengan permission salah konfigurasi | Tetap ditolak oleh role gate | HTTP 403 | PASS |
| 13 | Management membuat Job/mutation | Ditolak | HTTP 403 | PASS |
| 14 | Audit mutation penting | Start, update general, checklist, submit, revision, approve, reject tercatat | Action ditemukan di `audit_logs` | PASS |

Foto tidak menjadi syarat palsu pada skenario UAT ini karena template UAT tidak mewajibkan attachment dan object storage belum dibuktikan aktif.

## 5. Dokumen, laporan, dan fitur yang tetap nonaktif

| No. | Skenario | Ekspektasi | Hasil aktual | Status |
|---:|---|---|---|---|
| 1 | Approval dengan `generate_report=false` | Tidak membuat report otomatis | Count report tetap 2 | PASS |
| 2 | Download final PDF | Fitur tidak aktif | HTTP 409 `FEATURE_NOT_ACTIVE` | PASS |
| 3 | Generate report | Fitur tidak aktif | HTTP 409 `FEATURE_NOT_ACTIVE` | PASS |
| 4 | Public QR verification | Fitur tidak aktif | HTTP 409 `FEATURE_NOT_ACTIVE` | PASS |
| 5 | Version/metadata report existing | Read-only | Endpoint/list existing dapat dibaca | PASS |
| 6 | Final document live | Tidak diklaim aktif | Bergantung pada keputusan bisnis dan object storage | BLOCKED |

## 6. Penomoran, Company Profile, dan Audit Log

| No. | Skenario | Ekspektasi | Hasil aktual | Status |
|---:|---|---|---|---|
| 1 | GET penomoran | Preview tanpa increment | Nilai sequence sebelum/sesudah sama | PASS |
| 2 | Company Profile satu form | Satu record aktif, record kedua ditolak | Sesuai | PASS |
| 3 | Field Company Profile belum lengkap | Warning tampil | Address/phone/email/logo terdeteksi belum lengkap | PASS |
| 4 | Audit Log | Paginated/search/read-only | GET berhasil; tidak ada mutation endpoint UI | PASS |
| 5 | Audit context | Waktu, pengguna/role, action, entity/ID dan metadata tersedia sesuai kolom | Data tampil dari record existing | PASS |

## 7. Database migration

| No. | Skenario | Ekspektasi | Hasil aktual | Status |
|---:|---|---|---|---|
| 1 | Audit nomor migration | Gunakan nomor aktual setelah migration terakhir | `0011` terakhir; dipakai `0012` | PASS |
| 2 | Audit orphan `survey_id` | Tidak tambah FK bila ada orphan | 0 orphan | PASS |
| 3 | Audit orphan `template_item_id` | Tidak tambah FK bila ada orphan | 0 orphan | PASS |
| 4 | Upgrade copy DB15 | Kolom SPK dan FK bertambah | 4 kolom SPK dan 3 FK target tersedia | PASS |
| 5 | Down migration DB15 | Perubahan `0012` dapat di-rollback | Kolom/FK target kembali 0 | PASS |
| 6 | Up ulang DB15 | Schema kembali lengkap, data tidak hilang | 7 response tetap ada, tanpa orphan | PASS |
| 7 | Clean database chain | `0001`-`0012` berjalan pada MySQL 8.4 | Seluruh migration exit 0 | PASS |
| 8 | Jumlah tabel clean DB | Struktur konsisten | 67 tabel | PASS |
| 9 | MySQL integration test | Smoke test sama dengan GitHub Actions | `TestMasterDataSmokeWithTestDatabase` PASS, exit 0 | PASS |

Defect direproduksi pada `0010` baris 139: parent `container_types.id` adalah `CHAR(36) utf8mb4_0900_ai_ci`, sedangkan child `fitness_checklist_templates.container_type_id` adalah `CHAR(36) utf8mb4_unicode_ci`. Canonical dump memakai `utf8mb4_0900_ai_ci`; 19 deklarasi migration `0010` dan patch `0015` diselaraskan ke collation tersebut tanpa menghapus FK. Audit runtime seluruh FK string target menunjukkan child dan parent sama-sama `CHAR(36) utf8mb4_0900_ai_ci`.

## 8. Test source dan build

| Perintah | Hasil | Status |
|---|---|---|
| MySQL integration `TestMasterDataSmokeWithTestDatabase` | PASS pada MySQL 8.4.10, exit 0 | PASS |
| `go test ./...` - `services/api` | Seluruh package lulus, exit 0 | PASS |
| `go test ./...` - `services/worker` | Seluruh package lulus, exit 0 | PASS |
| `npm run typecheck --workspace apps/web` | Tidak ada type error | PASS |
| `npm run test:navigation --workspace apps/web` | Struktur canonical dan label terlarang sesuai | PASS |
| `npm run lint --workspace apps/web` | Tidak ada error/warning pada rerun | PASS |
| `npm run build --workspace apps/web` | Build production lulus | PASS |
| `git diff --check` | Tidak ada whitespace error | PASS |

Catatan lingkungan:

- Smoke test pertama di sandbox menghasilkan warning izin cache/telemetry setelah test PASS; rerun di luar sandbox lulus bersih dengan exit 0.
- Production build follow-up dijalankan di luar sandbox untuk menghindari batas proses child Windows dan lulus dengan exit 0.
- Warning lingkungan tidak diperlakukan sebagai kegagalan source; status tabel di atas berasal dari rerun terminal yang bersih.

## 9. Browser UAT dan screenshot

| No. | Viewport | Layar | Assertion | Status |
|---:|---|---|---|---|
| 1 | 1440×1000 | Dashboard Admin | Enam grup canonical; fitur Admin terlarang tidak ada | PASS |
| 2 | 1440×1000 | Customer readiness | Panel kelengkapan tampil | PASS |
| 3 | 1440×1000 | Semua Pekerjaan | Seluruh tab status target tampil | PASS |
| 4 | 1440×1000 | Company Profile | Satu form fisik | PASS |
| 5 | 1440×1000 | Audit Log | Tabel read-only tampil | PASS |
| 6 | 390×844 | Penomoran | Halaman mobile tanpa overflow | PASS |
| 7 | 390×844 | Compatibility assignment | Redirect canonical dan query benar | PASS |

Artefak:

- [01 Dashboard desktop](screenshots/admin-menu-db15-alignment/01-dashboard-desktop.png)
- [02 Customer readiness desktop](screenshots/admin-menu-db15-alignment/02-customers-readiness-desktop.png)
- [03 Tab status pekerjaan desktop](screenshots/admin-menu-db15-alignment/03-jobs-status-tabs-desktop.png)
- [04 Company Profile desktop](screenshots/admin-menu-db15-alignment/04-company-profile-desktop.png)
- [05 Audit Log desktop](screenshots/admin-menu-db15-alignment/05-audit-log-desktop.png)
- [06 Penomoran mobile](screenshots/admin-menu-db15-alignment/06-numbering-mobile.png)
- [07 Redirect assignment mobile](screenshots/admin-menu-db15-alignment/07-compat-assignment-redirect-mobile.png)

PNG memiliki dimensi target dan ukuran file nonzero. Karena viewer gambar lokal tertahan wrapper sandbox, status PASS browser didasarkan pada DOM, navigation, overflow, response aplikasi, dan keberhasilan capture; tidak diklaim sebagai inspeksi pixel-by-pixel manual.

## 10. Blocker dan deferred decision

| Area | Status | Tindak lanjut yang diperlukan |
|---|---|---|
| Upload SPK | BLOCKED | Aktifkan dan buktikan object storage/file flow |
| Upload foto live | NOT_TESTED | Siapkan object storage dan skenario attachment wajib |
| Daftar CEDEX produksi | DECISION_REQUIRED | GIS/Pak Agus memberikan daftar resmi |
| Format Location Code | DECISION_REQUIRED | Konfirmasi aturan face/grid/mapping/size dan validasi format |
| Final PDF/QR/public verification | BLOCKED | Tetap nonaktif sampai keputusan dan dependensi tersedia |
| Auto report queue | DECISION_REQUIRED | Tentukan pemicu, retry, versioning, dan ownership proses |
| Data produksi | BLOCKED | Dump saat ini didominasi UAT; Company Profile dan signer belum lengkap |
| Route Surveyor GIFT `/settings/surveyors` | DECISION_REQUIRED | Route aktual `/master/surveyors` tersedia; perubahan canonical/redirect ditunda agar scope CI tetap sempit |
| CI commit perbaikan `9dba3bc` | PASS | Workflow `Validate` run `30087909560`: MySQL, Go, Web, dan whitespace seluruhnya hijau |
| Deployment production | NOT_TESTED | Tidak dijalankan pada scope ini |
| Visual in-app browser | PARTIAL | Edge CDP lulus; bootstrap in-app browser tertahan runtime sandbox |

Perbaikan dipublikasikan ke `origin/main` sebagai commit `9dba3bc`; workflow `Validate` run `30087909560` selesai PASS untuk seluruh job.
