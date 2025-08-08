# Course Map

A tool to visualize course dependencies from Quarto/Markdown documents, available in multiple programming languages.

## Overview

Course Map analyzes Quarto/Markdown documents with course metadata and generates visual dependency graphs showing the relationships between courses. It's designed to help educators and course designers understand and visualize curriculum structures.

## Multi-Language Support

This project provides the same functionality across three programming languages:

- 🦀 **Rust** (crates.io): Core library and command-line tool
- 🐍 **Python** (PyPI): Python bindings with Quarto integration
- 📊 **R** (CRAN): R package with Quarto integration

## Quick Start

### Rust
```bash
cargo install coursemap
coursemap -i ./courses -o course_map.svg
```

### Python
```bash
pip install coursemap
```
```python
import coursemap
coursemap.generate_course_map("./courses", "course_map.svg")
```

### R
```r
install.packages("coursemap")
library(coursemap)
generate_course_map("./courses", "course_map.svg")
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

## Quarto Integration

### Python
```python
# In a .qmd file
```{python}
#| echo: false
import coursemap

svg_content = coursemap.create_quarto_filter("../courses")
print(svg_content)
```

### R
```r
# In a .qmd file
```{r}
#| echo: false
library(coursemap)

svg_content <- create_quarto_filter("../courses")
cat(svg_content)
```

## Output Formats

- **SVG**: Vector graphics (requires Graphviz)
- **PNG**: Raster graphics (requires Graphviz)
- **DOT**: Graphviz source format (no Graphviz required)

## Project Structure

```
coursemap/
├── core/               # 🔧 Shared core functionality
├── coursemap-rs/       # 🦀 Rust library for crates.io
├── coursemap-py/       # 🐍 Python package for PyPI
├── coursemap-r/        # 📊 R package for CRAN (RStudio project)
├── test_docs/          # 📝 Test data
├── config.yml          # ⚙️ Example configuration
├── .bumpversion.toml   # 🔄 Version management
├── CHANGELOG.md        # 📋 Change history
├── PUBLISHING.md       # 📖 Publishing guide
└── README.md           # 📄 This file
```

## Development

Each package can be developed independently with its own versioning:

### Rust
```bash
cd coursemap-rs
cargo build
cargo test
# Version management
bump-my-version bump patch  # Independent versioning
```

### Python
```bash
cd coursemap-py
maturin develop
# Version management
bump-my-version bump minor  # Independent versioning
```

### R (RStudio Project)
```bash
cd coursemap-r
R -e "rextendr::document()"
# Version management
bump-my-version bump patch  # Independent versioning
```

## Version Management Strategy

This project uses **independent versioning** for each package:

- 🦀 **Rust**: `rs-v0.1.0` → `rs-v0.1.1` (patch fixes)
- 🐍 **Python**: `py-v0.1.0` → `py-v0.2.0` (new features)
- 📊 **R**: `r-v0.1.0` → `r-v0.1.1` (bug fixes)

### Benefits
- ✅ Only changed packages get version bumps
- ✅ Clear change tracking per package
- ✅ Efficient development workflow
- ✅ Language-specific conventions

## Requirements

- **Rust**: 1.70+
- **Graphviz**: Optional, for SVG/PNG output
- **Python**: 3.8+ (for Python package)
- **R**: 4.0+ (for R package)

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## AI Acknowledgement

This project utilized generative AI tools, including Claude and ChatGPT, to assist in code generation, documentation, and testing. These tools were used to enhance productivity and facilitate the development process.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Links

- **Repository**: https://github.com/kenjisato/coursemap
- **Rust Package**: https://crates.io/crates/coursemap
- **Python Package**: https://pypi.org/project/coursemap/
- **R Package**: https://cran.r-project.org/package=coursemap
- **Documentation**: https://docs.rs/coursemap

## Support

- 📝 [Issues](https://github.com/kenjisato/coursemap/issues)
- 💬 [Discussions](https://github.com/kenjisato/coursemap/discussions)
- 📧 Email: mail@kenjisato.jp
