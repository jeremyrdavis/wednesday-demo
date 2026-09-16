# sbx-demo

A live demo of [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) — AI coding agents running against a real codebase on stage.

The demo app is `docker-faq`: a deliberately incomplete three-service FAQ application about Docker Sandboxes. Three GitHub issues are left open so AI agents can fix them live: adding Docker Compose orchestration, seeding the database, and applying Docker brand styling. The sandbox kit packages the agent with the network access and context it needs to complete each issue.

## Repository layout

```
sbx-demo/
├── docker-faq/               # The demo application (push this to GitHub)
│   ├── backend/              # Python / Flask REST API  →  :8000
│   ├── frontend/             # Node.js / Express server →  :3000
│   ├── db/                   # PostgreSQL schema (no seed data)
│   └── scripts/
│       └── create-issues.sh  # Populates the three demo issues on GitHub
├── docker-faq-demo-kit/      # Docker Sandbox kit for the demo agent
│   ├── spec.yaml             # Kit definition (image, network policy, credentials)
│   └── files/home/
│       └── docker-brand.md   # Brand guide injected into agent memory
└── docker-faq-demo-initial-state-SPEC.md  # Full build specification
```

## Running the application

The app has three services that must be started in order. See [`docker-faq/README.md`](docker-faq/README.md) for full details.

**Prerequisites:** Docker, Python 3.10+ with `uv`, Node.js 18+ with `npm`.

### 1. Start PostgreSQL

From the `docker-faq/` directory:

```bash
docker run -d --name faq-db \
  -e POSTGRES_DB=faq \
  -e POSTGRES_USER=faq \
  -e POSTGRES_PASSWORD=faq \
  -p 5432:5432 \
  -v "$PWD/db":/docker-entrypoint-initdb.d \
  postgres:16
```

### 2. Start the backend

```bash
cd docker-faq/backend
uv run python app.py
```

### 3. Start the frontend

```bash
cd docker-faq/frontend
npm install && node server.js
```

Open **http://localhost:3000**. You should see a plain page with an empty FAQ list — this is the expected initial state.

## What's missing (intentionally)

The application works but is incomplete. Three things are left as open GitHub issues for agents to fix:

1. **No orchestration** — services must be started individually; no `compose.yaml` exists
2. **No data** — the `faqs` table is empty; no seed file exists in `db/`
3. **No styling** — the frontend has minimal black-and-white CSS; no brand styling applied

## Sandbox kit

The `docker-faq-demo-kit/` directory contains the kit that launches the demo agent. It scopes network access to what the tasks need (GitHub, package registries, Google Fonts for issue #3) and injects the Docker brand guide into agent memory — kept out of the application repo so the styling reveal works on stage.

See [`RUNBOOK.md`](docker-faq/RUNBOOK.md) for presenter setup steps.
