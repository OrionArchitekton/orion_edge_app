# Orchestrator Deliverable Inventory

The orchestrator now oversees a broader "business shop" scope. This manifest captures every asset we actively maintain, the canonical location inside `orchestrator_kit/`, any shadow copies that still exist elsewhere in the repo, and—most importantly—where guardrails are introduced so teams know where policy lives.

## Canonical Asset Table

| Category | Artifact | Purpose | Canonical Path | Other Copies / References | Guardrail Coverage |
| --- | --- | --- | --- | --- | --- |
| Orientation | `README.md` | Landing page for the orchestrator hub + guardrail highlights | `orchestrator_kit/README.md` | Linked from `00_README.md`, legacy launch kit | Points to every guardrail document; onboarding instructions |
| Orientation | `STRUCTURE.md` | Directory blueprint & migration map | `orchestrator_kit/STRUCTURE.md` | Supersedes scattered notes in `docs/kit` | Calls out guardrail surfaces in each directory |
| Orientation | `MANIFEST.md` | This inventory of canonical artifacts | `orchestrator_kit/MANIFEST.md` | N/A | Summarises where guardrails live per artifact |
| Orientation | `STEWARDSHIP.md` | Contribution & review standards | `orchestrator_kit/STEWARDSHIP.md` | Replaces ad-hoc PR notes | Defines ownership for guardrail updates + escalation paths |
| Orientation | `.checklist.yml` | Automated checklist enforced pre-merge | `orchestrator_kit/.checklist.yml` | Referenced in PR templates | Enforces prompt word limits, sheet column ranges |
| Governance | `guides/roles_matrix.md` | Ownership, cadence, handoffs | `orchestrator_kit/guides/roles_matrix.md` | Embedded snapshot inside legacy launch kit | Governance guardrails (DRI, approvals, RACI) |
| Governance | `guides/message_standards.md` | Customer messaging macro + safe phrasing | `orchestrator_kit/guides/message_standards.md` | Referenced by prompts, automation specs | Primary customer-facing guardrails (≤60 words, deferral copy, no PII) |
| Governance | `guides/governance_security.md` | Access policy & audit cadence | `orchestrator_kit/guides/governance_security.md` | Legacy references in launch kit | Security guardrails (vault usage, rotation, cost alerts) |
| Governance | `guides/incident_runbook.md` | Incident classification & response | `orchestrator_kit/guides/incident_runbook.md` | Linked from automation README | Incident guardrails (maintenance mode, escalations, SLOs) |
| Governance | `guides/slack_channels.md` | Channel architecture & webhook bootstrap | `orchestrator_kit/guides/slack_channels.md` | Derived from Agent 7 workspace | Webhook validation, pin requirements, service accounts |
| Artifacts | `artifacts/01_stack.md` | Stack & platform decisions | `orchestrator_kit/artifacts/01_stack.md` | Mentioned in prompts, launch kit | Budget guardrail, policy deferral statement |
| Artifacts | `artifacts/02_scope_faq.csv` | Core FAQ dataset | `orchestrator_kit/artifacts/02_scope_faq.csv` | Vertical variants under `docs/kit/faqpacks/` | Schema enforces ≤60 word answers and source attribution |
| Artifacts | `artifacts/03_flow_spec.json` | Flow skeleton + routing | `orchestrator_kit/artifacts/03_flow_spec.json` | Referenced by automation and prompts | Unknown handling, Messenger footer, logging rules |
| Artifacts | `artifacts/04_prompts.md` | System prompts + fallback variants | `orchestrator_kit/artifacts/04_prompts.md` | Excerpts in launch kit | Primary LLM guardrails (tone, length, deferral) |
| Artifacts | `artifacts/05_sheets_setup.md` | Data schemas for Google Sheets | `orchestrator_kit/artifacts/05_sheets_setup.md` | Referenced in automation specs | Data retention guardrails, redaction expectations |
| Artifacts | `artifacts/07_slack_channels.md` | Execution checklist for Agent 7 | `orchestrator_kit/artifacts/07_slack_channels.md` | Complements `guides/slack_channels.md` | Webhook verification + pins |
| Artifacts | `artifacts/08_integrations.md` | Shopify/Messenger integration plan | `orchestrator_kit/artifacts/08_integrations.md` | Mentioned in prompts | Messenger fallback policy |
| Artifacts | `artifacts/09_qa_checklist.md` | QA + compliance checklist | `orchestrator_kit/artifacts/09_qa_checklist.md` | Summary in launch kit | WCAG quick pass, policy tests, regression gates |
| Artifacts | `artifacts/10_kpi_rollup.md` | Weekly KPI + digest prompt | `orchestrator_kit/artifacts/10_kpi_rollup.md` | Referenced by automation flows | Reporting cadence guardrails, ≤120 word digest |
| Artifacts | `artifacts/11_sales_playbook.md` | Sales ops + pricing scripts | `orchestrator_kit/artifacts/11_sales_playbook.md` | Legacy copies in agent workspace (removed) | Messaging guardrails for outbound comms |
| Artifacts | `artifacts/12_monitoring.md` | Monitoring & SRE checklist | `orchestrator_kit/artifacts/12_monitoring.md` | Linked from incident runbook | On-call expectations, maintenance mode |
| Artifacts | `marketing/13_pull_site_strategy.md` | Pull-site GTM plan | `orchestrator_kit/marketing/13_pull_site_strategy.md` | Marketing decks in `docs/kit/marketing/` | Messaging consistency guardrails |
| Artifacts | `marketing/positioning_pack.md` | Positioning narrative | `orchestrator_kit/marketing/positioning_pack.md` | Slides in `docs/kit/marketing/` | Tone alignment, promise guardrails |
| Automation | `automation/README.md` | Map between automation assets & docs | `orchestrator_kit/automation/README.md` | N/A | Lists guardrail touchpoints for automation |
| Automation | `automation/automation_specs.md` | Zap/Make contract | `orchestrator_kit/automation/automation_specs.md` | Pointer in `docs/kit/automation_specs.md` | Budget cap, retries, PII redaction |
| Automation | `automation/06_zaps_make.yaml` | Detailed automation blueprint | `orchestrator_kit/automation/06_zaps_make.yaml` | Former `.bak` removed, prompts reference | Redaction patterns, owner rotation |
| Automation | `automation/webhook_contracts.json` | Payload schema for Slack/Zap flows | `orchestrator_kit/automation/webhook_contracts.json` | Referenced in prompts, QA checklist | Schema guardrails for automation payloads |
| Automation | `automation/cloud_workers/*` | Cloudflare Workers, Supabase schema | `orchestrator_kit/automation/cloud_workers/` | N/A | Runtime guardrails (env vars, scope enforcement) |
| Automation | `automation/src/index.ts` | Typescript entrypoint mirroring worker logic | `orchestrator_kit/automation/src/index.ts` | Old copy under `orchestrator_kit/src/` removed | Enforces middleware, CORS guardrails |
| Automation | `n8n/flows/*.json` | Low-code orchestration (content, KPI, inbox) | `n8n/flows/` | Documented in automation README | Scheduling & escalation guardrails |
| Automation | `mcp/tools/*.yaml` | MCP nightly/ops tasks | `mcp/tools/` | Documented in automation README | Rate limiting, guardrail references per tool |
| Automation | `jobs/memory/consolidate.py` | FAQ/transcript consolidation job | `jobs/memory/consolidate.py` | Referenced in automation README | Data hygiene guardrails |
| Prompts | `prompts/agent_00_prompt.md`–`agent_12_prompt.md` | Live agent instructions | `orchestrator_kit/prompts/` | Historical copies deleted from `agent_workspaces/` | Each prompt points to guardrail docs (message standards, automation specs) |
| Prompts | `prompts/start_work_template.md` | Base template for new agent work | `orchestrator_kit/prompts/start_work_template.md` | Legacy copy in root removed | Instructs teams to cite guardrail docs before editing |
| Prompts | `prompts/bonus_prompts.md` | Extra tone + fallback variants | `orchestrator_kit/prompts/bonus_prompts.md` | Linked in launch kit | Reinforces LLM guardrails |
| Collaboration | `workspaces/README.md` | Guidance for transient drafting | `orchestrator_kit/workspaces/README.md` | N/A | Explicitly states finals must live in artifacts/ |
| Legacy | `docs/kit/chatbot_launch_role_slackkit_v_1.1.md` | Historic launch handbook | `docs/kit/chatbot_launch_role_slackkit_v_1.1.md` | Links updated to new canonical paths | Preserves historical guardrail context |
| Legacy | `docs/kit/faqpacks/*.json` & `generated/*.csv` | Vertical FAQ packs | `docs/kit/faqpacks/` | Consumed via `scripts/faqpack_to_csv.js` | Provide source data but defer to core FAQ guardrails |

## Guardrail Entry Points

1. **Customer messaging guardrails** — `orchestrator_kit/guides/message_standards.md`, echoed in `artifacts/04_prompts.md` and every agent prompt.
2. **Automation guardrails** — `orchestrator_kit/automation/automation_specs.md`, `automation/06_zaps_make.yaml`, and `automation/webhook_contracts.json` (schemas + retry policy).
3. **Operational/SRE guardrails** — `orchestrator_kit/guides/incident_runbook.md`, `artifacts/12_monitoring.md`, `artifacts/09_qa_checklist.md`, and `artifacts/10_kpi_rollup.md` for monitoring cadence.
4. **Security & governance guardrails** — `orchestrator_kit/guides/governance_security.md`, `guides/roles_matrix.md`, and `.checklist.yml` for ownership + CI gates.

> When in doubt, start with `orchestrator_kit/README.md` → it links to every guardrail-heavy artifact listed above.

