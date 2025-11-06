// server.js
import express from "express";
import { verifySlack } from "./verifySlack.js";
import fetch from "node-fetch";
import fs from "fs";
import csv from "csv-parse/sync";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();

// Only use JSON parsers for non-Slack routes; Slack routes use verifySlack to read raw body.
app.use("/slack", (req, res, next) => verifySlack(req, res, next));

function loadCSV(path) {
  const fullPath = join(__dirname, "../templates", path);
  const raw = fs.readFileSync(fullPath, "utf8");
  return csv.parse(raw, { columns: true, skip_empty_lines: true });
}

const channels = loadCSV("channels.csv");     // name + webhook_url
const artifacts = loadCSV("artifacts.csv");   // title + url + tags + channel_name
const messages = loadCSV("messages.csv");     // channel_name + text + (blocks_json)
const memories = loadCSV("memory.csv");       // topic + who + detail + type + confidence + half_life_days

const hookFor = (name) => {
  const row = channels.find(x => x.channel_name === name);
  return row?.webhook_url || process.env.DEFAULT_SLACK_WEBHOOK;
};

async function postToSlack(webhook, payload) {
  const r = await fetch(webhook, {method:"POST", headers:{ "Content-Type":"application/json"}, body: JSON.stringify(payload)});
  if(!r.ok){ console.error("Slack error", await r.text()); }
}

// Slash: /drop messages
app.post("/slack/drop", async (req,res)=>{
  for(const m of messages){
    const webhook = hookFor(m.channel_name);
    if(!webhook) continue;
    const payload = m.blocks_json?.trim()
      ? { blocks: JSON.parse(m.blocks_json) }
      : { text: m.text };
    await postToSlack(webhook, payload);
  }
  res.send("Dropped.");
});

// Slash: /artifacts
app.post("/slack/artifacts", async (req,res)=>{
  const target = req.body.text?.trim() || ""; // optional channel filter
  const list = artifacts.filter(a => !target || a.channel_name===target);
  const byChan = {};
  list.forEach(a => {
    byChan[a.channel_name] ||= [];
    byChan[a.channel_name].push(`• *${a.title}* — ${a.url}  _(${a.tags})_`);
  });
  for(const [chan,items] of Object.entries(byChan)){
    const webhook = hookFor(chan);
    if(!webhook) continue;
    await postToSlack(webhook, { text: `*Artifacts*\n${items.join("\n")}` });
  }
  res.send("Artifacts posted.");
});

// Slash: /mem ingest  (packages memory.csv into JSON for CMA prompt use)
app.post("/slack/mem", async (req,res)=>{
  const bundle = memories.map(m => ({
    topic:m.topic, who:m.who, detail:m.detail, type:m.type,
    confidence: Number(m.confidence||0.8),
    half_life_days: Number(m.half_life_days||30)
  }));
  const webhook = hookFor(req.body.channel_name || "#orion-ops");
  await postToSlack(webhook, {
    text: "CMA Memory Bundle",
    blocks: [
      { type:"section", text:{ type:"mrkdwn", text:"*CMA Memory Bundle* (paste into the CMA extractor prompt):" }},
      { type:"section", text:{ type:"mrkdwn", text:"```" + JSON.stringify(bundle,null,2) + "```" }}
    ]
  });
  res.send("Memory bundle posted.");
});

app.listen(process.env.PORT || 3000, ()=> console.log("Slack hooks app up"));

