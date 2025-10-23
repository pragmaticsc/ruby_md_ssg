# frozen_string_literal: true

require 'kramdown'

module StaticRuby
  class MarkdownRenderer
    def render(markdown)
      Kramdown::Document.new(markdown).to_html
    end
  end
end
