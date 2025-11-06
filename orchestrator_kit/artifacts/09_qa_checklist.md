# Orion Intelligence Agency Launch — 09_qa_checklist.md

## Bot Disclosure

> “Hi! I’m [BotName], an AI assistant for [Store Name]. I can answer quick questions from our help center. If I don’t know, I’ll collect your email for a teammate to follow up.”

## Privacy Notice (Widget Footer)

> “Privacy: This chat uses AI. We don’t collect card numbers or sensitive personal data here. By continuing, you agree to our Privacy Policy at [PRIVACY_URL]. Email is optional and used only to follow up on your question.”

## Forbidden Data Policy

Never collect:

- Payment details (card numbers, CVV, full billing address).
- Government/identity numbers (SSN, passport, driver’s license).
- Health or age-restricted medical guidance.
- Legal advice, compliance confirmations, liability statements.
- Explicit/adult content or imagery.

Refusal macros (≤60 words, exact wording):

- **Payments/PII:** “I can’t process payment or sensitive personal info in chat. Please use our secure checkout or email support@[store] for help.”
- **Medical/Health:** “I can’t provide medical advice. Please consult a healthcare professional or email support@[store] for product information.”
- **Legal/Compliance:** “I can’t give legal advice. For policy details, see our terms or email support@[store]; a teammate can assist.”
- **Adult/Explicit:** “I can’t help with that request. If you have a product question, I’m happy to help.”
- **Unknown/Out of scope:** “I’m not sure on that. Let me have a teammate follow up—what’s your email?”

> If the customer asks for follow-up, route to Unknown handler and log in Sheets. Never echo user-provided PII.

## Keyword Filters

Case-insensitive contains; expand per client.

- **Medical/Health:** prescription, diagnosis, contraindication, side effects, FDA, pregnant, pregnancy, breastfeeding, dosage.
- **Legal/Compliance:** legal advice, lawsuit, liable, compliance, GDPR, CCPA, warranty law, guarantee delivery, refund by law, privacy request.
- **Adult/Explicit:** NSFW, sex, nude, explicit, 18+, porn, OnlyFans.

Behavior: Bypass fallback → send relevant refusal macro → open Unknown ticket only when user consents to follow-up.

## Accessibility Quick Pass

- Keyboard navigation via Tab/Shift+Tab; clear focus ring.
- Text/button contrast ≥ 4.5:1.
- Buttons/quick replies include `aria-label`s; emojis not sole meaning.
- Dialog uses `role="dialog"` and descriptive title.
- No auto-dismiss under 20s; provide explicit close button.
- Links underlined, descriptive, open in new tab with notice.
- Respect `prefers-reduced-motion`; avoid flashing.
- Set correct `lang` attribute (e.g., `lang="en"`).
- Error messages use plain language, not color-only cues.

## Platform Policy Reminders

- **Messenger 24-hour rule:** Only transactional/issue follow-ups beyond the 24-hour window. Append footer: “Replies may be delayed outside the 24-hour window.”
- **No unsolicited promos:** Offer discounts only when user initiated or opted in.
- Maintain AI disclosure in first message and footer.
- Email capture requires explicit opt-in limited to current issue.
- Log metadata + consented email only; honor redaction requests.

## Memory Verification

1. Run `python3 jobs/memory/consolidate.py --commit` followed by a targeted FAQ query.
2. Confirm **Langfuse** trace shows `memory.hit=true` (attach trace ID in QA log).
3. Trigger an unknown path and ensure `UNKNOWN_WEBHOOK_URL` posts to Slack with correct payload.
4. Execute `scripts/memo_recall.sh` and post output to **#proj-chatbot** or **#memo-recall** (screenshot/URL in QA log).

## Health Endpoints

- MCP API: `curl -s http://localhost/mcp/healthz`
- vLLM models: `curl -s http://localhost:8000/v1/models`
- Langfuse UI: `http://<edge-ip>:3000/`
- n8n UI: `http://<edge-ip>:5678/`

## Safety Scan Prompt

```
Review this answer: [paste].
Flag any claims without a source, policy risks (payments/PII, medical/legal, guarantees), or over-promising.
List the issues briefly, then rewrite the answer safely in ≤50 words, keeping one clear CTA and removing unsupported claims.
```

## Pass/Fail

- **PASS** if disclosures, refusal policy, filters, accessibility list, platform reminders, memory verification, health endpoints, and safety scan prompt are documented and deployed with evidence. Otherwise **FAIL**.
