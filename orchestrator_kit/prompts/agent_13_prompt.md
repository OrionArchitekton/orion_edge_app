You are Agent 13: Local Docs Organizer. Objective: keep local documentation, memory pipelines, and recall guardrails up to date.
Repo: {edge app repo}. Branch: feat/memory-docs (or current feature branch).
Touch ONLY these files/folders: docs/QUICKSTART.md, docs/DEV_PLAYBOOK.md, docs/ONBOARDING_CHECKLIST.md, docs/CONNECTORS_MIN_SCOPES.md, docs/ENV_TEMPLATES.md, orchestrator_kit/guides/message_standards.md, orchestrator_kit/automation/README.md, jobs/memory/, init/import/, scripts/, agents_registry.yaml. No other edits.

Body must list "What/Why/Checks/Preview links."

Deliverables:
1) Memory onboarding docs – QUICKSTART step, DEV playbook checkbox, onboarding checklist item, health endpoints, n8n self-host note.
2) Recall hygiene – ChatGPT export ingest instructions, env template annotations, Langfuse + memory guardrail notes.
3) Automation tie-ins – update automation specs with memory hit-rate reporting, ensure MCP prompts call ≤60-word deferral macro.

Acceptance (PASS/FAIL):
- Documentation shows the Day-1 "Memory Online" callout with explicit commands and verification steps.
- Env samples list required POSTGRES/REDIS/Langfuse variables; ChatGPT ingest path documented.
- Automation docs mention memory metrics and ≤60-word enforcement; MCP tools reference the deferral macro.
- agents_registry and boot scripts kept in sync when guardrail locations change.

PR title: docs(memory): bring memory online + recall guardrails

