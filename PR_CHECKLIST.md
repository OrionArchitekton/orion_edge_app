# Pre-Merge Checklist

## ✅ Security Fixes (Blocking)

- [x] **Tailscale auth key removed** - `cloud-init/cosmocrat-user-data.yaml` now uses `${TS_AUTHKEY}` env var
- [x] **Google Drive SA removed** - `env/drive_sa_base64.txt` replaced with placeholder; documented `GOOGLE_DRIVE_SA_JSON_BASE64` in `docs/ENV_TEMPLATES.md`
- [x] **Variable alignment** - All Slack webhook references use `SLACK_WEBHOOK_URL` consistently
- [x] **Filename fixed** - `docs/Dail_Executive_Summary.md` → `docs/Daily_Executive_Summary.md`
- [x] **Cleanup** - Removed `README_PATCH_v3.txt` with noise

## ✅ Pre-Merge Edge Tests

Run these on your edge host before merging:

### 1) Pull and up stack
```bash
git -C /opt/orion/orion_edge_app fetch && \
git -C /opt/orion/orion_edge_app checkout cosmocrat-v1 && \
git -C /opt/orion/orion_edge_app pull

docker compose -f deploy/cosmocrat-v1.compose.yml up -d
```

### 2) Health (Traefik routes)
```bash
curl -sI http://ops.localhost/langfuse | head -n1     # 200 or 302
curl -sI http://ops.localhost/n8n      | head -n1     # 200
curl -s   http://mcp.localhost/healthz | head -n1     # ok
```

### 3) Langfuse v3 dependencies
```bash
docker ps --format 'table {{.Names}}\t{{.Ports}}' | grep -i clickhouse
docker logs -n 80 langfuse | tail -n 40              # should show ClickHouse connect + listening on :3000
```

### 4) Runner smoke
```bash
docker logs --tail=100 deploy-runner-daily-report-1 | tail -n 30
```

**If any fail:** Double-check `${CLICKHOUSE_URL}`, `${DATABASE_URL}`, `${NEXTAUTH_SECRET}/SALT`, and that `ops.localhost` is resolvable on the edge box.

## ✅ Post-Merge Functional Checks (5 minutes)

### Memory pipeline
```bash
python3 jobs/memory/consolidate.py --commit
bash scripts/memo_recall.sh
```

### Slack webhook sanity
```bash
export SLACK_WEBHOOK_URL="<your incoming webhook>"
node -e "import('./scripts/slack_digest.js').then(m=>m.postSlackDigest({jsonUrl:'http://ops.localhost/reports/2025/11/foo.json',mdUrl:'http://ops.localhost/reports/2025/11/foo.md',date:'2025-11-06',decisions:['Cutover to delta'],actions:['Archive JSONs'],deltas:['Legacy job closed']})).catch(e=>console.error(e))"
```

## 🔐 Security Reminder

**Rotate the Tailscale key** that was previously committed (even though it's been replaced in code).

Ensure `.gitignore` still excludes any real `.env` and SA JSON files.

## 🧭 Merge Plan

1. **Squash-merge PR #14 → main**
2. **Tag release:** `cosmocrat-v1.0.0`
3. **On edge:** `git pull && docker compose -f deploy/cosmocrat-v1.compose.yml up -d`
4. **Import n8n flows** (inactive), wire creds, then activate one by one

## 📋 What's Included

- ✅ Full compose stack (Traefik, Postgres+pgvector, Redis, ClickHouse, Langfuse v3, n8n, vLLM, MCP, memory job, runner-daily-report)
- ✅ Orchestrator kit reorganization (`orchestrator_kit/` canonical structure)
- ✅ Langfuse v3 ClickHouse integration
- ✅ Daily executive summary runner + Slack digest functions
- ✅ Slack CSV hooks mini-app scaffold
- ✅ Operator prompts documentation
- ✅ Memory integration documentation
- ✅ Production deployment guidance (Traefik + DNS)

## 🧱 Go-Forward Guidelines

- **Local dev:** Keep iterating on feature branches; push small PRs (compose, flows, docs separated)
- **Edge is for:** GPU/vLLM tests, ClickHouse/Langfuse performance, Traefik/routing, real n8n creds
- **Never commit secrets:** Update `docs/ENV_TEMPLATES.md` when adding new required env vars

---

**Ready to merge** 🚀

