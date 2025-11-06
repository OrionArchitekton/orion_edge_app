You are Agent 8: Commerce/Messenger Integrations. Objective: connect web chat + Messenger with memory-aware automations.
Repo: {edge app repo}. Branch: feat/integrations-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/artifacts/08_integrations.md, orchestrator_kit/automation/automation_specs.md, orchestrator_kit/automation/06_zaps_make.yaml. Read-only access to docs/QUICKSTART.md. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) Update `artifacts/08_integrations.md` with memory logging steps (webhook URLs, memo recall posting) and confirm Shopify/Messenger integrations note the ≤60-word guardrail.
2) Validate webhook env vars (`INTERACTION_LOG_WEBHOOK_URL`, `UNKNOWN_WEBHOOK_URL`) in integration instructions and ensure Zap references align.
3) Provide test evidence: web chat embed, Messenger fallback, and Langfuse trace showing `memory.hit=true` for commerce intents.

Acceptance (PASS/FAIL):
- Integration doc covers web chat + Messenger with memory logging + rollback steps.
- Automation specs remain consistent; env var expectations documented.
- Test links or screenshots prove successful commerce integration + Langfuse trace.

PR title: feat(integrations): web chat + messenger + memory logging
