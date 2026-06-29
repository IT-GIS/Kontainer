# MySQL infrastructure

Migration MySQL berada di `services/api/migrations` dan file gabungan untuk import manual tersedia di `database/kontainer_db.sql`.

Untuk Laragon, import file gabungan melalui phpMyAdmin. Untuk Docker Compose, migration dipasang ke `/docker-entrypoint-initdb.d` dan dijalankan otomatis saat volume MySQL masih kosong.
