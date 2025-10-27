# Ruby MD SSG

The `ruby-md-ssg` gem exposes a command-line interface for building and serving markdown-driven static sites.

## Development

```bash
bundle install
bundle exec ruby bin/test
```

## CLI

- `ruby_md_ssg new my-site` — scaffold a new project using the bundled template
- `ruby_md_ssg build` — regenerate the site into `build/` (also emits `sitemap.xml`; pass `--base-url`/`--base-path` to control canonical URLs and link prefixes)
- `ruby_md_ssg serve` — serve the site locally with automatic rebuilds
- `ruby_md_ssg menu` — refresh `docs/menu.yml`
