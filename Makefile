# Course Map - Multi-language Test Runner
.PHONY: help test test-rust test-python test-r build clean install

# Default target
help:
	@echo "Course Map Test Runner"
	@echo ""
	@echo "Available targets:"
	@echo "  test        - Run all tests (Rust, Python, R)"
	@echo "  test-rust   - Run Rust tests only"
	@echo "  test-python - Run Python tests only"
	@echo "  test-r      - Run R tests only"
	@echo "  build       - Build all packages"
	@echo "  clean       - Clean build artifacts"
	@echo "  install     - Install all packages for development"
	@echo ""

# Run all tests
test: test-rust test-python test-r

# Rust tests
test-rust:
	@echo "🦀 Running Rust tests..."
	@cd coursemap-rs && cargo test
	@echo "✅ Rust tests completed"

# Python tests
test-python:
	@echo "🐍 Running Python tests..."
	@cd coursemap-py && uv run maturin develop
	@cd coursemap-py && uv run --with pytest pytest tests/ -v
	@echo "✅ Python tests completed"

# R tests (if R and testthat are available)
test-r:
	@echo "📊 Running R tests..."
	@if command -v Rscript >/dev/null 2>&1; then \
		cd coursemap-r && Rscript --vanilla -e "if (!require('devtools', quietly=TRUE)) install.packages('devtools', repos='https://cran.rstudio.com/'); if (!require('testthat', quietly=TRUE)) install.packages('testthat', repos='https://cran.rstudio.com/'); devtools::load_all(); testthat::test_dir('tests/testthat')"; \
	else \
		echo "⚠️  Rscript not found, skipping R tests"; \
	fi
	@echo "✅ R tests completed"

# Build all packages
build:
	@echo "🔨 Building all packages..."
	@cd coursemap-rs && cargo build
	@cd coursemap-py && uv run maturin build
	@echo "✅ Build completed"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@cd coursemap-rs && cargo clean
	@cd coursemap-py && cargo clean
	@rm -rf coursemap-py/target
	@rm -rf target
	@echo "✅ Clean completed"

# Install packages for development
install:
	@echo "📦 Installing packages for development..."
	@cd coursemap-py && uv run maturin develop
	@echo "✅ Installation completed"

# Quick test (without R, for CI/CD)
test-quick: test-rust test-python
	@echo "✅ Quick tests completed"

# Lint and format
lint:
	@echo "🔍 Running linters..."
	@cd coursemap-rs && cargo clippy -- -D warnings
	@cd coursemap-py && cargo clippy -- -D warnings
	@cd coursemap-py && uv run --with black black --check python/
	@cd coursemap-py && uv run --with isort isort --check-only python/
	@echo "✅ Linting completed"

# Format code
format:
	@echo "🎨 Formatting code..."
	@cd coursemap-rs && cargo fmt
	@cd coursemap-py && cargo fmt
	@cd coursemap-py && uv run --with black black python/
	@cd coursemap-py && uv run --with isort isort python/
	@echo "✅ Formatting completed"
