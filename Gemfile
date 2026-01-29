source "https://rubygems.org"

gemspec

gem "train", git: "https://github.com/inspec/train", branch: "CHEF-28703-update-azure-gems-to-v2"

# Remaining group is only used for development.
group :development do
  gem "bundler"
  gem "byebug"
  gem "inspec", ">= 5.22.72" # We need InSpec for the test harness while developing.
  gem "minitest"
  gem "mocha"
  gem "rake"
  gem "m"
  gem "rubocop"
  gem "chefstyle"
  gem "simplecov"
  gem "simplecov_json_formatter"
  gem "github_changelog_generator"
end
