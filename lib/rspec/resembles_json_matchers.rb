require "rspec/resembles_json_matchers/version"
require "rspec/resembles_json_matchers/string_indent"

module RSpec
  module ResemblesJsonMatchers
    autoload :AttributeMatcher, "rspec/resembles_json_matchers/attribute_matcher"
    # autoload :ResemblesMatcher, "rspec/resembles_json_matchers/resembles_matcher"
    autoload :JsonMatcher,      "rspec/resembles_json_matchers/json_matcher"
    autoload :Helpers,          "rspec/resembles_json_matchers/helpers"
    # autoload :Matcherizer,      "rspec/resembles_json_matchers/matcherizer"

    autoload :ResemblesHashMatcher,    "rspec/resembles_json_matchers/resembles_hash_matcher"
    autoload :ResemblesArrayMatcher,   "rspec/resembles_json_matchers/resembles_array_matcher"
    autoload :ResemblesAnyOfMatcher,   "rspec/resembles_json_matchers/resembles_any_of_matcher"
    autoload :ResemblesRouteMatcher,   "rspec/resembles_json_matchers/resembles_route_matcher"
    autoload :ResemblesDateMatcher,    "rspec/resembles_json_matchers/resembles_date_matcher"
    autoload :ResemblesNumericMatcher, "rspec/resembles_json_matchers/resembles_numeric_matcher"
    autoload :ResemblesStringMatcher,  "rspec/resembles_json_matchers/resembles_string_matcher"
    autoload :ResemblesClassMatcher,   "rspec/resembles_json_matchers/resembles_class_matcher"

    def iso8601_timestamp
      match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
    end

    def match_json(*a)
      JsonMatcher.new(*a)
    end

    def have_attribute(*a)
      AttributeMatcher.new(*a)
    end

    def resembles(*a)
      RSpec::ResemblesJsonMatchers.resembles_matcher_for(*a).new(*a)
    end
    alias resemble resembles
    alias resemble_json resembles

    def self.resembles_matcher_candidates
      # Order matters
      @candidates ||= [
        ResemblesHashMatcher,
        #ResemblesArrayMatcher,
        ResemblesAnyOfMatcher,
        ResemblesRouteMatcher,
        ResemblesDateMatcher,
        ResemblesNumericMatcher,
        ResemblesStringMatcher,
        ResemblesClassMatcher
      ].freeze
    end

    def self.resembles_matcher_for(expected, **a)
      resembles_matcher_candidates.detect { |candidate| candidate.can_match?(expected) }
    end

  end
end
