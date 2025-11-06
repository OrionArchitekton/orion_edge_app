# Pull Request Guidelines

To ensure quality and consistency, every pull request for a deliverable must meet the "PASS" criteria outlined below. Before submitting, please review the checklist for the relevant artifact (canonical copies now live in `orchestrator_kit/`) and confirm that all conditions are met.

## General Process
1.  Create a feature branch for your work.
2.  Complete the deliverable according to the specifications in the [Orchestrator Kit](./chatbot_launch_role_slackkit_v_1.1.md).
3.  Use the checklists below to verify your work.
4.  Submit a pull request with a descriptive title and a summary of the changes.
5.  Link the PR to the relevant issue or task.

---

## Deliverable Checklists

### `01_stack.md` (Agent 1)
- [ ] Web chat is running with an embeddable script and a functional webhook.
- [ ] An optional Messenger path is configured.
- [ ] Zaps 1 (Interactions) and 2 (Unknowns) are active and tested.
- [ ] Google Sheets for `Interactions`, `Unknowns`, `KPI`, and `Prospects` are created and shared.
- [ ] OpenAI API key is capped, stored in a vault, and the key inventory is initialized.

### `02_scope_faq.csv` (Agent 2)
- [ ] A scope statement is present.
- [ ] The CSV contains at least 15 rows with answers of ≤60 words, including sources/notes.
- [ ] All placeholders (e.g., `[STORE]`) are clearly marked for replacement.
- [ ] A list of 10 deferral questions and the safe deferral copy is included.
- [ ] Utility prompts for FAQ expansion and tone calibration are present.

### `03_flow_spec.json` (Agent 3)
- [ ] A greeting and quick reply menu are defined.
- [ ] The pseudo-JSON for the flow is conceptually valid (nodes, variables, transitions).
- [ ] Fallback prompt includes all required guardrails (tone, brevity, safety).
- [ ] The unknown handler language is exactly as specified.
- [ ] A data schema for required fields is defined.
- [ ] Webhook payloads align with `webhook_contracts.json`.

### `04_prompts.md` (Agent 4)
- [ ] An improved v2 fallback prompt and 3 tone variants are provided.
- [ ] A 25-item test suite covering FAQs, edge cases, hostile inputs, and policy tests is included.
- [ ] A scoring rubric and gating (hard FAIL) criteria are defined.
- [ ] A CSV evaluation script template is present.
- [ ] Utility prompts for apologies and answer shortening are included.

### `05_sheets_setup.md` & Google Sheets (Agent 5)
- [ ] Google Sheets are provisioned: `Interactions`, `Unknowns`, `KPI`, `Prospects`.
- [ ] An `automation@agency.com` service account is created and granted editor access.
- [ ] Sheet schemas and column definitions are finalized and documented.
- [ ] Test rows can be successfully written to `Interactions` and `Unknowns`.

### `06_zaps_make.yaml` & Automations (Agent 6)
- [ ] All required Zaps (1-5) are implemented and tested successfully.
- [ ] Google Sheets columns in Zaps match the schemas in `05_sheets_setup.md`.
- [ ] The owner rotation rule for unknown tickets is functional.
- [ ] The KPI digest (Zap 3) is scheduled for Friday at 9 am.
- [ ] Deploy notices (Zap 5) successfully post to the `#ops-bot` channel.

### `slack_channels.md` & Webhooks (Agent 7)
- [ ] The Slack app is installed with all required bot scopes.
- [ ] All project channels have been created.
- [ ] Three webhooks are created and successfully post test messages to `#ops-bot`, `#sales`, and `#incidents`.
- [ ] Core standard documents are pinned in the appropriate channels.
- [ ] The automation service account is created and its credentials are in the vault.

### `08_integrations.md` (Agent 8)
- [ ] The Messenger fallback is implemented and functional.
- [ ] An optional Shopify lead handoff mechanism is documented.
- [ ] All integration points are tested and verified.

### `09_qa_checklist.md` (Agent 9)
- [ ] A test plan and harness fields for logging are defined.
- [ ] A defect logging template (CSV or Sheets) is present.
- [ ] A prioritized defect list with owners and proposed fixes is included.
- [ ] A "Top 10 Improvements" plan is documented.
- [ ] Example bug reports are provided for clarity.
- [ ] A WCAG quick pass has been performed and documented.

### `10_kpi_rollup.md` (Agent 10)
- [ ] Google Sheets tabs for analytics exist with the specified columns and formulas.
- [ ] Zap 1 (Interactions log) and Zap 2 (Unknowns) are confirmed to be populating data correctly.
- [ ] Zap 4 (Weekly KPI) is scheduled and sends a summary to both Slack and email.
- [ ] The weekly summary prompt for the LLM is present.

### `11_sales_playbook.md` (Agent 11)
- [ ] A prospecting sheet CSV header and at least 5 example rows are present.
- [ ] Three distinct follow-up sequences are documented.
- [ ] A utility prompt for generating DM variants is included.
- [ ] A sourcing mini-playbook is documented.
- [ ] A check-in email template with metrics and top-3 unknowns is present.
- [ ] At least three pricing tiers with clear inclusions are defined.
- [ ] Simple agreement bullet-point terms are included.
- [ ] An invoice template (both Markdown table and CSV) is provided.
- [ ] A referral ask utility prompt is included.

### `12_monitoring.md` & `incident_runbook.md` (Agent 12)
- [ ] The `#incidents` channel exists and on-call rotation is noted.
- [ ] The Maintenance Mode message is documented and deployed.
- [ ] A P1 incident drill has been completed and documented.
- [ ] A postmortem template has been used for the last incident drill.

### `governance_security.md`
- [ ] The secrets vault is live and the service account is in use.
- [ ] A key rotation schedule (90 days) is documented.
- [ ] The monthly audit log has been recorded.
- [ ] An alerting mechanism for when tooling costs exceed $30/mo is in place.

### `webhook_contracts.json`
- [ ] The JSON is valid.
- [ ] All fields are correctly populated by the corresponding Zaps.
- [ ] Slack receives payloads that match the defined types.
- [ ] Any URLs included in payloads are resolvable.


