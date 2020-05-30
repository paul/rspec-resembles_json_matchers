# frozen_string_literal: true

require "active_support/core_ext/array/wrap"

module RSpec::ResemblesJsonMatchers
  class ResemblesAnyOfMatcher
    include Helpers

    def self.can_match?(array)
      array.is_a? Array
    end

    attr_reader :expected, :actual, :original_expected

    def initialize(expected)
      @original_expected = expected
      @expected = expected.map { |e| matcherize(e) }
    end

    def matches?(actual)
      @actual = Array.wrap(actual)
      @matched = @actual.all? do |a|
        expected_matchers.any? { |m| attempted_matchers << m; m.matches? a }
      end
    end

    def matched?
      @matched
    end

    def description
      if @expected.size == 1
        "have every item #{expected_matchers.first.description}"
      else
        "have every item match one of:\n#{expected_formatted}"
      end
    end

    def failure_message; end

    def expected_matchers
      @expected
    end

    def attempted_matchers
      @attempted_matchers ||= []
    end

    def expected_formatted
      out = +""
      out << expected_matchers.map do |v|
        "should #{v.description}".indent(2)
      end.join("\n")
      out << "\n"
      out
    end
  end
end
