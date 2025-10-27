require_relative 'test_helper'

module RubyMdSsg
  class CompilerTest < Minitest::Test
    def setup
      @project_root = File.join(TEST_TMP_DIR, 'compile_project')
      @docs_dir = File.join(@project_root, 'docs')
      @build_dir = File.join(@project_root, 'build')
      @assets_dir = File.join(@project_root, 'assets')
      @templates_dir = File.join(@project_root, 'templates')
      FileUtils.rm_rf(@project_root)
      FileUtils.mkdir_p([@docs_dir, @assets_dir, @templates_dir, @build_dir])
      File.write(File.join(@assets_dir, 'style.css'), 'body { color: #000; }')
      File.write(File.join(@assets_dir, 'app.js'), 'console.log("hi");')
      File.write(File.join(@templates_dir, 'layout.html.erb'), <<~ERB)
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title><%= title %></title>
          <% if meta_description && !meta_description.empty? %>
            <meta name="description" content="<%= meta_description %>">
          <% end %>
        </head>
        <body>
          <nav>
            <% menu.sections.each do |section| %>
              <section>
                <h2><%= section.title %></h2>
                <ul>
                  <% section.links.each do |link| %>
                    <li><a href="<%= link.route %>"><%= link.label %></a></li>
                  <% end %>
                </ul>
              </section>
            <% end %>
          </nav>
          <main>
            <%= body_html %>
          </main>
        </body>
        </html>
      ERB
    end

    def test_compile_generates_html_and_copies_assets
      write_doc('index.md', <<~MD)
        ---
        title: Home
        description: Landing page for Ruby MD SSG.
        ---
        # Home
        Welcome to Ruby MD SSG.
      MD
      write_doc('ideas/story.md', '# Story')

      compile

      index_html = File.read(File.join(@build_dir, 'index.html'))
      assert File.exist?(File.join(@build_dir, 'index.html'))
      assert File.exist?(File.join(@build_dir, 'ideas', 'story', 'index.html'))
      assert_includes index_html, '<nav'
      assert_includes index_html, '<meta name="description" content="Landing page for Ruby MD SSG."'
      assert_equal 1, index_html.scan('<h1').count
      assert File.exist?(File.join(@build_dir, 'assets', 'style.css'))
      assert File.exist?(File.join(@build_dir, 'assets', 'app.js'))

      sitemap = File.read(File.join(@build_dir, 'sitemap.xml'))
      assert_includes sitemap, '<loc>https://example.test/</loc>'
      assert_includes sitemap, '<loc>https://example.test/ideas/story</loc>'
      assert_includes sitemap, '<lastmod>'
    end

    private

    def compile
      with_stubbed_paths do
        compiler = Compiler.new(
          docs_dir: @docs_dir,
          build_dir: @build_dir,
          assets_dir: @assets_dir,
          menu_path: File.join(@docs_dir, 'menu.yml'),
          base_url: 'https://example.test'
        )
        compiler.compile
      end
    end

    def with_stubbed_paths(&block)
      Paths.stub(:root, @project_root) do
        Paths.stub(:docs_dir, @docs_dir) do
          Paths.stub(:build_dir, @build_dir) do
            Paths.stub(:assets_dir, @assets_dir) do
              Paths.stub(:templates_dir, @templates_dir, &block)
            end
          end
        end
      end
    end

    def write_doc(relative_path, content)
      full_path = File.join(@docs_dir, relative_path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content)
      full_path
    end
  end
end
