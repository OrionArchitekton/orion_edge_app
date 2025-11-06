## incident\_runbook.md

**Severity:** P1 (no replies), P2 (degraded), P3 (minor).

**Steps:**

1. Acknowledge in **#incidents** (template below).
2. Triage: platform status, auth, rate-limit, webhooks, memo recall output (`scripts/memo_recall.sh`).
3. Mitigate: switch to **Maintenance Mode** message, notify client.
4. Capture root cause + rollback; rerun memo recall to confirm recovery.
5. Postmortem ≤24h.

**Maintenance Mode (customer‑facing):**\
“Sorry—our assistant is briefly down. Please email support@{store}. We’ll reply ASAP.”

**P1 Template** (also in message\_standards.md)

```
[INCIDENT P1] {client} – {symptom}
Start: {UTC time}
Impact: {orders/chat affected}
Workaround: {msg or rollback}
Owner: {name}
Next update: {+30m}
```

**Escalation ladder:** Agent 12 → Agent 7 → Agent 0.

**SLOs:** P1 ack ≤5m; P2 ack ≤30m; P3 ack same‑day.

##### PASS/FAIL — incident\_runbook.md

- PASS if: #incidents exists + on-call noted, MM message deployed, P1 drill completed, memo recall captured during incident, postmortem template used in last incident. Else FAIL.
