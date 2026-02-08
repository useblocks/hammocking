.PHONY: help install clean build test lint docs run all

# Detect OS
UNAME_S := $(shell uname -s)

# Python executable
PYTHON := python3
POETRY := poetry

# Directories
VENV_DIR := .venv
BUILD_DIR := build
DOCS_DIR := docs
DOCS_OUT := out/docs/html
SRC_DIR := src
TESTS_DIR := tests

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Hammocking - Build System$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

install: ## Install dependencies using poetry
	@echo "$(BLUE)Installing dependencies...$(NC)"
	@if ! command -v $(POETRY) >/dev/null 2>&1; then \
		echo "$(RED)Poetry not found. Installing poetry...$(NC)"; \
		curl -sSL https://install.python-poetry.org | $(PYTHON) -; \
	fi
	$(POETRY) install
	@echo "$(GREEN)Dependencies installed successfully$(NC)"

install-dev: install ## Install development dependencies
	@echo "$(BLUE)Installing development dependencies...$(NC)"
	$(POETRY) install --with dev
	@echo "$(GREEN)Development dependencies installed successfully$(NC)"

clean: ## Clean build artifacts and cache files
	@echo "$(BLUE)Cleaning build artifacts...$(NC)"
	rm -rf $(BUILD_DIR)
	rm -rf $(DOCS_OUT)
	rm -rf out
	rm -rf .pytest_cache
	rm -rf .ruff_cache
	rm -rf htmlcov
	rm -rf .coverage
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Cleaned successfully$(NC)"

clean-all: clean ## Clean everything including virtual environment
	@echo "$(BLUE)Removing virtual environment...$(NC)"
	rm -rf $(VENV_DIR)
	rm -rf .bootstrap
	$(POETRY) env remove --all 2>/dev/null || true
	@echo "$(GREEN)Complete cleanup done$(NC)"

test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	$(POETRY) run pytest --verbose --capture=tee-sys
	@echo "$(GREEN)Tests completed$(NC)"

test-coverage: ## Run tests with coverage
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	$(POETRY) run pytest --verbose --capture=tee-sys --cov=hammocking --cov-report=html --cov-report=term
	@echo "$(GREEN)Tests with coverage completed$(NC)"
	@echo "$(YELLOW)Coverage report: htmlcov/index.html$(NC)"

lint: ## Run linting and format checks
	@echo "$(BLUE)Running pre-commit checks...$(NC)"
	$(POETRY) run pre-commit run --all-files
	@echo "$(GREEN)Linting completed$(NC)"

format: ## Format code with black and ruff
	@echo "$(BLUE)Formatting code...$(NC)"
	$(POETRY) run black $(SRC_DIR) $(TESTS_DIR)
	$(POETRY) run ruff check --fix $(SRC_DIR) $(TESTS_DIR)
	@echo "$(GREEN)Formatting completed$(NC)"

docs: ## Build documentation
	@echo "$(BLUE)Building documentation...$(NC)"
	mkdir -p $(DOCS_OUT)
	$(POETRY) run sphinx-build -b html $(DOCS_DIR) $(DOCS_OUT)
	@echo "$(GREEN)Documentation built successfully$(NC)"
	@echo "$(YELLOW)Documentation: $(DOCS_OUT)/index.html$(NC)"

docs-clean: ## Build documentation (clean build)
	@echo "$(BLUE)Building documentation (clean)...$(NC)"
	mkdir -p $(DOCS_OUT)
	$(POETRY) run sphinx-build -a -E -b html $(DOCS_DIR) $(DOCS_OUT)
	@echo "$(GREEN)Documentation built successfully$(NC)"
	@echo "$(YELLOW)Documentation: $(DOCS_OUT)/index.html$(NC)"

docs-serve: docs ## Build and serve documentation locally
	@echo "$(BLUE)Serving documentation at http://localhost:8000$(NC)"
	@cd $(DOCS_OUT) && $(PYTHON) -m http.server 8000

run: ## Run hammocking (use ARGS for arguments)
	@echo "$(BLUE)Running hammocking...$(NC)"
	$(POETRY) run python -m hammocking $(ARGS)

build: lint test docs ## Run full build pipeline (lint, test, docs)
	@echo "$(GREEN)Build completed successfully$(NC)"

check: ## Run all checks without building docs
	@echo "$(BLUE)Running all checks...$(NC)"
	@$(MAKE) lint
	@$(MAKE) test
	@echo "$(GREEN)All checks passed$(NC)"

pre-commit-install: ## Install pre-commit hooks
	@echo "$(BLUE)Installing pre-commit hooks...$(NC)"
	$(POETRY) run pre-commit install
	$(POETRY) run pre-commit install --hook-type commit-msg
	@echo "$(GREEN)Pre-commit hooks installed$(NC)"

setup: install pre-commit-install ## Complete project setup (install + hooks)
	@echo "$(GREEN)Project setup completed$(NC)"
	@echo "$(YELLOW)You can now run 'make build' to build the project$(NC)"

all: clean-all setup build ## Complete rebuild from scratch
	@echo "$(GREEN)Complete rebuild finished$(NC)"

# Development helpers
watch-test: ## Watch for changes and run tests
	@echo "$(BLUE)Watching for changes...$(NC)"
	$(POETRY) run pytest-watch

shell: ## Start poetry shell
	$(POETRY) shell

info: ## Show project information
	@echo "$(BLUE)Project Information:$(NC)"
	@echo "  Python:  $$($(PYTHON) --version)"
	@echo "  Poetry:  $$($(POETRY) --version 2>/dev/null || echo 'Not installed')"
	@echo "  OS:      $(UNAME_S)"
	@echo "  Venv:    $$($(POETRY) env info --path 2>/dev/null || echo 'Not created')"
	@echo ""
	@echo "$(BLUE)Dependencies:$(NC)"
	@$(POETRY) show --tree 2>/dev/null || echo "  Run 'make install' first"

# Example usage
example-simple: ## Run simple example (one compile unit)
	@echo "$(BLUE)Running simple example...$(NC)"
	@cd docs/usage/examples/one_compile_unit && make clean && make

example-complex: ## Run complex example (multiple compile units)
	@echo "$(BLUE)Running complex example...$(NC)"
	@cd docs/usage/examples/one_or_more_compile_units && make clean && make

.DEFAULT_GOAL := help
