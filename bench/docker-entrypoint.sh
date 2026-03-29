#!/bin/sh
#
# Docker entrypoint for benchmark runner (Bun)
# Simply passes all CLI arguments to the benchmark script

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     LiteLLM vs API Map - Bun Benchmark Runner               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Default URLs (internal Docker network)
LITELLM_URL="${LITELLM_URL:-http://litellm:4000}"
APIMAP_URL="${APIMAP_URL:-http://apimap:3000}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Wait for services
echo -e "${BLUE}Checking service health...${NC}\n"

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

if ! wait_for_service "Mock Server" "$MOCK_SERVER_URL" "/health" 30; then
    exit 1
fi

if ! wait_for_service "LiteLLM" "$LITELLM_URL" "/health/liveliness" 60; then
    exit 1
fi

if ! wait_for_service "API Map" "$APIMAP_URL" "/v1/models" 60; then
    exit 1
fi

echo ""
echo -e "${GREEN}✅ All services are ready!${NC}"
echo ""

# Show configuration
echo -e "${BLUE}Benchmark Configuration:${NC}"
echo "  LiteLLM URL: $LITELLM_URL"
echo "  API Map URL: $APIMAP_URL"
echo "  Arguments: $*"
echo ""

# Run benchmark - pass all arguments directly
echo -e "${BLUE}Starting benchmarks...${NC}\n"

bun run src/benchmark/index.ts \
    --litellm-url "$LITELLM_URL" \
    --apimap-url "$APIMAP_URL" \
    "$@"

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
