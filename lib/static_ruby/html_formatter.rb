# frozen_string_literal: true

require 'nokogiri'

module StaticRuby
  class HtmlFormatter
    def initialize(indent: 2)
      @indent = indent
    end

    def format(html)
      document = Nokogiri::HTML5.parse(html)
      document.to_html(indent: indent)
    end

    private

    attr_reader :indent
  end
end
