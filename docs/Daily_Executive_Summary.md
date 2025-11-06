1. Add the block to your active compose file

Open the file that is actually being used by Docker
(/opt/orion/orion_edge_app/cosmocrat_v1_loaded/cosmocrat_v1_loaded/deploy/cosmocrat-v1.compose.yml)

Append this section just above the last volumes: line:

  runner-daily-report:
    image: ghcr.io/orionarchitekton/orion-runner:latest
    restart: always
    environment:
      TZ: America/Los_Angeles
      EXEC_ANALYST_URL: https://edge.orionapexcapital.com/api/analyst
      STORAGE_PATH: /data/reports
      SLACK_WEBHOOK_URL: ${SLACK_WEBHOOK_URL}
      JOB_NAME: exec-daily-v3
    volumes:
      - ./data/reports:/data/reports
      - ./data/conversations:/data/conversations
    command: ["python3", "runner.py", "--daily"]


Save and close.

2. Bring it up
cd /opt/orion/orion_edge_app/cosmocrat_v1_loaded/cosmocrat_v1_loaded/deploy
sudo docker compose -f cosmocrat-v1.compose.yml up -d runner-daily-report
sudo docker ps | grep runner


That will pull the image (about 100 MB) and start the scheduled runner.

3. Confirm it’s working

Check the container log once to confirm the first daily summary seeded:

sudo docker logs --tail=30 deploy-runner-daily-report-1

Step: add two secrets to your core env so the daily runner + webhook can sign and notify.

cd /opt/orion/orion_edge_app/cosmocrat_v1_loaded/cosmocrat_v1_loaded
# 1) set Slack webhook (paste your URL after the =, no quotes)
sudo sed -i 's/^SLACK_WEBHOOK_URL=.*/SLACK_WEBHOOK_URL=/' env/.env.core || true
echo 'SLACK_WEBHOOK_URL=' | sudo tee -a env/.env.core >/dev/null
sudo nano env/.env.core   # put your Slack webhook URL on the SLACK_WEBHOOK_URL= line

# 2) generate a shared secret for HMAC signatures
SECRET=$(openssl rand -base64 32)
echo "WEBHOOK_SECRET=${SECRET}" | sudo tee -a env/.env.core

1) Env + secret

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
cd /opt/cosmocrat_live 2>/dev/null || cd /opt/orion/orion_edge_app/cosmocrat_v1_loaded/cosmocrat_v1_loaded

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
