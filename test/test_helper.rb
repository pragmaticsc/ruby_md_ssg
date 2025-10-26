require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'ruby_md_ssg'

TEST_TMP_DIR = File.expand_path('../tmp', __dir__)

FileUtils.mkdir_p(TEST_TMP_DIR)

module RubyMdSsgPathsReset
  def before_setup
    RubyMdSsg::Paths.reset!
    super
  end
end

Minitest::Test.prepend(RubyMdSsgPathsReset)
