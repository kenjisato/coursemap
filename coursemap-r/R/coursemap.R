#' Course Map - R Interface
#' 
#' R wrapper for the Rust-based course-map tool.
#' Provides intuitive API with seamless integration with knitr/Quarto.
#' 
#' @name coursemap-package
#' @aliases coursemap
#' @docType package
#' @title Course Dependency Map Visualization
#' @author Kenji Sato
#' @keywords package
NULL

#' Create a course map object
#' 
#' Creates a course map from documents in a directory. The resulting object
#' can be displayed using plot() or saved using write_map().
#' 
#' @param input_dir Directory containing course documents (default: ".")
#' @param config Path to configuration file (optional)
#' 
#' @return A coursemap object
#' 
#' @examples
#' \dontrun{
#' # Create course map
#' cm <- coursemap("./courses")
#' 
#' # Display in current device (knitr-friendly)
#' plot(cm)
#' 
#' # Save to file
#' write_map(cm, "course_map.png")
#' }
#' 
#' @export
coursemap <- function(input_dir = ".", config = NULL) {
  structure(
    list(
      input_dir = input_dir,
      config = config
    ),
    class = "coursemap"
  )
}

#' Plot method for coursemap objects
#' 
#' Displays the course map in the current graphics device.
#' This method provides knitr/Quarto integration and environment-aware display.
#' 
#' @param x A coursemap object
#' @param ... Additional arguments (ignored)
#' 
#' @examples
#' \dontrun{
#' cm <- coursemap("./courses")
#' plot(cm)  # Display in current environment
#' }
#' 
#' @export
plot.coursemap <- function(x, ...) {
  # Skip output during testing
  if (is_testing()) {
    return(invisible(x))
  }
  
  # Generate DOT content directly (memory-efficient)
  dot_string <- .Call("wrap__generate_dot_string", x$input_dir, x$config, PACKAGE = "coursemap")
  
  # Render using DiagrammeR and return the result
  result <- DiagrammeR::grViz(dot_string)
  print(result)
  
  invisible(x)
}

#' Print method for coursemap objects
#' 
#' Simple print method that shows object information and calls plot().
#' 
#' @param x A coursemap object
#' @param ... Additional arguments (ignored)
#' 
#' @export
print.coursemap <- function(x, ...) {
  cat("Course Map\n")
  cat("Input directory:", x$input_dir, "\n")
  if (!is.null(x$config)) {
    cat("Config file:", x$config, "\n")
  }
  cat("\nUse plot() to display or write_map() to save.\n")
  invisible(x)
}

#' Save a course map to file
#' 
#' Save a course map object to a file in various formats.
#' 
#' @param x Course map object to save
#' @param filename File name to create on disk
#' @param format Output format: "svg", "png", or "dot" (auto-detected from filename if NULL)
#' @param width Width in inches (for future use, currently ignored)
#' @param height Height in inches (for future use, currently ignored)
#' @param ... Additional arguments (ignored)
#' 
#' @return Path to the saved file (invisibly)
#' 
#' @examples
#' \dontrun{
#' cm <- coursemap("./courses")
#' 
#' # Save as PNG (format auto-detected)
#' write_map(cm, "course_map.png")
#' 
#' # Save as SVG with explicit format
#' write_map(cm, "course_map", format = "svg")
#' 
#' # Save as DOT format
#' write_map(cm, "course_map.dot")
#' }
#' 
#' @export
write_map <- function(x, filename, format = NULL, width = 10, height = 8, ...) {
  if (!inherits(x, "coursemap")) {
    stop("x must be a coursemap object")
  }
  
  # Auto-detect format from filename
  if (is.null(format)) {
    ext <- tools::file_ext(filename)
    format <- switch(tolower(ext),
                    "png" = "png",
                    "svg" = "svg", 
                    "dot" = "dot",
                    "svg")  # default
  }
  
  # Ensure correct extension
  base_name <- tools::file_path_sans_ext(filename)
  actual_filename <- paste0(base_name, ".", format)
  
  # Generate the file
  result <- .Call("wrap__generate_course_map", 
                  x$input_dir, actual_filename, format, x$config, 
                  PACKAGE = "coursemap")
  
  message("Course map saved to: ", actual_filename)
  invisible(actual_filename)
}

#' Check if Graphviz is available
#' 
#' @return TRUE if Graphviz is available, FALSE otherwise
#' 
#' @examples
#' \dontrun{
#' if (graphviz_available()) {
#'   message("Can generate PNG/SVG files")
#' } else {
#'   message("Only DOT format available")
#' }
#' }
#' 
#' @export
graphviz_available <- function() {
  .Call("wrap__check_graphviz_available", PACKAGE = "coursemap")
}

#' Get Graphviz version information
#' 
#' @return Graphviz version string
#' 
#' @examples
#' \dontrun{
#' if (graphviz_available()) {
#'   cat(graphviz_info())
#' }
#' }
#' 
#' @export
graphviz_info <- function() {
  .Call("wrap__get_graphviz_info", PACKAGE = "coursemap")
}

# Helper functions for environment detection

#' Check if running in knitr/Quarto
#' @keywords internal
is_knitr_running <- function() {
  !is.null(knitr::opts_knit$get("out.format")) || 
  !is.null(Sys.getenv("QUARTO_PROJECT_DIR", unset = NA))
}

#' Check if running in RStudio
#' @keywords internal
is_rstudio_running <- function() {
  Sys.getenv("RSTUDIO") == "1" || !is.na(Sys.getenv("RSTUDIO_USER_IDENTITY", unset = NA))
}

#' Check if running in testing environment
#' @keywords internal
is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true") || 
  exists("test_that", envir = .GlobalEnv) ||
  any(grepl("testthat", search()))
}
