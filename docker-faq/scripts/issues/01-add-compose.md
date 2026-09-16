---
title: Add Docker Compose orchestration
---

Running three services by hand is error-prone. Add a `compose.yaml` at the repo root that runs the full stack:

- `db`: postgres:16, env per the README, mounting `./db` into `/docker-entrypoint-initdb.d`, with a `healthcheck` using `pg_isready`
- `backend`: built from `./backend`, wired to the db via environment variables, with a healthcheck against `/api/healthz`, starting only after `db` is healthy (`depends_on` with `condition: service_healthy`)
- `frontend`: built from `./frontend`, `BACKEND_URL` pointing at the backend service, port 3000 published, starting only after `backend` is healthy

`docker compose up` from a clean checkout must bring up all three services and serve the site on :3000. **This issue owns all Compose changes — do not modify application code.**
