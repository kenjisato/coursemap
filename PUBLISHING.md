# Publishing Guide for Course Map

This document outlines the process for publishing the course-map packages to their respective repositories.

## Project Structure

```
coursemap/
├── coursemap-rs/       # Rust library + CLI for crates.io
├── coursemap-py/       # Python package for PyPI
├── coursemap-r/        # R package for CRAN (RStudio project)
├── test_docs/          # Test data
├── .bumpversion.toml   # Version management
└── README.md           # Main documentation
```

## 1. Rust Library (crates.io)

### Location
`coursemap-rs/`

### Publishing Steps
```bash
cd coursemap-rs

# Check the package
cargo check
cargo test

# Build documentation
cargo doc --no-deps

# Publish to crates.io
cargo publish
```

### Package Details
- **Name**: `coursemap`
- **Description**: A tool to visualize course dependencies from Quarto/Markdown documents
- **Keywords**: quarto, markdown, course, dependency, visualization
- **Categories**: command-line-utilities, visualization, education

## 2. Python Package (PyPI)

### Location
`coursemap-py/`

### Publishing Steps
```bash
cd coursemap-py

# Install maturin if not already installed
pip install maturin

# Build the package
maturin build --release

# Upload to PyPI
maturin publish
```

### Package Details
- **Name**: `coursemap`
- **Description**: A tool to visualize course dependencies from Quarto/Markdown documents
- **Python Support**: 3.8+
- **Keywords**: quarto, markdown, course, dependency, visualization

### Usage Example
```python
import coursemap

# Generate course map
coursemap.generate_course_map("./courses", "course_map.svg")

# For Quarto documents
svg_content = coursemap.create_quarto_filter("../courses")
print(svg_content)
```

## 3. R Package (CRAN)

### Location
`coursemap-r/`

### Publishing Steps (Following Hadley-Bryan Protocol)

#### Pre-release Checklist
```r
# Install required packages
install.packages(c("devtools", "usethis", "roxygen2", "testthat", "covr"))

# Load devtools
library(devtools)

# 1. Update documentation
document()

# 2. Run tests
test()

# 3. Check test coverage
covr::package_coverage()

# 4. Check package
check()

# 5. Check on different platforms
check_win_devel()  # Windows
check_mac_release()  # macOS (if available)

# 6. Check reverse dependencies (if any)
revdep_check()

# 7. Update NEWS.md
usethis::use_news_md()

# 8. Update cran-comments.md
usethis::use_cran_comments()
```

#### Release Process
```r
# 1. Final check before release
check()

# 2. Submit to CRAN
devtools::release()

# 3. After CRAN acceptance, tag the release
usethis::use_github_release()
```

#### Post-release
```r
# 1. Increment version for development
usethis::use_version("dev")

# 2. Update NEWS.md for next version
# Add "# coursemap (development version)" section
```

### Package Details
- **Name**: `coursemap`
- **Description**: Course Dependency Map Visualization
- **SystemRequirements**: Rust (>= 1.70), Graphviz (optional)

### Usage Example
```r
library(coursemap)

# Generate course map
generate_course_map("./courses", "course_map.svg")

# For Quarto documents
svg_content <- create_quarto_filter("../courses")
cat(svg_content)
```

## Version Management

This project uses **independent versioning** for each package, allowing them to evolve at their own pace.

### Setup
```bash
pip install bump-my-version
```

### Independent Package Versioning

Each package maintains its own version and changelog:

#### Rust Package
```bash
cd coursemap-rs
bump-my-version bump patch  # 0.1.0 → 0.1.1
```
- Updates: `Cargo.toml`, `CHANGELOG.md`
- Git tag: `rs-v0.1.1`

#### Python Package
```bash
cd coursemap-py
bump-my-version bump minor  # 0.1.0 → 0.2.0
```
- Updates: `pyproject.toml`, `python/coursemap/__init__.py`, `CHANGELOG.md`
- Git tag: `py-v0.2.0`

#### R Package
```bash
cd coursemap-r
bump-my-version bump patch  # 0.1.0 → 0.1.1
```
- Updates: `DESCRIPTION`, `CHANGELOG.md`
- Git tag: `r-v0.1.1`

### Version Strategy Benefits

1. **Accurate Change Tracking**: Only packages with actual changes get version bumps
2. **Efficient Development**: No unnecessary releases for unchanged packages
3. **Clear Dependencies**: Package managers see real version changes
4. **Language Conventions**: Each package follows its ecosystem's practices

### Coordinated Major Releases

For major API changes affecting all packages:

```bash
# Coordinate v1.0.0 release
cd coursemap-rs && bump-my-version bump major  # → 1.0.0
cd ../coursemap-py && bump-my-version bump major  # → 1.0.0
cd ../coursemap-r && bump-my-version bump major   # → 1.0.0
```

### Package-Specific Changelogs

Each package maintains its own changelog:
- `coursemap-rs/CHANGELOG.md`
- `coursemap-py/CHANGELOG.md`
- `coursemap-r/CHANGELOG.md`

## Pre-Publishing Checklist

### For All Packages
- [ ] Update version numbers
- [ ] Update CHANGELOG.md
- [ ] Update README.md
- [ ] Run tests
- [ ] Update documentation

### Rust Specific
- [ ] `cargo check` passes
- [ ] `cargo test` passes
- [ ] `cargo clippy` has no warnings
- [ ] Documentation builds correctly

### Python Specific
- [ ] `maturin build` succeeds
- [ ] Package installs correctly
- [ ] Python tests pass
- [ ] Type hints are correct

### R Specific
- [ ] `R CMD check` passes with no errors
- [ ] Documentation is complete
- [ ] Examples run correctly
- [ ] CRAN policy compliance

## Continuous Integration

Consider setting up GitHub Actions for:

1. **Rust**: Test on multiple platforms, check formatting, run clippy
2. **Python**: Test on multiple Python versions and platforms
3. **R**: Test on multiple R versions and platforms

## Release Process

1. Create a new branch for the release
2. Update all version numbers
3. Update documentation
4. Run all tests
5. Create a pull request
6. After merge, create a git tag
7. Publish packages in order: Rust → Python → R

## Support and Maintenance

- Monitor issues on GitHub
- Respond to user questions
- Keep dependencies updated
- Address security vulnerabilities promptly

## Documentation

Each package should have:
- Clear installation instructions
- Usage examples
- API documentation
- Troubleshooting guide
- Contributing guidelines

## License

All packages use the MIT license for consistency and broad compatibility.
