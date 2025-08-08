#' Course Map - R Interface
#' 
#' R wrapper for the Rust-based course-map tool.
#' Provides easy integration with Quarto documents and R environments.
#' 
#' @name coursemap-package
#' @aliases coursemap
#' @docType package
#' @title Course Dependency Map Visualization
#' @author Your Name
#' @keywords package
NULL

#' Generate a course dependency map
#' 
#' @param input_dir Directory containing course documents (default: ".")
#' @param output_path Output file path (default: "course_map.svg")
#' @param format Output format: "svg", "png", or "dot" (default: "svg")
#' @param config_path Path to configuration file (optional)
#' 
#' @return Path to the generated file
#' 
#' @examples
#' \dontrun{
#' # Generate SVG course map
#' generate_course_map("./courses", "my_course_map.svg")
#' 
#' # Generate PNG with custom config
#' generate_course_map("./courses", "course_map.png", "png", "config.yml")
#' }
#' 
#' @export
generate_course_map <- function(input_dir = ".", 
                               output_path = "course_map.svg",
                               format = "svg",
                               config_path = NULL) {
  .Call("wrap__generate_course_map", input_dir, output_path, format, config_path, PACKAGE = "coursemap")
}

#' Generate inline SVG content for embedding in documents
#' 
#' @param input_dir Directory containing course documents (default: ".")
#' @param config_path Path to configuration file (optional)
#' 
#' @return SVG content as character string
#' 
#' @examples
#' \dontrun{
#' # Generate inline SVG for Quarto document
#' svg_content <- generate_inline_svg("./courses")
#' cat(svg_content)
#' }
#' 
#' @export
generate_inline_svg <- function(input_dir = ".", config_path = NULL) {
  .Call("wrap__generate_inline_svg", input_dir, config_path, PACKAGE = "coursemap")
}

#' Check if Graphviz is available
#' 
#' @return TRUE if Graphviz is available, FALSE otherwise
#' 
#' @export
check_graphviz_available <- function() {
  .Call("wrap__check_graphviz_available", PACKAGE = "coursemap")
}

#' Get Graphviz version information
#' 
#' @return Graphviz version string or error message
#' 
#' @export
get_graphviz_info <- function() {
  .Call("wrap__get_graphviz_info", PACKAGE = "coursemap")
}

#' Create a Quarto filter function for embedding course maps
#' 
#' This function is designed to be used in Quarto documents to embed
#' course dependency maps directly in the rendered output.
#' 
#' @param input_dir Directory containing course documents (default: ".")
#' @param config_path Path to configuration file (optional)
#' 
#' @return SVG content as character string for embedding
#' 
#' @examples
#' \dontrun{
#' # In a Quarto document (.qmd):
#' # ```{r}
#' # #| echo: false
#' # library(coursemap)
#' # 
#' # # Generate and display course map
#' # svg_content <- create_quarto_filter("../courses")
#' # cat(svg_content)
#' # ```
#' }
#' 
#' @export
create_quarto_filter <- function(input_dir = ".", config_path = NULL) {
  .Call("wrap__create_quarto_filter", input_dir, config_path, PACKAGE = "coursemap")
}

#' CourseMap R6 Class
#' 
#' R6 class wrapper for CourseMap functionality
#' 
#' @export
CourseMapR <- function(config_path = NULL) {
  .Call("wrap__CourseMapR__new", config_path, PACKAGE = "coursemap")
}
