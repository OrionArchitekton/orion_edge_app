# ReplyByAI Niche Pull Site Strategy (Artifact 13)

## Summary

- **Goal:** Attract <$1M ecommerce stores through publisher-style content and lead magnets, then convert to chatbot trials for Orion Intelligence Agency.
- **Initial niches:** Beauty & Skincare · Pets · Home & Décor.
- **Phase-2 niches:** Indie Baby/Kids, Eco-friendly brands, POD Apparel, Specialty Food.
- **Lead magnets:** `/launch-checklist`, `/free-audit`, `/site-speed-pack` (tagged via `topic` field).
- **Funnel:** replybyai.com hub → niche subpaths → LPs → Supabase `leads` table → Slack `#sales` → demo/trial → weekly KPI email.
- **Ethics:** Clear disclosures, no medical/legal/payment advice, consent-only email capture, accessibility and Messenger 24-hour compliance.

---

## Content Map

**Pillars:** Launch & Setup · SEO & Traffic · CRO & UX · Retention & Automation · Case/Insights  
**Publish order (D1–D7 rolling):**

1. Launch Checklist (PDF) → link to `/launch-checklist`
2. Long-tail SEO for Small Stores
3. Trust Checklist: 10 Signals on Product Pages
4. Site Speed for Non-Devs (7 fixes)
5. Welcome Series: 3-Email Template
6. Beauty niche FAQs (top 15)
7. Pets niche FAQs (top 15)
8. Home niche FAQs (top 15)
9. A/B Ideas: Greeting & Quick Replies
10. Mini Case: +25% CVR in 3 months

Every post includes CTA to the chatbot (≤60-word answers, safe deferrals, weekly KPIs) and links to a relevant lead magnet.

---

## Landing Pages (Copy Blocks)

### `/launch-checklist`
- **Headline:** Launch your store with fewer surprises  
- **Subhead:** 20-step checklist for shipping, returns, sizing, and trust signals.  
- **Form:** `email*`, `first_name` (opt), `store_url` (opt), consent checkbox (required).  
- **Thank-you:** “We’ve emailed your checklist and a 7-day setup guide.”

### `/free-audit`
- **Headline:** Free 10-minute chatbot audit (limit 5/month)  
- **Subhead:** We review FAQ clarity, order status path, and returns. Receive 3 fixes to cut repeat DMs.  
- **Form:** `email*`, `store_url*`, `platform`, `main_challenge`, consent checkbox.  
- **SLA:** “We’ll reply within 2 business days.”

### `/site-speed-pack`
- **Headline:** Faster pages, better conversions  
- **Subhead:** A small-store “speed pack” you can apply in 20 minutes.  
- **Form:** `email*`, `first_name` (opt), consent checkbox.  
- **Thank-you:** “Speed pack sent. Reply to the email for help.”

All forms submit to `/api/lead` with `topic` matching the magnet slug plus `utm_*` and `niche` when available.

---

## Niche Subpaths (replybyai.com)

### `/beauty`
- **Hero:** AI Chatbots for Beauty & Skincare  
- **Bullets:** Ingredients/routine answers from policy pages · no medical advice · returns/shipping clarity · lead capture on unknowns · weekly KPIs.  
- **CTA:** Get the Starter FAQ Pack · Book a 15-min Fit Call.  
- **Compliance:** Defer health claims with exact deferral line.

### `/pets`
- **Hero:** AI Chatbots for Pet Brands & Subscriptions  
- **Bullets:** Sizing/fit guidance · subscription prompts · order status linking · safe deferrals · weekly KPIs.  
- **CTA:** Starter FAQ Pack · Book a Fit Call.

### `/home`
- **Hero:** AI Chatbots for Home & Décor Stores  
- **Bullets:** Décor kit contents · shipping windows · returns/exchanges · lead capture · weekly KPIs.  
- **CTA:** Starter FAQ Pack · Book a Fit Call.

Layout mirrors `/faqfix` and `/leadflow`, swapping bullets/examples per niche.

---

## Distribution SOP (30-Day)

- Publish 2 blog posts/week on replybyai.com; syndicate top 3 to Medium (canonical) and LinkedIn.
- Community participation: 2 substantive answers/week in r/Shopify + 1 in a FB founder group (value-first, link only when relevant).
- Partnerships: pitch 3 (Klaviyo, LoyaltyLion/Smile, Shopify meetup) for co-webinar or guest post.
- UTM scheme: `utm_source=community|partner|search`, `utm_medium=post|link|webinar`, `utm_campaign=magnet-slug`, `utm_content=niche|title`.

---

## Supabase & APIs

- Leads table fields: `email, first_name, store_url, platform, niche, topic, utm_*, referrer, status`.
- `/api/lead` accepts `topic`, `niche`, `platform`, `store_url`; writes to Supabase; optional Slack ping to `#sales`.
- CORS `ALLOWED_ORIGINS`: `https://replybyai.com` + Orion domain.

---

## Analytics & KPIs Enhancements

- GA4 events: `lead_submit`, `cta_click`, `newsletter_signup` (with `niche`, `topic`, `utm_*` parameters).
- Submit sitemap to Google Search Console (`sitemap.xml`).
- Add `niche` pivot to `10_kpi_rollup.md`; weekly digest segments results by niche.

---

## Automation Updates

- **Zap A3 dedupe:** de-duplicate leads on `(LOWER(email), 7 days)` and append `niche`, `topic`, `utm_*`.
- **Slack #sales:** include niche badge and magnet slug in message payload.
- **Rotation:** Unknown tickets continue to alternate between @agent2 and @agent4.

---

## Owners & 72-Hour Timeline

- **A11 Sales Ops:** publish `/beauty`, `/pets`, `/home` + three LPs; launch partner outreach.
- **A12 Marketing:** publish three blog posts (Checklist, Trust, Speed) and syndicate two.
- **A6 Automations:** confirm `/api/lead` writes to Supabase and pings Slack.
- **A10 Analytics:** GA4/GSC wired, UTM conventions enforced, pivot by `niche`.
- **A1 Platform:** verify Resend domain `notify.replybyai.com`.

**Milestones:**  
- D0: `/launch-checklist` live; analytics configured; Slack alerts active.  
- D1: `/beauty` & `/pets` live; SEO + trust posts published.  
- D2: `/home` + `/free-audit` live; site speed post and community answers shipped.

---

## Copy Snippets

- **Starter FAQ Pack CTA:** “Get the Starter FAQ Pack — 15 gold-standard FAQs + ≤60-word patterns.”  
- **Footer disclosure:** “Independent publisher site. No medical/legal/payment advice. Email captured only with consent.”

---

## Pass/Fail Addendum

- **PASS** if 3 niche pages + 3 LPs live, forms write to Supabase `leads` with `topic` & `niche`, GA4 + GSC configured, Slack `#sales` alerts fire, and at least one post syndicated to Medium/LinkedIn.

---

## Positioning Pack Highlights

**Taglines:**  
- Turn questions into checkouts.  
- More sales, less support.  
- Your 24/7 salesperson—on every product page.

**Three-Sentence Explainer (≤60 words):**  
ReplyByAI installs a conversion-focused chatbot that answers product questions, captures emails, and nudges shoppers to buy. It learns your catalog, policies, and tone—then routes complex issues to you while handling the rest automatically. Stores see more purchases, fewer abandoned carts, and less time spent on repetitive support.

**Mini Case (anonymized):**  
A 7-SKU skincare Shopify shop added ReplyByAI to PDPs and checkout: **+18%** add-to-cart, **+11%** checkout conversion, and **↓32%** WISMO tickets in 30 days. Plays like “shade finder,” “bundle builder,” and “shipping ETA” drove **$4.2k** assisted revenue; owner workload dropped ~3 hrs/week.

**Proof Points:**  
- Trained on your catalog, FAQs, and policies in minutes.  
- Built-in plays: back-in-stock capture, coupon handoff, UTM-aware prompts.  
- Human handoff + transcripts in email/Slack; no code required.

**CTA Blocks:**  
- Get the Starter FAQ Pack — 15 boutique FAQs + ≤60-word answer patterns.  
- Start a 15-min Fit Call — map your FAQ + install + first KPI email in 7 days.
