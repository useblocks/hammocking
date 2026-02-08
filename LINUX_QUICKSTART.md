# Linux Quickstart Guide

This guide helps you get started with **hammocking** on Linux.

## Prerequisites

### Required
- Python 3.10 or higher (3.13 recommended)
- Git

### Optional (for integration tests)
- clang/llvm
- cmake
- ninja-build

### Installing Prerequisites on Ubuntu/Debian

```bash
# Install Python 3.13
sudo apt update
sudo apt install python3.13 python3.13-venv python3-pip

# Optional: Install build tools for integration tests
sudo apt install clang cmake ninja-build llvm
```

## Installation

### Option 1: Using the build script

```bash
# Clone the repository
git clone https://github.com/avengineers/hammocking
cd hammocking

# Make build script executable
chmod +x build.sh

# Install dependencies
./build.sh --install

# Run full build
./build.sh
```

### Option 2: Using Makefile

```bash
# Clone the repository
git clone https://github.com/avengineers/hammocking
cd hammocking

# Setup (installs poetry and dependencies, sets up pre-commit hooks)
make setup

# Run full build (lint, test, docs)
make build
```

## Common Tasks

### Testing
```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage
```

### Linting
```bash
# Run linting checks
make lint

# Auto-format code
make format
```

### Documentation
```bash
# Build documentation
make docs

# Build and serve docs locally (http://localhost:8000)
make docs-serve
```

### Running Hammocking
```bash
# Using make
make run ARGS="--help"

# Using poetry directly
poetry run python -m hammocking --help

# Example: Generate mocks
poetry run python -m hammocking \
    --sources my_source.c \
    --plink my_partial_link.o \
    --outdir ./mocks
```

## Development Workflow

### Setup Development Environment
```bash
# Complete setup with pre-commit hooks
make setup

# Or manually
poetry install
poetry run pre-commit install
```

### Running Tests During Development
```bash
# Run specific test file
poetry run pytest tests/test_hammocking.py -v

# Run specific test
poetry run pytest tests/test_hammocking.py::TestVariable::test_simple -v

# Run tests excluding integration tests (if clang not installed)
poetry run pytest -v -m "not integration"
```

### Code Quality
```bash
# Run all pre-commit checks
make lint

# Format code
make format

# Check what would be formatted (dry run)
poetry run black --check src tests
```

## Make Targets Reference

Run `make help` to see all available commands. Most useful:

| Command | Description |
|---------|-------------|
| `make setup` | Complete project setup (install + hooks) |
| `make build` | Full build pipeline (lint + test + docs) |
| `make test` | Run tests |
| `make test-coverage` | Run tests with coverage report |
| `make lint` | Run linting/formatting checks |
| `make format` | Auto-format code |
| `make docs` | Build documentation |
| `make docs-serve` | Build and serve docs locally |
| `make clean` | Clean build artifacts |
| `make clean-all` | Clean everything including venv |
| `make info` | Show project information |

## Examples

The repository includes working examples:

### Simple Example (One Compile Unit)
```bash
make example-simple
```

### Complex Example (Multiple Compile Units)
```bash
make example-complex
```

### Manual Example Run
```bash
cd docs/usage/examples/one_compile_unit
make clean
make
```

## Troubleshooting

### Poetry Not Found
If `poetry` command is not found after installation:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

Add this to your `~/.bashrc` or `~/.zshrc` to make it permanent.

### Python Version Issues
Check your Python version:
```bash
python3 --version
```

If you need to use a specific Python version with poetry:
```bash
poetry env use python3.13
```

### Integration Test Failures
If integration tests fail due to missing clang:
```bash
# Skip integration tests
poetry run pytest -v -m "not integration"

# Or install clang
sudo apt install clang cmake
```

### Lock File Issues
If you see "poetry.lock changed" errors:
```bash
poetry lock
poetry install
```

## Getting Help

- Documentation: Built docs at `out/docs/html/index.html` after running `make docs`
- Issues: https://github.com/avengineers/hammocking/issues
- Main command help: `poetry run python -m hammocking --help`

## Next Steps

1. Read the full documentation: `make docs && firefox out/docs/html/index.html`
2. Explore the examples in `docs/usage/examples/`
3. Check out the test files in `tests/` to see how to use the API
