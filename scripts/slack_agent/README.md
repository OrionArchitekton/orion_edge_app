# Slack Agent Integration

Slack Bolt app that integrates with the MCP (Multi-Agent Control Plane) to draft and execute plans via Slack slash commands, with webhook fan-out for message mirroring.

## Features

- **Slash Commands**: ` p/plan` to create and execute agent plans
- **Modal Interface**: Interactive plan creation with goal and environment inputs
- **MCP Integration**: Drafts plans using LLM with MCP tool context
- **Plan Execution**: Streams plan execution updates to Slack
- **Webhook Fan-out**: Mirrors Slack messages to external agent webhooks
- **Token Rotation**: Automatic Slack OAuth token refresh

## Setup

### 1. Install Dependencies

```bash
cd scripts/slack_agent
npm install
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

### 3. Resolve Channel Names to IDs

Run the channel resolution script to create `channel-map.json`:

```bash
npm run resolve-channels
```

### 4. Start the App

```bash
npm start
```

## Usage

Use `/plan` command in Slack to create and execute plans.

## Related Documentation

- [Slack OAuth Token Rotation](../slack_oauth/README.md)
- [Environment Variables](../../docs/ENV_TEMPLATES.md)
