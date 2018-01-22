require "active_support/core_ext/hash/keys" # stringify_keys
require "json"

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
      all_passed = true
      expected_matchers.each do |key, attr_matcher|
        result = attr_matcher.matches?(actual)
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
        expected.each do |k,v|
          hsh[k.to_s] = AttributeMatcher.new(k, matcherize(v))
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

    def color_lines(text)
      text.split("\n").map do |line|
        case line.chr[0]
          when "-" then red line
          when "+" then green line
        end
      end.compact
    end

    def color(text, color_code)
      "\e[#{color_code}m#{text}\e[0m"
    end

    def red(text)
      color(text, 31)
    end

    def green(text)
      color(text, 32)
    end

    def normal(text)
      color(text, 0)
    end
  end
end
