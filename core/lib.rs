//! Course Map Core - Core library for course dependency visualization

pub mod config;
pub mod parser;
pub mod graph;
pub mod renderer;

pub use anyhow::{Error, Result};
pub use config::Config;

/// The main application structure
pub struct App {
    pub config: config::Config,
}

impl App {
    /// Create a new App instance with the given configuration
    pub fn new(config: config::Config) -> Self {
        Self { config }
    }

    /// Run the course map generation process
    pub fn run(&self, input_dir: &str, output_path: &str, format: &str) -> Result<()> {
        // Parse all documents in the input directory
        let documents = parser::parse_directory(input_dir, &self.config)?;
        
        // Build the dependency graph
        let graph = graph::build_graph(documents)?;
        
        // Render the graph to the specified format
        renderer::render_graph(&graph, output_path, format, &self.config)?;
        
        Ok(())
    }
}
