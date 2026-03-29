#!/bin/bash
# Benchmark runner wrapper script with proper cleanup and CLI argument passing
# Usage: bun run bench [BENCHMARK_OPTIONS]
#
# Examples:
#   bun run bench                              # Standard benchmark
#   bun run bench --help                       # Show benchmark help
#   bun run bench --scenarios "1:5,5:6"        # Custom scenarios
#   bun run bench --quick                      # Quick mode
#   bun run bench full                         # Full benchmark (legacy, use bench:full)
#   bun run bench quick                        # Quick benchmark (legacy, use bench:quick)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Handle legacy mode arguments for backward compatibility
if [[ ${#@} -gt 0 && ! "$1" =~ ^- ]]; then
    MODE="$1"
    shift
    case "$MODE" in
        full)
            set -- --scenarios "1:5,5:6,10:20,50:100" "$@"
            ;;
        quick)
            set -- --quick "$@"
            ;;
        standard)
            # No extra args for standard
            ;;
        *)
            echo "Warning: Unknown mode '$MODE'. Pass options directly instead."
            ;;
    esac
fi

cleanup() {
    echo ""
    echo "🧹 Cleaning up Docker containers..."
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" down -v 2>/dev/null || true
}

trap cleanup INT TERM EXIT

# Run benchmark with the benchmark profile, passing all arguments
docker compose -f "$SCRIPT_DIR/docker-compose.yml" --profile benchmark run --rm benchmark "$@"

BENCHMARK_EXIT_CODE=$?

if [ $BENCHMARK_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "📊 Generating visualization report..."
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" --profile visualize run --rm visualize 2>/dev/null || {
        echo "⚠️  Report generation skipped (visualize.py may not be available)"
    }
fi

echo "✅ Benchmark complete!"
trap - INT TERM EXIT

exit $BENCHMARK_EXIT_CODE
