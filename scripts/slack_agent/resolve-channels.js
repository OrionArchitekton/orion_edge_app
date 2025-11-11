// resolve-channels.js
import fs from "fs";
import pkg from "@slack/web-api";
const { WebClient } = pkg;

const bot = new WebClient(process.env.SLACK_BOT_TOKEN);

(async () => {
  const channelsCfg = JSON.parse(fs.readFileSync("./channels.json", "utf8"));
  const wanted = channelsCfg.names.map((n) => n.replace(/^#/, ""));
  const found = {};

  let cursor = undefined;
  do {
    const resp = await bot.conversations.list({
      exclude_archived: true,
      limit: 1000,
      cursor,
    });

    for (const ch of resp.channels ?? []) {
      if (!ch?.name || !ch?.id) continue;
      if (wanted.includes(ch.name)) {
        found[`#${ch.name}`] = ch.id;
      }
    }
    cursor = resp.response_metadata?.next_cursor || undefined;
  } while (cursor);

  // Fill in missing with placeholder to help debugging
  const missing = wanted
    .filter((n) => !found[`#${n}`])
    .map((n) => `#${n}`);

  fs.writeFileSync(
    "./channel-map.json",
    JSON.stringify({ found, missing }, null, 2)
  );

  if (missing.length) {
    console.warn("Not found (check spelling or invite the bot):", missing);
  } else {
    console.log("All channels resolved.");
  }
})();
