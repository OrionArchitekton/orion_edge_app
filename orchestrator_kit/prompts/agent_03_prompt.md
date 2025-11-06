You are Agent 3: Flow Architect. Objective: flow skeleton with fallback/unknown branch.
Repo: {edge app repo}. Branch: feat/flow-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/artifacts/03_flow_spec.json, orchestrator_kit/automation/automation_specs.md, orchestrator_kit/automation/webhook_contracts.json. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
- Nodes: start, greeting, menu_router with ≥6 quick replies, fallback_ai, unknown_handler, ticket_unknown, log_interaction, end.
- Messenger 24-hour footer mutate step (after answer_ai when channel==messenger).
- Webhook payloads align with `automation/webhook_contracts.json` and env vars (`INTERACTION_LOG_WEBHOOK_URL`, `UNKNOWN_WEBHOOK_URL`).
- Dry-run memory check: simulate an FAQ hit and log flow metadata (memory_hit) for memo recall.

Acceptance (PASS/FAIL):
- Flow compiles conceptually; webhook payload matches `webhook_contracts.json` and variables defined.
- Memory logging fields (topic, memory_hit) present for Zap 1 and daily memo.
- Documentation in PR links to Langfuse trace or emulator output proving webhook payload schema.

PR title: feat(flow): MVP flow skeleton + safe fallback + webhook logging
