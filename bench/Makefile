# Makefile for LiteLLM vs API Map Benchmark
#
# This Makefile provides convenient shortcuts for common tasks.
# The recommended way to run benchmarks is using the run.sh script.

.PHONY: help install test quick full clean status logs docker-build docker-push

# Default target
help:
	@echo "LiteLLM vs API Map - Benchmark"
	@echo ""
	@echo "Recommended commands:"
	@echo "  make quick          Run quick benchmark (2-3 min) - RECOMMENDED"
	@echo "  make full           Run full benchmark (10-15 min)"
	@echo "  make clean          Clean up all containers"
	@echo ""
	@echo "Other commands:"
	@echo "  make install        Install local dependencies"
	@echo "  make test           Run setup tests"
	@echo "  make status         Show container status"
	@echo "  make logs           Show service logs"
	@echo "  make docker-build   Build Docker images"
	@echo "  make docker-push    Push images to registry"
	@echo ""
	@echo "See README.md for detailed usage."

# Quick benchmark (recommended)
quick:
	@echo "Running quick benchmark..."
	@chmod +x run.sh
	@./run.sh quick

# Full benchmark suite
full:
	@echo "Running full benchmark suite..."
	@chmod +x run.sh
	@./run.sh full

# Clean up containers and images
clean:
	@echo "Cleaning up..."
	@chmod +x run.sh
	@./run.sh clean

# Show status
status:
	@echo "Showing status..."
	@chmod +x run.sh
	@./run.sh status

# Show logs
logs:
	@echo "Showing logs..."
	@chmod +x run.sh
	@./run.sh logs

# Install dependencies locally
install:
	@echo "Installing dependencies..."
	pip install -r requirements.txt

# Run setup tests
test:
	@echo "Running tests..."
	python tests/test_setup.py

# Run linting
lint:
	@echo "Running linter..."
	@which flake8 > /dev/null || pip install flake8
	flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
	flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

# Format code
format:
	@echo "Formatting code..."
	@which black > /dev/null || pip install black
	black . --line-length 100

# Docker commands
docker-build:
	@echo "Building Docker images..."
	docker-compose build --parallel

docker-push:
	@echo "Pushing Docker images..."
	docker-compose push

# Development helpers (no Docker)
dev-mock-server:
	@echo "Starting mock server (local)..."
	python servers/mock_llm_server.py --port 9999

dev-benchmark:
	@echo "Running benchmark (local, requires services running)..."
	python benchmark.py --quick

dev-visualize:
	@echo "Generating visualizations..."
	python visualize.py results/

# CI/CD helpers
ci-test:
	@echo "Running CI tests..."
	python tests/test_setup.py
	make lint

ci-benchmark:
	@echo "Running CI benchmark..."
	@chmod +x run.sh
	@BENCHMARK_DURATION=10 ./run.sh quick
