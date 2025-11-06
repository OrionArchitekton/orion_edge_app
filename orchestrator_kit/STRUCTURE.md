# Target Repository Structure

The orchestrator now supports a broader operations shop (multiple brands, shared automations, multi-agent workflows). This structure ensures contributors always know where the canonical artifact lives and where guardrails are injected. Paths are relative to the repository root.

## Scope & Guardrail Primer

- *Business shop remit:* customer messaging, sales enablement, automation, incident response, marketing collateral, and analytics across multiple storefronts.
- *Fixed agent identities:* Agent numbering and responsibilities remain unchanged (see `guides/roles_matrix.md`); only their deliverable footprint has expanded.
- *Guardrail injection points:* messaging (`guides/message_standards.md` + `artifacts/04_prompts.md`), automation (`automation/automation_specs.md` + `automation/06_zaps_make.yaml`), operations (`artifacts/09_qa_checklist.md`, `artifacts/12_monitoring.md`, `guides/incident_runbook.md`), and governance (`guides/governance_security.md`, `.checklist.yml`). Every directory below calls out the relevant guardrail sources so editors know what to reference before making changes.

```
orchestrator_kit/
  README.md                # high-level guide + quick links
  MANIFEST.md              # inventory of canonical assets (generated above)
  STRUCTURE.md             # this file
  artifacts/               # final, approved deliverables (D0–D7 outputs, datasets)
    01_stack.md
    02_scope_faq.csv
    ...
  automation/              # machine-consumable specs & worker code
    automation_specs.md
    06_zaps_make.yaml
    webhook_contracts.json
    cloud_workers/
    ...
  guides/                  # governance + guardrail references
    roles_matrix.md
    message_standards.md
    incident_runbook.md
    governance_security.md
    slack_channels.md
  prompts/                 # agent prompts + reusable prompt libraries
    agent_0_prompt.md
    agent_1_prompt.md
    ...
    bonus_prompts.md
  workspaces/              # active drafting areas per agent (transient notebooks, scratch pads)
    agent_1/
    agent_2/
    ...
  marketing/               # positioning + GTM collateral tied to orchestrator deliverables
    positioning_pack.md
    13_pull_site_strategy.md

docs/kit/                  # legacy launch kit; will link into orchestrator_kit and retain marketing assets
  marketing/
  niche_pages/
  faqpacks/

automation surfaces:
  n8n/flows/               # operationalized flows (documented via link-automation task)
  mcp/tools/
  scripts/
```

## Directory Ownership & Guardrails

| Directory | Owner(s) | Primary Guardrails |
| --- | --- | --- |
| `orchestrator_kit/artifacts/` | DRIs listed per artifact in `guides/roles_matrix.md` | LLM prompt guardrails, QA/SRE checklists, reporting cadence |
| `orchestrator_kit/guides/` | Agent 0 (governance) + named collaborators | Messaging macros, governance policy, security rules, incident response |
| `orchestrator_kit/automation/` | Agent 6 + Agent 12 | Budget caps, retry policy, payload schemas, worker scope |
| `orchestrator_kit/prompts/` | Agent 4 (tone) + Agent 6 (automation impacts) | ≤60-word enforcement, deferral phrasing, start-work template |
| `orchestrator_kit/workspaces/` | Any agent (transient) | No guardrails—finals must graduate to `artifacts/` |
| `orchestrator_kit/marketing/` | Agent 11 + marketing lead | Messaging consistency, value prop guardrails |
| `docs/kit/` | Agent 0 (historical) | Legacy reference only; point readers to new canonical paths |
| `n8n/flows/`, `mcp/tools/`, `jobs/` | Agent 6 (automation) + Agent 12 (SRE) | Scheduling, escalation hooks, nightly safeguards |

## Migration Notes

| Category | Examples | Former Location(s) | Target Directory | Action |
| --- | --- | --- | --- | --- |
| Final deliverables | `01_stack.md`, `03_flow_spec.json`, `09_qa_checklist.md` | `agent_workspaces/agent_*/*` | `orchestrator_kit/artifacts/` | Move files; keep filenames; update references |
| Automation configs | `automation_specs.md`, `06_zaps_make.yaml`, `webhook_contracts.json`, `cloud_workers/*` | `agent_workspaces/`, `orchestrator_kit/cloud_workers/` | `orchestrator_kit/automation/` | Consolidate specs + worker assets; delete `.bak` backups after verification |
| Governance guides | `roles_matrix.md`, `message_standards.md`, `incident_runbook.md`, `governance_security.md`, `slack_channels.md` | `agent_workspaces/` | `orchestrator_kit/guides/` | Move and link to guardrail-heavy sections |
| Prompts | `agent_*/*_agent_prompt.md`, `bonus_prompts.md` | `agent_workspaces/agent_*/` + root | `orchestrator_kit/prompts/` | Rename to `agent_<n>_prompt.md`; update instructions |
| Working drafts | ad-hoc notes, to-be-added scratch docs | `agent_workspaces/agent_*/` (mixed with finals today) | `orchestrator_kit/workspaces/agent_*/` | Create README placeholders; future drafts live here, separate from finals |
| Marketing + GTM | `positioning_pack.md`, `13_pull_site_strategy.md`, marketing kits under `docs/kit` | `agent_workspaces/`, `docs/kit/marketing/` | `orchestrator_kit/marketing/` (bridged to `docs/kit/marketing`) | Move shared positioning docs, keep large marketing packs in place but cross-link |
| Data packs | FAQ CSV/JSON, generated assets | `agent_workspaces/agent_2/`, `docs/kit/faqpacks/generated` | `orchestrator_kit/artifacts/` (core), `docs/kit/faqpacks/` (vertical packs) | Sync canonical CSV into artifacts, leave generated packs under `docs/kit/faqpacks/` |

## Guardrail Visibility Plan

- **Customer messaging** — `guides/message_standards.md` + `artifacts/04_prompts.md`; every agent prompt references these macros and ≤60-word rules.
- **Automation & data** — `automation/automation_specs.md`, `automation/06_zaps_make.yaml`, `automation/webhook_contracts.json`; mirrored inside `n8n/flows` and MCP tools via the automation README.
- **Operational resilience** — `guides/incident_runbook.md`, `artifacts/12_monitoring.md`, `artifacts/09_qa_checklist.md`; tie directly into incident Slack channels and KPI digests.
- **Security & governance** — `guides/governance_security.md`, `guides/roles_matrix.md`, `orchestrator_kit/.checklist.yml`; enforce access control, rotation, and CI checks.

All cross-references (agent prompts, README files, CI scripts) are being updated during migration so contributors always land on the canonical path above. Legacy files under `docs/kit/` will remain as pointers until downstream documentation is refreshed.

## Migration Status (Nov 2025)

- ✅ Files moved from `agent_workspaces/` into `orchestrator_kit/{artifacts|prompts}` with pointer README left behind.
- ✅ Automation assets consolidated under `orchestrator_kit/automation/` (including Cloudflare worker code and Supabase schema).
- ✅ Governance docs consolidated under `orchestrator_kit/guides/` with updated links in `docs/kit/`.
- 🔄 Legacy launch handbook (`docs/kit/chatbot_launch_role_slackkit_v_1.1.md`) still references historical narrative; keep until marketing revamp completes.
- 🔄 **Legacy bridges:** `agents_registry.yaml` and `agent_workspaces/docs_organizer/boot_prompt.sh` intentionally point to `agent_workspaces/` paths temporarily. These are compatibility shims until boot tooling migrates to `orchestrator_kit/` paths. Comments in these files note the future swap.
- 🔄 Run `scripts/cleanup_agent_workspaces.sh` once all tooling points to `orchestrator_kit/` to delete the compatibility shims.


