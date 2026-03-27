#!/bin/bash
#
# Quick Start Script for LiteLLM vs API Map Benchmark (Bun Edition)
#
# Usage: ./quickstart.sh [OPTIONS]
#
# Run with: ./quickstart.sh
# Get help: ./quickstart.sh --help

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Check if first arg is a help request
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    exec ./run.sh quick --help
fi

# Check if first arg is 'full' mode
MODE="quick"
if [ "$1" = "full" ]; then
    MODE="full"
    shift
fi

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}                                                              ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}   ${BOLD}LiteLLM vs API Map - Benchmark Quick Start (Bun)${NC}          ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}                                                              ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    echo ""
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo ""
    echo "Please install Docker first:"
    echo "  • macOS/Windows: https://www.docker.com/products/docker-desktop"
    echo "  • Linux: https://docs.docker.com/engine/install/"
    echo ""
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo ""
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo ""
    echo "Docker Compose is included with Docker Desktop."
    echo "For Linux, see: https://docs.docker.com/compose/install/"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Docker is installed${NC}"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo ""
    echo -e "${RED}❌ Docker is not running${NC}"
    echo ""
    echo "Please start Docker and try again."
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Make scripts executable
echo ""
echo -e "${BLUE}Setting up...${NC}"
chmod +x run.sh docker-entrypoint.sh 2>/dev/null || true
mkdir -p results reports logs

# Show what we're running
echo ""
if [ "$MODE" = "full" ]; then
    echo -e "${YELLOW}Running FULL benchmark${NC}"
else
    echo -e "${YELLOW}Running QUICK benchmark${NC}"
fi

if [ $# -gt 0 ]; then
    echo -e "${BLUE}Arguments: $*${NC}"
fi
echo ""

# Pass all remaining arguments to run.sh
exec ./run.sh "$MODE" "$@"
