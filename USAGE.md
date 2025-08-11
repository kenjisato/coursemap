# Course Map Usage Guide

This document provides examples of how to use the coursemap tool in different environments.

## Rust Binary

### Installation

```bash
# Install from crates.io
cargo install coursemap

# Or build from source (requires CLI feature)
cd coursemap-rs
cargo build --release --features cli
```

### Development Build

```bash
# Clone the repository
git clone https://github.com/kenjisato/coursemap.git
cd coursemap/coursemap-rs

# Build with CLI (default)
cargo build --features cli

# Build library only (for development/testing)
cargo build --no-default-features
```

### Basic Usage

```bash
# Generate SVG from current directory
coursemap test_docs -o course_map.svg

# Generate PNG format
coursemap test_docs -o course_map.png -f png

# Generate DOT format (no Graphviz required)
coursemap test_docs -o course_map.dot -f dot

# Use custom configuration
coursemap test_docs -o course_map.svg -c config.yml

# Verbose output
coursemap test_docs -o course_map.svg -v

# Show help
coursemap --help
```

## Python Package

### Installation

```bash
# Install from PyPI
pip install coursemap
```

### Usage in Python

```python
import coursemap

# Quick display (like matplotlib.pyplot.show())
coursemap.show("./courses")

# Object-oriented approach (recommended)
cm = coursemap.CourseMap("./courses")
cm.show()  # Display inline in Jupyter/Quarto
cm.save("course_map.svg")  # Save to file

# Check Graphviz availability
if coursemap.graphviz_available():
    print("Graphviz is available")
    print(coursemap.graphviz_info())
```

### Usage in Quarto Documents

```python
# In a .qmd file
```{python}
#| echo: false
import coursemap

# Simple one-liner for Quarto
coursemap.show("../courses")

# Or save and display
cm = coursemap.CourseMap("../courses")
cm.show()  # Displays inline in Quarto
```

## R Package

### Installation

```r
# Install from CRAN
install.packages("coursemap")

# Or install development version
# devtools::install_github("kenjisato/coursemap", subdir = "coursemap-r")
```

### Usage in R

```r
library(coursemap)

# Object-oriented approach (recommended)
cm <- coursemap("./courses")
plot(cm)  # Display in RStudio/knitr
write_map(cm, "course_map.svg")  # Save to file

# Check Graphviz availability
if (graphviz_available()) {
  cat("Graphviz is available\n")
  cat(graphviz_info(), "\n")
}
```

### Usage in Quarto Documents

```r
# In a .qmd file
```{r}
#| echo: false
library(coursemap)

# Simple display in Quarto
cm <- coursemap("../courses")
plot(cm)  # Automatically displays inline in Quarto
```

## Document Format

Course documents should include frontmatter with course metadata:

```yaml
---
title: "Introduction to Economics"
course-map:
  id: intro
  phase: Pre
  prerequisites: []
---

# Course Content

Your course content here...
```

### Metadata Fields

- `id`: Unique identifier for the course
- `phase`: Course phase (Pre, InClass, Post, etc.)
- `prerequisites`: List of prerequisite course IDs

## Configuration

Create a `config.yml` file to customize phases and colors:

```yaml
root-key: course-map

phase:
  Pre: 
    face: lightblue
  InClass:
    face: lightgreen
  Post:
    face: orange
  Unknown:
    face: lightgray    

ignore:
  - /index.qmd
  - /README.md
```

## Examples

### Simple Course Structure

```
courses/
├── intro.qmd          # Prerequisites: none
├── microeconomics.qmd # Prerequisites: [intro]
└── advanced.qmd       # Prerequisites: [microeconomics]
```

### Complex Dependencies

```
courses/
├── intro.qmd          # Prerequisites: none
├── micro.qmd          # Prerequisites: [intro]
├── macro.qmd          # Prerequisites: [intro]
└── advanced.qmd       # Prerequisites: [micro, macro]
```

## Troubleshooting

### "Graphviz not found" Error

Install Graphviz or use DOT format:
```bash
# macOS
brew install graphviz

# Ubuntu/Debian
sudo apt-get install graphviz

# Or use DOT format (no Graphviz required)
course-map -f dot -o output.dot
```

### Python Import Error

Make sure the package is properly installed:
```bash
maturin develop --features python
```

### Python Development Build Error

For development builds from source:
```bash
# Clone the repository
git clone https://github.com/kenjisato/coursemap.git
cd coursemap/coursemap-py

# Build with maturin (requires coursemap-rs at ../coursemap-rs)
maturin develop
```

### R Package Build Error

Make sure rextendr is installed and Rust is available:
```r
install.packages("rextendr")
rextendr::document()
```

For development builds from source:
```bash
# Clone the repository
git clone https://github.com/kenjisato/coursemap.git
cd coursemap/coursemap-r

# Build R package (requires coursemap-rs at ../coursemap-rs)
R -e "rextendr::document()"
```

## Development Notes

### Monorepo Structure
This project uses a monorepo with path dependencies:

```
coursemap/
├── coursemap-rs/       # Core Rust library + CLI
├── coursemap-py/       # Python bindings (depends on ../coursemap-rs)
├── coursemap-r/        # R package (depends on ../coursemap-rs)
└── test_docs/          # Test data
```

### Feature Flags
The core Rust library uses feature flags:
- **Default**: `cli` feature enabled (includes clap, env_logger)
- **Library only**: `--no-default-features` (lightweight for bindings)

### Path Dependencies
- **Python**: `coursemap = { path = "../coursemap-rs", default-features = false }`
- **R**: `coursemap = { path = "../../../coursemap-rs", default-features = false }`

This ensures:
- ✅ No external crates.io dependency during development
- ✅ Lightweight builds (no CLI dependencies for bindings)
- ✅ CRAN-compatible offline builds
