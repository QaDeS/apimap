#!/bin/bash
#
# API Map - Unified Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/qades/apimap/main/scripts/install.sh | bash
#
# This script installs API Map using either Docker (default) or as a standalone binary.
#
# Installation modes:
#   Docker (default):  curl -fsSL ... | bash
#   Binary:            curl -fsSL ... | bash -s -- --binary
#
# Environment variables:
#   APIMAP_INSTALL_DIR         - Installation directory (default: ~/.local/share/apimap)
#   APIMAP_PORT                - API server port (default: 3000)
#   APIMAP_GUI_PORT            - GUI server port (default: 3001)
#   APIMAP_EXTERNAL_PORT       - External API port for port mapping (default: APIMAP_PORT)
#   APIMAP_EXTERNAL_GUI_PORT   - External GUI port for port mapping (default: APIMAP_GUI_PORT)
#   APIMAP_SKIP_SYSTEMD        - Skip systemd service setup
#   APIMAP_VERSION             - Specific version to install (binary mode only)
#
# Examples:
#   # Docker install with custom ports
#   APIMAP_PORT=8080 APIMAP_GUI_PORT=8081 ./install.sh
#
#   # Binary install
#   ./install.sh --binary
#
#   # Specific version (binary only)
#   APIMAP_VERSION=v2.1.0 ./install.sh --binary

set -e

# =============================================================================
# Configuration
# =============================================================================

REPO="qades/apimap"
IMAGE="ghcr.io/qades/apimap:latest"
INSTALL_DIR="${APIMAP_INSTALL_DIR:-$HOME/.local/share/apimap}"
CONFIG_DIR="$INSTALL_DIR/config"
LOGS_DIR="$INSTALL_DIR/logs"
API_PORT="${APIMAP_PORT:-3000}"
GUI_PORT="${APIMAP_GUI_PORT:-3001}"
EXTERNAL_PORT="${APIMAP_EXTERNAL_PORT:-$API_PORT}"
EXTERNAL_GUI_PORT="${APIMAP_EXTERNAL_GUI_PORT:-$GUI_PORT}"
SERVICE_NAME="apimap"

# Parse arguments
INSTALL_MODE="docker"  # docker or binary
while [[ $# -gt 0 ]]; do
    case $1 in
        --binary)
            INSTALL_MODE="binary"
            shift
            ;;
        --docker)
            INSTALL_MODE="docker"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "\n${CYAN}▶ $1${NC}"; }

# =============================================================================
# Helper Functions
# =============================================================================

detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "Mac";;
        CYGWIN*|MINGW*|MSYS*) echo "Windows";;
        *)          echo "UNKNOWN";;
    esac
}

detect_platform() {
    local os arch
    case "$(uname -s)" in
        Linux*)     os="linux";;
        Darwin*)    os="darwin";;
        CYGWIN*|MINGW*|MSYS*) os="windows";;
        *)          os="unknown";;
    esac
    case "$(uname -m)" in
        x86_64|amd64)  arch="x64";;
        arm64|aarch64) arch="arm64";;
        *)             arch="unknown";;
    esac
    echo "${os}-${arch}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

show_help() {
    cat << 'EOF'
API Map - Unified Installation Script

Usage: install.sh [OPTIONS]

Options:
  --docker       Install using Docker (default)
  --binary       Install as standalone binary (requires Bun)
  --help, -h     Show this help message

Environment Variables:
  APIMAP_INSTALL_DIR         Installation directory (default: ~/.local/share/apimap)
  APIMAP_PORT                API server port (default: 3000)
  APIMAP_GUI_PORT            GUI server port (default: 3001)
  APIMAP_EXTERNAL_PORT       External API port for reverse proxy (default: APIMAP_PORT)
  APIMAP_EXTERNAL_GUI_PORT   External GUI port for reverse proxy (default: APIMAP_GUI_PORT)
  APIMAP_SKIP_SYSTEMD        Skip systemd service setup
  APIMAP_VERSION             Specific version for binary install (e.g., v2.1.0)

Examples:
  # Docker install (recommended)
  curl -fsSL https://raw.githubusercontent.com/qades/apimap/main/scripts/install.sh | bash

  # Docker with custom ports
  APIMAP_PORT=8080 APIMAP_GUI_PORT=8081 ./install.sh

  # Binary install
  ./install.sh --binary

  # Binary specific version
  APIMAP_VERSION=v2.1.0 ./install.sh --binary
EOF
}

# =============================================================================
# Docker Installation
# =============================================================================

check_docker() {
    log_step "Checking Docker prerequisites"
    
    if ! command_exists docker; then
        log_error "Docker is not installed."
        echo ""
        echo "Please install Docker first:"
        echo "  - Linux: https://docs.docker.com/engine/install/"
        echo "  - macOS: https://docs.docker.com/desktop/install/mac-install/"
        echo "  - Windows: https://docs.docker.com/desktop/install/windows-install/"
        exit 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running or not accessible."
        echo ""
        echo "Please start Docker and try again."
        exit 1
    fi
    
    log_success "Docker is installed and running"
}

setup_directories() {
    log_step "Setting up directories"
    
    mkdir -p "$CONFIG_DIR" "$LOGS_DIR"
    
    # Set ownership to UID 1001 (apimap user in container)
    local os=$(detect_os)
    if [ "$os" = "Linux" ] || [ "$os" = "Mac" ]; then
        if chown -R 1001:1001 "$CONFIG_DIR" "$LOGS_DIR" 2>/dev/null; then
            log_success "Directory ownership set to UID 1001"
        else
            log_warn "Could not change ownership to UID 1001 (may need sudo)"
            log_warn "Making directories world-writable as fallback..."
            chmod -R 777 "$CONFIG_DIR" "$LOGS_DIR"
        fi
    fi
    
    log_success "Directories created at $INSTALL_DIR"
}

create_config() {
    local config_file="$CONFIG_DIR/config.yaml"
    
    if [ -f "$config_file" ]; then
        log_info "Existing configuration found"
        return
    fi
    
    log_step "Creating default configuration"
    
    cat > "$config_file" << 'EOF'
# API Map Configuration
# Documentation: https://github.com/qades/apimap#configuration

server:
  port: 3000
  host: "0.0.0.0"
  timeout: 120

logging:
  dir: "/app/logs"
  level: "info"
  maskKeys: true

# Configure your providers and API keys here
# providers:
#   openai:
#     apiKeyEnv: "OPENAI_API_KEY"
#     timeout: 180
#   
#   anthropic:
#     apiKeyEnv: "ANTHROPIC_API_KEY"
#     timeout: 180

# Configure routing rules here
# routes:
#   - pattern: "gpt-4*"
#     provider: openai
#     priority: 100

defaultProvider: null
EOF
    
    log_success "Configuration created"
}

create_docker_compose() {
    log_step "Creating docker-compose.yml"
    
    # Only add external port env vars if they differ from internal ports
    local external_config=""
    if [ "${EXTERNAL_PORT}" != "${API_PORT}" ]; then
        external_config="      - EXTERNAL_PORT=${EXTERNAL_PORT}"
    fi
    if [ "${EXTERNAL_GUI_PORT}" != "${GUI_PORT}" ]; then
        if [ -n "$external_config" ]; then
            external_config="${external_config}
      - EXTERNAL_GUI_PORT=${EXTERNAL_GUI_PORT}"
        else
            external_config="      - EXTERNAL_GUI_PORT=${EXTERNAL_GUI_PORT}"
        fi
    fi
    
    cat > "$INSTALL_DIR/docker-compose.yml" << EOF
# API Map - Docker Compose Configuration

services:
  apimap:
    image: ${IMAGE}
    container_name: ${SERVICE_NAME}
    restart: unless-stopped
    ports:
      - "${API_PORT}:3000"
      - "${GUI_PORT}:3001"
    environment:
      # Port mapping configuration
${external_config:-#      - EXTERNAL_PORT=3000}
      
      # API Keys - pass through from host environment
      - OPENAI_API_KEY=\${OPENAI_API_KEY:-}
      - ANTHROPIC_API_KEY=\${ANTHROPIC_API_KEY:-}
      - GOOGLE_API_KEY=\${GOOGLE_API_KEY:-}
      - GROQ_API_KEY=\${GROQ_API_KEY:-}
      - TOGETHER_API_KEY=\${TOGETHER_API_KEY:-}
      - FIREWORKS_API_KEY=\${FIREWORKS_API_KEY:-}
      - DEEPSEEK_API_KEY=\${DEEPSEEK_API_KEY:-}
      - MISTRAL_API_KEY=\${MISTRAL_API_KEY:-}
      - COHERE_API_KEY=\${COHERE_API_KEY:-}
      - OPENROUTER_API_KEY=\${OPENROUTER_API_KEY:-}
      - PERPLEXITY_API_KEY=\${PERPLEXITY_API_KEY:-}
      - ANYSCALE_API_KEY=\${ANYSCALE_API_KEY:-}
      
      # Ollama configuration
      - OLLAMA_BASE_URL=\${OLLAMA_BASE_URL:-http://host.docker.internal:11434}
      
    volumes:
      - ${CONFIG_DIR}:/app/config:rw
      - ${LOGS_DIR}:/app/logs:rw
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
EOF
    
    log_success "docker-compose.yml created"
}

create_docker_wrapper() {
    log_step "Creating command wrapper"
    
    cat > "$INSTALL_DIR/apimap" << 'EOF'
#!/bin/bash
# API Map - Docker Command Wrapper

INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$INSTALL_DIR/docker-compose.yml"

case "${1:-}" in
    start)
        echo "Starting API Map..."
        docker compose -f "$COMPOSE_FILE" up -d
        echo ""
        echo "API Map is running at:"
        echo "  API:  http://localhost:3000"
        echo "  GUI:  http://localhost:3001"
        ;;
    stop)
        echo "Stopping API Map..."
        docker compose -f "$COMPOSE_FILE" down
        ;;
    restart)
        echo "Restarting API Map..."
        docker compose -f "$COMPOSE_FILE" restart
        ;;
    logs)
        docker compose -f "$COMPOSE_FILE" logs -f
        ;;
    status)
        docker compose -f "$COMPOSE_FILE" ps
        ;;
    update)
        echo "Updating API Map..."
        docker compose -f "$COMPOSE_FILE" pull
        docker compose -f "$COMPOSE_FILE" up -d
        ;;
    config)
        ${EDITOR:-nano} "$INSTALL_DIR/config/config.yaml"
        ;;
    shell)
        docker compose -f "$COMPOSE_FILE" exec apimap sh
        ;;
    *)
        echo "API Map - Universal Model Router (Docker)"
        echo ""
        echo "Usage: apimap [command]"
        echo ""
        echo "Commands:"
        echo "  start    Start API Map"
        echo "  stop     Stop API Map"
        echo "  restart  Restart API Map"
        echo "  logs     View logs"
        echo "  status   Check status"
        echo "  update   Update to latest version"
        echo "  config   Edit configuration"
        echo "  shell    Open shell in container"
        echo ""
        echo "Directories:"
        echo "  Config: $INSTALL_DIR/config"
        echo "  Logs:   $INSTALL_DIR/logs"
        ;;
esac
EOF
    
    chmod +x "$INSTALL_DIR/apimap"
    log_success "Wrapper script created"
}

setup_docker_systemd() {
    if [ -n "$APIMAP_SKIP_SYSTEMD" ]; then
        return
    fi
    
    local os=$(detect_os)
    if [ "$os" != "Linux" ]; then
        return
    fi
    
    if [ ! -d /etc/systemd/system ]; then
        return
    fi
    
    if [ "$EUID" -ne 0 ] && ! command_exists sudo; then
        log_warn "Cannot setup systemd without sudo access"
        return
    fi
    
    log_step "Setting up systemd service"
    
    cat > /tmp/apimap.service << EOF
[Unit]
Description=API Map - Universal Model Router
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${INSTALL_DIR}
ExecStart=${INSTALL_DIR}/apimap start
ExecStop=${INSTALL_DIR}/apimap stop

[Install]
WantedBy=multi-user.target
EOF
    
    if [ "$EUID" -eq 0 ]; then
        mv /tmp/apimap.service /etc/systemd/system/
    else
        sudo mv /tmp/apimap.service /etc/systemd/system/
    fi
    
    systemctl daemon-reload
    log_success "Systemd service installed"
    log_info "Enable with: sudo systemctl enable apimap"
    log_info "Start with:  sudo systemctl start apimap"
}

install_docker() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         API Map - Docker Installation                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    log_info "Installation directory: $INSTALL_DIR"
    log_info "API port: $API_PORT"
    log_info "GUI port: $GUI_PORT"
    [ "${EXTERNAL_PORT}" != "${API_PORT}" ] && log_info "External API port: $EXTERNAL_PORT"
    [ "${EXTERNAL_GUI_PORT}" != "${GUI_PORT}" ] && log_info "External GUI port: $EXTERNAL_GUI_PORT"
    echo ""
    
    check_docker
    setup_directories
    create_config
    create_docker_compose
    create_docker_wrapper
    setup_docker_systemd
    
    # Add to PATH suggestion
    local shell_rc=""
    case "$SHELL" in
        */bash) shell_rc="$HOME/.bashrc" ;;
        */zsh)  shell_rc="$HOME/.zshrc" ;;
        */fish) shell_rc="$HOME/.config/fish/config.fish" ;;
    esac
    
    if [ -n "$shell_rc" ]; then
        echo ""
        log_info "To add 'apimap' to your PATH, run:"
        echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> $shell_rc"
        echo "  source $shell_rc"
    fi
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Installation Complete!                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    log_success "API Map installed to $INSTALL_DIR"
    echo ""
    echo "Quick start:"
    echo "  cd $INSTALL_DIR"
    echo "  ./apimap start"
    echo ""
    echo "Access:"
    if [ "${EXTERNAL_PORT}" != "${API_PORT}" ]; then
        echo "  API: http://localhost:$EXTERNAL_PORT (mapped to container port $API_PORT)"
    else
        echo "  API: http://localhost:$API_PORT"
    fi
    if [ "${EXTERNAL_GUI_PORT}" != "${GUI_PORT}" ]; then
        echo "  GUI: http://localhost:$EXTERNAL_GUI_PORT (mapped to container port $GUI_PORT)"
    else
        echo "  GUI: http://localhost:$GUI_PORT"
    fi
    echo ""
    echo "Configuration:"
    echo "  Edit: $CONFIG_DIR/config.yaml"
    echo "  Logs: $LOGS_DIR"
    echo ""
    log_info "Next steps:"
    echo "  1. Edit $CONFIG_DIR/config.yaml to add your API keys"
    echo "  2. Run: cd $INSTALL_DIR && ./apimap start"
    echo ""
}

# =============================================================================
# Binary Installation
# =============================================================================

install_bun() {
    log_step "Installing Bun"
    curl -fsSL https://bun.sh/install | bash
    
    if [ -f "$HOME/.bun/bin/bun" ]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi
    
    if ! command_exists bun; then
        log_error "Bun installation failed"
        exit 1
    fi
    
    log_success "Bun installed ($(bun --version))"
}

check_binary_prereqs() {
    log_step "Checking prerequisites"
    
    if ! command_exists bun; then
        log_warn "Bun is not installed"
        install_bun
    else
        log_success "Bun is installed ($(bun --version))"
    fi
    
    if ! command_exists git; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    log_success "All prerequisites met"
}

build_binary() {
    local platform="$1"
    local src_dir="$INSTALL_DIR/source"
    local bin_dir="$INSTALL_DIR/bin"
    
    log_step "Building API Map binary"
    
    mkdir -p "$bin_dir"
    
    # Clone or update source
    if [ -d "$src_dir/.git" ]; then
        log_info "Updating existing source..."
        cd "$src_dir" && git pull origin main
    else
        log_info "Cloning repository..."
        rm -rf "$src_dir"
        git clone --depth 1 "https://github.com/$REPO.git" "$src_dir"
    fi
    
    cd "$src_dir"
    
    # Install dependencies
    log_info "Installing dependencies..."
    bun install
    cd gui && bun install && cd ..
    
    # Build GUI
    log_info "Building GUI..."
    bun run build:gui
    
    # Compile binary
    log_info "Compiling binary (this may take a minute)..."
    bun build --compile --target="bun-${platform}" \
        --outfile="$bin_dir/apimap-server" \
        src/server.ts
    
    # Copy GUI build
    mkdir -p "$INSTALL_DIR/gui"
    cp -r gui/build "$INSTALL_DIR/gui/"
    
    log_success "Binary built at $bin_dir/apimap-server"
}

create_binary_config() {
    local config_file="$CONFIG_DIR/config.yaml"
    
    if [ -f "$config_file" ]; then
        log_info "Existing configuration found"
        return
    fi
    
    log_step "Creating default configuration"
    
    cat > "$config_file" << EOF
# API Map Configuration

server:
  port: ${API_PORT}
  host: "0.0.0.0"
  timeout: 120

logging:
  dir: "${LOGS_DIR}"
  level: "info"
  maskKeys: true

defaultProvider: null
EOF
    
    log_success "Configuration created"
}

create_binary_wrapper() {
    local bin_dir="$INSTALL_DIR/bin"
    
    log_step "Creating command wrapper"
    
    mkdir -p "$bin_dir"
    
    cat > "$bin_dir/apimap" << EOF
#!/bin/bash
# API Map - Binary Command Wrapper

INSTALL_DIR="$INSTALL_DIR"
CONFIG_DIR="$CONFIG_DIR"
LOGS_DIR="$LOGS_DIR"
PID_FILE="$INSTALL_DIR/apimap.pid"

mkdir -p "\$CONFIG_DIR" "\$LOGS_DIR"

is_running() {
    if [ -f "\$PID_FILE" ]; then
        local pid=\$(cat "\$PID_FILE" 2>/dev/null)
        [ -n "\$pid" ] && kill -0 "\$pid" 2>/dev/null
        return \$?
    fi
    return 1
}

case "\${1:-}" in
    start)
        if is_running; then
            echo "API Map is already running (PID: \$(cat "\$PID_FILE"))"
            exit 1
        fi
        echo "Starting API Map..."
        export APIMAP_CONFIG_DIR="\$CONFIG_DIR"
        nohup "$bin_dir/apimap-server" --gui-port "${GUI_PORT}" > "\$LOGS_DIR/apimap.log" 2>&1 &
        echo \$! > "\$PID_FILE"
        sleep 2
        if is_running; then
            echo "API Map started!"
            echo "  API: http://localhost:${API_PORT}"
            echo "  GUI: http://localhost:${GUI_PORT}"
        else
            echo "Failed to start. Check logs: \$LOGS_DIR/apimap.log"
            exit 1
        fi
        ;;
    stop)
        if ! is_running; then
            echo "API Map is not running"
            exit 1
        fi
        kill "\$(cat "\$PID_FILE")" 2>/dev/null
        rm -f "\$PID_FILE"
        echo "API Map stopped"
        ;;
    restart)
        \$0 stop || true
        sleep 1
        \$0 start
        ;;
    status)
        if is_running; then
            echo "API Map is running (PID: \$(cat "\$PID_FILE"))"
        else
            echo "API Map is not running"
        fi
        ;;
    logs)
        tail -f "\$LOGS_DIR/apimap.log"
        ;;
    config)
        \${EDITOR:-nano} "\$CONFIG_DIR/config.yaml"
        ;;
    update)
        echo "Updating API Map..."
        curl -fsSL https://raw.githubusercontent.com/$REPO/main/scripts/install.sh | bash -s -- --binary
        ;;
    *)
        echo "API Map - Binary Mode"
        echo ""
        echo "Usage: apimap [start|stop|restart|status|logs|config|update]"
        ;;
esac
EOF
    
    chmod +x "$bin_dir/apimap"
    log_success "Wrapper script created"
}

setup_binary_systemd() {
    if [ -n "$APIMAP_SKIP_SYSTEMD" ]; then
        return
    fi
    
    if [ "$(uname -s)" != "Linux" ]; then
        return
    fi
    
    if [ ! -d /etc/systemd/system ]; then
        return
    fi
    
    log_step "Setting up systemd service"
    
    cat > /tmp/apimap.service << EOF
[Unit]
Description=API Map - Universal Model Router
After=network.target

[Service]
Type=forking
User=%I
WorkingDirectory=$INSTALL_DIR
Environment="PATH=$HOME/.bun/bin:/usr/local/bin:/usr/bin:/bin"
Environment="APIMAP_CONFIG_DIR=$CONFIG_DIR"
ExecStart=$INSTALL_DIR/bin/apimap start
ExecStop=$INSTALL_DIR/bin/apimap stop
PIDFile=$INSTALL_DIR/apimap.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    
    if command_exists sudo; then
        sudo mv /tmp/apimap.service /etc/systemd/system/apimap@.service
        sudo systemctl daemon-reload
    else
        mv /tmp/apimap.service /etc/systemd/system/apimap@.service
        systemctl daemon-reload
    fi
    
    log_success "Systemd service installed"
}

add_to_path() {
    local bin_dir="$INSTALL_DIR/bin"
    local shell_rc=""
    
    case "$SHELL" in
        */bash) shell_rc="$HOME/.bashrc" ;;
        */zsh)  shell_rc="$HOME/.zshrc" ;;
        */fish) shell_rc="$HOME/.config/fish/config.fish" ;;
    esac
    
    if [ "$(uname -s)" = "Darwin" ] && [ -f "$HOME/.bash_profile" ]; then
        shell_rc="$HOME/.bash_profile"
    fi
    
    if [ -n "$shell_rc" ] && [ -f "$shell_rc" ]; then
        if ! grep -q "$bin_dir" "$shell_rc" 2>/dev/null; then
            log_info "Adding $bin_dir to PATH in $shell_rc"
            echo "export PATH=\"$bin_dir:\$PATH\"" >> "$shell_rc"
        fi
    fi
}

install_binary() {
    local platform=$(detect_platform)
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         API Map - Binary Installation                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    log_info "Platform: $platform"
    log_info "Installation directory: $INSTALL_DIR"
    echo ""
    
    check_binary_prereqs
    setup_directories
    build_binary "$platform"
    create_binary_config
    create_binary_wrapper
    setup_binary_systemd
    add_to_path
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Installation Complete!                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    log_success "API Map installed to $INSTALL_DIR"
    echo ""
    echo "Quick start:"
    echo "  $INSTALL_DIR/bin/apimap start"
    echo ""
    echo "Access:"
    echo "  API: http://localhost:$API_PORT"
    echo "  GUI: http://localhost:$GUI_PORT"
    echo ""
    
    if ! command -v apimap >/dev/null 2>&1; then
        echo "Note: Restart your shell or run: export PATH=\"$INSTALL_DIR/bin:\$PATH\""
    fi
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    if [ "$INSTALL_MODE" = "binary" ]; then
        install_binary
    else
        install_docker
    fi
}

main "$@"
