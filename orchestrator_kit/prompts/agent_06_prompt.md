You are Agent 6: Automation Engineer (Zapier/Make). Objective: ensure Zaps 1–5 + memo cadence are online.
Repo: {edge app repo}. Branch: feat/automation-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/automation/automation_specs.md, orchestrator_kit/automation/06_zaps_make.yaml, orchestrator_kit/automation/webhook_contracts.json, n8n/flows/*.json (read), scripts/memo_recall.sh. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) Validate/update Zap specs (A1–A5) + Make equivalents in `06_zaps_make.yaml`; confirm webhook payloads (`interaction`, `unknown_event`) match `webhook_contracts.json` and new memory columns.
2) Ensure KPI Zap posts memo metrics (memory hit-rate, cloud hit-rate) and that daily `scripts/memo_recall.sh` output is archived in Slack.
3) Provide a runbook snippet in PR (or link to Langfuse) showing at least one Zap execution + Slack message for memo recall.

Acceptance (PASS/FAIL):
- `automation_specs.md` and `06_zaps_make.yaml` stay in sync (payloads + env vars documented).
- Webhooks hit Slack / Sheets successfully; memo recall script output shared.
- Any edits keep ≤60-word rules intact (check MCP constraints for reference).

PR title: feat(automation): zap alignment + memo cadence
