# frozen_string_literal: true

require 'yaml'
require_relative 'paths'

module StaticRuby
  class MenuConfig
    Section = Struct.new(:title, :links, keyword_init: true)
    Link = Struct.new(:label, :route, keyword_init: true)

    def self.load(path = Paths.menu_config)
      return new([]) unless File.exist?(path)

      raw = YAML.safe_load(File.read(path)) || {}
      sections = Array(raw['sections']).map do |section|
        Section.new(
          title: section['title'],
          links: Array(section['links']).map do |link|
            Link.new(label: link['label'], route: link['route'])
          end
        )
      end
      new(sections)
    end

    def self.from_documents(documents)
      grouped = documents.group_by { |doc| top_level_segment(doc.route) }
      sections = grouped.keys.sort.map do |segment|
        docs_in_group = grouped[segment]
        Section.new(
          title: segment_title(segment),
          links: docs_in_group.sort_by(&:route).map do |doc|
            Link.new(label: doc.title, route: doc.route)
          end
        )
      end
      new(sections)
    end

    def initialize(sections)
      @sections = sections
    end

    attr_reader :sections

    def to_h
      {
        'sections' => sections.map do |section|
          {
            'title' => section.title,
            'links' => section.links.map do |link|
              { 'label' => link.label, 'route' => link.route }
            end
          }
        end
      }
    end

    private_class_method def self.top_level_segment(route)
      return 'home' if route == '/'

      route.split('/')[1]
    end

    private_class_method def self.segment_title(segment)
      return 'Home' if segment == 'home'

      segment.to_s.tr('_-', ' ').split.map(&:capitalize).join(' ')
    end
  end
end
