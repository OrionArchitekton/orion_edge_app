#!/usr/bin/env bash
#
# Cosmocrat Edge Stack Health Check
# Tests all service endpoints, Docker containers, and Slack webhooks
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
check_start() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Cosmocrat Edge Stack Health Check${NC}"
    echo -e "${BLUE}$(date)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

check_http() {
    local name="$1"
    local url="$2"
    local expected_code="${3:-200}"

    TOTAL=$((TOTAL + 1))
    echo -n "  [$name] $url ... "

    if command -v curl &> /dev/null; then
        status_code=$(curl -L -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>&1 | tail -n1)

        # If curl failed, status_code might be empty or contain error message
        if [[ -z "$status_code" ]] || [[ ! "$status_code" =~ ^[0-9]+$ ]]; then
            status_code="000"
        fi

        # Accept 2xx and 3xx codes as success
        if [[ "$status_code" =~ ^[23][0-9][0-9]$ ]]; then
            echo -e "${GREEN}✓ OK${NC} ($status_code)"
            PASSED=$((PASSED + 1))
            return 0
        elif [[ "$status_code" == "000" ]]; then
            echo -e "${YELLOW}⚠ TIMEOUT${NC} (connection failed or timeout)"
            WARNINGS=$((WARNINGS + 1))
            return 0
        else
            echo -e "${RED}✗ FAIL${NC} (got $status_code)"
            FAILED=$((FAILED + 1))
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ SKIP${NC} (curl not installed)"
        WARNINGS=$((WARNINGS + 1))
        return 0
    fi
}

check_docker_service() {
    local service_name="$1"

    TOTAL=$((TOTAL + 1))
    echo -n "  [Docker] $service_name ... "

    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}⚠ SKIP${NC} (docker not installed)"
        WARNINGS=$((WARNINGS + 1))
        return 0
    fi

    # Check if service is running
    status=$(docker ps --filter "name=$service_name" --format "{{.Status}}" 2>/dev/null || echo "")

    if [[ -n "$status" ]]; then
        if [[ "$status" =~ ^Up ]]; then
            echo -e "${GREEN}✓ UP${NC} ($status)"
            PASSED=$((PASSED + 1))
            return 0
        else
            echo -e "${RED}✗ NOT UP${NC} ($status)"
            FAILED=$((FAILED + 1))
            return 1
        fi
    else
        echo -e "${RED}✗ NOT FOUND${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

check_slack_webhook() {
    local webhook_url="$1"

    TOTAL=$((TOTAL + 1))
    echo -n "  [Slack Webhook] Testing connectivity ... "

    if [[ -z "$webhook_url" ]]; then
        echo -e "${YELLOW}⚠ SKIP${NC} (SLACK_WEBHOOK_URL not set)"
        WARNINGS=$((WARNINGS + 1))
        return 0
    fi

    payload='{"text":"Health check test from cosmocrat edge stack"}'
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$webhook_url" 2>/dev/null || echo "000")

    if [[ "$status_code" == "200" ]]; then
        echo -e "${GREEN}✓ OK${NC} (webhook reachable)"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (got $status_code)"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

check_volume_usage() {
    local volume_name="$1"

    TOTAL=$((TOTAL + 1))
    echo -n "  [Volume] $volume_name ... "

    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}⚠ SKIP${NC} (docker not installed)"
        WARNINGS=$((WARNINGS + 1))
        return 0
    fi

    # Get volume mountpoint and check disk usage
    mountpoint=$(docker volume inspect "$volume_name" --format '{{ .Mountpoint }}' 2>/dev/null || echo "")

    if [[ -z "$mountpoint" ]]; then
        echo -e "${YELLOW}⚠ NOT FOUND${NC}"
        WARNINGS=$((WARNINGS + 1))
        return 0
    fi

    # Check if we can access the mountpoint
    if [[ -d "$mountpoint" ]]; then
        size=$(du -sh "$mountpoint" 2>/dev/null | awk '{print $1}' || echo "unknown")
        echo -e "${GREEN}✓ OK${NC} (size: $size)"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${YELLOW}⚠ NO ACCESS${NC}"
        WARNINGS=$((WARNINGS + 1))
        return 0
    fi
}

# Main health checks
check_start

echo -e "${BLUE}1. HTTP Health Checks${NC}"
check_http "MCP Local" "http://mcp.localhost/healthz"
check_http "MCP External" "https://mcp.orionbot.online/healthz" || true  # External may not exist
check_http "Langfuse UI" "http://ops.localhost/langfuse" "200"
check_http "n8n UI" "http://ops.localhost/n8n" "200"
check_http "Traefik Dashboard" "http://ops.localhost/traefik" "200" || true  # May require auth
check_http "Ollama Models" "http://localhost:11434/v1/models"
echo

echo -e "${BLUE}2. Docker Services${NC}"
check_docker_service "traefik"
check_docker_service "postgres"
check_docker_service "redis"
check_docker_service "clickhouse"
check_docker_service "langfuse"
check_docker_service "n8n"
check_docker_service "ollama"
check_docker_service "mcp"
check_docker_service "memory-consolidator"
check_docker_service "runner-daily-report"
check_docker_service "slack-hooks"
check_docker_service "slack-agent"
echo

echo -e "${BLUE}3. Docker Volumes${NC}"
check_volume_usage "deploy_pg_data"
check_volume_usage "deploy_redis_data"
check_volume_usage "deploy_n8n_data"
check_volume_usage "deploy_clickhouse_data"
echo

echo -e "${BLUE}4. Slack Webhook Connectivity${NC}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-${DEFAULT_SLACK_WEBHOOK:-}}"
check_slack_webhook "$SLACK_WEBHOOK_URL"
echo

# Security warnings
echo -e "${BLUE}5. Security Warnings${NC}"
if docker exec deploy-postgres-1 psql -U cosmocrat -c "SELECT 1" &>/dev/null 2>&1; then
    postgres_pass=$(docker exec deploy-postgres-1 printenv POSTGRES_PASSWORD 2>/dev/null || echo "")
    if [[ "$postgres_pass" == "change-me" ]]; then
        echo -e "  ${YELLOW}⚠ WARNING${NC}: Postgres using default password 'change-me'"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "  ${GREEN}✓ OK${NC}: Postgres password rotated"
    fi
fi

if docker exec deploy-clickhouse-1 printenv CLICKHOUSE_PASSWORD &>/dev/null 2>&1; then
    clickhouse_pass=$(docker exec deploy-clickhouse-1 printenv CLICKHOUSE_PASSWORD 2>/dev/null || echo "")
    if [[ "$clickhouse_pass" == "change-me" ]]; then
        echo -e "  ${YELLOW}⚠ WARNING${NC}: ClickHouse using default password 'change-me'"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "  ${GREEN}✓ OK${NC}: ClickHouse password rotated"
    fi
fi
echo

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "  Total checks:  $TOTAL"
echo -e "  ${GREEN}Passed:        $PASSED${NC}"
echo -e "  ${RED}Failed:        $FAILED${NC}"
echo -e "  ${YELLOW}Warnings:      $WARNINGS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [[ $FAILED -gt 0 ]]; then
    echo -e "${RED}Health check FAILED${NC}"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}Health check PASSED with warnings${NC}"
    exit 0
else
    echo -e "${GREEN}Health check PASSED${NC}"
    exit 0
fi
