# Maintainer Guide

## Project Structure
Core code lives under `lib/ruby_md_ssg/` (compiler, CLI, server, helpers). Executables are in `exe/`, and the site scaffold lives in `template/site/`. Tests reside in `test/` and mirror the public API. The gem spec is `ruby-md-ssg.gemspec`.

## Development Commands
Run `bundle install` after touching the gemspec. Use `bundle exec ruby bin/test` (wrapper around the Minitest suite) before publishing. `bundle exec ruby_md_ssg build` from a test project exercises the full pipeline and should emit `sitemap.xml`; set `RUBY_MD_SSG_BASE_URL` (or pass `--base-url`) to control sitemap URLs.

CI lives in `.github/workflows/test.yml` (runs RuboCop, then the test suite on pushes/PRs). Publishing is handled by `.github/workflows/release.yml`; configure the repository secret `RUBYGEMS_API_KEY` before dispatching the workflow or pushing a `v*` tag.

## Releasing
1. Update `lib/ruby_md_ssg/version.rb`.
2. Run `bundle exec rake release` (after configuring credentials).
3. Update downstream projects (e.g., `ruby-md-ssg-example`) to the new version.

## Context Logging
See `CONTEXT_LOG.md` for recent architectural changes.
