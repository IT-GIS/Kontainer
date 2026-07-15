# Master Data Field Verification

Tanggal verifikasi: 15 Juli 2026
Baseline: `8dba26aca6d60b74179cadab5d1d90e95317da8c`

## Metode

Field legacy diverifikasi dengan membaca konfigurasi frontend global, resource API, dan schema/dump repository. Sumber tersebut hanya dibaca dan tidak diubah. Implementasi final tetap frontend-only pada type, mock, service, komponen, route, dan style Master Data.

Status:

- **Terverifikasi**: nama dan bentuk field ditemukan pada sumber repository.
- **Mapping frontend**: bentuk camelCase frontend memetakan field legacy tanpa menambah aturan bisnis.
- **Frontend-only**: field berasal dari kebutuhan UI Customer dan tidak mengubah kontrak backend.

## Matriks field

| Kategori | Field repository/legacy | Field UI dan frontend | Sumber file | Status |
| --- | --- | --- | --- | --- |
| Customer | `code`, `name`, identitas, alamat, PIC, email, telepon, status | Kode Customer, Nama Perusahaan/Organisasi, Nama Singkat, identitas, alamat, PIC Utama, jabatan, email, telepon, Status, Catatan Admin | `apps/web/types/fitness-admin.ts`; `apps/web/mocks/fitness-client-master-data.ts` | Frontend-only; sumber Customer existing |
| Location | `code`, `name`, `type`, alamat, kota, provinsi, kode pos, PIC, telepon, email, catatan akses, status | `code`, `name`, `type`, `address`, `city`, `province`, `postalCode`, `contactName`, `phone`, `email`, `accessNotes`, `status`; Customer read-only dan metadata `clientId` | `apps/web/types/fitness-admin.ts`; `apps/web/components/fitness/client-master-data/client-master-workspace.tsx` | Frontend-only; isolasi route terverifikasi |
| Surveyor Customer | kode, nama, jabatan, lokasi Customer, email, telepon, status | `code`, `name`, `title`, `locationIds`, `locationNames`, `email`, `phone`, `status` | `apps/web/types/fitness-admin.ts`; `apps/web/components/fitness/client-master-data/client-master-workspace.tsx` | Frontend-only; terpisah dari Surveyor GIFT |
| Container Type Customer | kode, nama, ukuran, deskripsi, status | `code`, `name`, `size`, `description`, `status` | `apps/web/types/fitness-admin.ts`; `apps/web/components/fitness/client-master-data/client-master-workspace.tsx` | Frontend-only; bukan peti kemas individual |
| Survey Type | `code`, `name`, `description`, `requires_eir`, `requires_light_test`, `requires_cargo_worthy_result`, `status` | Kode, Nama Survey Type, Deskripsi, `requiresEir`, `requiresLightTest`, `requiresCargoWorthyResult`, Status | `apps/web/constants/master-data.ts`; `services/api/internal/masterdata/resources.go`; `database/kontainer_db.sql` | Terverifikasi; mapping snake_case ke camelCase |
| CEDEX Location | `code`, `face`, `grid_code`, `cedex_mapping_code`, `container_size`, `description`, `display_order`, `status` | Kode CEDEX Location, Face, `gridCode`, `cedexMappingCode`, `containerSize`, Deskripsi, `displayOrder`, Status | `apps/web/constants/master-data.ts`; `services/api/internal/masterdata/resources.go`; `database/kontainer_db.sql` | Terverifikasi; mapping snake_case ke camelCase |
| CEDEX Component | `code`, `component_name`, `description`, `status` | Kode CEDEX Component, `name` dengan label Nama Component, Deskripsi, Status | sumber legacy yang sama di atas | Terverifikasi; `component_name` dipresentasikan sebagai `name` |
| CEDEX Damage | `code`, `damage_name`, `description`, `status` | Kode CEDEX Damage, `name` dengan label Nama Damage, Deskripsi, Status | sumber legacy yang sama di atas | Terverifikasi; tanpa severity atau decision |
| CEDEX Repair | `code`, `repair_name`, `description`, `status` | Kode CEDEX Repair, `name` dengan label Nama Repair, Deskripsi, Status | sumber legacy yang sama di atas | Terverifikasi; tanpa workshop atau operasional perbaikan |
| CEDEX Material | `code`, `material_name`, `description`, `status` | Kode CEDEX Material, `name` dengan label Nama Material, Deskripsi, Status | sumber legacy yang sama di atas | Terverifikasi; tanpa inventori |
| Responsibility Code | `code`, `name`, `description`, `status` | Responsibility Code, `name` dengan label Nama/Label Responsibility, Deskripsi, Status | `apps/web/constants/master-data.ts`; `services/api/internal/masterdata/resources.go`; `database/kontainer_db.sql` | Terverifikasi; tanpa aturan hukum, biaya, atau keputusan |

## Mapping dan batas implementasi

- Semua record turunan memuat `clientId` frontend yang dikunci dari route.
- `requires_eir` → `requiresEir`, `requires_light_test` → `requiresLightTest`, dan `requires_cargo_worthy_result` → `requiresCargoWorthyResult`.
- `grid_code` → `gridCode`, `cedex_mapping_code` → `cedexMappingCode`, `container_size` → `containerSize`, dan `display_order` → `displayOrder`.
- `component_name`, `damage_name`, `repair_name`, serta `material_name` memakai property frontend `name` pada union kategori bernama; label UI tetap spesifik per kategori.
- Kelengkapan overview adalah presence-based: **Lengkap** bila kategori mempunyai minimal satu record dan **Belum Lengkap** bila kosong. Nilai ini bukan keputusan bisnis.

## Batas role

Admin mengelola Master Data. Supervisor/Reviewer mengambil keputusan pada tahap berikutnya. Management read-only. Admin boleh melihat Review untuk monitoring, tetapi final correction ini tidak memberi Admin aksi keputusan teknis.
