# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the Orion Edge App repository, containing the orchestrator kit, deployment configurations, and automation tools for an e-commerce chatbot edge application stack. The codebase is organized around a 7-day launch plan with 13 agent roles (0-12), each responsible for specific deliverables.

## Key Commands

### Development & Testing
```bash
# Run FAQ CSV generation tests
npm test

# Generate FAQ CSV files from JSON packs
npm run faq:csv

# Run memory consolidation (requires env vars)
python3 jobs/memory/consolidate.py --commit

# Import ChatGPT exports (optional)
python3 jobs/memory/consolidate.py --import init/import/ --commit

# Generate daily memory recall summary
make memo-recall
```

### Docker & Deployment
```bash
# Start the full stack
docker compose -f deploy/cosmocrat-v1.compose.yml up -d

# View specific service logs
docker logs --tail=30 deploy-runner-daily-report-1

# Run utility services (tools profile)
docker compose --profile tools run slack-resolve-channels
```

### Health Checks
```bash
# Quick health check (recommended - checks Docker services, connectivity, security)
bash scripts/quick_health.sh

# Comprehensive health check (includes HTTP endpoint tests)
bash scripts/health_check.sh

# Individual service checks
curl -s http://localhost/mcp/healthz           # MCP API
curl -s http://localhost:8000/v1/models        # vLLM models (if enabled)
curl -s http://localhost:11434/v1/models       # Ollama models

# Database connectivity
docker exec deploy-postgres-1 pg_isready -U cosmocrat
docker exec deploy-redis-1 redis-cli ping

# Service logs
docker logs --tail=50 deploy-mcp-1
docker logs --tail=50 deploy-runner-daily-report-1

# Langfuse UI: http://<edge-ip>:3000/ or http://ops.localhost/langfuse
# n8n UI: http://ops.localhost/n8n
```

## Architecture

### Core Stack Components

**Infrastructure (Traefik + Services):**
- `traefik`: Reverse proxy with HTTPS/Let's Encrypt support (ports 80/443)
- `postgres`: PostgreSQL 16 with pgvector extension for semantic search
- `redis`: Persistent cache for session state
- `clickhouse`: Analytics backend for Langfuse v3
- `langfuse`: LLM observability platform (available at `/langfuse` path)
- `n8n`: Workflow automation engine (available at `/n8n` path)

**LLM & Inference:**
- `ollama`: CPU-based local inference (default model: `qwen2.5:0.5b-instruct`)
- Models stored in `/opt/orion/models` on host

**Application Services:**
- `mcp`: Main API service (built from `deploy/app/mcp/`) - handles chatbot logic
- `memory-consolidator`: Daily job for FAQ/transcript consolidation
- `runner-daily-report`: Executive summary generation service
- `slack-hooks`: Node.js webhook server for Slack CSV integration
- `slack-agent`: Full Slack bot with Socket Mode support (optional)

### Directory Structure

```
orchestrator_kit/          # Canonical source of truth for all deliverables
├── README.md             # Orchestrator hub landing page
├── MANIFEST.md           # Complete artifact inventory with guardrail references
├── artifacts/            # Final deliverables (01_stack.md through 12_monitoring.md)
├── automation/           # Automation specs, webhooks, cloud workers
├── guides/               # Governance (roles_matrix.md, message_standards.md, etc.)
├── prompts/              # Agent prompts (agent_00 through agent_13)
└── workspaces/           # Scratch area for drafts

deploy/
├── cosmocrat-v1.compose.yml  # Production Docker Compose configuration
├── jobs/                     # Containerized Python jobs (memory, runner)
└── letsencrypt/              # ACME certificates

scripts/
├── faqpack_to_csv.js         # Convert JSON FAQ packs to CSV
├── slack_csv_hooks/          # Primary Slack integration (webhooks only)
├── slack_agent/              # Full Slack bot (Socket Mode, optional)
└── slack_oauth/              # OAuth token management

docs/
├── QUICKSTART.md             # Setup instructions
├── ENV_TEMPLATES.md          # Environment variable guidance
├── kit/                      # Legacy launch artifacts (historical reference)
└── Daily_Executive_Summary.md

n8n/flows/                    # n8n workflow definitions (JSON)
jobs/memory/consolidate.py    # Memory consolidation script (runs in container)
templates/                    # CSV templates for Slack integrations
```

### Orchestrator Agent Roles

The codebase follows a multi-agent orchestration model with 13 specialized roles:

- **Agent 0**: Orchestrator & Governance (roles_matrix.md, message_standards.md)
- **Agent 1**: Stack & Platform Lead (01_stack.md)
- **Agent 2**: FAQ & Knowledge Curator (02_scope_faq.csv)
- **Agent 3**: Flow Architect (03_flow_spec.json)
- **Agent 4**: Prompt & Tone Designer (04_prompts.md)
- **Agent 5**: Data & Sheets Owner (05_sheets_setup.md)
- **Agent 6**: Automation Engineer (automation_specs.md, 06_zaps_make.yaml)
- **Agent 7**: Slack Ops & Bot Engineer (slack_channels.md, webhook_contracts.json)
- **Agent 8**: Commerce/Messenger Integrations (08_integrations.md)
- **Agent 9**: QA, Compliance & Accessibility (09_qa_checklist.md)
- **Agent 10**: Analytics & KPI Lead (10_kpi_rollup.md)
- **Agent 11**: Sales Ops & Client Success (11_sales_playbook.md)
- **Agent 12**: SRE/Incident Manager (incident_runbook.md, 12_monitoring.md)

Each agent has defined deliverables, dependencies, and handoff points documented in `orchestrator_kit/guides/roles_matrix.md`.

### Key Guardrails

**Customer Messaging (always enforced):**
- ≤60 words per response
- Exact deferral macro: "I'm not sure on that. Let me have a teammate follow up—what's your email?"
- No PII/payment requests in chat
- Unknown questions → Slack ticket in #ops-bot
- Reference: `orchestrator_kit/guides/message_standards.md`

**Automation & LLM:**
- Budget: $0-$30/month (Slack Free, Google Sheets Free, gpt-4o-mini only)
- LLM settings: temperature 0.4, max tokens to enforce ≤60 words
- 3× retry with exponential backoff, dead-letter to #ops-bot
- PII redaction patterns enforced
- Reference: `orchestrator_kit/automation/automation_specs.md`

**Security & Governance:**
- Never commit `.env` files (templates in private vault only)
- Required env vars: `POSTGRES_URL`, `REDIS_URL`, `LANGFUSE_*`, `SLACK_WEBHOOK_URL`
- Rotate `NEXTAUTH_SECRET`, `SALT`, `CLICKHOUSE_PASSWORD` from defaults
- Reference: `docs/ENV_TEMPLATES.md`, `orchestrator_kit/guides/governance_security.md`

## Important File Locations

**When updating artifacts, ALWAYS use paths in `orchestrator_kit/`** (not legacy `docs/kit/`):

- Agent prompts: `orchestrator_kit/prompts/agent_00_prompt.md` through `agent_13_prompt.md`
- Automation contracts: `orchestrator_kit/automation/webhook_contracts.json`
- FAQ schema: `orchestrator_kit/artifacts/02_scope_faq.csv`
- Message standards: `orchestrator_kit/guides/message_standards.md`
- Roles & dependencies: `orchestrator_kit/guides/roles_matrix.md`

**Legacy location:** `docs/kit/` is kept for historical reference only. Link to canonical paths in `orchestrator_kit/` when referencing deliverables.

## Slack Integrations

**Two integration patterns available:**

1. **Webhook-only** (`scripts/slack_csv_hooks/`): Primary integration for posting messages, reading CSV templates. Requires `SLACK_SIGNING_SECRET` and `DEFAULT_SLACK_WEBHOOK`.

2. **Full bot** (`scripts/slack_agent/`): Optional Socket Mode bot with DM, modal, and channel reading capabilities. Requires `SLACK_APP_TOKEN`, `SLACK_BOT_TOKEN`.

See `docs/ENV_TEMPLATES.md` for when to use each pattern.

## FAQ Pack Workflow

FAQ packs are JSON files in `docs/kit/faqpacks/*.json` structured as:
```json
{
  "vertical_name": [
    {
      "intent": "greeting",
      "utterances": ["hello", "hi"],
      "reply": "Welcome! How can I help?",
      "tone": "friendly, concise, ≤60 words",
      "source_notes": "faqpack:vertical/intent"
    }
  ]
}
```

Convert to CSV for automation ingestion:
```bash
node scripts/faqpack_to_csv.js docs/kit/faqpacks out=./docs/kit/faqpacks/generated
```

Test the conversion:
```bash
npm test  # Runs tests/faq_csv.test.js
```

## Memory & Observability

**Memory consolidation** runs daily via `memory-consolidator` service:
- Pulls traces from Langfuse
- Writes episodic + semantic memories to Postgres/pgvector
- Tags traces with `memory.hit` and `cloud.hit` metadata

**Daily report runner** (`runner-daily-report`):
- Generates executive summaries (Decisions, Actions, Deltas)
- Posts to Slack via `SLACK_WEBHOOK_URL`
- Stores reports in `/data/reports`

**Orchestrator memo recall:**
```bash
make memo-recall  # Runs scripts/memo_recall.sh
```

## Production Deployment Notes

**Before going live:**
1. Update Traefik host rules: `ops.localhost` → `ops.yourdomain.com`, `mcp.localhost` → `mcp.yourdomain.com`
2. Add DNS A records pointing to edge host IP
3. Configure Let's Encrypt: set `ACME_EMAIL` env var, ensure `letsencrypt/acme.json` has correct permissions
4. Rotate all default secrets: `NEXTAUTH_SECRET`, `SALT`, `CLICKHOUSE_PASSWORD`, `POSTGRES_PASSWORD`
5. Run health checks (see QUICKSTART.md)
6. Verify memory consolidation with test query

**Daily orchestrator checklist:**
1. Run `make memo-recall` and post to #proj-chatbot
2. Review Langfuse dashboard for memory/cloud hit trends
3. Confirm KPI schedule succeeded (Zap 3, Fridays 9am)
4. Update roles_matrix.md RAG table if risk/blocked

## n8n Workflows

Import workflows after stack is up:
```bash
n8n import:workflow --input n8n/flows/post_setup.n8n.json
n8n import:workflow --input n8n/flows/daily_report.json
# Repeat for: content_nightly.json, inbox_agent.json, kb_refresh.json, lead_passthrough.json
```

Workflows handle:
- Content refresh (nightly)
- Inbox triage
- KB updates
- Lead capture passthrough
- Daily reports

## Links to Key Documentation

- **Orchestrator Hub**: `orchestrator_kit/README.md` → `MANIFEST.md` (source of truth)
- **7-Day Launch Plan**: `00_README.md`
- **Setup Guide**: `docs/QUICKSTART.md`
- **Environment Setup**: `docs/ENV_TEMPLATES.md`
- **Slack Webhooks**: `docs/SLACK_CSV_HOOKS.md` (if exists)
