# frozen_string_literal: true

require 'optparse'
require 'fileutils'
require 'erb'

module StaticRuby
  class CLI
    TEMPLATE_DIR = File.expand_path('../../template/site', __dir__)

    def self.start(argv)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv.dup
    end

    def run
      command = argv.shift
      case command
      when 'new'
        handle_new(argv)
      when 'build'
        handle_build(argv)
      when 'serve'
        handle_serve(argv)
      when 'menu'
        handle_menu(argv)
      when 'version', '--version', '-v'
        puts "Static Ruby #{StaticRuby::VERSION}"
      else
        puts usage
        command ? exit(1) : exit(0)
      end
    end

    private

    attr_reader :argv

    def usage
      <<~TEXT
        Usage: static_ruby <command> [options]

        Commands:
          new NAME           # Scaffold a new Static Ruby project
          build              # Generate the site into the build directory
          serve              # Serve the site locally with rebuilds
          menu               # Regenerate docs/menu.yml from docs/
          version            # Show gem version
      TEXT
    end

    def handle_new(args)
      options = { path: nil }
      parser = OptionParser.new do |opts|
        opts.banner = 'Usage: static_ruby new NAME [options]'
        opts.on('-pPATH', '--path=PATH', 'Target directory (defaults to NAME)') { |path| options[:path] = File.expand_path(path) }
      end
      parser.parse!(args)

      project_name = args.shift
      unless project_name
        warn 'Project name is required.'
        puts parser
        exit 1
      end

      destination = options[:path] || File.expand_path(project_name)
      Scaffold.new(project_name, destination).run
      puts "Created Static Ruby project at #{destination}"
    end

    def handle_build(args)
      StaticRuby::Paths.reset!
      StaticRuby::Paths.root = Dir.pwd
      options = build_options(args)

      generator = StaticRuby::MenuGenerator.new(docs_dir: options[:docs], menu_path: options[:menu])
      generator.generate

      compiler = StaticRuby::Compiler.new(
        docs_dir: options[:docs],
        build_dir: options[:build],
        assets_dir: options[:assets],
        menu_path: options[:menu]
      )
      compiler.compile
    end

    def handle_menu(args)
      StaticRuby::Paths.reset!
      StaticRuby::Paths.root = Dir.pwd
      options = build_options(args)
      generator = StaticRuby::MenuGenerator.new(docs_dir: options[:docs], menu_path: options[:menu])
      generator.generate
    end

    def handle_serve(args)
      StaticRuby::Paths.reset!
      StaticRuby::Paths.root = Dir.pwd
      options = build_options(args)
      StaticRuby::Server.start(options)
    end

    def build_options(args)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = 'Options:'
        opts.on('--docs PATH', 'Directory containing markdown docs') { |path| options[:docs] = File.expand_path(path) }
        opts.on('--build PATH', 'Build output directory') { |path| options[:build] = File.expand_path(path) }
        opts.on('--menu PATH', 'Menu configuration path') { |path| options[:menu] = File.expand_path(path) }
        opts.on('--assets PATH', 'Assets directory') { |path| options[:assets] = File.expand_path(path) }
        opts.on('--port PORT', Integer, 'Port for serve command (default: 4000)') { |port| options[:port] = port }
        opts.on('--[no-]auto-build', 'Serve only: build before starting (default: true)') { |flag| options[:auto_build] = flag }
        opts.on('--[no-]watch', 'Serve only: watch for changes (default: true)') { |flag| options[:watch] = flag }
        opts.on('--interval SECONDS', Float, 'Serve only: watch interval (default: 1.0)') { |seconds| options[:interval] = seconds }
      end
      parser.parse!(args)

      options[:docs] ||= StaticRuby::Paths.docs_dir
      options[:build] ||= StaticRuby::Paths.build_dir
      options[:menu] ||= StaticRuby::Paths.menu_config
      options[:assets] ||= StaticRuby::Paths.assets_dir
      options.delete_if { |_key, value| value.nil? }
    end

    class Scaffold
      attr_reader :project_name, :destination

      def initialize(project_name, destination)
        @project_name = project_name
        @destination = destination
      end

      def run
        raise "Directory already exists: #{destination}" if File.exist?(destination)

        FileUtils.mkdir_p(destination)
        copy_template
        post_process
      end

      private

      def copy_template
        Dir.glob(File.join(TEMPLATE_DIR, '**', '*'), File::FNM_DOTMATCH).each do |source|
          next if ['.', '..'].include?(File.basename(source))

          relative = source.delete_prefix("#{TEMPLATE_DIR}/")
          templated = source.end_with?('.erb') && !relative.start_with?('templates/')
          target_relative = templated ? relative.sub(/\.erb\z/, '') : relative
          target = File.join(destination, target_relative)

          if File.directory?(source)
            FileUtils.mkdir_p(target)
          else
            content = if templated
                        ERB.new(File.read(source), trim_mode: '-').result(binding_context)
                      else
                        File.binread(source)
                      end
            FileUtils.mkdir_p(File.dirname(target))
            File.write(target, content)
            File.chmod(File.stat(source).mode & 0o777, target)
          end
        end
      end

      def post_process
        FileUtils.mkdir_p(File.join(destination, 'build'))
      end

      def binding_context
        BindingStruct.new(
          project_name: project_name,
          module_name: module_name,
          gem_version: StaticRuby::VERSION,
          helpers: HelperMethods.new(project_name)
        ).get_binding
      end

      def module_name
        normalize_identifier(project_name)
      end

      def normalize_identifier(value)
        value.split(/[^a-zA-Z0-9]/).reject(&:empty?).map(&:capitalize).join
      end

      class BindingStruct < Struct.new(:project_name, :module_name, :gem_version, :helpers, keyword_init: true)
        def get_binding
          binding
        end
      end

      class HelperMethods
        def initialize(project_name)
          @project_name = project_name
        end

        def human_project_name
          @human_project_name ||= @project_name.split(/[^a-zA-Z0-9]/).reject(&:empty?).map(&:capitalize).join(' ')
        end
      end
    end
  end
end
