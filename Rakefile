require 'bundler/gem_tasks'
require 'rake/testtask'

desc 'Run the test suite'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

desc 'Run RuboCop'
task :lint do
  sh 'bundle exec rubocop'
end

desc 'Build the static site'
task :build do
  sh 'bundle exec ruby exe/static_ruby build'
end

desc 'Serve the static site'
task :serve do
  sh 'bundle exec ruby exe/static_ruby serve'
end

task default: :test
