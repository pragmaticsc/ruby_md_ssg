require_relative 'test_helper'

module StaticRuby
  class DocumentTest < Minitest::Test
    def setup
      @docs_dir = File.join(TEST_TMP_DIR, 'docs')
      FileUtils.rm_rf(@docs_dir)
      FileUtils.mkdir_p(@docs_dir)
    end

    def test_route_for_root_index
      path = write_doc('index.md', '# Hello')

      Paths.stub(:docs_dir, @docs_dir) do
        document = Document.new(path)
        assert_equal '/', document.route
        assert_equal File.join(Paths.build_dir, 'index.html'), document.output_path
      end
    end

    def test_route_for_nested_document
      path = write_doc('ideas/government.md', '# Governance')
      Paths.stub(:docs_dir, @docs_dir) do
        document = Document.new(path)
        assert_equal '/ideas/government', document.route
        assert_equal File.join(Paths.build_dir, 'ideas', 'government', 'index.html'), document.output_path
      end
    end

    def test_title_prefers_frontmatter
      path = write_doc('ideas/participation.md', <<~MD)
        ---
        title: Civic Participation
        ---
        # Should not be used
      MD

      Paths.stub(:docs_dir, @docs_dir) do
        document = Document.new(path)
        assert_equal 'Civic Participation', document.title
      end
    end

    def test_meta_description_from_frontmatter
      path = write_doc('guides/setup.md', <<~MD)
        ---
        title: Setup Guide
        description: Prepare your environment for Static Ruby.
        ---
        # Setup Guide
        Content body.
      MD

      Paths.stub(:docs_dir, @docs_dir) do
        document = Document.new(path)
        assert_equal 'Prepare your environment for Static Ruby.', document.meta_description
      end
    end

    def test_meta_description_nil_when_absent
      path = write_doc('ideas/inspiration.md', '# Inspiration')

      Paths.stub(:docs_dir, @docs_dir) do
        document = Document.new(path)
        assert_nil document.meta_description
      end
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
