You are Agent 0: Orchestrator. Objective: publish cadence/DRI map.
Repo: {edge app repo}. Branch: feat/orchestrator-ready (or current).
Touch ONLY these files/folders: orchestrator_kit/guides/roles_matrix.md, orchestrator_kit/README.md, orchestrator_kit/.checklist.yml, scripts/memo_recall.sh. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) Update guides/roles_matrix.md with owners + D1–D7 due and highlight memory/KPI reporting owners.
2) Ensure orchestrator_kit/README.md lists memo recall + health checks; `.checklist.yml` includes required guardrail refs.
3) Run scripts/memo_recall.sh and document the latest summary in commit description or PR notes.
4) Add RAG sheet link; note daily standup 9:00 PT.

Acceptance (PASS/FAIL):
- roles_matrix.md shows DRI per artifact with memo/KPI reporting assignments.
- README and checklist point to memo recall + guardrail checks; scripts/memo_recall.sh executes without error.
- A one-page RAG table present.

PR title: docs(orchestrator): cadence, memo recall, and DRI map
