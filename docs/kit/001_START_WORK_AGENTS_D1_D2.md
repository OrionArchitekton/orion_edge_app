# Operator → Agent Start Work (Day 1–2)

Body must list “What/Why/Checks/Preview links.”

---

## Day 1 — Kickoff

### Agent 7 — Slack Ops & Bot Engineer (channels + webhooks)
You are Agent 7: Slack Ops & Bot Engineer. Objective: workspace online + webhooks live.
Repo: {repo}. Branch: feat/kit-bootstrap (or current).
Touch ONLY these files/folders: `orchestrator_kit/slack_channels.md`, `orchestrator_kit/webhook_contracts.json`.

Deliverables
1) `slack_channels.md` – mark webhook URLs (mask tokens), and paste channel list + pins.
2) `webhook_contracts.json` – present in repo and shared with Agent 6.
3) Test posts – send “hello from Agent 7” to each channel (#ops-bot, #sales, #incidents).

Acceptance (PASS/FAIL)
- Webhook test messages appear in #ops-bot/#sales/#incidents.
- Pins visible in #proj-chatbot.
- `webhook_contracts.json` available to Agent 6.

PR title
chore(slack): channels + 3 webhooks + pins

---

### Agent 1 — Stack & Platform Lead (01_stack.md + cost guardrail)
You are Agent 1: Stack & Platform Lead. Objective: pick web chat + LLM under $0–$30 and write 01_stack.md.
Repo: {edge app repo}. Branch: feat/kit-bootstrap (or current).
Touch ONLY these files/folders: `docs/kit/01_stack.md`.

Deliverables
1) `01_stack.md` – tool decisions (Landbot primary, Typebot fallback, OpenAI gpt-4o-mini), env var list, spend cap & math.
2) OpenAI usage cap screenshot URL (or note) and model defaults (temp 0.4; ≤60-word replies).
3) Quick embed instruction (Shopify/Wix) matching Agent 8 wording.

Acceptance (PASS/FAIL)
- `01_stack.md` includes tools + env + cost < $30.
- Defers card/PII handling to secure checkout (policy line present).

PR title
feat(stack): 01_stack with tools, env, and cost math

---

### Agent 5 — Data & Sheets Owner (create the 4 tabs)
You are Agent 5: Data & Sheets Owner. Objective: create Sheets & confirm writes.
Tabs: Interactions, Unknowns, KPI, Prospects. Share Editor to automation@agency.com.
Repo: kit. Branch: feat/kit-bootstrap.
Touch ONLY these files/folders: `docs/kit/05_sheets_setup.md`.

Deliverables
1) `05_sheets_setup.md` – column schema (A:K Interactions, A:G Unknowns, KPI formulas, Prospects columns), data validation + sample rows.
2) Paste the 4 shareable URLs under “Links” in `05_sheets_setup.md`.

Acceptance (PASS/FAIL)
- Sample rows append in Interactions & Unknowns.
- automation@agency.com has edit access.

PR title
feat(sheets): 4 tabs, schemas, samples, and access

---

### Agent 0 — Orchestrator (publish cadence/DRI)
You are Agent 0: Orchestrator. Objective: publish cadence/DRI map.
Repo: kit. Branch: feat/kit-bootstrap.
Touch ONLY these files/folders: `orchestrator_kit/roles_matrix.md`.

Deliverables
1) Update `roles_matrix.md` with owners + D1–D7 due.
2) Add RAG sheet link.
3) Note daily standup 9:00 PT in #proj-chatbot.

Acceptance (PASS/FAIL)
- `roles_matrix.md` shows DRI per artifact; handoffs listed.
- A one-page RAG table present.

PR title
docs(orchestrator): cadence & DRI map

---

## Day 2 — KB + Flow + Prompts

### Agent 2 — Scope & FAQ Curator
You are Agent 2. Objective: seed 20 concise FAQs.
Repo: kit. Branch: feat/kit-bootstrap.
Touch ONLY these files/folders: `docs/kit/02_scope_faq.csv`.

Deliverables
- 20 rows (Q, A ≤60 words, Tone, Source/Notes).
- Note referencing vertical packs: `docs/kit/faqpacks/*.json` and `scripts/faqpack_to_csv.js`.

Acceptance (PASS/FAIL)
- 20 valid rows; explicit placeholders [RETURNS_WINDOW], etc.

PR title
feat(faq): seed 20 core Q&As and link vertical packs

---

### Agent 3 — Flow Architect
You are Agent 3. Objective: flow skeleton with fallback/unknown branch.
Repo: kit. Branch: feat/kit-bootstrap.
Touch ONLY these files/folders: `docs/kit/03_flow_spec.json`.

Deliverables
- Nodes: start, greeting, 6 quick replies, fallback_ai, unknown_handler, log_interaction, ticket_unknown.
- Messenger 24-hour footer mutate step (after answer_ai when channel==messenger).

Acceptance (PASS/FAIL)
- Flow compiles conceptually; webhook payload matches `webhook_contracts.json`.

PR title
feat(flow): MVP flow skeleton + safe fallback + Messenger footer

---

### Agent 4 — Prompt & Tone Designer
You are Agent 4. Objective: ≤60-word guardrails + fallbacks.
Repo: kit. Branch: feat/kit-bootstrap.
Touch ONLY these files/folders: `docs/kit/04_prompts.md`.

Deliverables
- Guardrails block (≤60 words; KB-only; exact deferral; domain replies from faqpacks; no card data).
- Fallback system prompt v2 + 3 tone variants.

Acceptance (PASS/FAIL)
- Guardrails present; deferral phrase EXACT everywhere.

PR title
feat(prompts): guardrails + fallback v2 + tone variants
