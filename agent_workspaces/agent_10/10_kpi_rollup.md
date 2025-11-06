# Orion Intelligence Agency Launch — 10_kpi_rollup.md

## Weekly KPI Process (Agent 10)

- **Cadence:** Every Friday at 09:00 America/Los_Angeles.
- **Inputs:** `Interactions`, `Unknowns`, `Leads`, `Weekly Summary` tabs (see 05_sheets_setup.md).
- **Delivery:** Slack `#analytics-kpi` + client email using KPI summary prompt.

## Metrics to Track

| Metric                | Definition & Formula                                                                                                  |
| --------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `interactions`        | `=COUNTIFS(Interactions!$A:$A,">="&week_start,Interactions!$A:$A,"<"&week_end,Interactions!$B:$B,client)`             |
| `answered_in_chat`    | KB hits + fallback responses without handoff.                                                                        |
| `resolution_rate`     | `=IFERROR(answered_in_chat / interactions, 0)`                                                                       |
| `leads`               | `=COUNTIFS(Leads!$A:$A,">="&week_start,Leads!$A:$A,"<"&week_end,Leads!$B:$B,client)`                                 |
| `handoffs`            | `=COUNTIFS(Interactions!$A:$A,">="&week_start,Interactions!$A:$A,"<"&week_end,Interactions!$B:$B,client,Interactions!$I:$I,TRUE)` |
| `avg_first_response_ms` | `=AVERAGE(FILTER(Interactions!$H:$H,Interactions!$A:$A>=week_start,Interactions!$A:$A<week_end,Interactions!$B:$B=client))` |
| `top_topics`          | Use pivot/`QUERY` on `Interactions!E:E` filtered by week to extract top 3.                                            |
| `wow_interactions`    | Week-over-week delta vs previous row for the same client.                                                             |
| `wow_resolution_rate` | Week-over-week change vs previous row.                                                                                |

Insert formulas into the **Weekly Summary** tab so Zap A4 can upsert rows automatically.

## KPI Email Prompt

```
Draft a weekly client report using these metrics:
- Week of {{week_start}} – {{week_end}}
- Interactions: {{interactions}}
- Resolution rate: {{resolution_rate}}%
- Leads captured: {{leads}}
- Handoffs: {{handoffs}}
- Top topics: {{top_topics}}
- Notable unknowns: {{unknowns_summary}}

Structure:
1) Quick thank you + context.
2) Bulleted metrics.
3) One recommendation for KB updates.
4) One recommendation for next experiment (A/B, Messenger, etc.).
Keep to 120 words, friendly, factual, and policy-safe (no guarantees). Close with “Reply if you need changes or want a walkthrough.”
```

## Slack Digest Payload (`kpi_summary`)

```json
{
  "type": "kpi_summary",
  "client": "{{client_name}}",
  "week_start": "{{week_start}}",
  "week_end": "{{week_end}}",
  "interactions": "{{interactions}}",
  "resolution_rate": "{{resolution_rate}}",
  "leads": "{{leads}}",
  "handoffs": "{{handoffs}}",
  "top_topics": ["{{topic_1}}","{{topic_2}}","{{topic_3}}"],
  "wow_interactions": "{{wow_interactions}}",
  "wow_resolution_rate": "{{wow_resolution_rate}}",
  "notes": "{{summary_sentence}}"
}
```

## Checklist Before Sending

1. Confirm Zaps A1–A2 logged the week’s activity (spot-check new rows).  
2. Validate formulas in **Weekly Summary** updated (no `#VALUE!`).  
3. Review OpenAI draft → ensure ≤120 words, no promises; edit if necessary.  
4. Post JSON payload via Slack webhook; confirm message delivered.  
5. Email stakeholders (client + internal) with same summary text.  
6. Archive KPI row link in `#proj-chatbot` for traceability.

## Pass/Fail

- **PASS** when metrics formulas are correct, Zap A4 sends on schedule, and Slack/email digests include interactions, resolution rate, leads, handoffs, top topics, and action recommendation.  
- **FAIL** if digest missing, formulas broken, or metrics out of sync.
