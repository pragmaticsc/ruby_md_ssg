## 2024-10-08
- Extracted gem from the original project: contains library code, CLI, scaffold template, and test suite.
- Added helper-backed ERB templates for scaffolding and ensured tests cover project generation.
- Added GitHub Actions workflows for CI (`.github/workflows/test.yml`) and RubyGems publishing (`.github/workflows/release.yml`).
- Renamed gem to `ruby-md-ssg`, updated namespaces/commands, and refreshed documentation and tests to reflect the new branding.
- Compiler now emits `sitemap.xml` (with optional `--base-url` support), CI runs RuboCop before executing tests, and the scaffold ships a GitHub Pages deploy workflow.
