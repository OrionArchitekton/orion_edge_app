## governance\_security.md

**Principles:** least privilege; disclose bot; explicit consent for email capture; no payment data.

**Access:** separate service accounts; revoke on offboarding; rotate keys **every 90 days**.

**Data:** store only Q/A metadata + consented email. Strip order IDs from logs on request.

**Compliance cues:** Messenger 24‑hour rule; accessibility (keyboard focus, contrast); CAN‑SPAM for follow‑ups.

**Secrets:** 1Password/Bitwarden vault; share read‑only; never in Sheets.

**Logging & Retention:** redact PII; 90‑day log retention; monthly export.

**Budget guardrails:** flag if tools >\$30/mo; propose free/low‑cost alternatives; approve in #proj‑chatbot.

**Audits:** monthly permission review; red‑team replay of top 10 unknowns; dependency license check.

##### PASS/FAIL — governance\_security.md

- PASS if: vault live, service acct in use, keys rotated, audit log recorded monthly, ≤\$30 tool alerting in place. Else FAIL.
