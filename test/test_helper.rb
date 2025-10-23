require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'static_ruby'

TEST_TMP_DIR = File.expand_path('../tmp', __dir__)

FileUtils.mkdir_p(TEST_TMP_DIR)

module StaticRubyPathsReset
  def before_setup
    StaticRuby::Paths.reset!
    super
  end
end

Minitest::Test.prepend(StaticRubyPathsReset)
