## automation\_specs.md

### Cost & Guardrails

- **Within \$0–\$30/mo:** Slack Free, Google Sheets Free, Zapier/Make Free (low volume), ManyChat Free (Messenger) *or* Landbot **trial** for launch week; revisit M1. OpenAI: use **gpt‑4o‑mini**; strict token caps.
- **LLM limits:** temperature 0.4, `max_completion_tokens` to keep replies ≤60 words; auto‑truncate.
- **Retries:** 3× with exponential backoff; dead‑letter to **#ops‑bot**.

### Zap 1 — Log every interaction to Google Sheets

- **Trigger:** ManyChat/Landbot “New Conversation”
- **Actions:** Formatter (clean text) → GSheet **Interactions!A:K**
- **Fields:** timestamp, client, user\_id, channel, intent, matched\_faq(bool), ai\_used(bool), response\_ms, handoff(bool), email\_captured, transcript\_url
- **Webhook hook:** Flow spec posts to `INTERACTION_LOG_WEBHOOK_URL` before this Zap runs.

### Zap 2 — Unknown → Slack ticket

- **Trigger:** Tag `unknown_needed` OR fallback used + no KB match
- **Actions:** LLM 2‑sentence summary → Slack Webhook **#ops‑bot** (Unknown template) → GSheet **Unknowns!A:G**
- **Auto‑assign:** rotate **@agent2** (FAQ) and **@agent4** (prompt)
- **Webhook hook:** Flow spec posts to `UNKNOWN_WEBHOOK_URL` prior to Slack escalation.

### Zap 3 — Weekly KPI (Fri 9am)

- **Trigger:** Schedule
- **Actions:** GSheet rollup → LLM summary → Slack **#analytics‑kpi** + email to client
- **KPIs:** interactions, resolution\_rate, top\_topics[3], leads, handoffs, avg\_first\_response\_ms, WoW deltas
- **Daily memo (08:00):** include memory hit-rate and cloud hit-rate for the Slack recall summary.

### Zap 4 — Sales pipeline

- **Trigger:** new row in **Prospects!A:H** or form submit
- **Actions:** Slack **#sales** message + follow‑up tasks (ClickUp/Notion optional)

### Zap 5 — Deploy notice

- **Trigger:** Git/Notion tag `READY-DEPLOY` or flow publish
- **Actions:** Slack **#ops‑bot** deploy message with version, changelog, rollback steps

**OpenAI Usage (within Zaps):** summarize unknowns, create KPI digest; redact PII; enforce ≤60 words by prompt instruction + token cap.

### Daily Report Runner & Slack Digest

- **Runner service:** `runner-daily-report` container (see `deploy/cosmocrat-v1.compose.yml`) runs daily summaries
- **Slack digest functions:** Use `scripts/slack_digest.js` (Node) or `scripts/slack_digest.py` (Python) to post executive daily digests
- **Digest fields:** Decisions, Actions (next 48h), Deltas, with links to JSON/Markdown reports
- **Environment:** Requires `SLACK_WEBHOOK_URL` and `WEBHOOK_SECRET` (generate with `openssl rand -base64 32`)
- **Usage:** See `docs/Daily_Executive_Summary.md` for setup instructions

##### PASS/FAIL — automation\_specs.md

- PASS if: all Zaps exist & test green, Sheets columns match spec, rotation rule works, KPI scheduled Fri 9am, deploy notices hit #ops‑bot. Else FAIL.
