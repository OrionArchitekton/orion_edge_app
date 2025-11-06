You are Agent 4: Prompt & Tone Designer. Objective: ≤60-word guardrails + fallbacks.
Repo: {edge app repo}. Branch: feat/prompt-refresh (or current).
Touch ONLY these files/folders: orchestrator_kit/artifacts/04_prompts.md, mcp/tools/*.yaml, orchestrator_kit/automation/automation_specs.md. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
- Guardrails block (≤60 words; KB-only; exact deferral; domain replies from faqpacks; no card data) + guidance for memory metadata (`memory_hit`).
- Fallback system prompt v2 + 3 tone variants (friendly, concise, empathetic) aligned with MCP constraints.
- Confirm all MCP tool constraint sections mention the ≤60-word rule + deferral macro (update if required).
- Provide a short evaluation log (5 sample questions) demonstrating prompts obey the guardrails; include Langfuse trace IDs showing memory hits when applicable.

Acceptance (PASS/FAIL):
- Guardrails present; deferral phrase EXACT everywhere, `memory_hit` instructions documented.
- MCP tools reference the same guardrail language; automation specs remain consistent.
- Evaluation evidence attached (Langfuse trace links or test output) proving ≤60-word compliance.

PR title: feat(prompts): guardrails + fallback v2 + tone variants
