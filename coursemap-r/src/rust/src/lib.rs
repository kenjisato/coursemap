use extendr_api::prelude::*;
use coursemap::App;
use std::fs;
use tempfile::NamedTempFile;

/// Generate a course dependency map
#[extendr]
fn generate_course_map(input_dir: &str, output_path: &str, format: &str, config_path: Option<&str>) -> Result<String> {
    let config = coursemap::load_config_from_path(config_path).map_err(|e| {
        Error::Other(format!("Failed to load config: {}", e))
    })?;

    let app = App::new(config);
    
    app.run(input_dir, output_path, format).map_err(|e| {
        Error::Other(format!("Failed to generate course map: {}", e))
    })?;

    Ok(output_path.to_string())
}

/// Generate SVG content as string for inline embedding
#[extendr]
fn generate_inline_svg(input_dir: &str, config_path: Option<&str>) -> Result<String> {
    let config = coursemap::load_config_from_path(config_path).map_err(|e| {
        Error::Other(format!("Failed to load config: {}", e))
    })?;

    // Create a temporary file that persists until we read it
    let temp_file = NamedTempFile::new().map_err(|e| {
        Error::Other(format!("Failed to create temp file: {}", e))
    })?;

    let temp_path = temp_file.path().to_string_lossy().to_string();

    // Generate the SVG file
    let app = App::new(config);
    app.run(input_dir, &temp_path, "svg").map_err(|e| {
        Error::Other(format!("Failed to generate course map: {}", e))
    })?;

    // Read the content while the temp file is still alive
    let content = fs::read_to_string(&temp_path).map_err(|e| {
        Error::Other(format!("Failed to read generated SVG: {}", e))
    })?;

    // Explicitly close the temp file
    temp_file.close().map_err(|e| {
        Error::Other(format!("Failed to close temp file: {}", e))
    })?;

    Ok(content)
}

/// Generate DOT content as string (memory-efficient)
#[extendr]
fn generate_dot_string(input_dir: &str, config_path: Option<&str>) -> Result<String> {
    let config = coursemap::load_config_from_path(config_path).map_err(|e| {
        Error::Other(format!("Failed to load config: {}", e))
    })?;

    let app = App::new(config);
    app.generate_dot_string(input_dir).map_err(|e| {
        Error::Other(format!("Failed to generate DOT string: {}", e))
    })
}

/// Check if Graphviz is available
#[extendr]
fn graphviz_available() -> bool {
    coursemap::renderer::graphviz_available()
}

/// Get Graphviz version information
#[extendr]
fn graphviz_info() -> Result<String> {
    coursemap::renderer::graphviz_info().map_err(|e| {
        Error::Other(format!("Failed to get Graphviz info: {}", e))
    })
}

/// Parse documents in a directory and return metadata
#[extendr]
fn parse_documents(input_dir: &str, config_path: Option<&str>) -> Result<List> {
    let config = coursemap::load_config_from_path(config_path).map_err(|e| {
        Error::Other(format!("Failed to load config: {}", e))
    })?;

    let documents = coursemap::parser::parse_directory(input_dir, &config).map_err(|e| {
        Error::Other(format!("Failed to parse documents: {}", e))
    })?;

    let mut result = List::new(documents.len());
    for (i, doc) in documents.iter().enumerate() {
        let mut doc_list = List::new(5);
        doc_list.set_names(&["id", "title", "phase", "prerequisites", "file_path"])?;
        doc_list.set_elt(0, doc.id.clone().into())?;
        doc_list.set_elt(1, doc.title.clone().into())?;
        doc_list.set_elt(2, doc.phase.clone().into())?;
        doc_list.set_elt(3, doc.prerequisites.clone().into())?;
        doc_list.set_elt(4, doc.file_path.to_string_lossy().to_string().into())?;
        result.set_elt(i, doc_list.into())?;
    }

    Ok(result)
}

/// Get configuration as list
#[extendr]
fn get_config(config_path: Option<&str>) -> Result<List> {
    let config = coursemap::load_config_from_path(config_path).map_err(|e| {
        Error::Other(format!("Failed to load config: {}", e))
    })?;

    let mut result = List::new(3);
    result.set_names(&["root_key", "phase", "ignore"])?;
    result.set_elt(0, config.root_key.into())?;
    
    // Convert phase configuration to R list
    let mut phases = List::new(config.phase.len());
    let phase_names: Vec<String> = config.phase.keys().cloned().collect();
    phases.set_names(&phase_names.iter().map(|s| s.as_str()).collect::<Vec<_>>())?;
    
    for (i, (_, phase_config)) in config.phase.iter().enumerate() {
        let mut phase_list = List::new(1);
        phase_list.set_names(&["face"])?;
        phase_list.set_elt(0, phase_config.face.clone().into())?;
        phases.set_elt(i, phase_list.into())?;
    }
    result.set_elt(1, phases.into())?;
    result.set_elt(2, config.ignore.into())?;

    Ok(result)
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod coursemap;
    fn generate_course_map;
    fn generate_inline_svg;
    fn generate_dot_string;
    fn graphviz_available;
    fn graphviz_info;
    fn parse_documents;
    fn get_config;
}
