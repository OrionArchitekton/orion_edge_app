#!/usr/bin/env bash
set -euo pipefail

# This helper removes the legacy `agent_workspaces/agent_*` directories once all
# tooling has switched to the canonical `orchestrator_kit/` paths. The script is
# intentionally idempotent and will abort if it detects files that are still in
# use (non-empty prompts, guardrail shims, or custom agent folders).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${ROOT_DIR}/agent_workspaces"

if [[ ! -d "${WORK_DIR}" ]]; then
  echo "[cleanup] agent_workspaces/ not found; nothing to do." >&2
  exit 0
fi

# guard: only run when there are no custom files besides README + shims.
readarray -t extra_files < <(find "${WORK_DIR}" -mindepth 1 -maxdepth 1 \
  ! -name 'README.md' \
  ! -name '0_START_WORK_TEMPLATE.md' \
  ! -name 'GUARDRAILS.md' \
  ! -name 'docs_organizer' \
  ! -name '.gitkeep' )

if (( ${#extra_files[@]} > 0 )); then
  echo "[cleanup] Found additional folders/files under agent_workspaces/:" >&2
  printf '  %s\n' "${extra_files[@]}" >&2
  echo "[cleanup] Remove or migrate these manually before running the cleanup." >&2
  exit 1
fi

echo "[cleanup] Removing legacy agent_workspaces assets..."
rm -rf "${WORK_DIR}/docs_organizer" "${WORK_DIR}/agent_"*

cat <<'MSG'
[cleanup] Legacy agent_workspaces/ contents removed.

- Ensure guardrail tooling points to orchestrator_kit/.
- Update any downstream scripts/pipelines that referenced agent_workspaces/.
- Commit this change when ready.
MSG

