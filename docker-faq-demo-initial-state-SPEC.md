# Spec: Docker Sandboxes Demo — Initial State

**Audience for this document:** Claude Code, tasked with building the starting state of a live demo.
**Do not implement the three GitHub issues.** The whole point is that they are unresolved — AI agents fix them live, on stage. Your job is to build a repo that works *just barely*, plus the sandbox kit used to launch the agents.

---

## 1. Concept and constraints

The demo repo is `docker-faq`: a deliberately unfinished three-service FAQ application about Docker Sandboxes.

- **Backend:** Python / Flask REST API, reads FAQ entries from PostgreSQL
- **Frontend:** Node.js / Express, server that serves a page listing the FAQs
- **Database:** PostgreSQL 16, run via `docker run` (no Compose file exists — that's issue #1)

**The "before" state must be:** each service runs individually, the page renders, but it is visually bare (black and white, minimal styling) and shows an empty/degraded FAQ list because the database has no seed data. The three issues collectively bring it to life: orchestration (#1), content (#2), brand styling (#3).

Hard constraints:

1. **No `docker-compose.yml` / `compose.yaml` anywhere.** Issue #1 creates it.
2. **No seed data.** `db/` contains schema only. Issue #2 creates `db/import.sql`.
3. **Frontend styling must be deliberately plain.** Black text, white background, grays only, system font, minimal CSS. No colors, no web fonts, no CSS framework. Issue #3 restyles it. Resist the urge to make it look good.
4. **No brand assets in the repo.** No hex codes, no `docker-brand.md`, no references to Docker's palette anywhere in the Git repository. The brand guide ships only inside the sandbox kit (section 5) — this is load-bearing for the demo's reveal.
5. **Everything must degrade gracefully.** DB down or empty → the page still renders with a clear empty state. The before-screenshot is a working skeleton, not a stack trace.
6. Keep dependencies minimal and pinned. This runs live on stage; boring is a feature.

---

## 2. Repository layout

```
docker-faq/
├── README.md
├── .gitignore                  # node_modules, __pycache__, .venv, .env
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── server.js
│   ├── package.json
│   ├── public/
│   │   ├── index.html
│   │   ├── app.js
│   │   └── styles.css
│   └── Dockerfile
└── db/
    └── 01_schema.sql
```

**Dockerfiles for backend and frontend are part of the initial state** (simple, single-stage, official base images: `python:3.12-slim`, `node:22-slim`). Issue #1 must be pure orchestration — the agent writes Compose, not Dockerfiles.

**The schema file is named `01_schema.sql` deliberately.** Postgres's `docker-entrypoint-initdb.d` executes files in sorted order; `01_schema.sql` sorts before `import.sql`, so the seed file the agent creates in issue #2 will load after the schema with no extra wiring. Do not rename it.

---

## 3. Component specs

### 3.1 Database (`db/01_schema.sql`)

```sql
CREATE TABLE IF NOT EXISTS faqs (
    id          SERIAL PRIMARY KEY,
    question    TEXT NOT NULL,
    answer      TEXT NOT NULL,
    category    TEXT NOT NULL DEFAULT 'general',
    sort_order  INTEGER NOT NULL DEFAULT 100
);
```

Schema only. **No INSERT statements.**

The database runs via plain `docker run` (documented in the README, exact command below in 3.4).

### 3.2 Flask backend (`backend/`)

- Flask ≥ 3.0, `psycopg2-binary` (or `psycopg[binary]`), pinned in `requirements.txt`. No ORM.
- Listens on port **8000** (not 5000 — macOS AirPlay squats on 5000).
- Configuration via environment variables with defaults:
  `DB_HOST=localhost`, `DB_PORT=5432`, `DB_NAME=faq`, `DB_USER=faq`, `DB_PASSWORD=faq`.
- Endpoints:
  - `GET /api/faqs` → `200` with JSON `{"faqs": [{id, question, answer, category}, ...]}` ordered by `sort_order, id`. If the DB is unreachable, return `503` with `{"faqs": [], "error": "database unavailable"}` — never a 500 stack trace.
  - `GET /api/healthz` → `200 {"status": "ok"}` unconditionally (process liveness). Do **not** add a readiness endpoint — leave room for agents to extend.
- Connect per-request or with a tiny retry; must start cleanly even when Postgres isn't up yet.
- `Dockerfile`: install requirements, run with `python app.py` binding `0.0.0.0:8000`. Dev-grade server is fine.

### 3.3 Node frontend (`frontend/`)

- Express (pinned), no other runtime deps. Listens on port **3000**.
- `server.js`:
  - Serves `public/` statically.
  - Proxies `GET /api/*` to the backend at `BACKEND_URL` (default `http://localhost:8000`) — server-side proxy so there is no CORS anywhere. A ~10-line manual proxy using `fetch` is fine; don't add a proxy library.
- `public/index.html` + `app.js`: on load, fetch `/api/faqs` and render:
  - Header: "Docker Sandboxes — FAQ", plain `<h1>`.
  - Each FAQ as question (bold) + answer (paragraph), grouped or tagged by category — but structure it as identifiable elements (e.g., a `<section class="faq-list">` of `<article class="faq-item">`) so the styling agent has clean hooks. **Semantic, styleable markup; zero visual design.**
  - Empty/error state: a visible message — "No FAQs yet. The database has no entries." This is the before-screenshot.
- `public/styles.css`: intentionally minimal — max-width container, default system font, black on white, thin gray borders. **Under ~30 lines.** It must look like 1996.
- `Dockerfile`: `npm ci`, `node server.js`.

### 3.4 README.md

Written for the presenter. Must contain, in order:

1. One-paragraph description + architecture line: `browser → frontend :3000 → backend :8000 → postgres :5432`.
2. **Run PostgreSQL** (this exact command, verbatim):

```bash
docker run -d --name faq-db \
  -e POSTGRES_DB=faq \
  -e POSTGRES_USER=faq \
  -e POSTGRES_PASSWORD=faq \
  -p 5432:5432 \
  -v "$PWD/db":/docker-entrypoint-initdb.d \
  postgres:16
```

   With a note: any `.sql` files in `db/` load automatically, in sorted order, on **first** initialization only — `docker rm -f faq-db` and re-run to re-initialize.

3. **Run the backend:** `cd backend && pip install -r requirements.txt && python app.py`
4. **Run the frontend:** `cd frontend && npm install && node server.js` → open http://localhost:3000
5. A short "Known gaps" section that mirrors the three issues (no orchestration, no data, no styling) — it reads as an honest TODO and quietly justifies the issue list.

---

## 4. GitHub issues (create verbatim)

Create these as `ISSUES.md` at the repo root **and** provide a `scripts/create-issues.sh` using `gh issue create` so the presenter can populate a fresh GitHub repo in one command. Titles and bodies verbatim:

**Issue 1 — Add Docker Compose orchestration**
> Running three services by hand is error-prone. Add a `compose.yaml` at the repo root that runs the full stack:
> - `db`: postgres:16, env per the README, mounting `./db` into `/docker-entrypoint-initdb.d`, with a `healthcheck` using `pg_isready`
> - `backend`: built from `./backend`, wired to the db via environment variables, with a healthcheck against `/api/healthz`, starting only after `db` is healthy (`depends_on` with `condition: service_healthy`)
> - `frontend`: built from `./frontend`, `BACKEND_URL` pointing at the backend service, port 3000 published, starting only after `backend` is healthy
>
> `docker compose up` from a clean checkout must bring up all three services and serve the site on :3000. **This issue owns all Compose changes — do not modify application code.**

**Issue 2 — Seed the FAQ database**
> The FAQ is empty. Create `db/import.sql` that inserts ~10 FAQ entries about **Docker Sandboxes** into the `faqs` table (see `db/01_schema.sql`), covering at minimum: what sandboxes are, how credential injection keeps secrets out of the VM, the three network policy presets, clone mode, and what kits are. Use categories `basics`, `security`, and `networking`, and set `sort_order` so entries display sensibly. Keep answers to 2–3 sentences, technically accurate per https://docs.docker.com/ai/sandboxes/.
>
> The file must load automatically via the existing `docker-entrypoint-initdb.d` mount (it already sorts after `01_schema.sql`). **Do not modify the schema or any application code.**

**Issue 3 — Style the site to match Docker's brand**
> The site is unstyled. Restyle the frontend to follow Docker's brand: palette, typography, and spacing. Style the header, the FAQ list/cards, and the empty state.
> Constraints: modify only `frontend/public/` (HTML structure edits allowed, but no restructuring of the data flow); **no CSS frameworks, no build step, no new dependencies**. The result should look like it belongs on docker.com.

> Note the deliberate omission: issue 3 contains **no hex codes and no link to a style guide**. The agent gets the brand knowledge from the kit — that gap is the demo's reveal.

---

## 5. The sandbox kit (`docker-faq-demo-kit/`, sibling to the repo — NOT inside it)

A **sandbox kit** (`kind: sandbox`) that packages the demo agent: Claude Code, plus the Docker brand guide in agent memory, plus exactly the network access the demo tasks need. Based on Docker's documented built-in `claude` kit spec.

```
docker-faq-demo-kit/
├── spec.yaml
└── files/
    └── home/
        └── docker-brand.md
```

### 5.1 `spec.yaml`

```yaml
schemaVersion: "1"
kind: sandbox
name: docker-faq-demo
displayName: Docker FAQ Demo Agent
description: >
  Claude Code packaged for the FAQ demo: brand guidance in agent memory,
  network access scoped to the demo's tasks.

sandbox:
  image: "docker/sandbox-templates:claude-code-docker"
  aiFilename: CLAUDE.md
  entrypoint:
    run: [claude, "--dangerously-skip-permissions"]

network:
  serviceDomains:
    api.anthropic.com: anthropic
    console.anthropic.com: anthropic
  serviceAuth:
    anthropic:
      headerName: x-api-key
      valueFormat: "%s"
  allowedDomains:
    - "claude.com:443"
    - claude.ai                          # Claude Code install script
    # GitHub — clone, push, gh pr create
    - github.com
    - api.github.com
    # Brand typography (issue 3) — BOTH domains required:
    # googleapis serves the CSS, gstatic serves the font files
    - fonts.googleapis.com
    - fonts.gstatic.com
    # Package managers (agents install deps to test their work)
    - pypi.org
    - files.pythonhosted.org
    - registry.npmjs.org
    # Docker Hub pulls (agents run postgres etc. on their in-sandbox daemon)
    - hub.docker.com
    - registry-1.docker.io
    - auth.docker.io
    - production.cloudflare.docker.com
    # NOTE: docker.com is deliberately NOT allowed — the brand guide
    # forbids fetching it, and the policy log proving a blocked probe
    # is a bonus governance beat.

credentials:
  sources:
    anthropic:
      env:
        - ANTHROPIC_API_KEY

environment:
  variables:
    IS_SANBOX_PLACEHOLDER_REMOVE: "unused"   # see build note below
    IS_SANDBOX: "1"

commands:
  install:
    - command: "curl -fsSL https://claude.ai/install.sh | bash"
      user: "1000"
      description: Install Claude Code

agentContext: |
  A Docker brand style guide is available at /home/agent/docker-brand.md.
  For ANY styling or visual design work, follow it exactly: palette,
  typography, spacing, and component guidance. Do not fetch docker.com or
  any other external site for design reference — everything you need is
  in that file.
```

Build note: remove the `IS_SANBOX_PLACEHOLDER_REMOVE` line — it exists in this spec only to make you read the environment block. Final YAML has exactly `IS_SANDBOX: "1"`. Validate the finished kit with `sbx kit validate ./docker-faq-demo-kit/` if `sbx` is available in your environment; otherwise ensure it is well-formed YAML and note validation as a presenter step.

### 5.2 `files/home/docker-brand.md`

The file lands in the agent's home directory, **not** the workspace — anything under `files/workspace/` would be committed into the agent's PR and ruin the reveal. Content:

```markdown
# Docker Brand Style Guide (demo excerpt)

## Palette
| Role | Name | Hex |
|---|---|---|
| Primary action, links | Moby blue | #1D63ED |
| Header / footer background, headings | Dark blue | #00084D |
| Card & section tint | Light blue | #E5F2FC |
| Body text | Off black | #17191E |
| Page background | White | #FFFFFF |
| Accents (borders, hover, tags) | Blue 700 / 400 / 200 | #00308D / #1C90ED / #C0E0FA |

Use white or light-blue text on dark-blue backgrounds. Never place
Moby blue text on dark blue. Body text is off-black on white.

## Typography
Load "Roboto" from Google Fonts (weights 400, 500, 700), with fallback
stack: Roboto, -apple-system, "Segoe UI", Helvetica, Arial, sans-serif.
Headings 600–700 weight. Body 16px, line-height 1.6.

## Components
- **Header:** dark blue (#00084D) full-width bar, white title, subtle
  light-blue tagline.
- **FAQ items:** cards on white — light-blue (#E5F2FC) background,
  8px rounded corners, 24px padding, 16px gaps. Question in dark blue,
  600 weight; answer in off-black. Category shown as a small pill:
  Blue 200 background, Blue 700 text, fully rounded.
- **Empty state:** centered card, light-blue tint, friendly one-liner.
- Max content width 900px, centered. Generous whitespace.

## Rules
- No CSS frameworks, no build tooling — hand-written CSS only.
- Do not fetch docker.com or screenshot any site for reference.
- Maintain WCAG AA contrast throughout.
```

(Reproduce faithfully; light editing for correctness is fine, but keep the palette values exact and keep both "do not fetch docker.com" rules — one here, one in `agentContext`.)

---

## 6. Acceptance criteria (verify before declaring done)

Run these checks; the demo depends on them.

1. `grep -ri "compose" --include="*.y*ml" .` in the repo → no Compose file exists.
2. `grep -ri "1D63ED\|00084D\|docker-brand" docker-faq/` → zero hits. Brand material lives only in the kit.
3. Fresh clone, README steps followed literally:
   - Postgres container starts; `docker exec faq-db psql -U faq -d faq -c '\dt'` shows the `faqs` table, and `SELECT count(*) FROM faqs;` returns **0**.
   - Backend starts with no DB env vars set; `curl localhost:8000/api/faqs` → `200` with empty list; `curl localhost:8000/api/healthz` → `200`.
   - Backend responds `503` (not a crash) when Postgres is stopped.
   - Frontend starts; http://localhost:3000 renders the plain page with the empty-state message. Screenshot-worthy in its ugliness.
4. Insert one row manually (`INSERT INTO faqs (question, answer) VALUES ('t','t');`) → refresh → it renders. Delete it afterward so the repo/DB state stays clean.
5. Both Dockerfiles build: `docker build backend/` and `docker build frontend/` succeed.
6. `scripts/create-issues.sh` is executable and contains three `gh issue create` calls matching section 4 verbatim.
7. Kit directory structure matches 5.x exactly; `docker-brand.md` is under `files/home/`, not `files/workspace/`.

---

## 7. Out of scope for you — presenter runbook (include as `RUNBOOK.md`)

Generate a short `RUNBOOK.md` at the repo root listing the steps the presenter performs, so nothing here gets silently absorbed into the build:

- Push repo to GitHub; run `scripts/create-issues.sh`.
- `sbx secret set -g anthropic` and `gh auth token | sbx secret set -g github`.
- Launch three sandboxes from the kit, one issue each (e.g. `sbx run --clone --name faq-compose --kit ../docker-faq-demo-kit/ ...`) — **exact sandbox-kit invocation syntax must be verified against current docs/`sbx` help; kits are Early Access and the CLI shape may have shifted.**
- **Rehearsal checklist** (verbatim into RUNBOOK.md):
  1. Confirm the agent actually reads `docker-brand.md` (check the memory wiring — with kits, agent context may land under a `kits-agent-context/` index; verify the styled output uses the palette).
  2. Run each issue end-to-end at least twice; tune issue wording if agent output disappoints.
  3. `sbx policy log` after a full rehearsal — add any missed domains (Docker Hub pull CDNs are the likely gap) to the kit's `allowedDomains`.
  4. Verify `gh pr create` works from inside a sandbox launched from this custom kit (GitHub credential injection via the built-in `github` service should apply, but confirm — if not, add github serviceDomains/serviceAuth wiring to the kit).
  5. Pre-warm all three sandboxes the night before (image pulls are per-VM).
  6. Font fallback: if Google Fonts is flaky even when allowed, edit `docker-brand.md` to specify the system stack only and drop the two font domains — fully deterministic, slightly less flashy.
- Final on-stage verification runs in a **fourth** fresh sandbox with the port published — never on the host.
