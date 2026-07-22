# Old to New Admin Menu Mapping

| Menu Lama | Route Lama | Menu Baru | Tab Baru | Canonical Route | Compatibility | Permission | Status |
|---|---|---|---|---|---|---|---|
| Dashboard Admin | `/dashboard` | Dashboard | - | `/dashboard` | Render existing | `dashboard.view.all` | Aktif |
| Job List | `/jobs` | Pekerjaan Inspeksi > Semua Pekerjaan | Semua | `/jobs` | Render canonical | `jobs.view.all` | Aktif |
| Create Job | `/jobs/create` | Pekerjaan Inspeksi > Buat Job/SPK | - | `/jobs/create` | Render existing | `jobs.create.all` | Aktif |
| Import Container | `/jobs/import` | Action detail Job | Peti Kemas | `/jobs/{id}?tab=peti-kemas` | Redirect ke daftar dengan notice | Existing jobs | Aktif |
| Assign Surveyor | `/jobs/assign` | Action detail Job | Penugasan | `/jobs/{id}?tab=penugasan` | Redirect ke daftar dengan notice | Existing jobs | Aktif |
| All Survey | `/surveys/monitoring` | Pekerjaan Inspeksi | Sedang Diperiksa | `/jobs?view=in-progress` | Redirect | Existing jobs/surveys | Aktif |
| In Progress | `/surveys/monitoring/in-progress` | Pekerjaan Inspeksi | Sedang Diperiksa | `/jobs?view=in-progress` | Redirect | Existing jobs/surveys | Aktif |
| Submitted | `/surveys/monitoring/submitted` | Pekerjaan Inspeksi | Menunggu Review | `/jobs?view=pending-review` | Redirect | Existing jobs/surveys | Aktif |
| Need Revision | `/surveys/monitoring/need-revision` | Pekerjaan Inspeksi | Perlu Revisi | `/jobs?view=need-revision` | Redirect | Existing jobs/surveys | Aktif |
| Approved | `/surveys/monitoring/approved` | Pekerjaan Inspeksi | Disetujui | `/jobs?view=approved` | Redirect | Existing jobs/surveys | Aktif |
| Customer | `/master/customers` | Master Data > Customer | Profil Customer | `/master/customers` | Render canonical | `customers.view.all` | Aktif |
| Location | `/master/locations` | Master Data > Customer | Location Pemeriksaan | `/master/customers?tab=location` | Redirect, lalu pilih Customer | `locations.view.all` | Aktif |
| Surveyor Customer | legacy customer-scoped | Master Data > Customer | Personel/PIC | `/master/customers/customer/{id}?tab=personnel` | Detail legacy redirect | Existing customer/personnel | Aktif |
| Container Type | `/master/container-types` | Master Data > Referensi Pemeriksaan | Container Type | `/master/inspection-references?tab=container-type` | Redirect | `container_types.view.all` | Aktif |
| Survey Type | `/master/survey-types` | Master Data > Referensi Pemeriksaan | Survey Type | `/master/inspection-references?tab=survey-type` | Redirect | `survey_types.view.all` | Aktif |
| Template Checklist | `/fitness/master-data/checklist-templates` | Master Data > Referensi Pemeriksaan | Checklist | `/master/inspection-references?tab=checklist` | Route lama tetap render | Existing checklist | Aktif |
| Test Parameter | existing fitness master | Master Data > Referensi Pemeriksaan | Test Parameter | `/master/inspection-references?tab=test-parameter` | Resource existing | Existing test parameter | Aktif |
| Photo Category | existing fitness master | Master Data > Referensi Pemeriksaan | Photo Category | `/master/inspection-references?tab=photo-category` | Resource existing | Existing photo category | Aktif |
| Finding Severity | existing fitness master | Master Data > Referensi Pemeriksaan | Finding Severity | `/master/inspection-references?tab=finding-severity` | Resource existing | Existing finding severity | Aktif |
| CEDEX Location | `/master/cedex/locations` | Master Data > ISO CEDEX | Location Code | `/master/iso-cedex?tab=location` | Redirect | `cedex_locations.view.all` | Aktif |
| CEDEX Component | `/master/cedex/components` | Master Data > ISO CEDEX | Component Code | `/master/iso-cedex?tab=component` | Redirect | `cedex_components.view.all` | Aktif |
| CEDEX Damage | `/master/cedex/damages` | Master Data > ISO CEDEX | Damage Code | `/master/iso-cedex?tab=damage` | Redirect | `cedex_damages.view.all` | Aktif |
| CEDEX Repair | `/master/cedex/repairs` | Master Data > ISO CEDEX | Action Repair Code | `/master/iso-cedex?tab=action-repair` | Redirect | `cedex_repairs.view.all` | Aktif |
| CEDEX Material | `/master/cedex/materials` | Master Data > ISO CEDEX | Material Code | `/master/iso-cedex?tab=material` | Redirect | `cedex_materials.view.all` | Aktif |
| Responsibility Code | `/master/responsibility-codes` | Master Data > ISO CEDEX | Responsibility Code | `/master/iso-cedex?tab=responsibility` | Redirect | `responsibility_codes.view.all` | Aktif |
| Pending Review | `/review/pending` | Review & Keputusan > Menunggu Review | - | `/review/pending` | Render existing | Existing reviews | Aktif |
| Review History | `/review/history` | Review & Keputusan > Riwayat Keputusan | - | `/review/history` | Render existing | Existing reviews | Aktif |
| Report | `/reports` | Dokumen & Laporan > Laporan Pemeriksaan | Laporan Pemeriksaan | `/reports` | Render canonical | `reports.view.all` | Aktif |
| Report Version | `/reports/versions` | Dokumen & Laporan > Arsip Laporan | Riwayat pada detail | `/reports?view=archive` | Redirect | Existing reports/version | Aktif |
| QR Validation | `/reports/qr-validation` | Tidak tampil di sidebar | - | - | Notice fitur belum aktif | Existing reports | Aman |
| Surveyor internal | `/master/surveyors` | Pengaturan > Surveyor GIFT | - | `/master/surveyors` | Render source internal existing | `surveyors.view.all` | Aktif |
| Company Profile | `/settings/company-profile` | Pengaturan > Company Profile | - | sama | Render existing | Existing company profile | Aktif |
| Numbering Setting | `/settings/numbering` | Pengaturan > Penomoran | - | sama | Render existing | Existing numbering | Aktif |
| User Management | `/settings/users` | Pengaturan > User & Hak Akses | User | `/settings/users` | Render canonical | `users.view.all` | Aktif |
| Role & Permission | `/settings/roles` | Pengaturan > User & Hak Akses | Role & Permission | `/settings/users#role-permission` | Redirect | Existing roles | Aktif |
| Audit Log | `/settings/audit-log` | Pengaturan > Audit Log | - | sama | Render existing | `audit.view.all` | Aktif |

## Catatan

- Compatibility tidak mengubah API, permission backend, database, migration, SQL, seed, atau ownership data.
- Route legacy detail customer-scoped membawa `customerId` ke canonical tab.
- QR, PDF final, dan verifikasi publik tidak diaktifkan.
- Menu dan route Surveyor workspace tidak diubah pada tahap ini.
