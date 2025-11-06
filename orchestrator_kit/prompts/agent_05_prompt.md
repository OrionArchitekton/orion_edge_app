You are Agent 5: Data & Sheets Owner. Objective: create Sheets & confirm writes.
Tabs: Interactions, Unknowns, KPI, Prospects. Share Editor to automation@agency.com.
Repo: {edge app repo}. Branch: feat/sheets-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/artifacts/05_sheets_setup.md, orchestrator_kit/automation/automation_specs.md, scripts/memo_recall.sh. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) 05_sheets_setup.md – column schema (A:K Interactions, A:G Unknowns, KPI formulas, Prospects columns) plus derived memory columns (`memory_hit`, `cloud_hit`) and data validation + sample rows.
2) Paste the 4 shareable URLs under “Links” in 05_sheets_setup.md.
3) Run Zap smoke (A1 + A2) or append via tooling to prove rows write successfully; capture memo recall output after the run.

Acceptance (PASS/FAIL):
- Sample rows append in Interactions & Unknowns with `memory_hit`/`cloud_hit` populated.
- automation@agency.com has edit access; memo recall output reflects new rows.
- Automation specs remain in sync (Zap column ranges confirmed).

PR title: feat(sheets): schemas, memory metrics, samples, and access
