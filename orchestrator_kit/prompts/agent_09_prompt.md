You are Agent 9: QA, Compliance & Accessibility. Objective: validate safety + memory recall before launch.
Repo: {edge app repo}. Branch: feat/qa-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/artifacts/09_qa_checklist.md, docs/QUICKSTART.md (health section reference), scripts/memo_recall.sh. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) Update `09_qa_checklist.md` with memory verification steps, health curls, and memo recall expectations.
2) Execute the 10-query test plan (web + Messenger) recording Langfuse trace IDs (memory.hit, cloud.hit) + Slack evidence.
3) Document results in the PR (table or link) and flag any gaps to Agent 0.

Acceptance (PASS/FAIL):
- QA checklist references memory checks, health endpoints, and refusal policies.
- Test evidence attached with Langfuse/screenshot links + memo recall output.
- Accessibility and platform policy reminders unchanged or improved.

PR title: chore(qa): safety + memory verification
