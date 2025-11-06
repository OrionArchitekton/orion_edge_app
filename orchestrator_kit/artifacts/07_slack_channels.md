# Orion Intelligence Agency Launch — slack_channels.md

## Workspace Bootstrap

- Create workspace: `{your-agency}.slack.com`.
- Build → Create App → enable **Incoming Webhooks**; bot scopes: `chat:write`, `chat:write.public`, `channels:read`, `files:write`, `links:read`, `reactions:write`, `users:read`.
- Provision service account `automation@agency.com` (Editor on Sheets; limited elsewhere).
- Add integrations: Google Sheets, Landbot/ManyChat, Zapier/Make, Gmail, Calendar, Shopify (optional).
- Store secrets in 1Password/Bitwarden (read-only where possible).
- Create and test webhooks for **#ops-bot**, **#sales**, **#incidents**.
- Pin `guides/message_standards.md`, `guides/roles_matrix.md`, `automation/automation_specs.md`, `guides/incident_runbook.md`, `guides/governance_security.md`.

## Channel Architecture

| Channel            | Purpose                                                     |
| ------------------ | ----------------------------------------------------------- |
| `#proj-chatbot`    | Master project updates, daily standups, decisions.          |
| `#ops-bot`         | Deploy notices, unknown tickets, alerting (webhook target). |
| `#sales`           | Outreach logs, replies, demos, closed-won.                  |
| `#clients-{store}` | Per-client threads; keep transcripts + notes.               |
| `#content-assets`  | FAQs, prompt drafts, marketing copy, creative assets.       |
| `#incidents`       | P0/P1 coordination, postmortems, maintenance mode.          |
| `#analytics-kpi`   | Weekly KPI digest, dashboards, cohort pivots.               |
| `#sandbox`         | Experiments, A/B results, rapid prototyping.                |

**Thread norms:** one thread per artifact/lead/incident.  
**Reactions:** ✅ done · ❓ needs info · 🔁 retry · ⚠️ risk · 📎 doc added.

## Pass/Fail

- **PASS** when: channels exist, app installed with scopes, three webhooks post successfully, service account provisioned, and required pins in place. Otherwise mark **FAIL**.
