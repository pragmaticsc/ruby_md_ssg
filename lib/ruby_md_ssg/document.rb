# frozen_string_literal: true

require 'yaml'
require_relative 'paths'

module RubyMdSsg
  # Represents a markdown document and its derived site metadata.
  class Document
    attr_reader :source_path, :docs_dir

    def initialize(source_path, docs_dir: Paths.docs_dir)
      @source_path = source_path
      @docs_dir = docs_dir
    end

    def relative_path
      @relative_path ||= begin
        prefix = "#{docs_dir}/"
        if source_path.start_with?(prefix)
          source_path.delete_prefix(prefix)
        else
          source_path
        end
      end
    end

    def route
      return '/' if relative_path == 'index.md'

      "/#{relative_path.sub(/\.md\z/, '')}"
    end

    def output_dir
      File.join(Paths.build_dir, route.delete_prefix('/'))
    end

    def output_path
      if route == '/'
        File.join(Paths.build_dir, 'index.html')
      else
        File.join(output_dir, 'index.html')
      end
    end

    def title
      @title ||= title_from_frontmatter || title_from_heading || default_title
    end

    def content
      @content ||= File.read(source_path)
    end

    def last_modified
      File.mtime(source_path)
    end

    def meta_description
      @meta_description ||= begin
        value = frontmatter['description'] || frontmatter['meta_description']
        value&.to_s&.strip
      end
    end

    def body_markdown
      frontmatter_match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
      return content unless frontmatter_match

      content.sub(frontmatter_match[0], '')
    end

    def frontmatter
      return @frontmatter if defined?(@frontmatter)

      match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
      @frontmatter = if match
                       YAML.safe_load(match[1]) || {}
                     else
                       {}
                     end
    end

    private

    def title_from_frontmatter
      frontmatter['title']
    end

    def title_from_heading
      line = content.each_line.find { |l| l.start_with?('# ') }
      return unless line

      heading = line.split('# ', 2).last
      heading&.strip
    end

    def default_title
      File.basename(relative_path, '.md').tr('_-', ' ').split.map(&:capitalize).join(' ')
    end
  end
end
