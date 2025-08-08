//! Python bindings for the course-map library using PyO3

use pyo3::prelude::*;
use pyo3::types::PyDict;
use course_map::{Config, App};
use std::collections::HashMap;

#[pyclass]
#[derive(Clone)]
pub struct CourseMap {
    config: Config,
}

#[pymethods]
impl CourseMap {
    #[new]
    #[pyo3(signature = (config_path = None))]
    pub fn new(config_path: Option<String>) -> PyResult<Self> {
        let config = if let Some(path) = config_path {
            Config::from_file(path).map_err(|e| {
                pyo3::exceptions::PyIOError::new_err(format!("Failed to load config: {}", e))
            })?
        } else {
            Config::load_default().map_err(|e| {
                pyo3::exceptions::PyIOError::new_err(format!("Failed to load default config: {}", e))
            })?
        };

        Ok(CourseMap { config })
    }

    /// Generate a course dependency map
    #[pyo3(signature = (input_dir = ".", output_path = "course_map.svg", format = "svg"))]
    pub fn generate(
        &self,
        input_dir: &str,
        output_path: &str,
        format: &str,
    ) -> PyResult<String> {
        let app = App::new(self.config.clone());
        
        app.run(input_dir, output_path, format).map_err(|e| {
            pyo3::exceptions::PyRuntimeError::new_err(format!("Failed to generate course map: {}", e))
        })?;

        Ok(output_path.to_string())
    }

    /// Generate SVG format course map
    #[pyo3(signature = (input_dir = ".", output_path = "course_map.svg"))]
    pub fn generate_svg(&self, input_dir: &str, output_path: &str) -> PyResult<String> {
        self.generate(input_dir, output_path, "svg")
    }

    /// Generate PNG format course map
    #[pyo3(signature = (input_dir = ".", output_path = "course_map.png"))]
    pub fn generate_png(&self, input_dir: &str, output_path: &str) -> PyResult<String> {
        self.generate(input_dir, output_path, "png")
    }

    /// Generate DOT format course map
    #[pyo3(signature = (input_dir = ".", output_path = "course_map.dot"))]
    pub fn generate_dot(&self, input_dir: &str, output_path: &str) -> PyResult<String> {
        self.generate(input_dir, output_path, "dot")
    }

    /// Generate SVG content as string for inline embedding
    #[pyo3(signature = (input_dir = "."))]
    pub fn generate_inline_svg(&self, input_dir: &str) -> PyResult<String> {
        use std::fs;
        use tempfile::NamedTempFile;

        let temp_file = NamedTempFile::new().map_err(|e| {
            pyo3::exceptions::PyIOError::new_err(format!("Failed to create temp file: {}", e))
        })?;

        let temp_path = temp_file.path().to_str().ok_or_else(|| {
            pyo3::exceptions::PyValueError::new_err("Invalid temp file path")
        })?;

        self.generate(input_dir, temp_path, "svg")?;

        let content = fs::read_to_string(temp_path).map_err(|e| {
            pyo3::exceptions::PyIOError::new_err(format!("Failed to read generated SVG: {}", e))
        })?;

        Ok(content)
    }

    /// Get configuration as dictionary
    pub fn get_config(&self) -> PyResult<PyObject> {
        Python::with_gil(|py| {
            let dict = PyDict::new(py);
            dict.set_item("root_key", &self.config.root_key)?;
            
            let phases = PyDict::new(py);
            for (phase, config) in &self.config.phase {
                let phase_dict = PyDict::new(py);
                phase_dict.set_item("face", &config.face)?;
                phases.set_item(phase, phase_dict)?;
            }
            dict.set_item("phase", phases)?;
            dict.set_item("ignore", &self.config.ignore)?;
            
            Ok(dict.into())
        })
    }

    /// Parse documents in a directory and return metadata
    #[pyo3(signature = (input_dir = "."))]
    pub fn parse_documents(&self, input_dir: &str) -> PyResult<Vec<PyObject>> {
        let documents = course_map::parser::parse_directory(input_dir, &self.config).map_err(|e| {
            pyo3::exceptions::PyRuntimeError::new_err(format!("Failed to parse documents: {}", e))
        })?;

        Python::with_gil(|py| {
            let mut result = Vec::new();
            for doc in documents {
                let dict = PyDict::new(py);
                dict.set_item("id", &doc.id)?;
                dict.set_item("title", &doc.title)?;
                dict.set_item("phase", &doc.phase)?;
                dict.set_item("prerequisites", &doc.prerequisites)?;
                dict.set_item("file_path", doc.file_path.to_string_lossy().as_ref())?;
                result.push(dict.into());
            }
            Ok(result)
        })
    }
}

/// Convenience function to generate a course map
#[pyfunction]
#[pyo3(signature = (input_dir = ".", output_path = "course_map.svg", format = "svg", config_path = None))]
pub fn generate_course_map(
    input_dir: &str,
    output_path: &str,
    format: &str,
    config_path: Option<String>,
) -> PyResult<String> {
    let course_map = CourseMap::new(config_path)?;
    course_map.generate(input_dir, output_path, format)
}

/// Convenience function to generate inline SVG
#[pyfunction]
#[pyo3(signature = (input_dir = ".", config_path = None))]
pub fn generate_inline_svg(input_dir: &str, config_path: Option<String>) -> PyResult<String> {
    let course_map = CourseMap::new(config_path)?;
    course_map.generate_inline_svg(input_dir)
}

/// Check if Graphviz is available
#[pyfunction]
pub fn check_graphviz_available() -> bool {
    course_map::renderer::check_graphviz_available()
}

/// Get Graphviz version information
#[pyfunction]
pub fn get_graphviz_info() -> PyResult<String> {
    course_map::renderer::get_graphviz_info().map_err(|e| {
        pyo3::exceptions::PyRuntimeError::new_err(format!("Failed to get Graphviz info: {}", e))
    })
}

#[pymodule]
fn course_map_rs(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_class::<CourseMap>()?;
    m.add_function(wrap_pyfunction!(generate_course_map, m)?)?;
    m.add_function(wrap_pyfunction!(generate_inline_svg, m)?)?;
    m.add_function(wrap_pyfunction!(check_graphviz_available, m)?)?;
    m.add_function(wrap_pyfunction!(get_graphviz_info, m)?)?;
    Ok(())
}
