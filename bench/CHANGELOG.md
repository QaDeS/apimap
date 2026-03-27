# Changelog

All notable changes to the LiteLLM vs API Map Benchmark project.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2024-03-26

### Added
- Initial release of the benchmark suite
- Docker-based setup with one-command execution (`./run.sh`)
- Mock LLM server for consistent testing
- Automated service orchestration with docker-compose
- **Performance Benchmarks:**
  - Latency testing (P50, P95, P99)
  - Throughput testing (1, 10, 50, 100 concurrent)
  - Streaming performance (TTFT, tokens/sec)
- **Feature Comparison:**
  - 50+ features compared across 13 categories
  - Provider support matrix
  - Protocol compatibility analysis
- **Output Formats:**
  - JSON results for programmatic access
  - Markdown reports for human reading
  - PDF visualizations (when matplotlib available)
- **CI/CD:**
  - GitHub Actions workflow for automated testing
  - Weekly full benchmark runs
  - PR comments with benchmark results
- **Documentation:**
  - Comprehensive README
  - Feature matrix documentation
  - Contributing guidelines
  - Quick start guide

### Infrastructure
- Docker Compose configuration for 4 services
- Health checks for all services
- Volume mounting for persistent results
- Environment variable configuration
- GitHub Actions for CI/CD

### Scripts
- `run.sh` - Master orchestration script
- `quickstart.sh` - User-friendly entry point
- `docker-entrypoint.sh` - Container startup script
- `setup.py` - Installation verification

### Benchmark Components
- `benchmark.py` - Simple synchronous benchmark
- `benchmarks/runner.py` - Advanced async benchmark suite
- `servers/mock_llm_server.py` - Configurable mock LLM
- `visualize.py` - Results visualization

## [Unreleased]

### Planned
- WebSocket performance benchmarks
- Memory usage profiling
- Multi-region latency testing
- Cache hit/miss ratio measurement
- Security/penetration testing
- Long-running stability tests
- Custom provider plugin testing
- Helm charts for Kubernetes deployment
- AWS CloudFormation templates

---

## Release Notes Template

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security improvements
```

---

For the complete list of changes, see the [Git commit history](https://github.com/YOUR_USERNAME/YOUR_REPO/commits/main).
