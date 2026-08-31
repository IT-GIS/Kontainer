# Playwright UAT

`responsive-smoke.spec.ts` tidak memerlukan API dan berjalan pada viewport
360x800, 390x844, 412x915, 768x1024, 1366x768, serta 1920x1080.
Pada Windows dengan Microsoft Edge terpasang, set `PLAYWRIGHT_USE_EDGE=1`
sebagai alternatif lokal tanpa unduhan browser Playwright. CI tetap memasang
Chromium versi yang dikunci oleh package.

`operational-workflow.spec.ts` bersifat mutatif dan sengaja tidak aktif secara
default. Jalankan hanya pada database berakhiran `_uat` dan bucket/prefix UAT
setelah `scripts/uat/seed-real-case.ps1` serta fixture domain selesai. Fixture
wajib menyediakan:

- satu job dua peti kemas yang keduanya belum dimulai;
- satu survey draft lengkap dan lolos validasi submit;
- satu survey lengkap berstatus `submitted` untuk cabang reject;
- akun Surveyor, Supervisor, Management, dan Admin tanpa permission review.

Environment wajib: `PLAYWRIGHT_EXTERNAL_SERVER=1`, `PLAYWRIGHT_BASE_URL`,
`E2E_OPERATIONAL=1`, `E2E_MULTI_CONTAINER_JOB_ID`, `E2E_CONTAINER_A_NO`,
`E2E_CONTAINER_B_NO`, `E2E_REVISION_SURVEY_ID`, `E2E_REJECTION_SURVEY_ID`, dan
`E2E_ISOLATION_SURVEY_ID`, serta
pasangan `E2E_<ROLE>_EMAIL`/`E2E_<ROLE>_PASSWORD` untuk keempat role.
`E2E_PHOTO_PATH` opsional; default memakai logo PNG repository sebagai file
uji dan bukan sebagai bukti inspeksi nyata.

Jalankan `npm run test:e2e:operational --workspace apps/web`. Setiap tahap
penting melampirkan screenshot ke report Playwright; video/trace disimpan bila
gagal. Reseed fixture sebelum rerun karena suite mengubah status workflow.
