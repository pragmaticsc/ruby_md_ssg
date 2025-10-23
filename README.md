# Static Ruby

The `static_ruby` gem exposes a command-line interface for building and serving markdown-driven static sites.

## Development

```bash
bundle install
bundle exec ruby bin/test
```

## CLI

- `static_ruby new my-site` — scaffold a new project using the bundled template
- `static_ruby build` — regenerate the site into `build/`
- `static_ruby serve` — serve the site locally with automatic rebuilds
- `static_ruby menu` — refresh `docs/menu.yml`
