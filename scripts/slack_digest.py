#!/usr/bin/env python3
"""
Post an executive daily digest to Slack.

Usage:
    python3 scripts/slack_digest.py --json-url <url> --md-url <url> --date <date> --decisions "item1" "item2" --actions "action1" --deltas "delta1"
"""

import os
import json
import urllib.request
import argparse
from typing import List, Optional


def fmt(lst: List[str]) -> str:
    """Format a list as numbered items or '_None_' if empty."""
    return "\n".join([f"{i+1}. {t}" for i, t in enumerate(lst)]) if lst else "_None_"


def post_slack_digest(
    json_url: str,
    md_url: str,
    date: str,
    decisions: Optional[List[str]] = None,
    actions: Optional[List[str]] = None,
    deltas: Optional[List[str]] = None,
) -> None:
    """
    Post an executive daily digest to Slack.

    Args:
        json_url: URL to the JSON report
        md_url: URL to the Markdown report
        date: Date string (e.g., "2025-11-28")
        decisions: List of decisions (default: [])
        actions: List of actions for next 48h (default: [])
        deltas: List of deltas/changes (default: [])
    """
    decisions = decisions or []
    actions = actions or []
    deltas = deltas or []

    payload = {
        "blocks": [
            {"type": "header", "text": {"type": "plain_text", "text": f"Executive Daily — {date}"}},
            {"type": "section", "text": {"type": "mrkdwn", "text": f"*Decisions*\n{fmt(decisions)}"}},
            {"type": "section", "text": {"type": "mrkdwn", "text": f"*Actions (next 48h)*\n{fmt(actions)}"}},
            {"type": "section", "text": {"type": "mrkdwn", "text": f"*Deltas*\n{fmt(deltas)}"}},
            {
                "type": "actions",
                "elements": [
                    {"type": "button", "text": {"type": "plain_text", "text": "Open JSON"}, "url": json_url},
                    {"type": "button", "text": {"type": "plain_text", "text": "Open Markdown"}, "url": md_url}
                ]
            }
        ]
    }

    webhook_url = os.environ.get("SLACK_WEBHOOK_URL")
    if not webhook_url:
        raise RuntimeError("SLACK_WEBHOOK_URL environment variable not set")

    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    with urllib.request.urlopen(req) as r:
        if r.status != 200:
            raise RuntimeError(f"Slack webhook failed: {r.status} {r.read()}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Post executive daily digest to Slack")
    parser.add_argument("--json-url", required=True, help="URL to JSON report")
    parser.add_argument("--md-url", required=True, help="URL to Markdown report")
    parser.add_argument("--date", required=True, help="Date string (e.g., 2025-11-28)")
    parser.add_argument("--decisions", nargs="*", default=[], help="List of decisions")
    parser.add_argument("--actions", nargs="*", default=[], help="List of actions for next 48h")
    parser.add_argument("--deltas", nargs="*", default=[], help="List of deltas/changes")

    args = parser.parse_args()
    post_slack_digest(
        json_url=args.json_url,
        md_url=args.md_url,
        date=args.date,
        decisions=args.decisions,
        actions=args.actions,
        deltas=args.deltas,
    )

