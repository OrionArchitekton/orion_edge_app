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
