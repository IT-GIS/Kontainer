# Admin Information Architecture - Pak Agus Alignment

## 1. Baseline

- Repository: `IT-GIS/Kontainer`.
- Baseline HEAD saat audit: `9ea105f fix: restore master data add actions`.
- Worktree sejak awal sudah berisi perubahan lokal frontend, backend, database migration, dan dokumentasi dari pekerjaan lain.
- Implementasi ini ditumpangkan secara terbatas pada frontend Admin; perubahan lokal lain tidak dibuang, tidak di-commit, dan tidak di-push.

## 2. Dokumen acuan

Prompt menetapkan acuan domain: Panduan Domain dan Alur Aplikasi Kelaikan Kontainer, Struktur Dasar ISO CEDEX, PROGIS Survey, Flowchart GIS System, Input Data Master, dan Survey Sheet Kontainer. File DOCX/PDF tersebut tidak tersedia di checkout saat audit. Implementasi memakai ringkasan alur yang tertulis di prompt: SPK Customer, pembuatan Job, persiapan peti kemas, penugasan Surveyor GIFT, pemeriksaan dengan Survey Sheet dan ISO CEDEX, review, lalu laporan.

## 3. Menu sebelum

Sidebar sebelumnya memecah Customer, Location, Surveyor, Container Type, Survey Type, enam referensi CEDEX, Template Checklist, pekerjaan, monitoring status, report, dan pengaturan menjadi banyak item terpisah.

## 4. Masalah

- Sidebar terlalu panjang.
- Data Customer, referensi pemeriksaan, dan CEDEX tersebar.
- Personel Customer berisiko tertukar dengan Surveyor GIFT.
- Job dan monitoring menggambarkan objek pekerjaan yang sama.
- Import serta assignment terlalu menonjol sebagai submenu.
- QR Validation muncul sebelum fiturnya aktif.

## 5. Menu sesudah

Sidebar Admin final mempunyai enam entry tingkat utama:

1. Dashboard.
2. Pekerjaan Inspeksi.
3. Master Data.
4. Review & Keputusan.
5. Dokumen & Laporan.
6. Pengaturan.

Submenu mengikuti prompt dan tidak menambahkan fungsi bisnis baru.

## 6. ISO CEDEX

`/master/iso-cedex` menjadi canonical presentation dengan tab Location Code, Component Code, Damage Code, Action Repair Code, Material Code, dan Responsibility Code. Setiap tab tetap memakai resource, permission module, endpoint, serta customer scope existing. Label utama repair diubah menjadi Action Repair.

Location Code menampilkan field existing: Code, Face, Grid, Container Size, Mapping Code, Description, Display Order, dan Status. Tab lain memakai field existing yang telah tersedia dan tidak menambah schema.

## 7. Ownership CEDEX yang tidak diubah

Model kepemilikan CEDEX global atau customer-scoped belum diubah pada tahap ini. Tahap ini hanya menyederhanakan struktur menu dan halaman Admin. Konsep Master CEDEX Global dan aktivasi per Customer tetap menjadi rekomendasi tahap backend/database terpisah.

## 8. Customer detail

Detail Customer memakai empat tab:

- Profil Customer.
- Personel/PIC.
- Location Pemeriksaan.
- Riwayat Pekerjaan.

Profil mempertahankan field Customer existing. Riwayat bersifat read-only dan dihitung dari endpoint pekerjaan existing tanpa API baru.

## 9. Personel/PIC dan Surveyor GIFT

Hasil audit source:

- Personel/PIC Customer memakai endpoint customer-scoped `/customers/{customerId}/personnel` dan resource presentation `customer-personnel`.
- Surveyor GIFT memakai master internal `/master/surveyors`, termasuk relasi `user_id` ke akun role Surveyor.
- Assignment tetap memakai Surveyor GIFT.

Kedua data tersebut tidak digabung. Label customer-scoped diubah menjadi Personel/PIC Customer, sedangkan `/master/surveyors` dipindahkan secara presentation ke Pengaturan sebagai Surveyor GIFT.

## 10. Referensi Pemeriksaan

`/master/inspection-references` menyatukan:

- Container Type.
- Survey Type.
- Checklist.
- Test Parameter.
- Photo Category.
- Finding Severity.

Container Type, Survey Type, dan Checklist mempertahankan customer scope existing. Tiga referensi teknis lain memakai resource existing. Tidak ada nilai ambang, metode uji, atau standar baru.

## 11. Pekerjaan Inspeksi

`/jobs` menjadi pusat Pekerjaan Inspeksi dengan filter/tab Semua, Belum Ditugaskan, Sedang Diperiksa, Menunggu Review, Perlu Revisi, Disetujui, dan Selesai. Disetujui adalah derived UI filter dari status/review existing, bukan status backend baru.

`/jobs/create` diberi label Buat Job/SPK. Import Peti Kemas dan Assign Surveyor GIFT tetap tersedia pada detail Job, sedangkan route compatibility lama mengarahkan pengguna ke pekerjaan yang relevan.

Detail Job mempertahankan tab Ringkasan, Peti Kemas, Penugasan, Progress Pemeriksaan, Hasil Survey, Review, Dokumen, dan Riwayat.

## 12. Review

Review & Keputusan tetap terpisah menjadi Menunggu Review dan Riwayat Keputusan. Permission serta action existing tidak diubah. Admin biasa tidak memperoleh action teknis baru.

## 13. Dokumen & Laporan

Group Report diubah menjadi Dokumen & Laporan dengan submenu Laporan Pemeriksaan dan Arsip Laporan. Riwayat versi tersedia pada detail laporan existing. QR Validation disembunyikan dari sidebar dan route lamanya tetap hanya menampilkan notice fitur belum aktif.

## 14. Pengaturan

Pengaturan berisi Surveyor GIFT, Company Profile, Penomoran, User & Hak Akses, dan Audit Log. User Management serta Role & Permission digabung pada presentation `/settings/users`; permission backend tidak berubah.

## 15. Route compatibility

Route lama untuk Location, Container Type, Survey Type, enam referensi CEDEX, monitoring, import, assignment, report versions, QR Validation, serta settings tetap redirect atau render aman. Detail legacy customer-scoped diteruskan ke tab canonical dengan `customerId` yang sama.

## 16. Active state

Satu navigation item memiliki seluruh match canonical dan legacy terkait. Query-specific match pada Arsip Laporan mendapat skor lebih tinggi daripada match umum Laporan Pemeriksaan. Route detail Customer mengaktifkan Customer; route ISO legacy mengaktifkan ISO CEDEX; route Container Type dan Survey Type mengaktifkan Referensi Pemeriksaan.

## 17. Responsive

Group sidebar dapat collapse, drawer mobile tetap dipakai, tab memakai horizontal overflow, tabel memakai presentation responsive existing, dan action utama tetap dapat membungkus pada viewport sempit.

## 18. Accessibility

- Tab memakai `role=tablist`, `role=tab`, dan `aria-selected`.
- Focus visible ditambahkan pada link tab.
- Navigation active memakai `aria-current`.
- Status tetap memakai label teks melalui StatusBadge, bukan warna saja.
- Picker, loading state, dan ringkasan mempunyai label atau status yang dapat dibaca.

## 19. Hasil test

- `npm run typecheck --workspace apps/web`: lulus.
- `npm run build --workspace apps/web`: lulus; 68 route berhasil digenerate.
- `git diff --check`: lulus; hanya warning normalisasi LF/CRLF.
- Browser UAT: lulus memakai Microsoft Edge headless lokal sebagai fallback setelah koneksi in-app browser tidak dapat bootstrap pada metadata sandbox.
- Login Admin, Supervisor, Management, dan sanity check menu Surveyor berhasil.
- Seluruh 25 route compatibility yang diwajibkan merender halaman non-blank dan active state tunggal yang sesuai.
- Viewport 1440 x 900, 1280 x 720, 1024 x 768, 768 x 1024, dan 390 x 844 tidak mempunyai overflow body horizontal; tab tetap dapat scroll.
- Tidak ditemukan runtime exception, log error, atau hydration error pada rangkaian UAT.
- Delapan screenshot tersimpan di `docs/screenshots/admin-iso-pak-agus`.

## 20. Hal yang belum selesai

- Keputusan arsitektur CEDEX global atau customer-scoped.
- Aktivasi PDF final, QR, dan verifikasi publik.
- Backend, database, permission, serta workflow Surveyor berada di luar scope tahap ini.
- Dokumen domain biner perlu disertakan di checkout bila dibutuhkan verifikasi field terhadap sumber asli.
