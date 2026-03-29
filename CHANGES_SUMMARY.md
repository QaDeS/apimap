# Summary of Changes

## Environment Variable Consolidation

### Fixed Typos
- Renamed `APIMAN_*` → `APIMAP_*` in all files
  - `APIMAN_API_PORT` → `APIMAP_PORT`
  - `APIMAN_GUI_PORT` → `APIMAP_GUI_PORT`
  - `APIMAN_EXTERNAL_PORT` → `APIMAP_EXTERNAL_PORT`
  - `APIMAN_EXTERNAL_GUI_PORT` → `APIMAP_EXTERNAL_GUI_PORT`
  - `APIMAN_INSTALL_DIR` → `APIMAP_INSTALL_DIR`
  - `APIMAN_SKIP_SYSTEMD` → `APIMAP_SKIP_SYSTEMD`

### Consolidated Port Variables
- **User-facing**: `APIMAP_PORT`, `APIMAP_GUI_PORT`, `APIMAP_EXTERNAL_PORT`, `APIMAP_EXTERNAL_GUI_PORT`
- **Internal** (container-only): `API_PORT`, `GUI_PORT`, `EXTERNAL_PORT`, `EXTERNAL_GUI_PORT`
- **Benchmark-isolated**: `MOCK_SERVER_PORT`, `LITELLM_PORT`, etc. (kept in `bench/`)

### Updated Files
1. `docker-compose.yml` - Uses `APIMAP_PORT` / `APIMAP_GUI_PORT`
2. `docker-entrypoint.sh` - Uses `APIMAP_EXTERNAL_PORT` from host
3. `.env.example` - Documents all user-facing variables
4. `scripts/install.sh` - Unified install script with correct naming
5. `README.md` - Updated documentation

## Install Script Merger

### Removed
- `scripts/install-binary.sh` - Merged into unified `install.sh`

### New Unified Install Script
- `scripts/install.sh` - Supports both Docker and Binary modes
  - Default: Docker installation
  - `--binary` flag: Binary installation
  - `--help` flag: Usage information

### Usage Examples
```bash
# Docker install (recommended)
curl -fsSL ... | bash

# Docker with custom ports
APIMAP_PORT=8080 APIMAP_GUI_PORT=8081 ./install.sh

# Binary install
./install.sh --binary

# Binary specific version
APIMAP_VERSION=v2.1.0 ./install.sh --binary
```

## README Restructuring

### Simplified Installation Section
Three clear options:
1. **Docker Install Script** (Recommended) - One-liner with `curl | bash`
2. **Docker Compose** (Manual) - For more control
3. **From Source** (Development) - For developers

### Removed Duplication
- Removed redundant "Deployment" section
- Consolidated environment variable documentation
- Removed manual Docker run examples (refer to docker-compose)

## Testing

### Full Test Suite
- ✅ 292 tests passed
- 0 failures

### Full Benchmark
- ✅ Completed successfully
- Exit code: 0
- Results: API Map shows lower latency than LiteLLM across all scenarios

### New E2E Install Tests
- `scripts/test/test-install.sh` - Comprehensive install script tests
- Tests syntax validation, env consistency, Docker integration

## Environment Variable Reference

| Variable | Location | Purpose |
|----------|----------|---------|
| `APIMAP_PORT` | User-facing | External API port (default: 3000) |
| `APIMAP_GUI_PORT` | User-facing | External GUI port (default: 3001) |
| `APIMAP_EXTERNAL_PORT` | User-facing | For reverse proxy scenarios |
| `APIMAP_EXTERNAL_GUI_PORT` | User-facing | For reverse proxy scenarios |
| `APIMAP_INSTALL_DIR` | User-facing | Installation directory |
| `APIMAP_SKIP_SYSTEMD` | User-facing | Skip systemd setup |
| `APIMAP_VERSION` | User-facing | Specific version (binary mode) |
| `*_API_KEY` (12) | User-facing | Provider API keys |
| `API_PORT` | Internal | Container internal port |
| `GUI_PORT` | Internal | Container internal port |
| `BENCHMARK_*` | Isolated | Benchmark config (in `bench/`) |
| `MOCK_*` | Isolated | Mock server config (in `bench/`) |

## Backward Compatibility

⚠️ **Breaking Change**: Users previously using `APIMAN_*` variables need to update to `APIMAP_*`.

Migration:
```bash
# Before (old, no longer works)
APIMAN_API_PORT=8080 ./install.sh

# After (new)
APIMAP_PORT=8080 ./install.sh
```
