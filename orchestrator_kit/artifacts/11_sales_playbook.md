# Orion Intelligence Agency Launch — 11_sales_playbook.md

## Week-1 Check-In Email Template

**Subject:** Week 1 results + next steps — [Store Name] AI Assistant  
**To:** `[client email]`  

```
Hi [Client First Name],

Thanks for piloting the AI assistant. Here’s your first-week snapshot:
• Interactions: {interactions}
• Resolution rate: {resolution_rate}%
• Leads captured (email opt-ins): {leads}
• Memory hit-rate: {memory_hit_rate}% (cloud fallback {cloud_hit_rate}%)
• Top topics: {topic_1}, {topic_2}, {topic_3}
• Top 3 unanswered to add: 1) {u1} 2) {u2} 3) {u3}

Quality & safety: No payment data collected in chat; unknowns routed to your inbox/Slack. Daily memo recap posted to #proj-chatbot.

Proposed next steps (7 days):
1) Add the 3 answers above to the KB (we’ll draft + load).
2) Optional: enable Messenger fallback (free during trial).
3) Light A/B on greeting to lift self-serve clicks.

Pick a plan (below) and I’ll send an invoice + enable auto-reports.

Best,
[Your Name]
{BOOKING_URL} · {DEMO_URL}
```

## Pricing Options

| Plan        | Setup | Monthly | Includes | Notes |
| ----------- | ----- | ------- | -------- | ----- |
| **Basic**   | $300  | $75/mo  | Web chat widget, 15 core FAQs, AI fallback, Unknowns→Slack, weekly KPI digest, 1 update/month | ≤1,500 interactions/mo; email support ≤2 business days. |
| **Pro**     | $600  | $200/mo | Everything in Basic + Shopify order lookup proxy (read-only), Messenger fallback, 2 updates/month, quarterly A/B test | ≤5,000 interactions/mo; priority email ≤1 business day. |
| **Growth**  | $1,200 | $400/mo | Everything in Pro + monthly live review, KPI workbook, custom flow per quarter, priority incident response | ≤12,000 interactions/mo; shared on-call during business hours. |

**Overages:** +$25 per additional 1,000 interactions. **Pauses:** month-to-month; pause anytime. **Compliance:** bot never handles payment data; Messenger replies respect the 24-hour rule. **Reporting:** price includes weekly KPI digest + daily memo recall summary.

## Agreement Bullet Points (one-page)

- **Scope:** Branded web chat (and optional Messenger), KB-bound responses, Unknowns routed to Slack, weekly KPI digest.  
- **Service Levels:** Incident acknowledgements within 30 minutes (business hours). Maintenance mode message provided.  
- **Updates per month:** Basic 1 · Pro 2 · Growth 4 (FAQ/prompt changes ≤150 words). Extra updates billed at $50 each.  
- **Client responsibilities:** Supply policy URLs, returns portal, size chart, product notes, and approve copy.  
- **Privacy & security:** Email capture requires opt-in; no card/PII collection. Keys stored in vault; rotated every 90 days.  
- **Billing:** Setup due at kickoff. Monthly subscription billed in advance, net-7.  
- **Cancellation:** Cancel anytime; service ends at current cycle. Logs purged within 10 business days on request.  
- **IP:** Client owns brand assets/data; agency retains generic bot templates (custom work-for-hire via addendum).  
- **Compliance:** Messenger 24-hour rule, accessibility quick pass, CAN-SPAM for follow-ups.

## Invoice Line Items

| Item                                      | Qty | Unit  | Rate             | Amount | Notes |
| ----------------------------------------- | --- | ----- | ---------------- | ------ | ----- |
| AI Chatbot Setup — Basic/Pro/Growth       | 1   | fixed | $300 / $600 / $1,200 | $… | Implementation, branding, QA |
| Monthly Subscription — Basic/Pro/Growth   | 1   | month | $75 / $200 / $400 | $… | Logging, KPIs, updates/month |
| Add-on: Shopify order lookup proxy        | 1   | month | $75             | $75   | Optional if not in plan |
| Add-on: Messenger fallback                | 1   | month | $50             | $50   | Optional if not in plan |
| Extra KB/prompt updates                   | N   | each  | $50             | $…    | Beyond included quota |
| Overages (interactions)                   | B   | per 1k| $25             | $…    | Blocks of 1,000 interactions |

CSV starter:

```
Item,Qty,Unit,Rate,Amount,Notes
Setup - Basic/Pro/Growth,1,fixed,300|600|1200,,Implementation, branding, QA
Monthly - Basic/Pro/Growth,1,month,75|200|400,,Subscription
Add-on - Shopify order lookup,1,month,75,,Optional
Add-on - Messenger fallback,1,month,50,,Optional
Extra KB/Prompt update,N,each,50,,Beyond plan
Overages (per 1k interactions),B,per_1000,25,,Calculated
```

## Referral Ask (Client-Forwardable)

> “We just finished a 7-day pilot for our tiny AI support widget and it cut repeat DMs while capturing leads. If you know a store that could use this, I’m happy to set up a no-cost demo this week: {BOOKING_URL}.”

Alt for direct ask:

> “Quick favor—if this bot saved you time, would you forward this to a peer? They get a 7-day trial and setup discount if they mention you. Want me to line up a short demo link?”

## Pass/Fail

- **PASS** if email template, pricing table, agreement bullets, invoice template, referral prompt, and memory-aware talking points are ready.  
- **FAIL** otherwise.
