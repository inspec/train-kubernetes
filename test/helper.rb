if ENV["CI_ENABLE_COVERAGE"]
  require "simplecov/no_defaults"
  require_relative "helpers/simplecov_minitest"
  SimpleCov.start do
    add_filter "/test/"
    add_group "Resources", ["lib/train-kubernetes"]
  end
end


require "minitest/autorun"
require "mocha/minitest"
require "byebug"
require "train"
require "train/extras"

module Minitest
  class Test
    def setup
      # TODO: Setup logic
    end
  end
end
