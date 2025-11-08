# Local Runner Setup - Pass-Through to MCP

The `runner-daily-report` service is configured to use a local `runner.py` script that calls the MCP service locally for pass-through. This allows you to test and develop locally before transitioning to the full runner.

## 1. Create the local runner script

First, create the runner directory and script:

```bash
cd /opt/orion/orion_edge_app
mkdir -p jobs/runner
```

Create `jobs/runner/runner.py` with this content:

```python
#!/usr/bin/env python3
"""
Local daily report runner - calls MCP API locally for pass-through.
"""
import os
import sys
import json
import requests
from datetime import datetime
from pathlib import Path

def call_mcp_tool(tool_name: str, input_data: dict) -> dict:
    """Call an MCP tool via the local MCP service."""
    mcp_url = os.environ.get("MCP_BASE_URL", "http://mcp:8080")
    url = f"{mcp_url}/tools/{tool_name}"
    try:
        response = requests.post(url, json={"input": input_data}, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Failed to call MCP tool {tool_name}: {e}", file=sys.stderr)
        return {"error": str(e)}

def save_report(data: dict, date: str, storage_path: str) -> tuple:
    """Save report as JSON and Markdown."""
    storage = Path(storage_path)
    year, month = date[:4], date[5:7]
    report_dir = storage / year / month
    report_dir.mkdir(parents=True, exist_ok=True)
    
    json_path = report_dir / f"daily-{date}.json"
    with open(json_path, "w") as f:
        json.dump(data, f, indent=2)
    
    md_path = report_dir / f"daily-{date}.md"
    with open(md_path, "w") as f:
        f.write(f"# Executive Daily Report — {date}\n\n")
        f.write(f"Generated: {datetime.now().isoformat()}\n\n")
        f.write("## Summary\n\n")
        f.write(json.dumps(data, indent=2))
    
    json_url = f"/reports/{year}/{month}/daily-{date}.json"
    md_url = f"/reports/{year}/{month}/daily-{date}.md"
    return json_url, md_url

def post_to_slack(json_url: str, md_url: str, date: str, data: dict):
    """Post digest to Slack."""
    webhook_url = os.environ.get("SLACK_WEBHOOK_URL")
    if not webhook_url:
        print("[WARN] SLACK_WEBHOOK_URL not set, skipping Slack notification")
        return
    
    def fmt(lst):
        return "\n".join([f"{i+1}. {t}" for i, t in enumerate(lst)]) if lst else "_None_"
    
    decisions = data.get("decisions", [])
    actions = data.get("actions", [])
    deltas = data.get("deltas", [])
    
    payload = {
        "blocks": [
            {"type": "header", "text": {"type": "plain_text", "text": f"Executive Daily — {date}"}},
            {"type": "section", "text": {"type": "mrkdwn", "text": f"*Decisions*\n{fmt(decisions)}"}},
            {"type": "section", "text": {"type": "mrkdwn", "text": f"*Actions (next 48h)*\n{fmt(actions)}"}},
            {"type": "section", "text": {"type": "mrkdwn", "text": f"*Deltas*\n{fmt(deltas)}"}},
            {"type": "actions", "elements": [
                {"type": "button", "text": {"type": "plain_text", "text": "Open JSON"}, "url": json_url},
                {"type": "button", "text": {"type": "plain_text", "text": "Open Markdown"}, "url": md_url}
            ]}
        ]
    }
    
    try:
        requests.post(webhook_url, json=payload, timeout=10).raise_for_status()
        print(f"[INFO] Posted digest to Slack")
    except Exception as e:
        print(f"[ERROR] Failed to post to Slack: {e}", file=sys.stderr)

def main():
    job_name = os.environ.get("JOB_NAME", "exec-daily-v3")
    storage_path = os.environ.get("STORAGE_PATH", "/data/reports")
    date = datetime.now().strftime("%Y-%m-%d")
    
    if "--date" in sys.argv:
        date_idx = sys.argv.index("--date")
        if date_idx + 1 < len(sys.argv):
            date = sys.argv[date_idx + 1]
    
    print(f"[{datetime.now()}] Runner started: {job_name}")
    print(f"  Date: {date}")
    
    if "--daily" not in sys.argv:
        print("[INFO] Not in daily mode, exiting")
        return
    
    print(f"[INFO] Calling MCP tool: ops.report.daily")
    result = call_mcp_tool("ops.report.daily", {"date": date})
    
    if "error" in result:
        print(f"[ERROR] MCP tool failed: {result['error']}")
        sys.exit(1)
    
    print(f"[INFO] Saving reports to {storage_path}")
    json_url, md_url = save_report(result, date, storage_path)
    print(f"[INFO] Reports saved: {json_url}, {md_url}")
    
    post_to_slack(json_url, md_url, date, result)
    print(f"[INFO] Daily report completed for {date}")

if __name__ == "__main__":
    main()
```

Make it executable:
```bash
chmod +x jobs/runner/runner.py
```

## 2. Start the service

The compose file is already configured to mount the local script. Start it:

```bash
cd /opt/orion/orion_edge_app/deploy
docker compose -f cosmocrat-v1.compose.yml up -d runner-daily-report
docker ps | grep runner
```

The service will:
- Mount `jobs/runner/runner.py` 
- Call MCP service locally at `http://mcp:8080`
- Save reports to `data/reports/{YYYY}/{MM}/`
- Post to Slack if `SLACK_WEBHOOK_URL` is set

## 3. Confirm it's working

Check the container log:

```bash
docker logs --tail=30 deploy-runner-daily-report-1

# Or find the container name:
docker ps | grep runner
docker logs <container-name>
```

You should see output like:
```
[INFO] Runner started: exec-daily-v3
[INFO] Calling MCP tool: ops.report.daily
[INFO] Reports saved: /reports/2025/11/daily-2025-11-28.json
[INFO] Daily report completed for 2025-11-28
```

Verify reports are generated:
```bash
ls -la /opt/orion/orion_edge_app/data/reports/
```

## 4. Configure Slack (Optional)

```bash
cd /opt/orion/orion_edge_app

# Export as environment variable:
export SLACK_WEBHOOK_URL="your-webhook-url-here"

# Or add to compose file environment section (already configured)
# The compose file will pick up ${SLACK_WEBHOOK_URL} from your environment

# Generate a shared secret for HMAC signatures (if needed):
SECRET=$(openssl rand -base64 32)
echo "WEBHOOK_SECRET=${SECRET}"
```

Then restart the service to pick up the new environment:
```bash
docker compose -f deploy/cosmocrat-v1.compose.yml restart runner-daily-report
```

## 5. Transitioning to Full Runner

When you're ready to use the full runner implementation:

### Option A: Keep using local script (recommended for development)
Just update `jobs/runner/runner.py` with your enhanced implementation. The compose file will automatically use the updated script.

### Option B: Use a custom Docker image
Create `jobs/runner/Dockerfile`:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY runner.py /app/
RUN pip install --no-cache-dir requests
CMD ["python3", "runner.py", "--daily"]
```

Update compose file:
```yaml
runner-daily-report:
  build:
    context: ./jobs/runner
    dockerfile: Dockerfile
  # ... rest of config
```

### Option C: Use registry image (when available)
```yaml
runner-daily-report:
  image: ghcr.io/orionarchitekton/orion-runner:latest
  # ... rest of config
```

---

## Reference: Slack Digest Implementation

### Env + secret

SLACK_WEBHOOK_URL: (new rotated URL)

Optional: SLACK_CHANNEL_OVERRIDE (if you later move off the incoming-webhook’s default)

2) Minimal sender (Node)
import fetch from "node-fetch";

export async function postSlackDigest({jsonUrl, mdUrl, date, decisions=[], actions=[], deltas=[]}) {
  const fmtList = (arr) => arr.length ? arr.map((t,i)=>`${i+1}. ${t}`).join("\n") : "_None_";
  const blocks = [
    { type: "header", text: { type: "plain_text", text: `Executive Daily — ${date}` } },
    { type: "section", text: { type: "mrkdwn", text: `*Decisions*\n${fmtList(decisions)}` } },
    { type: "section", text: { type: "mrkdwn", text: `*Actions (next 48h)*\n${fmtList(actions)}` } },
    { type: "section", text: { type: "mrkdwn", text: `*Deltas*\n${fmtList(deltas)}` } },
    {
      type: "actions",
      elements: [
        { type: "button", text: { type: "plain_text", text: "Open JSON" }, url: jsonUrl },
        { type: "button", text: { type: "plain_text", text: "Open Markdown" }, url: mdUrl }
      ]
    }
  ];

  const res = await fetch(process.env.SLACK_WEBHOOK_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ blocks })
  });
  if (!res.ok) throw new Error(`Slack webhook failed: ${res.status} ${await res.text()}`);
}

3) Minimal sender (Python)
import os, json, urllib.request

def post_slack_digest(json_url, md_url, date, decisions=None, actions=None, deltas=None):
    decisions = decisions or []
    actions = actions or []
    deltas = deltas or []

    def fmt(lst):
        return "\n".join([f"{i+1}. {t}" for i,t in enumerate(lst)]) if lst else "_None_"

    payload = {
        "blocks": [
            {"type":"header","text":{"type":"plain_text","text":f"Executive Daily — {date}"}},
            {"type":"section","text":{"type":"mrkdwn","text":f"*Decisions*\n{fmt(decisions)}"}},
            {"type":"section","text":{"type":"mrkdwn","text":f"*Actions (next 48h)*\n{fmt(actions)}"}},
            {"type":"section","text":{"type":"mrkdwn","text":f"*Deltas*\n{fmt(deltas)}"}},
            {"type":"actions","elements":[
                {"type":"button","text":{"type":"plain_text","text":"Open JSON"},"url":json_url},
                {"type":"button","text":{"type":"plain_text","text":"Open Markdown"},"url":md_url}
            ]}
        ]
    }
    req = urllib.request.Request(
        os.environ["SLACK_WEBHOOK_URL"],
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type":"application/json"},
        method="POST"
    )
    with urllib.request.urlopen(req) as r:
        if r.status != 200:
            raise RuntimeError(f"Slack webhook failed: {r.status} {r.read()}")

4) Digest fields we’ll send

Decisions → the decisions[].text

Actions (next 48h) → from actions_due[] filtered by due in next 2 days + status != done

Deltas → short bullets from deltas.new/updated/closed

Buttons → links to the saved JSON/MD in /reports/{YYYY}/{MM}/…

5) cURL sanity check (after you rotate)
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"text":"Executive Daily: webhook connectivity OK"}'



















  ------------------------------------------------------------------
  got it — you have a **standard boot schema**: every agent reads the **`0_START_WORK_TEMPLATE.md`** first, then the **guardrails** come in early. perfect.

### tiny outline

* add a **registry entry** for the new agent with pointers to the **start template** and **guardrails**.
* drop a **boot stub** that always concatenates `0_START_WORK_TEMPLATE.md` + `GUARDRAILS.md` → `01_agent_prompt.md`.
* pause, then you can point me to the real guardrails file(s) and I’ll wire the exact paths.

we’ll do **one small step** now and stop.

---

## STEP — add registry + boot stub (non-destructive)

Run this in the root that contains `agent_workspaces/`:

```bash
cd /opt/orion/orion_edge_app

# 1) ensure a registry exists; append/update docs_organizer
cat > agents_registry.yaml <<'YAML'
agents:
  - id: docs_organizer
    folder: agent_workspaces/docs_organizer
    index: auto        # will be resolved to the numeric folder via symlink
    role: "Local Docs Organizer"
    status: active
    boot:
      start_template: "agent_workspaces/0_START_WORK_TEMPLATE.md"
      guardrails:     "agent_workspaces/GUARDRAILS.md"   # placeholder; we’ll swap to your real path
      prompt_out:     "01_agent_prompt.md"
YAML

# 2) create a tiny boot script the orchestrator (or you) can run anytime
cat > agent_workspaces/docs_organizer/boot_prompt.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$DIR/../.." && pwd)"

START="${ROOT}/agent_workspaces/0_START_WORK_TEMPLATE.md"
GUARDS="${ROOT}/agent_workspaces/GUARDRAILS.md"      # <— we’ll point this to your real guardrails file
OUT="${DIR}/01_agent_prompt.md"

touch "$OUT"
: > "$OUT"
[ -f "$START" ]  && { echo "<!-- START TEMPLATE -->" >> "$OUT"; cat "$START" >> "$OUT"; echo -e "\n" >> "$OUT"; }
[ -f "$GUARDS" ] && { echo "<!-- GUARDRAILS -->"     >> "$OUT"; cat "$GUARDS" >> "$OUT"; echo -e "\n" >> "$OUT"; }

echo "[boot_prompt] wrote $(wc -w < "$OUT") words to $OUT"
SH
chmod +x agent_workspaces/docs_organizer/boot_prompt.sh

# 3) show where things landed
echo "== registry =="
sed -n '1,40p' agents_registry.yaml
echo
echo "== boot stub =="
sed -n '1,40p' agent_workspaces/docs_organizer/boot_prompt.sh
```

**Your turn:** reply **“boot ready”** and tell me **where your real guardrails live** (path/filename).
I’ll update the registry + boot to point to that exact file, then we run `boot_prompt.sh` once to materialize `01_agent_prompt.md` for the new agent.

10/28/2025 – 19:44 PDT
