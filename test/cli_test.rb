require_relative 'test_helper'

module RubyMdSsg
  class CLITest < Minitest::Test
    def setup
      @tmp_root = Dir.mktmpdir('static_ruby_cli', TEST_TMP_DIR)
    end

    def teardown
      FileUtils.rm_rf(@tmp_root)
    end

    def test_scaffold_generates_project_structure
      destination = File.join(@tmp_root, 'demo-site')

      RubyMdSsg::CLI::Scaffold.new('demo-site', destination).run

      gemfile = File.read(File.join(destination, 'Gemfile'))
      index = File.read(File.join(destination, 'docs', 'index.md'))
      build_dir = File.join(destination, 'build')
      bin_build = File.join(destination, 'bin', 'build')

      assert_includes gemfile, "gem 'static_ruby'"
      assert_includes index, '# Welcome to Demo Site'
      assert Dir.exist?(build_dir)
      assert File.executable?(bin_build), 'bin/build should be executable'
    end
  end
end
