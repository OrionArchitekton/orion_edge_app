# Environment Template Guidance (Private Assets)

The repository intentionally ignores `env/*.env` example files. Maintain the canonical templates in your private secrets repo or vault using the guidance below.

1. **Create a mirrored directory** in your secure storage:
   - `env/biz_core.env.template`
   - `env/re_env.template`
   - `env/ecom_env.template`

2. **Minimum required variables (biz_core):**
   - `POSTGRES_URL`
   - `REDIS_URL`
   - `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY`, `LANGFUSE_HOST`
   - `VLLM_BASE_URL` (optional when running local models)
   - `SLACK_WEBHOOK_URL` (required for daily reports and Slack integrations)
   - `WEBHOOK_SECRET` (required for daily reports; generate with `openssl rand -base64 32`)
   - `GOOGLE_DRIVE_SA_JSON_BASE64` (optional; base64-encoded Google Drive service account JSON)
   - Slack webhooks, OpenAI keys, and any commerce integrations

3. **Slack CSV Hooks Integration (Primary - `scripts/slack_csv_hooks/`):**
   - `DEFAULT_SLACK_WEBHOOK` (required; from Slack app → Incoming Webhooks)
   - `SLACK_SIGNING_SECRET` (required; from Slack app → Basic Information → Signing Secret)
   - `PORT` (optional; defaults to 3000)
   - See `scripts/slack_csv_hooks/.env.example` for template
   - See `docs/SLACK_APP_SETUP.md` for setup guide

4. **Slack Full Bot Integration (Optional - `scripts/slack_agent/`):**
   - **Only use if you need:** reading channel messages, DMing users, modals, or App Home
   - `SLACK_APP_TOKEN` (app-level token for Socket Mode, scope: `connections:write`)
   - `SLACK_BOT_TOKEN` (bot token from OAuth v2 install)
   - `WEBHOOK_SIGNING_SECRET` (for webhook fan-out; generate with `openssl rand -base64 32`)
   - `DEFAULT_PLAN_CHANNEL` (default channel for plans, e.g., `#proj-chatbot`)
   - `MCP_BASE_URL` (MCP server URL, default: `http://mcp.localhost`)
   - `OPENAI_API_KEY` (optional; if not set, uses `VLLM_BASE_URL`)
   - `OPENAI_MODEL` (default: `gpt-4o-mini`)
   - `VLLM_BASE_URL` (default: `http://vllm:8000/v1`)
   - See `docs/SLACK_ARCHITECTURE.md` for when to use full bot vs webhook-only

5. **Version the templates** in your secrets repo. During onboarding copy them to the edge host:

   ```bash
   cp /secure-repo/env/biz_core.env.template /opt/cosmocrat_live/env/biz_core.env
   cp /secure-repo/env/re_env.template       /opt/cosmocrat_live/env/re_env
   cp /secure-repo/env/ecom_env.template     /opt/cosmocrat_live/env/ecom_env
   ```

6. **After copying**, run `python3 jobs/memory/consolidate.py --commit` and the `scripts/memo_recall.sh` helper to confirm Langfuse connectivity.

7. **Keep templates in sync** with the live `.env` files. When adding a new variable:
   - Update the template in the secure repo.
   - Notify the orchestrator (Agent 0) to update the onboarding checklist.

> Reminder: never commit `.env` files to this repository. Use the templates only for private distribution.

