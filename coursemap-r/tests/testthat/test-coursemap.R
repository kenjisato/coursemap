test_that("coursemap basic functionality works", {
  # Test that the package loads without error
  expect_true(exists("coursemap"))
  expect_true(exists("write_map"))
  expect_true(exists("graphviz_available"))
  expect_true(exists("graphviz_info"))
})

test_that("coursemap object creation works", {
  # Test creating coursemap object
  cm <- coursemap(".")
  expect_s3_class(cm, "coursemap")
  expect_equal(cm$input_dir, ".")
  expect_null(cm$config)
  
  # Test with config
  cm_with_config <- coursemap(".", config = "test.yml")
  expect_equal(cm_with_config$config, "test.yml")
})

test_that("write_map works with test data", {
  # Create temporary directory with test files
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "test_courses")
  dir.create(test_dir, showWarnings = FALSE)
  
  # Create test course file
  course_file <- file.path(test_dir, "test_course.qmd")
  writeLines(c(
    "---",
    "title: \"Test Course\"",
    "course-map:",
    "  id: test-course",
    "  phase: Pre",
    "  prerequisites: []",
    "---",
    "",
    "# Test Course Content"
  ), course_file)
  
  # Create coursemap object
  cm <- coursemap(test_dir)
  
  # Test write_map with DOT format
  output_file <- file.path(temp_dir, "test_output.dot")
  expect_error(
    result <- write_map(cm, output_file),
    NA
  )
  
  # Check that output file was created
  expect_true(file.exists(output_file))
  
  # Check that output contains expected content
  content <- readLines(output_file)
  content_text <- paste(content, collapse = " ")
  expect_true(grepl("test-course", content_text))
  
  # Clean up
  unlink(test_dir, recursive = TRUE)
  unlink(output_file)
})

test_that("plot method works", {
  # Create temporary directory with test files
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "plot_test")
  dir.create(test_dir, showWarnings = FALSE)
  
  # Create test course file
  course_file <- file.path(test_dir, "simple.qmd")
  writeLines(c(
    "---",
    "title: \"Simple Course\"",
    "course-map:",
    "  id: simple",
    "  phase: Pre",
    "  prerequisites: []",
    "---",
    "",
    "# Simple Course"
  ), course_file)
  
  # Create coursemap object
  cm <- coursemap(test_dir)
  
  # Test plot method (should not error)
  expect_error(plot(cm), NA)
  
  # Clean up
  unlink(test_dir, recursive = TRUE)
})

test_that("graphviz functions work", {
  # Test graphviz_available
  result <- graphviz_available()
  expect_type(result, "logical")
  
  # Test graphviz_info (only if available)
  if (graphviz_available()) {
    info <- graphviz_info()
    expect_type(info, "character")
    expect_true(nchar(info) > 0)
  }
})

test_that("write_map format auto-detection works", {
  # Create temporary directory with test files
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "format_test")
  dir.create(test_dir, showWarnings = FALSE)
  
  # Create test course file
  course_file <- file.path(test_dir, "format_test.qmd")
  writeLines(c(
    "---",
    "title: \"Format Test\"",
    "course-map:",
    "  id: format-test",
    "  phase: Pre",
    "  prerequisites: []",
    "---",
    "",
    "# Format Test"
  ), course_file)
  
  # Create coursemap object
  cm <- coursemap(test_dir)
  
  # Test DOT format auto-detection
  dot_output <- file.path(temp_dir, "test.dot")
  expect_error(
    result <- write_map(cm, dot_output),
    NA
  )
  expect_true(file.exists(dot_output))
  expect_equal(result, dot_output)
  
  # Test explicit format specification
  svg_output <- file.path(temp_dir, "test_explicit")
  expect_error(
    result <- write_map(cm, svg_output, format = "svg"),
    NA
  )
  expected_svg <- paste0(svg_output, ".svg")
  expect_equal(result, expected_svg)
  
  # Clean up
  unlink(test_dir, recursive = TRUE)
  unlink(dot_output)
  unlink(expected_svg)
})

test_that("error handling works correctly", {
  # Test write_map with non-coursemap object
  expect_error(
    write_map("not_a_coursemap", "output.dot"),
    "x must be a coursemap object"
  )
})
