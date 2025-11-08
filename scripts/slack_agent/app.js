// app.js - Slack Bolt app with MCP agent integration and webhook fan-out
import pkg from "@slack/bolt";
const { App, LogLevel } = pkg;
import crypto from "crypto";
import fs from "fs";
import fetch from "node-fetch";
import { draftPlanWithAgent, runPlanStreamViaMCP } from "./agent-client.js";
import { getBotToken } from "./token-manager.js";

// Load channel mappings
const CHANNEL_MAP_BY_NAME = JSON.parse(
  fs.readFileSync("./channel-map.json", "utf8")
).found || {};

// Load webhook mappings
const WEBHOOK_MAP = JSON.parse(
  fs.readFileSync("./webhook-map.json", "utf8")
);

// Helper: Get channel ID from name
function channelIdFrom(name) {
  return CHANNEL_MAP_BY_NAME[name] || null;
}

// Helper: Sign webhook payload
function sign(secret, payload) {
  const hmac = crypto.createHmac("sha256", secret);
  hmac.update(JSON.stringify(payload));
  return hmac.digest("hex");
}

// Helper: Fan-out to webhooks for a channel
async function fanoutByName(channelName, payload) {
  const webhooks = WEBHOOK_MAP[channelName] || [];
  if (webhooks.length === 0) return;

  const secret = process.env.WEBHOOK_SIGNING_SECRET;
  const signature = secret ? sign(secret, payload) : null;
  const idempotencyKey = crypto.randomUUID();

  const requests = webhooks.map((url) =>
    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(signature && { "X-Webhook-Signature": signature }),
        "X-Idempotency-Key": idempotencyKey,
      },
      body: JSON.stringify(payload),
    }).catch((err) => {
      console.error(`Webhook fan-out failed for ${url}:`, err);
      return null;
    })
  );

  await Promise.all(requests);
}

// Helper: Post message and mirror to webhooks
async function postAndMirror(client, channelId, channelName, text, blocks = null) {
  const result = await client.chat.postMessage({
    channel: channelId,
    text,
    blocks,
  });

  // Mirror to webhooks
  await fanoutByName(channelName, {
    type: "message",
    channel: channelName,
    text,
    blocks,
    ts: result.ts,
    user: result.message?.user || "bot",
  });

  return result;
}

// Initialize Slack app
const app = new App({
  socketMode: true,
  appToken: process.env.SLACK_APP_TOKEN,
  token: process.env.SLACK_BOT_TOKEN,
  logLevel: LogLevel.INFO,
});

// Store plans in memory (in production, use Redis or database)
const plans = new Map();

// /plan slash command
app.command("/plan", async ({ command, ack, respond, client }) => {
  await ack();

  const channelId = command.channel_id;
  const channelName = Object.keys(CHANNEL_MAP_BY_NAME).find(
    (name) => CHANNEL_MAP_BY_NAME[name] === channelId
  ) || `#unknown-${channelId}`;

  try {
    // Open modal for plan creation
    await client.views.open({
      trigger_id: command.trigger_id,
      view: {
        type: "modal",
        callback_id: "plan_submit",
        title: {
          type: "plain_text",
          text: "Create Plan",
        },
        submit: {
          type: "plain_text",
          text: "Draft Plan",
        },
        close: {
          type: "plain_text",
          text: "Cancel",
        },
        blocks: [
          {
            type: "input",
            block_id: "goal",
            label: {
              type: "plain_text",
              text: "Goal",
            },
            element: {
              type: "plain_text_input",
              action_id: "goal_input",
              placeholder: {
                type: "plain_text",
                text: "What do you want to achieve?",
              },
              multiline: true,
            },
          },
          {
            type: "input",
            block_id: "env",
            label: {
              type: "plain_text",
              text: "Environment",
            },
            element: {
              type: "plain_text_input",
              action_id: "env_input",
              placeholder: {
                type: "plain_text",
                text: "e.g., production, staging",
              },
              initial_value: "production",
            },
          },
        ],
      },
    });
  } catch (error) {
    console.error("Error opening modal:", error);
    await respond({
      text: `Error: ${error.message}`,
      response_type: "ephemeral",
    });
  }
});

// Handle modal submission
app.view("plan_submit", async ({ ack, view, client, body }) => {
  await ack();

  const goal =
    view.state.values.goal.goal_input.value ||
    "No goal specified";
  const env =
    view.state.values.env.env_input.value || "production";
  const userId = body.user.id;
  const channelId = view.private_metadata || body.user.id;

  try {
    // Draft plan using agent
    const plan = await draftPlanWithAgent({ env, goal, authorId: userId });

    // Store plan
    plans.set(plan.id, { ...plan, channelId, userId, env, goal });

    // Format plan for Slack
    const blocks = [
      {
        type: "header",
        text: {
          type: "plain_text",
          text: `Plan: ${plan.id}`,
        },
      },
      {
        type: "section",
        text: {
          type: "mrkdwn",
          text: `*Goal:* ${goal}\n*Environment:* ${env}`,
        },
      },
      {
        type: "divider",
      },
    ];

    plan.steps.forEach((step, idx) => {
      blocks.push({
        type: "section",
        text: {
          type: "mrkdwn",
          text: `*Step ${idx + 1}:* ${step.title}\n${step.summary || ""}`,
        },
      });
    });

    blocks.push({
      type: "actions",
      elements: [
        {
          type: "button",
          text: {
            type: "plain_text",
            text: "Run Plan",
          },
          style: "primary",
          action_id: "approve_run",
          value: plan.id,
        },
        {
          type: "button",
          text: {
            type: "plain_text",
            text: "Cancel",
          },
          action_id: "cancel_plan",
          value: plan.id,
        },
      ],
    });

    const channelName = Object.keys(CHANNEL_MAP_BY_NAME).find(
      (name) => CHANNEL_MAP_BY_NAME[name] === channelId
    ) || `#unknown-${channelId}`;

    await postAndMirror(
      client,
      channelId,
      channelName,
      `Plan drafted: ${plan.id}`,
      blocks
    );
  } catch (error) {
    console.error("Error drafting plan:", error);
    await client.chat.postMessage({
      channel: channelId,
      text: `Error drafting plan: ${error.message}`,
    });
  }
});

// Handle "Run Plan" button
app.action("approve_run", async ({ ack, action, client, body }) => {
  await ack();

  const planId = action.value;
  const plan = plans.get(planId);

  if (!plan) {
    await client.chat.postMessage({
      channel: body.channel.id,
      text: `Plan ${planId} not found`,
    });
    return;
  }

  const channelId = plan.channelId;
  const channelName = Object.keys(CHANNEL_MAP_BY_NAME).find(
    (name) => CHANNEL_MAP_BY_NAME[name] === channelId
  ) || `#unknown-${channelId}`;

  // Post initial status
  const statusMsg = await postAndMirror(
    client,
    channelId,
    channelName,
    `Running plan: ${planId}...`
  );

  try {
    // Stream plan execution
    for await (const update of runPlanStreamViaMCP(planId)) {
      const statusText =
        update.phase === "running"
          ? `⏳ ${update.title}...`
          : update.phase === "succeeded"
          ? `✅ ${update.title}`
          : update.phase === "failed"
          ? `❌ ${update.title}: ${update.summary}`
          : `📝 ${update.title}`;

      await client.chat.update({
        channel: channelId,
        ts: statusMsg.ts,
        text: `Running plan: ${planId}\n\n${statusText}`,
      });

      if (update.phase === "failed") {
        break;
      }
    }

    await client.chat.update({
      channel: channelId,
      ts: statusMsg.ts,
      text: `✅ Plan ${planId} completed`,
    });
  } catch (error) {
    console.error("Error running plan:", error);
    await client.chat.update({
      channel: channelId,
      ts: statusMsg.ts,
      text: `❌ Plan ${planId} failed: ${error.message}`,
    });
  }
});

// Handle "Cancel Plan" button
app.action("cancel_plan", async ({ ack, action, client, body }) => {
  await ack();
  plans.delete(action.value);
  await client.chat.postMessage({
    channel: body.channel.id,
    text: `Plan ${action.value} cancelled`,
  });
});

// Handle message events (mirror to webhooks)
app.message(async ({ message, client }) => {
  // Skip bot messages to avoid loops
  if (message.subtype === "bot_message" || message.bot_id) {
    return;
  }

  const channelId = message.channel;
  const channelName = Object.keys(CHANNEL_MAP_BY_NAME).find(
    (name) => CHANNEL_MAP_BY_NAME[name] === channelId
  );

  if (channelName) {
    await fanoutByName(channelName, {
      type: "message",
      channel: channelName,
      text: message.text,
      user: message.user,
      ts: message.ts,
    });
  }
});

// Start the app
(async () => {
  await app.start();
  console.log("⚡️ Orion Agent app running (Slack + webhook fan-out)");
})();
