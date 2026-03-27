# Project Index - LiteLLM vs API Map Benchmark

Complete guide to all files in this repository.

## 🚀 Start Here

| File | Purpose |
|------|---------|
| `quickstart.sh` | **START HERE** - One command to run everything |
| `run.sh` | Master orchestration script with multiple modes |
| `README.md` | Full documentation |

## 📁 File Structure

```
apibench/
│
├── 🚀 ENTRY POINTS
│   ├── quickstart.sh           # User-friendly 1-command start
│   ├── run.sh                  # Master script (quick/full/clean/status)
│   └── Makefile                # Alternative make commands
│
├── 🐳 DOCKER CONFIGURATION
│   ├── docker-compose.yml      # Service orchestration (4 containers)
│   ├── Dockerfile.mockserver   # Mock LLM server image
│   ├── Dockerfile.benchmark    # Benchmark runner image
│   └── docker-entrypoint.sh    # Container startup script
│
├── 🔧 CONFIGURATION
│   ├── configs/
│   │   ├── litellm_config.yaml     # LiteLLM gateway config
│   │   └── apimap_config.yaml      # API Map gateway config
│   ├── .env.example            # Environment variables template
│   ├── .gitignore              # Git ignore rules
│   └── .dockerignore           # Docker ignore rules
│
├── 🏃 BENCHMARK CODE
│   ├── benchmark.py            # Simple benchmark runner (17KB)
│   ├── benchmarks/
│   │   ├── __init__.py
│   │   └── runner.py           # Advanced async benchmark (37KB)
│   └── servers/
│       ├── __init__.py
│       └── mock_llm_server.py  # Mock LLM API server (11KB)
│
├── 📊 VISUALIZATION
│   ├── visualize.py            # Results visualization & PDF charts
│   └── results/                # Generated benchmark results
│       └── .gitkeep
│
├── 🧪 TESTING
│   ├── tests/
│   │   ├── __init__.py
│   │   └── test_setup.py       # Setup verification tests
│   └── setup.py                # Installation script
│
├── 📚 DOCUMENTATION
│   ├── README.md               # Main documentation (10KB)
│   ├── GITHUB_README.md        # GitHub repo landing page
│   ├── FEATURE_MATRIX.md       # 50+ feature comparison (11KB)
│   ├── PROJECT_SUMMARY.md      # Project overview (8KB)
│   ├── CONTRIBUTING.md         # Contribution guidelines
│   ├── CHANGELOG.md            # Version history
│   ├── INDEX.md                # This file
│   └── LICENSE                 # MIT License
│
├── 🔄 CI/CD
│   └── .github/
│       └── workflows/
│           └── benchmark.yml   # GitHub Actions workflow
│
├── 📦 DEPENDENCIES
│   ├── requirements.txt        # Python packages
│   └── reports/                # Generated PDF reports
│       └── .gitkeep
│
└── 📖 ADDITIONAL
    └── ... (supporting files)
```

## 🎯 Quick Reference

### Running Benchmarks

```bash
# Quick (2-3 min) - RECOMMENDED
./quickstart.sh
./run.sh quick
make quick

# Full (10-15 min)
./quickstart.sh full
./run.sh full
make full

# Clean up
./run.sh clean
make clean
```

### Docker Commands

```bash
# Build and start services
docker-compose up --build

# Run benchmark
docker-compose --profile benchmark run --rm benchmark

# Generate visualizations
docker-compose --profile visualize run --rm visualize

# Stop everything
docker-compose down -v
```

### Development

```bash
# Install locally
pip install -r requirements.txt

# Run tests
python tests/test_setup.py

# Local benchmark
python benchmark.py --mock-server --quick

# Format code
make format

# Run linter
make lint
```

## 📊 Output Files

Generated in `results/` and `reports/`:

| File Pattern | Description |
|--------------|-------------|
| `results/benchmark_*.json` | Raw benchmark data |
| `results/benchmark_*.md` | Human-readable report |
| `reports/benchmark_report.pdf` | Visualizations |

## 🔧 Key Components

### Mock Server (`servers/mock_llm_server.py`)
- Simulates LLM API responses
- Configurable latency, error rate
- OpenAI-compatible endpoints
- Supports streaming

### Benchmark Runner (`benchmark.py`)
- Simple synchronous tests
- Latency measurement
- Throughput testing
- Feature comparison

### Advanced Benchmark (`benchmarks/runner.py`)
- Async/await implementation
- High concurrency testing
- Streaming benchmarks
- Detailed metrics

### Visualizer (`visualize.py`)
- Matplotlib charts
- PDF report generation
- Latency distributions
- Throughput graphs

## 🐳 Docker Services

| Service | Port | Purpose |
|---------|------|---------|
| mock-server | 9999 | Simulated LLM API |
| litellm | 4000 | LiteLLM gateway |
| apimap | 3000 | API Map gateway |
| benchmark | - | Test runner |

## 📝 Configuration Files

| File | Purpose |
|------|---------|
| `configs/litellm_config.yaml` | LiteLLM routing config |
| `configs/apimap_config.yaml` | API Map routing config |
| `.env` | Environment variables (create from .env.example) |
| `docker-compose.yml` | Service definitions |

## 🧪 Testing

| File | Purpose |
|------|---------|
| `tests/test_setup.py` | Verify installation |
| `setup.py` | Setup script |

## 📚 Documentation Files

| File | Description |
|------|-------------|
| `README.md` | Complete usage guide |
| `GITHUB_README.md` | GitHub repo front page |
| `FEATURE_MATRIX.md` | Detailed feature comparison |
| `PROJECT_SUMMARY.md` | Architecture & design |
| `CONTRIBUTING.md` | How to contribute |
| `CHANGELOG.md` | Version history |

## 🔄 CI/CD

GitHub Actions workflow in `.github/workflows/benchmark.yml`:

- **Triggers:** Push, PR, weekly schedule, manual
- **Jobs:** Test, Quick Benchmark, Full Benchmark
- **Artifacts:** Results uploaded automatically
- **Comments:** PRs get benchmark summaries

## 📦 Requirements

### For Users
- Docker 20.10+
- Docker Compose 2.0+
- ~2GB disk space
- ~4GB RAM

### For Developers
- Python 3.8+
- pip
- git
- (Optional) black, flake8, pytest

## 🎯 Common Tasks

### Add New Benchmark

1. Edit `benchmark.py` for simple tests
2. Edit `benchmarks/runner.py` for async tests
3. Add result dataclass
4. Update visualization
5. Test with `./run.sh quick`

### Update Feature Matrix

1. Edit `FEATURE_MATRIX.md`
2. Update categories/scores
3. Regenerate with benchmark
4. Update `benchmark.py` feature list

### Add Visualization

1. Edit `visualize.py`
2. Add chart function
3. Include in PDF output
4. Test generation

## 🔍 File Sizes (Approximate)

```
Total: ~2,800 lines of code
├── Python: ~2,400 lines
├── Shell: ~250 lines
├── YAML: ~150 lines
└── Docs: ~1,200 lines (Markdown)
```

## 🆘 Getting Help

1. Check `README.md` for usage
2. Run `python tests/test_setup.py` to verify
3. Check logs: `./run.sh logs`
4. See `CONTRIBUTING.md` for development

## 📄 License

All files are MIT Licensed unless otherwise noted.

---

**Last Updated:** 2024-03-26  
**Version:** 1.0.0
