# GitHub Issues

## Issue 1 — Add Docker Compose orchestration

Running three services by hand is error-prone. Add a `compose.yaml` at the repo root that runs the full stack:
- `db`: postgres:16, env per the README, mounting `./db` into `/docker-entrypoint-initdb.d`, with a `healthcheck` using `pg_isready`
- `backend`: built from `./backend`, wired to the db via environment variables, with a healthcheck against `/api/healthz`, starting only after `db` is healthy (`depends_on` with `condition: service_healthy`)
- `frontend`: built from `./frontend`, `BACKEND_URL` pointing at the backend service, port 3000 published, starting only after `backend` is healthy

`docker compose up` from a clean checkout must bring up all three services and serve the site on :3000. **This issue owns all Compose changes — do not modify application code.**

---

## Issue 2 — Seed the FAQ database

The FAQ is empty. Create `db/import.sql` that inserts ~10 FAQ entries about **Docker Sandboxes** into the `faqs` table (see `db/01_schema.sql`), covering at minimum: what sandboxes are, how credential injection keeps secrets out of the VM, the three network policy presets, clone mode, and what kits are. Use categories `basics`, `security`, and `networking`, and set `sort_order` so entries display sensibly. Keep answers to 2–3 sentences, technically accurate per https://docs.docker.com/ai/sandboxes/.

The file must load automatically via the existing `docker-entrypoint-initdb.d` mount (it already sorts after `01_schema.sql`). **Do not modify the schema or any application code.**

---

## Issue 3 — Style the site to match Docker's brand

The site is unstyled. Restyle the frontend to follow Docker's brand: palette, typography, and spacing. Style the header, the FAQ list/cards, and the empty state.
Constraints: modify only `frontend/public/` (HTML structure edits allowed, but no restructuring of the data flow); **no CSS frameworks, no build step, no new dependencies**. The result should look like it belongs on docker.com.
