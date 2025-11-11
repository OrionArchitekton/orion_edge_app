# Slack CSV Hooks Server

Lightweight Slack integration server for CSV-driven workflows. Uses Incoming Webhooks + Slash Commands (no OAuth tokens required).

## Quick Start

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Configure `.env`:**
   - Set `DEFAULT_SLACK_WEBHOOK` (from Slack app settings)
   - Set `SLACK_SIGNING_SECRET` (from Slack app → Basic Information → Signing Secret)
   - Optionally set `PORT` (defaults to 3000)

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Start server:**
   ```bash
   npm start
   ```

5. **Configure Slack slash commands:**
   - Go to your Slack app → Slash Commands
   - Create three commands pointing to your server:
     - `/drop` → `POST https://<your-host>/slack/drop`
     - `/artifacts` → `POST https://<your-host>/slack/artifacts`
     - `/mem` → `POST https://<your-host>/slack/mem`

## Environment Setup

See `.env.example` for required variables:
- `DEFAULT_SLACK_WEBHOOK` (required) - Default webhook URL
- `SLACK_SIGNING_SECRET` (required) - Slack signing secret for request verification
- `PORT` (optional) - Server port, defaults to 3000

## Slack App Configuration

See `docs/SLACK_APP_SETUP.md` for detailed step-by-step instructions.

**Quick checklist:**
1. Create Slack app at https://api.slack.com/apps
2. Enable **Incoming Webhooks** (do NOT enable Events API)
3. Install app to workspace
4. Copy webhook URL → set as `DEFAULT_SLACK_WEBHOOK`
5. Copy Signing Secret → set as `SLACK_SIGNING_SECRET`
6. Add slash commands (`/drop`, `/artifacts`, `/mem`)

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

## CSV Files

The server expects CSV files in `templates/` directory (relative to repo root):
- `templates/channels.csv` - Channel webhook mappings
- `templates/artifacts.csv` - Artifact links and resources
- `templates/messages.csv` - Pre-baked messages to post
- `templates/memory.csv` - Memory items for CMA prompts

See `orchestrator_kit/automation/csv_schemas.md` for schema details.

## Testing

1. **Test webhook connectivity:**
   ```bash
   curl -X POST -H "Content-type: application/json" \
     --data '{"text":"Hello from CSV Hooks 👋"}' \
     "$DEFAULT_SLACK_WEBHOOK"
   ```

2. **Test slash commands:** Use the configured commands in Slack channels

## Docker Deployment

```bash
cd scripts/slack_csv_hooks
docker build -t slack-csv-hooks .
docker run -d \
  -p 3000:3000 \
  -e DEFAULT_SLACK_WEBHOOK="..." \
  -e SLACK_SIGNING_SECRET="..." \
  slack-csv-hooks
```

## Troubleshooting

- **"Signing secret not set":** Ensure `SLACK_SIGNING_SECRET` is in `.env`
- **"Missing Slack headers":** Verify slash command URLs point to `/slack/*` endpoints
- **CSV not found:** Ensure CSV files exist in `templates/` directory
- **Webhook errors:** Check webhook URL is valid and app is installed to workspace

## Security

- **Signing secret verification:** All `/slack/*` routes verify Slack request signatures
- **Replay protection:** Requests older than 5 minutes are rejected
- **Network security:** Keep server on LAN/VPN; if public, use HTTPS and restrict by IP

## Architecture

This is a webhook-first implementation. See `docs/SLACK_ARCHITECTURE.md` for:
- Why webhook-only vs full bot
- When to upgrade to full bot capabilities
- Security considerations

## Related Documentation

- `docs/SLACK_CSV_HOOKS.md` - Full setup guide
- `docs/SLACK_ARCHITECTURE.md` - Architecture decision document
- `docs/SLACK_APP_SETUP.md` - Slack app configuration guide
- `orchestrator_kit/automation/csv_schemas.md` - CSV schema definitions
