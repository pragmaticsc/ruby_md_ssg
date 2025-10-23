# Maintainer Guide

## Project Structure
Core code lives under `lib/static_ruby/` (compiler, CLI, server, helpers). Executables are in `exe/`, and the site scaffold lives in `template/site/`. Tests reside in `test/` and mirror the public API. The gem spec is `static_ruby.gemspec`.

## Development Commands
Run `bundle install` after touching the gemspec. Use `bundle exec ruby bin/test` (wrapper around the Minitest suite) before publishing. `bundle exec static_ruby build` from a test project exercises the full pipeline.

CI lives in `.github/workflows/test.yml` (runs on pushes/PRs). Publishing is handled by `.github/workflows/release.yml`; configure the repository secret `RUBYGEMS_API_KEY` before dispatching the workflow or pushing a `v*` tag.

## Releasing
1. Update `lib/static_ruby/version.rb`.
2. Run `bundle exec rake release` (after configuring credentials).
3. Update downstream projects (e.g., `ruby_static_example`) to the new version.

## Context Logging
See `CONTEXT_LOG.md` for recent architectural changes.
