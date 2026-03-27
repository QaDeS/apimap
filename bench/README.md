# LiteLLM vs API Map - Benchmark

High-performance benchmark comparing [LiteLLM](https://github.com/BerriAI/litellm) and [API Map](https://github.com/qades/apimap) AI gateways.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  bun run bench                                              │
│  ├── Starts Docker services (mock-server, litellm, apimap)  │
│  ├── Runs benchmarks                                        │
│  ├── Stops services                                         │
│  └── Generates PDF report                                   │
├─────────────────────────────────────────────────────────────┤
│  Services (Docker):                                         │
│    - Mock LLM Server (Bun + Elysia) :9999  ← Direct target  │
│    - LiteLLM Proxy                   :4000                  │
│    - API Map (from local source)     :3000                  │
├─────────────────────────────────────────────────────────────┤
│  Report Generation: Python + matplotlib (PDF only)          │
└─────────────────────────────────────────────────────────────┘
```

## Usage

From project root:

```bash
# Quick benchmark (~2-3 min)
bun run bench

# Full benchmark suite (~10-15 min)
bun run bench:full
```

That's it. The benchmark runner manages Docker services automatically.

## Requirements

- **Docker** 20.10+ 
- **Docker Compose** 2.0+
- **~2GB free disk space**
- **~4GB RAM** recommended

## Options

```bash
# Skip targets (e.g., test only Direct)
bun run bench --skip-targets litellm,apimap

# Custom mock server latency
bun run bench --latency-mean 100 --latency-std 20

# Zero error rate
bun run bench --error-rate 0

# Keep services running after benchmark
bun run bench --keep-services
```

## Results

Saved to `bench/results/`:
- `benchmark_*.json` - Raw data
- `benchmark_*.md` - Human-readable report
- `reports/benchmark_report.pdf` - Visual charts

## Manual Service Control (Optional)

If you want to run services manually:

```bash
cd bench
docker-compose up -d mock-server litellm apimap
bun run benchmark:quick
docker-compose down
```

## Report Generation Only

If you have results but need to regenerate the PDF:

```bash
cd bench
pip install -r requirements.txt  # matplotlib + numpy
python3 visualize.py results/
```
