# Operator Prompts for Pro GPT

This document contains ready-made prompts for use with ChatGPT Pro or similar LLM interfaces. These prompts enable a no-API workflow where teammates paste prompts into Pro GPT, and outputs are synthesized and managed via CSV files and Slack hooks.

## Usage

1. Copy a prompt below
2. Replace placeholders (e.g., `{topic}`, `{constraints}`) with actual values
3. Paste into ChatGPT Pro or similar interface
4. Use outputs with the Slack CSV hooks workflow (see `docs/SLACK_CSV_HOOKS.md`)

## Prompts

### 1. Research Request (Universal)

```
Act as a senior analyst. Research **{topic}**. Prioritize primary sources, last 90 days, and contradictory viewpoints. Produce:

* Key findings (5 bullets, source-tagged)
* What matters (3 bullets)
* Risks/unknowns (3 bullets)
* Actionable next steps (≤5)
Return: a) 150-word exec summary, b) source list with URLs.
```

**Example:** Replace `{topic}` with "AI chatbot ROI for e-commerce"

### 2. Conversation Memory Extractor (for CMA)

```
From the text below, extract durable facts vs. ephemeral chatter. Tag each memory with:

* `topic`, `who`, `confidence (0–1)`, `half_life_days`
* `type`: {preference, constraint, goal, decision, blocker}
Output JSON array only.
TEXT: `{paste thread or notes}`
```

**Example:** Paste a Slack thread or meeting notes in `{paste thread or notes}`

### 3. Decision Brief (Fast)

```
You are Chief Strategist. Decide **{yes/no or pick A/B}**. Constraints: {constraints}. Criteria: {criteria}. Return:

* Decision (1 line)
* Rationale (3 bullets)
* Assumptions to watch (3)
* Next 3 actions (owners + ETA)
≤200 words.
```

**Example:**
- `{yes/no or pick A/B}` → "Should we use OpenAI or local LLM?"
- `{constraints}` → "Budget < $30/mo, latency < 2s"
- `{criteria}` → "Cost, performance, reliability"

### 4. SEO Quick Sweep (Page or Site)

```
Be a Technical SEO. Audit **{URL or sitemap}**. Output:

* Title/meta fixes (max 5)
* Internal links (max 5, with anchors)
* Schema to add (JSON-LD blocks)
* 3 content briefs (H2/H3 + FAQs)
Keep it surgical. 300 words max + code blocks for schema.
```

**Example:** Replace `{URL or sitemap}` with "https://tarotbymarie.com" or sitemap URL

### 5. Profit Snapshot (Manual Mode)

```
From the data below (revenue, ad spend, ops costs), calculate:

* Net profit, ROAS, CAC, CTR (if given), top/worst channel
* 3 scale moves, 3 cuts (with $ impact estimate)
Return a 120-word CFO brief + a small table.
DATA:
`{paste numbers or table}`
```

**Example:** Paste CSV or table data in `{paste numbers or table}`

### 6. A/B Personalization Eval (Memory vs Cold)

```
Given outputs A (with memory) and B (without), score on: Relevance, Brevity, Specificity, Actionability (1–5 each). Decide winner + 2 lines why. Return JSON:
`{winner: "A|B", scores: {A:{...}, B:{...}}, notes: "…"}`
```

**Example:** Provide two chatbot responses - one using memory, one without

### 7. PII/Safety Scrubber

```
Redact emails, phones, addresses, bank/IDs from the text, replace with `<REDACTED:TYPE>`. Keep meaning. Return clean text + list of redactions.
TEXT:
`{paste}`
```

**Example:** Paste customer conversation or sensitive data in `{paste}`

### 8. Content Brief (TBM/OAM)

```
Create a 7-day content plan for **{brand}** targeting **{ICP}**. Channels: TikTok, IG, YT Shorts, LinkedIn. For each day: hook, 3 beats, CTA, hashtag set, and repurpose notes. Keep each item ≤5 lines.
```

**Example:**
- `{brand}` → "Tarot by Marie"
- `{ICP}` → "Women 25-45 interested in spirituality"

## JSON Schemas

### Memory Item Schema

```json
{
  "topic": "string",
  "who": "string",
  "detail": "string",
  "type": "goal|preference|constraint|decision|blocker",
  "confidence": 0.85,
  "half_life_days": 30
}
```

### A/B Score Schema

```json
{
  "winner": "A",
  "scores": {
    "A": {
      "relevance": 5,
      "brevity": 4,
      "specificity": 5,
      "actionability": 5
    },
    "B": {
      "relevance": 3,
      "brevity": 5,
      "specificity": 3,
      "actionability": 3
    }
  },
  "notes": "A used user's stated goal + next step."
}
```

## Handoff Format

When sending outputs back to the orchestrator:

**Subject:** `[RUNNER] Topic – Date`

**Body:**
* Objective: …
* Inputs: links/files
* Outputs from Pro GPT: (paste)
* Constraints/Deadline: …

**Attachments:** any source exports/screens

## Return Formats

### Strategy One-Pager
* Decision + Why (≤3 bullets)
* Playbook (steps 1–5)
* Risks/mitigations
* KPIs + next checkpoint date

### SEO/TBM Pack
* Fix list (PR-ready)
* 3 briefs
* Schema blocks
* Internal-link map

### Finance Mini-Report
* Profit table
* Scale/Cut calls (with $ deltas)
* Watch items

## Related Documentation

- `docs/no-api-GPTpro-OrionRoute.md` - Full workflow documentation
- `docs/SLACK_CSV_HOOKS.md` - Slack CSV hooks setup
- `orchestrator_kit/automation/csv_schemas.md` - CSV schema definitions

