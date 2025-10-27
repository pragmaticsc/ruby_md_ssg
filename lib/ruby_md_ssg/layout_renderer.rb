# frozen_string_literal: true

require 'erb'
require_relative 'paths'

module RubyMdSsg
  class LayoutRenderer
    def initialize(template_path: default_template_path)
      @template_path = template_path
    end

    def render(document:, body_html:, menu:, base_path: '')
      template.result_with_hash(
        title: document.title,
        body_html: body_html,
        menu: menu,
        meta_description: document.meta_description,
        helpers: TemplateHelpers.new(base_path)
      )
    end

    private

    attr_reader :template_path

    def template
      @template ||= ERB.new(File.read(template_path))
    end

    def default_template_path
      File.join(Paths.root, 'templates', 'layout.html.erb')
    end

    class TemplateHelpers
      def initialize(base_path)
        @base_path = normalize_base_path(base_path)
      end

      def asset_path(filename)
        build_path('assets', filename)
      end

      def route_path(route)
        return base_path if base_path? && root_route?(route)
        return '/' if root_route?(route)

        build_path(route.delete_prefix('/'))
      end

      private

      attr_reader :base_path

      def base_path?
        !base_path.empty?
      end

      def normalize_base_path(path)
        return '' if path.nil? || path.empty? || path == '/'

        normalized = path.start_with?('/') ? path : "/#{path}"
        normalized.chomp('/')
      end

      def build_path(*segments)
        tail = segments.join('/').sub(%r{^/+}, '')
        return "/#{tail}" unless base_path?

        "#{base_path}/#{tail}"
      end

      def root_route?(route)
        route.nil? || route == '/'
      end
    end
  end
end
