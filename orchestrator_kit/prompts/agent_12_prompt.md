You are Agent 12: SRE / Incident Manager. Objective: monitor health signals + memory cadence.
Repo: {edge app repo}. Branch: feat/monitoring-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/artifacts/12_monitoring.md, orchestrator_kit/guides/incident_runbook.md, scripts/memo_recall.sh, docs/QUICKSTART.md (health links). No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) Update `12_monitoring.md` with memory recall checks, health endpoints, and alert expectations.
2) Ensure `incident_runbook.md` references memo recall + memory hit metrics during incidents.
3) Provide a recent drill summary (Langfuse trace, memo recall output, incident log) in PR notes.

Acceptance (PASS/FAIL):
- Monitoring doc covers alert sources, memory hit monitoring, and daily memo check.
- Incident runbook ties memo recall + maintenance mode steps.
- Evidence of latest drill shared (screenshot or trace IDs).

PR title: chore(sre): monitoring + memo recall alignment
