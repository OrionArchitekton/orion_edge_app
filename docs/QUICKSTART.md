# Quickstart

## Step 1 — Prepare the Host
- Boot USB installer → Ubuntu Server.
- `tailscale up --authkey=<key> --ssh` so the edge box is reachable.
- `git clone` (or unpack the shipped archive) into `/opt/cosmocrat_live` or `/opt/orion/orion_edge_app`.

## Step 2 — Bring the Stack Online
- Fill environment files (see `docs/DEV_PLAYBOOK.md` and `docs/ENV_TEMPLATES.md`).
- `docker compose -f deploy/cosmocrat-v1.compose.yml up -d`.

## Step 3 — Automations & n8n
- Open `http://<edge-ip>:5678/` and create the owner account (self-hosted n8n; no Cloud required).
- Import bundled workflows:
  - `n8n import:workflow --input n8n/flows/post_setup.n8n.json`
  - repeat for any additional files under `n8n/flows/*.json`.
- Wire credentials, mark critical flows **Active**, run the built-in smoke tests.

## Step 4 — Memory Online
1. Create a Langfuse project; record `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY`, `LANGFUSE_HOST`.
2. Set required environment variables (typically in `env/biz_core.env`):
   - `POSTGRES_URL`
   - `REDIS_URL`
   - `LANGFUSE_PUBLIC_KEY`, `LANGFUSE_SECRET_KEY`, `LANGFUSE_HOST`
   - `VLLM_BASE_URL` (optional if you serve a local model)
3. **Langfuse v3 requirement:** The compose file includes ClickHouse (required for v3). Ensure `CLICKHOUSE_PASSWORD` in `deploy/cosmocrat-v1.compose.yml` is set to a secure value (not `change-me`). Also set `NEXTAUTH_SECRET` and `SALT` to non-default values.
4. Consolidate memories:

   ```bash
   python3 jobs/memory/consolidate.py --commit
   ```

   This writes episodic + semantic memories into Postgres/pgvector and links traces → memories in Langfuse.
4. (Optional) ChatGPT export ingest: drop JSON exports into `init/import/`, then run

   ```bash
   python3 jobs/memory/consolidate.py --import init/import/ --commit
   ```

5. Verify recall:
   - Ask the bot something that exists only in the imported pack.
   - Confirm the Langfuse trace shows `memory.hit=true` and links to the stored memory.

## Step 5 — Daily Report Runner (Optional)

1. Set Slack webhook environment variables in `env/biz_core.env`:
   - `SLACK_WEBHOOK_URL` (your Slack incoming webhook URL)
   - `WEBHOOK_SECRET` (generate with `openssl rand -base64 32`)

2. Start the daily report runner:

   ```bash
   docker compose -f deploy/cosmocrat-v1.compose.yml up -d runner-daily-report
   ```

3. Verify the runner is working:

   ```bash
   docker logs --tail=30 deploy-runner-daily-report-1
   ```

## Health Checks
- MCP API: `curl -s http://localhost/mcp/healthz`
- vLLM models: `curl -s http://localhost:8000/v1/models`
- Langfuse UI: `http://<edge-ip>:3000/`

## Production Deployment (Traefik + DNS)

For production deployments, update Traefik host rules in `deploy/cosmocrat-v1.compose.yml`:

1. **Replace `ops.localhost` and `mcp.localhost`** with your actual domain names:
   - `ops.localhost` → `ops.yourdomain.com`
   - `mcp.localhost` → `mcp.yourdomain.com`

2. **Add DNS A records** pointing to your edge host IP:
   ```
   ops.yourdomain.com  →  <edge-ip>
   mcp.yourdomain.com  →  <edge-ip>
   ```

3. **Update `NEXTAUTH_URL`** in the Langfuse service to match your domain:
   ```yaml
   NEXTAUTH_URL: https://ops.yourdomain.com/langfuse
   ```

4. **For HTTPS**, add a Traefik Let's Encrypt certificate resolver (see Traefik docs) or use a reverse proxy with SSL termination.

Example Traefik labels for production:
```yaml
labels:
  - traefik.http.routers.langfuse.rule=Host(`ops.yourdomain.com`) && PathPrefix(`/langfuse`)
  - traefik.http.routers.langfuse.tls.certresolver=letsencrypt
```
