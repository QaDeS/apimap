#!/usr/bin/env python3
"""
LiteLLM vs API Map - Simplified Benchmark Runner

This script provides a simple way to run benchmarks comparing
the two AI gateway solutions.

Usage:
    # Run with mock server (recommended for testing)
    python benchmark.py --mock-server

    # Run against existing gateways
    python benchmark.py --litellm-url http://localhost:4000 --apimap-url http://localhost:3000

    # Quick test (fewer requests)
    python benchmark.py --mock-server --quick
"""

import argparse
import asyncio
import json
import os
import subprocess
import sys
import time
import statistics
from datetime import datetime
from pathlib import Path

# Try to import required packages
try:
    import aiohttp
    import requests
except ImportError:
    print("Error: Required packages not installed.")
    print("Please run: pip install aiohttp requests")
    sys.exit(1)


# ============================================================================
# Configuration
# ============================================================================

class Config:
    """Benchmark configuration."""
    LITELLM_URL = "http://localhost:4000"
    APIMAP_URL = "http://localhost:3000"
    MOCK_SERVER_URL = "http://localhost:9999"
    
    # Test parameters
    WARMUP_REQUESTS = 5
    BENCHMARK_REQUESTS = 50
    CONCURRENCY_LEVELS = [1, 10, 25]
    
    # Model
    MODEL = "gpt-4o-mini"
    
    # Output
    OUTPUT_DIR = Path(__file__).parent / "results"


# ============================================================================
# HTTP Clients
# ============================================================================

class GatewayClient:
    """Simple HTTP client for gateway testing."""
    
    def __init__(self, base_url: str, api_key: str = "test-key"):
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
    
    def chat_completion(self, model: str, messages: list, 
                       stream: bool = False, **kwargs) -> dict:
        """Send a synchronous chat completion request."""
        url = f"{self.base_url}/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        payload = {
            "model": model,
            "messages": messages,
            "stream": stream,
            **kwargs
        }
        
        start = time.perf_counter()
        response = requests.post(url, headers=headers, json=payload, timeout=60)
        latency = (time.perf_counter() - start) * 1000
        
        response.raise_for_status()
        
        return {
            "latency_ms": latency,
            "status": response.status_code,
            "data": response.json() if not stream else None
        }
    
    def health_check(self) -> bool:
        """Check if gateway is healthy."""
        try:
            response = requests.get(
                f"{self.base_url}/v1/models",
                headers={"Authorization": f"Bearer {self.api_key}"},
                timeout=5
            )
            return response.status_code == 200
        except:
            return False


# ============================================================================
# Benchmark Functions
# ============================================================================

def benchmark_latency(client: GatewayClient, name: str, 
                      num_requests: int = 50) -> dict:
    """Benchmark request latency."""
    print(f"  Measuring latency for {name}...")
    
    messages = [
        {"role": "system", "content": "You are helpful."},
        {"role": "user", "content": "Say 'hello' briefly."}
    ]
    
    latencies = []
    errors = 0
    
    # Warmup
    for _ in range(Config.WARMUP_REQUESTS):
        try:
            client.chat_completion(Config.MODEL, messages, max_tokens=50)
        except Exception as e:
            pass
    
    # Benchmark
    for i in range(num_requests):
        try:
            result = client.chat_completion(Config.MODEL, messages, max_tokens=50)
            latencies.append(result["latency_ms"])
        except Exception as e:
            errors += 1
            if i < 3:  # Show first few errors
                print(f"    Error: {e}")
    
    if not latencies:
        return {"error": "All requests failed"}
    
    latencies.sort()
    n = len(latencies)
    
    return {
        "target": name,
        "requests": n,
        "errors": errors,
        "mean_ms": statistics.mean(latencies),
        "median_ms": statistics.median(latencies),
        "p95_ms": latencies[int(n * 0.95)],
        "p99_ms": latencies[int(n * 0.99)],
        "min_ms": min(latencies),
        "max_ms": max(latencies),
        "std_dev_ms": statistics.stdev(latencies) if n > 1 else 0
    }


def benchmark_throughput(client: GatewayClient, name: str, 
                         concurrency: int, duration: int = 10) -> dict:
    """Benchmark throughput at a specific concurrency level."""
    print(f"  Measuring throughput for {name} @ {concurrency} concurrent...")
    
    messages = [
        {"role": "system", "content": "You are helpful."},
        {"role": "user", "content": "Say 'hello' briefly."}
    ]
    
    results = {"success": 0, "failed": 0, "latencies": []}
    stop_event = False
    
    def worker():
        while not stop_event:
            try:
                result = client.chat_completion(Config.MODEL, messages, max_tokens=50)
                results["success"] += 1
                results["latencies"].append(result["latency_ms"])
            except Exception as e:
                results["failed"] += 1
    
    import threading
    
    start_time = time.perf_counter()
    
    # Start workers
    threads = [threading.Thread(target=worker) for _ in range(concurrency)]
    for t in threads:
        t.daemon = True
        t.start()
    
    # Run for duration
    time.sleep(duration)
    stop_event = True
    
    # Wait for threads
    for t in threads:
        t.join(timeout=1)
    
    elapsed = time.perf_counter() - start_time
    
    return {
        "target": name,
        "concurrency": concurrency,
        "duration_sec": elapsed,
        "total_requests": results["success"] + results["failed"],
        "successful": results["success"],
        "failed": results["failed"],
        "requests_per_sec": results["success"] / elapsed if elapsed > 0 else 0,
        "mean_latency_ms": statistics.mean(results["latencies"]) if results["latencies"] else 0,
        "p95_latency_ms": sorted(results["latencies"])[int(len(results["latencies"]) * 0.95)] if results["latencies"] else 0
    }


def compare_features() -> list:
    """Generate feature comparison."""
    print("  Comparing features...")
    
    features = [
        ("Unified API", "✅", "✅", "Both provide unified API access"),
        ("Python SDK", "✅", "❌", "LiteLLM has native Python SDK"),
        ("Proxy Server", "✅", "✅", "Both offer OpenAI-compatible proxy"),
        ("Provider Count", "100+", "12+", "LiteLLM supports more providers"),
        ("Streaming", "✅", "✅", "Both support streaming"),
        ("Pattern Routing", "⚠️", "✅", "API Map has better pattern matching"),
        ("Load Balancing", "✅", "❌", "LiteLLM has built-in load balancing"),
        ("Fallback Logic", "✅", "⚠️", "LiteLLM has advanced routing"),
        ("Web GUI", "✅", "✅", "Both have web interfaces"),
        ("Cost Tracking", "✅", "❌", "LiteLLM tracks costs"),
        ("Caching", "✅", "❌", "LiteLLM supports Redis caching"),
        ("Guardrails", "✅", "❌", "LiteLLM has content moderation"),
        ("A2A Protocol", "✅", "❌", "LiteLLM supports Agent-to-Agent"),
        ("MCP Tools", "✅", "❌", "LiteLLM supports Model Context Protocol"),
        ("Protocol Bridging", "⚠️", "✅", "API Map converts between formats"),
        ("Configuration UI", "✅", "✅", "Both have visual configuration"),
    ]
    
    return features


# ============================================================================
# Results Handling
# ============================================================================

def save_results(results: dict):
    """Save benchmark results."""
    Config.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # JSON
    json_path = Config.OUTPUT_DIR / f"benchmark_{timestamp}.json"
    with open(json_path, 'w') as f:
        json.dump(results, f, indent=2)
    
    # Markdown
    md_path = Config.OUTPUT_DIR / f"benchmark_{timestamp}.md"
    with open(md_path, 'w') as f:
        f.write("# LiteLLM vs API Map - Benchmark Results\n\n")
        f.write(f"**Date:** {datetime.now().isoformat()}\n\n")
        
        # Latency
        if results.get('latency'):
            f.write("## Latency Benchmark\n\n")
            f.write("| Target | Mean (ms) | Median (ms) | P95 (ms) | P99 (ms) | Errors |\n")
            f.write("|--------|-----------|-------------|----------|----------|--------|\n")
            for r in results['latency']:
                if 'error' not in r:
                    f.write(f"| {r['target']} | {r['mean_ms']:.1f} | {r['median_ms']:.1f} | "
                           f"{r['p95_ms']:.1f} | {r['p99_ms']:.1f} | {r['errors']} |\n")
            f.write("\n")
        
        # Throughput
        if results.get('throughput'):
            f.write("## Throughput Benchmark\n\n")
            f.write("| Target | Concurrency | Req/sec | Mean Latency (ms) | Success |\n")
            f.write("|--------|-------------|---------|-------------------|----------|\n")
            for r in results['throughput']:
                f.write(f"| {r['target']} | {r['concurrency']} | {r['requests_per_sec']:.1f} | "
                       f"{r['mean_latency_ms']:.1f} | {r['successful']} |\n")
            f.write("\n")
        
        # Features
        if results.get('features'):
            f.write("## Feature Comparison\n\n")
            f.write("| Feature | LiteLLM | API Map | Notes |\n")
            f.write("|---------|---------|---------|-------|\n")
            for feat in results['features']:
                f.write(f"| {feat[0]} | {feat[1]} | {feat[2]} | {feat[3]} |\n")
            f.write("\n")
    
    print(f"\n📄 Results saved to:")
    print(f"   JSON: {json_path}")
    print(f"   Markdown: {md_path}")


# ============================================================================
# Mock Server Management
# ============================================================================

mock_server_process = None

def start_mock_server():
    """Start the mock LLM server."""
    global mock_server_process
    
    print("Starting mock LLM server...")
    
    server_script = Path(__file__).parent / "servers" / "mock_llm_server.py"
    
    mock_server_process = subprocess.Popen(
        [sys.executable, str(server_script), "--port", "9999"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    
    # Wait for server to be ready
    time.sleep(2)
    
    # Verify it's running
    try:
        response = requests.get("http://localhost:9999/health", timeout=5)
        if response.status_code == 200:
            print("  ✅ Mock server is running")
            return True
    except:
        pass
    
    print("  ❌ Failed to start mock server")
    return False


def stop_mock_server():
    """Stop the mock LLM server."""
    global mock_server_process
    
    if mock_server_process:
        print("Stopping mock server...")
        mock_server_process.terminate()
        mock_server_process.wait()
        mock_server_process = None


# ============================================================================
# Main
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Benchmark LiteLLM vs API Map"
    )
    parser.add_argument("--mock-server", action="store_true",
                       help="Start and use mock LLM server")
    parser.add_argument("--litellm-url", default=Config.LITELLM_URL,
                       help="LiteLLM URL")
    parser.add_argument("--apimap-url", default=Config.APIMAP_URL,
                       help="API Map URL")
    parser.add_argument("--quick", action="store_true",
                       help="Quick test (fewer requests)")
    parser.add_argument("--latency-only", action="store_true",
                       help="Run only latency benchmark")
    parser.add_argument("--throughput-only", action="store_true",
                       help="Run only throughput benchmark")
    parser.add_argument("--features-only", action="store_true",
                       help="Run only feature comparison")
    
    args = parser.parse_args()
    
    # Adjust settings for quick test
    if args.quick:
        Config.BENCHMARK_REQUESTS = 10
        Config.CONCURRENCY_LEVELS = [1, 5]
    
    # Start mock server if requested
    if args.mock_server:
        if not start_mock_server():
            print("Failed to start mock server. Exiting.")
            sys.exit(1)
    
    try:
        print("\n" + "="*60)
        print("LiteLLM vs API Map - Benchmark")
        print("="*60 + "\n")
        
        results = {"timestamp": datetime.now().isoformat()}
        
        # Determine which tests to run
        run_latency = not args.throughput_only and not args.features_only
        run_throughput = not args.latency_only and not args.features_only
        run_features = not args.latency_only and not args.throughput_only
        
        # Check gateways
        print("Checking gateways...")
        litellm_client = GatewayClient(args.litellm_url, api_key="sk-test-key")
        apimap_client = GatewayClient(args.apimap_url, api_key="test-key")
        
        litellm_ok = litellm_client.health_check()
        apimap_ok = apimap_client.health_check()
        
        print(f"  LiteLLM ({args.litellm_url}): {'✅' if litellm_ok else '❌'}")
        print(f"  API Map ({args.apimap_url}): {'✅' if apimap_ok else '❌'}")
        
        if not litellm_ok and not apimap_ok:
            print("\n❌ No gateways available for testing!")
            print("\nMake sure the gateways are running:")
            print("  LiteLLM: litellm --config configs/litellm_config.yaml")
            print("  API Map:  cd ../apimap && bun run src/server.ts --config ../apibench/configs/apimap_config.yaml")
            sys.exit(1)
        
        # Latency benchmark
        if run_latency:
            print("\n--- Latency Benchmark ---")
            latency_results = []
            
            if litellm_ok:
                latency_results.append(benchmark_latency(
                    litellm_client, "LiteLLM", Config.BENCHMARK_REQUESTS
                ))
            
            if apimap_ok:
                latency_results.append(benchmark_latency(
                    apimap_client, "API Map", Config.BENCHMARK_REQUESTS
                ))
            
            results["latency"] = latency_results
            
            # Print results
            print("\n  Results:")
            for r in latency_results:
                if 'error' not in r:
                    print(f"    {r['target']}: Mean={r['mean_ms']:.1f}ms, "
                          f"P95={r['p95_ms']:.1f}ms, P99={r['p99_ms']:.1f}ms")
        
        # Throughput benchmark
        if run_throughput:
            print("\n--- Throughput Benchmark ---")
            throughput_results = []
            
            for concurrency in Config.CONCURRENCY_LEVELS:
                if litellm_ok:
                    throughput_results.append(benchmark_throughput(
                        litellm_client, "LiteLLM", concurrency, duration=5 if args.quick else 10
                    ))
                
                if apimap_ok:
                    throughput_results.append(benchmark_throughput(
                        apimap_client, "API Map", concurrency, duration=5 if args.quick else 10
                    ))
            
            results["throughput"] = throughput_results
            
            # Print results
            print("\n  Results:")
            for r in throughput_results:
                print(f"    {r['target']} @ {r['concurrency']}: "
                      f"{r['requests_per_sec']:.1f} req/sec")
        
        # Feature comparison
        if run_features:
            print("\n--- Feature Comparison ---")
            feature_results = compare_features()
            results["features"] = feature_results
            
            # Print summary
            litellm_score = sum(1 for f in feature_results if "✅" in f[1])
            apimap_score = sum(1 for f in feature_results if "✅" in f[2])
            print(f"\n  Feature Score: LiteLLM {litellm_score} - API Map {apimap_score}")
        
        # Save results
        save_results(results)
        
        print("\n" + "="*60)
        print("Benchmark Complete!")
        print("="*60)
    
    finally:
        # Clean up mock server
        if args.mock_server:
            stop_mock_server()


if __name__ == "__main__":
    main()
