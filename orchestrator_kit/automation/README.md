# Automation Surface Map

This guide connects every automation asset in the repo back to the orchestrator deliverables and guardrails that govern them.

## Core Specs

- `automation_specs.md` — high-level contract (budget caps, retry policy, guardrails).
- `06_zaps_make.yaml` — Zapier/Make blueprint; mirrors sections in `automation_specs.md`.
- `webhook_contracts.json` — payload schema consumed by Zaps and Cloudflare Workers.
- `cloud_workers/` — Worker code + Supabase schema implementing advanced automation paths.
- `src/` — Typescript entrypoint for orchestrator-controlled workers (keep in sync with `cloud_workers/`).

## Connected Systems

| System | Location | Purpose | Linked Deliverables |
| --- | --- | --- | --- |
| n8n flows | `n8n/flows/*.json` | Scheduler + ETL (content nightly, KPI digest, inbox triage) | `automation_specs.md`, `10_kpi_rollup.md`, `12_monitoring.md` |
| MCP tools | `mcp/tools/*.yaml` | Operational runbooks and nightly refresh tasks | `automation_specs.md`, `incident_runbook.md`, `message_standards.md` |
| Memory jobs | `jobs/memory/consolidate.py` | FAQ + transcript consolidation for knowledge curation | `02_scope_faq.csv`, `04_prompts.md` |
| Scripts | `scripts/faqpack_to_csv.js`, etc. | Local tooling to transform FAQ packs | `02_scope_faq.csv`, `docs/kit/faqpacks/*.json` |

## Automation ↔ Guardrail Map

| Surface | Guardrail Docs | Enforcement Notes |
| --- | --- | --- |
| Zapier/Make (A1–A5) | `automation_specs.md`, `06_zaps_make.yaml`, `guides/message_standards.md` | Redaction patterns, owner rotation, ≤60-word replies echoed via prompts |
| Slack Webhooks | `automation/webhook_contracts.json`, `guides/slack_channels.md` | Schema validation and channel pin requirements; failures surface in `#ops-bot` |
| Cloud Workers | `automation/automation_specs.md`, `automation/cloud_workers/README_DEPLOY.md`, `guides/governance_security.md` | Env vars documented, deploy checklist enforced via SRE review |
| n8n Schedules | `automation_specs.md`, `artifacts/10_kpi_rollup.md`, `artifacts/12_monitoring.md` | KPI cadence and health checks; send status pings per incident runbook |
| MCP Nightlies | `mcp/tools/*.yaml`, `guides/incident_runbook.md`, `guides/governance_security.md` | Nightly tasks must log to `#ops-bot` and honor access controls |
| Local Scripts | `scripts/faqpack_to_csv.js`, `artifacts/02_scope_faq.csv` | Output must pass CI guardrails (`.github/workflows/kit.yml`) before merging |

## Guardrail Checklist

- Ensure prompt updates in `artifacts/04_prompts.md` are reflected in `automation_specs.md` before deploying.
- When modifying `06_zaps_make.yaml`, re-run dependent n8n flows and validate payloads against `webhook_contracts.json`.
- Any change to `cloud_workers/` must call out required environment variables in `automation_specs.md` and update `roles_matrix.md` for ownership.
- n8n and MCP schedules should post health updates to `#ops-bot` per `guides/message_standards.md`.

Document new automations here as they come online to keep routing decisions transparent for every agent.


