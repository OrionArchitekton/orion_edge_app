#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import os, json, requests
from datetime import datetime, timedelta, timezone

PG_URL = os.environ.get("POSTGRES_URL")
LF_HOST = os.environ.get("LANGFUSE_HOST", os.environ.get("LANGFUSE_BASE_URL", "http://localhost:3000"))
LF_PUBLIC = os.environ.get("LANGFUSE_PUBLIC_KEY")
LF_SECRET = os.environ.get("LANGFUSE_SECRET_KEY")

total_memories = "n/a"
memories_24h = "n/a"

try:
    import psycopg
except ImportError as exc:  # pragma: no cover
    print(f"[memo-recall] psycopg not available: {exc}")
else:
    if PG_URL:
        try:
            with psycopg.connect(PG_URL) as conn, conn.cursor() as cur:
                cur.execute("""
                    CREATE TABLE IF NOT EXISTS memory_semantic_log (
                        id bigserial primary key,
                        created_at timestamptz default now(),
                        summary text
                    )
                """)
                cur.execute("SELECT COUNT(*) FROM memory_semantic_log")
                total_memories = cur.fetchone()[0]
                cur.execute("SELECT COUNT(*) FROM memory_semantic_log WHERE created_at >= now() - interval '24 hours'")
                memories_24h = cur.fetchone()[0]
        except Exception as err:  # pragma: no cover
            print(f"[memo-recall] postgres query failed: {err}")

since = (datetime.now(timezone.utc) - timedelta(hours=24)).isoformat()
traces = []
hit_rate = "n/a"
cloud_rate = "n/a"

if LF_PUBLIC and LF_SECRET:
    try:
        resp = requests.get(
            f"{LF_HOST.rstrip('/')}/api/public/traces",
            auth=(LF_PUBLIC, LF_SECRET),
            params={"limit": 200, "order": "desc", "created_after": since},
            timeout=10,
        )
        resp.raise_for_status()
        payload = resp.json()
        traces = payload.get("data", payload if isinstance(payload, list) else [])
    except Exception as err:  # pragma: no cover
        print(f"[memo-recall] langfuse fetch failed: {err}")

if traces:
    hits = sum(1 for t in traces if (t.get("metadata") or {}).get("memory", {}).get("hit"))
    hit_rate = f"{(hits / len(traces)) * 100:.1f}%"
    cloud_hits = sum(1 for t in traces if (t.get("metadata") or {}).get("cloud", {}).get("hit"))
    cloud_rate = f"{(cloud_hits / len(traces)) * 100:.1f}%"

summary = (
    f"[memo-recall] memories={total_memories} (+{memories_24h} /24h) | "
    f"memory.hit={hit_rate} | cloud.hit={cloud_rate}"
)

print(summary)
PY

