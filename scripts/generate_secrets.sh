#!/bin/bash
# Generate secrets for Orion Edge App stack
# Usage: ./scripts/generate_secrets.sh [--type=TYPE] [--output=DIR]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_DIR="${PROJECT_ROOT}/secrets"
GENERATED_DIR="${SECRETS_DIR}/generated"
TEMPLATES_DIR="${SECRETS_DIR}/templates"

# Default options
SECRET_TYPE="all"
OUTPUT_DIR="$GENERATED_DIR"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type=*)
            SECRET_TYPE="${1#*=}"
            shift
            ;;
        --output=*)
            OUTPUT_DIR="${1#*=}"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--type=TYPE] [--output=DIR]"
            echo ""
            echo "Generate secrets for Orion Edge App stack"
            echo ""
            echo "Options:"
            echo "  --type=TYPE     Generate specific secret type (password, token, all)"
            echo "  --output=DIR    Output directory (default: secrets/generated/)"
            echo "  --help, -h      Show this help message"
            echo ""
            echo "Secret types:"
            echo "  password        Database and service passwords"
            echo "  token           Authentication tokens and API keys"
            echo "  all             Generate all secrets (default)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Create directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMPLATES_DIR"

# Function to generate random base64 string
generate_secret() {
    local length="${1:-32}"
    openssl rand -base64 "$length" | tr -d '\n'
}

# Function to generate random hex string
generate_hex() {
    local length="${1:-32}"
    openssl rand -hex "$length"
}

# Function to write secret to file
write_secret() {
    local name="$1"
    local value="$2"
    local file="${OUTPUT_DIR}/${name}.txt"
    echo "$value" > "$file"
    chmod 600 "$file"
    echo "Generated: $file"
}

# Function to create template file
create_template() {
    local name="$1"
    local description="$2"
    local usage="$3"
    local file="${TEMPLATES_DIR}/${name}.md"
    cat > "$file" <<EOF
# ${name}

${description}

## Generation

\`\`\`bash
openssl rand -base64 32
\`\`\`

## Usage

${usage}

## Location

- Generated value: \`secrets/generated/${name}.txt\`
- Used in: See usage above
EOF
    echo "Created template: $file"
}

# Generate passwords
generate_passwords() {
    echo "Generating passwords..."
    
    # PostgreSQL password
    POSTGRES_PASSWORD=$(generate_secret 32)
    write_secret "postgres_password" "$POSTGRES_PASSWORD"
    create_template "postgres_password" \
        "PostgreSQL database password for cosmocrat user" \
        "Set in \`deploy/cosmocrat-v1.compose.yml\`:\n\`POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}\`"
    
    # ClickHouse password
    CLICKHOUSE_PASSWORD=$(generate_secret 32)
    write_secret "clickhouse_password" "$CLICKHOUSE_PASSWORD"
    create_template "clickhouse_password" \
        "ClickHouse database password for langfuse user" \
        "Set in \`deploy/cosmocrat-v1.compose.yml\`:\n\`CLICKHOUSE_PASSWORD: ${CLICKHOUSE_PASSWORD}\`"
    
    # n8n basic auth password
    N8N_PASSWORD=$(generate_secret 24)
    write_secret "n8n_password" "$N8N_PASSWORD"
    create_template "n8n_password" \
        "n8n web UI basic auth password" \
        "Set in \`deploy/cosmocrat-v1.compose.yml\`:\n\`N8N_BASIC_AUTH_PASSWORD: ${N8N_PASSWORD}\`\n\nDefault user: \`admin\`"
    
    echo "✓ Passwords generated"
}

# Generate tokens
generate_tokens() {
    echo "Generating tokens..."
    
    # NextAuth secret
    NEXTAUTH_SECRET=$(generate_secret 32)
    write_secret "nextauth_secret" "$NEXTAUTH_SECRET"
    create_template "nextauth_secret" \
        "NextAuth.js session encryption secret" \
        "Set in \`deploy/cosmocrat-v1.compose.yml\`:\n\`NEXTAUTH_SECRET: ${NEXTAUTH_SECRET}\`"
    
    # Salt
    SALT=$(generate_secret 32)
    write_secret "salt" "$SALT"
    create_template "salt" \
        "Salt for password hashing" \
        "Set in \`deploy/cosmocrat-v1.compose.yml\`:\n\`SALT: ${SALT}\`"
    
    # Webhook signing secret
    WEBHOOK_SECRET=$(generate_secret 32)
    write_secret "webhook_signing_secret" "$WEBHOOK_SECRET"
    create_template "webhook_signing_secret" \
        "Secret for webhook request signing" \
        "Set in environment:\n\`WEBHOOK_SIGNING_SECRET=${WEBHOOK_SECRET}\`\n\nUsed in Slack agent webhook routing."
    
    echo "✓ Tokens generated"
}

# Generate all secrets
generate_all() {
    echo "Generating all secrets..."
    echo ""
    generate_passwords
    echo ""
    generate_tokens
    echo ""
}

# Main execution
case "$SECRET_TYPE" in
    password)
        generate_passwords
        ;;
    token)
        generate_tokens
        ;;
    all)
        generate_all
        ;;
    *)
        echo "Unknown secret type: $SECRET_TYPE"
        echo "Use --help for usage information"
        exit 1
        ;;
esac

# Create summary
SUMMARY_FILE="${OUTPUT_DIR}/SUMMARY.txt"
cat > "$SUMMARY_FILE" <<EOF
Secrets Generated: $(date -Iseconds)
Type: $SECRET_TYPE
Output Directory: $OUTPUT_DIR

Generated Files:
$(ls -1 "$OUTPUT_DIR"/*.txt 2>/dev/null | xargs -n1 basename || echo "None")

Next Steps:
1. Review generated secrets in: $OUTPUT_DIR
2. Update deploy/cosmocrat-v1.compose.yml with database passwords
3. Update environment files with tokens
4. Restart services after updating secrets

Security Reminder:
- Never commit secrets to git
- Store secrets in encrypted vault
- Rotate secrets regularly
- Limit access to secret files (chmod 600)
EOF

chmod 600 "$SUMMARY_FILE"
echo ""
echo "✓ Summary created: $SUMMARY_FILE"
echo ""
echo "All secrets generated successfully!"
echo "Review generated files in: $OUTPUT_DIR"
echo "See templates in: $TEMPLATES_DIR"

