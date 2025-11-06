#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Checking env files..."
for f in env/.env.core env/.env.re env/.env.ecom; do
  if [ ! -f "$f" ]; then
    echo "Missing $f. Copy from ${f}.example and fill secrets."; exit 1;
  fi
done

echo "==> Bringing core stack online..."
docker compose -f deploy/cosmocrat-v1.compose.yml up -d

echo "==> Waiting for services (postgres, langfuse, n8n)..."
sleep 15

echo "==> Importing n8n flows via API (inactive by default)..."
N8N_BASE="${N8N_BASE:-http://ops.localhost/n8n}"
for flow in n8n/flows/*.json; do
  curl -s -X POST "$N8N_BASE/rest/workflows"     -H 'Content-Type: application/json'     --data-binary "@${flow}" >/dev/null
done

echo "==> Posting Slack 'stack online' alert (if webhook is set)..."
if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
  curl -s -X POST "$SLACK_WEBHOOK_URL" -H 'Content-type: application/json'     --data "{"text":"Cosmocrat v1 stack online on $(hostname)"}" >/dev/null || true
fi

echo "==> Done. Open Langfuse and n8n from your ops URL."
