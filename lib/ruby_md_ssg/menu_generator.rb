# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require_relative 'paths'
require_relative 'document_finder'
require_relative 'menu_config'

module RubyMdSsg
  class MenuGenerator
    def initialize(docs_dir: Paths.docs_dir, menu_path: Paths.menu_config)
      @docs_dir = docs_dir
      @menu_path = menu_path
    end

    def generate
      documents = DocumentFinder.new(docs_dir: docs_dir).all
      default_menu = MenuConfig.from_documents(documents)
      config = if File.exist?(menu_path)
                 merge_existing(MenuConfig.load(menu_path), default_menu)
               else
                 default_menu
               end

      serialized = YAML.dump(config.to_h)
      FileUtils.mkdir_p(File.dirname(menu_path))
      existing = File.exist?(menu_path) ? File.read(menu_path) : nil
      File.write(menu_path, serialized) unless existing == serialized
      menu_path
    end

    private

    attr_reader :docs_dir, :menu_path

    def merge_existing(existing, default_menu)
      default_lookup = {}
      default_menu.sections.each do |section|
        default_lookup[normalized(section.title)] = section
      end

      merged_sections = existing.sections.map do |existing_section|
        key = normalized(existing_section.title)
        default_section = default_lookup.delete(key)
        if default_section
          SectionMerger.merge(existing_section, default_section)
        else
          existing_section
        end
      end

      additional_sections = default_lookup.values.sort_by(&:title)
      MenuConfig.new(merged_sections + additional_sections)
    end

    def normalized(value)
      value.to_s.downcase
    end

    module SectionMerger
      module_function

      def merge(existing_section, default_section)
        existing_links = {}
        existing_section.links.each do |link|
          existing_links[normalized(link.route)] = link
        end
        default_section.links.each do |link|
          key = normalized(link.route)
          existing_links[key] ||= link
        end

        merged_links = existing_section.links.map { |link| existing_links[normalized(link.route)] }
        additional_links = existing_links.values.reject { |link| merged_links.include?(link) }
        merged_links += additional_links
        RubyMdSsg::MenuConfig::Section.new(
          title: existing_section.title,
          links: merged_links
        )
      end

      def normalized(value)
        value.to_s.downcase
      end
    end
  end
end
