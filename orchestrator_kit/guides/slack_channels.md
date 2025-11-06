### Slack Workspace Bootstrap (execute)

-   Create workspace: **{your‑agency}.slack.com**
-   App: **Build → Create App**; enable **Incoming Webhooks**; Bot scopes: `chat:write`, `chat:write.public`, `channels:read`, `files:write`, `links:read`, `reactions:write`, `users:read`.
-   Create channels (below) + pin **message\_standards.md**.
-   Create **3 webhooks** → post to **#ops‑bot**, **#sales**, **#incidents**.
-   Connect Zapier/Make: Google Sheets, ManyChat/Landbot, Gmail, Calendar, Shopify (optional).
-   Service account: [**automation@agency.com**](mailto:automation@agency.com) for Sheets/Zaps.
-   Secrets in 1Password/Bitwarden (read‑only where possible).

### Channel Architecture

-   **#proj‑chatbot** — master project updates (daily summaries, decisions)
-   **#ops‑bot** — live bot events (deploys, unknowns, errors)
-   **#sales** — outreach, replies, demos, closed‑won
-   **#clients‑{store}** — per‑client thread (one per store)
-   **#content‑assets** — FAQs, prompts, copies, images
-   **#incidents** — outages, P0/P1 coordination
-   **#analytics‑kpi** — weekly KPIs, dashboards
-   **#sandbox** — experiments & A/B notes

**Thread norms:** one thread per artifact/lead/incident.\\
**Reactions:** ✅ done, 🧩 needs‑info, 🔁 retry, ⚠️ risk, 📝 doc‑added.

**Default Pins:** links to **roles\_matrix.md**, **message\_standards.md**, **automation\_specs.md**, **incident\_runbook.md**, **governance\_security.md**.

##### PASS/FAIL — slack\_channels.md

-   PASS if: app installed with scopes, channels exist, 3 webhooks working (test posts), pins added, service account created, vault shared read‑only. Else FAIL.
