require "rspec/json_api_matchers/version"

module RSpec
  module ResemblesJsonMatchers
    autoload :AttributeMatcher, "rspec/json_api_matchers/attribute_matcher"
    autoload :ResemblesMatcher, "rspec/json_api_matchers/resembles_matcher"
    autoload :JsonMatcher,      "rspec/json_api_matchers/json_matcher"
    autoload :Helpers,          "rspec/json_api_matchers/helpers"

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
