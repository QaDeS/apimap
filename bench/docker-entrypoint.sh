#!/bin/sh
#
# Docker entrypoint for benchmark runner (Bun)

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     LiteLLM vs API Map - Bun Benchmark Runner               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Configuration from environment
LITELLM_URL="${LITELLM_URL:-http://litellm:4000}"
APIMAP_URL="${APIMAP_URL:-http://apimap:3000}"
BENCHMARK_SCENARIOS="${BENCHMARK_SCENARIOS:-1:50,10:100,50:200,100:300}"
WAIT_FOR_SERVICES="${WAIT_FOR_SERVICES:-true}"
QUICK_MODE="${QUICK_MODE:-false}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to wait for a service
wait_for_service() {
    local name=$1
    local url=$2
    local endpoint=$3
    local max_attempts=${4:-30}
    
    echo -e "${BLUE}Waiting for $name at $url...${NC}"
    
    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if bun -e "fetch('$url$endpoint').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))" 2>/dev/null; then
            echo -e "${GREEN}✅ $name is ready${NC}"
            return 0
        fi
        
        echo "  Attempt $attempt/$max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ $name failed to start${NC}"
    return 1
}

# Wait for services if enabled
if [ "$WAIT_FOR_SERVICES" = "true" ]; then
    echo -e "${BLUE}Checking service health...${NC}\n"
    
    # Wait for mock server
    if ! wait_for_service "Mock Server" "$MOCK_SERVER_URL" "/health" 30; then
        exit 1
    fi
    
    # Wait for LiteLLM
    if ! wait_for_service "LiteLLM" "$LITELLM_URL" "/health/liveliness" 60; then
        exit 1
    fi
    
    # Wait for API Map
    if ! wait_for_service "API Map" "$APIMAP_URL" "/v1/models" 60; then
        exit 1
    fi
    
    echo ""
    echo -e "${GREEN}✅ All services are ready!${NC}"
    echo ""
fi

# Show configuration
echo -e "${BLUE}Benchmark Configuration:${NC}"
echo "  LiteLLM URL: $LITELLM_URL"
echo "  API Map URL: $APIMAP_URL"
echo "  Scenarios: $BENCHMARK_SCENARIOS"
echo ""

# Run benchmark
echo -e "${BLUE}Starting benchmarks...${NC}\n"

if [ "$QUICK_MODE" = "true" ]; then
    echo -e "${YELLOW}Running in QUICK mode${NC}\n"
    bun run src/benchmark/index.ts \
        --litellm-url "$LITELLM_URL" \
        --apimap-url "$APIMAP_URL" \
        --quick \
        "$@"
else
    bun run src/benchmark/index.ts \
        --litellm-url "$LITELLM_URL" \
        --apimap-url "$APIMAP_URL" \
        "$@"
fi

BENCHMARK_EXIT_CODE=$?

echo ""
echo "═══════════════════════════════════════════════════════════════"

if [ $BENCHMARK_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Benchmark completed successfully!${NC}"
    echo ""
    echo "Results saved to:"
    ls -lh results/ 2>/dev/null || echo "  (No results directory)"
else
    echo -e "${RED}❌ Benchmark failed with exit code $BENCHMARK_EXIT_CODE${NC}"
fi

echo "═══════════════════════════════════════════════════════════════"

exit $BENCHMARK_EXIT_CODE
