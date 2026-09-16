# docker-faq

A three-service web application that serves a FAQ list about Docker Sandboxes. It is built to demonstrate how Docker Sandboxes can run AI coding agents against a real codebase.

```
browser → frontend :3000 → backend :8000 → postgres :5432
```

| Service | Stack | Responsibility |
|---|---|---|
| **frontend** | Node.js / Express | Serves the HTML page; proxies `/api/*` to the backend |
| **backend** | Python / Flask | REST API; reads FAQ entries from PostgreSQL |
| **database** | PostgreSQL 16 | Stores FAQ content (question, answer, category) |

The frontend never talks to the database directly — all data flows through the backend API. There is no build step and no client-side framework.

## Prerequisites

- **Docker** — to run PostgreSQL
- **Python 3.10+** with [`uv`](https://docs.astral.sh/uv/getting-started/installation/)
- **Node.js 18+** with `npm`

## Running the initial state

Start the services in this order: database → backend → frontend.

### 1. Start PostgreSQL

**Run this from the `docker-faq/` directory** — `$PWD/db` must resolve to the repo's `db/` folder or the schema won't load.

```bash
cd docker-faq   # if you aren't already here
docker run -d --name faq-db \
  -e POSTGRES_DB=faq \
  -e POSTGRES_USER=faq \
  -e POSTGRES_PASSWORD=faq \
  -p 5432:5432 \
  -v "$PWD/db":/docker-entrypoint-initdb.d \
  postgres:16
```

Any `.sql` files in `db/` are loaded automatically, in filename order, on **first** initialization only (i.e. when the container's data directory is empty). To re-initialize from scratch:

```bash
docker rm -f faq-db
# then re-run the docker run command above from docker-faq/
```

Verify the schema loaded:

```bash
docker exec faq-db psql -U faq -d faq -c '\dt'
# Expected:        List of relations
#  Schema | Name | Type  | Owner
# --------+------+-------+-------
#  public | faqs | table | faq
```

If you see "Did not find any relations", the init script didn't run — usually because `docker run` was called from the wrong directory. Remove the container and re-run from `docker-faq/`.

### 2. Start the backend

```bash
cd backend
uv run python app.py
```

The backend listens on port **8000**. Configuration is via environment variables — the defaults match the `docker run` command above:

| Variable | Default |
|---|---|
| `DB_HOST` | `localhost` |
| `DB_PORT` | `5432` |
| `DB_NAME` | `faq` |
| `DB_USER` | `faq` |
| `DB_PASSWORD` | `faq` |

Verify it's running:

```bash
curl localhost:8000/api/healthz
# {"status": "ok"}

curl localhost:8000/api/faqs
# {"faqs": []}
```

### 3. Start the frontend

Open a new terminal:

```bash
cd frontend
npm install
node server.js
```

The frontend listens on port **3000**. Open **http://localhost:3000** in a browser.

You should see a plain page with the heading "Docker Sandboxes — FAQ" and an empty state message: *"No FAQs yet. The database has no entries."* This is the expected initial state.

Set `BACKEND_URL` to point the proxy at a non-local backend (default: `http://localhost:8000`).

## API reference

| Endpoint | Method | Response |
|---|---|---|
| `/api/faqs` | GET | `{"faqs": [{id, question, answer, category}, ...]}` ordered by `sort_order, id`. Returns `503` if the database is unreachable. |
| `/api/healthz` | GET | `{"status": "ok"}` — always 200, regardless of database state. |

## Known gaps

These are tracked as GitHub issues and are intentionally unresolved:

1. **No orchestration** — the three services must be started by hand. A `compose.yaml` would bring up the full stack with a single command.
2. **No data** — the schema exists but the `faqs` table is empty. A seed file (`db/import.sql`) with FAQ content about Docker Sandboxes would populate it on first initialization.
3. **No styling** — the page renders correctly but has no visual design. A CSS pass to match Docker's brand guidelines would make it presentable.
