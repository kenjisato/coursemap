# Changelog - R Package

All notable changes to the R package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.5] - 2025-08-11

### Added
- R CMD check integration with `make check-r` target
- Comprehensive development workflow with Makefile targets
- Complete Roxygen2 documentation for all functions
- Vendor directory system for self-contained distribution
- CRAN-compliant package structure and validation
- Automated source code synchronization via configure scripts

### Changed
- Improved package documentation with proper argument descriptions
- Updated license format for CRAN compliance
- Enhanced .Rbuildignore for cleaner package builds
- Migrated from `@docType "package"` to `"_PACKAGE"` format

### Fixed
- Resolved duplicate Rd aliases issue
- Fixed undocumented function arguments warnings
- Eliminated all R CMD check notes
- Corrected non-standard file warnings

### Development
- Established comprehensive test suite (Rust: 24 tests, Python: 12 tests, R: 21 tests)
- Implemented vendor-based build system for offline compilation
- Added quality assurance workflow with R CMD check validation
- Achieved CRAN submission readiness (0 errors, 0 notes, 3 minor warnings)

## [0.1.2] - 2025-08-08

### Added
- Initial R package implementation using extendr
- R bindings for Rust core functionality
- Quarto integration support
- Package name unified to `coursemap`
- Independent versioning system
- Wickham-Bryan release protocol compliance

### Changed
- Migrated to independent versioning strategy
- RStudio project structure for better development experience

## [0.1.0] - 2025-01-08

### Added
- Initial release of the R package
- R bindings for course map generation
- Integration with Quarto documents
- Support for R data structures and workflows
