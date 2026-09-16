-- Seed data for the faqs table.
-- Loaded automatically by postgres via docker-entrypoint-initdb.d
-- (runs after 01_schema.sql, in filename sort order).

INSERT INTO faqs (question, answer, category, sort_order) VALUES
(
    'What is a Docker Sandbox?',
    'A Docker Sandbox is an isolated environment where an agent can run commands, edit files, and use tools without touching your host machine directly. Changes stay contained inside the sandbox until you review and pull them back out.',
    'basics',
    10
),
(
    'What is a sandbox kit?',
    'A kit is a reusable spec.yaml package that pre-configures a sandbox for a specific job: environment variables, starter files, network policy, and sometimes a prebuilt image. Handing someone a kit gets them a ready-to-go environment instead of manual setup.',
    'basics',
    20
),
(
    'What is clone mode?',
    'Clone mode is a workspace mode where the sandbox works on a standalone git clone of your repository instead of mounting your working tree directly. Commits stay inside the sandbox until you fetch them onto the host from its git-daemon remote.',
    'basics',
    30
),
(
    'How is a sandbox different from a regular long-running container?',
    'A sandbox is scoped to a single task or session rather than a persistent service. It has its own filesystem, network policy, and lifecycle, and it is torn down (after its useful changes are reconciled back) once the task is finished.',
    'basics',
    40
),
(
    'How does credential injection keep secrets out of the sandbox?',
    'Outbound requests pass through a proxy that injects credentials, such as a GitHub token, at the network layer. The agent and the sandbox filesystem never receive or store the raw secret, so it cannot leak through files, logs, or a compromised process.',
    'security',
    10
),
(
    'Does the agent inside a sandbox ever see my GitHub token?',
    'No. Tools like gh even report "not logged in" inside the sandbox because no token file exists there. The proxy authenticates git pushes and API calls transparently, injecting the credential on each request without exposing it to the agent.',
    'security',
    20
),
(
    'What limits what a sandboxed agent can reach or change?',
    'Three things combine to set the blast radius: the filesystem scope it was given (a worktree or a clone), the network policy controlling which domains it can reach, and the specific secrets scoped to that sandbox. Anything outside those stays out of reach.',
    'security',
    30
),
(
    'What are the three network policy presets?',
    'Sandboxes can run with default deny (only explicitly allowed domains are reachable), an allow-list of specific domains, or allow-all (matching every domain not on a denylist). Presets trade off safety against how much internet access a task genuinely needs.',
    'networking',
    10
),
(
    'What happens when a sandboxed request is blocked by network policy?',
    'The request fails with an HTTP 403 whose body explains why: a local deny rule, an organization policy, or a default-deny with no matching allow rule. That detail is enough to diagnose the block and add an allow rule if the access is legitimate.',
    'networking',
    20
),
(
    'How do I expose a service running inside a sandbox to my host machine?',
    'From the host, run sbx ports <sandbox-name> --publish <port> to publish it. The service inside the sandbox must bind to 0.0.0.0 (or ::) rather than only 127.0.0.1, or the published port will have nothing to forward to.',
    'networking',
    30
);
