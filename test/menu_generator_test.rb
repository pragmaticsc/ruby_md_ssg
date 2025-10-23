require 'yaml'
require_relative 'test_helper'

module StaticRuby
  class MenuGeneratorTest < Minitest::Test
    def setup
      @docs_dir = File.join(TEST_TMP_DIR, 'generator_docs')
      @menu_path = File.join(@docs_dir, 'menu.yml')
      FileUtils.rm_rf(@docs_dir)
      FileUtils.mkdir_p(@docs_dir)
    end

    def test_writes_default_menu_when_none_exists
      write_doc('index.md', '# Home')
      write_doc('ideas/government.md', '# Government')

      generator = MenuGenerator.new(docs_dir: @docs_dir, menu_path: @menu_path)
      generator.generate

      menu = YAML.safe_load(File.read(@menu_path))
      assert_equal ['Home', 'Ideas'].sort, menu['sections'].map { |section| section['title'] }.sort
    end

    def test_preserves_existing_order_and_adds_new_links
      write_doc('index.md', '# Home')
      write_doc('ideas/government.md', '# Government')
      write_doc('ideas/participation.md', '# Participation')

      existing_menu = {
        'sections' => [
          {
            'title' => 'Ideas',
            'links' => [
              { 'label' => 'Government', 'route' => '/ideas/government' }
            ]
          }
        ]
      }
      File.write(@menu_path, YAML.dump(existing_menu))

      generator = MenuGenerator.new(docs_dir: @docs_dir, menu_path: @menu_path)
      generator.generate

      menu = YAML.safe_load(File.read(@menu_path))
      ideas_links = menu['sections'].first['links']
      assert_equal ['/ideas/government', '/ideas/participation'], ideas_links.map { |link| link['route'] }
    end

    private

    def write_doc(relative_path, content)
      full_path = File.join(@docs_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content)
      full_path
    end
  end
end
