# Orion Intelligence Agency Launch — 12_monitoring.md

## On-Call & Escalation

- Primary on-call: **Agent 12** (SRE/Incident Manager).  
- Escalation ladder: Agent 12 → Agent 7 (Slack Ops) → Agent 0 (Program Manager).  
- SLO targets:
  - P1 (bot down / no replies): acknowledge ≤5 min, update every 30 min.
  - P2 (degraded functionality): acknowledge ≤30 min, hourly updates.
  - P3 (minor issue): acknowledge same business day.

## Monitoring Signals

- Slack `#ops-bot` alerts from Zap A2/A5 and Workers Cron (deploys, unknowns, KPI).
- Sheets `Unknowns` backlog (open tickets >24h triggers follow-up).
- Landbot/ManyChat status pages; OpenAI usage dashboard (cap warnings at 80%).
- Optional: UptimeRobot check on `/widget.js` and `/api/fallback` (Cloudflare Workers).
- Daily memo recall output from `scripts/memo_recall.sh` (memory hit-rate + cloud hit-rate posted to Slack).
- Health endpoints: MCP (`curl -s http://localhost/mcp/healthz`), vLLM (`curl -s http://localhost:8000/v1/models`), Langfuse UI (`http://<edge-ip>:3000/`), n8n UI (`http://<edge-ip>:5678/`).

## Incident Playbook

1. **Acknowledge** in `#incidents` using the template below.  
2. **Triage:** platform status, auth failures, rate limits, webhook errors, upstream API status.  
3. **Mitigate:** enable Maintenance Mode message, disable affected Zap, notify client via Slack/email.  
4. **Remediate:** roll back to previous flow/prompt, purge bad deploy, or throttle traffic.  
5. **Verify memo:** run `scripts/memo_recall.sh` and confirm memory/cloud rates recovered; capture Langfuse trace links.  
6. **Postmortem:** complete within 24 hours; capture root cause, fix, prevention.

**Maintenance Mode message (customer-facing):**
> “Sorry—our assistant is briefly down. Please email support@[store]; we’ll reply ASAP.”

Optional Messenger footer: “Replies may be delayed outside the 24-hour window.”

**Incident template (`#incidents`):**

```
[INCIDENT P1] {client} – {symptom}
Start: {utc_timestamp}
Impact: {orders/chat affected}
Workaround: {maintenance mode / rollback}
Owner: {agent}
Next update: {+30m}
```

## Postmortem Outline

1. Summary & timeline.  
2. Customer impact (orders, lost leads).  
3. Root cause (software, vendor, config).  
4. Mitigation & recovery steps.  
5. Follow-up actions (owner + due date).  
6. Detection improvements (monitoring or alert rule).  
7. Lessons learned.

## Pass/Fail

- **PASS** if on-call roster documented, maintenance message staged, alerting path active (`#ops-bot` and `#incidents`), daily memo recall monitored, and last incident drill/postmortem recorded with memory stats.  
- **FAIL** otherwise.
