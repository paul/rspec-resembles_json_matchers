# frozen_string_literal: true

require "rspec/resembles_json_matchers/version"
require "rspec/resembles_json_matchers/string_indent"

module RSpec
  module ResemblesJsonMatchers
    require "rspec/resembles_json_matchers/helpers"
    require "rspec/resembles_json_matchers/attribute_matcher"
    require "rspec/resembles_json_matchers/json_matcher"

    require "rspec/resembles_json_matchers/resembles_any_of_matcher"
    require "rspec/resembles_json_matchers/resembles_route_matcher"
    require "rspec/resembles_json_matchers/resembles_date_matcher"
    require "rspec/resembles_json_matchers/resembles_numeric_matcher"
    require "rspec/resembles_json_matchers/resembles_string_matcher"
    require "rspec/resembles_json_matchers/resembles_boolean_matcher"
    require "rspec/resembles_json_matchers/resembles_nil_matcher"
    require "rspec/resembles_json_matchers/resembles_class_matcher"

    def iso8601_timestamp
      match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
    end

    def match_json(*a)
      JsonMatcher.new(*a)
    end
    alias resemble_json match_json

    def resembles(*a)
      RSpec::ResemblesJsonMatchers.resembles_matcher_for(*a).new(*a)
    end
    alias resemble resembles

    def self.resembles_matcher_candidates
      # Order matters
      @resembles_matcher_candidates ||= [
        JsonMatcher,
        ResemblesAnyOfMatcher,
        ResemblesRouteMatcher,
        ResemblesDateMatcher,
        ResemblesNumericMatcher,
        ResemblesStringMatcher,
        ResemblesBooleanMatcher,
        ResemblesNilMatcher,
        ResemblesClassMatcher
      ].freeze
    end

    def self.resembles_matcher_for(expected, **_a)
      resembles_matcher_candidates.detect { |candidate| candidate.can_match?(expected) } || RSpec::Matchers::BuiltIn::Eq
    end
  end
end
