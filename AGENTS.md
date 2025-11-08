# Repository Guidelines

## Project Structure & Module Organization
The root pairs documentation (`docs/`, `00_README.md`) with deploy assets (`deploy/`, `infra/`, `cloud-init/`) so contributors can jump between guides and runnable stack definitions. Runtime code lives under `orchestrator_kit/` (prompts, operator artifacts), `src/` (app assets), `scripts/` (Node utilities), and `jobs/` (Python automation such as `jobs/memory/consolidate.py`). Supporting content includes `n8n/flows/` for workflow JSON, `env/` for template `.env` files, `appsmith/` for dashboard scaffolds, and `tests/` for Node-based smoke tests.

## Build, Test, and Development Commands
- `docker compose -f deploy/cosmocrat-v1.compose.yml up -d` spins up the full Traefik/Postgres/Redis/Langfuse/n8n/vLLM stack described in the launch kit.
- `python3 jobs/memory/consolidate.py --commit` writes recent Langfuse traces into Postgres + pgvector and should be run after refreshing environment data.
- `npm run faq:csv` rebuilds FAQ CSVs from `docs/kit/faqpacks` using `scripts/faqpack_to_csv.js`; pass a pack path to process ad hoc files.
- `npm test` executes `tests/faq_csv.test.js`, validating CSV escaping and column overrides.
- `make memo-recall` (wrapper around `scripts/memo_recall.sh`) emits the Slack-ready memory recap.

## Coding Style & Naming Conventions
Python modules use 4-space indentation, snake_case identifiers, and environment-driven configuration via `os.environ` (see `jobs/memory/consolidate.py`). Node scripts use CommonJS imports, const bindings, and explicit semicolons (`tests/faq_csv.test.js`). Favor kebab-case for directories (`deploy/`, `orchestrator_kit/`) and align filenames with their primary component (e.g., `cosmocrat-v1.compose.yml` for the production stack). Keep environment keys in SHOUTING_SNAKE_CASE and document additions in `docs/ENV_TEMPLATES.md`.

## Testing Guidelines
Add lightweight Node or Python tests under `tests/` and mirror the existing `*.test.js` naming pattern so `npm test` discovers them. Tests should create their own scratch data in `.tmp/` to avoid mutating repo artifacts. For stack-level changes, follow `PR_CHECKLIST.md`: boot the compose stack, hit the health endpoints (`curl -s http://mcp.localhost/healthz`), and run the memory + Slack runners before submitting.

## Commit & Pull Request Guidelines
Recent commits (`git log -5`) show short, imperative summaries focused on the touched area: “Update cosmocrat-v1.compose.yml”, “Refactor FAQ CSV generation and update packs”. Match that style and group unrelated changes into separate commits. PRs should include: (1) a short problem/solution blurb, (2) links to any tickets, (3) confirmation that edge tests from `PR_CHECKLIST.md` passed, and (4) screenshots or logs for UI/automation tweaks. Keep secrets out of diffs and note new env requirements in the PR body.

## Security & Configuration Tips
Never commit populated `.env` files or service accounts; rely on the placeholders in `env/` and expand `docs/ENV_TEMPLATES.md` when adding secrets. When editing `deploy/cosmocrat-v1.compose.yml`, replace example domains (`ops.localhost`, `mcp.localhost`) and ensure `CLICKHOUSE_PASSWORD`, `NEXTAUTH_SECRET`, and `SALT` are rotated. For n8n imports, stage JSON files under `n8n/flows/` and use `n8n import:workflow --input <file>` so operators can replay the same assets on edge hardware.
