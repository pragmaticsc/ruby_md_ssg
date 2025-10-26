# frozen_string_literal: true

module RubyMdSsg
  module Paths
    module_function

    def root
      @root ||= begin
        env_root = ENV['RUBY_MD_SSG_ROOT']
        if env_root && !env_root.empty?
          File.expand_path(env_root)
        else
          Dir.pwd
        end
      end
    end

    def root=(value)
      @root = value && File.expand_path(value)
    end

    def reset!
      @root = nil
    end

    def docs_dir
      File.join(root, 'docs')
    end

    def build_dir
      File.join(root, 'build')
    end

    def assets_dir
      File.join(root, 'assets')
    end

    def menu_config
      File.join(docs_dir, 'menu.yml')
    end

    def templates_dir
      File.join(root, 'templates')
    end
  end
end
