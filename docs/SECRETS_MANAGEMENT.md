# Secrets Management Guide

This document describes how to generate, store, and manage secrets for the Orion Edge App stack.

## Overview

Secrets are required for:
- Database passwords (Postgres, ClickHouse)
- Authentication tokens (NextAuth, Langfuse API keys)
- Service passwords (n8n basic auth)
- Integration secrets (Slack signing secrets, webhook secrets)
- External API keys (OpenAI, Google Drive service accounts)

**Never commit secrets to git.** All `.env` files and secret values are gitignored.

## Secret Generation

Use the provided script to generate all required secrets:

```bash
./scripts/generate_secrets.sh
```

This will create:
- `secrets/generated/` - Directory with generated secret values
- `secrets/templates/` - Template files showing where to place secrets

## Required Secrets

### 1. Database Passwords

**PostgreSQL:**
- `POSTGRES_PASSWORD` - Database password for `cosmocrat` user
- Used in: `deploy/cosmocrat-v1.compose.yml` (postgres service)
- Generate: `openssl rand -base64 32`

**ClickHouse:**
- `CLICKHOUSE_PASSWORD` - Database password for `langfuse` user
- Used in: `deploy/cosmocrat-v1.compose.yml` (clickhouse service)
- Generate: `openssl rand -base64 32`

### 2. Langfuse Authentication

**NextAuth Secret:**
- `NEXTAUTH_SECRET` - Secret for NextAuth.js session encryption
- Used in: `deploy/cosmocrat-v1.compose.yml` (langfuse service)
- Generate: `openssl rand -base64 32`

**Salt:**
- `SALT` - Salt for password hashing
- Used in: `deploy/cosmocrat-v1.compose.yml` (langfuse service)
- Generate: `openssl rand -base64 32`

**Langfuse API Keys:**
- `LANGFUSE_PUBLIC_KEY` - Public API key from Langfuse UI
- `LANGFUSE_SECRET_KEY` - Secret API key from Langfuse UI
- `LANGFUSE_API_KEY` - Alternative API key (if using API key auth)
- Get from: Langfuse UI → Settings → API Keys

### 3. Service Authentication

**n8n Basic Auth:**
- `N8N_BASIC_AUTH_PASSWORD` - Password for n8n web UI
- Used in: `deploy/cosmocrat-v1.compose.yml` (n8n service)
- Default user: `admin`
- Generate: `openssl rand -base64 24`

### 4. Slack Integration Secrets

**Slack Signing Secret:**
- `SLACK_SIGNING_SECRET` - Secret for verifying Slack webhook requests
- Used in: `scripts/slack_csv_hooks/server.js`
- Get from: Slack App → Basic Information → Signing Secret

**Slack App Token (Socket Mode):**
- `SLACK_APP_TOKEN` - App-level token for Socket Mode
- Used in: `scripts/slack_agent/` (full bot integration)
- Get from: Slack App → Basic Information → App-Level Tokens
- Required scope: `connections:write`

**Slack Bot Token:**
- `SLACK_BOT_TOKEN` - Bot token from OAuth installation
- Used in: `scripts/slack_agent/` (full bot integration)
- Get from: Slack App → OAuth & Permissions → Bot User OAuth Token

**Webhook Signing Secret:**
- `WEBHOOK_SIGNING_SECRET` - Secret for webhook fan-out
- Used in: `scripts/slack_agent/` (webhook routing)
- Generate: `openssl rand -base64 32`

**Slack Webhook URLs:**
- `DEFAULT_SLACK_WEBHOOK` - Default webhook URL for CSV hooks
- `SLACK_WEBHOOK_URL` - General webhook URL for reports
- Get from: Slack App → Incoming Webhooks → Add New Webhook

### 5. External API Keys

**OpenAI API Key:**
- `OPENAI_API_KEY` - API key for OpenAI (optional if using local models)
- Get from: https://platform.openai.com/api-keys
- Note: Can use `ollama` as placeholder when using local Ollama models

**Google Drive Service Account:**
- `GOOGLE_DRIVE_SA_JSON_BASE64` - Base64-encoded service account JSON
- Generate: Create service account in Google Cloud Console
- Encode: `base64 -w 0 /path/to/service-account.json`

### 6. ACME/Let's Encrypt

**ACME Email:**
- `ACME_EMAIL` - Email for Let's Encrypt certificate notifications
- Used in: `deploy/cosmocrat-v1.compose.yml` (traefik service)
- Set: Your email address

## Secret Storage Locations

### Development/Edge Host

Secrets should be stored in environment-specific locations:

**Compose Stack Secrets:**
- Set as environment variables in shell before running `docker compose`
- Or use `.env` file in `deploy/` directory (gitignored)
- Example: `deploy/.env` (not committed)

**Application Secrets:**
- `env/biz_core.env` - Core business logic secrets
- `env/ecom_env.env` - E-commerce integration secrets
- `env/trading_env.env` - Trading integration secrets
- All gitignored, use `.example.txt` templates

**Service-Specific Secrets:**
- `scripts/slack_csv_hooks/.env` - Slack CSV hooks secrets
- `scripts/slack_agent/.env` - Slack agent secrets
- See respective README files for templates

### Private Secrets Repository

Maintain a separate private repository or vault with:
- Canonical `.env.template` files
- Generated secret values (encrypted)
- Version-controlled templates

**Structure:**
```
/secure-repo/
  env/
    biz_core.env.template
    ecom_env.template
    trading_env.template
  secrets/
    generated/
      postgres_password.txt
      nextauth_secret.txt
      ...
```

## Secret Generation Script

The `scripts/generate_secrets.sh` script generates all required secrets:

```bash
# Generate all secrets
./scripts/generate_secrets.sh

# Generate specific secret type
./scripts/generate_secrets.sh --type=password
./scripts/generate_secrets.sh --type=token
```

**Output:**
- `secrets/generated/` - Generated values (gitignored)
- `secrets/templates/` - Template files showing usage

## Security Best Practices

1. **Never commit secrets** - All `.env` files are gitignored
2. **Use strong passwords** - Minimum 32 characters for database passwords
3. **Rotate regularly** - Change secrets periodically (quarterly recommended)
4. **Limit access** - Only grant secrets to users/services that need them
5. **Use environment variables** - Prefer env vars over hardcoded values
6. **Encrypt at rest** - Use encrypted storage for secrets repository
7. **Audit access** - Log access to secrets when possible

## Secret Rotation

When rotating secrets:

1. **Generate new secrets:**
   ```bash
   ./scripts/generate_secrets.sh
   ```

2. **Update environment files:**
   - Update `.env` files with new values
   - Update compose file if hardcoded

3. **Restart services:**
   ```bash
   docker compose -f deploy/cosmocrat-v1.compose.yml restart <service>
   ```

4. **Verify functionality:**
   - Check service logs
   - Test integrations
   - Verify database connectivity

5. **Archive old secrets:**
   - Move old values to encrypted archive
   - Document rotation date

## Troubleshooting

**Secret not working:**
- Verify secret is set correctly (no extra spaces/newlines)
- Check service logs for authentication errors
- Ensure secret matches between services

**Secret generation fails:**
- Ensure `openssl` is installed: `which openssl`
- Check write permissions to `secrets/` directory
- Verify script has execute permissions: `chmod +x scripts/generate_secrets.sh`

**Environment variable not found:**
- Check `.env` file exists and is readable
- Verify variable name matches exactly (case-sensitive)
- Ensure `.env` file is in correct location

## Related Documentation

- `docs/ENV_TEMPLATES.md` - Environment variable templates
- `docs/QUICKSTART.md` - Quick start guide with secret setup
- `docs/SLACK_CSV_HOOKS.md` - Slack integration secrets
- `scripts/slack_csv_hooks/README.md` - Slack CSV hooks setup

