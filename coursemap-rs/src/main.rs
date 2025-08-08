//! Course Map - A tool to visualize course dependencies from Quarto/Markdown documents

use anyhow::Result;
use coursemap::{cli::Cli, config::Config, App};

fn main() -> Result<()> {
    let args = Cli::parse_args();

    // Set up logging based on verbosity
    if args.verbose {
        env_logger::Builder::from_default_env()
            .filter_level(log::LevelFilter::Debug)
            .init();
    }

    // Load configuration
    let config = if let Some(config_path) = &args.config {
        Config::from_file(config_path)?
    } else {
        Config::load_default()?
    };

    if args.verbose {
        println!("Loaded configuration:");
        println!("  Root key: {}", config.root_key);
        println!("  Phases: {:?}", config.phase.keys().collect::<Vec<_>>());
        println!("  Ignore patterns: {:?}", config.ignore);
        println!();
    }

    // Create and run the application
    let app = App::new(config);
    
    println!("Scanning directory: {}", args.input_dir());
    println!("Output file: {}", args.output_path());
    println!("Format: {}", args.format_str());
    println!();

    // Check if Graphviz is available for non-DOT formats
    if args.format_str() != "dot" {
        if !coursemap::renderer::check_graphviz_available() {
            eprintln!("Warning: Graphviz not found. Only DOT format will be available.");
            eprintln!("To generate SVG/PNG files, please install Graphviz:");
            eprintln!("  macOS: brew install graphviz");
            eprintln!("  Ubuntu/Debian: sudo apt-get install graphviz");
            eprintln!("  Windows: Download from https://graphviz.org/download/");
            eprintln!();
            
            if args.format_str() != "dot" {
                return Err(anyhow::anyhow!("Cannot generate {} format without Graphviz", args.format_str()));
            }
        } else if args.verbose {
            if let Ok(info) = coursemap::renderer::get_graphviz_info() {
                println!("Graphviz found: {}", info);
                println!();
            }
        }
    }

    // Run the application
    match app.run(args.input_dir(), args.output_path(), &args.format_str()) {
        Ok(()) => {
            println!("Course map generated successfully!");
            Ok(())
        }
        Err(e) => {
            eprintln!("Error: {}", e);
            
            // Print additional context for common errors
            if e.to_string().contains("Directory does not exist") {
                eprintln!("Make sure the input directory exists and contains course documents.");
            } else if e.to_string().contains("Graphviz") {
                eprintln!("Try using --format dot to generate DOT format without Graphviz.");
            }
            
            std::process::exit(1);
        }
    }
}
