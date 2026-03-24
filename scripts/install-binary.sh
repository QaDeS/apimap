#!/bin/bash
#
# API Map - Binary Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/qades/apimap/main/scripts/install-binary.sh | bash
#
# This script installs API Map as a standalone binary (no Docker required).
# Note: Binary installation requires Bun runtime.
#
# Environment variables:
#   APIMAN_INSTALL_DIR - Installation directory (default: ~/.local/share/apimap)
#   APIMAN_API_PORT    - API server port (default: 3000)
#   APIMAN_GUI_PORT    - GUI server port (default: 3001)
#   APIMAN_SKIP_SYSTEMD - Skip systemd service setup
#

set -e

# Configuration
REPO="qades/apimap"
INSTALL_DIR="${APIMAN_INSTALL_DIR:-$HOME/.local/share/apimap}"
BIN_DIR="$INSTALL_DIR/bin"
CONFIG_DIR="$INSTALL_DIR/config"
LOGS_DIR="$INSTALL_DIR/logs"
GUI_BUILD_DIR="$INSTALL_DIR/gui"
API_PORT="${APIMAN_API_PORT:-3000}"
GUI_PORT="${APIMAN_GUI_PORT:-3001}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS and architecture
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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for Bun
    if ! command_exists bun; then
        log_warn "Bun is not installed. Installing now..."
        install_bun
    else
        log_success "Bun is installed ($(bun --version))"
    fi
    
    # Check Git for cloning
    if ! command_exists git; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# Install Bun
install_bun() {
    log_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    
    # Source bun if installed to default location
    if [ -f "$HOME/.bun/bin/bun" ]; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi
    
    if ! command_exists bun; then
        log_error "Bun installation failed. Please install manually:"
        echo "  curl -fsSL https://bun.sh/install | bash"
        exit 1
    fi
    
    log_success "Bun installed ($(bun --version))"
}

# Create directories
setup_directories() {
    log_info "Setting up directories..."
    
    mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$LOGS_DIR" "$GUI_BUILD_DIR"
    
    log_success "Directories created"
}

# Clone or update repository
get_source() {
    local src_dir="$INSTALL_DIR/source"
    
    if [ -d "$src_dir/.git" ]; then
        log_info "Updating existing source..."
        cd "$src_dir"
        git pull origin main
    else
        log_info "Cloning repository..."
        rm -rf "$src_dir"
        git clone --depth 1 "https://github.com/$REPO.git" "$src_dir"
    fi
    
    log_success "Source code ready"
    echo "$src_dir"
}

# Build binary from source
build_binary() {
    local src_dir="$1"
    local platform="$2"
    
    log_info "Building API Map binary for $platform..."
    
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
        --outfile="$BIN_DIR/apimap-server" \
        src/server.ts
    
    # Copy GUI build
    cp -r gui/build "$GUI_BUILD_DIR/"
    
    log_success "Binary built at $BIN_DIR/apimap-server"
}

# Download pre-built binary (fallback)
download_binary() {
    local platform="$1"
    local version="${APIMAN_VERSION:-latest}"
    
    log_info "Attempting to download pre-built binary..."
    
    local download_url="https://github.com/$REPO/releases/download/${version}/apimap-${platform}"
    
    if curl -fsSL "$download_url" -o "$BIN_DIR/apimap-server" 2>/dev/null; then
        chmod +x "$BIN_DIR/apimap-server"
        log_success "Binary downloaded"
        return 0
    else
        log_warn "No pre-built binary available for $platform"
        return 1
    fi
}

# Create default config
create_default_config() {
    local config_file="$CONFIG_DIR/config.yaml"
    
    if [ -f "$config_file" ]; then
        log_info "Existing configuration found"
        return
    fi
    
    log_info "Creating default configuration..."
    
    cat > "$config_file" << EOF
# API Map Configuration
# Generated by install script

server:
  port: ${API_PORT}
  host: "0.0.0.0"
  timeout: 120

logging:
  dir: "${LOGS_DIR}"
  level: "info"
  maskKeys: true

# Configure your providers and API keys here
# providers:
#   openai:
#     apiKeyEnv: "OPENAI_API_KEY"
#     timeout: 180

# routes:
#   - pattern: "gpt-4*"
#     provider: openai
#     priority: 100

defaultProvider: null
EOF
    
    log_success "Configuration created at $config_file"
}

# Create wrapper script
create_wrapper_script() {
    log_info "Creating command wrapper..."
    
    cat > "$BIN_DIR/apimap" << EOF
#!/bin/bash
# API Map - Binary Command Wrapper

INSTALL_DIR="$INSTALL_DIR"
CONFIG_DIR="$CONFIG_DIR"
LOGS_DIR="$LOGS_DIR"
PID_FILE="$INSTALL_DIR/apimap.pid"

# Ensure directories exist
mkdir -p "\$CONFIG_DIR" "\$LOGS_DIR"

# Function to check if running
is_running() {
    if [ -f "\$PID_FILE" ]; then
        local pid=\$(cat "\$PID_FILE" 2>/dev/null)
        if [ -n "\$pid" ] && kill -0 "\$pid" 2>/dev/null; then
            return 0
        fi
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
        export API_MAP_CONFIG_DIR="\$CONFIG_DIR"
        nohup "$BIN_DIR/apimap-server" --gui-port "${GUI_PORT}" > "\$LOGS_DIR/apimap.log" 2>&1 &
        echo \$! > "\$PID_FILE"
        
        # Wait a moment to check if it started successfully
        sleep 2
        if is_running; then
            echo "API Map started successfully!"
            echo "  API:  http://localhost:${API_PORT}"
            echo "  GUI:  http://localhost:${GUI_PORT}"
            echo "  PID:  \$(cat "\$PID_FILE")"
        else
            echo "Failed to start API Map. Check logs: \$LOGS_DIR/apimap.log"
            exit 1
        fi
        ;;
    
    stop)
        if ! is_running; then
            echo "API Map is not running"
            exit 1
        fi
        
        echo "Stopping API Map..."
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
            echo "  API: http://localhost:${API_PORT}"
            echo "  GUI: http://localhost:${GUI_PORT}"
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
        curl -fsSL https://raw.githubusercontent.com/$REPO/main/scripts/install-binary.sh | bash
        ;;
    
    *)
        echo "API Map - Universal Model Router (Binary Installation)"
        echo ""
        echo "Usage: apimap [command]"
        echo ""
        echo "Commands:"
        echo "  start    Start API Map"
        echo "  stop     Stop API Map"
        echo "  restart  Restart API Map"
        echo "  status   Check status"
        echo "  logs     View logs"
        echo "  update   Update to latest version"
        echo "  config   Edit configuration"
        echo ""
        echo "Directories:"
        echo "  Binary: $BIN_DIR"
        echo "  Config: \$CONFIG_DIR"
        echo "  Logs:   \$LOGS_DIR"
        ;;
esac
EOF
    
    chmod +x "$BIN_DIR/apimap"
    log_success "Wrapper script created"
}

# Setup systemd service
setup_systemd() {
    if [ -n "$APIMAN_SKIP_SYSTEMD" ]; then
        return
    fi
    
    if [ "$(uname -s)" != "Linux" ]; then
        return
    fi
    
    if [ ! -d /etc/systemd/system ]; then
        return
    fi
    
    log_info "Setting up systemd service..."
    
    cat > /tmp/apimap.service << EOF
[Unit]
Description=API Map - Universal Model Router
After=network.target

[Service]
Type=forking
User=%I
WorkingDirectory=$INSTALL_DIR
Environment="PATH=$HOME/.bun/bin:/usr/local/bin:/usr/bin:/bin"
Environment="API_MAP_CONFIG_DIR=$CONFIG_DIR"
ExecStart=$BIN_DIR/apimap start
ExecStop=$BIN_DIR/apimap stop
PIDFile=$INSTALL_DIR/apimap.pid
Restart=on-failure
RestartSec=5

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
    
    log_success "Systemd service template installed"
    log_info "Enable with: sudo systemctl enable apimap@\$USER"
    log_info "Start with:  sudo systemctl start apimap@\$USER"
}

# Add to PATH
add_to_path() {
    local shell_rc=""
    case "$SHELL" in
        */bash) shell_rc="$HOME/.bashrc" ;;
        */zsh)  shell_rc="$HOME/.zshrc" ;;
        */fish) shell_rc="$HOME/.config/fish/config.fish" ;;
    esac
    
    # Also check .bash_profile on macOS
    if [ "$(uname -s)" = "Darwin" ] && [ -f "$HOME/.bash_profile" ]; then
        shell_rc="$HOME/.bash_profile"
    fi
    
    if [ -n "$shell_rc" ] && [ -f "$shell_rc" ]; then
        if ! grep -q "$BIN_DIR" "$shell_rc" 2>/dev/null; then
            log_info "Adding $BIN_DIR to PATH in $shell_rc..."
            echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$shell_rc"
            log_success "Added to PATH. Run: source $shell_rc"
        fi
    fi
}

# Main installation
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║             API Map - Binary Installation                  ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    
    local platform=$(detect_platform)
    log_info "Detected platform: $platform"
    log_info "Installation directory: $INSTALL_DIR"
    echo ""
    
    check_prerequisites
    setup_directories
    
    # Try to download pre-built binary first, fallback to building
    if ! download_binary "$platform"; then
        log_info "Building from source..."
        local src_dir=$(get_source)
        build_binary "$src_dir" "$platform"
    fi
    
    create_default_config
    create_wrapper_script
    setup_systemd
    add_to_path
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Installation Complete!                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    log_success "API Map installed to $INSTALL_DIR"
    echo ""
    echo "Quick start:"
    echo "  $BIN_DIR/apimap start"
    echo ""
    echo "Access:"
    echo "  API: http://localhost:$API_PORT"
    echo "  GUI: http://localhost:$GUI_PORT"
    echo ""
    echo "Commands:"
    echo "  apimap start    - Start the server"
    echo "  apimap stop     - Stop the server"
    echo "  apimap status   - Check status"
    echo "  apimap logs     - View logs"
    echo "  apimap config   - Edit configuration"
    echo ""
    log_info "Next steps:"
    echo "  1. Edit $CONFIG_DIR/config.yaml to add your API keys"
    echo "  2. Run: $BIN_DIR/apimap start"
    echo ""
    
    if ! command_exists apimap; then
        echo "Note: You may need to restart your shell or run:"
        echo "  export PATH=\"$BIN_DIR:\$PATH\""
    fi
    echo ""
}

# Run main
main "$@"
