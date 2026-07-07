# Migration Plan ke Sistem Kelaikan Peti Kemas

## Tujuan

Mengubah aplikasi dari `Container Survey Management System` menjadi `Sistem Kelaikan Peti Kemas` secara aman dan bertahap.

## Prinsip Migrasi

1. Jangan langsung hapus tabel lama pada tahap awal.
2. Tambahkan tabel baru terlebih dahulu.
3. Ubah menu dan label agar user tidak salah scope.
4. Pindahkan proses bisnis dari survey umum ke kelaikan.
5. Hapus/deprecate modul di luar scope setelah alur baru stabil.

## Tahap 0 - Dokumentasi Scope

Buat/update file:

```text
README.md
docs/SCOPE_KELAIKAN_PETI_KEMAS.md
docs/MENU_KELAIKAN_PETI_KEMAS.md
docs/DATABASE_REDESIGN_CONTAINER_FITNESS.md
docs/WORKFLOW_KELAIKAN_PETI_KEMAS.md
docs/CERTIFICATE_FIELDS_KELAIKAN_PETI_KEMAS.md
docs/STATUS_LIFECYCLE_KELAIKAN_PETI_KEMAS.md
docs/FORM_REQUIREMENTS_KELAIKAN_PETI_KEMAS.md
```

## Tahap 1 - Menu dan Label

Perubahan:

- Ganti brand aplikasi menjadi Sistem Kelaikan Peti Kemas.
- Hide menu CEDEX Repair.
- Hide Responsibility Code.
- Hide Survey Type.
- Hide Finance jika belum prioritas.
- Rename Customer menjadi Pemilik Peti Kemas.
- Rename Job Order menjadi Permohonan Kelaikan.
- Rename Report menjadi Dokumen Kelaikan.

Output:

- Menu Admin sesuai `MENU_KELAIKAN_PETI_KEMAS.md`.

## Tahap 2 - Database Baru

Tambahkan tabel baru:

```text
container_owners
container_manufacturers
fitness_applications
application_containers
inspection_assignments
inspection_assignment_containers
container_inspections
inspection_checklist_responses
structural_findings
finding_photos
repair_followups
reinspection_records
fitness_approvals
approval_documents
csc_plate_records
structural_components
structural_damage_criteria
test_parameters
```

Jangan hapus tabel lama dulu.

## Tahap 3 - Form Admin

Implement:

- Form Permohonan Kelaikan.
- Form Data Peti Kemas sesuai field sertifikat.
- Import Data Peti Kemas.
- Assign Surveyor.
- Monitoring status kelaikan.

## Tahap 4 - Pemeriksaan Surveyor

Implement:

- General Info.
- Checklist Kelaikan.
- Pengujian Beban.
- Temuan Struktur.
- Foto Evidence.
- Submit hasil.

## Tahap 5 - Review dan Status Perbaikan

Implement:

- Review hasil pemeriksaan.
- Need Repair.
- Repair Follow Up.
- Ready for Re-Inspection.
- Re-Inspection.
- Approve Fit.
- Approve Unfit.
- Release After Repair.

## Tahap 6 - Dokumen Kelaikan Peti Kemas

Generate:

- Surat Persetujuan Kelaikan Baru Type Design.
- Surat Persetujuan Kelaikan Baru Individual.
- Surat Persetujuan Peti Kemas Lama.
- Surat Pembebasan Setelah Perbaikan.
- QR Validation.

## Tahap 7 - Cleanup

Setelah alur baru stabil:

- Hapus dependency survey_type.
- Hapus CEDEX Repair dari menu dan schema jika tidak dipakai.
- Hapus responsibility_codes dari alur kelaikan.
- Hapus VGM-related route jika ada.
- Update README final.
- Update `database/kontainer_db.sql` sebagai schema canonical.

## Test Wajib

```powershell
go test ./...
npm run typecheck --workspace apps/web
npm run build --workspace apps/web
git diff --check
```

## Risiko

- Banyak route lama akan berubah label dan konteks.
- Data lama perlu mapping jika sudah ada data real.
- Dokumen approval harus diverifikasi manual dengan contoh Permenhub 25/2022.
- Status repair dan re-inspection harus diuji dengan data peti kemas lama.
