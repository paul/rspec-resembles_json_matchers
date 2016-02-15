require "rspec/json_matchers/version"

module Rspec
  module JsonMatchers
    autoload :AttributeMatcher, "rspec/json_matchers/attribute_matcher"
    autoload :JsonMatcher,      "rspec/json_matchers/json_matcher"
    autoload :Helpers,          "rspec/json_matchers/helpers"

    def iso8601_timestamp
      match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
    end

    def match_json(*a)
      JsonMatcher.new(*a)
    end

    def have_attribute(*a)
      AttributeMatcher.new(*a)
    end

  end
end
