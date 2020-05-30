# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rspec/resembles_json_matchers"

require "awesome_print"
require "pry-byebug"
require "active_support/core_ext/string/strip"

RSpec.configure do |config|
  config.example_status_persistence_file_path = "tmp/failing_examples.txt"

  config.filter_run_when_matching :focus
  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true

  # config.fail_fast = true
end
