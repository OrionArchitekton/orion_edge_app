# E-Commerce Chatbot Launch Kit

This kit provides the single source of truth for the chatbot launch. All artifacts are organized to align with the 7-day execution plan detailed in the [Orchestrator Kit](./chatbot_launch_role_slackkit_v_1.1.md).

Start here: `000_START_WORK_TEMPLATE.md` — copy this when beginning any agent task.

## 7-Day Execution Plan

The launch is structured around a 7-day plan, with specific goals, agent tasks, and deliverables for each day.

-   **Day 1: Foundation & Comms Online**
    -   **Goal:** Workspace, stack choices, and data backbone live.
    -   **Agents:** 7, 1, 5, 0
    -   **Deliverables:** `slack_channels.md`, `01_stack.md`, `05_sheets_setup.md`

-   **Day 2: Knowledge & Flow Skeleton**
    -   **Goal:** Seed FAQs and flow map with unknown path.
    -   **Agents:** 2, 3, 4, 1, 5
    -   **Deliverables:** `02_scope_faq.csv`, `03_flow_spec.json`, `04_prompts.md`

-   **Day 3: Automation & Triage Live**
    -   **Goal:** All interactions logged; unknowns become Slack tickets.
    -   **Agents:** 6, 7, 12, 9
    -   **Deliverables:** `automation_specs.md`, `webhook_contracts.json`, `incident_runbook.md`

-   **Day 4: v0.1 (Internal) + Deploy Hooks**
    -   **Goal:** Internal v0.1 live with deploy notice & WCAG quick pass.
    -   **Agents:** 3, 4, 6, 9, 10, 0
    -   **Deliverables:** `03_flow_spec.json`, `04_prompts.md`, `10_kpi_rollup.md`

-   **Day 5: Sales & Channels Ready**
    -   **Goal:** Demoable bot + lead capture & Messenger fallback.
    -   **Agents:** 8, 11, 6, 5
    -   **Deliverables:** `08_integrations.md`, `11_sales_playbook.md`

-   **Day 6: Dry Run & Client Demo**
    -   **Goal:** End-to-end rehearsal + first external demo.
    -   **Agents:** 9, 0, 11, 12, 2
    -   **Deliverables:** `09_qa_checklist.md`, `02_scope_faq.csv`

-   **Day 7: MVP Launch & Review/Pricing**
    -   **Goal:** Production MVP live; pricing & M1 plan set.
    -   **Agents:** 1, 3, 6, 10, 0
    -   **Deliverables:** Pricing docs, M1 Plan, `docs/kit/marketing/orion_ai_bots_marketing_kit_v1.md`, `docs/kit/faqpacks/beauty.json`, `docs/kit/faqpacks/pets.json`, `docs/kit/faqpacks/home_garden.json`

## Roles & Responsibilities

Agent roles, responsibilities, and dependencies are defined in the [Roles Matrix (`orchestrator_kit/roles_matrix.md`)](../../orchestrator_kit/roles_matrix.md).

## Contribution Guidelines

To maintain quality and consistency, all contributions must follow the guidelines and checklists outlined in the [Pull Request Guidelines](./PULL_REQUEST_GUIDELINES.md). Before submitting a deliverable, please ensure it meets all PASS criteria for that artifact. Vertical packs live in docs/kit/faqpacks/*.json. Use scripts/faqpack_to_csv.js to convert a pack to CSV.
