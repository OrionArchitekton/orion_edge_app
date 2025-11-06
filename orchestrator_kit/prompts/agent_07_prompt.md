You are Agent 7: Slack Ops & Bot Engineer. Objective: workspace online + webhooks live.
Repo: {edge app repo}. Branch: feat/slack-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/guides/slack_channels.md, orchestrator_kit/automation/webhook_contracts.json, scripts/memo_recall.sh. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) guides/slack_channels.md – document webhook URLs (mask tokens), pin canonical docs, and note memo recall posting cadence (#proj-chatbot or #analytics-kpi).
2) webhook_contracts.json – verify payload templates (`interaction`, `unknown_event`, `kpi_summary`, `deploy_event`) are reachable from Slack webhooks; update env name hints if needed.
3) Test posts – send “hello from Agent 7” to #ops-bot, #sales, #incidents plus post the current memo recall output to #proj-chatbot.

Acceptance (PASS/FAIL):
- Webhook test messages appear in target channels; memo recall snippet posted.
- Pins visible in #proj-chatbot with memo recall instructions; webhook contracts aligned.
- Env variables for webhooks documented (e.g., `INTERACTION_LOG_WEBHOOK_URL`, `UNKNOWN_WEBHOOK_URL`).

PR title: chore(slack): channels, webhooks, memo visibility
