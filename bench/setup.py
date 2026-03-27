#!/usr/bin/env python3
"""
Setup script for the LiteLLM vs API Map benchmark suite.

This script:
1. Checks Python version
2. Installs dependencies
3. Verifies the installation
4. Creates necessary directories
"""

import subprocess
import sys
from pathlib import Path


def print_step(msg):
    """Print a setup step."""
    print(f"\n{'='*60}")
    print(f"  {msg}")
    print(f"{'='*60}")


def check_python():
    """Check Python version."""
    print_step("Checking Python Version")
    
    version = sys.version_info
    print(f"Python {version.major}.{version.minor}.{version.micro}")
    
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Python 3.8 or higher is required")
        return False
    
    print("✅ Python version OK")
    return True


def install_dependencies():
    """Install required packages."""
    print_step("Installing Dependencies")
    
    req_file = Path(__file__).parent / "requirements.txt"
    
    if not req_file.exists():
        print("❌ requirements.txt not found")
        return False
    
    print("Installing packages from requirements.txt...")
    
    try:
        subprocess.check_call([
            sys.executable, "-m", "pip", "install", "-r", str(req_file)
        ])
        print("✅ Dependencies installed")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install dependencies: {e}")
        return False


def create_directories():
    """Create necessary directories."""
    print_step("Creating Directories")
    
    base = Path(__file__).parent
    dirs = ["results", "logs"]
    
    for d in dirs:
        path = base / d
        path.mkdir(exist_ok=True)
        print(f"  ✅ {d}/")
    
    return True


def verify_installation():
    """Verify the installation works."""
    print_step("Verifying Installation")
    
    # Try importing key modules
    modules = [
        "aiohttp",
        "requests",
        "fastapi",
        "uvicorn",
    ]
    
    all_ok = True
    for module in modules:
        try:
            __import__(module)
            print(f"  ✅ {module}")
        except ImportError:
            print(f"  ❌ {module}")
            all_ok = False
    
    # Check files exist
    print("\nChecking files:")
    base = Path(__file__).parent
    files = [
        "benchmark.py",
        "benchmarks/runner.py",
        "servers/mock_llm_server.py",
    ]
    
    for file in files:
        path = base / file
        if path.exists():
            print(f"  ✅ {file}")
        else:
            print(f"  ❌ {file}")
            all_ok = False
    
    return all_ok


def print_next_steps():
    """Print next steps for the user."""
    print_step("Next Steps")
    
    print("""
Your benchmark environment is ready! Here's how to get started:

1. QUICK TEST (with mock server):
   
   python benchmark.py --mock-server --quick

2. FULL BENCHMARK (with mock server):
   
   python benchmark.py --mock-server

3. VERIFY SETUP:
   
   python tests/test_setup.py

4. CUSTOM CONFIGURATION:
   
   Edit configs/litellm_config.yaml and configs/apimap_config.yaml
   to use real API keys instead of the mock server.

5. RUN AGAINST REAL GATEWAYS:
   
   # Terminal 1: Start LiteLLM
   litellm --config configs/litellm_config.yaml
   
   # Terminal 2: Start API Map
   cd ../apimap && bun run src/server.ts --config ../apibench/configs/apimap_config.yaml
   
   # Terminal 3: Run benchmark
   python benchmark.py

6. VISUALIZE RESULTS:
   
   python visualize.py results/

For more information, see README.md
""")


def main():
    """Run setup."""
    print("""
╔══════════════════════════════════════════════════════════════╗
║     LiteLLM vs API Map - Benchmark Setup                     ║
║                                                              ║
║  This will set up the benchmark environment.                 ║
╚══════════════════════════════════════════════════════════════╝
""")
    
    # Run checks
    checks = [
        ("Python Version", check_python),
        ("Install Dependencies", install_dependencies),
        ("Create Directories", create_directories),
        ("Verify Installation", verify_installation),
    ]
    
    results = []
    for name, check_fn in checks:
        try:
            results.append((name, check_fn()))
        except Exception as e:
            print(f"\n❌ Error in {name}: {e}")
            results.append((name, False))
    
    # Summary
    print_step("Setup Summary")
    
    for name, passed in results:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {name}: {status}")
    
    if all(r[1] for r in results):
        print_next_steps()
    else:
        print("\n⚠️  Setup completed with errors.")
        print("Please fix the issues above and run setup again.")
        sys.exit(1)


if __name__ == "__main__":
    main()
