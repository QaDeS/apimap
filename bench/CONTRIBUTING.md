# Contributing to LiteLLM vs API Map Benchmark

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the benchmark suite.

## 🚀 Quick Start for Contributors

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd apibench

# Install dependencies
pip install -r requirements.txt

# Run tests to verify setup
python tests/test_setup.py

# Make your changes
# ...

# Test your changes
python benchmark.py --mock-server --quick

# Submit a PR!
```

## 📋 Development Setup

### Prerequisites

- Python 3.8+
- Docker 20.10+ (for Docker-based testing)
- Git

### Local Development

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Install development dependencies:**
   ```bash
   pip install black flake8 pytest
   ```

3. **Run setup tests:**
   ```bash
   python tests/test_setup.py
   ```

### Docker Development

For consistent testing across environments:

```bash
# Build containers
docker-compose build

# Start services
docker-compose up -d mock-server litellm apimap

# Run benchmark
docker-compose --profile benchmark run --rm benchmark

# Clean up
docker-compose down -v
```

## 🎯 Areas for Contribution

### 1. New Benchmarks

Add new types of benchmarks:

```python
# In benchmarks/runner.py or benchmark.py

class MyBenchmark:
    def __init__(self, config):
        self.config = config
    
    async def run(self, target_name, target_url):
        # Your benchmark logic
        return {
            "target": target_name,
            "my_metric": value
        }
```

**Ideas:**
- Memory usage benchmarks
- Error recovery tests
- Authentication performance
- Custom provider tests

### 2. Visualizations

Add new charts to `visualize.py`:

```python
def create_my_chart(data, ax):
    """Create a custom chart."""
    ax.plot(...)
    ax.set_title("My Chart")
```

**Ideas:**
- Latency distribution histograms
- Throughput over time
- Error rate comparisons
- Resource usage charts

### 3. Feature Matrix Updates

Update `FEATURE_MATRIX.md` when:
- New versions of LiteLLM/API Map are released
- New features are discovered
- Corrections are needed

### 4. Documentation

Improve documentation:
- README clarity
- Code comments
- Usage examples
- Troubleshooting guides

### 5. Bug Fixes

Fix issues:
- Incorrect metrics
- Docker issues
- Compatibility problems
- Typos and formatting

## 📝 Code Style

### Python Code

We use:
- **Black** for formatting (line length: 100)
- **Flake8** for linting
- **Type hints** where appropriate

```bash
# Format code
make format

# Run linter
make lint
```

### Commit Messages

Use conventional commits:

```
feat: add streaming benchmark
fix: correct latency calculation
docs: update README with examples
refactor: simplify benchmark runner
test: add mock server tests
```

## 🧪 Testing

### Before Submitting

1. **Run setup tests:**
   ```bash
   python tests/test_setup.py
   ```

2. **Run the benchmark:**
   ```bash
   python benchmark.py --mock-server --quick
   ```

3. **Check linting:**
   ```bash
   make lint
   ```

4. **Test Docker setup:**
   ```bash
   ./run.sh quick
   ```

### Writing Tests

Add tests to `tests/`:

```python
def test_my_feature():
    """Test description."""
    result = my_function()
    assert result == expected
```

Run tests:
```bash
pytest tests/
```

## 📤 Submitting Changes

### Pull Request Process

1. **Fork the repository**

2. **Create a feature branch:**
   ```bash
   git checkout -b feature/my-feature
   ```

3. **Make your changes**

4. **Test thoroughly**

5. **Commit with clear messages:**
   ```bash
   git commit -m "feat: add new benchmark for X"
   ```

6. **Push to your fork:**
   ```bash
   git push origin feature/my-feature
   ```

7. **Create a Pull Request**

### PR Checklist

- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Docker setup works
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if applicable)
- [ ] Commit messages are clear

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Performance improvement

## Testing
- [ ] Setup tests pass
- [ ] Benchmark runs successfully
- [ ] Docker setup works

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

## 🐛 Reporting Issues

### Bug Reports

Include:
1. **Environment:** OS, Docker version, Python version
2. **Steps to reproduce**
3. **Expected behavior**
4. **Actual behavior**
5. **Logs/output**

### Feature Requests

Include:
1. **Use case**
2. **Proposed solution**
3. **Alternatives considered**

## 🏆 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in relevant documentation

## 📞 Getting Help

- **Discussions:** Use GitHub Discussions for questions
- **Issues:** Report bugs via GitHub Issues
- **Documentation:** Check README.md and docs/

## 📝 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Thank You!

Every contribution, no matter how small, helps make this benchmark suite better for everyone!
