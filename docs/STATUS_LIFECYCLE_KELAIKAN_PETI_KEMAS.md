# Status Lifecycle Kelaikan Peti Kemas

## Status Permohonan

```text
draft
submitted
assigned
inspection_in_progress
under_review
need_repair
repair_in_progress
ready_for_reinspection
reinspection_in_progress
approved_fit
approved_unfit
suspended
released
certificate_issued
cancelled
```

## Definisi Status

| Status | Makna |
|---|---|
| draft | Permohonan dibuat tetapi belum lengkap. |
| submitted | Permohonan siap diproses. |
| assigned | Surveyor/pemeriksa sudah ditugaskan. |
| inspection_in_progress | Pemeriksaan/pengujian sedang berjalan. |
| under_review | Hasil sudah dikirim dan menunggu review. |
| need_repair | Ada kerusakan/ketidaksesuaian yang harus diperbaiki. |
| repair_in_progress | Pemilik/client sedang melakukan perbaikan. |
| ready_for_reinspection | Pemilik/client menyatakan perbaikan selesai dan siap diperiksa ulang. |
| reinspection_in_progress | Surveyor melakukan pemeriksaan ulang. |
| approved_fit | Memenuhi persyaratan kelaikan. |
| approved_unfit | Tidak memenuhi persyaratan kelaikan. |
| suspended | Dilarang/dihentikan sementara penggunaannya. |
| released | Dibebaskan setelah diperbaiki dan memenuhi kelaikan. |
| certificate_issued | Dokumen persetujuan/sertifikat sudah diterbitkan. |
| cancelled | Permohonan dibatalkan. |

## Status Temuan Kerusakan

```text
open
repair_required
repair_in_progress
repaired_pending_check
still_defective
closed
```

## Status Perbaikan

```text
not_required
required
in_progress
completed_by_owner
ready_for_reinspection
accepted
rejected_still_defective
```

## Transisi Status Utama

```text
draft â†’ submitted â†’ assigned â†’ inspection_in_progress â†’ under_review
```

Jika hasil memenuhi:

```text
under_review â†’ approved_fit â†’ certificate_issued
```

Jika hasil perlu perbaikan:

```text
under_review â†’ need_repair â†’ repair_in_progress â†’ ready_for_reinspection â†’ reinspection_in_progress â†’ under_review
```

Jika setelah re-inspection memenuhi:

```text
under_review â†’ released â†’ certificate_issued
```

Jika tidak memenuhi:

```text
under_review â†’ approved_unfit
```

Jika ada larangan penggunaan:

```text
under_review â†’ suspended
suspended â†’ repair_in_progress â†’ ready_for_reinspection â†’ released
```

## Catatan Implementasi

- Jangan gunakan `rejected` secara umum tanpa konteks. Untuk workflow kelaikan peti kemas, lebih jelas memakai `approved_unfit`, `need_repair`, atau `suspended`.
- Status `released` dipakai untuk kasus peti kemas yang telah diperbaiki dan memenuhi persyaratan kelaikan.
- Status `certificate_issued` hanya setelah dokumen final diterbitkan.
