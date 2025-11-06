# Orion Orchestrator Hub

This directory is now the canonical home for every asset the orchestrator team stewards. Use the quick links below when spinning up agents or reviewing deliverables.

## Directory Index

- `MANIFEST.md` — source-of-truth inventory showing where each artifact lives and which guardrails it enforces.
- `STRUCTURE.md` — directory blueprint plus migration notes.
- `artifacts/` — final deliverables handed off to stakeholders (`01_stack.md`, `03_flow_spec.json`, `09_qa_checklist.md`, etc.).
- `automation/` — machine-facing specs (`automation_specs.md`, `06_zaps_make.yaml`, `webhook_contracts.json`, `cloud_workers/`, `src/`).
- `guides/` — governance guardrails (`roles_matrix.md`, `message_standards.md`, `incident_runbook.md`, `governance_security.md`, `slack_channels.md`).
- `prompts/` — agent prompts + start-work template.
- `workspaces/` — scratch area for in-progress drafts. Create subfolders as needed.
- `marketing/` — positioning collateral plus pull-site strategy.

## Guardrail Highlights

- **Customer messaging:** `guides/message_standards.md` (deferral macro, ≤60-word limit, unknown ticketing).
- **LLM prompt safety:** `artifacts/04_prompts.md` and `prompts/bonus_prompts.md` (tone variants, fallback phrasing).
- **Automation controls:** `automation/automation_specs.md` + `automation/06_zaps_make.yaml` (budgets, retry policy, redaction patterns).
- **Operational assurance:** `artifacts/09_qa_checklist.md`, `artifacts/10_kpi_rollup.md`, `artifacts/12_monitoring.md`.
- **Memo recall:** `scripts/memo_recall.sh` (daily 08:00 Slack-ready summary) + `docs/QUICKSTART.md` health checks.

## Daily Orchestrator Checklist

1. Run `scripts/memo_recall.sh` and post the output to `#proj-chatbot`.
2. Review Langfuse dashboard for `memory.hit` and `cloud.hit` trends.
3. Confirm `automation/automation_specs.md` KPI schedule succeeded (Zap 3).
4. Update `guides/roles_matrix.md` RAG table if risk/blocked.

Legacy launch assets remain under `docs/kit/` for historical reference (marketing packs, FAQ generators). When updating process docs or referencing artifacts, link to the paths above to avoid drift.


