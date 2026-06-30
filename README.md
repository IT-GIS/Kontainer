# Container Survey Management System

Monorepo aplikasi pengelolaan survey container.

## Stack

- Web: Next.js + TypeScript
- API: Go + Gin
- Database: MySQL 8 / Laragon
- Queue/cache: Redis
- Object storage: MinIO / S3

## Menjalankan dengan MySQL Laragon

Prasyarat: Node.js, npm, Go 1.22+, Laragon dengan MySQL 8+.

1. Nyalakan MySQL dari Laragon.
2. Import `database/kontainer_db.sql` melalui phpMyAdmin.
3. Salin environment jika `.env` belum ada:

```powershell
Copy-Item .env.example .env
```

Konfigurasi Laragon default sudah disiapkan:

```env
DATABASE_URL=root@tcp(127.0.0.1:3306)/kontainer_db?parseTime=true&charset=utf8mb4&loc=Local
```

4. Jalankan API:

```powershell
cd services/api
go mod tidy
go run ./cmd/api
```

5. Pada terminal baru, jalankan web:

```powershell
npm install
npm run dev:web
```

6. Buka `http://localhost:3000`.

Akun development memakai password `password`:

- `superadmin@gift.local`
- `admin@gift.local`
- `surveyor@gift.local`
- `supervisor@gift.local`
- `finance@gift.local`
- `management@gift.local`

Dokumentasi query lengkap tersedia di `database/MYSQL_LARAGON_SETUP.md`.

## Docker Compose

Docker memakai service MySQL internal dan tidak memakai MySQL Laragon:

```powershell
docker compose -f infra/docker/docker-compose.yml --env-file .env up --build
```

URL lokal:

- Web: `http://localhost:3000`
- API: `http://localhost:8080`
- Nginx: `http://localhost:8088`
- MinIO: `http://localhost:9001`
