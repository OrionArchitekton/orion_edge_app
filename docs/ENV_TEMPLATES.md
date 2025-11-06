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
   - Slack webhooks, OpenAI keys, and any commerce integrations

3. **Version the templates** in your secrets repo. During onboarding copy them to the edge host:

   ```bash
   cp /secure-repo/env/biz_core.env.template /opt/cosmocrat_live/env/biz_core.env
   cp /secure-repo/env/re_env.template       /opt/cosmocrat_live/env/re_env
   cp /secure-repo/env/ecom_env.template     /opt/cosmocrat_live/env/ecom_env
   ```

4. **After copying**, run `python3 jobs/memory/consolidate.py --commit` and the `scripts/memo_recall.sh` helper to confirm Langfuse connectivity.

5. **Keep templates in sync** with the live `.env` files. When adding a new variable:
   - Update the template in the secure repo.
   - Notify the orchestrator (Agent 0) to update the onboarding checklist.

> Reminder: never commit `.env` files to this repository. Use the templates only for private distribution.

