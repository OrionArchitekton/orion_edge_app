# CSV Schema Documentation

This document defines the CSV schemas used for the no-API GPT Pro/Orion Route workflow. These CSVs enable a lightweight workflow where teammates paste prompts into Pro GPT, and outputs are managed via CSV files and Slack hooks.

## Overview

The CSV-based workflow uses four core schemas:
1. **channels.csv** - Slack channel configuration
2. **artifacts.csv** - Links and resources
3. **messages.csv** - Pre-baked Slack messages
4. **memory.csv** - Durable facts for memory extraction

## Schema Definitions

### 1. channels.csv

Source of truth for Slack channel webhook configuration.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `channel_name` | string | Yes | Slack channel name (e.g., `#orion-ops`) |
| `webhook_url` | string | No | Slack incoming webhook URL (optional, falls back to `DEFAULT_SLACK_WEBHOOK`) |

**Example:**
```csv
channel_name,webhook_url
#orion-ops,https://hooks.slack.com/services/XXX/YYY/ZZZ
#orion-uploads,https://hooks.slack.com/services/AAA/BBB/CCC
```

### 2. artifacts.csv

Links and resources organized by channel and tags.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `title` | string | Yes | Display name for the artifact |
| `url` | string | Yes | Full URL to the resource |
| `tags` | string | Yes | Comma-separated tags (e.g., `"seo,tbm"`) |
| `channel_name` | string | Yes | Target Slack channel |

**Example:**
```csv
title,url,tags,channel_name
TBM Site Map,https://tarotbymarie.com/sitemap.xml,"seo,tbm",#orion-ops
OAM Content Calendar,https://drive.google.com/your-file,"oam,planning",#orion-ops
```

### 3. messages.csv

Pre-baked Slack messages that can be posted via slash commands.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `channel_name` | string | Yes | Target Slack channel |
| `thread_ts` | string | No | Thread timestamp (for replies) |
| `text` | string | Yes | Message text |
| `blocks_json` | string | No | JSON-encoded Slack blocks (optional) |
| `post_at` | string | No | ISO 8601 timestamp for scheduled posting |

**Example:**
```csv
channel_name,thread_ts,text,blocks_json,post_at
#orion-ops,,Daily Profit Snapshot ready – upload CSV below to summarize.,,
#orion-uploads,,Drop Pro-GPT outputs here and tag with #CMA #SEOS #PAR,,
```

### 4. memory.csv

Durable facts extracted from conversations for memory extraction (CMA prompt).

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| `topic` | string | Yes | Topic or subject |
| `who` | string | Yes | Person or entity |
| `detail` | string | Yes | Factual detail |
| `type` | enum | Yes | One of: `goal`, `preference`, `constraint`, `decision`, `blocker` |
| `confidence` | float | Yes | Confidence score (0.0-1.0) |
| `half_life_days` | integer | Yes | Expected relevance duration in days |

**Example:**
```csv
topic,who,detail,type,confidence,half_life_days
Elisabeth brand,Elisabeth,TBM = tarot/astro focus,goal,0.9,60
ATSystem,Dan,≥2:1 R:R; TP1->BE then trail,constraint,0.85,45
Chief Strategist,Org,Sets runner priorities & safety guardrails,decision,0.95,90
```

## Usage

1. **Place CSV files** in the `templates/` directory or alongside the Slack CSV hooks server
2. **Load CSVs** via the Slack CSV hooks server (`scripts/slack_csv_hooks/`)
3. **Use slash commands** to interact with the data:
   - `/drop messages` - Post messages from `messages.csv`
   - `/artifacts` - List artifacts from `artifacts.csv`
   - `/mem ingest` - Post memory bundle from `memory.csv` as JSON

## Integration with Slack CSV Hooks

See `docs/SLACK_CSV_HOOKS.md` for setup instructions and `scripts/slack_csv_hooks/server.js` for implementation details.

## Related Documentation

- `docs/no-api-GPTpro-OrionRoute.md` - Full workflow documentation
- `orchestrator_kit/prompts/operator_prompts.md` - Operator prompts for Pro GPT
- `scripts/slack_csv_hooks/` - Server implementation

