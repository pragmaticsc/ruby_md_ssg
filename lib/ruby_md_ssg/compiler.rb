# frozen_string_literal: true

require 'fileutils'
require 'nokogiri'
require_relative 'paths'
require_relative 'document_finder'
require_relative 'menu_config'
require_relative 'markdown_renderer'
require_relative 'layout_renderer'
require_relative 'html_formatter'

module RubyMdSsg
  class Compiler
    def initialize(docs_dir: Paths.docs_dir, build_dir: Paths.build_dir, assets_dir: Paths.assets_dir, menu_path: Paths.menu_config, base_url: nil)
      @docs_dir = docs_dir
      @build_dir = build_dir
      @assets_dir = assets_dir
      @menu_path = menu_path
      @base_url = base_url
      @markdown = MarkdownRenderer.new
      @layout = LayoutRenderer.new
      @html_formatter = HtmlFormatter.new
    end

    def compile
      purge_build
      ensure_build_structure

      documents = DocumentFinder.new(docs_dir: docs_dir).all
      menu = menu_from_configuration(documents)

      documents.each do |document|
        render_document(document, menu)
      end

      copy_assets
      generate_sitemap(documents)
    end

    private

    attr_reader :docs_dir, :build_dir, :assets_dir, :menu_path, :markdown, :layout, :html_formatter, :base_url

    def purge_build
      FileUtils.rm_rf(build_dir)
    end

    def ensure_build_structure
      FileUtils.mkdir_p(build_dir)
      FileUtils.mkdir_p(File.join(build_dir, 'assets'))
    end

    def menu_from_configuration(documents)
      if File.exist?(menu_path)
        MenuConfig.load(menu_path)
      else
        MenuConfig.from_documents(documents)
      end
    end

    def render_document(document, menu)
      html_body = markdown.render(document.body_markdown)
      page = layout.render(document: document, body_html: html_body, menu: menu)
      page = html_formatter.format(page)
      output_path = document.output_path
      FileUtils.mkdir_p(File.dirname(output_path))
      File.write(output_path, page)
    end

    def copy_assets
      copy_asset('style.css')
      copy_asset('app.js')
    end

    def copy_asset(filename)
      source = File.join(assets_dir, filename)
      return unless File.exist?(source)

      destination = File.join(build_dir, 'assets', filename)
      FileUtils.cp(source, destination)
    end

    def generate_sitemap(documents)
      return if documents.empty?

      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.urlset('xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9') do
      documents.each do |document|
        xml.url do
          xml.loc sitemap_location_for(document.route)
          xml.lastmod document.last_modified.utc.iso8601
        end
      end
        end
      end

      File.write(File.join(build_dir, 'sitemap.xml'), builder.to_xml)
    end

    def sitemap_location_for(route)
      normalized_route = route == '/' ? '/' : route
      return normalized_route if base_url.nil? || base_url.empty?

      normalized_base = base_url.end_with?('/') ? base_url.chomp('/') : base_url
      normalized_base + normalized_route
    end
  end
end
