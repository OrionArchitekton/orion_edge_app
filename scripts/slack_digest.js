import fetch from "node-fetch";

/**
 * Post an executive daily digest to Slack
 * @param {Object} options
 * @param {string} options.jsonUrl - URL to the JSON report
 * @param {string} options.mdUrl - URL to the Markdown report
 * @param {string} options.date - Date string (e.g., "2025-11-28")
 * @param {string[]} [options.decisions=[]] - List of decisions
 * @param {string[]} [options.actions=[]] - List of actions for next 48h
 * @param {string[]} [options.deltas=[]] - List of deltas/changes
 */
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

