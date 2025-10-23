require_relative 'lib/static_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = 'static_ruby'
  spec.version       = StaticRuby::VERSION
  spec.authors       = ['Static Ruby Maintainers']
  spec.email         = ['maintainers@example.com']

  spec.summary       = 'Minimal static site generator for markdown-based projects.'
  spec.description   = 'Static Ruby provides CLI tooling to scaffold, build, and serve static sites from markdown using a consistent Ruby pipeline.'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*', 'exe/*', 'template/site/**/*', 'templates/**/*', 'AGENTS.md', 'CONTEXT_LOG.md', 'README.md'].select { |f| File.exist?(f) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'kramdown', '~> 2.4'
  spec.add_dependency 'nokogiri', '~> 1.16'
  spec.add_dependency 'webrick', '~> 1.8'

  spec.add_development_dependency 'minitest', '~> 5.22'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop'
end
