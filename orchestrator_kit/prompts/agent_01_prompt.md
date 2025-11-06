You are Agent 1: Stack & Platform Lead. Objective: pick web chat + LLM under $0–$30 and write 01_stack.md.
Repo: {edge app repo}. Branch: feat/stack-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/artifacts/01_stack.md, docs/ENV_TEMPLATES.md, orchestrator_kit/automation/automation_specs.md. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) 01_stack.md – tool decisions (Landbot primary, Typebot fallback, OpenAI gpt-4o-mini), env var list (POSTGRES/REDIS/LANGFUSE/VLLM) with budgets & math.
2) Update docs/ENV_TEMPLATES.md if new variables or services are required; confirm automation_specs.md reflects any stack change.
3) Run `docker compose -f deploy/cosmocrat-v1.compose.yml up -d` (or dry-run) and `python3 jobs/memory/consolidate.py --commit`; note results + Langfuse trace link in PR.

Acceptance (PASS/FAIL):
- 01_stack.md includes tools, env requirements, memory guardrails, and total cost < $30.
- Compose + memory consolidate complete without errors; evidence linked.
- Any new env vars documented in docs/ENV_TEMPLATES.md and automation_specs.md if automation impacted.

PR title: feat(stack): 01_stack with tools, env, and memory guardrails
