# syntax=docker/dockerfile:1
# ============================================================
# API Map - Universal Model Router
# ============================================================

FROM oven/bun:1-alpine AS base
WORKDIR /app

# Install dependencies for native modules
RUN apk add --no-cache ca-certificates

# ============================================================
# Dependencies
# ============================================================
FROM base AS deps

COPY package.json bun.lock ./
COPY gui/package.json gui/bun.lock ./gui/

RUN bun install --frozen-lockfile

# ============================================================
# Build
# ============================================================
FROM base AS builder

COPY --from=deps /app/node_modules node_modules
COPY --from=deps /app/gui/node_modules gui/node_modules

COPY . .

# Build GUI for production
RUN bun run build:gui

# ============================================================
# Runtime
# ============================================================
FROM base AS runner

# Create non-root user
RUN addgroup -g 1001 -S apimap && \
    adduser -S apimap -u 1001

# Copy source files and built GUI
COPY --from=builder /app/src src/
COPY --from=builder /app/gui/build gui/build/
COPY --from=builder /app/gui/package.json gui/package.json
COPY --from=builder /app/config config/
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules node_modules/

# Create directories for logs and config
RUN mkdir -p logs config/backups && \
    chown -R apimap:apimap /app

USER apimap

# Expose ports
# API: 3000, GUI: 3001
EXPOSE 3000 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Default run script
CMD ["bun", "run", "src/server.ts", "--gui-port", "3001"]
