#!/bin/bash
#
# Master script for running LiteLLM vs API Map Benchmark
#
# Usage:
#   ./run.sh              # Quick benchmark (recommended for first run)
#   ./run.sh full         # Full benchmark with all tests
#   ./run.sh clean        # Clean up all containers and volumes
#   ./run.sh help         # Show this help
#
# Environment Variables:
#   APIMAP_IMAGE          # Use specific image instead of building from source
#   CI=true               # Run in CI mode (use published images)
#
# This script will:
# 1. Check prerequisites (Docker, Docker Compose)
# 2. Build all containers (API Map from local source by default)
# 3. Start services (Mock Server, LiteLLM, API Map)
# 4. Run benchmarks
# 5. Generate visualizations
# 6. Display results

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="apibench"
QUICK_DURATION=10
FULL_DURATION=60

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BOLD}$1${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        echo "  Please install Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE="docker-compose"
    elif docker compose version &> /dev/null; then
        DOCKER_COMPOSE="docker compose"
    else
        print_error "Docker Compose is not installed"
        echo "  Please install Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    # Check Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running"
        echo "  Please start Docker and try again"
        exit 1
    fi
    
    print_success "Prerequisites OK (Docker + Compose)"
}

# Print compose file mode info (call before get_compose_files to avoid capturing output)
print_compose_mode_info() {
    # In CI mode or when APIMAP_IMAGE is set, use the CI override
    if [ -n "$CI" ] && [ "$CI" = "true" ]; then
        print_info "CI mode: Using published image (ghcr.io/qades/apimap:latest)"
    elif [ -n "$APIMAP_IMAGE" ]; then
        print_info "Using custom image: $APIMAP_IMAGE"
    else
        print_info "Development mode: Building API Map from local source"
    fi
}

# Determine compose files to use
get_compose_files() {
    local files="-f docker-compose.yml"
    
    # In CI mode or when APIMAP_IMAGE is set, use the CI override
    if [ -n "$CI" ] && [ "$CI" = "true" ]; then
        files="$files -f docker-compose.ci.yml"
    elif [ -n "$APIMAP_IMAGE" ]; then
        files="$files -f docker-compose.ci.yml"
    fi
    
    echo "$files"
}

# Build containers
build_containers() {
    print_step "Building containers..."
    
    cd "$SCRIPT_DIR"
    
    export COMPOSE_PROJECT_NAME="$PROJECT_NAME"
    
    print_compose_mode_info
    local compose_files=$(get_compose_files)
    
    # Check if docker-compose supports --parallel (podman-compose doesn't)
    if $DOCKER_COMPOSE $compose_files build --help 2>/dev/null | grep -q -- '--parallel'; then
        $DOCKER_COMPOSE $compose_files build --parallel
    else
        $DOCKER_COMPOSE $compose_files build
    fi
    
    print_success "Containers built successfully"
}

# Extract mock server settings from arguments
extract_mock_settings() {
    local args="$@"
    
    # Reset to defaults
    export MOCK_LATENCY_MEAN_MS="${MOCK_LATENCY_MEAN_MS:-0}"
    export MOCK_LATENCY_STD_MS="${MOCK_LATENCY_STD_MS:-0}"
    export MOCK_TOKENS_PER_SEC="${MOCK_TOKENS_PER_SEC:-100}"
    export MOCK_INSTANT_MODE="${MOCK_INSTANT_MODE:-false}"
    export MOCK_ERROR_RATE="${MOCK_ERROR_RATE:-0.01}"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --latency-mean)
                export MOCK_LATENCY_MEAN_MS="$2"
                shift 2
                ;;
            --latency-std)
                export MOCK_LATENCY_STD_MS="$2"
                shift 2
                ;;
            --tokens-per-sec)
                export MOCK_TOKENS_PER_SEC="$2"
                shift 2
                ;;
            --instant)
                export MOCK_INSTANT_MODE="true"
                shift
                ;;
            --error-rate)
                export MOCK_ERROR_RATE="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Run quick benchmark
run_quick() {
    # Check for help first (before building/starting anything)
    if [ $# -gt 0 ] && { [ "$1" = "--help" ] || [ "$1" = "-h" ]; }; then
        show_benchmark_help
        return 0
    fi
    
    # Extract mock server settings from arguments
    extract_mock_settings "$@"
    
    print_header "Running QUICK Benchmark (Recommended)"
    
    check_prerequisites
    build_containers
    
    print_step "Starting services and running benchmark..."
    echo ""
    
    cd "$SCRIPT_DIR"
    export COMPOSE_PROJECT_NAME="$PROJECT_NAME"
    
    print_compose_mode_info
    local compose_files=$(get_compose_files)
    
    # Start services and run benchmark with any extra arguments
    $DOCKER_COMPOSE $compose_files --profile benchmark run --rm benchmark \
        bun run src/benchmark/index.ts --quick "$@"
    
    BENCHMARK_EXIT=$?
    
    if [ $BENCHMARK_EXIT -eq 0 ]; then
        echo ""
        print_success "Benchmark completed!"
        show_results
    else
        echo ""
        print_error "Benchmark failed"
        show_logs
        exit 1
    fi
}

# Show benchmark help without starting services
show_benchmark_help() {
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║         LiteLLM vs API Map - Benchmark Runner                   ║
╚══════════════════════════════════════════════════════════════════╝

USAGE:
    ./run.sh [MODE] [OPTIONS]

MODES:
    (none)          Run quick benchmark (default, 2-3 min)
    quick           Same as above
    full            Run full benchmark suite (10-15 min)
    clean           Stop and clean up all containers
    status          Show container status
    logs            Show service logs
    help            Show this help

TARGETS:
    --litellm-url URL       LiteLLM URL (default: http://litellm:4000)
    --apimap-url URL        API Map URL (default: http://apimap:3000)

SCENARIOS:
    --concurrency LEVELS    Comma-separated concurrency levels
                            (default: 1,10,50,100)
    --requests COUNTS       Comma-separated request counts
                            (default: 50,100,200,300)
    --prompt-size CHARS     Prompt size in characters (default: 100)
    --context-size CHARS    Context size in characters (default: 0)
    --max-tokens N          Max tokens in response (default: 50)

MOCK SERVER:
    --latency-mean MS       Base latency in ms (default: 0)
    --latency-std MS        Latency std dev (default: 0)
    --tokens-per-sec N      Output tokens/sec (default: 100)
    --instant               Instant mode (no latency)
    --error-rate RATE       Error rate 0.0-1.0 (default: 0.01)
    
    Note: Input processing is always 1000 tokens/sec.
          Use --instant for zero latency (benchmarks gateway overhead only).

ENVIRONMENT VARIABLES:
    APIMAP_IMAGE=IMAGE      Use specific image instead of local build
    CI=true                 Run in CI mode (use published images)

EXAMPLES:
    # Default quick benchmark (builds from local source)
    ./run.sh

    # Test with specific concurrency
    ./run.sh quick --concurrency 1,5,10 --requests 10,50,100

    # Test published image
    APIMAP_IMAGE=ghcr.io/qades/apimap:v1.2.3 ./run.sh

    # CI mode (uses published latest)
    CI=true ./run.sh

    # Larger prompts
    ./run.sh full --prompt-size 500 --context-size 2000

    # Simulate slow LLM
    ./run.sh --latency-mean 500 --latency-std 100

For more information: ./run.sh help

EOF
}

# Run full benchmark
run_full() {
    # Check for help first (before building/starting anything)
    if [ $# -gt 0 ] && { [ "$1" = "--help" ] || [ "$1" = "-h" ]; }; then
        show_benchmark_help
        return 0
    fi
    
    # Extract mock server settings from arguments
    extract_mock_settings "$@"
    
    print_header "Running FULL Benchmark Suite"
    
    check_prerequisites
    build_containers
    
    print_step "Starting services and running full benchmark..."
    echo "  This may take several minutes..."
    echo ""
    
    cd "$SCRIPT_DIR"
    export COMPOSE_PROJECT_NAME="$PROJECT_NAME"
    
    print_compose_mode_info
    local compose_files=$(get_compose_files)
    
    # Start services and run full benchmark with any extra arguments
    $DOCKER_COMPOSE $compose_files --profile benchmark run --rm benchmark \
        bun run src/benchmark/index.ts "$@"
    
    BENCHMARK_EXIT=$?
    
    if [ $BENCHMARK_EXIT -eq 0 ]; then
        echo ""
        print_success "Full benchmark completed!"
        
        # Generate visualization
        print_step "Generating visualization..."
        $DOCKER_COMPOSE $compose_files --profile visualize run --rm visualize || true
        
        show_results
    else
        echo ""
        print_error "Benchmark failed"
        show_logs
        exit 1
    fi
}

# Show results
show_results() {
    print_header "Benchmark Results"
    
    cd "$SCRIPT_DIR"
    
    if [ -d "results" ] && [ "$(ls -A results/*.json 2>/dev/null)" ]; then
        LATEST_JSON=$(ls -t results/*.json 2>/dev/null | head -1)
        LATEST_MD=$(ls -t results/*.md 2>/dev/null | head -1)
        
        if [ -n "$LATEST_JSON" ]; then
            print_success "Results files:"
            echo "  📄 JSON: $LATEST_JSON"
            [ -n "$LATEST_MD" ] && echo "  📄 Markdown: $LATEST_MD"
            
            if [ -f "reports/benchmark_report.pdf" ]; then
                echo "  📊 PDF Report: reports/benchmark_report.pdf"
            fi
            
            echo ""
            print_step "Quick Summary:"
            
            # Extract and display key metrics from JSON if jq is available
            if command -v jq &> /dev/null && [ -f "$LATEST_JSON" ]; then
                echo ""
                
                # Show latency results
                if jq -e '.latency' "$LATEST_JSON" > /dev/null 2>&1; then
                    echo -e "${BOLD}Latency Results:${NC}"
                    jq -r '.latency[] | "  \(.target): Mean=\(.mean_ms // 0 | round)ms, P95=\(.p95_ms // 0 | round)ms"' "$LATEST_JSON" 2>/dev/null || true
                    echo ""
                fi
                
                # Show throughput results
                if jq -e '.throughput' "$LATEST_JSON" > /dev/null 2>&1; then
                    echo -e "${BOLD}Throughput Results (highest concurrency):${NC}"
                    jq -r '.throughput | group_by(.target) | map(max_by(.concurrency)) | .[] | "  \(.target): \(.requests_per_sec // 0 | round) req/sec @ \(.concurrency) concurrent"' "$LATEST_JSON" 2>/dev/null || true
                    echo ""
                fi
                
                # Show feature scores
                if jq -e '.features' "$LATEST_JSON" > /dev/null 2>&1; then
                    LITELLM_SCORE=$(jq '[.features[] | select(.[1] == "✅")] | length' "$LATEST_JSON" 2>/dev/null || echo 0)
                    APIMAP_SCORE=$(jq '[.features[] | select(.[2] == "✅")] | length' "$LATEST_JSON" 2>/dev/null || echo 0)
                    echo -e "${BOLD}Feature Score:${NC} LiteLLM $LITELLM_SCORE - API Map $APIMAP_SCORE"
                fi
            fi
            
            echo ""
            print_step "View full report:"
            if [ -n "$LATEST_MD" ]; then
                echo "  cat $LATEST_MD"
            fi
        fi
    else
        print_warning "No results found"
    fi
}

# Show logs
show_logs() {
    print_step "Recent logs:"
    cd "$SCRIPT_DIR"
    export COMPOSE_PROJECT_NAME="$PROJECT_NAME"
    local compose_files=$(get_compose_files)
    $DOCKER_COMPOSE $compose_files logs --tail=50 || true
}

# Clean up
clean_up() {
    print_header "Cleaning Up"
    
    cd "$SCRIPT_DIR"
    export COMPOSE_PROJECT_NAME="$PROJECT_NAME"
    
    # Determine compose files
    local compose_files="-f docker-compose.yml"
    if [ -f "docker-compose.ci.yml" ]; then
        compose_files="$compose_files -f docker-compose.ci.yml"
    fi
    
    print_step "Stopping containers..."
    $DOCKER_COMPOSE $compose_files down --volumes --remove-orphans 2>/dev/null || true
    
    print_step "Removing local images..."
    docker rmi "${PROJECT_NAME}-benchmark" "${PROJECT_NAME}-mock-server" "apibench-apimap:local" 2>/dev/null || true
    
    print_step "Pruning networks..."
    docker network prune -f 2>/dev/null || true
    
    print_success "Cleanup complete"
}

# Show status
show_status() {
    print_header "Benchmark Status"
    
    cd "$SCRIPT_DIR"
    export COMPOSE_PROJECT_NAME="$PROJECT_NAME"
    
    print_compose_mode_info
    local compose_files=$(get_compose_files)
    
    echo -e "${BOLD}Containers:${NC}"
    $DOCKER_COMPOSE $compose_files ps 2>/dev/null || echo "  No containers running"
    
    echo ""
    echo -e "${BOLD}Results:${NC}"
    if [ -d "results" ]; then
        ls -lh results/ 2>/dev/null || echo "  No results yet"
    else
        echo "  No results directory"
    fi
    
    echo ""
    print_info "Mode: $([ -n "$CI" ] && echo 'CI (published image)' || echo 'Development (local source)')"
    if [ -n "$APIMAP_IMAGE" ]; then
        print_info "Image: $APIMAP_IMAGE"
    fi
}

# Show help
show_help() {
    cat << EOF
LiteLLM vs API Map - Benchmark Runner

Usage: ./run.sh [COMMAND]

Commands:
  (no command)  Run quick benchmark (recommended for first run)
  quick         Same as above
  full          Run full benchmark suite (takes longer)
  report        Generate PDF report from results
  status        Show current status
  logs          Show service logs
  clean         Stop containers and clean up
  help          Show this help message

Quick Start:
  ./run.sh              # Run quick benchmark (~2-3 minutes)
  ./run.sh full         # Run full benchmark (~10-15 minutes)

Development Mode (default):
  By default, API Map is built from the local source code (parent directory).
  This allows you to benchmark your modifications immediately.

CI Mode:
  Set CI=true to use the published image instead of building from source:
    CI=true ./run.sh

  Or use a specific image:
    APIMAP_IMAGE=ghcr.io/qades/apimap:v1.2.3 ./run.sh

Configuration:
  Copy .env.example to .env and customize settings.

Results:
  Results are saved to the ./results/ directory as JSON and Markdown files.
  Visualizations are saved to ./reports/ as PDF files.

Examples:
  # First time - quick test
  ./run.sh

  # Full comprehensive benchmark
  ./run.sh full

  # Generate report from specific run
  ./run.sh report 2026-03-27T00-28-42

  # Clean up when done
  ./run.sh clean

  # Test with custom settings
  MOCK_LATENCY_MEAN_MS=100 ./run.sh

For more information, see README.md

EOF
}

# Generate PDF report from previous run
generate_report() {
    print_header "Generate PDF Report"
    
    cd "$SCRIPT_DIR"
    
    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required for report generation"
        exit 1
    fi
    
    # Check if matplotlib is installed
    if ! python3 -c "import matplotlib" 2>/dev/null; then
        print_step "Installing matplotlib..."
        pip3 install -q matplotlib numpy || {
            print_error "Failed to install matplotlib"
            exit 1
        }
    fi
    
    if [ $# -eq 0 ]; then
        # Generate report from most recent run
        print_step "Generating report from most recent run..."
        python3 visualize.py results/
    else
        # Generate report from specific run ID
        print_step "Generating report for run: $1"
        python3 visualize.py --run-id "$1"
    fi
    
    print_success "Report generated!"
}

# Main
case "${1:-quick}" in
    quick|"")
        shift 2>/dev/null || true
        run_quick "$@"
        ;;
    full)
        shift
        run_full "$@"
        ;;
    report)
        shift
        generate_report "$@"
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_up
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
