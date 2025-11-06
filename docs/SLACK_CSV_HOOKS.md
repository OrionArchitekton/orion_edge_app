# Slack CSV Hooks Setup

This document describes how to set up and use the Slack CSV hooks server for the no-API GPT Pro/Orion Route workflow.

## Overview

The Slack CSV hooks server provides slash commands that interact with CSV files to post messages, list artifacts, and ingest memory bundles. This enables a lightweight workflow without requiring full Slack API access.

## Prerequisites

1. Node.js 20+ installed
2. Slack workspace with Incoming Webhooks enabled
3. CSV files in `templates/` directory (see `orchestrator_kit/automation/csv_schemas.md`)

## Setup

1. **Create Slack app and webhook:**
   - Go to https://api.slack.com/apps
   - Create a new app → **Incoming Webhooks** → Activate
   - Install to workspace → Copy webhook URL

2. **Configure environment:**
   ```bash
   cd scripts/slack_csv_hooks
   cp .env.example .env
   # Edit .env and set:
   # - DEFAULT_SLACK_WEBHOOK (your webhook URL)
   # - SLACK_SIGNING_SECRET (from Slack app settings → Basic Information → Signing Secret)
   # - PORT (optional, defaults to 3000)
   ```

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Start the server:**
   ```bash
   npm start
   ```

5. **Configure Slack slash commands:**
   - Go to your Slack app → Slash Commands → Create New Command
   - Add three commands:
     - `/drop` → `POST https://<your-host>/slack/drop`
     - `/artifacts` → `POST https://<your-host>/slack/artifacts`
     - `/mem` → `POST https://<your-host>/slack/mem`

## Usage

### `/drop` - Post Messages

Posts all messages from `templates/messages.csv` to their configured channels.

```
/drop
```

### `/artifacts` - List Artifacts

Posts a formatted list of artifacts from `templates/artifacts.csv`. Optionally filter by channel:

```
/artifacts #orion-ops
```

### `/mem` - Memory Bundle

Posts a JSON bundle from `templates/memory.csv` formatted for the CMA (Conversation Memory Extractor) prompt:

```
/mem
```

## CSV File Locations

The server expects CSV files in `templates/` directory (relative to repo root):
- `templates/channels.csv`
- `templates/artifacts.csv`
- `templates/messages.csv`
- `templates/memory.csv`

See `orchestrator_kit/automation/csv_schemas.md` for schema details.

## Security

- **Signing secret verification:** All `/slack/*` routes verify Slack request signatures
- **Replay protection:** Requests older than 5 minutes are rejected
- **Network security:** Keep server on LAN/VPN; if public, use HTTPS and restrict by IP

## Docker Deployment (Optional)

```bash
cd scripts/slack_csv_hooks
docker build -t slack-csv-hooks .
docker run -d \
  -p 3000:3000 \
  -e DEFAULT_SLACK_WEBHOOK="..." \
  -e SLACK_SIGNING_SECRET="..." \
  slack-csv-hooks
```

## Testing

1. **Test webhook connectivity:**
   ```bash
   curl -X POST -H "Content-type: application/json" \
     --data '{"text":"Hello from CSV Hooks 👋"}' \
     "$DEFAULT_SLACK_WEBHOOK"
   ```

2. **Test slash commands:** Use the configured commands in Slack

## Troubleshooting

- **"Signing secret not set":** Ensure `SLACK_SIGNING_SECRET` is in `.env`
- **"Missing Slack headers":** Verify slash command URLs point to `/slack/*` endpoints
- **CSV not found:** Ensure CSV files exist in `templates/` directory
- **Webhook errors:** Check webhook URL is valid and app is installed to workspace

## Related Documentation

- `orchestrator_kit/automation/csv_schemas.md` - CSV schema definitions
- `docs/no-api-GPTpro-OrionRoute.md` - Full workflow documentation
- `orchestrator_kit/prompts/operator_prompts.md` - Operator prompts

