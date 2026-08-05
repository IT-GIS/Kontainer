# Laporan Finalisasi Survey Sheet dan UAT Real Case

Tanggal verifikasi: 5 Agustus 2026
Branch: `codex/redesign-surveyor-survey-sheet`
Baseline: `fed9215` (`feat: redesign Surveyor survey sheet workspace`)
Commit/push: dilakukan setelah permintaan eksplisit pengguna pada 5 Agustus 2026.

## Hasil implementasi

- Survey Sheet memakai `selection`, `onSelectionChange`, `focusedDamageId`, dan
  `focusRequestKey`; ketergantungan `initialSelection`/remount `key` dihapus.
- Klik marker, baris, dan Edit memakai jalur fokus yang sama. Request key selalu
  bertambah sehingga klik berulang tetap melakukan refocus.
- Snapshot mengaktifkan face, menyorot rentang section, memusatkan scroll, dan
  menandai marker/baris aktif. Temuan legacy membuka form dengan peringatan tanpa
  marker atau area fiktif.
- Area selected, mapped, unmapped, marker aktif, dan row aktif memiliki state
  visual serta teks legenda. Row aktif memakai `aria-current`.
- Di bawah 960 px panel Temuan menjadi dialog dengan `role="dialog"`,
  `aria-modal`, judul terhubung, focus trap, Escape, body scroll lock, dan focus
  return. Desktop tetap nonmodal.
- Header/action form tetap di luar body scroll. Layout memakai `100dvh`,
  safe-area empat sisi, overflow guard, dan overscroll containment.
- Opsi kategori foto membawa `applies_to`: umum hanya `inspection`, Temuan hanya
  `finding`; scope lain tidak dipaksakan.
- API melakukan validasi kategori sebelum object upload dan mengulanginya dalam
  transaksi metadata. Mismatch menghasilkan `PHOTO_CATEGORY_APPLIES_TO`.
- Endpoint umum memaksa `photo_type=general`/`damage_id=NULL`; endpoint Temuan
  memaksa `photo_type=damage` dan tetap memverifikasi Survey, assignment, role,
  serta status.
- `S3_OBJECT_PREFIX` bersifat opsional dan default kosong. Bootstrap Docker kini
  menyertakan migration 0013–0016.

## Database, API, dan storage nyata

| Bukti | Status | Hasil |
|---|---|---|
| Clone source | PASS | `kontainer_db` → `kontainer_db_uat` dengan dump single-transaction |
| Schema gate | PASS | marker migration 0013–0016 lengkap |
| Pengguna UAT | PASS | 5 user, reviewer=`supervisor`, Customer PIC tanpa role |
| Password | PASS | di-hash dengan `auth.HashPassword`, tidak dicetak |
| Manifest | PASS | `UAT-REAL-CASE-2026-08`, fingerprint `25d8f7…d5c18` |
| API lokal | PASS | API target UAT aktif pada `127.0.0.1:8080` |
| Isolasi roleless | PASS | login Customer PIC berhasil, resource berizin ditolak 403 tanpa body dicetak |
| MinIO | PASS | bucket `gift-survey-uat-real-case` ada dan private |
| Object dataset | SKIPPED | 0 object; upload tidak dijalankan karena Survey/Temuan tidak boleh dibuat |
| Browser UAT | BLOCKED | in-app Browser gagal bootstrap: metadata `sandboxPolicy` hilang |

Database setelah seed aman berisi 5 user bootstrap dan 1 manifest; jumlah Job,
Survey, Temuan, foto, dan revision dataset adalah 0. Ini bukan hasil UAT final.

## Gate master dan status skenario

Sumber `UAT-CUST-17B` unik dan memiliki Survey Type `SV-17B`, kategori foto
`general_container:inspection` dan `damage_finding:finding`, severity, test
parameter, serta template aktif. Namun lookup live membuktikan:

- jumlah Location Code structured aktif: **0**;
- template aktif hanya untuk Container Type `CT-17B` (20 Dry UAT);
- tidak ada template aktif tepat untuk 20GP, 40GP, dan 40HC pada spesifikasi.

| Skenario | Status | Alasan |
|---|---|---|
| CASE-01 draft + unstarted | SKIPPED_MASTER_MISSING | Survey draft tidak dapat diinstansiasi dengan template tepat |
| CASE-02 submitted | SKIPPED_MASTER_MISSING | Checklist/finding membutuhkan template dan mapping structured |
| CASE-03 approved setelah revisi | SKIPPED_MASTER_MISSING | snapshot Temuan dan workflow dasar tidak boleh difabrikasi |
| CASE-04 approved tanpa Temuan | SKIPPED_MASTER_MISSING | template/foto umum final tidak tersedia untuk tipe tepat |
| CASE-05 rejected | SKIPPED_MASTER_MISSING | submit evidence tidak dapat dibuat |
| CASE-06 isolation | PARTIAL PASS | roleless 403 terbukti; cross-Customer Survey ID belum ada |

Status `under_review`, `need_revision`, dan `resubmitted` tidak diklaim karena
audit/history nyata belum dapat dibuat. Observasi 30 × 12 × 0,8 cm tidak
diinsert; nilainya tetap data sintetis, bukan tolerance.

## Test dan closure checks

Hasil yang sudah benar-benar dijalankan:

- `npm run test:survey-sheet`: PASS.
- `npm run typecheck`: PASS.
- `npm run test:iso-cedex`: PASS.
- `npm run test:navigation`: PASS.
- `npm run lint`: PASS.
- `npm run build`: PASS (73 halaman berhasil digenerasikan).
- `go test ./...`: PASS untuk seluruh package API.
- Seed rerun: PASS idempotensi bootstrap/schema/manifest.
- Cleanup `-DryRun`: PASS; scope 0 Job, 5 user, 0 object, prefix dataset tepat.
- Verifier: pemeriksaan duplikasi PASS, container spec FAIL (6 missing), dan
  pemeriksaan domain lain SKIPPED setelah gate master.

`git diff --check`: PASS.

## Browser dan screenshot

Web serta API lokal berhasil berjalan. Pemanggilan pertama in-app Browser gagal
sebelum tab dibuat dengan:

```text
codex/sandbox-state-meta: missing field sandboxPolicy
```

Skill Browser melarang fallback ke browser Playwright mandiri. Karena itu enam
viewport, dialog interaktif, dan screenshot di
`docs/screenshots/uat-real-case/` berstatus `BLOCKED_BROWSER_TOOL`; tidak ada
screenshot palsu yang disimpan.

## Risiko tersisa

Acceptance data UAT dan browser belum lengkap. Admin perlu menyediakan mapping
Location Code structured aktif dan template aktif yang cocok—melalui master
resmi, bukan seed ini. Setelah itu jalankan `BrowserReady`, UAT interaktif,
`Finalize`, verifier, lalu cleanup dry-run dari
[panduan UAT](./UAT_REAL_CASE_GUIDE.md).
