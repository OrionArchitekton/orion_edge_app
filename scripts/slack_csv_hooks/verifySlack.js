// verifySlack.js
import crypto from "crypto";
import getRawBody from "raw-body";

export async function verifySlack(req, res, next) {
  try {
    const signingSecret = process.env.SLACK_SIGNING_SECRET;
    if (!signingSecret) return res.status(500).send("Signing secret not set");

    // Slack expects raw body for signature calc
    const raw = await getRawBody(req);
    req.rawBody = raw; // save for downstream if needed

    const ts = req.headers["x-slack-request-timestamp"];
    const sig = req.headers["x-slack-signature"];
    if (!ts || !sig) return res.status(400).send("Missing Slack headers");

    // optional: replay protection (5 min)
    const fiveMin = 60 * 5;
    if (Math.abs(Math.floor(Date.now() / 1000) - Number(ts)) > fiveMin) {
      return res.status(400).send("Stale request");
    }

    const base = `v0:${ts}:${raw.toString("utf8")}`;
    const hmac = crypto.createHmac("sha256", signingSecret).update(base).digest("hex");
    const expected = `v0=${hmac}`;
    if (!crypto.timingSafeEqual(Buffer.from(sig), Buffer.from(expected))) {
      return res.status(401).send("Invalid signature");
    }
    // Parse JSON or form after verification
    if (req.headers["content-type"]?.includes("application/json")) {
      req.body = JSON.parse(raw.toString("utf8"));
    } else {
      // Slack slash commands default to x-www-form-urlencoded
      const params = new URLSearchParams(raw.toString("utf8"));
      req.body = Object.fromEntries(params.entries());
    }
    next();
  } catch (e) {
    res.status(400).send("Bad request");
  }
}

