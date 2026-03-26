#!/bin/sh
# Docker entrypoint for API Map
# Handles port mapping configuration for containerized deployments

set -e

# Default internal ports (these are what the server binds to inside the container)
API_PORT="${API_PORT:-3000}"
GUI_PORT="${GUI_PORT:-3001}"

# External ports (these are what users access from outside the container)
# If not specified, they default to the internal ports
EXTERNAL_PORT="${EXTERNAL_PORT:-${API_PORT}}"
EXTERNAL_GUI_PORT="${EXTERNAL_GUI_PORT:-${GUI_PORT}}"

# Build the command arguments
ARGS="--port ${API_PORT} --gui-port ${GUI_PORT}"

# Only add external-port if it differs from internal port
if [ "${EXTERNAL_PORT}" != "${API_PORT}" ]; then
    ARGS="${ARGS} --external-port ${EXTERNAL_PORT}"
fi

# Pass through other common environment variables as CLI args
if [ -n "${CONFIG_PATH}" ]; then
    ARGS="${ARGS} --config ${CONFIG_PATH}"
fi

if [ -n "${LOG_LEVEL}" ]; then
    ARGS="${ARGS} --log-level ${LOG_LEVEL}"
fi

if [ -n "${TIMEOUT}" ]; then
    ARGS="${ARGS} --timeout ${TIMEOUT}"
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                   API Map - Docker                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Configuration:"
echo "  Internal API Port:  ${API_PORT}"
echo "  External API Port:  ${EXTERNAL_PORT}"
if [ "${EXTERNAL_PORT}" != "${API_PORT}" ]; then
    echo "  Port Mapping:       ${EXTERNAL_PORT} → ${API_PORT}"
fi
echo "  GUI Port:           ${GUI_PORT}"
if [ "${EXTERNAL_GUI_PORT}" != "${GUI_PORT}" ]; then
    echo "  GUI External Port:  ${EXTERNAL_GUI_PORT}"
fi
echo ""
echo "Starting server with: bun run src/server.ts ${ARGS}"
echo ""

# Execute the server
exec bun run src/server.ts ${ARGS}
