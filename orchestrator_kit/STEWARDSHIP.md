# Orchestrator Stewardship Guidelines

These rules keep our broadened orchestrator shop aligned as new agents and automations come online.

## Ownership & Review

- **Primary owners:**
  - Governance docs (`guides/`) — Agent 0
  - Prompts (`prompts/`) — Agent 4 (tone) + Agent 6 (automation impact)
  - Artifacts (`artifacts/`) — Respective DRI per `guides/roles_matrix.md`
  - Automation (`automation/`) — Agent 6 (Zap/Make) + Agent 12 (SRE) for deploy approval
- **Review flow:**
  1. Draft changes in `workspaces/` or feature branches.
  2. Run relevant checklists (`orchestrator_kit/.checklist.yml`).
  3. Tag owners above plus Agent 0 on PRs touching guardrails.
  4. Include “What/Why/Checks/Preview links” in PR body.

## Directory Expectations

- `artifacts/` holds final, approved copies only. Archive superseded versions in the PR, not the repo.
- `prompts/` mirrors the live agent instructions. Keep references to canonical artifact paths up-to-date when renaming files.
- `workspaces/` is optional scratch space; delete temp files before merging.
- `automation/` changes must note required env vars, rate limits, and slack destinations in `automation_specs.md`.
- `marketing/` contains shared positioning docs; large marketing kits remain in `docs/kit/marketing/`.

## CI & Guardrails

- GitHub workflow `.github/workflows/kit.yml` still validates FAQ converters; regenerate CSVs after editing `docs/kit/faqpacks/*.json`.
- Use scripts in `apply_orion_edge_safe_patch.sh` / `apply_orion_edge_one_step_patch.sh` to enforce guardrail sections when bootstrapping new work.
- Keep `.checklist.yml` in sync if new critical artifacts are added.
- After updating prompts or automation, sanity-check the corresponding n8n flows and MCP tools listed in `automation/README.md`.

## Change Log Discipline

- Add a short “Changelog” bullet list at the top of any artifact when the update materially changes agent behavior.
- Cross-link related updates (e.g., if `04_prompts.md` changes, reference the PR in `automation_specs.md` and `message_standards.md`).
- When deprecating assets, replace the file contents with a relocation notice instead of deleting outright, unless legal/compliance requires removal.

## Escalations

- Policy or guardrail concerns → `guides/message_standards.md` owner (Agent 4) and Agent 0.
- Automation regressions → Agent 6 + Agent 12; post incident summary to `#ops-bot` and file in `guides/incident_runbook.md`.
- Pricing/positioning changes → Agent 11 + marketing lead; synchronize with `marketing/positioning_pack.md`.

Adhering to these stewardship rules keeps the orchestrator kit coherent as we broaden beyond chatbot-only engagements.

## Guardrail Updates

- **Messaging guardrails** (`guides/message_standards.md`, `artifacts/04_prompts.md`)
  - Require sign-off from Agent 4 *and* Agent 6.
  - Update affected prompts and automation specs in the same PR or queue follow-up tasks with owners assigned.
- **Automation guardrails** (`automation/automation_specs.md`, `automation/06_zaps_make.yaml`, `automation/webhook_contracts.json`)
  - Tag Agent 6 + Agent 12; replay representative payloads through staging Zaps/n8n flows before merge.
  - Document new env vars or rate limits in the PR description and update `MANIFEST.md` if footprint expands.
- **Operational guardrails** (`artifacts/09_qa_checklist.md`, `artifacts/10_kpi_rollup.md`, `artifacts/12_monitoring.md`, `guides/incident_runbook.md`)
  - Loop in Agent 9 + Agent 12; after merge, post summary + next steps in `#analytics-kpi` or `#incidents`.
- **Security & governance guardrails** (`guides/governance_security.md`, `.checklist.yml`, `guides/roles_matrix.md`)
  - Agent 0 approves; ensure vault instructions / rotation timelines are updated in the shared security runbook.

## PR Checklists by Change Type

| Change Type | Required Reviewers | Must Reference | Verification Steps |
| --- | --- | --- | --- |
| Prompt or messaging update | Agents 4 & 6 | `guides/message_standards.md`, `artifacts/04_prompts.md` | Run 5x guardrail tests, confirm ≤60 words | 
| Zap / automation update | Agents 6 & 12 | `automation/automation_specs.md`, `automation/06_zaps_make.yaml`, `automation/webhook_contracts.json` | Replay sample payloads, validate n8n schedule output |
| Governance doc change | Agent 0 + relevant DRI | `guides/roles_matrix.md`, `.checklist.yml` | Ensure `MANIFEST.md` + `STRUCTURE.md` remain accurate |
| Analytics / KPI change | Agents 10 & 6 | `artifacts/10_kpi_rollup.md`, `automation/automation_specs.md` | Run KPI Zap in staging; confirm Slack + email digests |
| Security policy change | Agents 0 & 12 | `guides/governance_security.md` | Verify vault updates + run rotation checklist |

## Stewardship Checklist Before Merge

1. Update `MANIFEST.md` if canonical paths or guardrail owners change.
2. Confirm `STRUCTURE.md` still reflects the directory layout after your edits.
3. Re-run `.github/workflows/kit.yml` when FAQs, scripts, or automation schemas move.
4. Post a `[HANDOFF]` message in `#proj-chatbot` (see `guides/message_standards.md`) once the PR is merged.


