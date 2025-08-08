//! Course Map - A tool to visualize course dependencies from Quarto/Markdown documents
//! 
//! This library provides functionality to parse Quarto/Markdown documents and generate
//! visual dependency graphs showing the relationships between courses.
//! 
//! # Examples
//! 
//! ```rust,no_run
//! use coursemap::{Config, App};
//! 
//! // Load configuration
//! let config = Config::load_default().unwrap();
//! 
//! // Create app instance
//! let app = App::new(config);
//! 
//! // Generate course map
//! app.run("./courses", "course_map.svg", "svg").unwrap();
//! ```

pub mod cli;
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
