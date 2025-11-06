### Agent Map (D0–D7 & M1–M3)

| Agent | Role                              | Key Deliverables (files)                                                | Inputs                   | Outputs / Handoffs                    | DRI   | D0–D7 Due                                                                     | M1–M3 Milestones                                                  |
| ----- | --------------------------------- | ----------------------------------------------------------------------- | ------------------------ | ------------------------------------- | ----- | ----------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| 0     | Orchestrator & Governance         | roles_matrix.md, message_standards.md, governance_security.md, README.md, scripts/memo_recall.sh | scope, constraints       | approvals, cadence, audits, memo recall | A/DRI | D1: Publish cadence • D4: Schedule demo • D6: Run demo • D7: Draft M1 plan • Daily memo 08:00 | M1: audit #1 • M2: keys rotation • M3: ROI/governance review      |
| 1     | Stack & Platform Lead             | 01\_stack.md (web chat, LLM, hosting)                                   | constraints, costs       | tool choices, env vars                | 1     | D1: Select web chat • D2: OpenAI config & webhooks • D7: Cost check           | M1: A/B infra • M2: cost review • M3: upgrade recs                |
| 2     | FAQ & Knowledge Curator           | 02\_scope\_faq.csv                                                      | client docs, transcripts | scoped FAQs, intents, policies        | 2     | D2: Draft 20 FAQs • D6: Add +20 FAQs from demo                                | M1: topic clusters • M2: gap analysis • M3: archive policy        |
| 3     | Flow Architect                    | 03\_flow\_spec.json (states, routes, fallbacks)                         | 01,02                    | flow JSON + fallback map              | 3     | D2: Skeleton & unknown path • D4: v0.1 • D7: v0.1.1 fixes                     | M1: A/B variants • M2: edge‑case coverage • M3: refactor          |
| 4     | Prompt & Tone Designer            | 04\_prompts.md (system, tools, safety)                                  | 02,03                    | constrained prompts (≤60 words)       | 4     | D2: Tone guide & length guard • D4: Live prompts                              | M1: library v2 • M2: guardrails refine • M3: style pack           |
| 5     | Data & Sheets Owner               | 05\_sheets\_setup.md + GSheets (Interactions, Unknowns, KPI, Prospects) | 01,03,04                 | sheet schemas, access                 | 5     | D1: Provision sheets • D2: Finalize schemas • D5: Validate Prospects sheet    | M1: pivot views • M2: retention policy • M3: export routine       |
| 6     | Automation Engineer (Zapier/Make) | automation\_specs.md, 06\_zaps\_make.yaml                               | 01–05                    | Zaps/Scenarios 1–5 live               | 6     | D3: Zap 1–2 • D4: Zap 5 • D5: Zap 4 • D7: Zap 3                               | M1: retries/queues • M2: cost caps • M3: observability            |
| 7     | Slack Ops & Bot Engineer          | slack\_channels.md, webhook\_contracts.json                             | 01,06                    | app, scopes, webhooks, pins           | 7     | D1: Workspace, app, webhooks, pins • D3: Publish webhook\_contracts.json      | M1: slash cmds • M2: file uploads • M3: archiving rules           |
| 8     | Commerce/Messenger Integrations   | 08\_integrations.md (Shopify/Messenger)                                 | 01,03                    | opt‑in flows, Messenger tag use       | 8     | D5: Messenger fallback & Shopify handoff                                      | M1: cart events • M2: order lookup proxy • M3: channel compare    |
| 9     | QA, Compliance & Accessibility    | 09\_qa\_checklist.md                                                    | 02,03,04                 | test cases, WCAG check, policy checks | 9     | D3: smoke tests • D4: WCAG quick pass • D6: dry‑run                           | M1: WCAG deep pass • M2: privacy drill • M3: red‑team replay      |
| 10    | Analytics & KPI Lead              | 10\_kpi\_rollup.md                                                      | 05,06                    | KPI queries & weekly summary          | 10    | D4: KPI rollups • D7: Send KPI summary                                        | M1: trends viz • M2: cohort cuts • M3: ROI model                  |
| 11    | Sales Ops & Client Success        | 11\_sales\_playbook.md                                                  | 05                       | pipeline, replies, demos              | 11    | D5: Sales templates • D6: Prospect flow & follow-ups                          | M1: objection handling • M2: outreach cadences • M3: case studies |
| 12    | SRE/Incident Manager              | incident\_runbook.md, 12\_monitoring.md                                 | 06,07                    | on‑call, maintenance mode             | 12    | D3: MM msg • D6: P1 drill                                                     | M1: uptime SLO • M2: on‑call rota • M3: chaos test                |

#### RACI (artifacts)

| Artifact                | A | R  | C         | I                   |
| ----------------------- | - | -- | --------- | ------------------- |
| roles\_matrix.md        | 0 | 0  | 1,2,3     | 4–12                |
| slack\_channels.md      | 0 | 7  | 6,12      | 1,2,3,4,5,8,9,10,11 |
| message\_standards.md   | 0 | 4  | 7,11      | all                 |
| automation\_specs.md    | 0 | 6  | 1,4,5,7,8 | 2,3,9,10,12         |
| webhook\_contracts.json | 0 | 7  | 6         | 1–6,8–12            |
| incident\_runbook.md    | 0 | 12 | 7,6       | 1–11                |
| governance\_security.md | 0 | 9  | 12,7      | all                 |

#### Inter‑Agent Dependencies & Handoffs

- 1→6: **01\_stack.md** (tools, env)
- 2→3/4: **02\_scope\_faq.csv**
- 3→4/6/7/8: **03\_flow\_spec.json**
- 4→6/7: **04\_prompts.md**
- 5→6/10/11: **GSheets links** (Interactions, Unknowns, KPI, Prospects)
- 6→7/12: **automation\_specs.md, 06\_zaps\_make.yaml**
- 7→6/12: **webhook\_contracts.json, webhook URLs**
- 8→6/11: **08\_integrations.md** (Shopify/Messenger hooks)
- 9→0: **09\_qa\_checklist.md** (sign‑off)
- 10→#analytics‑kpi: weekly digest
- 12→#incidents: incident reports/postmortems

##### PASS/FAIL — roles\_matrix.md

- PASS if: Agents 0–12 assigned with D0–D7 due, M1–M3 milestones, DRI set; RACI present; dependencies + file handoffs listed. Else FAIL.
