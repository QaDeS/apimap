# LiteLLM vs API Map - Benchmark Project Summary

## Project Overview

This benchmark suite provides comprehensive testing and comparison capabilities for two leading AI gateway solutions:

- **LiteLLM** (https://github.com/BerriAI/litellm) - Python SDK + Proxy Server with 100+ provider support
- **API Map** (https://github.com/qades/apimap) - TypeScript/Bun Universal Model Router with pattern-based routing

## Project Structure

```
apibench/
├── README.md                    # Main documentation (10KB)
├── FEATURE_MATRIX.md            # Detailed feature comparison (11KB)
├── PROJECT_SUMMARY.md           # This file
├── LICENSE                      # MIT License
├── Makefile                     # Build and test automation
├── quickstart.sh               # One-command setup script
├── requirements.txt            # Python dependencies
├── setup.py                    # Installation script
│
├── benchmark.py                # Simple benchmark runner (17KB)
├── visualize.py                # Results visualization (9KB)
│
├── benchmarks/                 # Advanced benchmark suite
│   ├── __init__.py
│   └── runner.py              # Full-featured async benchmark (37KB)
│
├── servers/                    # Test infrastructure
│   ├── __init__.py
│   └── mock_llm_server.py     # Mock LLM API server (11KB)
│
├── configs/                    # Gateway configurations
│   ├── litellm_config.yaml    # LiteLLM test config
│   └── apimap_config.yaml     # API Map test config
│
├── tests/                      # Test suite
│   ├── __init__.py
│   └── test_setup.py          # Setup verification
│
└── results/                    # Generated benchmark results
```

## Total Code Statistics

- **Total Lines of Code**: ~2,400 lines
- **Main Components**:
  - Benchmark runner: 560 lines
  - Mock server: 275 lines
  - Visualization: 260 lines
  - Feature comparison: 400+ feature checks

## Key Features

### Performance Benchmarks

1. **Latency Testing**
   - Single-request latency measurement
   - P50, P95, P99 percentile analysis
   - Standard deviation calculation
   - Error rate tracking

2. **Throughput Testing**
   - Concurrent request handling (1, 10, 50, 100)
   - Requests per second measurement
   - Load performance analysis

3. **Streaming Performance**
   - Time to first token (TTFT)
   - Time to last token (TTLT)
   - Tokens per second
   - Chunk latency analysis

### Feature Comparison

Comprehensive comparison across 16 categories:
- Core Capabilities (6 features)
- Provider Support (20+ providers)
- Protocol & Format (10 features)
- Routing & Load Balancing (8 features)
- Management & UI (10 features)
- Observability (12 features)
- Caching & Performance (5 features)
- Security & Guardrails (10 features)
- Advanced Features (10 features)
- Deployment Options (12 options)
- Development & Extensibility (10 aspects)
- Documentation & Support (10 aspects)
- Runtime & Performance (7 metrics)

## Usage Options

### 1. Quick Start (Recommended)

```bash
./quickstart.sh
```

One command that:
- Checks dependencies
- Installs requirements
- Runs verification tests
- Executes quick benchmark

### 2. Manual Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Verify setup
python tests/test_setup.py

# Run benchmark with mock server
python benchmark.py --mock-server --quick
```

### 3. Using Make

```bash
make install    # Install dependencies
make test       # Run tests
make quick      # Quick benchmark
make benchmark  # Full benchmark
```

## Test Configurations

### Mock Server Mode
Uses simulated LLM API for consistent, repeatable testing:
- Configurable latency (default: 100ms ± 20ms)
- Configurable error rate (default: 1%)
- Configurable token throughput (default: 50 tokens/sec)
- No API keys required

### Real Gateway Mode
Tests against actual gateway instances:
- Requires running LiteLLM proxy
- Requires running API Map server
- Can use real or mock backends
- More realistic performance data

## Output Formats

1. **Console Output**
   - Real-time progress
   - Summary statistics
   - Winner announcements

2. **JSON Results** (`results/benchmark_*.json`)
   - Machine-readable raw data
   - Detailed metrics
   - Timestamped

3. **Markdown Report** (`results/benchmark_*.md`)
   - Human-readable tables
   - Feature comparisons
   - Configuration details

4. **PDF Visualizations** (`results/benchmark_*.pdf`)
   - Latency comparison charts
   - Throughput graphs
   - Feature score breakdowns
   - (Requires matplotlib)

## Benchmark Methodology

### Latency Testing
1. Warmup: 5 requests to prime caches
2. Measurement: 50 requests (configurable)
3. Statistics: Mean, median, P95, P99
4. Error tracking: Count and rate

### Throughput Testing
1. Duration: 10 seconds per concurrency level
2. Concurrency: 1, 10, 50, 100 concurrent clients
3. Metric: Successful requests per second
4. Error tracking: Failed request count

### Feature Comparison
1. Static analysis of documented features
2. Community feedback integration
3. Version-specific capability tracking
4. Regular updates to maintain accuracy

## Extensibility

### Adding New Benchmarks

```python
class MyBenchmark:
    def __init__(self, config):
        self.config = config
    
    async def run(self, target_name, target_url):
        # Implement your benchmark
        return result
```

### Adding New Metrics

```python
@dataclass
class MyResult:
    target: str
    custom_metric: float
```

### Custom Visualizations

```python
def create_my_chart(data, ax):
    # Custom matplotlib visualization
    ax.plot(...)
```

## Requirements

### Minimum Requirements
- Python 3.8+
- aiohttp
- requests

### Full Features
- fastapi + uvicorn (for mock server)
- matplotlib + numpy (for visualizations)
- websockets (for streaming tests)

### Optional
- litellm (for running LiteLLM proxy)
- bun (for running API Map)

## Docker Support

Both gateways can be tested via Docker:

```bash
# Build API Map image
cd ../apimap && docker build -t apimap:benchmark .

# Run with Docker Compose
docker-compose up -d
```

## CI/CD Integration

The benchmark suite is designed for CI/CD:

```yaml
# Example GitHub Actions
- name: Run Benchmark
  run: |
    pip install -r requirements.txt
    python benchmark.py --mock-server --quick
    
- name: Upload Results
  uses: actions/upload-artifact@v3
  with:
    name: benchmark-results
    path: results/
```

## Known Limitations

1. **Network Variance**: Real-world results depend on network conditions
2. **Provider Rate Limits**: May affect throughput benchmarks
3. **Resource Contention**: Concurrent tests compete for CPU/memory
4. **Cold Start**: First requests may be slower due to initialization

## Best Practices

1. **Warmup**: Always include warmup requests
2. **Multiple Runs**: Run benchmarks multiple times for consistency
3. **Isolation**: Run benchmarks on dedicated hardware if possible
4. **Monitoring**: Monitor resource usage during benchmarks
5. **Documentation**: Document configuration and environment

## Future Enhancements

Potential additions to the benchmark suite:

- [ ] WebSocket performance testing
- [ ] Multi-region latency testing
- [ ] Cache hit/miss ratio measurement
- [ ] Memory usage profiling
- [ ] Security/penetration testing
- [ ] Long-running stability tests
- [ ] Custom provider plugin testing

## Contributing

Contributions are welcome! Areas for contribution:

- Additional benchmarks
- New visualizations
- Bug fixes
- Documentation improvements
- Feature matrix updates

## License

MIT License - See LICENSE file for details.

## Resources

- LiteLLM Documentation: https://docs.litellm.ai/
- API Map Repository: https://github.com/qades/apimap
- Benchmark Results: See `results/` directory after running

---

**Version**: 1.0.0  
**Last Updated**: 2024-03-26  
**Maintainers**: Benchmark Suite Team
