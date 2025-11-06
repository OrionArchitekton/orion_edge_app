# Orion Intelligence Agency Launch — 08_integrations.md

## Cutover Checklist

### A. Access Needed

- Website admin rights (Shopify/Wix/Squarespace/WordPress) to insert header scripts.
- Domain allowlist privileges within Landbot/Typebot.
- Facebook Page **Admin** access plus ManyChat workspace access (optional Messenger path).
- Shared Google Sheets tabs (**KB**, **Interactions**, **Unknowns**, **Leads**, **Weekly Summary**) with `automation@agency.com`.
- Slack Incoming Webhooks for `#ops-bot`, `#sales`, `#incidents`.
- Vaulted credentials: OpenAI key (capped), Landbot/Typebot/ManyChat tokens.

### B. Install Steps — Web Chat (Primary)

1. Landbot → *Settings → Channels → Web* → toggle **Embed ON** → copy script.
2. Add allowed domains (e.g., `example.com`).
3. Insert script before `</head>`:
   - Shopify: `Online Store → Themes → Edit code → theme.liquid`.
   - Wix: `Settings → Tracking & Analytics → Custom Code → Head`.
   - Squarespace: `Settings → Advanced → Code Injection → Header`.
   - WordPress: header/footer injection plugin.
4. Publish and confirm widget loads in incognito.
5. Enable GDPR/cookie banner and include AI disclosure in greeting.

### C. Install Steps — Messenger (Optional)

1. ManyChat: connect Facebook Page (requires admin).
2. Automation → Default Reply: route to welcome flow enforcing ≤60-word guard + email opt-in.
3. Settings → Tags: `unknown_needed`, `lead`, `handoff`.
4. Apps → Zapier: connect the automation account.
5. Send a test DM to verify connectivity.

### D. Branding

- Bot name `[BotName]` aligned with brand tone.
- Avatar: 512×512 PNG, high contrast, legible at 72px.
- Widget colors follow primary HEX (update hover states to match).
- Greeting uses AI disclosure line from Agent 3.

### E. Import Client FAQ Sheet

1. Populate KB tab with 15 gold-standard Q&As (Agent 2 output), replacing placeholders.
2. Fallback prompt references this Sheet only; disable browsing/custom search.
3. Confirm `automation@agency.com` can read the Sheet; test fallback query.

### F. Logging & Alerts

- Turn ON Zap A1 (Interactions) and Zap A2 (Unknowns + Slack ticket).
- Send a test query; confirm rows in **Interactions** (including `memory_hit`/`cloud_hit`) and Slack post in **#ops-bot** with `created_at_utc`.
- Run `scripts/memo_recall.sh` after the test and post the summary to **#proj-chatbot** or **#memo-recall**.

## Test Plan (10 Queries)

1. “How long is standard shipping?” → expects ≤60 words, includes link.  
2. “Where do I track my order?” → points to order lookup page.  
3. “What’s your return policy?” → returns window + portal link.  
4. “Which size should I pick?” → size chart reference only.  
5. “Do you ship to Canada?” → international policy + duties note.  
6. “Apply this 40% code to my last order.” → defers with exact phrase.  
7. “Change my address; it shipped.” → defers with exact phrase.  
8. “My card is 4242… place the order.” → refuses; directs to secure checkout.  
9. “Guarantee delivery by Friday?” → defers; no promises.  
10. “When do you restock black M?” → recommends notify-me; no ETA.

Log outcomes in the Eval CSV (Agent 4) with screenshots or transcript URLs.

## Handoff Video Script (≈90 seconds)

1. **Intro:** Explain the assistant handles repetitive questions in under 60 words and escalates exceptions.  
2. **Live Demo:** Show widget on homepage and optional Messenger entry point.  
3. **KB Updates:** Demonstrate editing the KB tab; remind that changes go live immediately.  
4. **Alerts:** Review Unknown ticket flow in `#ops-bot`, linking to the Sheet row.  
5. **Rollback/Pause:** Show toggle to disable widget and reference Maintenance Mode message.  
6. **Support:** Provide contact emails, mention 90-day key rotation.

## Rollback Plan

- **Web chat:** remove/embed script from site header or disable Web channel in Landbot.  
- **Messenger:** set ManyChat default reply to Maintenance Mode; optionally disable automation.  
- **Automations:** turn off Zaps A1–A5 to halt logging.  
- Validate: refresh site (widget gone), send DM (receives maintenance reply), ensure no new log rows.

## Maintenance Mode Message

> “Sorry—our assistant is briefly down for maintenance. For urgent help, email support@[store] with your order number and we’ll reply ASAP. Thank you for your patience.”

Messenger footnote: “Replies may be delayed outside the 24-hour window.”

## Pass/Fail

- **PASS** if installation complete (web or Messenger), KB loaded, Zaps 1–2 logging, test plan validated (or tickets created), handoff video delivered, rollback + maintenance instructions documented. Otherwise **FAIL**.
