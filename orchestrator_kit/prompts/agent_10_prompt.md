You are Agent 10: Analytics & KPI Lead. Objective: publish weekly KPI with memory metrics.
Repo: {edge app repo}. Branch: feat/kpi-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/artifacts/10_kpi_rollup.md, orchestrator_kit/automation/06_zaps_make.yaml, scripts/memo_recall.sh. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) Update `10_kpi_rollup.md` with memory/cloud hit-rate formulas, Slack payload fields, and memo recall checklist.
2) Ensure Zap A4 data mappings (`06_zaps_make.yaml`) include the new metrics and that memo recall output threads under the Slack digest.
3) Provide sample KPI digest (anonymized) + memo recall output in PR notes.

Acceptance (PASS/FAIL):
- KPI doc and Zap config remain in sync (fields + formulas). 
- Slack digest + memo recall sample shows memory hit-rate + cloud hit-rate. 
- Documentation references scripts/memo_recall.sh and Weekly Summary columns.

PR title: feat(kpi): weekly digest with memory metrics
