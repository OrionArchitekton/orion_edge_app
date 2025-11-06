# Cosmocrat v1 — Developer Playbook (Loaded)
- Core: Traefik, MCP, Postgres+pgvector, Redis, Langfuse, n8n, vLLM
- Plus: Memory consolidator job; Appsmith page placeholders; Cloud-init with Terraform

## Launch Steps
1) Copy env/*.example → env/*.env and fill secrets
2) docker compose -f deploy/cosmocrat-v1.compose.yml up -d
3) Import n8n flows → set creds → run smoke tests
4) (Optional) Terraform from infra/terraform/envs/tarot-prod

## Packs
- re, ecom (Tarot), trading (paper mode)
