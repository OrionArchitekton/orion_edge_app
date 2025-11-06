### Zap 1 — Log every interaction to Google Sheets
- **Trigger:** ManyChat/Landbot “New Conversation”
- **Actions:** Formatter (clean text) → GSheet **Interactions!A:K**
- **Fields:** timestamp, client, user_id, channel, intent, matched_faq(bool), ai_used(bool), response_ms, handoff(bool), email_captured, transcript_url

### Zap 2 — Unknown → Slack ticket
- **Trigger:** Tag `unknown_needed` OR fallback used + no KB match
- **Actions:** LLM 2-sentence summary → Slack Webhook **#ops-bot** (Unknown template) → GSheet **Unknowns!A:G**
- **Auto-assign:** rotate **@agent2** (FAQ) and **@agent4** (prompt)

### Zap 4 — Sales pipeline
- **Trigger:** new row in **Prospects!A:H** or form submit
- **Actions:** Slack **#sales** message + follow-up tasks (ClickUp/Notion optional)
