---
title: Seed the FAQ database
---

The FAQ is empty. Create `db/import.sql` that inserts ~10 FAQ entries about **Docker Sandboxes** into the `faqs` table (see `db/01_schema.sql`), covering at minimum: what sandboxes are, how credential injection keeps secrets out of the VM, the three network policy presets, clone mode, and what kits are. Use categories `basics`, `security`, and `networking`, and set `sort_order` so entries display sensibly. Keep answers to 2–3 sentences, technically accurate per https://docs.docker.com/ai/sandboxes/.

The file must load automatically via the existing `docker-entrypoint-initdb.d` mount (it already sorts after `01_schema.sql`). **Do not modify the schema or any application code.**
