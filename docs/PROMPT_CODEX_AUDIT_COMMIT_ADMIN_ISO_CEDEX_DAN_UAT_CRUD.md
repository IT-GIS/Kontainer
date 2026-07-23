# PROMPT CODEX — AUDIT SCOPE COMMIT ADMIN ISO CEDEX DAN UAT CRUD ADMIN

## Repository

```text
IT-GIS/Kontainer
```

## Baseline Git yang Harus Diaudit

Commit sebelum restrukturisasi:

```text
9ea105f2b43fdf89aa24c9a2257d73e2585c2531
fix: restore master data add actions
```

Commit restrukturisasi Admin terbaru:

```text
af1ec4c3ded3b3ff8b81d3214478e90011b8587e
feat: align admin navigation with ISO CEDEX workflow
```

Commit `af1ec4c3...` mencakup banyak file, bukan hanya navigasi Admin. Karena itu, tahap ini bukan sekadar melihat tampilan, tetapi melakukan audit scope, audit keamanan, audit route, dan UAT fungsi Admin secara nyata.

Jangan commit dan jangan push.

---

# 1. TUJUAN UTAMA

Lakukan audit menyeluruh terhadap perubahan pada commit:

```text
af1ec4c3ded3b3ff8b81d3214478e90011b8587e
```

Tujuan:

1. memastikan restrukturisasi menu Admin sesuai alur Pak Agus;
2. memastikan tidak ada perubahan di luar scope yang merusak sistem;
3. memastikan seluruh route lama tetap aman;
4. memastikan seluruh tab Admin dapat digunakan;
5. memastikan CRUD benar-benar memakai backend/database, bukan state lokal;
6. memastikan data tidak hilang setelah refresh;
7. memastikan Customer, Personel/PIC, Location, ISO CEDEX, dan Referensi Pemeriksaan tidak tercampur;
8. memastikan Surveyor GIFT tetap terpisah dari Personel/PIC Customer;
9. memastikan role Admin, Supervisor, Management, dan Surveyor tetap benar;
10. memastikan tidak ada perubahan backend/database tersembunyi yang ikut terbawa tanpa audit;
11. memastikan menu Surveyor tidak berubah;
12. menghasilkan daftar temuan dan rekomendasi perbaikan;
13. hanya memperbaiki masalah yang terbukti dari audit;
14. tidak menambah fitur baru di luar scope.

---

# 2. SCOPE GUARD

Tahap ini hanya untuk:

- audit commit;
- audit diff;
- audit route;
- audit menu Admin;
- audit UI;
- audit integrasi CRUD existing;
- audit permission;
- audit role;
- audit Customer scope;
- audit active state;
- audit responsive;
- audit accessibility;
- perbaikan bug yang ditemukan dari audit;
- dokumentasi hasil.

Jangan membuat:

- fitur Surveyor baru;
- Survey Seat baru;
- generator Location Code baru;
- PDF final;
- QR aktif;
- verifikasi publik;
- finance;
- invoicing;
- accounting;
- workshop;
- work order repair;
- billing;
- inventory;
- stok material;
- vendor;
- VGM;
- penimbangan;
- Type Design;
- laporan enam bulanan.

Gunakan istilah:

```text
Kelaikan
```

Jangan menambah istilah `Kelayakan` pada kode atau UI baru.

---

# 3. AUDIT GIT DAN WORKTREE

Jalankan terlebih dahulu:

```bash
git status
git branch --show-current
git log -5 --oneline
git show --stat af1ec4c3ded3b3ff8b81d3214478e90011b8587e
git diff --stat 9ea105f2b43fdf89aa24c9a2257d73e2585c2531..af1ec4c3ded3b3ff8b81d3214478e90011b8587e
```

Catat:

- branch aktif;
- apakah worktree bersih/kotor;
- tracked modified;
- untracked files;
- staged files;
- file yang berubah setelah commit;
- perubahan lokal yang bukan bagian commit;
- apakah ada perubahan backend/database lokal yang belum di-commit;
- apakah ada file hasil build yang berubah.

Jangan:

- reset;
- stash;
- clean;
- checkout file;
- rebase;
- amend;
- commit;
- push.

Pertahankan seluruh pekerjaan lokal.

---

# 4. AUDIT DIFF BERDASARKAN KELOMPOK

Kelompokkan file commit ke kategori:

## A. Navigasi Admin

Contoh:

```text
apps/web/constants/navigation-admin.ts
```

## B. Canonical Route Baru

Contoh:

```text
apps/web/app/master/iso-cedex/page.tsx
apps/web/app/master/inspection-references/page.tsx
apps/web/app/master/customers/customer/[customerId]/page.tsx
```

## C. Route Compatibility

Contoh:

```text
apps/web/app/master/cedex/*
apps/web/app/master/locations/page.tsx
apps/web/app/master/container-types/page.tsx
apps/web/app/master/survey-types/page.tsx
apps/web/app/master/responsibility-codes/page.tsx
apps/web/app/jobs/import/page.tsx
apps/web/app/jobs/assign/page.tsx
apps/web/app/surveys/monitoring/*
apps/web/app/reports/qr-validation/page.tsx
apps/web/app/settings/roles/page.tsx
```

## D. Pekerjaan Inspeksi

Contoh:

```text
apps/web/app/jobs/page.tsx
apps/web/app/jobs/create/page.tsx
apps/web/app/jobs/[id]/page.tsx
apps/web/components/jobs/*
apps/web/lib/inspection-work.ts
apps/web/types/inspection-work.ts
apps/web/types/job-detail-workspace.ts
```

## E. Master Data dan CRUD

Contoh:

```text
apps/web/components/master/*
apps/web/constants/master-data.ts
apps/web/constants/fitness-master-data-client-first.ts
```

## F. Checklist

Contoh:

```text
apps/web/app/fitness/master-data/checklist-templates/*
apps/web/components/master/checklist-reference-tab.tsx
```

## G. Laporan dan Review

Contoh:

```text
apps/web/app/reports/*
apps/web/components/reports/*
apps/web/app/review/*
```

## H. CSS dan UI Component

Contoh:

```text
apps/web/app/globals.css
apps/web/components/ui/data-table.tsx
apps/web/components/ui/workspace-tabs.tsx
```

## I. Dokumentasi dan Screenshot

Contoh:

```text
docs/ADMIN_INFORMATION_ARCHITECTURE_PAK_AGUS_ALIGNMENT.md
docs/OLD_TO_NEW_ADMIN_MENU_MAPPING.md
docs/screenshots/admin-iso-pak-agus/*
```

Untuk setiap kategori, laporkan:

- file;
- tujuan perubahan;
- apakah sesuai scope;
- apakah berasal dari pekerjaan lama;
- risiko;
- dependency;
- route terdampak;
- permission terdampak;
- rekomendasi.

---

# 5. DETEKSI PERUBAHAN DI LUAR SCOPE

Cari perubahan yang bukan sekadar restrukturisasi menu Admin.

Periksa khusus:

- Create Job;
- detail Job;
- daftar Pekerjaan Inspeksi;
- Checklist Template;
- Checklist Item;
- laporan;
- review;
- customer-scoped data;
- CSS besar;
- type baru;
- lib baru;
- route baru.

Untuk setiap perubahan di luar scope, klasifikasikan:

```text
A. Aman dan dibutuhkan
B. Aman tetapi bukan bagian prompt
C. Berisiko dan perlu UAT
D. Harus dipisahkan pada commit berikutnya
E. Harus diperbaiki
```

Jangan menghapus perubahan hanya karena di luar scope.

Hanya perbaiki bila terbukti menyebabkan:

- bug;
- konflik route;
- permission bocor;
- data salah;
- broken UI;
- broken build;
- broken runtime;
- Customer scope bocor;
- menu Surveyor berubah;
- route 404;
- active state ganda.

---

# 6. AUDIT MENU ADMIN

Pastikan sidebar Admin berisi:

```text
Dashboard

Pekerjaan Inspeksi
├── Semua Pekerjaan
└── Buat Job/SPK

Master Data
├── Customer
├── Referensi Pemeriksaan
└── ISO CEDEX

Review & Keputusan
├── Menunggu Review
└── Riwayat Keputusan

Dokumen & Laporan
├── Laporan Pemeriksaan
└── Arsip Laporan

Pengaturan
├── Surveyor GIFT
├── Company Profile
├── Penomoran
├── User & Hak Akses
└── Audit Log
```

Audit:

- urutan menu;
- icon;
- label;
- route;
- active state;
- permission;
- role;
- sidebar expanded;
- sidebar collapsed;
- mobile drawer;
- route lama;
- browser back/forward;
- query tab;
- duplicate active menu.

Pastikan:

- `QR Validation` tidak tampil;
- `Import Container` tidak tampil sebagai submenu;
- `Assign Surveyor` tidak tampil sebagai submenu;
- route lama tetap aman;
- menu Surveyor tidak berubah.

---

# 7. AUDIT ISO CEDEX

Canonical route:

```text
/master/iso-cedex
```

Tab:

```text
Location Code
Component Code
Damage Code
Action Repair Code
Material Code
Responsibility Code
```

Audit setiap tab:

1. tab aktif benar;
2. URL berubah benar;
3. refresh mempertahankan tab;
4. browser back/forward benar;
5. route lama redirect ke tab benar;
6. Customer picker tampil rapi;
7. pilih Customer membuka data benar;
8. tambah data;
9. edit data;
10. status aktif/tidak aktif;
11. duplicate validation;
12. error backend;
13. loading;
14. empty state;
15. refresh browser;
16. data tetap ada;
17. Customer A tidak melihat Customer B;
18. tidak memakai state lokal sebagai source utama;
19. tidak ada teks `Simpan lokal`;
20. Action Repair hanya referensi teknis.

Route lama yang wajib diuji:

```text
/master/cedex/locations
/master/cedex/components
/master/cedex/damages
/master/cedex/repairs
/master/cedex/materials
/master/responsibility-codes
```

Expected mapping:

```text
locations       → tab location
components      → tab component
damages         → tab damage
repairs         → tab action-repair
materials       → tab material
responsibility  → tab responsibility
```

---

# 8. AUDIT CUSTOMER DETAIL

Canonical route:

```text
/master/customers/customer/:customerId
```

Tab:

```text
Profil Customer
Personel/PIC
Location Pemeriksaan
Riwayat Pekerjaan
```

## 8.1 Profil Customer

Audit:

- Customer yang benar;
- kode;
- nama;
- status;
- alamat;
- identitas;
- PIC utama;
- data tidak tertukar;
- error state;
- loading state;
- Customer tidak ditemukan.

## 8.2 Personel/PIC

Endpoint expected:

```text
/customers/:customerId/personnel
```

Audit CRUD:

- create;
- read;
- update;
- inactive;
- duplicate code;
- validation;
- Customer fixed dari route;
- body tidak dapat mengganti Customer;
- refresh data tetap ada;
- data Customer lain tidak muncul.

Pastikan label:

```text
Personel/PIC Customer
```

bukan:

```text
Surveyor Customer
```

## 8.3 Location Pemeriksaan

Endpoint expected:

```text
/customers/:customerId/locations
```

Audit CRUD:

- create;
- read;
- update;
- inactive;
- duplicate;
- validation;
- Customer fixed dari route;
- refresh;
- Customer isolation.

## 8.4 Riwayat Pekerjaan

Audit:

- query hanya Customer tersebut;
- jumlah pekerjaan;
- pekerjaan aktif;
- pemeriksaan selesai;
- terakhir diperiksa;
- link detail Job;
- status;
- Location;
- Survey Type;
- jumlah peti kemas;
- data Customer lain tidak ikut.

---

# 9. AUDIT SURVEYOR GIFT

Route:

```text
/master/surveyors
```

Pastikan sumbernya adalah Surveyor internal GIFT.

Audit:

- terhubung ke user account bila memang existing;
- hanya Surveyor internal;
- tidak berisi PIC Customer;
- tidak berisi Personel Customer;
- digunakan pada Assignment;
- status aktif;
- permission Admin;
- tidak muncul pada Customer Detail.

Uji:

```text
Personel/PIC Customer
≠
Surveyor GIFT
```

Buat bukti screenshot dan catatan endpoint/resource yang digunakan kedua jenis data.

---

# 10. AUDIT REFERENSI PEMERIKSAAN

Canonical route:

```text
/master/inspection-references
```

Tab:

```text
Container Type
Survey Type
Checklist
Test Parameter
Photo Category
Finding Severity
```

Audit masing-masing tab.

## Container Type

- Customer picker;
- Customer scope;
- CRUD;
- ISO Code;
- Size;
- status;
- refresh;
- duplicate;
- route lama `/master/container-types`.

## Survey Type

- Customer picker;
- Customer scope;
- CRUD;
- status;
- refresh;
- route lama `/master/survey-types`.

## Checklist

Audit:

- Customer picker;
- Template Checklist;
- Checklist Item;
- endpoint;
- create template;
- edit template;
- tambah item;
- edit item;
- status;
- urutan;
- Survey Type relation;
- Container Type relation;
- Customer isolation;
- refresh;
- error handling.

Pastikan tidak membuat seed teknis.

## Test Parameter

Audit resource existing:

```text
fitness-test-parameters
```

Pastikan:

- source benar;
- CRUD nyata;
- tidak mengarang nilai ambang;
- tidak mengarang metode uji;
- tidak mengarang referensi standar.

## Photo Category

Audit resource existing:

```text
fitness-photo-categories
```

## Finding Severity

Audit resource existing:

```text
fitness-finding-severities
```

Keputusan akhir Kelaikan tetap bukan otomatis dari Severity.

---

# 11. AUDIT PEKERJAAN INSPEKSI

Menu:

```text
Pekerjaan Inspeksi
├── Semua Pekerjaan
└── Buat Job/SPK
```

## 11.1 Semua Pekerjaan

Route:

```text
/jobs
```

Filter presentation:

```text
Semua
Belum Ditugaskan
Sedang Diperiksa
Menunggu Review
Perlu Revisi
Disetujui
Selesai
```

Audit:

- filter memakai status existing;
- tidak membuat status baru;
- count benar;
- search;
- Customer;
- Location;
- Survey Type;
- Surveyor;
- progress;
- actions;
- pagination;
- error;
- loading;
- empty state;
- mobile.

## 11.2 Create Job

Route:

```text
/jobs/create
```

Audit end-to-end:

```text
Pilih Customer
→ PIC terfilter
→ Location terfilter
→ Survey Type terfilter
→ simpan Job
```

Pastikan:

- Customer berubah mereset dependent field;
- data Customer lain tidak muncul;
- PIC auto-fill bila implemented;
- Location benar;
- Survey Type benar;
- backend ownership validation;
- refresh;
- success;
- validation error;
- network error.

## 11.3 Detail Job

Route:

```text
/jobs/:id
```

Tab:

```text
Ringkasan
Peti Kemas
Penugasan
Progress Pemeriksaan
Hasil Survey
Review
Dokumen
Riwayat
```

Audit:

- tab benar;
- data Job benar;
- Customer benar;
- container benar;
- Assignment benar;
- route lama;
- mobile.

## 11.4 Import Peti Kemas

Route compatibility:

```text
/jobs/import
/jobs/:id/containers/import
```

Pastikan:

- tidak tampil di sidebar;
- tersedia sebagai action detail Job;
- route lama tidak 404;
- import masih bekerja;
- error terlihat;
- data tidak duplikat tidak sah.

## 11.5 Assign Surveyor

Route compatibility:

```text
/jobs/assign
```

Pastikan:

- tidak tampil di sidebar;
- tersedia sebagai action detail Job;
- dropdown hanya Surveyor GIFT;
- Personel/PIC Customer tidak muncul;
- Assignment berhasil;
- Surveyor lain tidak menerima Job.

---

# 12. AUDIT REVIEW DAN MANAGEMENT READ-ONLY

Menu:

```text
Review & Keputusan
├── Menunggu Review
└── Riwayat Keputusan
```

Role yang diuji:

- Admin;
- Supervisor;
- Management.

Expected:

## Admin

- dapat monitoring;
- tidak otomatis mempunyai action keputusan bila permission tidak ada.

## Supervisor/Reviewer

- dapat membuka review;
- Need Revision;
- Reject;
- Approve;
- Final Result;
- Review Note.

## Management

- read-only;
- tidak dapat Approve;
- tidak dapat Reject;
- tidak dapat Need Revision;
- tidak dapat edit;
- request mutation ditolak backend.

Uji tidak hanya UI.

Coba request mutation sebagai Management dan pastikan backend menolak.

---

# 13. AUDIT DOKUMEN & LAPORAN

Menu:

```text
Dokumen & Laporan
├── Laporan Pemeriksaan
└── Arsip Laporan
```

Audit:

- route `/reports`;
- route `/reports?view=archive`;
- route `/reports/:id`;
- route `/reports/versions`;
- route `/reports/qr-validation`.

Pastikan:

- QR Validation tidak tampil di sidebar;
- route lama tidak 404;
- QR tidak aktif;
- verifikasi publik tidak aktif;
- PDF final baru tidak dibuat;
- Report Version tampil sebagai riwayat/tab bila existing;
- data laporan benar;
- permission benar;
- Management read-only.

---

# 14. AUDIT USER & HAK AKSES

Menu:

```text
User & Hak Akses
```

Route:

```text
/settings/users
/settings/roles
```

Audit:

- User tab;
- Role & Permission tab;
- route lama;
- super_admin restriction;
- Admin restriction;
- Supervisor restriction;
- Management restriction;
- active state;
- no duplicate menu.

Jangan mengubah permission backend.

---

# 15. AUDIT MENU SURVEYOR TIDAK BERUBAH

Periksa:

```text
apps/web/constants/navigation-surveyor.ts
```

Expected tetap:

```text
Dashboard Surveyor
Job Saya
Draft Survey
Need Revision
Submitted Survey
Approved Survey
Riwayat Survey
```

Pastikan commit tidak mengubah file tersebut.

Uji login Surveyor:

- menu sama;
- route sama;
- Job Saya tetap dapat dibuka;
- tidak melihat menu Admin;
- tidak melihat Customer Master;
- tidak melihat ISO CEDEX Admin;
- tidak melihat User & Hak Akses.

---

# 16. AUDIT CUSTOMER SCOPE DAN KEAMANAN

Buat dua Customer UAT:

```text
Customer A
Customer B
```

Uji:

```text
Customer A → Location A
Customer B → Location B
```

```text
Customer A → Component Code CMP-01
Customer B → Component Code CMP-01
```

Expected:

- code sama boleh bila backend existing memang customer-scoped;
- duplicate dalam Customer yang sama ditolak;
- Customer A tidak melihat data B;
- URL tampering ditolak;
- body tampering ditolak;
- edit record B dari route A ditolak;
- inactive record tidak muncul pada pilihan operasional baru.

Jangan mengubah model ownership CEDEX pada tahap ini.

---

# 17. AUDIT DATA PERSISTENCE

Untuk setiap CRUD:

1. create;
2. lihat list;
3. refresh;
4. tutup browser;
5. buka kembali;
6. data tetap ada;
7. edit;
8. refresh;
9. perubahan tetap ada;
10. inactive;
11. refresh;
12. status tetap ada.

Periksa browser network:

- method;
- endpoint;
- status code;
- request body;
- response;
- error.

Pastikan tidak ada:

```text
Simpan lokal
State lokal
Mock save
React-only persistence
```

pada halaman operasional yang dinyatakan selesai.

---

# 18. AUDIT ROUTE COMPATIBILITY

Uji seluruh route:

```text
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
/master/iso-cedex
/master/inspection-references
/master/customers
/master/customers/customer/:customerId
/jobs
/jobs/create
/jobs/import
/jobs/assign
/jobs/:id
/surveys/monitoring
/surveys/monitoring/in-progress
/surveys/monitoring/submitted
/surveys/monitoring/need-revision
/surveys/monitoring/approved
/review/pending
/review/history
/reports
/reports/versions
/reports/qr-validation
/settings/company-profile
/settings/numbering
/settings/audit-log
/settings/users
/settings/roles
```

Pastikan:

- tidak 404;
- tidak blank;
- redirect benar;
- tab benar;
- query benar;
- active state benar;
- permission benar;
- browser back/forward benar.

---

# 19. AUDIT RESPONSIVE

Uji viewport:

```text
1440 × 900
1280 × 720
1024 × 768
768 × 1024
390 × 844
```

Uji:

- sidebar expanded;
- sidebar collapsed;
- Customer picker;
- ISO CEDEX;
- Referensi Pemeriksaan;
- Customer Detail;
- Pekerjaan Inspeksi;
- Detail Job;
- Laporan;
- User & Hak Akses.

Pastikan:

- tidak ada body overflow horizontal;
- tab dapat scroll;
- button tidak terpotong;
- tabel responsive;
- text wrap;
- form usable;
- modal usable;
- action accessible.

---

# 20. AUDIT ACCESSIBILITY

Periksa:

- heading hierarchy;
- label form;
- aria-label;
- focus visible;
- keyboard navigation;
- tab role;
- tabpanel;
- button name;
- link name;
- status bukan hanya warna;
- error terhubung field;
- zoom 200%;
- screen-reader text;
- contrast.

---

# 21. VALIDASI TEKNIS

Jalankan:

```bash
npm run typecheck --workspace apps/web
npm run build --workspace apps/web
git diff --check
```

Jalankan backend test existing bila tersedia:

```bash
npm test
```

atau command sesuai package repository.

Periksa:

- console error;
- hydration error;
- runtime exception;
- duplicate React key;
- failed fetch;
- unauthorized request;
- route error;
- build route count;
- generated file churn.

Pulihkan file build-generated yang berubah otomatis hanya bila benar-benar generated dan sudah diverifikasi, tanpa menghapus pekerjaan pengguna.

---

# 22. CI DAN STATUS GITHUB

Periksa apakah commit mempunyai CI.

Bila tidak ada:

```text
Belum ada verifikasi CI GitHub.
```

Jangan menulis:

```text
CI lulus
```

bila status tidak tersedia.

Pisahkan:

- test lokal;
- browser UAT lokal;
- CI GitHub.

---

# 23. PERBAIKAN BUG

Perbaiki hanya bug yang terbukti dari audit.

Untuk setiap bug:

1. tulis gejala;
2. tulis route;
3. tulis role;
4. tulis akar masalah;
5. tulis file;
6. buat perubahan minimal;
7. test ulang;
8. dokumentasikan.

Jangan melakukan refactor besar tanpa kebutuhan.

Jangan mengubah backend/database kecuali bug memang berasal dari integrasi existing dan perubahan sudah ada dalam scope pengguna. Bila perlu perubahan backend/database baru, berhenti dan laporkan sebagai rekomendasi, jangan langsung implementasi.

---

# 24. DOKUMENTASI HASIL

Buat:

```text
docs/ADMIN_ISO_CEDEX_COMMIT_SCOPE_AUDIT.md
```

Isi:

1. baseline;
2. branch;
3. worktree;
4. commit scope;
5. file per kategori;
6. perubahan di luar scope;
7. risiko;
8. menu Admin;
9. ISO CEDEX;
10. Customer Detail;
11. Personel/PIC;
12. Surveyor GIFT;
13. Referensi Pemeriksaan;
14. Checklist;
15. Pekerjaan Inspeksi;
16. Review;
17. Management read-only;
18. Dokumen & Laporan;
19. User & Hak Akses;
20. menu Surveyor;
21. Customer isolation;
22. persistence;
23. route compatibility;
24. responsive;
25. accessibility;
26. test;
27. CI;
28. bug diperbaiki;
29. bug belum diperbaiki;
30. rekomendasi tahap berikutnya.

Buat juga:

```text
docs/ADMIN_ISO_CEDEX_UAT_MATRIX.md
```

Kolom:

```text
No
Modul
Route
Role
Skenario
Expected
Actual
Status
Evidence
Issue
```

---

# 25. SCREENSHOT WAJIB

Ambil screenshot:

1. sidebar Admin;
2. ISO CEDEX Location;
3. ISO CEDEX Component;
4. ISO CEDEX Action Repair;
5. Referensi Pemeriksaan;
6. Checklist;
7. Detail Customer Profil;
8. Detail Customer Personel/PIC;
9. Detail Customer Location;
10. Riwayat Pekerjaan;
11. Pekerjaan Inspeksi;
12. Create Job;
13. Detail Job;
14. Assign Surveyor;
15. Review sebagai Supervisor;
16. Review sebagai Management read-only;
17. Dokumen & Laporan;
18. User & Hak Akses;
19. mobile;
20. menu Surveyor unchanged.

---

# 26. ACCEPTANCE CRITERIA

Audit diterima bila:

1. commit scope terdokumentasi;
2. perubahan di luar scope teridentifikasi;
3. sidebar Admin benar;
4. ISO CEDEX mempunyai enam tab;
5. Action Repair label benar;
6. seluruh tab dapat dibuka;
7. route lama aman;
8. Customer Detail benar;
9. Personel/PIC customer-scoped;
10. Surveyor GIFT internal;
11. kedua jenis personel tidak tercampur;
12. Referensi Pemeriksaan benar;
13. Checklist dapat diuji nyata;
14. Create Job tetap bekerja;
15. Detail Job tetap bekerja;
16. Import tetap bekerja;
17. Assignment hanya Surveyor GIFT;
18. Review permission benar;
19. Management benar-benar read-only;
20. QR tidak aktif;
21. menu Surveyor tidak berubah;
22. Customer isolation lulus;
23. data persistence lulus;
24. responsive lulus;
25. accessibility lulus;
26. typecheck lulus;
27. build lulus;
28. backend test existing lulus bila tersedia;
29. `git diff --check` bersih;
30. tidak ada bug runtime;
31. hasil lokal dibedakan dari CI;
32. tidak ada commit;
33. tidak ada push.

---

# 27. OUTPUT AKHIR CODEX

Laporkan:

1. baseline commit;
2. current commit;
3. branch;
4. status worktree;
5. daftar file commit;
6. perubahan per kategori;
7. perubahan di luar scope;
8. risiko;
9. menu Admin;
10. ISO CEDEX;
11. Customer Detail;
12. Personel/PIC;
13. Surveyor GIFT;
14. Referensi Pemeriksaan;
15. Checklist;
16. Pekerjaan Inspeksi;
17. Create Job;
18. Detail Job;
19. Import;
20. Assignment;
21. Review;
22. Management read-only;
23. Dokumen & Laporan;
24. User & Hak Akses;
25. menu Surveyor;
26. route compatibility;
27. Customer isolation;
28. persistence;
29. responsive;
30. accessibility;
31. hasil typecheck;
32. hasil build;
33. hasil backend test;
34. hasil browser UAT;
35. status CI;
36. screenshot;
37. bug diperbaiki;
38. bug belum diperbaiki;
39. rekomendasi tahap berikutnya.

Berhenti setelah audit, UAT, dan perbaikan bug yang terbukti selesai.

Jangan commit.
Jangan push.
Jangan reset.
Jangan stash.
Jangan clean.
