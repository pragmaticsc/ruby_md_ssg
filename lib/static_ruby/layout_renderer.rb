# frozen_string_literal: true

require 'erb'
require_relative 'paths'

module StaticRuby
  class LayoutRenderer
    def initialize(template_path: default_template_path)
      @template_path = template_path
    end

    def render(document:, body_html:, menu:)
      template.result_with_hash(
        title: document.title,
        body_html: body_html,
        menu: menu,
        meta_description: document.meta_description
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
  end
end
