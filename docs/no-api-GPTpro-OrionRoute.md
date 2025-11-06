Got it. Let’s run a **no-API, Pro-GPT workflow**: teammates paste a ready-made prompt into their Pro chat, you forward me the outputs or links, and I synthesize/research + send back crisp briefs. Here’s the copy-paste kit.

# Operator Prompts (paste into Pro GPT)

## 1) Research Request (universal)

“Act as a senior analyst. Research **{topic}**. Prioritize primary sources, last 90 days, and contradictory viewpoints. Produce:

* Key findings (5 bullets, source-tagged)
* What matters (3 bullets)
* Risks/unknowns (3 bullets)
* Actionable next steps (≤5)
  Return: a) 150-word exec summary, b) source list with URLs.”

## 2) Conversation Memory Extractor (for CMA)

“From the text below, extract durable facts vs. ephemeral chatter. Tag each memory with:

* `topic`, `who`, `confidence (0–1)`, `half_life_days`
* `type`: {preference, constraint, goal, decision, blocker}
  Output JSON array only.
  TEXT: `{paste thread or notes}`”

## 3) Decision Brief (fast)

“You are Chief Strategist. Decide **{yes/no or pick A/B}**. Constraints: {constraints}. Criteria: {criteria}. Return:

* Decision (1 line)
* Rationale (3 bullets)
* Assumptions to watch (3)
* Next 3 actions (owners + ETA)
  ≤200 words.”

## 4) SEO Quick Sweep (page or site)

“Be a Technical SEO. Audit **{URL or sitemap}**. Output:

* Title/meta fixes (max 5)
* Internal links (max 5, with anchors)
* Schema to add (JSON-LD blocks)
* 3 content briefs (H2/H3 + FAQs)
  Keep it surgical. 300 words max + code blocks for schema.”

## 5) Profit Snapshot (manual mode)

“From the data below (revenue, ad spend, ops costs), calculate:

* Net profit, ROAS, CAC, CTR (if given), top/worst channel
* 3 scale moves, 3 cuts (with $ impact estimate)
  Return a 120-word CFO brief + a small table.
  DATA:
  `{paste numbers or table}`”

## 6) A/B Personalization Eval (memory vs cold)

“Given outputs A (with memory) and B (without), score on: Relevance, Brevity, Specificity, Actionability (1–5 each). Decide winner + 2 lines why. Return JSON:
`{winner: "A|B", scores: {A:{...}, B:{...}}, notes: "…"}`”

## 7) PII/Safety Scrubber

“Redact emails, phones, addresses, bank/IDs from the text, replace with `<REDACTED:TYPE>`. Keep meaning. Return clean text + list of redactions.
TEXT:
`{paste}`”

## 8) Content Brief (TBM/OAM)

“Create a 7-day content plan for **{brand}** targeting **{ICP}**. Channels: TikTok, IG, YT Shorts, LinkedIn. For each day: hook, 3 beats, CTA, hashtag set, and repurpose notes. Keep each item ≤5 lines.”

---

# Handoff Format (what they send back to me)

**Subject:** `[RUNNER] Topic – Date`
**Body:**

* Objective: …
* Inputs: links/files
* Outputs from Pro GPT: (paste)
* Constraints/Deadline: …

**Attachments:** any source exports/screens

---

# My Return Formats (what I’ll give you)

## Strategy One-Pager

* Decision + Why (≤3 bullets)
* Playbook (steps 1–5)
* Risks/mitigations
* KPIs + next checkpoint date

## SEO/TBM Pack

* Fix list (PR-ready)
* 3 briefs
* Schema blocks
* Internal-link map

## Finance Mini-Report

* Profit table
* Scale/Cut calls (with $ deltas)
* Watch items

---

# Optional JSON Schemas (if you want structure)

**Memory Item**

```json
{"topic":"","who":"","detail":"","type":"goal|preference|constraint|decision|blocker","confidence":0.85,"half_life_days":30}
```

**A/B Score**

```json
{"winner":"A","scores":{"A":{"relevance":5,"brevity":4,"specificity":5,"actionability":5},"B":{"relevance":3,"brevity":5,"specificity":3,"actionability":3}},"notes":"A used user’s stated goal + next step."}
```

—

If you want, I can also drop a **one-pager SOP** your team can pin in Slack with these prompts + formats.

Love it. Here’s a lean plan that keeps API usage minimal, seeds context via CSV, and gives you a tiny Slack app for hooks.

# What we’ll upload

**CSV schemas (put in Google Drive or drop in `#orion-uploads`):**

1. `channels.csv` — source of truth
   `channel_name,webhook_url(optional)`
   `#orion-ops,https://hooks.slack.com/services/XXX/YYY/ZZZ`

2. `artifacts.csv` — links we want handy
   `title,url,tags,channel_name`
   `TBM Site Map,https://tarotbymarie.com/sitemap.xml,"seo,tbm",#orion-ops`

3. `messages.csv` — pre-baked posts (so we don’t hit API for fetch)
   `channel_name,thread_ts(optional),text,blocks_json(optional),post_at(optional ISO)`
   `#orion-ops,,“Daily Profit Snapshot ready – upload CSV below to summarize.”,,`

4. `memory.csv` — durable facts (for CMA prompt)
   `topic,who,detail,type,confidence,half_life_days`
   `Elisabeth brand,"Elisabeth","TBM = tarot/astro focus",goal,0.9,60`

# Minimal Slack app (webhook-first)

Use **Incoming Webhooks** (no full Web API). One webhook per channel (or a single default).

**Slash commands (optional but nice):**

* `/seed channels` — registers any new channels from `channels.csv`
* `/drop messages` — posts rows from `messages.csv`
* `/artifacts` — posts a tidy list with buttons
* `/mem ingest` — posts a CMA-ready JSON bundle (from `memory.csv`) back into the channel

## Tiny Node server (Express)

````js
// server.js
import express from "express";
import fetch from "node-fetch";
import fs from "fs";
import csv from "csv-parse/sync";

const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

function loadCSV(path){
  const raw = fs.readFileSync(path, "utf8");
  return csv.parse(raw, { columns: true, skip_empty_lines: true });
}

const channels = loadCSV("./channels.csv");     // name + webhook_url
const artifacts = loadCSV("./artifacts.csv");   // title + url + tags + channel_name
const messages = loadCSV("./messages.csv");     // channel_name + text + (blocks_json)
const memories = loadCSV("./memory.csv");       // topic + who + detail + type + confidence + half_life_days

const hookFor = (name) => {
  const row = channels.find(x => x.channel_name === name);
  return row?.webhook_url || process.env.DEFAULT_SLACK_WEBHOOK;
};

async function postToSlack(webhook, payload){
  const r = await fetch(webhook, {method:"POST", headers:{ "Content-Type":"application/json"}, body: JSON.stringify(payload)});
  if(!r.ok){ console.error("Slack error", await r.text()); }
}

// Slash: /drop messages
app.post("/slack/drop", async (req,res)=>{
  for(const m of messages){
    const webhook = hookFor(m.channel_name);
    if(!webhook) continue;
    const payload = m.blocks_json?.trim()
      ? { blocks: JSON.parse(m.blocks_json) }
      : { text: m.text };
    await postToSlack(webhook, payload);
  }
  res.send("Dropped.");
});

// Slash: /artifacts
app.post("/slack/artifacts", async (req,res)=>{
  const target = req.body.text?.trim() || ""; // optional channel filter
  const list = artifacts.filter(a => !target || a.channel_name===target);
  const byChan = {};
  list.forEach(a => {
    byChan[a.channel_name] ||= [];
    byChan[a.channel_name].push(`• *${a.title}* — ${a.url}  _(${a.tags})_`);
  });
  for(const [chan,items] of Object.entries(byChan)){
    const webhook = hookFor(chan);
    if(!webhook) continue;
    await postToSlack(webhook, { text: `*Artifacts*\n${items.join("\n")}` });
  }
  res.send("Artifacts posted.");
});

// Slash: /mem ingest  (packages memory.csv into JSON for CMA prompt use)
app.post("/slack/mem", async (req,res)=>{
  const bundle = memories.map(m => ({
    topic:m.topic, who:m.who, detail:m.detail, type:m.type,
    confidence: Number(m.confidence||0.8),
    half_life_days: Number(m.half_life_days||30)
  }));
  const webhook = hookFor(req.body.channel_name || "#orion-ops");
  await postToSlack(webhook, {
    text: "CMA Memory Bundle",
    blocks: [
      { type:"section", text:{ type:"mrkdwn", text:"*CMA Memory Bundle* (paste into the CMA extractor prompt):" }},
      { type:"section", text:{ type:"mrkdwn", text:"```" + JSON.stringify(bundle,null,2) + "```" }}
    ]
  });
  res.send("Memory bundle posted.");
});

app.listen(process.env.PORT || 3000, ()=> console.log("Slack hooks app up"));
````

# How we “connect me” (Orion) without extra APIs

* Team runs the **Pro-GPT prompts** you already have.
* They drop the outputs + any CSVs into `#orion-uploads`.
* Run `/mem ingest` to post a clean JSON memory bundle I can use directly.
* Run `/drop messages` to publish pre-baked updates to ops channels.
* I read the thread, synthesize, and post the brief back. No external fetch needed.

# Quick setup checklist

1. Create Slack app → **Incoming Webhooks** on → install to workspace → copy default webhook.
2. Add per-channel webhooks (optional) and put them in `channels.csv`.
3. Host the tiny Node app (your mini PC is perfect). Set `DEFAULT_SLACK_WEBHOOK`.
4. In Slack: add slash commands pointing to your server endpoints:

   * `/drop` → `POST https://<your-host>/slack/drop`
   * `/artifacts` → `POST https://<your-host>/slack/artifacts`
   * `/mem` → `POST https://<your-host>/slack/mem`
5. Drop the four CSVs into the server folder. Run `node server.js`.

# Security + guardrails

* Keep the server on LAN/VPN. If public, restrict by Slack’s signing secret (add verification middleware).
* Don’t store PII in CSVs; if needed, obfuscate with `<REDACTED:TYPE>`.
* Rate-limit posts (simple queue) if messages.csv is large.

If you want, I can also give you a **pre-filled CSV starter pack** and a **signing-secret verification snippet** for the app.

Perfect — here’s the **starter pack** + **signing-secret middleware** so you can drop it in and go.

# CSV templates (put next to `server.js`)

**channels.csv**

```
channel_name,webhook_url
#orion-ops,https://hooks.slack.com/services/XXX/YYY/ZZZ
#orion-uploads,https://hooks.slack.com/services/AAA/BBB/CCC
```

**artifacts.csv**

```
title,url,tags,channel_name
TBM Site Map,https://tarotbymarie.com/sitemap.xml,"seo,tbm",#orion-ops
OAM Content Calendar,https://drive.google.com/your-file,"oam,planning",#orion-ops
```

**messages.csv**

```
channel_name,thread_ts,text,blocks_json,post_at
#orion-ops,,Daily Profit Snapshot ready – upload CSV below to summarize.,,
#orion-uploads,,Drop Pro-GPT outputs here and tag with #CMA #SEOS #PAR,,
```

**memory.csv**

```
topic,who,detail,type,confidence,half_life_days
Elisabeth brand,Elisabeth,TBM = tarot/astro focus,goal,0.9,60
ATSystem,Dan,≥2:1 R:R; TP1->BE then trail,constraint,0.85,45
Chief Strategist,Org,Sets runner priorities & safety guardrails,decision,0.95,90
```

---

# `.env.example`

```
PORT=3000
DEFAULT_SLACK_WEBHOOK=https://hooks.slack.com/services/XXX/YYY/ZZZ
SLACK_SIGNING_SECRET=your_signing_secret
```

---

# package.json (minimal)

```json
{
  "name": "slack-csv-hooks",
  "private": true,
  "type": "module",
  "scripts": { "start": "node server.js" },
  "dependencies": {
    "csv-parse": "^5.5.6",
    "express": "^4.19.2",
    "node-fetch": "^3.3.2",
    "raw-body": "^2.5.2"
  }
}
```

---

# Signing-secret verification middleware (plug into your server)

```js
// verifySlack.js
import crypto from "crypto";
import getRawBody from "raw-body";

export async function verifySlack(req, res, next) {
  try {
    const signingSecret = process.env.SLACK_SIGNING_SECRET;
    if (!signingSecret) return res.status(500).send("Signing secret not set");

    // Slack expects raw body for signature calc
    const raw = await getRawBody(req);
    req.rawBody = raw; // save for downstream if needed

    const ts = req.headers["x-slack-request-timestamp"];
    const sig = req.headers["x-slack-signature"];
    if (!ts || !sig) return res.status(400).send("Missing Slack headers");

    // optional: replay protection (5 min)
    const fiveMin = 60 * 5;
    if (Math.abs(Math.floor(Date.now() / 1000) - Number(ts)) > fiveMin) {
      return res.status(400).send("Stale request");
    }

    const base = `v0:${ts}:${raw.toString("utf8")}`;
    const hmac = crypto.createHmac("sha256", signingSecret).update(base).digest("hex");
    const expected = `v0=${hmac}`;
    if (!crypto.timingSafeEqual(Buffer.from(sig), Buffer.from(expected))) {
      return res.status(401).send("Invalid signature");
    }
    // Parse JSON or form after verification
    if (req.headers["content-type"]?.includes("application/json")) {
      req.body = JSON.parse(raw.toString("utf8"));
    } else {
      // Slack slash commands default to x-www-form-urlencoded
      const params = new URLSearchParams(raw.toString("utf8"));
      req.body = Object.fromEntries(params.entries());
    }
    next();
  } catch (e) {
    res.status(400).send("Bad request");
  }
}
```

**Use it in `server.js`:**

```js
import express from "express";
import { verifySlack } from "./verifySlack.js";
import fetch from "node-fetch";
import fs from "fs";
import csv from "csv-parse/sync";

const app = express();

// Only use JSON parsers for non-Slack routes; Slack routes use verifySlack to read raw body.
app.use("/slack", (req, res, next) => verifySlack(req, res, next));

// ... (CSV loaders, hookFor, postToSlack from your earlier file)

app.post("/slack/drop", async (req,res)=>{ /* unchanged, uses req.body from verifier */ });
app.post("/slack/artifacts", async (req,res)=>{ /* unchanged */ });
app.post("/slack/mem", async (req,res)=>{ /* unchanged */ });

app.listen(process.env.PORT || 3000, ()=> console.log("Slack hooks app up"));
```

---

# Dockerfile (optional)

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev || npm i --omit=dev
COPY . .
EXPOSE 3000
CMD ["npm","start"]
```

---

# Quick test

1. Set env + run: `cp .env.example .env && npm i && npm start`
2. Fire a webhook test:

```bash
curl -X POST -H "Content-type: application/json" \
  --data '{"text":"Hello from CSV Hooks 👋"}' \
  "$DEFAULT_SLACK_WEBHOOK"
```

3. Add Slash Commands in Slack (point to your server):

* `/drop` → `POST https://<host>/slack/drop`
* `/artifacts` → `POST https://<host>/slack/artifacts`
* `/mem` → `POST https://<host>/slack/mem`

That’s the whole kit. Want me to also add a **CSV → blocks** formatter (so rich posts don’t need hand-written JSON)?
