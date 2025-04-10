# frozen_string_literal: true

require "rake/testtask"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

# run tests
desc "default checks"
task default: %i(test:unit)

# Rubocop
desc "Run Rubocop lint checks"
task :style do
  RuboCop::RakeTask.new
end

# lint the project
require "chefstyle"
require "rubocop/rake_task"
RuboCop::RakeTask.new(:lint) do |task|
  task.options << "--display-cop-names"
end

# Automatically generate a changelog for this project. Only loaded if
# the necessary gem is installed.
# use `rake changelog to=1.2.0`
begin
  v = ENV["to"]
  require "github_changelog_generator/task"
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = v
  end
rescue LoadError
  puts ">>>>> GitHub Changelog Generator not loaded, omitting tasks"
end

namespace :test do
  {
      unit: "test/unit/**/*_test.rb",
    }.each do |task_name, glob|
      Rake::TestTask.new(task_name) do |t|
        t.libs.push "lib"
        t.libs.push "test"
        t.test_files = FileList[glob]
        t.verbose = true
        t.warning = false
      end
    end
end
