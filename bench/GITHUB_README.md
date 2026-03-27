# 🔬 LiteLLM vs API Map - Benchmark Suite

[![Benchmark CI](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/benchmark.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/benchmark.yml)
[![Docker](https://img.shields.io/badge/docker-ready-blue?logo=docker)](https://github.com/YOUR_USERNAME/YOUR_REPO/pkgs/container/apibench)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A comprehensive, configurable benchmark suite comparing [LiteLLM](https://github.com/BerriAI/litellm) and [API Map](https://github.com/qades/apimap) AI gateway solutions.

## 🎯 What This Benchmarks

| Metric | Description |
|--------|-------------|
| **Latency** | Single-request P50, P95, P99 response times |
| **Throughput** | Requests per second at various concurrency levels |
| **Streaming** | Time to first token, tokens per second |
| **Features** | Side-by-side capability comparison |

## 🚀 Quick Start (Seriously, Just 1 Command)

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd apibench
./quickstart.sh
```

**That's it!** This will:
- ✅ Check your Docker installation
- 🔨 Build all containers (mock LLM, LiteLLM, API Map)
- 🚀 Start the services
- ⚡ Run benchmarks (~2-3 minutes)
- 📊 Show you the results

### Full Benchmark (10-15 minutes)

```bash
./quickstart.sh full
```

## 📊 Sample Results

After running, you'll see something like:

```
═══════════════════════════════════════════════════════════════
  ✅ Benchmark completed successfully!
═══════════════════════════════════════════════════════════════

Results saved to:
  📄 JSON: results/benchmark_20240326_143022.json
  📄 Markdown: results/benchmark_20240326_143022.md

Quick Summary:

Latency Results:
  LiteLLM: Mean=145ms, P95=189ms
  API Map: Mean=132ms, P95=175ms

Throughput Results (highest concurrency):
  LiteLLM: 45 req/sec @ 50 concurrent
  API Map: 52 req/sec @ 50 concurrent

Feature Score: LiteLLM 35 - API Map 18
```

## 📋 Requirements

- **Docker** 20.10+ ([Get Docker](https://docs.docker.com/get-docker/))
- **~2GB free disk space**
- **~4GB RAM**

That's it! No Python, no dependencies to install manually.

## 🏗️ How It Works

This benchmark creates a complete isolated environment:

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network                            │
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │ Mock Server  │    │   LiteLLM    │    │   API Map    │  │
│  │   :9999      │◄───│   :4000      │    │   :3000      │  │
│  │              │    │              │    │              │  │
│  │ Simulates    │    │ AI Gateway   │    │ AI Gateway   │  │
│  │ LLM API      │    │ (Python)     │    │ (Bun/TS)     │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         ▲                                                    │
│         │              ┌──────────────┐                      │
│         └──────────────│  Benchmark   │                      │
│                        │   Runner     │                      │
│                        └──────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

1. **Mock Server**: Simulates LLM responses (100ms latency, configurable)
2. **LiteLLM**: AI gateway (Python-based, 100+ providers)
3. **API Map**: AI gateway (Bun/TypeScript, pattern routing)
4. **Benchmark Runner**: Executes tests and collects metrics

## 🎨 Commands

```bash
# Quick benchmark (2-3 minutes) - RECOMMENDED
./run.sh

# Full benchmark (10-15 minutes)
./run.sh full

# Check status
./run.sh status

# View logs
./run.sh logs

# Clean up containers
./run.sh clean

# Show help
./run.sh help
```

## 📁 Output Files

Results are saved to:

| File | Description |
|------|-------------|
| `results/*.json` | Raw benchmark data |
| `results/*.md` | Human-readable report |
| `reports/*.pdf` | Visualizations (charts) |

View results:

```bash
# Markdown report
cat results/benchmark_*.md

# JSON data
jq . results/benchmark_*.json

# PDF report (if generated)
open reports/benchmark_report.pdf
```

## 🔧 Configuration

Create a `.env` file to customize:

```bash
# Benchmark duration
BENCHMARK_DURATION=60

# Concurrency levels
BENCHMARK_CONCURRENCY=1,10,50,100

# Mock server behavior
LATENCY_MEAN_MS=100
LATENCY_STD_MS=20
ERROR_RATE=0.01
```

## 📊 What Gets Measured

### 1. Latency Benchmark
- **Mean**: Average response time
- **Median**: Middle value
- **P95**: 95th percentile (tail latency)
- **P99**: 99th percentile (worst case)
- **Error Rate**: Failed requests

### 2. Throughput Benchmark
Tests at concurrency levels: 1, 10, 50 (or custom)
- **Requests/sec**: Successful requests per second
- **Success Rate**: % of successful requests
- **Mean Latency**: Average under load

### 3. Streaming Benchmark
- **Time to First Token**: Initial response time
- **Time to Last Token**: Total streaming time
- **Tokens/sec**: Generation speed

### 4. Feature Comparison
50+ features compared:
- Provider support
- Protocol compatibility
- Management capabilities
- Observability features

## 🧪 Development

Want to modify the benchmark?

```bash
# Install dependencies locally
pip install -r requirements.txt

# Run without Docker
python servers/mock_llm_server.py --port 9999 &
python benchmark.py --mock-server --quick

# Run tests
python tests/test_setup.py
```

### Project Structure

```
apibench/
├── run.sh              # Main entry point
├── quickstart.sh       # User-friendly wrapper
├── docker-compose.yml  # Service orchestration
├── benchmark.py        # Benchmark logic
├── visualize.py        # Result visualization
├── benchmarks/         # Advanced benchmark suite
├── servers/            # Mock LLM server
├── configs/            # Gateway configurations
└── tests/              # Test suite
```

## 🔄 Continuous Integration

This repository includes GitHub Actions that:

- ✅ Run quick benchmark on every push/PR
- 📊 Post results as PR comments
- 🕒 Run full benchmark weekly
- 🐳 Build and publish Docker images

See `.github/workflows/benchmark.yml`

## 📚 Documentation

- [Detailed README](apibench/README.md)
- [Feature Matrix](apibench/FEATURE_MATRIX.md) - Complete feature comparison
- [Project Summary](apibench/PROJECT_SUMMARY.md)

## 🤝 Contributing

Contributions welcome! Areas for help:

- Additional benchmark tests
- New visualizations
- Bug fixes
- Documentation improvements

## 📄 License

MIT License - See [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- [LiteLLM](https://github.com/BerriAI/litellm) - Comprehensive AI gateway
- [API Map](https://github.com/qades/apimap) - Innovative model router

---

**Ready to benchmark?** Just run:

```bash
./quickstart.sh
```
