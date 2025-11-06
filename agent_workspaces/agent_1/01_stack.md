# 01 Stack Decision Table

**Path:** `docs/kit/01_stack.md`  
**Owner:** @tech-lead  
**Last Updated:** 2025-10-20

---

## Decision Matrix

| Component | MVP Path ($0-$30/mo) | Cloud Workers Path ($35+/mo) | Choice | Rationale |
|-----------|---------------------|------------------------------|--------|-----------|
| **Bot Platform** | Landbot Free / ManyChat Free | Custom Cloudflare Worker | MVP | Zero upfront, validate first |
| **KB Storage** | Google Sheets (shared) | Supabase Postgres | MVP | Free, familiar, fast to ship |
| **Embeddings** | None (exact-match only) | Vectorize + D1 | MVP | Delay until 5+ clients |
| **Hosting** | Static (GitHub Pages / Netlify) | Cloudflare Pages + Workers | MVP | Free tier sufficient |
| **Analytics** | Google Sheets formulas | Custom dashboard (Grafana) | MVP | Manual KPI rollup weekly |
| **Email** | Gmail + Zapier Free | Resend API + queues | MVP | 100 emails/day sufficient |
| **Monitoring** | Manual daily checks | Sentry + uptime alerts | Hybrid | Free Sentry tier + manual |
| **CRM Handoff** | Email + CSV export | Direct API (HubSpot/Salesforce) | MVP | Phase 2 automation |

---

## Stack Components

### Frontend (Static Sites)
**Orion Intelligence Agency (orionintelligenceagency.com)**
- **Host:** Netlify Free or GitHub Pages
- **Build:** Plain HTML/CSS + optional React artifacts
- **Purpose:** Service showcase, case studies, blog

**Reply By AI (replybyai.com)**
- **Host:** Netlify Free or GitHub Pages  
- **Build:** Landing page builder (Carrd $19/yr or plain HTML)
- **Purpose:** Lead capture, niche verticals, free audit CTA

### Backend (MVP)
**Bot Logic**
- **Platform:** Landbot (free tier) or ManyChat (free tier)
- **Flow:** `docs/kit/03_flow_spec.json` + `04_prompts.md`
- **Limitations:** 
  - 100 conversations/month (Landbot free)
  - No custom code (use webhooks to Zapier)
  - Manual prompt updates via UI

**Knowledge Base**
- **Storage:** Google Sheets (per `05_sheets_setup.md`)
  - `Core_FAQs` (15 rows)
  - `Vertical_FAQs` (30 rows, 3 niches)
  - `Interactions` (append-only log)
  - `Weekly Summary` (weekly KPI rollup)
- **Search:** VLOOKUP or QUERY formulas
- **Sync:** Manual CSV upload weekly

**Automation**
- **Tool:** Zapier Free (5 zaps, 100 tasks/mo)
- **Zaps:**
  1. New chat → append transcript to Sheets
  2. Unknown intent → email owner + log
  3. Lead form submit → email + CSV row

### Backend (Phase 2: Cloud Workers)
**Trigger:** After 5 paying clients OR $2k MRR

**Stack:**
- **Runtime:** Cloudflare Workers ($5/mo)
- **DB:** Supabase Free (500MB, 2GB transfer)
- **Embeddings:** Cloudflare Vectorize ($0.04/1M queries)
- **Storage:** R2 ($0.015/GB)
- **Monitoring:** Sentry Free + Grafana Cloud Free

**Benefits:**
- Custom routing logic
- Semantic search (embeddings)
- Real-time KPI dashboard
- Direct CRM integrations
- A/B testing prompts

---

## Cost Breakdown

### MVP Path (Month 1-3)
```
Domain (2x)                 $24/yr      ($2/mo)
Hosting (Netlify/GH)        $0
Landbot Free                $0
Google Sheets               $0
Zapier Free                 $0
Email (Gmail)               $0
Sentry Free                 $0
-----------------------------------
TOTAL                       $2/mo
```

### Cloud Workers Path (Month 4+)
```
Domains                     $2/mo
Cloudflare Workers          $5/mo
Supabase Free               $0 (or $25/mo Pro)
Vectorize                   ~$5/mo (estimated)
R2 Storage                  ~$3/mo (estimated)
Sentry                      $0 (free tier)
Monitoring                  $0 (Grafana free)
-----------------------------------
TOTAL                       $15-$40/mo
```

---

## Migration Path

### Phase 1 (Now): MVP Validation
- Ship Landbot + Sheets + Zapier
- Onboard 1-3 pilot clients
- Manually tune prompts daily
- Weekly KPI review in Sheets

### Phase 2 (Month 2-3): Optimization
- Add 2 more niche FAQs
- Automate transcript cleanup (script)
- Create lead scoring formula
- Add fallback prompts for edge cases

### Phase 3 (Month 4+): Cloud Workers
**Trigger Criteria:**
- 5+ paying clients
- $2k+ MRR
- >500 queries/month
- Support burden >5h/week

**Migration Checklist:**
- [ ] Export all Sheets data to Supabase
- [ ] Rebuild bot logic in `src/index.ts`
- [ ] Generate embeddings for all FAQs
- [ ] Set up staging environment
- [ ] A/B test 1 client (new vs old)
- [ ] Migrate remaining clients over 2 weeks

---

## Integration Points

### Landbot → Sheets (Zapier)
```yaml
trigger:
  app: Landbot
  event: "New Lead"
  
action:
  app: Google Sheets
  action: "Append Row"
  sheet: "Transcripts"
  values:
    - timestamp: "{{trigger.timestamp}}"
    - user_id: "{{trigger.user_id}}"
    - intent: "{{trigger.intent}}"
    - message: "{{trigger.message}}"
    - response: "{{trigger.bot_response}}"
```

### Unknown Intent → Email (Zapier)
```yaml
trigger:
  app: Landbot
  event: "Unknown Intent"
  
filter:
  confidence: < 0.7
  
action:
  app: Gmail
  action: "Send Email"
  to: "owner@example.com"
  subject: "Bot Escalation: {{trigger.intent}}"
  body: |
    User asked: {{trigger.message}}
    Bot confidence: {{trigger.confidence}}
    
    Review at: [Sheets Link]
```

---

## Decision Log

| Date | Decision | Rationale | Status |
|------|----------|-----------|--------|
| 2025-10-20 | Use MVP path first | Zero clients, need validation | ✅ Active |
| TBD | Migrate to Workers | After 5 clients + $2k MRR | ⏳ Pending |
| TBD | Add embeddings | After 100+ FAQs added | ⏳ Pending |

---

## Tech Debt Tracker

| Item | Impact | Effort | Priority | Target |
|------|--------|--------|----------|--------|
| Manual prompt updates | High | Medium | P1 | Week 6 |
| No semantic search | Medium | High | P2 | Month 4 |
| CSV exports for CRM | Medium | Low | P2 | Month 3 |
| No A/B testing | Low | High | P3 | Month 6 |

---

## References
- Cloudflare Workers Pricing: https://workers.cloudflare.com/
- Supabase Pricing: https://supabase.com/pricing
- Landbot Free Limits: https://landbot.io/pricing
- Zapier Free Tier: https://zapier.com/pricing
