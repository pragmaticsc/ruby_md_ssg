# frozen_string_literal: true

require 'webrick'
require 'digest'

module RubyMdSsg
  class Server
    class << self
      def start(options = {})
        new(default_options.merge(options)).start
      end

      private

      def default_options
        {
          port: 4000,
          docs: Paths.docs_dir,
          build: Paths.build_dir,
          assets: Paths.assets_dir,
          menu: Paths.menu_config,
          auto_build: true,
          watch: true,
          interval: 1.0
        }
      end
    end

    def initialize(options)
      @options = options
      @server = nil
    end

    def start
      build_site if options[:auto_build]
      watch_for_changes if options[:watch]
      start_server
    end

    private

    attr_reader :options, :server

    def build_site
      generator = MenuGenerator.new(docs_dir: options[:docs], menu_path: options[:menu])
      generator.generate

      compiler = Compiler.new(
        docs_dir: options[:docs],
        build_dir: options[:build],
        assets_dir: options[:assets],
        menu_path: options[:menu]
      )
      compiler.compile
      puts "[#{timestamp}] Build complete."
    rescue StandardError => e
      warn "[build] #{e.class}: #{e.message}"
      e.backtrace&.take(5)&.each { |line| warn "  #{line}" }
    end

    def watch_for_changes
      Thread.new do
        last = fingerprint
        loop do
          sleep options[:interval]
          current = fingerprint
          next if current == last

          puts "[watch] Change detected. Rebuilding..."
          build_site
          last = current
        rescue StandardError => e
          warn "[watch] #{e.class}: #{e.message}"
        end
      end
    end

    def start_server
      @server = WEBrick::HTTPServer.new(
        Port: options[:port],
        DocumentRoot: options[:build],
        AccessLog: [],
        Logger: WEBrick::Log.new($stderr, WEBrick::Log::INFO)
      )

      trap('INT') { server.shutdown }

      puts "Serving #{options[:build]} at http://localhost:#{options[:port]}"
      server.start
    end

    def fingerprint
      files = watched_files
      return 'empty' if files.empty?

      Digest::SHA1.hexdigest(
        files.sort.flat_map do |path|
          [path, File.mtime(path).to_f.to_s, (File.size?(path) || 0).to_s]
        end.join('|')
      )
    end

    def watched_files
      patterns = [
        File.join(options[:docs], '**', '*.md'),
        File.join(options[:docs], '*.yml'),
        File.join(options[:assets], '**', '*'),
        File.join(Paths.root, 'templates', '**', '*.erb')
      ]
      patterns.flat_map { |pattern| Dir.glob(pattern, File::FNM_DOTMATCH) }
              .select { |path| File.file?(path) }
    end

    def timestamp
      Time.now.strftime('%H:%M:%S')
    end
  end
end
