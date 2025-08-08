"""
Course Map - A tool to visualize course dependencies from Quarto/Markdown documents

This package provides Python bindings for the Rust-based course-map tool,
allowing easy integration with Quarto documents and Python environments.
"""

from typing import Optional, Dict, List, Any
import sys
import os

try:
    from .coursemap_rs import (
        CourseMap,
        generate_course_map,
        generate_inline_svg,
        check_graphviz_available,
        get_graphviz_info,
    )
except ImportError as e:
    raise ImportError(
        "Failed to import Rust extension. Make sure the package is properly installed with maturin."
    ) from e

__version__ = "0.1.2"
__all__ = [
    "CourseMap",
    "generate_course_map",
    "generate_inline_svg", 
    "check_graphviz_available",
    "get_graphviz_info",
    "create_quarto_filter",
]

def create_quarto_filter(input_dir: str = ".", config_path: Optional[str] = None) -> str:
    """
    Create a Quarto filter function that generates inline SVG course maps.
    
    This function is designed to be used in Quarto documents to embed
    course dependency maps directly in the rendered output.
    
    Args:
        input_dir: Directory containing course documents
        config_path: Path to configuration file
        
    Returns:
        SVG content as string for embedding in Quarto documents
        
    Example:
        In a Quarto document (.qmd):
        
        ```{python}
        #| echo: false
        import coursemap
        
        # Generate and display course map
        svg_content = coursemap.create_quarto_filter("../courses")
        print(svg_content)
        ```
    """
    try:
        return generate_inline_svg(input_dir, config_path)
    except Exception as e:
        # Return error message as HTML comment for debugging
        return f"<!-- Course Map Error: {str(e)} -->"

def main() -> None:
    """
    Command-line interface for the Python package.
    
    This provides a simple CLI that wraps the Rust binary functionality.
    """
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Generate course dependency maps from Quarto/Markdown documents"
    )
    parser.add_argument(
        "-i", "--input", 
        default=".", 
        help="Input directory containing course documents"
    )
    parser.add_argument(
        "-o", "--output", 
        default="course_map.svg", 
        help="Output file path"
    )
    parser.add_argument(
        "-f", "--format", 
        default="svg", 
        choices=["svg", "png", "dot"],
        help="Output format"
    )
    parser.add_argument(
        "-c", "--config", 
        help="Configuration file path"
    )
    parser.add_argument(
        "--inline", 
        action="store_true",
        help="Generate inline SVG content (prints to stdout)"
    )
    parser.add_argument(
        "--check-graphviz", 
        action="store_true",
        help="Check if Graphviz is available"
    )
    
    args = parser.parse_args()
    
    try:
        if args.check_graphviz:
            if check_graphviz_available():
                print("Graphviz is available:")
                print(get_graphviz_info())
            else:
                print("Graphviz is not available")
                sys.exit(1)
        elif args.inline:
            svg_content = generate_inline_svg(args.input, args.config)
            print(svg_content)
        else:
            output_path = generate_course_map(
                args.input, 
                args.output, 
                args.format, 
                args.config
            )
            print(f"Generated: {output_path}")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
