# API Map - Universal Model Router

[![CI](https://github.com/qades/apimap/actions/workflows/ci.yml/badge.svg)](https://github.com/qades/apimap/actions/workflows/ci.yml)
[![Benchmark](https://github.com/qades/apimap/actions/workflows/benchmark.yml/badge.svg)](https://github.com/qades/apimap/actions/workflows/benchmark.yml)
[![Benchmark Results](https://img.shields.io/badge/benchmark-results-green?logo=github)](https://qades.github.io/apimap/)
[![Feature Matrix](https://img.shields.io/badge/features-vs%20LiteLLM-blue)](./FEATURE_MATRIX.md)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io%2Fqades%2Fapimap-blue?logo=docker)](https://ghcr.io/qades/apimap)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A powerful AI model gateway that routes requests between OpenAI, Anthropic, local models (Ollama, LM Studio), and more. Features a modern SvelteKit GUI for easy configuration and request monitoring.

## Features

- **Multi-Provider Support**: Route requests to OpenAI, Anthropic, Google Gemini, Groq, Together AI, Fireworks, DeepSeek, Mistral, Cohere, OpenRouter, and local providers (Ollama, LM Studio, llama.cpp, vLLM)
- **Protocol Bridging**: Use Anthropic's API format to call OpenAI-compatible providers and vice versa
- **Pattern-Based Routing**: Wildcard patterns for flexible model matching (e.g., `gpt-4*` matches all GPT-4 variants)
- **Real-Time Monitoring**: Web GUI shows unrouted requests, routing statistics, and request logs
- **Configuration Management**: Visual editor for providers, routes, and YAML configuration with automatic backups
- **Streaming Support**: Full support for streaming responses across all compatible providers

## Quick Start

### Option 1: Docker Install Script (Recommended)

The fastest way to get started on Linux, macOS, or Windows:

```bash
curl -fsSL https://raw.githubusercontent.com/qades/apimap/main/scripts/install.sh | bash
```

Then start the server:
```bash
~/.local/share/apimap/apimap start
```

Access:
- **API**: http://localhost:3000
- **GUI**: http://localhost:3001

The install script creates:
- `~/.local/share/apimap/config/` - Configuration files
- `~/.local/share/apimap/logs/` - Request logs
- `~/.local/share/apimap/apimap` - Convenience command

### Option 2: Docker Compose (Manual)

For more control over the deployment:

```bash
# 1. Clone or download the compose file
mkdir -p apimap && cd apimap
curl -O https://raw.githubusercontent.com/qades/apimap/main/docker-compose.yml
curl -O https://raw.githubusercontent.com/qades/apimap/main/.env.example

# 2. Create directories with correct permissions
mkdir -p config logs
sudo chown -R 1001:1001 config logs  # Linux/macOS

# 3. Configure your API keys
cp .env.example .env
# Edit .env with your API keys

# 4. Start
docker-compose up -d
```

### Option 3: From Source (Development)

For development or custom modifications:

```bash
# 1. Clone repository
git clone https://github.com/qades/apimap.git
cd apimap

# 2. Install dependencies
bun install
cd gui && bun install && cd ..

# 3. Build GUI
bun run build:gui

# 4. Start development server (with hot reload)
bun run dev
```

## Configuration

After installation, configure your providers in `config/config.yaml` or through the web GUI.

Example configuration:
```yaml
server:
  port: 3000
  host: "0.0.0.0"
  timeout: 120

logging:
  dir: "./logs"
  level: "info"
  maskKeys: true

providers:
  openai:
    apiKeyEnv: "OPENAI_API_KEY"
    timeout: 180
  
  anthropic:
    apiKeyEnv: "ANTHROPIC_API_KEY"
    timeout: 180
  
  ollama:
    baseUrl: "http://localhost:11434"
    timeout: 300

routes:
  - pattern: "claude-3*"
    provider: anthropic
    priority: 100
  
  - pattern: "gpt-4*"
    provider: openai
    priority: 90
  
  - pattern: "local/*"
    provider: ollama
    model: "${1}"
    priority: 80

defaultProvider: openai
```

### Pattern Syntax

- `*` - Matches any sequence of characters
- `?` - Matches any single character
- `${1}`, `${2}`, etc. - Capture groups for model mapping

### Priority System

Routes are checked in priority order (highest first). First match wins.

- `100+` - Exact matches, critical routes
- `70-99` - High priority (e.g., GPT-4, Claude)
- `50-69` - Medium priority
- `30-49` - Low priority
- `0-29` - Fallback routes

## Usage

### Using OpenAI API Format

```bash
curl http://localhost:3000/v1/chat/completions \
  -H "Authorization: Bearer your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Using Anthropic API Format

```bash
curl http://localhost:3000/v1/messages \
  -H "x-api-key: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-opus-20240229",
    "max_tokens": 1024,
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Local Models via Ollama

```bash
curl http://localhost:3000/v1/chat/completions \
  -H "Authorization: Bearer dummy" \
  -d '{
    "model": "llama2:13b",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Listing Available Models

```bash
# OpenAI format
curl http://localhost:3000/v1/models \
  -H "Authorization: Bearer your-key"

# Anthropic format
curl http://localhost:3000/v1/models \
  -H "x-api-key: your-key" \
  -H "anthropic-version: 2023-06-01"
```

## Environment Variables

### Port Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `APIMAP_PORT` | External port for API | 3000 |
| `APIMAP_GUI_PORT` | External port for GUI | 3001 |
| `APIMAP_EXTERNAL_PORT` | External port for API (reverse proxy) | Same as APIMAP_PORT |
| `APIMAP_EXTERNAL_GUI_PORT` | External port for GUI (reverse proxy) | Same as APIMAP_GUI_PORT |

**Note:** Internal container ports (`API_PORT`, `GUI_PORT`) are not user-configurable.

### API Provider Keys

| Variable | Provider |
|----------|----------|
| `OPENAI_API_KEY` | OpenAI |
| `ANTHROPIC_API_KEY` | Anthropic |
| `GOOGLE_API_KEY` | Google Gemini |
| `GROQ_API_KEY` | Groq |
| `TOGETHER_API_KEY` | Together AI |
| `FIREWORKS_API_KEY` | Fireworks AI |
| `DEEPSEEK_API_KEY` | DeepSeek |
| `MISTRAL_API_KEY` | Mistral AI |
| `COHERE_API_KEY` | Cohere |
| `OPENROUTER_API_KEY` | OpenRouter |
| `PERPLEXITY_API_KEY` | Perplexity |
| `ANYSCALE_API_KEY` | Anyscale |
| `AWS_ACCESS_KEY_ID` | AWS Bedrock |
| `AWS_SECRET_ACCESS_KEY` | AWS Bedrock |
| `AWS_REGION` | AWS Bedrock |

### Custom Port Mapping Example

When running behind a reverse proxy with different external ports:

```bash
# Map external port 8080/8081 to internal 3000/3001
export APIMAP_PORT=8080
export APIMAP_GUI_PORT=8081
export APIMAP_EXTERNAL_PORT=8080
export APIMAP_EXTERNAL_GUI_PORT=8081

# With install script
APIMAP_PORT=8080 APIMAP_GUI_PORT=8081 ./install.sh

# Or with docker-compose
docker-compose up -d
```

## GUI Features

### Dashboard
- Real-time request statistics
- Unrouted requests list with one-click route creation
- Provider status and routing overview

### Providers
- Visual configuration of all providers
- API key management (direct or environment variables)
- Custom provider support

### Routes
- Interactive route editor with priority management
- Pattern tester for validating wildcards
- Quick-add from unrouted requests

### Configuration
- Raw YAML editor with syntax validation
- Download/upload configuration
- Automatic backup on every change

### Backups
- Automatic backup creation
- One-click restore
- Backup history management

### Logs
- Request/response logging
- Error tracking
- Detailed request inspection

## Management API

The server exposes a management API at `/api/admin/`:

- `GET /api/admin/status` - System status
- `GET /api/admin/providers` - List providers
- `PUT /api/admin/providers` - Update providers
- `GET /api/admin/routes` - List routes
- `PUT /api/admin/routes` - Update routes
- `GET /api/admin/unrouted` - Get unrouted requests
- `GET /api/admin/backups` - List backups
- `POST /api/admin/backups` - Create backup
- `POST /api/admin/backups/:filename` - Restore backup

## Performance

API Map is designed for high-performance routing with minimal overhead:

| Metric | Typical Value |
|--------|---------------|
| **Cold Start** | ~50ms |
| **Request Latency** | <5ms overhead |
| **Throughput** | 1000+ req/sec |
| **Memory Usage** | ~50MB base |

### Running Benchmarks

Benchmark your changes locally (runs entirely in Docker):

```bash
# Default benchmark (~5-10 minutes) - OpenAI→OpenAI protocol
bun run bench

# Full benchmark (~15-25 minutes) - ALL 16 protocol combinations
bun run bench:full

# Quick validation (~2-3 minutes) - minimal scenarios
bun run bench:quick
```

Results are saved to `bench/results/` and `bench/reports/` with detailed metrics comparing API Map against LiteLLM and Direct (baseline).

See [BENCHMARK.md](BENCHMARK.md) for detailed documentation.

## Advanced Deployment

### Docker Run (Direct)

For direct Docker execution without compose:

```bash
# Create directories with proper permissions
mkdir -p config logs
sudo chown -R 1001:1001 config logs  # Linux/macOS only

# Run container
docker run -d \
  --name apimap \
  --restart unless-stopped \
  -p 3000:3000 \
  -p 3001:3001 \
  -e OPENAI_API_KEY="$OPENAI_API_KEY" \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  -v "$(pwd)/config:/app/config:rw" \
  -v "$(pwd)/logs:/app/logs:rw" \
  ghcr.io/qades/apimap:latest
```

### Binary Installation (No Docker)

For systems without Docker, install as a standalone binary:

```bash
curl -fsSL https://raw.githubusercontent.com/qades/apimap/main/scripts/install.sh | bash -s -- --binary
```

This requires [Bun](https://bun.sh) (auto-installed if missing). The binary will be built from source.

### Permission Troubleshooting

The container runs as user `apimap` (UID 1001). If you see "permission denied" errors:

**Linux/macOS:**
```bash
# Set ownership to container user
sudo chown -R 1001:1001 ./config ./logs
```

**All platforms (fallback):**
```bash
# Make directories world-writable (less secure, but works everywhere)
chmod -R 777 ./config ./logs
```

**Without persistent volumes:**
Simply omit the volume mounts (logs/config will be lost when container stops):
```bash
docker run -d -p 3000:3000 -p 3001:3001 ghcr.io/qades/apimap:latest
```

### Building from Source

```bash
# Build the Docker image
docker build -t apimap:local .

# Run locally built image
docker run -d -p 3000:3000 -p 3001:3001 apimap:local
```

## Project Structure

```
apimap/
├── src/                    # Core source code
│   ├── types/              # TypeScript type definitions
│   ├── providers/          # Provider implementations
│   ├── transformers/       # Format transformers
│   ├── config/             # Configuration management
│   ├── logging/            # Logging system
│   ├── router/             # Request routing
│   └── server.ts           # Main server entry
├── gui/                    # SvelteKit management GUI
├── config/                 # Configuration files
├── logs/                   # Request logs
├── scripts/                # Installation scripts
│   └── install.sh          # Unified install script
├── bench/                  # Benchmark suite
├── docker-compose.yml      # Docker Compose configuration
└── README.md
```

## License

MIT
