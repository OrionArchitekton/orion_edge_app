#!/usr/bin/env bash
#
# Quick Cosmocrat Edge Stack Health Check
# Focuses on Docker services and basic connectivity
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Cosmocrat Edge Stack - Quick Health Check${NC}"
echo -e "${BLUE}$(date)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo

# 1. Docker Services
echo -e "${BLUE}Docker Services Status:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(deploy-|NAME)" || echo "No services running"
echo

# 2. Service Counts
echo -e "${BLUE}Service Summary:${NC}"
RUNNING=$(docker ps -q | wc -l)
TOTAL_EXPECTED=12
echo "  Running: $RUNNING / $TOTAL_EXPECTED expected"

if [ "$RUNNING" -eq "$TOTAL_EXPECTED" ]; then
    echo -e "  ${GREEN}✓ All services running${NC}"
elif [ "$RUNNING" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠ Some services may be down${NC}"
else
    echo -e "  ${RED}✗ No services running${NC}"
fi
echo

# 3. Check for restarting containers
echo -e "${BLUE}Unhealthy Services:${NC}"
RESTARTING=$(docker ps --filter "status=restarting" --format "{{.Names}}" 2>/dev/null)
if [ -z "$RESTARTING" ]; then
    echo -e "  ${GREEN}✓ No restarting containers${NC}"
else
    echo -e "  ${RED}✗ Restarting:${NC}"
    echo "$RESTARTING" | sed 's/^/    /'
fi
echo

# 4. Recent logs for failed services
echo -e "${BLUE}Recent Errors (last 5 lines per service):${NC}"
for container in $(docker ps -a --filter "status=restarting" --format "{{.Names}}" 2>/dev/null); do
    echo -e "${YELLOW}  [$container]${NC}"
    docker logs --tail=5 "$container" 2>&1 | sed 's/^/    /'
    echo
done

# 5. Quick connectivity tests
echo -e "${BLUE}Quick Connectivity Tests:${NC}"

# Test Ollama (local port)
if nc -z localhost 11434 2>/dev/null; then
    echo -e "  ${GREEN}✓ Ollama${NC} (port 11434)"
else
    echo -e "  ${YELLOW}⚠ Ollama${NC} (port 11434 not reachable)"
fi

# Test Postgres (via docker network)
if docker exec deploy-postgres-1 pg_isready -U cosmocrat &>/dev/null; then
    echo -e "  ${GREEN}✓ Postgres${NC} (ready for connections)"
else
    echo -e "  ${RED}✗ Postgres${NC} (not ready)"
fi

# Test Redis
if docker exec deploy-redis-1 redis-cli ping 2>/dev/null | grep -q PONG; then
    echo -e "  ${GREEN}✓ Redis${NC} (responding to ping)"
else
    echo -e "  ${RED}✗ Redis${NC} (not responding)"
fi

echo

# 6. Volume disk usage
echo -e "${BLUE}Volume Disk Usage:${NC}"
for vol in deploy_pg_data deploy_redis_data deploy_n8n_data deploy_clickhouse_data; do
    if docker volume inspect "$vol" &>/dev/null; then
        SIZE=$(docker system df -v | grep "$vol" | awk '{print $3}' || echo "unknown")
        echo "  $vol: $SIZE"
    fi
done
echo

# 7. Security warnings
echo -e "${BLUE}Security Check:${NC}"
WARNINGS=0

# Check Postgres password
if docker exec deploy-postgres-1 printenv POSTGRES_PASSWORD 2>/dev/null | grep -q "change-me"; then
    echo -e "  ${RED}✗ Postgres using default password${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${GREEN}✓ Postgres password rotated${NC}"
fi

# Check ClickHouse password
if docker exec deploy-clickhouse-1 printenv CLICKHOUSE_PASSWORD 2>/dev/null | grep -q "change-me"; then
    echo -e "  ${RED}✗ ClickHouse using default password${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "  ${GREEN}✓ ClickHouse password rotated${NC}"
fi

echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$RUNNING" -eq "$TOTAL_EXPECTED" ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✓ System Healthy${NC}"
    exit 0
elif [ "$RUNNING" -gt 0 ]; then
    echo -e "${YELLOW}⚠ System Partially Healthy (warnings present)${NC}"
    exit 0
else
    echo -e "${RED}✗ System Unhealthy${NC}"
    exit 1
fi
