#!/usr/bin/env python3
"""
Test script to verify benchmark setup.

Usage:
    python tests/test_setup.py
"""

import sys
import subprocess
from pathlib import Path

def check_python_version():
    """Check Python version."""
    print("Checking Python version...")
    version = sys.version_info
    if version.major >= 3 and version.minor >= 8:
        print(f"  ✅ Python {version.major}.{version.minor}.{version.micro}")
        return True
    else:
        print(f"  ❌ Python {version.major}.{version.minor}.{version.micro} (need 3.8+)")
        return False


def check_dependencies():
    """Check required dependencies."""
    print("\nChecking dependencies...")
    
    required = [
        ("aiohttp", "aiohttp"),
        ("requests", "requests"),
        ("fastapi", "fastapi"),
        ("uvicorn", "uvicorn"),
    ]
    
    all_ok = True
    for module, package in required:
        try:
            __import__(module)
            print(f"  ✅ {package}")
        except ImportError:
            print(f"  ❌ {package} (install with: pip install {package})")
            all_ok = False
    
    optional = [
        ("matplotlib", "matplotlib"),
        ("numpy", "numpy"),
        ("websockets", "websockets"),
    ]
    
    print("\nOptional dependencies:")
    for module, package in optional:
        try:
            __import__(module)
            print(f"  ✅ {package}")
        except ImportError:
            print(f"  ⚠️  {package} (optional, install with: pip install {package})")
    
    return all_ok


def check_files():
    """Check required files exist."""
    print("\nChecking files...")
    
    base = Path(__file__).parent.parent
    
    required_files = [
        "benchmark.py",
        "benchmarks/runner.py",
        "servers/mock_llm_server.py",
        "configs/litellm_config.yaml",
        "configs/apimap_config.yaml",
        "requirements.txt",
    ]
    
    all_ok = True
    for file in required_files:
        path = base / file
        if path.exists():
            print(f"  ✅ {file}")
        else:
            print(f"  ❌ {file} (missing)")
            all_ok = False
    
    return all_ok


def test_mock_server():
    """Test mock server can start."""
    print("\nTesting mock server...")
    
    server_script = Path(__file__).parent.parent / "servers" / "mock_llm_server.py"
    
    try:
        # Try to import the module
        import importlib.util
        spec = importlib.util.spec_from_file_location("mock_server", server_script)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        print(f"  ✅ Mock server module loads successfully")
        return True
    except Exception as e:
        print(f"  ❌ Mock server error: {e}")
        return False


def main():
    """Run all checks."""
    print("="*60)
    print("Benchmark Setup Verification")
    print("="*60)
    
    checks = [
        ("Python Version", check_python_version),
        ("Dependencies", check_dependencies),
        ("Files", check_files),
        ("Mock Server", test_mock_server),
    ]
    
    results = []
    for name, check_fn in checks:
        results.append((name, check_fn()))
    
    print("\n" + "="*60)
    print("Summary")
    print("="*60)
    
    for name, passed in results:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {name}: {status}")
    
    all_passed = all(r[1] for r in results)
    
    if all_passed:
        print("\n🎉 All checks passed! You're ready to run benchmarks.")
        print("\nQuick start:")
        print("  python benchmark.py --mock-server --quick")
    else:
        print("\n⚠️  Some checks failed. Please fix the issues above.")
        sys.exit(1)


if __name__ == "__main__":
    main()
