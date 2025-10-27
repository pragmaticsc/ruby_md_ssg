require_relative 'test_helper'

module RubyMdSsg
  class MenuConfigTest < Minitest::Test
    def setup
      @docs_dir = File.join(TEST_TMP_DIR, 'menu_docs')
      FileUtils.rm_rf(@docs_dir)
      FileUtils.mkdir_p(@docs_dir)
      Paths.stub(:docs_dir, @docs_dir) do
        write_doc('index.md', '# Home')
        write_doc('ideas/government.md', '# Government')
        write_doc('ideas/participation.md', '# Participation Works')
        write_doc('guides/setup.md', '# Setup')
      end
    end

    def test_groups_documents_by_top_level_directory
      documents = with_stubbed_paths { DocumentFinder.new(docs_dir: @docs_dir).all }
      menu = MenuConfig.from_documents(documents)

      section_titles = menu.sections.map(&:title)
      assert_equal %w[Guides Home Ideas], section_titles.sort

      ideas_section = menu.sections.find { |section| section.title == 'Ideas' }
      assert_equal ['/ideas/government', '/ideas/participation'], ideas_section.links.map(&:route)
    end

    private

    def write_doc(relative_path, content)
      full_path = File.join(@docs_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content)
      full_path
    end

    def with_stubbed_paths(&)
      Paths.stub(:docs_dir, @docs_dir, &)
    end
  end
end
