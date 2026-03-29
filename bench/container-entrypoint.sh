#!/bin/sh
# Container entrypoint script - runs INSIDE the Docker container
# Installs dependencies and then executes the main entrypoint with all arguments

# Install dependencies first
bun install --frozen-lockfile 2>/dev/null

# Execute the main entrypoint with all arguments passed through
exec /app/docker-entrypoint.sh "$@"
