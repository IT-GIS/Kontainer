# Docker Development

Use `docker-compose.dev.yml` for local infrastructure dependencies only:

```powershell
docker compose -f infra/docker/docker-compose.dev.yml --env-file .env up -d
```

Services:

- MySQL: `localhost:3306`
- Redis: `localhost:6379`
- MinIO API: `http://localhost:9000`
- MinIO Console: `http://localhost:9001`

Use `docker-compose.yml` later for the full application stack with web, API, worker, and Nginx.

