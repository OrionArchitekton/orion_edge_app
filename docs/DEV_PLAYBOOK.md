# Cosmocrat v1 — Developer Playbook (Loaded)
- Core: Traefik, MCP, Postgres+pgvector, Redis, Langfuse, n8n, vLLM
- Plus: Memory consolidator job; Appsmith page placeholders; Cloud-init with Terraform

## Launch Steps
1) Copy env/*.example → env/*.env and fill secrets (see `docs/ENV_TEMPLATES.md` for private template guidance)
2) docker compose -f deploy/cosmocrat-v1.compose.yml up -d
3) [ ] Memory Online / Recall enabled — `python3 jobs/memory/consolidate.py --commit` (verify Langfuse trace `memory.hit=true`)
4) Import n8n flows → set creds → run smoke tests
5) (Optional) Terraform from infra/terraform/envs/tarot-prod

## Packs
- re, ecom (Tarot), trading (paper mode)
