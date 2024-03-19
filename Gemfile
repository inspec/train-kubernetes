source 'https://rubygems.org'

gemspec

# Remaining group is only used for development.
group :development do
  gem 'bundler'
  gem 'byebug'
  gem 'inspec', '>= 3.7.11' # We need InSpec for the test harness while developing.
  gem 'minitest'
  gem 'rake'
  gem 'rubocop', '~> 0.59'
  gem "train", git: "https://github.com/inspec/train.git", branch: "bs/fix-CHEF-8031"
end
