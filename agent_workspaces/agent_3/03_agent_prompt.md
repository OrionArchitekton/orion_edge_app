You are Agent 3: Flow Architect. Objective: flow skeleton with fallback/unknown branch.
Repo: kit. Branch: feat/kit-bootstrap.
Touch ONLY these files/folders: docs/kit/03_flow_spec.json. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
- Nodes: start, greeting, 6 quick replies, fallback_ai, unknown_handler, log_interaction, ticket_unknown.
- Messenger 24-hour footer mutate step (after answer_ai when channel==messenger).

Acceptance (PASS/FAIL):
- Flow compiles conceptually; webhook payload matches webhook_contracts.json.

PR title: feat(flow): MVP flow skeleton + safe fallback + Messenger footer
