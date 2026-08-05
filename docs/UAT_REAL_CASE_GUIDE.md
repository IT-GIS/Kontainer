# Panduan UAT Real Case Survey Sheet

Dataset ini khusus lokal dan selalu memakai label `UAT-REAL-CASE-2026-08`.
Target database default adalah `kontainer_db_uat`, bucket
`gift-survey-uat-real-case`, dan object prefix
`uat/UAT-REAL-CASE-2026-08`.

## Prasyarat

- MySQL 8 lokal memiliki database sumber `kontainer_db`.
- Target harus berakhiran `_uat`; script menolak nama lain.
- Go dan executable MySQL Laragon tersedia.
- API, Redis, dan MinIO diperlukan untuk pembuktian HTTP/object storage.
- Customer sumber master default `UAT-CUST-17B` harus unik dan aktif.

Password lokal dari spesifikasi diproses memakai `auth.HashPassword`. Script dan
laporan tidak mencetak password maupun hash.

## Perintah

```powershell
.\scripts\uat\seed-real-case.ps1 `
  -SourceDatabaseName kontainer_db `
  -DatabaseName kontainer_db_uat `
  -ApiBaseUrl http://127.0.0.1:8080/api/v1 `
  -MinioEndpoint http://127.0.0.1:9000 `
  -MinioBucket gift-survey-uat-real-case `
  -MasterSourceCustomerCode UAT-CUST-17B `
  -Mode BrowserReady

.\scripts\uat\verify-real-case.ps1 -DatabaseName kontainer_db_uat

.\scripts\uat\cleanup-real-case.ps1 -DatabaseName kontainer_db_uat -DryRun
```

`Mode` menerima `All`, `BrowserReady`, atau `Finalize`. `-SkipPhotos` menandai
pemeriksaan object sebagai `SKIPPED`; script tidak membuat metadata foto palsu.

Jika target belum ada, seed membuat target lalu menyalin source dengan
`mysqldump --single-transaction`. Migration 0013–0016 hanya diterapkan bila
marker utuhnya belum ada. Kegagalan migration parsial menghentikan seed.

## Idempotensi dan manifest

Bootstrap memakai username UAT yang stabil, `INSERT IGNORE` pada relasi role,
upsert profile Surveyor, dan satu manifest `UAT-REAL-CASE-2026-08`.
Fingerprint SHA-256 dibuat dari mapping master aktif sumber. Rerun dataset lengkap
menjadi no-op untuk bootstrap; dataset domain parsial tidak dibangun jika master
teknis tidak cukup.

Gambar sintetis dibuat di `tmp/uat-real-case/` dan diberi label terlihat
`UAT DUMMY — BUKAN BUKTI INSPEKSI`. File tersebut tidak pernah dimasukkan
langsung ke tabel metadata.

## Status master lokal 5 Agustus 2026

Lookup database nyata menemukan kategori foto `inspection` dan `finding`, tetapi:

- tidak ada satu pun `cedex_locations.input_mode='structured'`;
- template aktif sumber hanya terkait Container Type `CT-17B` (`22G1`, 20,
  Dry UAT), bukan 20GP/40GP/40HC pada JSON.

Karena itu skenario yang membutuhkan marker, Temuan, dan workflow final diberi
`SKIPPED_MASTER_MISSING`. Menambah atau menebak kode CEDEX/template untuk
melewati gate dilarang.

Setelah Admin menyediakan mapping structured dan template aktif yang tepat,
jalankan seed ulang. Jangan mengubah JSON menjadi kode teknis buatan.

## Cleanup

Cleanup selalu memeriksa suffix `_uat` dan manifest. `-DryRun` hanya menghitung
scope. SQL cleanup memakai filter username `uat.%`, email `.test`, dan manifest.
Jika Job atau object dataset sudah ada, helper menolak cleanup SQL parsial:
hapus domain records melalui API sesuai urutan FK dan object hanya dengan prefix
dataset, lalu ulangi cleanup. Script tidak memakai `TRUNCATE`, `DROP TABLE`, atau
DELETE tanpa filter.
