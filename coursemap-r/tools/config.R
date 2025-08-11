# Note: Any variables prefixed with `.` are used for text
# replacement in the Makevars.in and Makevars.win.in

# check the packages MSRV first
source("tools/msrv.R")

# Vendor coursemap-rs source code for self-contained builds
vendor_dir <- "src/rust/vendor/coursemap"
coursemap_rs_src <- "../coursemap-rs/src"
coursemap_rs_cargo <- "../coursemap-rs/Cargo.toml"

# Create vendor directory if it doesn't exist
if (!dir.exists(vendor_dir)) {
  dir.create(vendor_dir, recursive = TRUE)
  message("Created vendor directory: ", vendor_dir)
}

# Copy source files from coursemap-rs if available
if (dir.exists(coursemap_rs_src) && file.exists(coursemap_rs_cargo)) {
  # Create src directory in vendor
  vendor_src_dir <- file.path(vendor_dir, "src")
  if (!dir.exists(vendor_src_dir)) {
    dir.create(vendor_src_dir, recursive = TRUE)
  }
  
  # Copy all .rs files
  rs_files <- list.files(coursemap_rs_src, pattern = "\\.rs$", full.names = TRUE)
  for (file in rs_files) {
    file.copy(file, vendor_src_dir, overwrite = TRUE)
  }
  
  # Copy default-coursemap.yml if it exists
  default_config <- file.path(coursemap_rs_src, "default-coursemap.yml")
  if (file.exists(default_config)) {
    file.copy(default_config, vendor_src_dir, overwrite = TRUE)
  }
  
  # Create Cargo.toml for the vendored library
  vendor_cargo_toml <- file.path(vendor_dir, "Cargo.toml")
  
  # Read the original Cargo.toml to extract dependencies
  original_lines <- readLines(coursemap_rs_cargo)
  
  # Find [dependencies] section
  deps_start <- which(grepl("^\\[dependencies\\]", original_lines))
  
  if (length(deps_start) > 0) {
    # Find the end of dependencies section
    deps_end <- length(original_lines)
    next_sections <- which(grepl("^\\[", original_lines[(deps_start + 1):length(original_lines)]))
    if (length(next_sections) > 0) {
      deps_end <- deps_start + next_sections[1] - 1
    }
    
    # Extract dependencies (excluding CLI-only ones)
    deps_lines <- original_lines[(deps_start + 1):deps_end]
    # Filter out CLI dependencies and empty lines
    deps_lines <- deps_lines[!grepl("^\\s*$", deps_lines)]
    deps_lines <- deps_lines[!grepl("^\\s*#", deps_lines)]
    deps_lines <- deps_lines[!grepl("clap|env_logger", deps_lines)]
    
    # Skip creating vendor Cargo.toml - it's handled by configure script
    message("Vendor Cargo.toml handled by configure script")
  }
  
  message("Vendored coursemap-rs source code to ", vendor_dir)
} else {
  message("Warning: coursemap-rs source directory not found at ", coursemap_rs_src)
  message("This is expected when building from a distributed package.")
}

# check DEBUG and NOT_CRAN environment variables
env_debug <- Sys.getenv("DEBUG")
env_not_cran <- Sys.getenv("NOT_CRAN")

# check if the vendored source exists (either from above or pre-packaged)
vendor_exists <- dir.exists(vendor_dir) && file.exists(file.path(vendor_dir, "Cargo.toml"))

is_not_cran <- env_not_cran != ""
is_debug <- env_debug != ""

if (is_debug) {
  # if we have DEBUG then we set not cran to true
  # CRAN is always release build
  is_not_cran <- TRUE
  message("Creating DEBUG build.")
}

if (!is_not_cran) {
  message("Building for CRAN.")
}

# we set cran flags only if NOT_CRAN is empty
# Note: Using hybrid approach - coursemap code is vendored, dependencies from crates.io
.cran_flags <- ifelse(
  !is_not_cran,
  "-j 2",
  ""
)

# when DEBUG env var is present we use `--debug` build
.profile <- ifelse(is_debug, "", "--release")
.clean_targets <- ifelse(is_debug, "", "$(TARGET_DIR)")

# We specify this target when building for webR
webr_target <- "wasm32-unknown-emscripten"

# here we check if the platform we are building for is webr
is_wasm <- identical(R.version$platform, webr_target)

# print to terminal to inform we are building for webr
if (is_wasm) {
  message("Building for WebR")
}

# we check if we are making a debug build or not
# if so, the LIBDIR environment variable becomes:
# LIBDIR = $(TARGET_DIR)/{wasm32-unknown-emscripten}/debug
# this will be used to fill out the LIBDIR env var for Makevars.in
target_libpath <- if (is_wasm) "wasm32-unknown-emscripten" else NULL
cfg <- if (is_debug) "debug" else "release"

# used to replace @LIBDIR@
.libdir <- paste(c(target_libpath, cfg), collapse = "/")

# use this to replace @TARGET@
# we specify the target _only_ on webR
# there may be use cases later where this can be adapted or expanded
.target <- ifelse(is_wasm, paste0("--target=", webr_target), "")

# read in the Makevars.in file checking
is_windows <- .Platform[["OS.type"]] == "windows"

# if windows we replace in the Makevars.win.in
mv_fp <- ifelse(
  is_windows,
  "src/Makevars.win.in",
  "src/Makevars.in"
)

# set the output file
mv_ofp <- ifelse(
  is_windows,
  "src/Makevars.win",
  "src/Makevars"
)

# delete the existing Makevars{.win}
if (file.exists(mv_ofp)) {
  message("Cleaning previous `", mv_ofp, "`.")
  invisible(file.remove(mv_ofp))
}

# read as a single string
mv_txt <- readLines(mv_fp)

# replace placeholder values
new_txt <- gsub("@CRAN_FLAGS@", .cran_flags, mv_txt) |>
  gsub("@PROFILE@", .profile, x = _) |>
  gsub("@CLEAN_TARGET@", .clean_targets, x = _) |>
  gsub("@LIBDIR@", .libdir, x = _) |>
  gsub("@TARGET@", .target, x = _)

message("Writing `", mv_ofp, "`.")
con <- file(mv_ofp, open = "wb")
writeLines(new_txt, con, sep = "\n")
close(con)

message("`tools/config.R` has finished.")
