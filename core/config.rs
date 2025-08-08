//! Configuration management for the course map tool

use anyhow::{Context, Result};
use indexmap::IndexMap;
use serde::{Deserialize, Serialize};
use std::collections::HashSet;
use std::fs;
use std::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    #[serde(rename = "root-key")]
    pub root_key: String,
    pub phase: IndexMap<String, PhaseConfig>,
    pub ignore: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhaseConfig {
    pub face: String,
}

impl Default for Config {
    fn default() -> Self {
        let mut phase = IndexMap::new();
        phase.insert("Pre".to_string(), PhaseConfig {
            face: "lightblue".to_string(),
        });
        phase.insert("InClass".to_string(), PhaseConfig {
            face: "lightgreen".to_string(),
        });
        phase.insert("Post".to_string(), PhaseConfig {
            face: "orange".to_string(),
        });
        phase.insert("Unknown".to_string(), PhaseConfig {
            face: "lightgray".to_string(),
        });

        Self {
            root_key: "course-map".to_string(),
            phase,
            ignore: vec!["/index.qmd".to_string()],
        }
    }
}

impl Config {
    /// Load configuration from a YAML file
    pub fn from_file<P: AsRef<Path>>(path: P) -> Result<Self> {
        let content = fs::read_to_string(&path)
            .with_context(|| format!("Failed to read config file: {}", path.as_ref().display()))?;
        
        let config: Config = serde_yaml::from_str(&content)
            .with_context(|| format!("Failed to parse config file: {}", path.as_ref().display()))?;
        
        Ok(config)
    }

    /// Load configuration from the default locations
    pub fn load_default() -> Result<Self> {
        // Try to load from common config file locations
        let config_paths = [
            "config.yml",
            "config.yaml",
            "src/course_map/config.yml",
            ".course-map.yml",
        ];

        for path in &config_paths {
            if Path::new(path).exists() {
                return Self::from_file(path);
            }
        }

        // If no config file found, use default configuration
        Ok(Self::default())
    }

    /// Get the color for a given phase
    pub fn get_phase_color(&self, phase: &str) -> String {
        self.phase
            .get(phase)
            .map(|p| p.face.clone())
            .unwrap_or_else(|| {
                self.phase
                    .get("Unknown")
                    .map(|p| p.face.clone())
                    .unwrap_or_else(|| "lightgray".to_string())
            })
    }

    /// Check if a file should be ignored
    pub fn should_ignore(&self, file_path: &str) -> bool {
        self.ignore.iter().any(|pattern| {
            if pattern.starts_with('/') {
                file_path.ends_with(&pattern[1..])
            } else {
                file_path.contains(pattern)
            }
        })
    }

    /// Get all available phases
    pub fn get_phases(&self) -> HashSet<String> {
        self.phase.keys().cloned().collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::NamedTempFile;
    use std::io::Write;

    #[test]
    fn test_default_config() {
        let config = Config::default();
        assert_eq!(config.root_key, "course-map");
        assert!(config.phase.contains_key("Pre"));
        assert!(config.phase.contains_key("InClass"));
        assert!(config.phase.contains_key("Post"));
        assert!(config.phase.contains_key("Unknown"));
    }

    #[test]
    fn test_phase_color() {
        let config = Config::default();
        assert_eq!(config.get_phase_color("Pre"), "lightblue");
        assert_eq!(config.get_phase_color("NonExistent"), "lightgray");
    }

    #[test]
    fn test_should_ignore() {
        let config = Config::default();
        assert!(config.should_ignore("some/path/index.qmd"));
        assert!(!config.should_ignore("some/path/intro.qmd"));
    }

    #[test]
    fn test_config_from_file() -> Result<()> {
        let mut temp_file = NamedTempFile::new()?;
        writeln!(temp_file, r#"
root-key: test-map
phase:
  Test:
    face: red
ignore:
  - test.qmd
"#)?;

        let config = Config::from_file(temp_file.path())?;
        assert_eq!(config.root_key, "test-map");
        assert_eq!(config.get_phase_color("Test"), "red");
        assert!(config.should_ignore("test.qmd"));

        Ok(())
    }
}
