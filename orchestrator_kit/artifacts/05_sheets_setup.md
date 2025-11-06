# Orion Intelligence Agency Launch — 05_sheets_setup.md

## Workbook Overview

Create a single Google Sheets workbook with the following tabs (Editor access for `automation@agency.com`):

1. **KB** – curated FAQ source of truth (columns: `id, question, answer, tags, product, priority, last_updated, approved_by`).
2. **Interactions** – log of every bot reply (schema below).
3. **Unknowns** – escalations sent to humans.
4. **Leads** – captured emails from the chatbot or landing pages.
5. **Weekly Summary** – per-client rollup for KPI Friday digest.

Restrict sharing to core agents; Zapier/Make connections should use service accounts only.

## Tab Schemas

### Interactions (required columns A–K; derived metrics start at L)

| Col | Field                   | Type                | Notes                                      |
| --- | ----------------------- | ------------------- | ------------------------------------------ |
| A   | `timestamp`             | datetime (ISO)      | From bot/Zap (UTC).                        |
| B   | `client`                | text                | Store name.                                |
| C   | `user_id`               | text (hashed)       | No raw PII.                                |
| D   | `channel`               | enum(`web`,`messenger`) |                                          |
| E   | `intent`                | text                | Quick-reply value or NLU output.           |
| F   | `matched_faq`           | boolean             | `true` if KB hit.                          |
| G   | `ai_used`               | boolean             | `true` if fallback LLM responded.          |
| H   | `response_ms`           | number              | Latency captured at runtime.               |
| I   | `handoff`               | boolean             | `true` if unknown ticket opened.           |
| J   | `email_captured`        | boolean             | From unknown handler form.                 |
| K   | `transcript_url`        | url                 | Link to full conversation.                 |
| L   | `words_count`           | number (derived)    | Count of reply words.                      |
| M   | `deferral_phrase_exact` | boolean (derived)   | Exact match to required deferral string.   |
| N   | `model`                 | text (optional)     | e.g. `gpt-4o-mini`.                        |

### Unknowns (columns A–G required; H–L optional ops metadata)

| Col | Field            | Type                              | Notes                            |
| --- | ---------------- | --------------------------------- | -------------------------------- |
| A   | `created_at`     | datetime (UTC)                    | From Zap trigger.                |
| B   | `client`         | text                              |                                  |
| C   | `channel`        | enum(`web`,`messenger`)           |                                  |
| D   | `user_id`        | text (hashed)                     |                                  |
| E   | `question`       | text                              | Redacted user text.              |
| F   | `email_captured` | boolean                           |                                  |
| G   | `link_transcript`| url                               |                                  |
| H   | `owner`          | enum(`@agent2`,`@agent4`)         | Round-robin assignment.          |
| I   | `owner_email`    | email                             | For follow-up alert.             |
| J   | `status`         | enum(`Open`,`In-Progress`,`Resolved`) | SLA tracking.                |
| K   | `due_date`       | date                              | Default = created_at + 2 business days. |
| L   | `kb_row_url`     | url                               | Where the answer was added.      |

### Leads

| Field                  | Type                              | Notes                                    |
| ---------------------- | --------------------------------- | ---------------------------------------- |
| `timestamp`            | datetime                          | When form submitted / email captured.    |
| `client`               | text                              | Store name.                              |
| `source_channel`       | enum(`web`,`messenger`,`landing`) |                                          |
| `email`                | email                             | Opt-in only.                             |
| `consent`              | boolean                           | Checkbox from form/chat.                 |
| `topic`                | text                              | Intent or LP slug (e.g., `starter-pack`).|
| `captured_via`         | enum(`unknown`,`form`,`chat_cta`) |                                          |
| `owner`                | text                              | Sales owner handling follow-up.          |
| `status`               | enum(`New`,`Contacted`,`Demo`,`Won`,`Lost`) | Pipeline stage.                  |
| `next_follow_up_date` | date                              | Optional reminder.                       |
| `notes`                | text                              | Free-form comments.                      |

### Weekly Summary (one row per client per week)

| Field                   | Type     | Formula / Guidance |
| ----------------------- | -------- | ------------------ |
| `week_start`            | date     | Monday (ISO). |
| `week_end`              | date     | Following Monday. |
| `client`                | text     | Store name. |
| `interactions`          | number   | `=COUNTIFS(Interactions!$A:$A,">="&$A2,Interactions!$A:$A,"<"&$B2,Interactions!$B:$B,$C2)` |
| `answered_in_chat`      | number   | Sum of KB hits plus fallback responses without handoff. |
| `resolution_rate`       | percent  | `=IFERROR(E2/D2,0)` |
| `leads`                 | number   | `=COUNTIFS(Leads!$A:$A,">="&$A2,Leads!$A:$A,"<"&$B2,Leads!$B:$B,$C2)` |
| `handoffs`              | number   | `=COUNTIFS(Interactions!$A:$A,">="&$A2,Interactions!$A:$A,"<"&$B2,Interactions!$B:$B,$C2,Interactions!$I:$I,TRUE)` |
| `avg_first_response_ms` | number   | `=AVERAGE(FILTER(Interactions!$H:$H,Interactions!$A:$A>=$A2,Interactions!$A:$A<$B2,Interactions!$B:$B=$C2))` |
| `top_topic_1`           | text     | Pivot/`QUERY` on Interactions!E within week. |
| `top_topic_2`           | text     | Same method. |
| `top_topic_3`           | text     | Same method. |
| `wow_interactions`      | percent  | Compare to prior week row. |
| `wow_resolution_rate`   | percent  | Compare to prior week row. |
| `notes`                 | text     | Summary sentence or link to Slack digest. |

## Automation Specs (Zapier / Make)

### Zap A1 — Interactions Log (must-have)
- **Trigger:** Landbot or ManyChat new message/conversation.
- **Actions:** Formatter step to redact card/email patterns → Append Row to **Interactions** (A–K) → optional update to populate derived fields.

### Zap A2 — Unknown Ticket Escalation (must-have)
1. **Trigger:** ManyChat tag `unknown_needed` or fallback branch without KB match.  
2. **Rotate owner:** Look up last owner and alternate between `@agent2` / `@agent4`.  
3. **Slack Webhook:** Post to `#ops-bot` using the `unknown_event` schema (per `webhook_contracts.json`).  
4. **Append Row:** Write to **Unknowns** (A–L) including due date (`=WORKDAY(TODAY(),2)`).  
5. **Email:** Notify owner with transcript link; optionally add to **Leads** if email captured.

### Zap A3 — Lead Capture Sync (nice-to-have)
- **Trigger:** Interactions row with `email_captured=TRUE` or LP form submission.
- **Actions:** Normalize to lowercase, dedupe on `(client,email,7 days)`, append/update **Leads**.

### Zap A4 — Weekly KPI Roll-Up (Friday 09:00 PT)
- Compute week window, update **Weekly Summary** row per client.
- Generate digest via OpenAI using KPI prompt (below).
- Post `kpi_summary` payload to Slack `#analytics-kpi` and email stakeholders.

### Zap A5 — Ticket Resolution Close-Out (optional)
- **Trigger:** Unknowns `status` becomes `Resolved`.
- **Actions:** React in Slack thread, record `kb_row_url`, optionally append new FAQ to KB.

> Make.com equivalents: replace Gmail/Slack/Zap steps with HTTP modules; keep payload keys identical to `webhook_contracts.json`.

## Prompts for Automation Copy

### Weekly Summary Prompt
```
Summarize this conversation in 2 sentences for the store owner. Focus on the customer’s request, whether the KB answered it, and if human follow-up is needed. Do not include personal data. End with one clear next step. Max 45 words.
```

### KPI Email Prompt
```
Draft a weekly client report: assisted X customers, resolution rate Y%, top topics [a,b,c], leads Z, suggested new FAQs [list]. Keep to 120 words, friendly and factual.
```

## Pass/Fail Checklist

- Workbook created with all tabs and schemas above.  
- Zap A1 and Zap A2 tested end-to-end (rows appear, Slack and email fire).  
- Zap A4 scheduled and sends a Friday digest to Slack + email.  
- Prompts for weekly summary and KPI email stored alongside this doc.
