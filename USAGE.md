# Course Map Usage Guide

This document provides examples of how to use the course-map tool in different environments.

## Rust Binary

### Basic Usage

```bash
# Generate SVG from current directory
cargo run -- -i test_docs -o course_map.svg

# Generate PNG format
cargo run -- -i test_docs -o course_map.png -f png

# Generate DOT format (no Graphviz required)
cargo run -- -i test_docs -o course_map.dot -f dot

# Use custom configuration
cargo run -- -i test_docs -o course_map.svg -c config.yml

# Verbose output
cargo run -- -i test_docs -o course_map.svg -v
```

### Release Binary

```bash
# Build release version
cargo build --release

# Use release binary
./target/release/course-map -i test_docs -o course_map.svg
```

## Python Package (with maturin)

### Installation

```bash
# Install maturin
pip install maturin

# Build and install Python package
maturin develop --features python

# Or build wheel
maturin build --features python
pip install target/wheels/course_map-*.whl
```

### Usage in Python

```python
import course_map

# Basic usage
course_map.generate_course_map("./courses", "course_map.svg")

# Generate inline SVG for Quarto
svg_content = course_map.generate_inline_svg("./courses")
print(svg_content)

# Using the class interface
cm = course_map.CourseMap()
cm.generate_svg("./courses", "output.svg")

# Check Graphviz availability
if course_map.check_graphviz_available():
    print("Graphviz is available")
    print(course_map.get_graphviz_info())
```

### Usage in Quarto Documents

```python
# In a .qmd file
```{python}
#| echo: false
import course_map

# Generate and display course map
svg_content = course_map.create_quarto_filter("../courses")
print(svg_content)
```

## R Package (with extendr)

### Installation

```r
# Install required packages
install.packages(c("rextendr", "devtools"))

# Build and install R package
rextendr::document()
devtools::install()
```

### Usage in R

```r
library(coursemap)

# Basic usage
generate_course_map("./courses", "course_map.svg")

# Generate inline SVG for Quarto
svg_content <- generate_inline_svg("./courses")
cat(svg_content)

# Check Graphviz availability
if (check_graphviz_available()) {
  cat("Graphviz is available\n")
  cat(get_graphviz_info(), "\n")
}
```

### Usage in Quarto Documents

```r
# In a .qmd file
```{r}
#| echo: false
library(coursemap)

# Generate and display course map
svg_content <- create_quarto_filter("../courses")
cat(svg_content)
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

### R Package Build Error

Make sure rextendr is installed and Rust is available:
```r
install.packages("rextendr")
rextendr::document()
