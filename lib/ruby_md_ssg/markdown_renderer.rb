# frozen_string_literal: true

require 'kramdown'

module RubyMdSsg
  class MarkdownRenderer
    def render(markdown)
      Kramdown::Document.new(markdown).to_html
    end
  end
end
