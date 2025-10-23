# frozen_string_literal: true

require_relative 'paths'
require_relative 'document'

module StaticRuby
  class DocumentFinder
    def initialize(docs_dir: Paths.docs_dir)
      @docs_dir = docs_dir
    end

    def all
      markdown_files.map { |path| Document.new(path, docs_dir: docs_dir) }
    end

    private

    attr_reader :docs_dir

    def markdown_files
      Dir.glob(File.join(docs_dir, '**', '*.md')).sort
    end
  end
end
