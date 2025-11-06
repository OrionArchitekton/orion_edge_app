#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$DIR/../.." && pwd)"

START="${ROOT}/agent_workspaces/0_START_WORK_TEMPLATE.md"
GUARDS="${ROOT}/agent_workspaces/GUARDRAILS.md"      # swap to orchestrator_kit guardrails once tooling updated
OUT="${DIR}/01_agent_prompt.md"

touch "$OUT"
: > "$OUT"

if [ -f "$START" ]; then
  echo "<!-- START TEMPLATE -->" >> "$OUT"
  cat "$START" >> "$OUT"
  echo >> "$OUT"
fi

if [ -f "$GUARDS" ]; then
  echo "<!-- GUARDRAILS -->" >> "$OUT"
  cat "$GUARDS" >> "$OUT"
  echo >> "$OUT"
fi

echo "[boot_prompt] wrote $(wc -w < "$OUT") words to $OUT"

