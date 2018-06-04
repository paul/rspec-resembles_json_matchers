require "active_support/core_ext/hash/keys" # stringify_keys
require "json"

require "rspec/matchers"
require "rspec/resembles_json_matchers/attribute_differ"

module RSpec::ResemblesJsonMatchers
  class JsonMatcher
    include RSpec::Matchers::Composable
    include Helpers

    def self.can_match?(hash)
      hash.is_a? Hash
    end

    attr_reader :expected, :actual

    def initialize(expected_json)
      @expected = expected_json.try(:deep_stringify_keys)
    end

    def matches?(actual_json)
      @actual = actual_json.try(:deep_stringify_keys)
      # Can't use #all? because it stops on the first false
      all_passed = true
      expected_matchers.each do |key, matcher|
        result = matcher.matches?(actual)
        all_passed &&= result
      end
      all_passed
    end

    def description
      # TODO Figure out how to discover the right indent level
      "have json that looks like\n#{expected_formatted.indent(2)}"
    end

    def failure_message
      AttributeDiffer.new(self).to_s
    end

    def to_json
      failure_message
    end

    def expected_matchers
      @expected_matchers ||= {}.tap do |hsh|
        (expected.keys + actual.keys).uniq.each do |key|
          expected_value = matcherize(expected[key])
          hsh[key.to_s] =
            if !expected.key?(key) then ExtraAttributeMatcher.new(key, expected_value)
            elsif !actual.key?(key) then MissingAttributeMatcher.new(key, expected_value)
            else
              AttributeMatcher.new(key, expected_value)
            end
        end
      end
    end

    def expected_formatted
      out = "{\n"
      out << expected_matchers.map do |k,v|
        %{"#{k}": #{RSpec::Support::ObjectFormatter.format(v.expected_value)}}.indent(2)
      end.join(",\n")
      out << "\n}"
    end

    def actual
      @actual ||= {}
    end

  end
end
