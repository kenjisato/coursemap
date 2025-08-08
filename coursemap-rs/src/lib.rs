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

// Re-export everything from coursemap-core
pub use coursemap_core::*;
pub use coursemap_core::config::Config;
